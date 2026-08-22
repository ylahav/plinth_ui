# plinth_core

Design tokens and theme foundation for [Plinth UI](https://github.com/ylahav/plinth_ui)
— colors, spacing, radius, and typography scales that every Plinth
component reads from.

This package is the theme layer only. For the actual widgets
(buttons, inputs, cards, and 112 others), see
[`plinth_components`](https://pub.dev/packages/plinth_components).

## Usage

Register `PlinthTheme` once, at your app root:

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    extensions: [PlinthTheme.defaultTheme],
  ),
)
```

Every Plinth widget reads its colors, spacing, and radius from this
theme via `context.plinth` — a single palette swap restyles the whole
app. `PlinthTheme` generates a full 10-shade ramp from a single base
color per palette entry, using non-linear lightness stops and
shade-dependent saturation rather than plain linear interpolation, so
light shades read as soft tints and dark shades stay rich rather than
just fading to gray.

## What's in this package

- `PlinthTheme` — the `ThemeExtension<PlinthTheme>` holding color
  palettes, spacing, radius, and font-size scales.
- `PlinthSize` (`xs`–`xl`) and `PlinthVariant` (`filled`, `light`,
  `outline`, `subtle`, `transparent`, `defaultVariant`) — shared
  tokens used consistently across every Plinth component.
- `context.plinth` — convenience extension for accessing the active
  theme from any `BuildContext`.

See the [full documentation](https://github.com/ylahav/plinth_ui) for
the complete component reference and a live example app.
