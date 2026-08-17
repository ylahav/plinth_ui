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

## Naming rules

Settled in 0.20.0, after an audit found the same idea spelled three
ways. New components follow these rather than reopening them.

| Idea | Spelling | Notes |
|---|---|---|
| Not usable right now | a null callback where the component has one (`onPressed: null`), otherwise `enabled` | Flutter's own idiom. `disabled` survives only on `PlinthComboboxOption`, where an option in a list is `disabled` in both Mantine and Flutter's `DropdownMenuItem` |
| Which way it runs | `direction`, typed `Axis` | Not a `vertical` flag. `PlinthFlex`, `PlinthScrollArea`, `PlinthSplitter` and `PlinthDivider` all take it |
| Step on the size scale | `size`, typed `PlinthSize` | Never a raw number |
| A measured dimension | its own name — `diameter`, `height`, `width`, `dimension` | `PlinthRingProgress`, `PlinthSemiCircleProgress` and `PlinthAngleSlider` take `diameter`; calling that `size` made one prop name mean two different things |
| Content before the label | `leadingIcon` for an icon, `leading` for arbitrary content | Only where there *is* a label or a trailing slot to be leading of |
| Content after the label | `trailing` | Arbitrary widget, e.g. a badge |
| The component's one icon | `icon` | When a component is *made of* an icon (`PlinthActionIcon`, `PlinthThemeIcon`, `PlinthAlert`, `PlinthTimelineItem`), it isn't leading anything |
| Reporting a change | `onChanged`, taking `ValueChanged<T>` | Mantine's `onChange` |

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
`onPressed`, `child`, `variant`, `size`, `color`, `radius`, `fullWidth`,
`leadingIcon`, `loading`.
The reference implementation — every other component's variant/size/color
resolution logic follows this one's pattern.

A null `onPressed` disables it, Flutter's own convention, and since
0.19.0 that is visible: a muted fill and `textDisabled` label, or for
the variants that draw nothing (`subtle`, `transparent`) just the muted
label. A muted fill rather than an opacity wrapper, so the same disabled
button doesn't read differently on a card and on a photograph.

`loading` shows a spinner in place of `leadingIcon` and ignores taps, so
a slow request can't be submitted twice. It keeps the button's own
colors — busy is not unavailable, and greying it out would suggest the
press never landed. The spinner is sized to the label's font size, so
loading doesn't change the button's height.

### `PlinthButtonGroup`
`children`. Visually joins a row of buttons (or any bordered children)
into one connected group — outer corners stay rounded, inner corners
square off, adjacent borders collapse into a shared hairline instead of
doubling up. A layout wrapper only; doesn't alter children's own
behavior.

### `PlinthActionIcon`
`icon`, `onPressed`, `variant`, `size`, `color`, `radius`, `circle`,
`loading`. Same variant/size/color resolution as `PlinthButton`, but
square (or fully circular) with no label — for icon-only actions.
Disabled and loading behave exactly as they do there; `loading` replaces
the icon rather than sitting beside it, since there is no label to keep.

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

### `PlinthStack`
`children`, `gap` (default `PlinthSize.md`), `crossAxisAlignment`
(default `stretch`), `mainAxisAlignment`, `mainAxisSize` (default
`min`). The vertical counterpart to `PlinthGroup`. Stretches by
default where `PlinthGroup` doesn't, because a column of form fields
or buttons almost always wants full width. Named for Mantine's
component, not Flutter's `Stack` — this one lays children out in a
line and never overlaps them.

`PlinthFlex(direction: Axis.vertical)` does the same thing; this
exists because stacking vertically is common enough that saying so
directly reads better than configuring a flex.

### `PlinthSplitter`
`first`, `second`, `direction` (default `horizontal`),
`initialFraction`, `minFraction`, `maxFraction`, `thickness`,
`onFractionChanged`. Two resizable panes with a draggable divider.

The divider position is presentation-local and kept internally, like
`PlinthSpoiler`'s expanded state: it's a view preference, not
application data, and making every caller hold a double to get a
draggable divider would be friction with nothing behind it.
`onFractionChanged` reports moves for callers persisting a layout. The
drag is clamped to `minFraction`/`maxFraction`, so a pane can't be
dragged away entirely and left with no handle to drag back.

### `PlinthScroller`
`controller`, `child`, `threshold`, `alignment`, `padding`,
`duration`, `color`, `icon`, `semanticLabel`. A back-to-top button that
appears once there's something to go back to.

The `ScrollController` is shared rather than created here, because the
scrollable inside has to be built with it. State changes only when the
offset crosses `threshold`, not on every scroll pixel — a `setState`
per pixel is exactly what this widget has to avoid. While hidden it's
wrapped in an `IgnorePointer`: an invisible button that still takes
taps is worse than no button.

### `PlinthMenubar` + `PlinthMenubarMenu`
`menus`, `size`, `color`, `radius`. A horizontal bar of menus,
desktop-style.

The behaviour that makes it a menubar rather than a row of
`PlinthMenu`s: **once one menu is open, moving the pointer across the
bar opens the next one** without a second click. A row of independent
menus makes you click, dismiss, click again — wrong for a File/Edit/View
bar in a way that's hard to name until you use one. Hovering with
nothing open does nothing, which is the other half of the rule;
otherwise merely crossing the bar would open menus.

Only one menu is open at a time and the bar owns that, which is why the
controllers live inside rather than being passed in.

### `PlinthFloatingWindow`
`child`, `title`, `initialOffset`, `initialSize`, `minSize`,
`resizable`, `onClose`, `onMoved`, `onResized`, `radius`. A draggable,
resizable panel.

Not a modal and not a dialog: it stays where it's put, several can be
open at once, and nothing behind it is blocked — a tool palette, an
inspector, a preview you want beside your work rather than over it.

Position and size are kept internally for the same reason as
`PlinthSplitter`'s divider; `onMoved`/`onResized` report them for
restoring a layout. Both are clamped to the parent's bounds, so a
window can't be dragged off the edge and stranded where its header is
unreachable. Expects a bounded parent — put it in a `Stack` filling the
area it should float over.

