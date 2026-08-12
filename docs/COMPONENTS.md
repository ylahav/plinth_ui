# Component Reference

Every component reads from the active `PlinthTheme` via `context.plinth`
(`plinth_core`). Register the theme once, at the app root:

```dart
MaterialApp(
  theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
)
```

For dark mode, register `PlinthTheme.darkTheme` as well:

```dart
MaterialApp(
  theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
  darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
)
```

Shared enums used throughout: `PlinthSize` (`xs, sm, md, lg, xl`) and
`PlinthVariant` (`filled, light, outline, subtle, transparent, defaultVariant`).

## Theme tokens

Two kinds of color live on `PlinthTheme`, and components use them for
different jobs.

**Palette ramps** — `theme.color('blue', 6)`. Thirteen named ramps of
ten shades each, the same in light and dark themes. Every `color:` prop
on a component is a key into these. Shade 6 is the base a component
fills with; 0–1 are tints for backgrounds, 7–9 are for contrast.

**Chrome tokens** — the neutrals the ramps don't cover, and what makes
a dark theme a value swap rather than a rewrite:

| Token | What it paints |
|---|---|
| `surface` | Panels and field backgrounds: cards, modals, drawers, inputs |
| `surfaceMuted` | Recessed fills: disabled inputs, `PlinthKbd`, segmented-control tracks |
| `surfaceSunken` | Structure: dividers, progress tracks, skeletons |
| `border` | Default hairlines around inputs and bordered containers |
| `borderMuted` | Softer, decorative borders |
| `text` / `textMuted` / `textDisabled` | Body, secondary, and disabled text |
| `onFilled` | Foreground *on* a saturated fill — a filled button's label, a checked box's tick |
| `shadow` / `scrim` | Elevation shadows, and the barrier behind a modal |

### Resolving a palette colour

Three methods, for three different jobs. Reaching for `color(name, 6)`
directly is almost always wrong — that fixed shade is what made the
palette fail contrast in the first place.

| Method | Use for | Why |
|---|---|---|
| `shaded(name, shade)` | **Fills** — button backgrounds, badge tints | Mirrors the shade in dark themes, so a shade-0 wash stays a wash rather than becoming near-white on a dark surface |
| `contrastingOn(fill)` | **Foreground on a fill** — a filled button's label, a checked tick | Picks light or dark by the *fill's* lightness. White on `yellow` measures 2.12:1; on `violet`, 8.75:1 |
| `readableOn(name, bg)` | **Palette colour as text or an icon** | Walks the ramp for a shade that clears contrast. No single index works for every hue — `cyan` at shade 6 measures 2.19:1 on white where `violet` measures 8.75:1 |

`onFilled` and `onFilledInverse` are the two candidates `contrastingOn`
chooses between. Neither follows `brightness`: a filled button is
saturated in either theme, so which foreground it needs depends on the
fill, not the theme. Tying that to brightness is how you end up with
dark text on a dark-blue button.

Contrast is asserted in `plinth_core`'s test suite against WCAG AA, so
a palette or token change that breaks legibility fails there rather
than shipping.

`brightness` is on the theme for the rare component that must branch
directly. `PlinthTooltip` is the only one that does — it's deliberately
inverted against the surface it floats over, so following `surface`
would make it vanish into the background in dark mode.

Looking for something that isn't here? **[Coming soon](#coming-soon)** at
the end lists the components Plinth doesn't have yet and why, so a gap
reads as a known one rather than an oversight.

---

## Primitives

### `PlinthButton`
`onPressed`, `child`, `variant`, `size`, `color`, `radius`, `fullWidth`, `leadingIcon`.
The reference implementation — every other component's variant/size/color
resolution logic follows this one's pattern.

### `PlinthButtonGroup`
`children`. Visually joins a row of buttons (or any bordered children)
into one connected group — outer corners stay rounded, inner corners
square off, adjacent borders collapse into a shared hairline instead of
doubling up. A layout wrapper only; doesn't alter children's own
behavior.

### `PlinthActionIcon`
`icon`, `onPressed`, `variant`, `size`, `color`, `radius`, `circle`. Same
variant/size/color resolution as `PlinthButton`, but square (or fully
circular) with no label — for icon-only actions.

### `PlinthCopyButton`
`value` (the text to copy), `color`, `size`, `confirmDuration` (default
2 seconds). Copies `value` to the clipboard on tap, showing a transient
checkmark before reverting to the copy icon.

### `PlinthBurger`
`opened`, `onPressed`, `color`, `size`. Animated hamburger→X toggle icon
using `AnimatedPositioned` with explicit pixel targets (not
`AnimatedSlide`, whose offset is relative to each thin bar's own tiny
height rather than the icon's overall size). Controlled component —
doesn't open anything itself, pair with a `PlinthDisclosureController`
or your own bool state.

### `PlinthBox`
`child`, `p`/`px`/`py` (padding), `m`/`mx`/`my` (margin) — all keyed by
`PlinthSize` and resolved through `theme.spacing`. Also `w`, `h`, `bg`,
`radius`, `border`, `alignment`.

### `PlinthCenter`
`child`, `widthFactor`, `heightFactor`. A thin themed wrapper around
Flutter's own `Center` — exists for API consistency (`Plinth*` layout
primitives throughout) rather than adding new behavior.

