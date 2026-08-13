# Plinth UI

A Mantine-inspired component library for Flutter — themeable widgets built
on a shared design-token foundation.

## Structure

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
    COMPONENTS.md            # Per-component prop reference
    SHOWCASE.md               # The example app's composed blocks, and what's missing
    TESTING.md                # How to verify this locally — SDK setup through golden tests
```

[![CI](https://github.com/ylahav/plinth_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/ylahav/plinth_ui/actions/workflows/ci.yml)

📖 **[Component reference](docs/COMPONENTS.md)** · 🧱 **[Showcase blocks](docs/SHOWCASE.md)** · 🧪 **[Testing guide](docs/TESTING.md)**

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
for all 101 components, and the theme-token table there explains which
color method to reach for (`shaded`, `contrastingOn`, `readableOn`)
when you build your own widget on the same foundation.

## Working on Plinth itself

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

The `example/` app has no platform folders checked in yet (`web/`,
`windows/`, `macos/`, `linux/`) — Flutter generates these from a
template tied to your exact installed SDK version, so they need to be
created locally rather than hand-written here. One-time setup:

```bash
cd example
flutter create --platforms=web,windows,macos,linux .
```

This adds the platform folders without touching `lib/main.dart` or
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
- **101 components** across Primitives, Forms, Feedback, Data Display,
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
  with a knob-driven **Playground** for 96 of the 101 components
  alongside the static variant grids (the two answer different
  questions: a playground explores combinations, a grid compares
  options side by side). A smoke test builds all 213 use cases in CI,
  so a page that compiles but throws on render is caught before anyone
  opens it. `web/` is checked in — `cd widgetbook && flutter run -d
  chrome`.
- **Tests** — pure-logic tests for `PlinthTheme`'s shade generator and
  `PlinthDisclosureController`, a golden (visual regression) test suite
  for `PlinthButton` (variants, a color override, disabled state, all
  sizes), and widget behavior tests across 42 test files. **Every
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
  Note that the golden test fails locally on Windows/macOS by design
  (the reference images are Linux-rendered to match CI) — see
  `docs/TESTING.md` §7 before chasing it.
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

- Extend golden test coverage beyond `PlinthButton` — `PlinthTextInput`
  (focus/error border states) and `PlinthAlert` (color tinting) are the
  next highest-value targets, since they have the most conditional
  visual logic. See `docs/TESTING.md`.
- Consider hue-drift at the extremes of the color-shade ramp for
  richer darks/lights (currently hue is held fixed).
- Extend the composed-blocks showcase — 12 examples against Mantine
  UI's 123, with Authentication, Stats, Error pages, and Footers
  entirely empty. Most need no new components. See
  **[docs/SHOWCASE.md](docs/SHOWCASE.md)**.

## Naming note

Package name `plinth` / `plinth_ui` was verified unclaimed on pub.dev as
of this session (Aug 2026) — re-check before publishing, since
availability can change.
