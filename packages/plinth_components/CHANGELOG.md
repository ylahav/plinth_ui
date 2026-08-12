# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to adhere to [Semantic Versioning](https://semver.org/)
once it reaches a `1.0.0` release. Versions before `1.0.0` may include
breaking changes without a major version bump.

## 0.6.0

### Changed
- Requires `plinth_core` ^0.1.0, which widens the default palette from
  four colors to Mantine's standard thirteen. Colors that previously
  fell back to the primary blue — `grape`, `orange`, and the rest — now
  render as themselves. `PlinthMark`'s highlight shifts slightly, since
  it picks up the real `yellow` ramp instead of its literal amber
  fallback.

### Added
- Behavior tests for every previously untested component, including
  `PlinthTextInput`'s border precedence, the Modal/Drawer/Popover
  lifecycle, and the controlled-component contract shared by
  Checkbox/Switch/Slider/Radio/Select. Every public component now has
  at least one test.

## 0.5.0

### Added
- `PlinthAppShell` — the page scaffold: header, footer, navbar, aside,
  and a main region, each optional and taking no space when omitted.
  Collapsing is controlled by the caller rather than by an internal
  breakpoint, since the surrounding page needs that same state to
  drive a `PlinthBurger` or a `PlinthDrawer`.
- `PlinthGrid` + `PlinthGridCol` — a responsive 12-column grid where
  each column declares its span, optionally per breakpoint. Spans
  apply from their breakpoint upward, so the unqualified `span` is the
  smallest case, matching CSS media queries. Complements
  `PlinthSimpleGrid`, which is for uniform equal-width items.
- `PlinthLoader` — a standalone loading indicator in `oval`, `dots`,
  and `bars` types. `PlinthLoadingOverlay` already showed a spinner,
  but only while covering existing content.
- `PlinthTitle` — semantic `h1`–`h6` headings. Unlike a large
  `PlinthText`, this exposes heading semantics and level to assistive
  technology, so a page becomes navigable by its headings.

75 components total.

## 0.4.1

### Fixed
- `PlinthSpoiler` reported a `RenderFlex` overflow (and painted
  overflow stripes) whenever its collapsed content was a `Column` or
  `Row` taller than `maxHeight` — the exact case it exists to handle.
  The child was laid out *within* `maxHeight`, so a widget that
  manages its own overflow reported one; the surrounding `ClipRect`
  hid the painting but not the error. It is now laid out at its
  natural height and clipped to the viewport. A `Text` child was
  unaffected, which is why every existing usage looked correct.

## 0.4.0

### Added
- `PlinthFlex` — direction-configurable flex layout with a
  consistent gap; `PlinthGroup` specialized to a fixed horizontal
  direction, `PlinthFlex` for when the direction itself needs to
  vary.
- `PlinthImage` — network image with an automatic loading
  placeholder and error fallback.
- `PlinthScrollArea` — a scrollable region with a themed,
  always-visible, draggable scrollbar.
- `PlinthPortal` — renders its child into the ambient `Overlay`
  rather than in place; the primitive every other overlay component
  in this library is already built on, exposed directly.

71 components total.

## 0.3.0

### Added
- `PlinthCenter` — thin themed wrapper around `Center`, for API
  consistency with the rest of the library.
- `PlinthAspectRatio` — thin themed wrapper around `AspectRatio`,
  commonly paired with images or embeds.
- `PlinthGroup` — horizontal layout with a consistent gap, wraps
  onto a new line by default when children overflow (unlike a plain
  `Row`, which just overflows) — the common "row of chips/tags"
  need.
- `PlinthList` + `PlinthListItem` — bulleted or numbered list, with
  each item able to override its own marker (e.g. a checklist mixing
  checkmarks and crosses).
- `PlinthContainer` — max-width content wrapper that centers its
  child, the standard "page content shouldn't get absurdly wide"
  primitive.
- `PlinthSpace` — a themed fixed-size spacer resolved through
  `theme.spacing`.
- `PlinthUnstyledButton` — a bare tap target with no visual chrome,
  for fully custom-styled clickable elements.
- `PlinthSimpleGrid` — a non-scrolling grid with a fixed number of
  columns and consistent spacing.

67 components total.

## 0.2.0

### Added
- `PlinthPinInput` — segmented OTP/PIN entry, one box per character,
  with auto-advancing focus as digits are typed and auto-retreating
  focus on backspace from an already-empty box.
- `PlinthButtonGroup` — visually joins a row of buttons into one
  connected group (shared borders, squared-off inner corners).
- `PlinthOverlay` — generic dimming backdrop, distinct from
  `PlinthLoadingOverlay` (which always shows a spinner and always
  blocks pointer events) — this is the more general primitive for
  dimming a background without necessarily blocking interaction.
- `PlinthVisuallyHidden` — content visible to screen readers but not
  sighted users, for supplementary context on icon-only controls.

59 components total.

## 0.1.0

### Added
- `PlinthBurger` — animated hamburger→X toggle icon.
- `PlinthHoverCard` — hover-triggered anchored panel (desktop/web),
  the same underlying `CompositedTransformTarget`/`Follower` technique
  as `PlinthPopover` but with its own implementation, since a hover
  trigger and a "stay open while the pointer travels onto the panel"
  grace period don't fit `Popover`'s tap-based design.
- `PlinthRangeSlider` — dual-thumb range slider, wrapping Flutter's
  built-in `RangeSlider` (same rationale as `PlinthSlider`).
- `PlinthMultiSelect<T>` + `PlinthMultiSelectOption<T>` — multi-value
  select with removable chips in the field and a dropdown to add more.

55 components total.

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