### `PlinthMarquee`
`child`, `speed` (logical pixels per second, default `40`), `gap`
(default `xl`), `pauseOnHover` (default `true`), `reverse`. Content
that scrolls past continuously — a logo strip, a headline ticker. The
child is repeated as many times as the width needs, so the loop has no
visible seam.

**Motion here is an accessibility question, not just a style one.**
WCAG asks that movement lasting more than five seconds can be paused,
and a marquee by definition never stops on its own. So this honours the
platform's reduce-motion setting by rendering the content once and
stationary, and pauses under the pointer by default. `pauseOnHover` is
desktop and web only, which is why it can't be the whole story on its
own and the reduce-motion behaviour isn't optional.

One copy is measured on the first frame to find the loop's period, so
the scroll starts a frame after mount; re-measured on later frames too,
so a child that changes size (a font loading, an image arriving) can't
leave the loop wrapping at a stale width.

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
`children`, `columns`, `spacing` (default `PlinthSize.md`), plus
`columnsXs`/`columnsSm`/`columnsMd`/`columnsLg`/`columnsXl`. A grid with
the same number of equal-width columns per row and consistent spacing.
The per-breakpoint counts work exactly like `PlinthGridCol`'s spans —
mobile-first, applying from that width upward — so `columns: 1,
columnsMd: 3` stacks on a phone and goes three across on a desktop, and
`columns: 3` on its own still means three at every width. Unlike
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

