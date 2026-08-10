# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to adhere to [Semantic Versioning](https://semver.org/)
once it reaches a `1.0.0` release. Versions before `1.0.0` may include
breaking changes without a major version bump.

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