### `PlinthAspectRatio`
`ratio`, `child`. A thin themed wrapper around Flutter's own
`AspectRatio` — constrains `child` to a width/height ratio, the common
case being reserving space for an image or embed before it loads so
layout doesn't jump.

### `PlinthGroup`
`children`, `gap` (default `PlinthSize.md`), `mainAxisAlignment`,
`crossAxisAlignment`, `wrap` (default `true`). Horizontal layout with a
consistent gap between children. Unlike a plain `Row`, wraps onto a new
line by default when children overflow the available width (via
`Wrap` under the hood) — the common "row of chips/buttons/tags" need
that a bare `Row` would just overflow on. Set `wrap: false` to opt back
into `Row`'s clip-and-overflow behavior.

### `PlinthList` + `PlinthListItem`
`items` (`List<PlinthListItem>`), `type` (`PlinthListType`: `bullet,
ordered` — default `bullet`), `spacing`, `size`. Each `PlinthListItem`
takes `content` (its text or arbitrary widget) and an optional `icon`
that overrides that item's marker — e.g. a checklist mixing checkmarks
and crosses while other items fall back to the list's default
bullet/numbering.

### `PlinthContainer`
`child`, `size` (`PlinthContainerSize`: `xs, sm, md, lg, xl` — default
`md`), `padding` (default `PlinthSize.md`). Constrains `child` to a
max width and centers it — the standard "page content shouldn't get
absurdly wide on a big monitor" wrapper.

### `PlinthSpace`
`w`, `h` (both nullable `PlinthSize`). A fixed-size spacer resolved
through `theme.spacing` — for a themed gap without a raw `SizedBox`
and a magic-number pixel value. Provide `w`, `h`, or both; omitting
both collapses to zero size.

### `PlinthUnstyledButton`
`child`, `onPressed`. A bare tap target with no visual chrome — no
color, border, padding, or ripple by default. The building block for
fully custom-styled clickable elements where `PlinthButton`'s built-in
variant/color/size resolution would fight the custom look. Still
provides proper semantics (announced as a button) and a disabled
state when `onPressed` is null.

### `PlinthAppShell`
`child` (the main region), `header`/`headerHeight`, `navbar`/`navbarWidth`/
`navbarCollapsed`, `aside`/`asideWidth`/`asideCollapsed`, `footer`/
`footerHeight`, `padding`, `withBorder`, `bg`. The page scaffold: header
and footer span the full width, navbar and aside run down either side,
and `child` fills what's left. Any region left `null` takes no space
rather than rendering empty (same convention as `PlinthCard`'s
header/footer). Collapsing is **controlled by the caller** — the shell
doesn't watch a breakpoint itself, since the surrounding page needs that
same state to drive a `PlinthBurger` or decide whether to offer the links
in a `PlinthDrawer` instead. `padding` applies to `child` only; the other
regions get their full extent so they can paint edge to edge. `withBorder`
draws hairlines *inside* each region, so a 200px navbar stays 200px wide
and its content gets 199.

Expects a bounded height — put it directly in a `Scaffold` body rather
than inside a scrolling column; `child` is what should scroll.

### `PlinthGrid` + `PlinthGridCol`
`PlinthGrid`: `children` (`List<PlinthGridCol>`), `gutter` (default
`PlinthSize.md`), `columns` (default `12`).
`PlinthGridCol`: `child`, `span` (default `12`), plus `spanXs`/`spanSm`/
`spanMd`/`spanLg`/`spanXl`.

A responsive column grid. Per-breakpoint spans apply from that width
**upward**, so `span: 12, spanMd: 6` is full width on a phone and half on
a desktop — mobile-first, matching CSS media queries, meaning the
unqualified `span` is the *smallest* case rather than a default that
larger screens fall back to. Breakpoints are Mantine's defaults in
logical pixels (`xs` 576, `sm` 768, `md` 992, `lg` 1200, `xl` 1408),
exported as `kDefaultBreakpoints`.

Distinct from `PlinthSimpleGrid`, which puts a fixed number of
equal-width items per row: reach for SimpleGrid for a uniform gallery of
cards, and this for a page layout where a sidebar and a main column have
genuinely different widths. A span wider than `columns` is clamped rather
than overflowing its row. Like SimpleGrid it is neither scrollable nor
virtualized and needs a bounded width.

### `PlinthSimpleGrid`
`children`, `columns`, `spacing` (default `PlinthSize.md`). A grid with
a fixed number of columns per row and consistent spacing. Unlike
`GridView`, this isn't scrollable or virtualized — it sizes to its
content and expects a bounded-width ancestor (uses `LayoutBuilder`
internally to compute cell width; an unbounded-width parent, like a
horizontal `ListView`, will throw). For a large or unbounded item
list, use `GridView.builder` directly instead.

### `PlinthFlex`
`children`, `direction` (`Axis` — default `horizontal`), `gap` (default
`PlinthSize.md`), `mainAxisAlignment`, `crossAxisAlignment`,
`mainAxisSize`. A direction-configurable flex layout with a consistent
gap. `PlinthGroup` is this same idea specialized to the horizontal case
with wrap-by-default — reach for `PlinthFlex` when the direction itself
needs to vary (horizontal on wide screens, vertical on narrow ones)
rather than always being a row.

