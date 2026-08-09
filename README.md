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
    plinth_components/       # Widgets (Button, ActionIcon, CopyButton, Box, Text,
    │                          Divider, Kbd, Anchor, Blockquote, Modal, Drawer,
    │                          TextInput, Textarea, PasswordInput, Checkbox,
    │                          Radio/RadioGroup, Select, Badge, Alert, Switch, Slider,
    │                          Progress, Spoiler, LoadingOverlay, Avatar, ThemeIcon,
    │                          Indicator, ColorSwatch, Table, Accordion, Stepper,
    │                          Breadcrumbs, Pagination, Timeline, NavLink,
    │                          Notification, Skeleton, Paper, Card, SegmentedControl,
    │                          NumberInput, Chip, Rating, Tooltip, Popover,
    │                          Tabs/TabView, Menu)
    plinth_hooks/             # PlinthDisclosureController (useDisclosure equivalent)
  example/                  # Showcase app — run this to see every component live
  widgetbook/               # Isolated component gallery (manual/non-codegen setup)
  docs/
    COMPONENTS.md            # Per-component prop reference
    TESTING.md                # How to verify this locally — SDK setup through golden tests
```

[![CI](https://github.com/ylahav/plinth_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/ylahav/plinth_ui/actions/workflows/ci.yml)

📖 **[Component reference](docs/COMPONENTS.md)** · 🧪 **[Testing guide](docs/TESTING.md)**

## First push to GitHub

Repo: https://github.com/ylahav/plinth_ui — `melos.yaml`'s `repository:`
field and the CI badge above are already pointed at it. If this workspace
isn't a git repo yet locally:

```bash
git init
git add .
git commit -m "Initial scaffold: Plinth UI monorepo"
git branch -M main
git remote add origin https://github.com/ylahav/plinth_ui.git
git push -u origin main
```

The CI badge won't show a real pass/fail status until the first workflow
run completes — that happens automatically once this push lands, since
`.github/workflows/ci.yml` triggers on `push` to `main`. A `.gitignore` is
already in place; it deliberately keeps `test/goldens/*.png` tracked
(those are reference images the tests compare against, not build output)
while excluding `.dart_tool/`, `build/`, and the Melos-generated
`pubspec_overrides.yaml` files.

## Getting started (run this locally — Flutter isn't available in the sandbox this was generated in)

```bash
# 1. Activate melos globally (one-time)
dart pub global activate melos

# 2. From the plinth_ui/ root, bootstrap the workspace
melos bootstrap

# 3. Run the example app (all components wired together in one scrollable demo)
cd example
flutter run

# 4. Or run the Widgetbook gallery (each component's variants as separate use cases)
cd ../widgetbook
flutter run
```

The example app demonstrates every component in one scrollable page —
run it to see the full set live, or browse `docs/COMPONENTS.md` for the
complete reference without running anything.

The Widgetbook app organizes the same components into browsable categories
(Buttons & Actions, Forms, Navigation, Feedback, Overlays, Data Display,
Surfaces, Layout & Typography) with each variant as its own use case in
the sidebar.

## What's implemented

- **`PlinthTheme`** (`plinth_core`) — a `ThemeExtension` holding color
  ramps (curve-based 10-shade generator with non-linear lightness
  stops + shade-dependent saturation), spacing, radius, and font-size
  scales.
- **47 components** across Primitives, Forms, Feedback, Data Display,
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
  registration of every component's key states as browsable use cases.
- **Tests** — pure-logic tests for `PlinthTheme`'s shade generator and
  `PlinthDisclosureController`, a golden (visual regression) test suite
  for `PlinthButton` (variants, a color override, disabled state, all
  sizes), and widget behavior tests for most other components — 19 test
  files covering the majority of the 47 public components as of this
  writing.
  Notable coverage: `PlinthPagination`'s ellipsis-collapse logic at large
  page counts, `PlinthAccordion`'s single/multiple-open modes,
  `PlinthCopyButton`'s clipboard write + timer-based revert,
  `PlinthMenu`/`PlinthNotification`'s overlay-dismissal behavior. See
  `docs/TESTING.md` for the full breakdown and how to run them.
- **CI is green** — `.github/workflows/ci.yml` passes end-to-end
  (bootstrap, format, analyze, test) on GitHub Actions as of this
  writing. Getting there surfaced two real, non-obvious issues worth
  knowing about if you add more golden tests or touch formatting:
  golden images are platform-sensitive (see `docs/TESTING.md` §7 —
  regenerate on Linux via `.github/workflows/regenerate-goldens.yml`,
  don't loosen tolerances), and `dart format` needs to actually be run
  locally at least once (`melos run format-fix`) since code written
  without a live SDK won't match its output exactly.

## Next steps (not yet built)

- Add knobs to the Widgetbook use cases (`context.knobs.*`) once the
  installed `widgetbook` version's knob API is confirmed — the current
  gallery uses static use cases per variant instead, to avoid guessing
  at an API surface that couldn't be verified in this sandbox.
- Extend golden test coverage beyond `PlinthButton` — `PlinthTextInput`
  (focus/error border states) and `PlinthAlert` (color tinting) are the
  next highest-value targets, since they have the most conditional
  visual logic. See `docs/TESTING.md`.
- Consider hue-drift at the extremes of the color-shade ramp for
  richer darks/lights (currently hue is held fixed).
- Pin the Flutter version in `.github/workflows/ci.yml` (currently
  tracks the `stable` channel) once you've confirmed the version
  you're developing against locally.
- Publishing prep: `CHANGELOG.md` per package, decide on a version
  bump strategy (`melos version` now works since `repository:` is set).

## Naming note

Package name `plinth` / `plinth_ui` was verified unclaimed on pub.dev as
of this session (Aug 2026) — re-check before publishing, since
availability can change.
