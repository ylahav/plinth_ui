# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to adhere to [Semantic Versioning](https://semver.org/)
once it reaches a `1.0.0` release. Versions before `1.0.0` may include
breaking changes without a major version bump.

## 0.15.0

### Added — the combobox primitives

The gap list said these were "only worth it if several of the above
land and start duplicating logic". They had: `PlinthTagsInput` carried
a private `_TagChip` and `PlinthMultiSelect` used Flutter's raw `Chip`
for the same job, in the same shape, with different sizing.

- **`PlinthPill`** — a removable value chip, and a real extraction:
  both components now render their values with it and their own
  versions are gone. `Chip` modelled the delete affordance correctly
  but carried Material's sizing and colours through a themed field.

  Three chip-shaped things now live here and they are deliberately not
  interchangeable: `PlinthBadge` is a **label** (states something, does
  nothing), `PlinthChip` is a **toggle** (selected/unselected), and
  this is a **value** (one entry in a collection, whose only action is
  to leave). A remove button means something different from a selected
  state, and conflating them makes both call sites read wrong.

  Its remove button names its value — "Remove design" — so a field of
  them isn't a row of identical "close" buttons to a screen reader.

- **`PlinthPillsInput`** — the field chrome around those pills, for
  when neither MultiSelect nor TagsInput fits and the values come from
  somewhere else. Deliberately presentational: `focused` is passed in
  rather than tracked, because whatever owns the input inside owns its
  focus node, and two widgets disagreeing about focus is worse than one
  prop.

- **`PlinthCombobox`** — the option-list primitive. The genuinely
  shared, genuinely fiddly part: an anchored overlay that tracks its
  field, a highlight that moves with the arrow keys and **skips
  disabled options** (one the keyboard lands on is a trap), Enter to
  take it, Escape to abandon it, and a list that stays in sync when its
  options are replaced underneath — which filtering does on every
  keystroke.

  Opening highlights the current value rather than the top, so the
  first arrow press moves from where you are; the highlight stops at
  the ends rather than wrapping, since wrapping past the bottom of a
  long filtered list reads as a glitch; and opening takes keyboard
  control *only if nothing inside the target already has it*, so a
  text-field target keeps its caret while the arrows still reach the
  list.

  **Mantine's `Combobox.Dropdown` is folded in rather than exported
  separately.** In React the dropdown is distinct markup; here the
  overlay is plumbing, and `PlinthPopover` already covers "anchored
  panel with arbitrary content". A second wrapper would be API surface
  with nothing behind it.

  The existing four dropdown-shaped components keep their own
  mechanics. This is for building the next one.

Two Flutter traps worth recording, both found by tests: `setState` in a
`dispose` path throws on a defunct element, and it wasn't needed at all
here — the panel is the overlay's and the highlight is only read while
building it. And a `Focus` that never receives focus never receives key
events, which is why opening requests it conditionally rather than not
at all.

104 components, 99 playgrounds, 218 Widgetbook use cases.

## 0.14.0

### Added — sorting and filtering on `PlinthTable`

`sortable` makes every header tappable with a direction caret;
`filter` keeps only rows containing that text across every column;
`emptyState` replaces the rows when nothing matches.

Both need something comparable, and **a widget cell has no value to
compare** — one `PlinthBadge` isn't greater or less than another. So
`PlinthTable.text` sorts and filters out of the box, while the widget
constructor takes `sortValues`: the plain strings standing behind the
widgets. Passing `sortable` or `filter` without them asserts in debug
rather than silently doing nothing, which is the failure mode worth
avoiding — a filter box that quietly never filters looks like a data
bug, not an API mistake.

Two details that are easy to get wrong and are pinned by tests:
sorting is **numeric where both sides parse as numbers**, so a score
column orders 9 before 10 rather than after it; and it is **stable**,
because Dart's `sort` isn't, so equal keys keep their original order
instead of reshuffling on every rebuild.

Uncontrolled by default. `onSortChanged` takes it over — the table
then reports the sort it would apply and leaves the row order alone,
which is what a server-side or paginated table needs.

### Added — the tree and hierarchy set

- **`PlinthTree`** — expandable hierarchical navigation, controlled.
  Expansion and selection are tracked by node `value` rather than
  position, so a tree can be reordered or lazily filled without losing
  its open branches. Arrow up/down move between rows, right opens a
  branch, left closes it or steps out. Only branches carry an expanded
  state in semantics: a leaf announcing "collapsed" would be claiming
  it opens.