### `PlinthBackgroundImage`
`src`, `child`, `width`, `height`, `fit` (default `BoxFit.cover`),
`radius` (default `sm`), `scrimOpacity` (default `0.35`), `alignment`.
An image behind arbitrary content. A `Container` with a
`DecorationImage` is most of this already; what it adds is the part
people forget — text over a photograph is unreadable against the light
parts of it, so a scrim goes between the two, and `child` takes the
`onFilled` foreground rather than the theme's body text colour. Set
`scrimOpacity: 0` only when the image is known to be dark or nothing
sits on top of it. A failed image falls back to a `surfaceMuted` fill
and keeps rendering `child`, rather than taking the content down with
it.

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
`direction` (`Axis`, default horizontal), `height` (only meaningful
when vertical — — `VerticalDivider`
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
(default `true`), `size`, `color`, `radius`, `error`. One box per character, with
auto-advancing focus as each digit is typed and auto-retreating focus on
backspace from an already-empty box.

### `PlinthCheckbox`
`value`, `onChanged` (nullable — null disables), `label`, `description`,
`error`, `indeterminate`, `size`, `color`, `radius`.

`indeterminate` draws the box filled with a dash for the "some of the
children are selected" state — filled rather than empty, since an empty
box claims "none of them", which is what this state exists to deny. It
reports `CheckedState.mixed` to assistive technology, and leaves what a
tap reports to `value`, so resolving the mixed state stays the caller's
decision.

`description` and `error` are the same chrome the text inputs have had
from the start; `PlinthRadio` and `PlinthSwitch` take both too, as of
0.21.0.

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
`enabled`, `clearable`, `multiple`, `leadingIcon`.

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
`clearable`, `maxTags`, `allowDuplicates`. Free-text entry producing
removable chips.

`PlinthMultiSelect` is the fixed-options equivalent, where the user
picks from a list you supply; this is where they invent the values.
Enter or a comma commits — so pasting `dart, flutter` yields two tags —
and backspace in an empty field removes the last one. Duplicates are
rejected by default, since two identical chips give the user no way to
tell them apart.

### `PlinthAutocomplete`
`value`, `onChanged`, `options`, `label`, `description`, `placeholder`,
`error`, `size`, `color`, `radius`, `enabled`, `clearable`, `limit`
(default `8`), `onOptionSelected`. A text field with suggestions.

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
`description`, `placeholder`, `error`, `size`, `color`, `radius`, `enabled`,
`clearable`.
Shares `PlinthTextInput`'s label/description/error chrome; wraps
`DropdownButton` internally with the default underline hidden.

`clearable` shows a small clear button once a value is chosen, reporting
`null`. It sits *outside* the `DropdownButton` rather than in its `icon`
slot, since that slot is inside the dropdown's own hit area and a tap
there would open the menu it is supposed to be clearing.

### `PlinthSwitch`
`value`, `onChanged` (nullable), `label`, `description`, `error`, `size`,
`color`, `radius`. Same animated-fill pattern as `PlinthCheckbox`,
pill-shaped instead of square.

### `PlinthSlider` + `PlinthSliderMark`
`value`, `onChanged` (nullable), `min`, `max`, `divisions` (omit for
continuous), `color`, `size`, `label` (shown above the thumb while
dragging), `marks`, `restrictToMarks`. A themed wrapper around Flutter's
built-in `Slider` (via `SliderTheme`) — same rationale as
`PlinthTooltip`: drag handling, keyboard stepping, and accessibility are
worth not reimplementing.

`marks` names positions along the track. Each `PlinthSliderMark` takes a
`value` in the slider's own units — not a fraction, so the same list
survives a change of range — and a `label`. The labels render beneath
the track, each centred on the point it names, allowing for the thumb
radius Flutter insets the track by at both ends. A slider with no marks
lays out exactly as before: no wrapper, no extra height.

**Labels, not ticks.** The ticks on the track are Flutter's own, drawn
from `divisions`; painting a second set would mean guessing at the track
geometry of a widget this only themes. Marks *name* positions,
`divisions` marks them, and the two are usually set together.

`restrictToMarks` snaps every reported value to the nearest mark — for a
scale whose steps aren't evenly spaced (1, 2, 5, 10), which `divisions`
can't express since it splits the range evenly.

### `PlinthRangeSlider`
`values` (`RangeValues`), `onChanged` (nullable), `min`, `max`,
`divisions`, `color`, `size`, `labels` (`RangeLabels`), `marks`. Same
wrap-not-reimplement rationale as `PlinthSlider`, wrapping Flutter's
built-in `RangeSlider` for dual-thumb range selection. Marks work as
they do there, with both thumbs emphasising the mark they sit on.

### `PlinthMultiSelect<T>` + `PlinthMultiSelectOption<T>`
`options`, `value` (`List<T>`), `onChanged`, `label`, `description`,
`placeholder`, `error`, `size`, `color`, `radius`, `enabled`,
`clearable`. Chosen
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
`size`, `radius`. Standalone toggle — for a group, manage a `Set`/value in your own
state and pass `selected` per chip, same controlled-component pattern as
`PlinthCheckbox`/`PlinthRadio`.

### `PlinthRating`
`value` (fractional values like `3.5` render as partly filled stars),
`onChanged`
(omit for a read-only display — e.g. showing an existing average rating),
`count` (default `5`), `color` (defaults to an amber gold, not the theme's
primary color — a rating in brand blue reads oddly against the
conventional gold-star look), `size`, `fractions`.

`fractions` (default `1`) is how many parts each star can be
*selected* in — `2` for halves, `4` for quarters. It splits each star
into that many hit regions, so a tap reports a value `1 / fractions`
granular. Rendering has always handled fractions; only choosing one
was missing.

Empty, half and full stars use Material's own drawn glyphs; anything
between them is a clipped fill, since a designed half-star beats a
mechanically clipped one where there is a glyph for it.

### `PlinthFieldset`
`child`, `legend`, `variant` (`defaultVariant` draws a border,
`filled` uses a muted fill with no border; other variants fall back to
the border treatment), `radius`, `padding` (default `md`), `enabled`.
A bordered group of related fields, with the legend sitting *in* the
border rather than above it — that's what distinguishes it from a
titled `PlinthCard`: the frame says "these belong together" and the
legend names the grouping without reading as a section heading for the
rest of the page.

`disabled` greys the contents and blocks interaction with everything
inside, so a whole section switches off without each field needing its
own `enabled` wired up. The legend is announced as a label for the
group, so a screen reader reaches "Shipping address, Street" rather
than a bare "Street".

### `PlinthMaskInput`
`mask`, `value`, `onChanged`, plus `PlinthTextInput`'s label,
description, placeholder, error, size, colour, radius and enabled. A
field that formats as you type. `#` is a digit, `A` a letter, `*`
either; everything else is a literal the field inserts.

`onChanged` reports the masked text as shown. The static
`PlinthMaskInput.unmask(masked, mask)` strips it back to the typed
characters — a phone number is usually stored without its brackets,
and the widget shouldn't decide that for you.

The formatter rebuilds the whole value on every edit rather than
patching it. Patching is where masked inputs usually go wrong: deleting
a character in the middle, or pasting, leaves the literals in the wrong
places. Characters that can't fill a slot are skipped rather than
rejecting the edit, so a stray space in a pasted number doesn't discard
the paste.

### `PlinthJsonInput`
`value`, `onChanged`, `onValidChanged`, `label`, `description`,
`placeholder`, `error`, `formatOnBlur`, `validationMessage`,
`minLines`, `maxLines`, `size`, `color`, `radius`, `enabled`. A
textarea that validates JSON.

**Validation runs on blur, not on every keystroke.** Half-typed JSON is
invalid by definition — an object is broken from the opening brace
until the closing one — so validating as you type means showing an
error for the entire time somebody is writing. Focusing again clears
it, rather than leaving a red field while it's being fixed.

`formatOnBlur` pretty-prints valid JSON when focus leaves, which is the
one moment it's welcome: reformatting mid-edit moves the caret out from
under whoever is typing. A caller-supplied `error` outranks the parse
error, since a schema problem is more specific than "this isn't JSON".
The statics `isValid` and `format` are exposed for the form that has to
ask the same question before submitting.

### `PlinthFileButton`
`onPick`, `onChanged`, `child`, plus `PlinthButton`'s variant, size,
colour, radius, fullWidth, leadingIcon and enabled. A button that opens
your file picker.

**It does not open a picker**, for the same reason `PlinthFileInput`
doesn't: Flutter has no built-in one, and every package that provides
it would become a dependency of `plinth_components` for every app.
`onPick` is yours; returning null or an empty list means cancelled, and
reports nothing.

Where `PlinthFileInput` is a form field — label, error, files listed
underneath — this is only the trigger, for when the selection is shown
somewhere else or not at all. It disables itself while `onPick` is in
flight, which is the one thing a plain button gets wrong here: a picker
is slow enough to invite a second tap, and two open pickers is a state
nobody handles.

### `PlinthPill`
`label` (positional), `onRemove`, `size`, `color`, `radius`,
`leadingIcon`. A removable value chip.

Three chip-shaped things live here and they are not interchangeable.
`PlinthBadge` is a **label** — it states something and does nothing.
`PlinthChip` is a **toggle** — it has selected/unselected state.
This is a **value** — one entry in a collection the user built, whose
only action is to leave. That's why it isn't a variant of either: a
remove button means something quite different from a selected state,
and conflating them makes both call sites read wrong.

`PlinthMultiSelect` and `PlinthTagsInput` render their values with it.
Before it existed, TagsInput had a private `_TagChip` and MultiSelect
used Flutter's raw `Chip` — which modelled the delete affordance
correctly but carried Material's own sizing and colours through a
themed field. The remove button names its value ("Remove design"), so
a row of them isn't a row of identical "close" buttons to a screen
reader.

### `PlinthPillsInput`
`children`, `label`, `description`, `error`, `placeholder`, `size`,
`color`, `radius`, `enabled`, `focused`, `onTap`. The field that holds
pills: the label, the bordered box that wraps onto new lines, the
focus and error borders, the message underneath.

Chrome, not behaviour — what goes inside is yours. `PlinthMultiSelect`
and `PlinthTagsInput` are the two finished components of this shape and
either is the better answer when it fits; this is for when neither
does, with values coming from somewhere else entirely.

`focused` is passed in rather than tracked, because whatever owns the
input inside also owns its focus node, and two widgets disagreeing
about focus is worse than one prop. An `error` outranks `focused` on
the border, the same order `PlinthTextInput` uses.

### `PlinthCombobox` + `PlinthComboboxOption`
`controller`, `target`, `options`, `onSelected`, `selected`, `width`,
`maxHeight`, `empty`, `size`, `color`, `radius`, `closeOnSelect`. The option-list
primitive behind a select-shaped control.

This is the part that is genuinely fiddly and genuinely shared: an
overlay anchored to a field that tracks it through scrolling, a
highlighted option that moves with the arrow keys and **skips disabled
entries** (one the keyboard lands on is a trap), Enter to take the
highlight, Escape to abandon it, and a list that stays in sync when
its options are replaced underneath — which is what filtering as you
type does on every keystroke.

Opening highlights the current value rather than the top, so the first
arrow press moves from where you are. The highlight stops at the ends
rather than wrapping, since wrapping past the bottom of a long filtered
list reads as a glitch. Opening also takes keyboard control only if
nothing inside the target already has it, so a text-field target keeps
its caret while the arrows still reach the list.

Unlike `PlinthPopover`, tapping the target is *not* wired up: the
trigger is usually a text field that needs its taps for the caret, so
opening is the caller's call.

**Mantine's `Combobox.Dropdown` is folded in rather than exported
separately.** In React the dropdown is distinct markup; here the
overlay is plumbing rather than something a caller composes, and
`PlinthPopover` already covers "anchored panel with arbitrary
content". A second wrapper would be API surface with nothing behind it.

`PlinthSelect`, `PlinthAutocomplete`, `PlinthMultiSelect` and
`PlinthTagsInput` predate this and keep their own dropdown mechanics.
This is for building the next one — or a control none of them cover,
like a command palette.

### `PlinthTreeSelect`
`nodes` (`List<PlinthTreeNode>`), `value`, `onChanged`, `label`,
`description`, `placeholder`, `error`, `selectableBranches`, `size`,
`radius`, `enabled`, `dropdownWidth`, `dropdownMaxHeight`. A select
whose options are a hierarchy.

`PlinthSelect` flattens everything into one list, which stops working
the moment the options have structure — a category and its
subcategories, a folder and its files. This is that list with the
structure kept. Opening it expands the branches leading to the current
value, so a deep selection is visible rather than hidden three levels
down. `selectableBranches: false` makes tapping a branch only open it,
for when only leaves are real choices.

### `PlinthCascader` + `PlinthCascaderOption`
`options`, `value` (the path), `onChanged`, `columnWidth`, `height`,
`size`, `color`, `radius`. Column-by-column selection through a hierarchy.

The same data `PlinthTreeSelect` shows, arranged for a different
question. A tree is for *finding* one item in a structure you have to
explore; this is for *walking a known path* — country → region → city
— where every level is a real decision and seeing the alternatives at
each one is the point.

The value is the path (`['eu', 'fr', 'paris']`), not a leaf, which
keeps a partial selection representable: choosing a category without
yet choosing its subcategory is a normal intermediate state rather than
an error. Choosing at a shallower level truncates the path, since
everything to its right is no longer reachable.

Panels wider than the available width pan sideways rather than
overflowing — three levels at the default `columnWidth` already needs
more than a phone has. When they fit, the box still shrink-wraps to
them, so its border stops at the last panel rather than stretching
across a wide screen.

Renders inline. Wrap it in a `PlinthPopover` for the dropdown form —
the columns are the part worth having, and keeping the trigger out
means it composes into a filter bar or a settings panel just as easily.

### `PlinthColorInput`
`value` (a `Color`), `onChanged`, `label`, `description`,
`placeholder`, `error`, `withAlpha`, `swatches`, `size`, `radius`,
`enabled`. A hex text field with a preview swatch that opens a
`PlinthColorPicker`.

Both halves matter: typing `#2f9e44` is the fastest way in when you
know the value, and the picker is the only way in when you don't. The
swatch is the picker's trigger rather than the whole field, since a
field that opened a dropdown on every tap would fight the caret for
the same gesture.

Typing is parsed leniently — `#abc`, `abc`, `#aabbcc`, `aabbcc`, and
with `withAlpha`, `#aabbccdd` in CSS order. An unparseable value is
simply not reported: the field keeps what was typed, so a half-finished
`#2f9` isn't destroyed mid-keystroke, and `onChanged` fires only once
the text means something. The static `formatHex`/`parseHex` are
exposed, since the same string usually has to appear elsewhere.

Where `PlinthColorSwatch` chooses from a fixed palette, this accepts
any colour — so reach for the palette when the choice should stay
on-system, and this when it genuinely shouldn't.

### `PlinthColorPicker`
`value`, `onChanged`, `withAlpha`, `swatches`, `areaHeight` (default
`140`), `radius`. A saturation/brightness area, a hue slider, and
optionally an opacity slider. Controlled like every other input here.

It remembers the last meaningful hue. Hue is *undefined* for greys and
blacks — `HSVColor` reports 0 — so reading it straight back would snap
the picker to red the moment brightness hit zero, and dragging the hue
slider on a black would appear to do nothing. Keeping the hue
separately is what lets the two controls behave independently, and it's
the difference between "drag to black and back" returning your colour
or returning red.

Without `withAlpha` the picker forces alpha to 1, rather than quietly
carrying through a transparency the UI gives no way to see or change.

### `PlinthHueSlider`
`value` (degrees, 0–360), `onChanged`, `height`, `radius`,
`saturation`/`brightness` (thumb preview only). One of the picker's
parts, exported separately because a hue alone is often the whole
interaction — tinting a chart series, theming a workspace — and a full
picker would be the wrong amount of UI for it. The track always shows
fully saturated hues; a washed-out track makes neighbouring hues hard
to tell apart.

### `PlinthAlphaSlider`
`color` (the colour whose opacity is being chosen — its own alpha is
ignored), `value` (0–1), `onChanged`, `height`, `radius`. The track
runs from transparent to `color` over a chequer, the convention that
separates *transparent* from *pale*: without it, 50% black and solid
grey look identical.

### `PlinthAngleSlider`
`value` (degrees), `onChanged`, `diameter` (default `60`), `thickness`,
`color`, `step`, `divisions`. A circular dial — the one control in this
set that isn't about colour. It picks a direction: a gradient's angle,
a shadow's offset, a rotation. Zero points up and the value grows
clockwise, the compass convention a dial implies, rather than the
mathematical one where zero points right and grows anticlockwise.
`divisions` snaps to equal steps — 8 for the compass points, 12 for
the clock positions.

**A note on all four sliders.** `PlinthSlider` wraps Flutter's
`Slider` precisely so drag handling, keyboard steps, and screen-reader
announcements don't have to be re-derived. These can't: their tracks
are gradients and a dial, and `SliderTheme` only paints flat colours.
So the parts `Slider` would have given free are rebuilt deliberately —
drag, tap-to-jump, arrow-key steps with Home/End, and a slider
semantics node announcing a real value ("210 degrees", not "0.58").
The shared machinery lives in one internal base so it isn't written
twice and left half-done in one of them.

---

## Feedback

### `PlinthBadge`
`label` (positional), `variant`, `size`, `color`, `leadingIcon`,
`radius`. Renders
uppercase by default, pill-shaped (`borderRadius: 999`).

### `PlinthAlert`
`title` (optional), `child`, `color` (default `'blue'`), `icon`, `onClose`
(non-null shows a close button), `radius`. Background at shade 0, accent
(icon/title/border) at shade 6.

### `PlinthProgress` + `PlinthProgressSection`
`value` (0.0–1.0, asserted in range), `color`, `size` (controls track
height), `radius`, `trackColor`. Fill animates smoothly on value change
via an internal `AnimatedFractionallySizedBox` helper.

`PlinthProgress.sections(sections: [...])` draws a part-to-whole bar
instead — traffic split by source, storage by file type. Each
`PlinthProgressSection` takes `value`, `color` (a palette key, required:
sections sharing one colour are a single bar drawn in pieces) and an
optional `label`.

Section values are fractions **of the whole bar**, not of each other:
0.5, 0.3 and 0.1 leave a tenth of the track empty, which is how a
part-to-whole bar says "and this much is neither". Values summing above
1 assert rather than being normalised — scaling raw counts is the
caller's job, and normalising silently would change what `value` means
depending on the data. The labelled sections are joined into one
semantics label, since a bar with no text in it otherwise reads as
nothing at all.

The named constructor isn't `const`: checking that the parts fit inside
the whole means summing them, which a const assert can't do.

### `PlinthRingProgress`
`value` (0.0–1.0, asserted in range), `color`, `diameter` (default 80),
`thickness` (default 8), `trackColor`, `label` (optional
centered content, e.g. a percentage). Circular companion to
`PlinthProgress` — built on `CustomPaint`, sweeping clockwise from 12
o'clock.

`PlinthRingProgress.sections(sections: [...])` takes the same
`PlinthProgressSection` list — a donut rather than a gauge. Its arcs use
butt caps rather than the single-value ring's round ones: rounded ends
on consecutive arcs overlap, so each section would eat a little of the
one before it.

### `PlinthSemiCircleProgress`
`value` (0.0–1.0, asserted in range), `color`, `diameter` (of the full
circle the arc is taken from, default 160 — rendered height is about
half that), `thickness` (default 12), `trackColor`, `label`.
`PlinthRingProgress` drawn as a 180° arc, which suits a dashboard tile
better than a full circle: the flat bottom sits on a baseline, and the
empty half of a full ring reads as wasted space when the value is the
only thing on the card. `thickness` is clamped to `size / 2` so an
over-thick arc can't paint back over itself.

### `PlinthEmptyState`
`title`, `description`, `icon` (shown above the title in a
`PlinthThemeIcon`, and hidden from assistive tech as decorative —
the title already says what it illustrates), `action`, `color`, `size`.
The "nothing here" placeholder. Distinct from `PlinthSkeleton`, which
stands in for content that is *coming*: this is for content that isn't
there — an empty search result, an unused inbox, a project with no
members yet.

`action` is the way out, and worth passing: an empty state without one
tells the user their situation but not what to do about it. The title
renders at heading level 4, since an empty state heads a region rather
than a page.

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
`color`, `colorValue`, `dimension`. The loading indicator on its own, for
a button mid-submit or an empty panel awaiting its first fetch.
`PlinthLoadingOverlay` already shows a spinner, but only as part of
covering existing content.

`colorValue` and `dimension` are exact overrides for `color` and `size`,
added so `PlinthButton.loading` could put a spinner in a filled button:
its foreground is whatever `contrastingOn` resolved against that fill, a
color the palette can't name, and its extent has to match the label's
line height rather than a step on the size scale. Mantine's `color`
takes a theme key *or* any CSS color; in Dart those are two types, so
they are two parameters.

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
`visible` (default `true`; false hides the dot without removing `child`
from the tree),
`radius` (squares off the dot; omit for the round default).
Anchors a small badge/dot to a corner of `child` via `Stack` +
`FractionalTranslation`.

### `PlinthCarousel` + `PlinthCarouselController`
`slides`, `height` (default `240`), `slideSize` (default `1.0`), `gap`
(default `sm`), `loop`, `withControls` (default `true`),
`withIndicators`, `initialSlide`, `onSlideChanged`, `controller`,
`color`. Swipeable slides with arrows, dot indicators, and looping.

Position is presentation-local, so this manages it internally the way
`PlinthAccordion` manages expansion, rather than taking a
`value`/`onChanged` pair like `PlinthTabs`. `onSlideChanged` reports
each new index — enough to drive a caption beside it — and
`PlinthCarouselController` (`next`, `previous`, `jumpTo`, `index`)
drives it from a button elsewhere on the page.

`slideSize` is a fraction of the viewport, matching Mantine's: below 1
the neighbouring slides peek in, which is what tells a reader there is
more to swipe to. `height` bounds the slide area, since a `PageView`
inheriting an unbounded height is a layout exception rather than a
carousel; indicators sit below that area. Arrow keys work once it has
focus, arrows disable at each end unless `loop` is set, and a
single-slide carousel renders neither arrows nor dots.

Looping is an endless page list mapped back onto the slides by
remainder, so there is no seam to cross at either end.

**No autoplay**, deliberately. Mantine ships its own as a plugin, and
the reason carries: slides that move on their own take content away
from a slow reader, and doing it properly means pausing on hover, on
focus, on `MediaQuery.disableAnimations`, and while the tab is hidden.

### `PlinthColorSwatch`
`color` (a theme palette key, e.g. `'blue'`), `selected`, `onTap`, `size`,
`radius` (defaults to a squarer 6px rather than the theme radius — a
swatch is a sample of colour, and squarer corners show more of it).
Standalone selectable color square — for a picker, lay out several with
your own selected-color state, same controlled-component pattern as
`PlinthChip`.

### `PlinthNumberFormatter`
`value` (`num`), `prefix`, `suffix`, `thousandSeparator` (default
`','` — pass an empty string to group nothing), `decimalSeparator`
(default `'.'`), `decimalScale` (null keeps whatever the value has),
`trimTrailingZeros`, `size`, `color`, `weight`. Grouping, decimals,
prefix, and suffix — the formatting a figure in a table or a stat tile
needs, without reaching for a package.

**Not localised.** The separators are yours to pass, so it's correct
for a fixed format and wrong for anything that should follow the
user's locale. For that, format with `package:intl`'s `NumberFormat`
and render the result with `PlinthText`; this widget deliberately
doesn't pull `intl` into the dependency graph of every app using the
library.

The `formatted` getter exposes the string, so the same formatting can
be reused where the widget doesn't fit — a chart axis, an exported
CSV, a semantics label.

### `PlinthRollingNumber`
`value`, the same formatting props as `PlinthNumberFormatter`
(`prefix`, `suffix`, `thousandSeparator`, `decimalSeparator`,
`decimalScale`, `trimTrailingZeros`), plus `duration` (default 600ms),
`curve`, `size`, `color`, `weight`. Digits that roll to their new
value — a live counter, a total that updates as a form is filled in, a
stat tile.

Formatting is delegated to `PlinthNumberFormatter` rather than
reimplemented, so the two can't drift and the same non-localised
caveat applies. The roll is a real odometer: the *value* animates and
each digit's position is derived from it, which is what makes 999 →
1000 turn every digit forward together. Tweening each digit separately
would send the 9 backwards through 8, 7, 6 while its neighbours went
the other way.

Honours reduce-motion (settling immediately), and announces the whole
formatted number once rather than letting a screen reader read a
stream of changing digits. Digits inside a `prefix` or `suffix` are
labels, not place values, and stay still.

### `PlinthDataList` + `PlinthDataListItem`
`items`, `orientation` (`PlinthDataListOrientation`: `horizontal,
vertical` — default `horizontal`), `gap`, `labelGap`, `size`,
`labelColor`. Key/value pairs in a definition-list layout — an order
summary, a resource's metadata, the "about" block on a profile.

Distinct from `PlinthTable`, which is for many records sharing
columns; this is for one record's fields, where the label belongs to
the value rather than to a column. Labels default to the theme's muted
text, because the label is chrome and the value is the content.

`PlinthDataListItem(label:, value:)` takes a widget value — a badge
for a status, an anchor for an email — and `PlinthDataListItem.text`
takes a plain string, the same split `PlinthTable` settled on and for
the same reason. Horizontal aligns every label into one
`IntrinsicColumnWidth` column via `Table`, so values line up without
the caller measuring anything; vertical stacks each pair and merges it
into a single semantics run.

### `PlinthOverflowList`
`children`, `gap` (default `sm`), `labelBuilder` (default `+N`),
`size`, `color`. Shows as many children as fit on one line and
collapses the rest into a marker — the avatar stack ending in "+4",
the tag row that mustn't wrap. Distinct from `PlinthGroup`, which
wraps onto a second line, and from clipping, which hides the overflow
without admitting it exists.

How many children fit is only knowable once they have been laid out,
so this is a render object rather than a composition: measuring in a
`LayoutBuilder` and rebuilding would cost a frame of the wrong answer
every time the width changed. The marker is painted directly for the
same reason — its text depends on the count layout produces. The
marker is measured per candidate count rather than reserved at a worst
case, so no item is dropped to make room for a label a shorter one
wouldn't have needed.

Children past the cut are still built (they have to be, to be
measured) but are not painted, not hit-testable, and not visible to
assistive technology — announcing items nobody can see gives a screen
reader user no way to act on them, so the count is the honest summary.
`RenderOverflowList` exposes `visibleCount` and `overflowCount`, since
the hidden children are still in the widget tree and `find.text` can't
tell what was actually shown.

### `PlinthTable`
`columns` (`List<String>`), `rows`, `striped`, `size`,
`highlightOnHover`, `maxHeight`. Built on
Flutter's low-level `Table` widget rather than `DataTable`, since
`DataTable`'s built-in Material styling (fixed row heights,
sort/selection chrome) fights against a themeable design system more
than it helps.

