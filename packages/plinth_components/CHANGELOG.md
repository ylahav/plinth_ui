# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to adhere to [Semantic Versioning](https://semver.org/)
once it reaches a `1.0.0` release. Versions before `1.0.0` may include
breaking changes without a major version bump.

## 0.0.1 — Initial development release

51 themeable components, all reading color/spacing/radius from a single
`PlinthTheme` (`plinth_core`). See `docs/COMPONENTS.md` in the repository
for the full prop reference.

### Primitives
`PlinthButton`, `PlinthActionIcon`, `PlinthBox`, `PlinthText`,
`PlinthDivider`, `PlinthKbd`, `PlinthCode`, `PlinthMark`.

### Forms
`PlinthTextInput`, `PlinthTextarea`, `PlinthPasswordInput`,
`PlinthCheckbox`, `PlinthRadio` / `PlinthRadioGroup`, `PlinthSelect`,
`PlinthSegmentedControl`, `PlinthNumberInput`, `PlinthChip`,
`PlinthRating`, `PlinthSlider`, `PlinthSwitch`.

### Feedback
`PlinthBadge`, `PlinthAlert`, `PlinthProgress`, `PlinthRingProgress`,
`PlinthNotification`, `PlinthSkeleton`, `PlinthSpoiler`,
`PlinthLoadingOverlay`.

### Data Display
`PlinthAvatar`, `PlinthThemeIcon`, `PlinthIndicator`,
`PlinthColorSwatch`, `PlinthTable`.

### Navigation
`PlinthTabs` / `PlinthTabView`, `PlinthAccordion`, `PlinthStepper`,
`PlinthBreadcrumbs`, `PlinthPagination`, `PlinthTimeline`,
`PlinthNavLink`.

### Surfaces
`PlinthPaper`, `PlinthCard`, `PlinthBlockquote`, `PlinthAnchor`,
`PlinthCopyButton`.

### Overlays
`PlinthModal`, `PlinthDrawer`, `PlinthPopover`, `PlinthMenu`,
`PlinthTooltip`, `PlinthAffix`.

### Notes on this release
- `PlinthMark` and `PlinthCode`'s single positional content field is
  named `label`, matching `PlinthBadge`/`PlinthKbd`/`PlinthAnchor`'s
  convention for the same pattern (found and fixed during an API
  consistency pass — see the main README's "API consistency review"
  section for the full audit).
- Golden (visual regression) test coverage currently exists only for
  `PlinthButton` — other components have behavior tests but not
  appearance tests yet.
- Widgetbook gallery entries use static per-variant use cases rather
  than interactive knobs; the knob API wasn't verified against a live
  SDK during initial development.