- **`PlinthTreeSelect`** — a select whose options have structure.
  Opening it expands the branches down to the current value, because a
  field claiming to show a selection three levels deep should not hide
  it. `selectableBranches: false` makes branches open-only.

- **`PlinthCascader`** — column-by-column selection. The same data
  `PlinthTreeSelect` shows, for a different question: a tree is for
  *finding* something in a structure you explore, this is for *walking
  a known path* where every level is a real decision. Its value is the
  path rather than a leaf, which keeps a partial selection
  representable instead of treating it as an error.

- **`PlinthTableOfContents`** — a jump list of a page's headings.
  **Headings are passed in, not discovered:** Flutter has no document
  to walk, and crawling the widget tree for `PlinthTitle`s would be
  fragile and blind to anything not yet built in a lazy list. Indent is
  relative to the shallowest heading present, so a document starting at
  level 2 isn't permanently indented.

### Fixed

- **`PlinthPopover` never rebuilt its overlay panel when its content
  changed.** An open popover was frozen at whatever it was built with,
  so anything interactive inside one — a tree that expands, a form that
  validates — silently stopped updating. Found by putting a
  `PlinthTree` in one.

  The fix has a wrinkle worth recording: `didUpdateWidget` runs *during*
  the build phase, and marking an `OverlayEntry` dirty then is illegal,
  because the entry isn't a descendant and the framework may already
  have walked past it. The rebuild is deferred to a post-frame callback.
  `PlinthDialog` carried the same illegal call from 0.11.0 and is fixed
  the same way.

101 components, 96 playgrounds, 213 Widgetbook use cases.

## 0.13.0

### Added

The colour inputs — the last large gap in the Forms category, and the
one where the interesting work was accessibility rather than painting.

- **`PlinthColorPicker`** — saturation/brightness area, hue, and
  optionally opacity. **It remembers the last meaningful hue**, which
  is the difference between a picker that works and one that quietly
  loses your colour: hue is undefined for greys and blacks, where
  `HSVColor` reports 0, so reading it straight back snaps the picker to
  red the moment brightness hits zero — and then the hue slider appears
  dead on a black. Keeping the hue separately is what lets the two
  controls behave independently.

  A related trap, found while writing the test for it: the remembered
  hue was a `late` field, and a lazy initialiser runs at first *read* —
  which is only ever the moment the hue has already gone undefined. It
  reliably recorded the 0 it existed to avoid. Captured eagerly now.

  Without `withAlpha` the picker forces alpha to 1 rather than quietly
  carrying through a transparency the UI gives no way to see or change.

- **`PlinthHueSlider`** and **`PlinthAlphaSlider`** — the picker's
  parts, exported separately because each is often the whole
  interaction. Alpha's track sits over a chequer, the convention that
  separates *transparent* from *pale*; without it, 50% black and solid
  grey look identical.

- **`PlinthAngleSlider`** — a circular dial for a direction: a
  gradient's angle, a shadow's offset. Zero points up and grows
  clockwise, the compass convention a dial implies rather than the
  mathematical one. `divisions` snaps to equal steps.

- **`PlinthColorInput`** — a hex field with a preview swatch that opens
  the picker. The swatch is the trigger rather than the whole field: a
  field that opened a dropdown on every tap would fight the caret for
  the same gesture. Typing is parsed leniently (`#abc`, `abc`,
  `#aabbcc`, and with `withAlpha`, CSS-order `#aabbccdd`), and an
  unparseable value is *not* an error — it simply isn't reported, so a
  half-finished `#2f9` isn't destroyed mid-keystroke. `formatHex` and
  `parseHex` are exposed as statics.

### The accessibility note that shaped all four sliders

`PlinthSlider` wraps Flutter's `Slider` precisely so drag handling,
keyboard steps, and screen-reader announcements don't have to be
re-derived. These four can't: their tracks are gradients and a dial,
and `SliderTheme` only paints flat colours.

So everything `Slider` would have given for free is rebuilt
deliberately — drag, tap-to-jump, arrow-key steps with Home/End, and a
slider semantics node announcing a real value ("210 degrees", not
"0.58"). It lives in one internal base (`PlinthColorSliderBase`) rather
than being written twice and left half-done in one of them.