Two constructors, because most tables are only text but the interesting
ones aren't:

- `PlinthTable(rows: List<List<Widget>>)` — cells are widgets, so a
  status column can hold a `PlinthBadge`, a person column a
  `PlinthAvatar`, an actions column a `PlinthActionIcon`. A bare `Text`
  cell inherits the table's size and text colour, so it lines up with
  the styled cells beside it.
- `PlinthTable.text(rows: List<List<String>>)` — plain strings, styled
  for you. Stays `const`, and avoids wrapping every value.

Each inner list must match `columns.length`. Columns share the
available width, so a cell is width-bounded: a `Row` inside one needs a
`Flexible` or `Expanded` around anything that can grow, or it overflows
rather than ellipsizing.

**Sorting and filtering.** `sortable` makes every header tappable with
a direction caret; `filter` keeps only rows containing that text, case
insensitively, across every column; `emptyState` replaces the rows when
nothing matches.

Both need something comparable, and **a widget cell has no value to
compare** — one `PlinthBadge` isn't greater or less than another. So
`PlinthTable.text` sorts and filters out of the box, while the widget
constructor needs `sortValues`: the plain strings standing behind the
widgets, in the same shape as the rows. Passing `sortable` or `filter`
without them asserts in debug rather than silently doing nothing.