### `PlinthImage`
`src`, `width`, `height`, `fit` (default `BoxFit.cover`), `radius`. A
network image with an automatic loading placeholder and error
fallback — Flutter's own `Image.network` shows nothing while loading
and lets a failed URL surface as a raw render error, so this fills
both gaps with a themed spinner and a broken-image icon.

### `PlinthText`
`data`, `size`, `color`, `weight`, `textAlign`, `italic`, `maxLines`, `overflow`.
`size` resolves through `theme.fontSizes` instead of a raw `fontSize` double.

### `PlinthTitle`
`data` (positional), `order` (1–6, default `1`, asserted in range),
`color`, `textAlign`, `maxLines`, `overflow`. A semantic heading. The
difference from a `PlinthText` at a larger `size` isn't only visual: this
marks the text as a heading for assistive technology and carries the
level through, so screen-reader users can navigate a page by its headings
and tell a sibling from a subsection. A visually large paragraph gives
them nothing to navigate by.

Uses its own size scale (34/26/22/18/16/14 px) rather than
`theme.fontSizes`, which tops out at 20px because it sizes body text,
badges, and input labels — an `h1` needs to be larger than any of them.

### `PlinthDivider`
`label` (optional, centers a label with rules on either side, e.g. "OR"),
`vertical`, `height` (only meaningful when `vertical` — `VerticalDivider`
needs an explicit extent from its parent to render visibly in an
unconstrained context), `color`.

### `PlinthKbd`
`label` (positional), `size`. A styled keyboard-key badge for documenting
shortcuts, e.g. `PlinthKbd('Ctrl')` + `PlinthKbd('K')`.

### `PlinthCode`
`label` (positional), `color` (default `'gray'`), `size`. Inline monospace
snippet on a tinted background — for referencing identifiers, commands,
or file names within a sentence (typically inside a `WidgetSpan`).

### `PlinthHighlight`
`data` (positional), `highlight` (`List<String>` of terms), `color`
(default `'yellow'`), `size`, `textColor`, `weight`, `textAlign`,
`maxLines`, `overflow`. Text with matching substrings marked.

