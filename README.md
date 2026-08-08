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
    plinth_components/       # Widgets (Button, ActionIcon, Box, Text, Divider, Modal,
    │                          Drawer, TextInput, Textarea, PasswordInput, Checkbox,
    │                          Radio/RadioGroup, Select, Badge, Alert, Switch, Slider,
    │                          Progress, Avatar, Table, Accordion, Stepper,
    │                          Breadcrumbs, Pagination, Timeline, Notification,
    │                          Skeleton, Paper, Card, SegmentedControl, NumberInput,
    │                          Chip, Rating, Tooltip, Popover, Tabs/TabView, Menu)
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

You should see, in the example app: a dismissible info Alert, badges, a checkbox,
a radio group, a select, a text input with live validation, a menu, tabs with
switched content, progress bars, a slider, an accordion, a striped table, a
notification trigger, an interactive stepper, skeleton loaders, breadcrumbs,
a divider (plain and labeled), a card with header/footer, a segmented control,
a number input with +/- steppers, filterable chips, a star rating, icon-only
action buttons, a textarea, a password field with visibility toggle,
pagination, an order-status timeline, drawer/modal/popover triggers, a
themed Box/Text/disclosure demo, and the full button variant/size/color
matrix — all driven by `PlinthTheme.defaultTheme` in `plinth_core`.

The Widgetbook app organizes the same components into browsable categories
(Buttons & Actions, Forms, Navigation, Feedback, Overlays, Data Display,
Surfaces, Layout & Typography) with each variant as its own use case in
the sidebar.

## What's implemented

- **`PlinthTheme`** (`plinth_core`) — a `ThemeExtension` holding color
  ramps (curve-based 10-shade generator with non-linear lightness
  stops + shade-dependent saturation), spacing, radius, and font-size
  scales.
- **Primitives** (`plinth_components`) — `PlinthButton`, `PlinthActionIcon`
  (icon-only, same variant/size/color pattern as Button), `PlinthBox`,
  `PlinthText`, `PlinthDivider` (plain, labeled, or vertical).
- **Forms** — `PlinthTextInput`, `PlinthTextarea`, `PlinthPasswordInput`
  (show/hide toggle), `PlinthCheckbox`, `PlinthRadio` /
  `PlinthRadioGroup`, `PlinthSelect`, `PlinthSegmentedControl`,
  `PlinthNumberInput` (shares TextInput's chrome, +/- steppers with
  min/max clamping), `PlinthChip`, `PlinthRating` (half-star support
  for read-only display).
- **Feedback** — `PlinthBadge`, `PlinthAlert`, `PlinthProgress`,
  `PlinthNotification` (toast-style, shown via the static `.show()`
  as a themed `SnackBar` — distinct from `PlinthAlert`'s inline
  callout), `PlinthSkeleton` (pulsing loading placeholder).
- **Data display** — `PlinthAvatar` (image → initials → icon fallback chain),
  `PlinthTable` (built on Flutter's `Table`, not `DataTable`).
- **Navigation** — `PlinthTabs` / `PlinthTabView` (underline tab bar +
  fade-switched content, generic over the tab value type),
  `PlinthAccordion` (single/multiple-open expand/collapse),
  `PlinthStepper` (numbered step indicator — visual only, same
  controlled-component split as Tabs/TabView), `PlinthBreadcrumbs`
  (last item always non-interactive, matching the "current page isn't
  a link" convention), `PlinthPagination` (ellipsis-collapsed for
  large page counts), `PlinthTimeline` (dot markers + connecting
  line via `IntrinsicHeight`/`Expanded`).
- **Surfaces** — `PlinthPaper` (base surface: padding, radius, shadow,
  border) and `PlinthCard` (built on `PlinthPaper`, adds an optional
  header/footer section convention with dividers).
- **Overlays** — `PlinthModal`, `PlinthDrawer`, `PlinthPopover` (anchored,
  `CompositedTransformFollower`-based, tracks its target across scroll),
  `PlinthMenu` (built directly on `PlinthPopover`), `PlinthTooltip`
  (themed wrapper over Flutter's built-in `Tooltip`).
  Modal/Drawer are driven by a shared `PlinthDisclosureController`
  (`plinth_hooks`) and a shared internal `PlinthOverlayHost`; Popover/Menu
  use the same controller type but their own show/hide mechanics since
  they aren't route-based.
- **`PlinthSwitch`** — animated toggle, same size/color pattern as Checkbox.
- **`PlinthSlider`** — themed wrapper around Flutter's built-in `Slider`
  (via `SliderTheme`), same rationale as `PlinthTooltip` — drag handling
  and accessibility aren't worth reimplementing.
- **Widgetbook gallery** (`widgetbook/`) — manual (non-codegen)
  registration of every component's key states as browsable use cases.
- **Tests** — a first checked-in test per package: pure-logic tests for
  `PlinthTheme`'s shade generator and `PlinthDisclosureController`,
  widget behavior test suites for `PlinthButton`, `PlinthTabs`/
  `PlinthTabView`, `PlinthMenu`, `PlinthAccordion`, `PlinthTable`,
  `PlinthStepper`, `PlinthSkeleton`, `PlinthNotification`,
  `PlinthBreadcrumbs`, `PlinthCard`/`PlinthPaper`, `PlinthNumberInput`,
  `PlinthChip`/`PlinthRating`/`PlinthSegmentedControl`,
  `PlinthPagination` (including its ellipsis-collapse logic at large
  page counts), and `PlinthActionIcon`/`PlinthTextarea`/
  `PlinthPasswordInput`/`PlinthTimeline`, plus a golden (visual
  regression) test suite for `PlinthButton` covering variants, a
  color override, disabled state, and all sizes.
  See `docs/TESTING.md`.
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