Getting that right surfaced a framework contract worth recording: a
semantics node exposing an increase/decrease action must also supply
`increasedValue`/`decreasedValue` whenever it supplies `value`, or it
asserts at build. That's why the base takes a *formatter* rather than a
formatted string — it needs the value a step either side, not just the
current one.

97 components, 92 playgrounds, 205 Widgetbook use cases.

## 0.12.0

### Added

The data-display set — four components that each needed a mechanism
rather than a composition of existing ones.

- **`PlinthOverflowList`** — as many children as fit on one line, the
  rest collapsed into a `+N` marker. A render object, not a
  composition: how many fit is only knowable once they have been laid
  out, and measuring in a `LayoutBuilder` and rebuilding would cost a
  frame of the wrong answer every time the width changed. The marker
  is painted directly because its text depends on the count that
  layout produces, and it's measured per candidate count rather than
  reserved at a worst case, so no item is dropped to make room for a
  label a shorter one wouldn't have needed.

  Children past the cut are still built — they have to be, to be
  measured — but are not painted, not hit-testable, and not in the
  semantics tree. That last one is the point: announcing items nobody
  can see gives a screen-reader user no way to act on them, so the
  count is the honest summary. `RenderOverflowList` exposes
  `visibleCount`/`overflowCount` because the hidden children are still
  in the widget tree, so `find.text` can't tell what was drawn.

- **`PlinthRollingNumber`** — digits that roll on change, formatted by
  `PlinthNumberFormatter` rather than by a second copy of the same
  logic. The roll is a real odometer: the *value* animates and each
  digit's position is derived from it, so 999 → 1000 turns every digit
  forward together. Tweening each digit separately — the obvious
  implementation — sends the 9 backwards through 8, 7, 6 while its
  neighbours go the other way.

  Digits inside a `prefix` or `suffix` are labels, not place values,
  so the numeric body is bounded by their lengths rather than found by
  scanning for digit characters; `' m2'` doesn't spin.

- **`PlinthDataList`** — key/value pairs in a definition-list layout,
  for one record's fields where `PlinthTable` is for many records
  sharing columns. Horizontal alignment goes through `Table`'s
  `IntrinsicColumnWidth`, the same "don't reimplement column
  alignment" reasoning that put `PlinthTable` on `Table`. Items take
  a widget value or, via `.text`, a plain string — the split
  `PlinthTable` arrived at in 0.10.0, adopted here from the start
  rather than after the string-only version proved limiting.

- **`PlinthMarquee`** — continuously scrolling content, repeated to
  fill the width so the loop has no seam. **Its motion is an
  accessibility question, not a style one.** WCAG asks that movement
  lasting over five seconds can be paused and a marquee never stops on
  its own, so this renders stationary under reduce-motion and pauses
  on hover by default. Hover is desktop and web only, which is exactly
  why the reduce-motion path isn't optional.

  The scrolling track is deliberately wider than its viewport — which
  is what a `Row` calls an overflow — so it runs inside an
  `OverflowBox` with a measured height, rather than reporting the
  intended layout as a mistake on every frame.

92 components, 87 playgrounds, 197 Widgetbook use cases.

## 0.11.0

### Added

Seven components, closing most of what the `Coming soon` list called
out as reachable. Four fill a real gap; three are wrappers that earn
their place by getting a detail right that the obvious hand-rolled
version gets wrong.

- **`PlinthEmptyState`** — the "no results" placeholder, and the one
  entry the gap list had flagged as highest value. Takes `title`,
  `description`, `icon`, and an `action`, which is the part worth
  insisting on: an empty state without one tells the user their
  situation but not what to do about it. The icon is decorative and
  excluded from semantics, since the title already says what it
  illustrates.

- **`PlinthFieldset`** — a bordered group with the legend sitting *in*
  the border. That placement is what separates it from a titled
  `PlinthCard`: the frame says "these belong together" without the
  legend reading as a heading for the rest of the page. `disabled`
  switches off a whole section — opacity, hit-testing, and semantics —
  so each field inside doesn't need its own `enabled` wired up.