`PlinthMark` highlights a span you've already split out yourself; this
does the splitting, which is what you want when the terms come from a
search box and you don't know where they land. Matching is
case-insensitive but preserves the original casing in what's rendered,
and terms are escaped before use — a query containing `.` or `(`
matches those characters rather than acting as a pattern. Overlapping
terms resolve to the longest, blank terms are ignored (so a raw
`query.split(' ')` with a trailing space doesn't mark everything), and
matches are styled with `backgroundColor` rather than a `WidgetSpan`
so a long match still wraps.

### `PlinthMark`
`label` (positional), `color` (defaults to `'yellow'` if the active theme
defines it, else a literal amber fallback). Highlighted inline text, e.g.
for search-match terms.

### `PlinthAnchor`
`label` (positional), `onTap`, `color`, `size`, `underline`
(`PlinthAnchorUnderline`: `always, hover, never` — default `hover`,
matching conventional link affordance). Styled link text; not a
navigation widget itself, just a themed tap target.

### `PlinthVisuallyHidden`
`child`. Renders `child` so screen readers announce it while sighted
users never see it — e.g. supplementary context for an icon-only
control. Uses the standard "clip to a near-zero size" technique rather
than `Opacity`/`Visibility.invisible`, which some screen readers still
treat as hidden from *them* too.

### `PlinthBlockquote`
`quote`, `citation`, `color`, `icon`. Colored left border with italic
quote text and an optional citation line.

---

## Surfaces

### `PlinthPaper`
`child`, `p` (padding, default `md`), `radius`, `shadow` (`PlinthShadow`:
`none, sm, md, lg`), `withBorder`, `bg`. The base surface primitive
`PlinthCard` builds on — reach for this directly when you just need a
raised/bordered container without card section conventions.

### `PlinthCard`
`child`, `header`, `footer`, `p`, `radius`, `shadow` (default `sm`),
`withBorder`. Built on `PlinthPaper` — adds a header/body/footer section
convention with a divider between whichever sections are present. Sections
left `null` are simply omitted, not rendered empty.

---

## Forms

### `PlinthTextInput`
`label`, `description`, `placeholder`, `error`, `controller`, `onChanged`,
`size`, `color`, `radius`, `obscureText`, `enabled`, `leadingIcon`.
Border color: gray (default) -> theme color at shade 6 (focused) -> red
(error present) — error takes precedence over focus.

### `PlinthTextarea`
`label`, `description`, `placeholder`, `error`, `controller`, `onChanged`,
`size`, `color`, `radius`, `enabled`, `minLines` (default `3`), `maxLines`
(default `6`). Shares `PlinthTextInput`'s chrome and border styling.

### `PlinthPasswordInput`
`label`, `description`, `placeholder`, `error`, `controller`, `onChanged`,
`size`, `color`, `radius`, `enabled`. Shares `PlinthTextInput`'s chrome,
with a show/hide visibility toggle icon instead of a plain `obscureText`
flag.

### `PlinthPinInput`
`length` (default `4`), `value`, `onChanged`, `onCompleted` (fires once
when the value reaches `length` characters), `obscureText`, `numbersOnly`
(default `true`), `size`, `color`, `error`. One box per character, with
auto-advancing focus as each digit is typed and auto-retreating focus on
backspace from an already-empty box.

### `PlinthCheckbox`
`value`, `onChanged` (nullable — null disables), `label`, `size`, `color`, `radius`.

### `PlinthRadio<T>` / `PlinthRadioGroup<T>`
Use `PlinthRadioGroup` in practice — it wires `groupValue`/`onChanged` to
each `PlinthRadioOption<T>` for you:
```dart
PlinthRadioGroup<String>(
  label: 'Plan',
  value: _plan,
  onChanged: (v) => setState(() => _plan = v),
  options: const [
    PlinthRadioOption('free', 'Free'),
    PlinthRadioOption('pro', 'Pro'),
  ],
)
```

### `PlinthFileInput<T>`
`value` (`List<T>`), `onPick`, `onChanged`, `labelBuilder`, `label`,
`description`, `placeholder`, `error`, `size`, `color`, `radius`,
`enabled`, `multiple`, `icon`.

**It does not open a file picker.** Flutter has no built-in one, and
every package providing it (`file_picker`, `file_selector`,
`image_picker`) would become a dependency of `plinth_components` and so
of every app using any part of this library — a disproportionate cost
for one component, and a choice each app is better placed to make.

So `onPick` is yours: open whichever picker you use and return what it
gives you. This renders the field, the selected files, the remove
affordances, and the error state. `T` is your own file type —
`PlatformFile`, `XFile`, a record — and `labelBuilder` says how to show
one. A cancelled picker (null or an empty list) leaves the selection
untouched rather than clearing it.

### `PlinthTagsInput`
`value` (`List<String>`), `onChanged`, `label`, `description`,
`placeholder`, `error`, `size`, `color`, `radius`, `enabled`,
`maxTags`, `allowDuplicates`. Free-text entry producing removable
chips.

`PlinthMultiSelect` is the fixed-options equivalent, where the user
picks from a list you supply; this is where they invent the values.
Enter or a comma commits — so pasting `dart, flutter` yields two tags —
and backspace in an empty field removes the last one. Duplicates are
rejected by default, since two identical chips give the user no way to
tell them apart.

### `PlinthAutocomplete`
`value`, `onChanged`, `options`, `label`, `description`, `placeholder`,
`error`, `size`, `color`, `radius`, `enabled`, `limit` (default `8`),
`onOptionSelected`. A text field with suggestions.

The difference from `PlinthSelect` is what the field accepts, not how
it looks: a select constrains the user to your list, while this takes
any text and merely *offers* it. Suggestions match anywhere in an
option rather than only at the start — typing `mail` still offers
`Gmail` — and the matched run is highlighted via `PlinthHighlight` so
it's clear why each is being suggested. `onOptionSelected` fires in
addition to `onChanged` when a suggestion is picked, for when that
should do more than set the text.

### `PlinthSelect<T>`
`options` (`List<PlinthSelectOption<T>>`), `value`, `onChanged`, `label`,
`description`, `placeholder`, `error`, `size`, `color`, `radius`, `enabled`.
Shares `PlinthTextInput`'s label/description/error chrome; wraps
`DropdownButton` internally with the default underline hidden.

### `PlinthSwitch`
`value`, `onChanged` (nullable), `label`, `size`, `color`. Same
animated-fill pattern as `PlinthCheckbox`, pill-shaped instead of square.

### `PlinthSlider`
`value`, `onChanged` (nullable), `min`, `max`, `divisions` (omit for
continuous), `color`, `size`, `label` (shown above the thumb while
dragging). A themed wrapper around Flutter's built-in `Slider` (via
`SliderTheme`) — same rationale as `PlinthTooltip`: drag handling,
keyboard stepping, and accessibility are worth not reimplementing.

### `PlinthRangeSlider`
`values` (`RangeValues`), `onChanged` (nullable), `min`, `max`,
`divisions`, `color`, `size`, `labels` (`RangeLabels`). Same wrap-not-
reimplement rationale as `PlinthSlider`, wrapping Flutter's built-in
`RangeSlider` for dual-thumb range selection.

### `PlinthMultiSelect<T>` + `PlinthMultiSelectOption<T>`
`options`, `value` (`List<T>`), `onChanged`, `label`, `description`,
`placeholder`, `error`, `size`, `color`, `radius`, `enabled`. Chosen
values render as removable chips inside the field (via Flutter's
built-in `Chip`, not `PlinthChip` — that's a *selectable toggle*
pattern, a different semantic than a removable value chip); tapping
the field opens a dropdown of the remaining options. A bespoke
implementation, not a `PlinthSelect` variant — `DropdownButton` (which
`PlinthSelect` wraps) has no multi-select mode.