Sorting is numeric where both sides parse as numbers, so a quantity
column orders 9 before 10 rather than after it, and stable for equal
keys, so rows don't shuffle between rebuilds.

It is uncontrolled by default — tapping sorts in place, tapping again
reverses. Pass `onSortChanged` to take that over: the table then
reports the sort it *would* apply and leaves the row order alone,
which is what a server-side or paginated table needs. Same split as
`PlinthTabs`/`PlinthTabView`.

**A header that stays put.** Mantine spells this `stickyHeader`, a flag
over the page's own scrolling. Flutter has no page scroll to stick to,
so the table has to own one — and a scroll view needs a height.
`maxHeight` is therefore the whole feature in one prop: give the table
a ceiling and its rows scroll under a header that stays. A separate
`stickyHeader: true` would only be a flag that throws when the height
it needs is missing, which is a prop that can be set wrong.

Under the hood the header and the body become two `Table`s. That works
only because every column is an equal-flex share of the available
width, so both land on the same column edges no matter what is in the
cells. Below `maxHeight` the table is its natural height, so a short
table doesn't grow to fill it.

**`highlightOnHover`** tints the row under the pointer. The region sits
on the cells rather than the row — a `TableRow` is configuration, not a
widget, so there is nothing spanning a row to wrap. Entering any cell
claims the row and only leaving the whole table gives it up, so the few
pixels a short cell doesn't cover in a tall row don't make the
highlight flicker. Pointer-only by nature, so it is decoration rather
than information.

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
`color`, `radius`, `direction`. Each `PlinthStep` has `label` and optional `description`. Purely
a visual progress indicator — like `PlinthTabs`/`PlinthTabView`, it doesn't
manage step *content*; pair with your own conditional rendering driven by
the same `currentStep` you pass in. Tapping a step calls `onStepTapped`
but doesn't change `currentStep` itself — controlled-component pattern,
same as `PlinthTabs`.

