# Plinth UI

**A design-token engine for Flutter — and 115 components built on it, so
you can see that it holds up.**

- **Colour resolves against a WCAG contrast floor**, not a fixed shade.
  Ask for a palette colour as *text* and you get a shade that clears
  4.5:1 against the background it actually sits on.
- **Ramps are anchored to your own colour.** Feed in `#FF3B30`, ask for
  shade 6, get `#FF3B30` back — not something near it.
- **Name colours by role** — `expense`, `income`, `brand` — rather than
  by hue, each with its own contrast floor.
- **Keep your existing `ThemeData`.** `colorSchemeDisagreements` reports
  where your `ColorScheme` and your tokens disagree, instead of asking
  you to replace one with the other.

Mantine-inspired rather than a port: 112 components track
`@mantine/core` because its answer was right, and three exist because
Flutter asked a question a web library never had to.

[![CI](https://github.com/ylahav/plinth_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/ylahav/plinth_ui/actions/workflows/ci.yml)

🌐 **[Live demo](https://ylahav.github.io/plinth_ui/)** · 🎛️ **[Widgetbook gallery](https://ylahav.github.io/plinth_ui/widgetbook/)**

📖 **[Component reference](docs/COMPONENTS.md)** · 🧭 **[Adopting tokens](docs/ADOPTING_TOKENS.md)** · 🧱 **[Showcase blocks](docs/SHOWCASE.md)** · 🧪 **[Testing guide](docs/TESTING.md)** · 🔍 **[Pre-1.0 audit](docs/PRE_1_0_AUDIT.md)** · 🗺️ **[Roadmap](docs/ROADMAP.md)**

Both are the real apps in this repo, built for the web and deployed on
every push to `main` by `.github/workflows/pages.yml`. The demo is the
curated tour — every component, plus the composed blocks, each with its
source. The gallery is the exhaustive one: every state of every
component, with knobs to poke at them.

> **Testing either demo with a screen reader?** Press `Tab` once from
> the top of the page and `Enter` before anything else.
>
> Flutter web builds its accessibility tree only on demand, behind an
> invisible "Enable accessibility" button, and until that is activated
> the semantics are not in the page at all — every control is silent.
> The web gives no way to detect a screen reader (deliberately: it
> would fingerprint users and disclose a disability to every site), so
> Flutter uses a button no mouse will ever find and every screen reader
> will, and treats reaching it as the signal.
>
> These demos are left at that default on purpose, so they behave like
> any Flutter web app rather than flattering this one. An app that
> would rather always pay the cost can call
> `SemanticsBinding.instance.ensureSemantics()` at startup and skip the
> button entirely.
>
> It needs redoing after every reload. Full instructions, including how
> to confirm it worked without a screen reader, are in
> [B0C_SCREEN_READER_PASS.md](docs/B0C_SCREEN_READER_PASS.md); what was
> heard when it was run is in [B0C_FINDINGS.md](docs/B0C_FINDINGS.md).

## Using Plinth in your app

All three packages are published on pub.dev. `plinth_components` is the
one most apps want, and it brings `plinth_core` (the theme) with it:

```bash
flutter pub add plinth_components
```

Add `plinth_hooks` as well if you use any of the overlay components —
`PlinthModal`, `PlinthDrawer`, `PlinthPopover`, `PlinthMenu`, and
`PlinthDialog` each take a `PlinthDisclosureController` from it:

```bash
flutter pub add plinth_hooks
```

### 1. Register the theme

Every component resolves its colors, spacing, and radii from a
`PlinthTheme` registered as a `ThemeData` extension. This is the one
required step — skip it and the components have no tokens to read.

```dart
import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
      home: const SignUpPage(),
    );
  }
}
```

Registering `darkTheme` is all dark mode takes. The palette ramps are
shared between the two — a blue button is the same blue either way —
and only the neutral chrome inverts.

### 2. Build with the components

```dart
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: PlinthCard(
            child: PlinthStack(
              children: [
                const PlinthTitle('Create an account', order: 3),
                const PlinthTextInput(
                  label: 'Email',
                  placeholder: 'you@example.com',
                ),
                const PlinthTextInput(label: 'Password', obscureText: true),
                PlinthButton(
                  onPressed: () {},
                  fullWidth: true,
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 3. Make it yours

`PlinthTheme.defaultTheme` is a starting point, not a fixed identity.
`copyWith` covers the usual reskin:

```dart
final theme = PlinthTheme.defaultTheme.copyWith(
  primaryColor: 'violet',
  defaultRadius: PlinthSize.lg,
);
```

Every `color:` prop on a component is a key into the palette ramps
(`'blue'`, `'red'`, `'teal'`, and ten more), and `primaryColor` is the
key components fall back to when you don't pass one. Sizes and spacing
go through the shared `PlinthSize` scale (`xs` … `xl`) rather than raw
pixel values, so `spacing`, `radius`, and `fontSizes` can be retuned in
one place.

**[docs/COMPONENTS.md](docs/COMPONENTS.md)** is the full prop reference
for all 115 components, and the theme-token table there explains which
color method to reach for (`shaded`, `contrastingOn`, `readableOn`)
when you build your own widget on the same foundation.

### 4. Running against a local checkout

Sooner or later you'll want to patch `plinth_core` locally — to debug
something, or to try a token change before asking for it. Adding it as
a path dependency **does not work**, and the error is not obviously
about what it is about:

```
Because your_app depends on plinth_components ^1.0.1 which
depends on plinth_core ^1.0.1, plinth_core from hosted is
required. So, because your_app depends on plinth_core from path,
version solving failed.
```

This is the first thing an adopter hits, before writing any Dart. Use
`dependency_overrides`, which is root-only and exists for exactly this:

```yaml
# your_app/pubspec.yaml
dependencies:
  plinth_components: ^1.0.1

dependency_overrides:
  plinth_core:
    path: ../plinth_ui/packages/plinth_core
  # If you're patching the widgets too, override both — otherwise
  # plinth_components still comes from pub.dev and won't see your
  # changes.
  plinth_components:
    path: ../plinth_ui/packages/plinth_components
```

**Loosening our version constraints would not have helped**, which is
worth saying because it is the natural first guess. Pub allows one
*source* per package in a resolution, so a path dependency in your app
conflicts with the hosted one `plinth_components` pulls in no matter how
wide the version range is — `plinth_core: any` fails the same way.
`dependency_overrides` is the mechanism, not a workaround for a
constraint we set too tightly.

Remove the overrides before you publish or ship; they are ignored for
anyone consuming your package, so an override that silently became
load-bearing is a bug you won't see until someone else builds your code.

Encouraging data point from doing this for real: `plinth_components
0.16.1`, compiled against `plinth_core 0.2.0`, ran clean against
`plinth_core 1.0.0-beta.1` — a major version later. The core's API has
stayed genuinely backward compatible.

## Working on Plinth itself

### Repository layout

```
plinth_ui/
  melos.yaml               # workspace config
  .github/workflows/ci.yml # analyze + format + test on every push/PR (see below)
  .github/workflows/regenerate-goldens.yml # manual — regenerates goldens on Linux to match CI
  packages/
    plinth_core/            # PlinthTheme, design tokens (colors, spacing, radius)
    plinth_components/       # Widgets — see docs/COMPONENTS.md for the full,
    │                          up-to-date list with props for each one
    plinth_hooks/             # PlinthDisclosureController (useDisclosure equivalent)
  example/                  # Showcase app — run this to see the components live
  widgetbook/               # Isolated component gallery (manual/non-codegen setup)
  docs/
    ROADMAP.md                # The single plan — who it is for, what is
    │                           done, what is next, and what is declined
    COMPONENTS.md             # Per-component prop reference
    ADOPTING_TOKENS.md        # What adopting tokens costs an app, and
    │                           the five patterns every adopter hits
    TESTING.md                # How to verify this locally — SDK setup
    │                           through golden tests
    PUBLISHING.md             # Release order, and the mistake that has
    │                           already shipped once
    SHOWCASE.md               # The example app's composed blocks
    ADOPTION_REQUIREMENTS.md  # What a real app needed and could not get.
    │                           All 19 closed
    PHASE_MINUS_1_FINDINGS.md # What happened when plinth_core was tried
    │                           against that app — including the
    │                           predictions it falsified
    APP_VALIDATION_PLAN.md    # That app as a standing harness
    PRE_1_0_AUDIT.md          # How complete each component is
    B0C_SCREEN_READER_PASS.md # The one accessibility task a person has
    │                           to run
```


Clone, bootstrap, and run one of the two demo apps:

```bash
git clone https://github.com/ylahav/plinth_ui.git
cd plinth_ui

# Melos manages the three packages as a single workspace (one-time install)
dart pub global activate melos

# Links the packages to each other and fetches dependencies
melos bootstrap

# The showcase app — every component wired together in one scrollable demo
cd example && flutter run

# ...or the Widgetbook gallery — each component's variants as separate use cases
cd ../widgetbook && flutter run
```

### Making a change

A component change touches more than its widget file. Every component
commit in this repo follows the same round, and skipping a step is what
leaves the docs drifting from the code:

1. The widget in `packages/plinth_components/lib/src/widgets/`
2. Its `export` in `packages/plinth_components/lib/plinth_components.dart`
3. Widget tests in `packages/plinth_components/test/`
4. Widgetbook use cases in `widgetbook/lib/main.dart`, including a
   knob-driven **Playground**
5. The prop reference in `docs/COMPONENTS.md` (and remove the entry from
   its *Coming soon* list if you just built one)
6. `CHANGELOG.md` and a version bump in `pubspec.yaml`

Then verify exactly what CI verifies, from the repo root:

```bash
melos run format     # fails if anything needs reformatting
melos run analyze
melos run test
```

`melos run format-fix` applies the formatting rather than just checking
it. One expected local failure: the `PlinthButton` golden test fails on
Windows and macOS by design, because the reference images are rendered
on Linux to match CI. Diffs under ~1% there are platform rendering
noise, not regressions — read `docs/TESTING.md` §7 before chasing one,
and don't regenerate goldens locally (there's a
`regenerate-goldens.yml` workflow that does it on Linux).

### The example app

The example app demonstrates most components in one scrollable page —
run it to see them live, or browse `docs/COMPONENTS.md` for the
complete reference without running anything. It has a persistent
sidebar (wide screens) or drawer menu (narrow screens) that jumps to
any section, a small branded hero at the top, and a **"Show code"**
toggle on every section that reveals the exact source used for that
demo (with a copy button). Those snippets live as hand-maintained
string literals in `example/lib/src/demo_code.dart` (and
`src/showcase/examples_code.dart` for the composed examples) — they
are *not* extracted at build time, so nothing enforces that they
match the widgets they mirror. Update the snippet alongside any demo
you edit; a stale one still compiles and still renders a working code
panel, which is what makes the drift easy to miss.

## Running the example app on Web and Desktop

`web/` is checked in for both `example/` and `widgetbook/`, which is
what lets the Pages workflow build them. The desktop folders
(`windows/`, `macos/`, `linux/`) are not — Flutter generates those from
a template tied to your exact SDK version, so create them locally if
you want a desktop build:

```bash
cd example
flutter create --platforms=windows,macos,linux .
```

That adds the platform folders without touching `lib/main.dart` or
`pubspec.yaml`. After that:

```bash
# Web
flutter run -d chrome

# Windows (on a Windows machine)
flutter run -d windows

# macOS (on a macOS machine)
flutter run -d macos

# Linux (on a Linux machine)
flutter run -d linux
```

Desktop targets only build on their matching OS — you can't build a
Windows `.exe` from macOS, for instance. Web builds anywhere. To
produce a shareable web build (e.g. for GitHub Pages):

```bash
flutter build web --release
# output lands in example/build/web/ — serve that directory statically
```

The Widgetbook app organizes the same components into browsable categories
(Buttons & Actions, Forms, Navigation, Feedback, Overlays, Data Display,
Surfaces, Layout & Typography) with each variant as its own use case in
the sidebar.

## What's implemented

- **`PlinthTheme`** (`plinth_core`) — a `ThemeExtension` holding color
  ramps (curve-based 10-shade generator with non-linear lightness
  stops + shade-dependent saturation), spacing, radius, and font-size
  scales, plus surface/text/border tokens for the neutral chrome the
  ramps don't cover.
- **Light and dark themes** — register `PlinthTheme.darkTheme`
  alongside `defaultTheme` and the whole library follows. The ramps are
  shared between them (a blue button is the same blue either way); only
  the chrome inverts. See
  **[docs/COMPONENTS.md § Theme tokens](docs/COMPONENTS.md#theme-tokens)**.
- **115 components** across Primitives, Forms, Feedback, Data Display,
  Navigation, Surfaces, and Overlays — full list with props in
  **[docs/COMPONENTS.md](docs/COMPONENTS.md)**, kept current every round
  rather than duplicated here. A few architectural patterns worth
  knowing up front:
  - Several components deliberately **wrap Flutter's own widgets**
    rather than reimplementing them — `PlinthSlider` (`Slider`),
    `PlinthTooltip` (`Tooltip`), `PlinthTable` (`Table`, not
    `DataTable`) — because drag handling, accessibility, and layout
    correctness aren't worth re-deriving from scratch.
  - **Overlays** (`PlinthModal`, `PlinthDrawer`, `PlinthPopover`,
    `PlinthMenu`) share a `PlinthDisclosureController`
    (`plinth_hooks`) for open/close state. Modal/Drawer additionally
    share an internal `PlinthOverlayHost`; Popover/Menu use their own
    show/hide mechanics since they aren't route-based.
  - **Controlled-component pairs** split visual indicator from content
    ownership — `PlinthTabs`/`PlinthTabView`, `PlinthStepper` (visual
    only), `PlinthSegmentedControl` all leave state ownership to the
    caller rather than managing it internally.
- **Widgetbook gallery** (`widgetbook/`) — manual (non-codegen)
  registration of every component's key states as browsable use cases,
  with a knob-driven **Playground** for 107 of the 115 components
  alongside the static variant grids (the two answer different
  questions: a playground explores combinations, a grid compares
  options side by side). A smoke test builds all 225 use cases in CI,
  so a page that compiles but throws on render is caught before anyone
  opens it. `web/` is checked in — `cd widgetbook && flutter run -d
  chrome`.
- **Tests** — pure-logic tests for `PlinthTheme`'s shade generator and
  `PlinthDisclosureController`, a golden (visual regression) test suite
  for `PlinthButton` (variants, a color override, disabled state, all
  sizes), and widget behavior tests across 65 test files. **Every
  public component has at least one test** — the only untested class is
  `PlinthOverlayHost`, which is internal and exercised indirectly
  through `PlinthModalHost`/`PlinthDrawerHost`.

  Coverage is behavioral rather than visual, so it pins down what a
  component *does*, not how it looks: border-colour precedence on
  `PlinthTextInput` (error beats focus), overlay teardown across
  repeated open/close cycles, controlled components reporting the value
  they would become rather than changing it themselves, and the
  fallback paths that only appear when something fails —
  `PlinthAvatar`'s missing-image chain, `PlinthImage`'s broken-URL
  icon.
  Notable coverage: `PlinthPagination`'s ellipsis-collapse logic at large
  page counts, `PlinthAccordion`'s single/multiple-open modes,
  `PlinthCopyButton`'s clipboard write + timer-based revert,
  `PlinthMenu`/`PlinthNotification`'s overlay-dismissal behavior. See
  `docs/TESTING.md` for the full breakdown and how to run them.
  Golden coverage spans `PlinthButton`, `PlinthTextInput` (focus and
  error borders), `PlinthAlert` (colour tinting), and the components
  that place things by arithmetic rather than by layout —
  `PlinthRollingNumber`, the two arc progress widgets,
  `PlinthAngleSlider`, `PlinthOverflowList` and the colour sliders.
  43 images. That last group exists because a behaviour test can only
  confirm the number that went in: `PlinthRollingNumber` shipped
  rendering 58,210 as nearly 68,210 while 494 tests passed.
  The reference images are Linux-rendered to match CI, so they can only
  pass on Linux. `dart_test.yaml` tags them and excludes that tag on
  Windows and macOS, which is why a local `flutter test` is green: they
  run in CI, where their result means something, and are skipped where
  it wouldn't. See `docs/TESTING.md` §7.
- **CI is green** — `.github/workflows/ci.yml` passes end-to-end
  (bootstrap, format, analyze, test) on GitHub Actions as of this
  writing. Getting there surfaced two real, non-obvious issues worth
  knowing about if you add more golden tests or touch formatting:
  golden images are platform-sensitive (see `docs/TESTING.md` §7 —
  regenerate on Linux via `.github/workflows/regenerate-goldens.yml`,
  don't loosen tolerances), and `dart format` needs to actually be run
  locally at least once (`melos run format-fix`) since code written
  without a live SDK won't match its output exactly.

## API consistency review

Before locking in any version number, every component's public
constructor was audited against the others for naming/type drift. One
real inconsistency was found and fixed: `PlinthMark` and `PlinthCode`
used `text` for their single positional content field while
`PlinthBadge`/`PlinthKbd`/`PlinthAnchor` (the same "wraps one short
string" pattern) used `label` — both renamed to `label` for consistency.
Since the field is positional-only, this didn't require updating any
call sites (`PlinthMark('...')` is unaffected by the internal field
name). `PlinthText.data` was deliberately left as-is — it intentionally
mirrors Flutter's own built-in `Text.data`, not an inconsistency.

Several other apparent differences were checked and confirmed
intentional rather than bugs:
- `onTap` (`PlinthNavLink`, `PlinthAnchor`, `PlinthColorSwatch`) vs.
  `onPressed` (`PlinthButton`, `PlinthActionIcon`) mirrors Flutter's own
  split — `ListTile`/`InkWell`-style tappable tiles use `onTap`,
  button-styled widgets use `onPressed`.
- `PlinthAlert`/`PlinthNotification` use a non-nullable `color` with a
  `'blue'` default, unlike every other component's nullable `color`
  falling back to the theme's primary color — deliberate, since a
  feedback banner reading in your brand's primary color regardless of
  intent (info vs. error vs. success) would be a worse default than a
  conventional blue.
- `PlinthBadge`/`PlinthTooltip` default to `PlinthSize.sm` rather than
  the `.md` every other component defaults to — matches how badges and
  tooltips actually look in practice; defaulting them to `.md` would
  make them oversized by default.
- Five form-field components (`TextInput`, `Textarea`, `PasswordInput`,
  `NumberInput`, `Select`) have an explicit `enabled: bool` alongside a
  nullable `onChanged`, while every other interactive component infers
  disabled state purely from a null callback. Justified: for a text
  field, "no `onChanged` provided" and "field is disabled" are
  genuinely different states (a read-only-but-still-selectable field
  vs. a grayed-out, non-focusable one) — for a button, they're the
  same state.

## Next steps (not yet built)

- ~~Extend golden test coverage beyond `PlinthButton`~~ — done, twice.
  `PlinthTextInput` and `PlinthAlert` first, then the components that
  compute their own offsets and angles, which is where the two real
  visual bugs found so far both lived. 43 images. The remaining
  candidates are lower value: `PlinthBadge`'s variants and
  `PlinthLoader`'s three types are conditional but not computed, so a
  behaviour test already reaches most of what could break.
- ~~Consider hue-drift at the extremes of the color-shade ramp~~ —
  tried and rejected. One signed drift can't suit every hue: rotating
  darks the same way sends red toward magenta and yellow toward orange
  (fine) but blue toward cyan (worse). Doing it properly needs per-hue
  drift tables rather than a formula. Contrast wasn't the blocker —
  the WCAG suite passed throughout. See `_generateShades`.
- Extend the composed-blocks showcase — 110 examples against Mantine
  UI's ~123. **Page Sections is complete**, no subcategory is empty
  since `PlinthCarousel` closed Carousels, and none is more than two
  behind except Inputs. Nothing is blocked on a missing component. See
  **[docs/SHOWCASE.md](docs/SHOWCASE.md)**.
- ~~Bring the example app's component tour up to date~~ — done. All
  112 Mantine-parity components have a section, and
  `example/test/section_coverage_test.dart` now holds the section list
  against the snippet map so the two can't drift apart silently.

  The three Flutter-specific additions — `PlinthLtr`, `PlinthFocusTrap`,
  `PlinthTapTarget` — deliberately have no tour section. Each is
  behaviour rather than appearance (a pinned text direction, a focus
  boundary, a minimum hit area), and a section showing one would be a
  screenshot of nothing. `PlinthLtr` has a Widgetbook use case, where a
  side-by-side comparison actually shows something.
- ~~Make a local `flutter test` quiet again~~ — done. The golden tests
  carry `@Tags(['golden'])` and `dart_test.yaml` excludes that tag on
  Windows and macOS only, so they still run in CI. Note this also means
  you can't force them on locally with `--tags golden`; the OS
  exclusion wins. That's deliberate — they cannot pass off Linux — but
  it's worth knowing before you go looking for the flag.
- Fill in pub.dev's discoverability fields — the package scores
  160/160 on pana but ships no `topics:` and no `screenshots:` in its
  pubspec, which are the two things that make it findable by someone
  who isn't already looking for it.