### `PlinthSegmentedControl<T>` + `PlinthSegmentedControlItem<T>`
`items` (`List<PlinthSegmentedControlItem<T>>`), `value`, `onChanged`,
`color`, `size`, `fullWidth`. Like `PlinthTabs`, uses a static
per-segment fill rather than a measured sliding indicator, for the same
simplicity/reliability reasons.

### `PlinthNumberInput`
`value` (`num`), `onChanged`, `min`, `max`, `step` (default `1`), `label`,
`description`, `error`, `size`, `color`, `radius`, `enabled`. Shares
`PlinthTextInput`'s label/description/error chrome and focus/error border
styling, with +/- step buttons that respect `min`/`max`. Typing a value
directly is also supported and clamped the same way.

### `PlinthChip`
`label`, `selected`, `onSelected` (nullable — null disables), `color`,
`size`. Standalone toggle — for a group, manage a `Set`/value in your own
state and pass `selected` per chip, same controlled-component pattern as
`PlinthCheckbox`/`PlinthRadio`.

### `PlinthRating`
`value` (supports half-values like `3.5` for read-only display), `onChanged`
(omit for a read-only display — e.g. showing an existing average rating),
`count` (default `5`), `color` (defaults to an amber gold, not the theme's
primary color — a rating in brand blue reads oddly against the
conventional gold-star look), `size`.

---

## Feedback

### `PlinthBadge`
`label` (positional), `variant`, `size`, `color`, `leadingIcon`. Renders
uppercase by default, pill-shaped (`borderRadius: 999`).

### `PlinthAlert`
`title` (optional), `child`, `color` (default `'blue'`), `icon`, `onClose`
(non-null shows a close button), `radius`. Background at shade 0, accent
(icon/title/border) at shade 6.

### `PlinthProgress`
`value` (0.0–1.0, asserted in range), `color`, `size` (controls track
height), `radius`, `trackColor`. Fill animates smoothly on value change
via an internal `AnimatedFractionallySizedBox` helper.

### `PlinthRingProgress`
`value` (0.0–1.0, asserted in range), `color`, `size` (outer diameter,
default 80), `thickness` (default 8), `trackColor`, `label` (optional
centered content, e.g. a percentage). Circular companion to
`PlinthProgress` — built on `CustomPaint`, sweeping clockwise from 12
o'clock.

### `PlinthNotification`
`title` (optional), `child`, `color` (default `'blue'`), `icon`, `onClose`,
`radius`. Distinct from `PlinthAlert`: Alert is an inline callout meant to
sit in normal page layout flow; Notification is meant to float. Use the
static `PlinthNotification.show(context, ...)` to push it as a `SnackBar`
via `ScaffoldMessenger` — inherits Flutter's own stacking, auto-dismiss
timing, and swipe-to-dismiss rather than reimplementing a toast stack.
`onClose` is wired up automatically when shown via `show()`.

### `PlinthLoader`
`type` (`PlinthLoaderType`: `oval, dots, bars` — default `oval`), `size`,
`color`. The loading indicator on its own, for a button mid-submit or an
empty panel awaiting its first fetch. `PlinthLoadingOverlay` already
shows a spinner, but only as part of covering existing content.

`oval` wraps Flutter's `CircularProgressIndicator` (same
wrap-don't-reimplement rationale as `PlinthSlider`); `dots` and `bars`
are three elements pulsing a third of a cycle out of phase. Uses its own
size scale (16/20/28/36/44 px) — none of spacing, radius, or font size
means "how big is this circle".

### `PlinthCloseButton`
`onPressed` (null disables), `size`, `color`, `radius`, `semanticLabel`
(default `'Close'`). The dismiss affordance shared by `PlinthAlert`,
`PlinthNotification`, `PlinthModal`, and `PlinthDrawer`, which each
built one inline before this existed — two of them as a bare `Icon` in
an `InkWell` with no semantics, so a screen reader announced nothing
where a sighted user saw a close button.

Narrower than `PlinthActionIcon` on purpose: it always carries the same
glyph and the same semantics, so the components using it can't drift
apart again. Override `semanticLabel` where "Close" is ambiguous —
"Dismiss notification", say.

### `PlinthCollapse`
`opened`, `child`, `duration` (default 200ms), `curve`. An animated
height reveal — a filter panel above a table, an "advanced options"
section, a validation summary that appears on submit. Controlled by the
caller, like every other disclosure here.

Keeps `child` **mounted** while collapsed, so a half-filled form or a
scroll position survives being hidden. That's the trade-off to weigh:
a clipped child is still built and laid out, so for a long list of
panels, or content that should genuinely go away, swapping it out is
the better shape. It's excluded from semantics and hit-testing when
fully closed — otherwise a screen reader would read a panel nobody can
see. `PlinthAccordion` deliberately unmounts instead, for that reason.

### `PlinthSkeleton`
`width` (omit to fill parent), `height` (default `16`), `radius`, `circle`
(renders as a circle instead of a rounded rect, for avatar placeholders).
Pulses via a self-triggering `TweenAnimationBuilder` rather than a
shimmer-gradient + `AnimationController` — simpler lifecycle, same
"this is loading" signal.

