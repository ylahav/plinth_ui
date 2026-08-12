# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to adhere to [Semantic Versioning](https://semver.org/)
once it reaches a `1.0.0` release. Versions before `1.0.0` may include
breaking changes without a major version bump.

## 0.2.0

### Added
- **Contrast-aware color resolution.** Measured against WCAG, the
  palette was failing badly in three separate ways, and each needed a
  different fix:

  - `contrastingOn(background)` picks a foreground by the *fill's*
    lightness. White on `yellow` measured 2.12:1 and on `teal` 1.82:1,
    against the 4.5:1 AA asks for — a filled button whose label you
    could see but not read. Which way it should fall depends on the
    fill, not the theme.
  - `shaded(name, shade)` and `shadeFor(shade)` mirror a shade for the
    theme's brightness. A shade-0 wash is nearly white behind a dark
    alert, and a shade-6 accent measured 1.97:1 as text on the dark
    surface. Mirroring keeps each shade's role while flipping its
    lightness.
  - `readableOn(name, background)` walks the ramp for a shade that
    clears a contrast threshold. Mirroring can't fix this half: the
    ramps differ in intrinsic lightness, so no single index serves
    every hue — `violet` at shade 6 reads comfortably on white where
    `cyan` at shade 6 lands at 2.19:1.

  Use `shaded` for fills, `contrastingOn` for what sits on them, and
  `readableOn` for a palette colour used as text or an icon.
- `onFilledInverse`, the dark counterpart to `onFilled`, for fills too
  light to carry white text.

### Changed
- Components resolving a palette colour now go through these rather
  than a fixed shade 6. Colours that already met contrast — `blue`,
  `red`, `violet`, `indigo`, `grape`, `pink` — are unaffected; the
  lighter half of the palette changes appearance, which is the point.

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
