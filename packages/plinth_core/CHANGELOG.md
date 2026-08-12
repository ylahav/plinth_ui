# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to adhere to [Semantic Versioning](https://semver.org/)
once it reaches a `1.0.0` release. Versions before `1.0.0` may include
breaking changes without a major version bump.

## 0.1.0

### Added
- **Dark mode.** `PlinthTheme.darkTheme` sits alongside `defaultTheme`,
  and a `brightness` field says which is which:

  ```dart
  MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
  )
  ```

  The color ramps are shared rather than darkened — a blue button is
  the same blue in either theme, as in Mantine. What changes is the
  neutral chrome the ramps never covered.
- Surface, text, and border tokens for that chrome: `surface`,
  `surfaceMuted`, `surfaceSunken`, `border`, `borderMuted`, `text`,
  `textMuted`, `textDisabled`, plus `onFilled`, `shadow`, and `scrim`.

  `onFilled` deliberately does not follow `brightness`: a filled
  button is saturated in either theme, so its label stays light in
  both. Flipping it with the theme is how you get dark text on a
  dark-blue button.

  The light values are exactly the literals components hardcoded
  before, so registering `defaultTheme` renders identically to 0.0.1.

- Nine more color ramps in `PlinthTheme.defaultTheme`, bringing it to
  Mantine's standard set: `pink`, `grape`, `violet`, `indigo`, `cyan`,
  `teal`, `lime`, `yellow`, and `orange` join `gray`, `red`, `blue`,
  and `green`.

  This fixes colors that silently rendered as the primary blue.
  `color()` falls back to `primaryColor` for an unrecognized name, so a
  palette missing a color callers reasonably expect doesn't fail — it
  quietly renders the wrong thing, which is harder to spot than an
  error. `PlinthBadge(color: 'grape')` was blue; it is now grape.
- `PlinthTheme.hasColor(name)`, for telling a real ramp from one that
  would fall back — useful when offering swatches rather than
  rendering one.

### Changed
- `PlinthMark` now picks up the real `yellow` ramp instead of its
  literal amber fallback, since the theme defines `yellow` at last.
  Its highlight shifts slightly as a result.

## 0.0.1 — Initial development release

- `PlinthTheme`: a `ThemeExtension<PlinthTheme>` holding the design-token
  layer every Plinth component reads from — color palettes, spacing,
  corner radius, and font-size scales, keyed by `PlinthSize`.
- Color-shade generator: produces a 10-shade ramp (`PlinthColorShades`)
  from a single base color, using non-linear lightness stops and
  shade-dependent saturation rather than plain linear interpolation, so
  light shades read as soft tints and dark shades stay rich.
- `context.plinth` extension for convenient theme access from any
  `BuildContext`.
- Shared tokens: `PlinthSize` (`xs`–`xl`) and `PlinthVariant`
  (`filled`, `light`, `outline`, `subtle`, `transparent`,
  `defaultVariant`) used consistently across every component in
  `plinth_components`.