### `PlinthSpoiler`
`child`, `maxHeight` (default `100`), `showLabel`/`hideLabel`, `color`.
"Show more/less" wrapper for a single block of content — distinct from
`PlinthAccordion` (a list of independently toggleable sections), this is
one block that's either fully shown or height-clipped.

### `PlinthLoadingOverlay`
`child`, `visible`, `color`. Dims `child` and shows a centered spinner on
top when `visible`, blocking interaction underneath via `IgnorePointer`
rather than removing `child` from the tree — layout stays stable across
the loading toggle. Distinct from `PlinthSkeleton`: this overlays
*existing* content during an async operation, rather than standing in for
content that doesn't exist yet.

### `PlinthOverlay`
`child`, `color` (default black), `opacity` (default `0.6`),
`blockPointerEvents` (default `false`). A generic dimming backdrop —
distinct from `PlinthLoadingOverlay`, which is specifically a loading
state (always shows a spinner, always blocks pointer events). This is
the more general primitive: dim a background image behind text, gray
out a section without necessarily blocking interaction, or build a
custom loading/empty state with your own content. Renders via
`Positioned.fill`, so — like `PlinthAffix` — it needs a `Stack`
ancestor; place it as a sibling of whatever it should dim.

### `PlinthScrollArea`
`child`, `direction` (default `Axis.vertical`). A scrollable region
with a themed, always-visible, draggable scrollbar — a thin wrapper
around `Scrollbar` + `SingleChildScrollView`, since Flutter's default
scrollbar is platform-styled and easy to miss on desktop/web. Good fit
for a custom-styled scrolling panel: a sidebar, a long settings list,
a code panel.

### `PlinthPortal`
`child`. Renders `child` into the ambient `Overlay` rather than its
normal place in the tree — the building block underneath every
overlay component in this library (`PlinthModal`, `PlinthDrawer`,
`PlinthPopover`, ...), exposed directly for cases outside those: a
custom floating panel that needs to escape a parent's `ClipRect`, an
overflow-hidden container, or a clipping scroll ancestor. Has no
show/hide state of its own — mount it conditionally to control when
its content appears.

---

## Data Display

### `PlinthAvatar`
`imageUrl`, `initials`, `color`, `size`, `radius` (omit for fully circular).
Fallback chain: `imageUrl` -> `initials` on a tinted background -> generic
person icon.

### `PlinthThemeIcon`
`icon`, `variant`, `size`, `color`, `radius`, `circle`. A colored icon
container for use as a leading visual in list items or feature cards —
same variant/size/color resolution as `PlinthActionIcon`, but not
tappable (`ThemeIcon` is decorative, `ActionIcon` is interactive).

### `PlinthIndicator`
`child`, `label` (omit for a plain dot), `color` (defaults to `'red'`,
not the theme's primary color — a notification dot conventionally reads
as red/attention regardless of brand color), `position`
(`PlinthIndicatorPosition`: `topStart, topEnd, bottomStart, bottomEnd`),
`disabled` (hides the indicator without removing `child` from the tree).
Anchors a small badge/dot to a corner of `child` via `Stack` +
`FractionalTranslation`.

### `PlinthColorSwatch`
`color` (a theme palette key, e.g. `'blue'`), `selected`, `onTap`, `size`.
Standalone selectable color square — for a picker, lay out several with
your own selected-color state, same controlled-component pattern as
`PlinthChip`.

### `PlinthTable`
`columns` (`List<String>`), `rows` (`List<List<String>>` — each inner
list must match `columns.length`), `striped`, `size`. Built on Flutter's
low-level `Table` widget rather than `DataTable`, since `DataTable`'s
built-in Material styling (fixed row heights, sort/selection chrome)
fights against a themeable design system more than it helps. No custom
per-cell widget support yet — cells are plain text.

---

## Navigation

### `PlinthAccordion` + `PlinthAccordionItem`
`items` (`List<PlinthAccordionItem>`), `multiple` (default `false` — only
one item open at a time), `initiallyOpen` (`Set<String>` of item
`value`s), `color`. Each `PlinthAccordionItem` has `value` (unique id),
`title`, `content`, `icon`. Manages its own open/closed state
internally — unlike the overlay components, there's no external
controller, since expanded state is presentation-local to the widget.

### `PlinthStepper` + `PlinthStep`
`steps` (`List<PlinthStep>`), `currentStep` (zero-based index), `onStepTapped`,
`color`. Each `PlinthStep` has `label` and optional `description`. Purely
a visual progress indicator — like `PlinthTabs`/`PlinthTabView`, it doesn't
manage step *content*; pair with your own conditional rendering driven by
the same `currentStep` you pass in. Tapping a step calls `onStepTapped`
but doesn't change `currentStep` itself — controlled-component pattern,
same as `PlinthTabs`.

### `PlinthBreadcrumbs` + `PlinthBreadcrumbItem`
`items` (`List<PlinthBreadcrumbItem>`), `separator` (default `'/'`), `color`.
Each `PlinthBreadcrumbItem` has `label` and optional `onTap`. The *last*
item is always rendered as plain, non-interactive text regardless of
whether it has an `onTap` — matching the convention that the current page
isn't itself a link.