- **`PlinthDialog`** — a small floating panel in a screen corner.
  Deliberately not a modal: no barrier and no `IgnorePointer`, so taps
  that miss the panel fall through and the rest of the app stays
  usable. That's the whole point of it next to `PlinthModal` — a cookie
  notice or "we've updated" prompt shouldn't take the screen. Joins the
  other disclosure components on `PlinthDisclosureController`, so the
  Overlays section is now five controller-based components, not four.

- **`PlinthSemiCircleProgress`** — `PlinthRingProgress` as a 180° arc.
  Suits a dashboard tile better than a full circle: the flat bottom
  sits on a baseline, where a full ring's empty half reads as wasted
  space. Thickness is clamped to `size / 2`, the same guard
  `PlinthRingProgress` needs to stop an over-thick arc painting back
  over itself.

- **`PlinthStack`** — the vertical counterpart to `PlinthGroup`.
  `PlinthFlex(direction: Axis.vertical)` already did this; it exists
  because stacking vertically is common enough that saying so directly
  reads better than configuring a flex. Stretches by default where
  `PlinthGroup` doesn't, since a column of fields or buttons almost
  always wants full width. Named for Mantine's component, not Flutter's
  `Stack` — it never overlaps children.

- **`PlinthBackgroundImage`** — an image behind arbitrary content. The
  gap list had called this one barely worth wrapping, since a
  `Container` with a `DecorationImage` is most of it. What changed the
  call is the part that version gets wrong: text over a photograph is
  unreadable against the light parts of it. This lays a scrim between
  the two and gives the child the `onFilled` foreground. A failed image
  also falls back to a muted fill and keeps rendering the child, rather
  than taking the content down with it.

- **`PlinthNumberFormatter`** — grouping, decimals, prefix, suffix.
  **Not localised, on purpose.** The gap list had described this as
  themed text around `intl`'s `NumberFormat`; pulling `intl` into the
  dependency graph of every app using the library isn't worth a
  thousands separator. The separators are yours to pass, which is
  correct for a fixed format and wrong for anything that should follow
  the user's locale — that case is a `NumberFormat` plus a
  `PlinthText`, and the doc comment says so. The `formatted` getter
  exposes the string for a chart axis or a semantics label.

Each ships with widget tests and Widgetbook coverage, including a
knob-driven `Playground` — 88 components, 83 playgrounds, 189 use
cases.

## 0.10.1

### Added
- An `example/` — a small sign-up form covering the things worth seeing
  before installing: registering light and dark themes, error state
  taking precedence over focus, a null callback meaning disabled, and
  the newer form components in use.

## 0.10.0

### Changed
- **`PlinthTable` cells are now widgets.** Its own doc comment had said
  "cells are plain strings; there's no per-cell custom-widget escape
  hatch yet — flag if you need that", and building a members table for
  the showcase is what flagged it: a status column wants a badge, an
  actions column a button, a person column an avatar.

  The default constructor takes `List<List<Widget>>`. Existing
  string tables become `PlinthTable.text(...)`, which keeps them `const`
  and avoids wrapping every value — a one-word change at each call site,
  rather than the churn of a single `Object`-typed cell.

  A bare `Text` in a widget cell inherits the table's size and text
  colour, so it lines up with the styled cells beside it. Rows now align
  vertically centred, since mixed-height cells are the reason widget
  cells exist.

  Note that columns share the available width, so a cell is
  width-bounded: a `Row` inside one needs a `Flexible` or `Expanded`
  around anything that can grow. The showcase smoke test caught exactly
  that while the first version of the members table was being written.

## 0.9.0

### Added
- `PlinthFileInput<T>` — a file field that **does not open a picker**.
  Flutter has no built-in one, and taking `file_picker` or
  `file_selector` as a dependency would push it onto every app using any
  part of this library, for one component. So `onPick` is the caller's:
  open whichever picker you use, return what it gives you, and this
  renders the field, the chips, the remove affordances, and the error
  state. `T` is your own file type, so nothing needs converting.
- `PlinthTagsInput` — free-text entry producing removable chips, the
  counterpart to `PlinthMultiSelect`'s fixed options. Enter or a comma
  commits, backspace on an empty field removes the last tag, and
  duplicates are rejected by default.
- `PlinthAutocomplete` — a text field with suggestions. Unlike
  `PlinthSelect` it accepts anything typed; the options are a
  convenience rather than a constraint. Matches anywhere in an option,
  so `mail` still offers `Gmail`, and highlights the matched run.

