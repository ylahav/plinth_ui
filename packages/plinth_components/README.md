# plinth_components

51 themeable Flutter widgets — [Plinth UI](https://github.com/ylahav/plinth_ui),
a component library in the spirit of [Mantine](https://mantine.dev).

Every component reads its color, spacing, and radius from a single
`PlinthTheme` ([`plinth_core`](https://pub.dev/packages/plinth_core)),
so swapping a palette restyles the whole app.

## Getting started

Register the theme once, at your app root:

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    extensions: [PlinthTheme.defaultTheme],
  ),
  home: const MyHomePage(),
)
```

Then use any component:

```dart
PlinthButton(
  onPressed: () {},
  color: 'blue',
  child: const Text('Save'),
)
```

## What's included

- **Primitives** — Button, ActionIcon, Box, Text, Divider, Kbd, Code, Mark
- **Forms** — TextInput, Textarea, PasswordInput, Checkbox,
  Radio/RadioGroup, Select, SegmentedControl, NumberInput, Chip,
  Rating, Slider, Switch
- **Feedback** — Badge, Alert, Progress, RingProgress, Notification,
  Skeleton, Spoiler, LoadingOverlay
- **Data display** — Avatar, ThemeIcon, Indicator, ColorSwatch, Table
- **Navigation** — Tabs/TabView, Accordion, Stepper, Breadcrumbs,
  Pagination, Timeline, NavLink
- **Surfaces** — Paper, Card, Blockquote, Anchor, CopyButton
- **Overlays** — Modal, Drawer, Popover, Menu, Tooltip, Affix

Full prop reference for every component:
[docs/COMPONENTS.md](https://github.com/ylahav/plinth_ui/blob/main/docs/COMPONENTS.md).

## Live example

The repository includes a live example app (compiles to Web and
Desktop) demonstrating every component with a "Show code" toggle on
each section — see the
[repository README](https://github.com/ylahav/plinth_ui) for how to
run it.

## Notable design choices

- Several components deliberately wrap Flutter's own widgets rather
  than reimplementing them — `PlinthSlider` wraps `Slider`,
  `PlinthTooltip` wraps `Tooltip`, `PlinthTable` wraps `Table` (not
  `DataTable`, whose built-in Material styling fights against a
  themeable design system more than it helps).
- Overlay components (`PlinthModal`, `PlinthDrawer`, `PlinthPopover`,
  `PlinthMenu`) share a `PlinthDisclosureController`
  ([`plinth_hooks`](https://pub.dev/packages/plinth_hooks)) for
  open/close state, so one controller can coordinate a trigger and
  the overlay it opens.
- Controlled-component pairs (`PlinthTabs`/`PlinthTabView`,
  `PlinthStepper`, `PlinthSegmentedControl`) split the visual
  indicator from content ownership — you own the state, the widget
  just reflects it.

See [CHANGELOG.md](https://github.com/ylahav/plinth_ui/blob/main/packages/plinth_components/CHANGELOG.md)
for release notes.