### `PlinthPagination`
`page` (1-based), `total`, `onChanged`, `color`, `size`, `siblingCount`
(default `1` — how many page numbers show on either side of `page` before
collapsing into an ellipsis). For large `total`, always shows the first
page, the last page, and `page`'s immediate neighbors; everything else
collapses into a single `…` marker per side.

### `PlinthTimeline` + `PlinthTimelineItem`
`items` (`List<PlinthTimelineItem>`), `color`. Each `PlinthTimelineItem`
has `title`, optional `description`/`icon`, and `active` (highlights the
dot in the theme color — use for the current/most-recent event). Dots are
connected by a line via `IntrinsicHeight` + `Expanded`, a standard Flutter
pattern for "match this column's height to its sibling."

### `PlinthNavLink`
`label`, `icon`, `trailing` (e.g. a `PlinthBadge` for an unread count),
`active`, `onTap`, `color`. Sidebar-style navigation item — active state
tints the background and label in the theme color.

### `PlinthTabs<T>` + `PlinthTabView<T>`
`PlinthTabs`: `tabs` (`List<PlinthTabItem<T>>`), `value`, `onChanged`, `size`,
`color`. Renders an underline-style tab bar — deliberately a static
per-tab underline rather than a measured sliding indicator (the kind
needing `GlobalKey`/`RenderBox` size lookups), to keep the implementation
simple and reliable.

`PlinthTabView`: `value`, `children` (`Map<T, Widget>`). Fades between
entries keyed by the same `value`/type as `PlinthTabs`. Renders nothing
(not an error) if `value` has no matching key — treated as a recoverable
transient state rather than a bug.

```dart
PlinthTabs<String>(
  value: _tab,
  onChanged: (v) => setState(() => _tab = v),
  tabs: const [
    PlinthTabItem('account', 'Account'),
    PlinthTabItem('security', 'Security'),
  ],
),
PlinthTabView<String>(
  value: _tab,
  children: const {
    'account': Text('Account settings'),
    'security': Text('Security settings'),
  },
),
```

---

## Overlays

All four controller-based overlay components share `PlinthDisclosureController`
(`plinth_hooks`) for open/close state — `open()`, `close()`, `toggle()`,
`isOpen`. Always call `.dispose()` on the controller when its owning
State is disposed.

### `PlinthAffix`
`child`, `top`, `right`, `bottom`, `left`. The one overlay-adjacent
component *without* a controller — it's a thin wrapper around `Positioned`
for anchoring a widget (e.g. a "scroll to top" button) to a screen corner
within an existing `Stack`, rather than an inserted floating overlay like
the others below.

### `PlinthModal` + `PlinthModalHost`
`controller`, `title`, `child`, `size`, `closeOnBackdropTap`, `radius`.
`PlinthModal` doesn't render inline — wrap the part of your tree that
should react to it in `PlinthModalHost(modal: ..., child: ...)`, which
calls `modal.show(context)` automatically whenever the controller opens
(via `showGeneralDialog` under the hood). Auto-closes the controller on
dismissal (backdrop tap or `Navigator.pop`).

### `PlinthDrawer` + `PlinthDrawerHost`
Same shape as Modal, plus `position` (`PlinthDrawerPosition`: `left,
right, top, bottom`). Slides in via `SlideTransition`; sizing is width
for left/right, height for top/bottom.

### `PlinthPopover`
`controller`, `target`, `content`, `position` (`PlinthPopoverPosition`:
`top, bottom, left, right`), `width`, `closeOnOutsideTap`. Unlike
Modal/Drawer, **not** route-based — built on
`CompositedTransformTarget`/`CompositedTransformFollower` + a manual
`OverlayEntry`, so it tracks its target's actual on-screen position
(including through scrolling). Tapping `target` toggles the controller
directly; no separate host widget needed since the popover wraps its
own trigger.

### `PlinthHoverCard`
`target`, `content`, `position`, `width`, `closeDelay` (default 100ms).
Hover-triggered — desktop/web-oriented, effectively inert on touch
devices (see `PlinthPopover` for a tap-triggered equivalent that works
everywhere). Not built by composing `PlinthPopover` — its trigger is
hardcoded to tap, and a hover card additionally needs to stay open
while the pointer travels from `target` onto `content` itself, which
`closeDelay` (a grace-period `Timer`) provides. No controller — hover
state is managed internally via `MouseRegion`.

### `PlinthTooltip`
`message`, `child`, `size`, `radius`. A themed wrapper around Flutter's
built-in `Tooltip` — shown on hover (desktop/web) or long-press (touch).

### `PlinthMenu` + `PlinthMenuItem`
`controller`, `target`, `items` (`List<PlinthMenuItem>`), `position`, `width`.
Built directly on `PlinthPopover` rather than reimplementing anchored
positioning — a menu is structurally a popover whose content is a themed
item list. Each `PlinthMenuItem` has `label`, `icon`, `onTap`, `color`
(e.g. `'red'` for a destructive action), and a `divider` flag —
`PlinthMenuItem.divider()` is a shorthand constructor for a separator.
Tapping an item closes the controller *then* calls its `onTap`.

---

## Internal / not exported