`direction: Axis.vertical` runs the sequence down the page, with each
label beside its circle rather than under it — the shape a long
checkout or onboarding flow wants, where a description gets a line's
width to sit on instead of a column's.

### `PlinthBreadcrumbs` + `PlinthBreadcrumbItem`
`items` (`List<PlinthBreadcrumbItem>`), `separator` (default `'/'`), `color`.
Each `PlinthBreadcrumbItem` has `label` and optional `onTap`. The *last*
item is always rendered as plain, non-interactive text regardless of
whether it has an `onTap` — matching the convention that the current page
isn't itself a link.

### `PlinthPagination`
`page` (1-based), `total`, `onChanged` (nullable — null disables every
control), `color`, `size`, `radius`, `siblingCount`
(default `1` — how many page numbers show on either side of `page` before
collapsing into an ellipsis), `withEdges`. For large `total`, always shows the first
page, the last page, and `page`'s immediate neighbors; everything else
collapses into a single `…` marker per side.

`withEdges` adds first/last controls outside the previous/next pair.
They earn their space once the range collapses: jumping from page 14 of
200 back to the start otherwise means tapping `1`, which the ellipsis
has usually hidden.

### `PlinthTimeline` + `PlinthTimelineItem`
`items` (`List<PlinthTimelineItem>`), `color`. Each `PlinthTimelineItem`
has `title`, optional `description`/`icon`, and `active` (highlights the
dot in the theme color — use for the current/most-recent event). Dots are
connected by a line via `IntrinsicHeight` + `Expanded`, a standard Flutter
pattern for "match this column's height to its sibling."

