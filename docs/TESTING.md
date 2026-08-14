# Testing Plinth UI

Everything in this repo was written without a Dart/Flutter SDK available
(the sandbox it was generated in doesn't have one) — it's been checked for
bracket balance and read through carefully, but **not compiled**. This guide
is your first real checkpoint: a short sequence that will surface any
mistakes fast, followed by how the different test layers work going forward.

## 1. Confirm the SDK is there

```bash
flutter --version
dart --version
```

If these fail, install Flutter first (https://docs.flutter.dev/get-started/install)
— everything below assumes a working `flutter`/`dart` on your PATH.

## 2. Bootstrap the workspace

```bash
dart pub global activate melos   # one-time
cd plinth_ui
melos bootstrap
```

`melos bootstrap` runs `flutter pub get` (or `dart pub get`) across every
package in the monorepo and links the local path dependencies
(`plinth_components` → `plinth_core` + `plinth_hooks`, etc.) together. This
step alone will catch:
- Typos in `pubspec.yaml` dependency names/paths
- A package whose `pubspec.yaml` I forgot to update after adding an import

## 3. Static analysis — catches most of what I couldn't verify

```bash
melos run analyze
```

(Or per-package: `cd packages/plinth_components && dart analyze .`)

This is the single highest-value command to run first. It will catch:
- Missing imports (e.g. if `plinth_alert.dart` uses a type I forgot to import)
- Type errors, undefined named parameters, unhandled enum cases
- Anything a compiler would reject — everything I could only check by eye

If this comes back clean, the vast majority of "did the AI actually write
valid Dart" risk is resolved. If it doesn't, paste me the errors — most
are fixable in one exchange.

## 4. Formatting

```bash
melos run format-fix
```

Applies formatting fixes across every package (equivalent to `dart format .`
with no flags). Run this once after cloning — the files in this repo were
originally written without a local Dart SDK to format against, so several
needed reformatting the first time this ran for real.

Then verify with the check-only version (this is what CI runs):

```bash
melos run format
```

This uses `dart format . --set-exit-if-changed`, which fails if anything
still needs reformatting rather than silently fixing it — that's
intentional for a CI check, but means `format` alone won't fix a failure,
only report one. If `melos run format` fails, run `melos run format-fix`,
then commit the result.

## 5. Run the actual tests

```bash
melos run test
```

This runs `flutter test` in every package that has a `test/` directory.
Three packages have tests checked in already, ordered roughly cheapest to
most expensive:

| Package | File | What it checks |
|---|---|---|
| `plinth_hooks` | `plinth_disclosure_controller_test.dart` | Pure Dart logic — `open()`/`close()`/`toggle()` semantics, listener notification, no-op guards. No widget pumping, runs in milliseconds. |
| `plinth_core` | `plinth_theme_test.dart` | The color-shade generator produces 10 shades per color, shade 0 is lighter than shade 9, unknown color names fall back to `primaryColor`, out-of-range shade indices don't throw, every `PlinthSize` has spacing/radius/fontSize entries. |
| `plinth_components` | `plinth_button_test.dart` | Widget-level: renders its label, `onPressed` fires on tap, a disabled button doesn't fire, every `PlinthVariant` renders without hitting an unhandled switch case, and the button exposes `SemanticsFlag.isButton` for accessibility. |

Run a single package's tests directly when iterating on it:

```bash
cd packages/plinth_core && flutter test
cd packages/plinth_hooks && flutter test
cd packages/plinth_components && flutter test
```

## 6. Manual verification — the example app and Widgetbook

Static analysis and unit tests won't catch everything, especially for the
overlay components (`PlinthModal`, `PlinthDrawer`, `PlinthPopover`) where
positioning and animation only really show themselves on screen.

```bash
cd example && flutter run
```

Walk through every section in the scrollable demo: toggle the checkbox,
open the radio group / select, type into the text input and confirm the
error state appears/clears, open the modal and drawer, tap the popover
trigger. Pay particular attention to:
- **`PlinthPopover`** — the newest and most structurally complex piece
  (`CompositedTransformFollower` + manual `OverlayEntry`). Confirm it
  appears anchored correctly below its trigger, dismisses on an outside
  tap, and doesn't leave a stray overlay entry behind after repeated
  open/close cycles (watch for it visually "stacking" — that would mean
  `_hide()` isn't being called somewhere).
- **`PlinthModal` / `PlinthDrawer`** — confirm the Cancel/Delete buttons
  inside the modal actually close it (this is the `Builder`-scoped
  `Navigator.of(dialogContext)` pattern — a mistake there would leave the
  buttons doing nothing rather than throwing a visible error).

```bash
cd widgetbook && flutter run
```

Browse every category in the sidebar. Since the gallery deliberately uses
**static use cases instead of interactive knobs** (documented in the code
and in the main README's "Next steps"), each variant is its own entry
rather than something you toggle — so "does it look right" is really the
main thing to check here, alongside confirming nothing throws when you
navigate between use cases.

## 7. Golden tests

`PlinthButton` now has a real golden test suite —
`packages/plinth_components/test/plinth_button_golden_test.dart` — covering
the filled variant, outline variant, a light/red combination, disabled
state, and all five sizes side by side. Unlike the behavior tests in
`plinth_button_test.dart` (does the callback fire, does it render), these
check *appearance*: each test renders the widget to an image and diffs it
against a committed reference file.

**First-time setup — generate the reference images:**

```bash
cd packages/plinth_components
flutter test --update-goldens
```

or across every package with a `test/` directory at once:

```bash
melos run update-goldens
```

This creates `packages/plinth_components/test/goldens/*.png`. **Commit
these files** — they're the reference every future test run compares
against, not build artifacts to gitignore.

**Every run after that:**

```bash
flutter test test/plinth_button_golden_test.dart
```

If a future change to `PlinthButton` (or `PlinthTheme`'s color-shade
generator, since golden images bake in whatever colors were active when
generated) alters its appearance, this test fails with an image diff
instead of silently shipping a visual regression. When the change is
intentional, re-run `flutter test --update-goldens` and commit the updated
images alongside the code change that caused them.

**Why these are reproducible across machines/CI without extra setup:**
`flutter test` renders with a placeholder test font by default rather than
your system's real fonts — text shows as solid blocks, not glyphs. That's
what makes the images bit-for-bit identical on any machine; it does mean
these tests won't catch a font-rendering regression specifically, but they
do catch color, layout, padding, and border changes, which covers the vast
majority of what could actually go wrong in a themed component.

**Extending this pattern to other components:** copy
`plinth_button_golden_test.dart`'s `_goldenWrap` helper (or share one via a
`test/helpers/` file once you have three or more golden test files) and
follow the same shape — `RepaintBoundary` with a stable `Key`, sized to a
fixed rectangle, one `matchesGoldenFile` call per state worth locking down
visually. Not every component needs golden coverage on day one; prioritize
the ones most likely to have a subtle visual regression slip through
(anything with conditional border/background logic, like `PlinthTextInput`'s
focus/error states or `PlinthAlert`'s color tinting) over ones that are
mostly just text (`PlinthText`, `PlinthBadge`'s label).

**Regenerate on CI, not locally — and note the workflow is pinned.**
`regenerate-goldens.yml` pins the same `flutter-version` as `ci.yml`
(3.44.8). That pin is load-bearing: it previously tracked `stable`
while CI pinned, and so produced reference images CI then rejected by
about 44 pixels of corner antialiasing per widget — a failure that
looks exactly like a visual regression and isn't one. **Bump both
workflows together**, and regenerate the images when you do.

**Platform sensitivity — read this before regenerating goldens locally.**
Golden images are sensitive to the platform they were generated on: font
hinting and anti-aliasing differ slightly between Windows, macOS, and
Linux, even though Flutter's placeholder test font makes them
reproducible *within* a platform. If you run `--update-goldens` on
Windows or macOS and CI runs on `ubuntu-latest` (as this repo's does),
expect small pixel diffs (typically under 1%) that are platform
rendering noise, not real regressions.

The fix isn't to loosen the comparison tolerance — it's to generate the
reference images on the same platform CI uses. Use the
**"Regenerate goldens"** workflow
(`.github/workflows/regenerate-goldens.yml`): trigger it manually from
the Actions tab (`workflow_dispatch`), it runs `melos run update-goldens`
on `ubuntu-latest` and uploads the resulting `test/goldens/` folders as a
downloadable artifact. Download that artifact, replace your local
`test/goldens/*.png` files with its contents, review the diff (`git diff`
won't show a meaningful text diff for binary PNGs, but `git status` will
show which files changed), and commit.

If you only have Windows/macOS available and don't want to touch GitHub
Actions for this, running goldens inside a Linux Docker container with
the same Flutter version installed would work equivalently — the
regenerate-goldens workflow is just a ready-made way to get an Ubuntu
environment without setting that up yourself.

**Important consequence, once you've regenerated goldens on Linux:**
your local `flutter test` on Windows/macOS will now show the *same kind*
of small pixel diff on the golden test — just flipped, since the
reference images are now Linux-rendered and your local machine isn't.
This is expected, not a regression — don't chase it locally. Treat
GitHub Actions CI (which runs on `ubuntu-latest`, matching the goldens)
as the source of truth for whether golden tests actually pass. If a
local golden failure is the *only* failure and CI is green, there's
nothing to fix.

## 8. Continuous integration

`.github/workflows/ci.yml` runs the exact sequence documented above —
bootstrap, analyze, format check, test — automatically on every push and
pull request to `main`, plus a manual `workflow_dispatch` trigger. It's
split into separate steps rather than one combined script so a failure in
analyze doesn't hide whether format/test would also have failed — you get
the full picture from one CI run instead of fixing issues one at a time
across several pushes.

If a golden test fails in CI, the workflow uploads the `failures/` folder
Flutter writes next to the test (containing the actual-vs-expected images)
as a build artifact, so you can download and inspect the diff directly
from the Actions run rather than only seeing a red X.

The Flutter version is currently unpinned (`channel: stable`) — worth
pinning to a specific version once you've confirmed what you're
developing against locally (there's a commented `flutter-version:` line
in the workflow file ready to uncomment), since an unpinned channel means
CI can start failing from an SDK upgrade alone, with no code change to
point to as the cause.

## Summary — the fastest path to confidence

```bash
melos bootstrap && melos run format-fix && melos run analyze && melos run test
```

If all three checks (`analyze`, `format`, `test`) succeed — `format-fix`
itself never fails, it just applies changes — you can trust the code
compiles, is internally consistent, is formatted the way CI expects, and
the logic and appearance covered by tests behaves as documented. `PlinthButton` has both behavior and golden coverage as of
this writing; everything else still needs the manual pass in step 6 for
appearance, and the "Next steps" list in the main README tracks which
components are next in line for golden tests.