- **`PlinthOverlayHost`** (`plinth_components/src/widgets/overlay_host.dart`)
  — shared listener/dispose plumbing behind `PlinthModalHost` and
  `PlinthDrawerHost`. Not part of the public API; any future route-based
  overlay host should wrap this the same way.

---

## Coming soon

Components in [Mantine's core catalog](https://mantine.dev/core/app-shell/)
that Plinth doesn't have yet, grouped by Mantine's own sections and
checked against its live component index. Nothing here is scheduled —
it's a map of the gaps, so you can tell "not built yet" from
"deliberately absent" without reading the source.

**Scope:** this covers the *core component* layer, the level this
document describes. Mantine's other layer,
[Mantine UI](https://ui.mantine.dev), is ~123 prebuilt *composed
blocks* (navbars, hero sections, auth forms, stat cards) assembled from
core components. Plinth's equivalent is the example app's showcase —
see **[SHOWCASE.md](SHOWCASE.md)** for that gap list, which is separate
from this one.

### Highest value

The gaps worth closing first, either because nothing here covers the
need at all or because the work is mostly extraction:

- **`PlinthEmptyState`** — the "no results" placeholder. Common enough
  in real apps that most teams write their own.

### Inputs

- **`PlinthColorInput`** — a text field with a color preview and
  picker. `PlinthColorSwatch` covers choosing from a preset palette.
- **`PlinthColorPicker`** — the full picker, plus its
  **`AlphaSlider`** / **`HueSlider`** / **`AngleSlider`** parts, which
  exist in Mantine mainly as its building blocks.
- **`PlinthFieldset`** — a bordered group with a legend, for related
  fields.
- **`PlinthInput`** — Mantine's unstyled base that its other fields are
  built from. Plinth's fields each own their chrome instead; adopting
  this would be an architectural change, not just a new widget.
- **`PlinthJsonInput`** / **`PlinthMaskInput`** — a validating JSON
  textarea and a format-masked field.
- **`PlinthNativeSelect`** — near-duplicate here: `PlinthSelect`
  already wraps Flutter's `DropdownButton`, which is the native
  control.

### Combobox

- **`PlinthPill`** / **`PlinthPillsInput`** — Mantine's removable-chip
  primitives. `PlinthMultiSelect` already renders chips internally, so
  this would be extracting them.
- **`PlinthCombobox`** / **`PlinthComboboxPopover`** — the low-level
  primitives Mantine's Select/Autocomplete/TagsInput are built on. Only
  worth it if several of the above land and start duplicating logic.
- **`PlinthCascader`** / **`PlinthTreeSelect`** — multi-level and
  hierarchical selection.

### Navigation & overlays

- **`PlinthTableOfContents`** — headings extracted into a jump list.
  Now that `PlinthTitle` carries heading levels, this has real
  structure to read from.
- **`PlinthTree`** — hierarchical navigation. Substantial work
  (expansion state, keyboard traversal, selection).
- **`PlinthDialog`** — a small floating panel that doesn't take the
  screen the way `PlinthModal` does.
- **`PlinthMenubar`** — a horizontal bar of menus, desktop-style.
- **`PlinthFloatingIndicator`** — the sliding indicator Mantine's tabs
  and segmented controls use. Plinth's equivalents deliberately use a
  static per-item fill instead, so this would be a change of approach
  rather than an addition (see `PlinthTabs`).
- **`PlinthFloatingWindow`** — a draggable, resizable panel.

### Data display & typography

- **`PlinthDataList`** — key/value pairs in a definition-list layout.
- **`PlinthNumberFormatter`** — locale-aware number display. Dart's
  `intl` already does the formatting; this would be the themed text
  around it.
- **`PlinthRollingNumber`** — digits that animate on change.
- **`PlinthOverflowList`** — shows as many items as fit, collapsing the
  rest into a "+N" marker.
- **`PlinthBackgroundImage`** — an image behind arbitrary content. A
  `Container` with a `DecorationImage` is close enough that the wrapper
  earns little.
- **`PlinthSemiCircleProgress`** — a gauge variant of
  `PlinthRingProgress`.

### Layout & miscellaneous

- **`PlinthStack`** — a vertical `PlinthGroup`.
  `PlinthFlex(direction: Axis.vertical)` already does this, so it would
  be a convenience alias rather than new capability.
- **`PlinthSplitter`** — resizable panes with a draggable divider.
- **`PlinthMarquee`** — continuously scrolling content.
- **`PlinthScroller`** — scroll-position helpers around `ScrollArea`.

### Deliberately not planned

These have a Flutter-native answer that a wrapper would only get in the
way of:

- **`Transition`** — `AnimatedSwitcher` and the implicit animation
  widgets already cover this, and better.
- **`FocusTrap`** — `FocusScope` is the native equivalent, and the
  overlay components already use it where it matters.
- **`Typography`** — Mantine's version styles raw HTML via the CSS
  cascade. Flutter has no cascading markup to style, so the idea
  doesn't carry over; `PlinthText` and `PlinthTitle` cover the need
  directly.

Mantine's separate packages — Carousel, Dropzone, Spotlight, Dates,
Charts, RichTextEditor, Notifications — are a different scope question,
not simply missing components. Each is a substantial library in its own
right and would belong in its own package here too, rather than in
`plinth_components`.