### `PlinthTree` + `PlinthTreeNode`
`nodes`, `expanded` (`Set<String>`), `onExpandedChanged`, `selected`,
`onSelected`, `size`, `color`, `indent`. Hierarchical navigation with
expandable branches. Each `PlinthTreeNode` has `value` (unique across
the tree), `label`, `children`, and an optional `icon`.

Controlled, and it matters more here than elsewhere: a file tree that
loads children on expand, or restores its open branches between
sessions, needs that state above the widget. Expansion and selection
are tracked by `value` rather than by position, so a tree can be
reordered or lazily filled without losing its open branches.

Keyboard traversal works the way a tree is expected to — arrow
up/down move between visible rows (Flutter's own directional
traversal, since every row is focusable), right opens a branch, left
closes it or steps out to the parent. Leaves reserve the caret's width
so labels line up down a level instead of stepping in and out, and
only branches carry an expanded state in semantics: a leaf announcing
"collapsed" would be claiming it opens.

### `PlinthTableOfContents` + `PlinthTocItem`
`items`, `activeIndex`, `onSelected`, `size`, `color`, `indent`,
`withRail`, `scrollDuration`. A jump list of a page's headings. Each
`PlinthTocItem` has `label`, `order` (1–6, matching `PlinthTitle`), and
an optional `targetKey`.

**Headings are passed in, not discovered.** Mantine's version reads
them out of the DOM; Flutter has no document to walk, and crawling the
widget tree for `PlinthTitle`s would be both fragile and blind to
anything not yet built inside a lazy list. The explicit list also means
it can name sections that aren't headings at all.

Indent is relative to the shallowest heading present, so a document
starting at level 2 isn't permanently indented. Give an item a
`targetKey` matching a key on the heading and tapping scrolls to it —
via `Scrollable.ensureVisible`, which needs the target already built,
so use a `SingleChildScrollView` or handle `onSelected` yourself in a
lazy list. The active entry carries weight *and* colour, not just the
rail: a rail alone is easy to miss, and colour alone doesn't survive a
mono display.

### `PlinthNavLink`
`label`, `leadingIcon`, `trailing` (e.g. a `PlinthBadge` for an unread
count),
`active`, `onTap`, `color`, `children`, `opened`, `onOpenedChanged`,
`childrenOffset`. Sidebar-style navigation item — active state
tints the background and label in the theme color.