### Fixed
- `PlinthMultiSelect`'s dropdown anchored to the whole widget rather
  than to its field. The outer `Column` stretches to fill a tall
  parent, so in one the list rendered a screen-height below the field —
  off the bottom of the viewport and untappable. Found while building
  `PlinthAutocomplete`, which had inherited the same shape from it.

## 0.8.0

### Added
- `PlinthCloseButton` — the dismiss affordance `PlinthAlert`,
  `PlinthNotification`, `PlinthModal`, and `PlinthDrawer` each built
  inline. They had drifted apart in the process: two used a bare `Icon`
  inside an `InkWell` with no semantics, so a screen reader announced
  nothing where a sighted user saw a close button. All four now share
  it, and it carries a `Close` label by default.
- `PlinthCollapse` — an animated height reveal for a filter panel, an
  "advanced options" section, or a validation summary. Keeps its child
  mounted so a half-filled form survives being hidden, and excludes it
  from semantics and hit-testing while closed, since a clipped child is
  still in the tree.
- `PlinthHighlight` — text with matching substrings marked. `PlinthMark`
  highlights a span you have already split out; this does the splitting,
  which is what a search result needs. Matching is case-insensitive,
  preserves the original casing, and escapes its terms — a query
  containing `.` matches a full stop rather than any character.

### Changed
- `PlinthAccordion` deliberately does *not* use `PlinthCollapse`. It was
  refactored to, and three tests caught the consequence: `PlinthCollapse`
  keeps its child mounted, which left closed panels readable by a screen
  reader. An accordion holds page content and should unmount it, so the
  original behaviour stands and the difference is now documented on both.

## 0.7.0

### Fixed
- **Palette colours are now legible.** Requires `plinth_core` ^0.2.0.

  A filled button, badge, chip, indicator, or theme icon picks its
  label colour from its own fill instead of always using white: white
  on `yellow` measured 2.12:1 and on `teal` 1.82:1, well under the
  4.5:1 WCAG AA asks for. Those labels are now dark.

  A palette colour used as *text* — `PlinthText`, `PlinthTitle`, and
  the `light`/`outline`/`subtle`/`transparent` button variants —
  resolves to a shade that actually contrasts with what's behind it,
  rather than a fixed shade 6. `cyan` measured 2.19:1 as text on white.

  In dark mode, shades mirror across the ramp, so accents lighten
  instead of staying dark against a dark surface — `violet` measured
  1.97:1 there.

  `blue`, `red`, `violet`, `indigo`, `grape`, and `pink` already
  cleared the threshold and are unchanged; the `PlinthButton` golden is
  byte-identical. The lighter half of the palette looks different,
  which is the fix.

  Contrast assertions now run as tests in `plinth_core`, so a future
  palette or token change fails rather than quietly regressing.

## 0.6.1

### Fixed
- Long labels overflowed instead of wrapping. `PlinthCheckbox`,
  `PlinthSwitch`, and `PlinthRadio` laid their label out at its full
  intrinsic width, so a checkbox reading "I agree to the terms of
  service" inside a narrow form painted overflow stripes rather than
  wrapping to a second line — the consent checkbox being the case where
  long labels are most common.
- `PlinthButton` had the same problem with `fullWidth: true` and a
  `leadingIcon`: the label could not shrink to the width the button was
  given. Reachable whenever the width is constrained rather than
  derived from the content, including at a large text scale.

  Both were found by building a realistic sign-in form for the example
  app's showcase, not by a component test — the components look correct
  in isolation and only overflow once something else constrains them.

## 0.6.0

### Added
- **Dark mode support.** Every component now reads its surfaces, text,
  and borders from `PlinthTheme` tokens instead of hardcoding them, so
  registering `PlinthTheme.darkTheme` actually restyles the library.
  Previously a `PlinthTextInput` painted a white box with black text
  whatever theme you gave it — 40 of the widget files carried literal
  colors.

  The light theme's token values are the exact literals they replaced,
  so this changes nothing visually in light mode; the golden test
  confirms it.

  `PlinthTooltip` is the one component that consults `brightness`
  directly: it is deliberately inverted against the surface it floats
  over, and following the surface token would make it disappear into
  the background in dark mode.

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