**Nesting.** `children` makes the link a disclosure: they sit indented
beneath it (by `childrenOffset`, default the theme's `lg` spacing) and
animate in and out through `PlinthCollapse`. `opened` is controlled by
the caller, like every other disclosure here, and a tap reports the
flip through `onOpenedChanged`.

`onTap` stays separate, and a parent with both calls both. Keeping them
apart is what lets a parent that is *only* a grouping heading stay
unreachable as a route, which is the shape a sidebar usually wants. The
chevron is supplied for you when there are children, unless `trailing`
fills that slot with something of its own.

`PlinthCollapse` keeps children mounted while closed, so a deep tree
pays to build every branch. For a sidebar that's the point — state in a
branch survives closing it — but a tree of hundreds of nodes wants
`PlinthTree`, which builds what it shows.

### `PlinthTabs<T>` + `PlinthTabView<T>`
`PlinthTabs`: `tabs` (`List<PlinthTabItem<T>>`), `value`, `onChanged`, `size`,
`color`, `direction`. Renders an underline-style tab bar — deliberately a static
per-tab underline rather than a measured sliding indicator (the kind
needing `GlobalKey`/`RenderBox` size lookups), to keep the implementation
simple and reliable.

More tabs than fit scroll horizontally rather than overflowing, so the
strip fills the width it is given and its underline runs the width of
the container. Given *unbounded* width — a tab bar in a `Row` with no
`Expanded` — it falls back to shrink-wrapping, since a scroll view
needs a bounded main axis and nothing can overflow a width that isn't
there.

`direction: Axis.vertical` stacks the tabs in a column and moves both
the divider and the active indicator to their trailing edge, so the
content sits to the right of the list — the shape a settings sidebar
wants, and the one where a dozen tabs stay readable. The same
bounded-axis rules apply, one axis over: a bounded *height* scrolls,
and an unbounded *width* takes the widest tab's width rather than
stretching to a width that isn't there.

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

All five controller-based overlay components share `PlinthDisclosureController`
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

### `PlinthDialog`
`controller`, `child`, `title`, `position` (`PlinthDialogPosition`:
`topLeft, topRight, bottomLeft, bottomRight` — default `bottomRight`),
`width` (default 320), `withCloseButton` (default `true`), `radius`,
`margin` (distance from the screen edges, default `lg`). A small
floating panel anchored to a screen corner.

Deliberately *not* a modal. `PlinthModal` takes the screen, dims what's
behind it, and demands an answer before anything else can happen; this
sits in a corner and lets the user carry on — a cookie notice, a
"we've updated" prompt, a quick feedback box. There's no barrier and
no `IgnorePointer`, so a tap that misses the panel falls straight
through to whatever is underneath.

Renders nothing inline — the panel is mounted in the overlay, so it
escapes any clipping ancestor. Mount it anywhere below an `Overlay`
and drive it with the controller. `withCloseButton` defaults on
because a dialog with no close button and no action inside it is a
trap.

### `PlinthPopover`
`controller`, `target`, `content`, `position` (`PlinthPopoverPosition`:
`top, bottom, left, right`), `width`, `radius`, `closeOnOutsideTap`. Unlike
Modal/Drawer, **not** route-based — built on
`CompositedTransformTarget`/`CompositedTransformFollower` + a manual
`OverlayEntry`, so it tracks its target's actual on-screen position
(including through scrolling). Tapping `target` toggles the controller
directly; no separate host widget needed since the popover wraps its
own trigger.

### `PlinthHoverCard`
`target`, `content`, `position`, `width`, `radius`, `closeDelay`
(default 100ms).
Hover-triggered — desktop/web-oriented, effectively inert on touch
devices (see `PlinthPopover` for a tap-triggered equivalent that works
everywhere). Not built by composing `PlinthPopover` — its trigger is
hardcoded to tap, and a hover card additionally needs to stay open
while the pointer travels from `target` onto `content` itself, which
`closeDelay` (a grace-period `Timer`) provides. No controller — hover
state is managed internally via `MouseRegion`.

### `PlinthTooltip`
`message`, `child`, `size`, `radius`, `position`
(`PlinthTooltipPosition`: `top, bottom` — default `top`), `offset`
(default 24), `openDelay` (default 400ms), `color`. A themed wrapper
around Flutter's built-in `Tooltip` — shown on hover (desktop/web) or
long-press (touch).

**`position` is above or below, not left or right**, unlike
`PlinthPopover`/`PlinthMenu`/`PlinthHoverCard`, which take a
`PlinthPopoverPosition` with four values. That is the price of the
wrapper: Flutter's tooltip decides its own horizontal placement and
exposes only a vertical preference. Adding the other two sides would
mean re-deriving hover, long-press, focus and dismissal on Plinth's own
overlay — the work this component exists to avoid — for a case Flutter
largely covers already, since it flips the tooltip to the opposite side
when the preferred one doesn't fit on screen.

`color` fills the tooltip from the palette, for the times it carries a
warning rather than a description; the label then resolves against that
fill via `contrastingOn` rather than the theme's text color. Without it
a tooltip is deliberately *inverted* against the surface it floats over
— dark on a light theme — so it reads as an overlay rather than as more
page.

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
- **`PlinthColorSliderBase`**
  (`plinth_components/src/widgets/color_slider_base.dart`) — the drag,
  tap-to-jump, arrow-key and slider-semantics behaviour behind
  `PlinthHueSlider` and `PlinthAlphaSlider`. Everything Flutter's
  `Slider` would have provided if a gradient track were paintable
  through `SliderTheme`, written once rather than twice.

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

### Inputs

- **`PlinthInput`** — Mantine's unstyled base that its other fields are
  built from. Plinth's fields each own their chrome instead; adopting
  this would be an architectural change, not just a new widget.
- **`PlinthNativeSelect`** — near-duplicate here: `PlinthSelect`
  already wraps Flutter's `DropdownButton`, which is the native
  control.

### Navigation & overlays

- **`PlinthFloatingIndicator`** — the sliding indicator Mantine's tabs
  and segmented controls use. Plinth's equivalents deliberately use a
  static per-item fill instead, so this would be a change of approach
  rather than an addition (see `PlinthTabs`).

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
- **A locale-aware number formatter** — `PlinthNumberFormatter` and
  `PlinthRollingNumber` cover the fixed-format case. Locale awareness
  is `package:intl`'s `NumberFormat`, and pulling `intl` into the
  dependency graph of every app using this library isn't worth a
  thousands separator. Format with it and render the result.

Mantine's separate packages — Dropzone, Spotlight, Dates, Charts,
RichTextEditor, Notifications — are a different scope question, not
simply missing components. Each is a substantial library in its own
right and would belong in its own package here too, rather than in
`plinth_components`.

**Carousel is the exception, and ships here.** Mantine's is separate
because it wraps Embla, a whole third-party engine; Flutter's
`PageView` already does the scrolling and snapping, so
`PlinthCarousel` is a themed arrangement over it rather than a library
in disguise. Autoplay stayed out for the reasons in its entry above.
