# Pre-1.0 audit — Plinth against Mantine

The gap lists in [COMPONENTS.md](COMPONENTS.md) and [SHOWCASE.md](SHOWCASE.md)
answer *"what is missing?"* — and as of 0.18.0 the answer is "nothing
that isn't a deliberate scope call". This document answers the harder
question underneath a 1.0: **of the components that exist, how much of
each one exists?**

A component with the right name and a third of its behaviour is a worse
problem than a missing one, because nothing lists it as a gap.

## Method, and how far to trust it

A script paired every Mantine props table in the reference dump with
the named parameters of the matching Plinth widget, and printed the
difference in both directions. That output is a **lead generator, not
evidence**: it matches on name only, so a rename (`leftSection` →
`leadingIcon`) reads as one prop missing and one extra, and its Dart
parsing is crude enough to have reported `position` missing from
`PlinthPopover`, which has had it all along.

**Every finding below was checked against the source by hand.** Where
this document says something is absent, the grep is in the commit that
added the file.

Out of scope, as before: Mantine's separate packages (charts, dates,
dropzone, spotlight, notifications manager, rich text editor). The
script flags ~50 of those; they are not gaps, they are other libraries.
Carousel *was* on that list until 0.18.0 — see the note in
COMPONENTS.md for why it moved.

## Deliberate divergences — decisions, not gaps

These recur across dozens of components. They are settled; recording
them here so the same question isn't re-litigated per component.

| Mantine | Plinth | Why |
|---|---|---|
| `onChange` | `onChanged` | Flutter convention, and `ValueChanged<T>` is the type it takes |
| `value` + `defaultValue` (controlled *or* uncontrolled) | controlled only | One source of truth. `PlinthTable` and `PlinthAccordion` are the exceptions, where state is purely presentational |
| `disabled` on interactive components | a null callback | Flutter's own idiom: `onPressed: null` *is* disabled |
| `withCloseButton` + `onClose` | `onClose` alone | A close button with nothing to call is a decoration; one flag can't be set wrong |
| `className` / `styles` / `vars` / Styles API | `PlinthTheme` tokens | A theme extension is the Flutter equivalent; per-instance style overrides are the caller's `Container` |
| `*Props` pass-throughs (`inputProps`, `portalProps`, …) | none | These exist because React composes by spreading props onto inner DOM nodes |
| `leftSection` / `rightSection` | `leadingIcon` / `trailing` | See the naming section — the *concept* is kept, the names are not consistent yet |

## Tier 1 — real gaps a 1.0 shouldn't ship with

Ranked by how often an app hits them.

### 1. No loading state anywhere
`PlinthButton` and `PlinthActionIcon` have no `loading`, and no input
has `loading`/`loadingPosition`. A form that submits over a network is
the ordinary case, and right now every app using this library has to
swap the child for a `PlinthLoader` itself and remember to keep the
button's width from jumping. Mantine has it on both buttons and every
input.

**Cost:** small on `PlinthButton` (a spinner in place of the leading
icon, width held), larger to do consistently across the input family.

### 2. `PlinthProgress` and `PlinthRingProgress` take one value, not sections
Mantine's take `sections` — several coloured segments summing to the
whole. The evidence that this matters is in this repo: the **Stat
breakdown** showcase block hand-rolls a segmented bar out of `Row` +
`Expanded` + `ClipRRect`, because the component couldn't express it.
When a demo has to route around a component, that's the component's
bug.

### 3. `PlinthSlider` has no marks
Mantine's `marks` puts labelled ticks under the track;
`restrictToMarks` snaps to them. Ours has `divisions` (the snap) and a
drag label, but no marks. Again the showcase proves it — the **Slider
with marks** block draws its own row of labels under a slider and
aligns them by hand.

### 4. `PlinthTooltip` can't be positioned — **done in 0.19.0, partly**
`PlinthPopover`, `PlinthMenu` and `PlinthHoverCard` all take
`position`. `PlinthTooltip` did not — it was always placed the same
way, with a fixed 400ms delay besides.

It now takes `position`, `offset`, `openDelay` and `color`. **`position`
has two values, not four**: Flutter's tooltip decides its own horizontal
placement and exposes only a vertical preference, so `left`/`right`
would mean re-deriving hover, long-press, focus and dismissal on our own
overlay — the work the component exists to avoid. Flutter already flips
to the opposite side when the preferred one won't fit, which was the
part that actually mattered near a screen edge.

Recorded as a divergence rather than a gap: if a caller genuinely needs
a tooltip beside its target, `PlinthHoverCard` is the four-sided
component and takes arbitrary content.

### 5. Nothing in the select family is clearable
`clearable`/`onClear` appears on Mantine's Select, MultiSelect,
TagsInput, FileInput, ColorInput, Cascader and Autocomplete. Plinth has
it on none of them. "I picked a value and now want none" is a normal
thing to want, and the caller currently has to build the clear affordance
outside the field.

### 6. `radius` and `size` cover only part of the library — **radius done in 0.19.0**
`radius` was accepted by 41 of ~112 components. The theme defines a
radius scale and `defaultRadius`, so the ones that didn't take it
weren't unstyled — they were un-overridable, with no pattern to what
was and wasn't.

Thirteen more now take it: Badge, Chip, ColorSwatch, Indicator,
Pagination, PinInput, Stepper, Switch, Popover, HoverCard, Combobox,
Cascader and Menubar. Twenty-six components round their corners; the
other thirteen are shapes rather than surfaces — a burger's bars, a
loader's dots, a splitter's handle — and adding the prop there would be
answering a question nobody asks. Every default is unchanged, which is
what the tests pin in both directions.

**`size` is still open**, on a smaller scale: `PlinthDivider` (thickness),
`PlinthIndicator`, `PlinthStepper`, and the colour sliders, which spell
it `height`. Left for the naming pass, since two of those are really the
naming question in disguise.

## Tier 2 — worth doing, in rough order

- **Vertical orientation.** Mantine offers it on Tabs, Stepper,
  Progress, Slider, SegmentedControl, ScrollArea, Collapse and Marquee.
  Plinth has it on Divider (`vertical`) and Splitter (`direction`) only.
  A vertical stepper and vertical tabs are the two people actually ask
  for.
- **`PlinthNavLink` has no children.** Mantine's nests, with
  `opened`/`childrenOffset`. The **Navbar with sublevels** block builds
  that by hand out of `PlinthCollapse` and a padded column — a third
  case of the showcase routing around a component.
- **`PlinthTable`**: no `stickyHeader` and no `highlightOnHover`. It
  has `striped`, sorting and filtering; a long table without a sticky
  header is the complaint that follows.
- **Checkbox / Radio / Switch** take `label` but not `description` or
  `error`, which every text input takes. Also missing: `indeterminate`
  on Checkbox (a real tristate need — "some children selected"), and
  `labelPosition`.
- **`PlinthPagination`**: no first/last controls (`withEdges`), no
  `disabled`.
- **`PlinthRating`**: no half-star selection (`fractions`) — it already
  *renders* halves internally — and no `readOnly` distinct from a null
  callback.
- **`PlinthIndicator`**: no `size`, `offset`, `withBorder`, or
  `processing` (the pulsing dot). It also spells disabled as
  `disabled`, which is the wrong side of our own convention.
- **Searchable selects.** Mantine's Select/MultiSelect take
  `searchable` + `nothingFoundMessage`; Plinth splits that into a
  separate `PlinthAutocomplete`. Defensible, but it means a searchable
  *multi* select isn't reachable at all.

## Tier 3 — noted, not urgent

`Avatar.name` (initials derived from a name, colour derived from the
string), `Blockquote.cite`, `Code.block`, `Container.fluid`,
`Marquee.fadeEdges`, `Spoiler` expand control refs, `Tabs.loop`,
`Menu.trigger: hover`, `Group.grow`, `SimpleGrid.minColWidth` (its
container-query mode), `Table.layout`, `Timeline.align`.

## Cross-cutting: three names for one idea — **done in 0.20.0**

Re-deriving this from the source before doing it changed the shape of
the job, which is worth recording: **two of the three rows above were
overstated, and one real case wasn't in the table at all.**

| Idea | What was actually there | What happened |
|---|---|---|
| Disabled | null callback (buttons), `enabled` (15 inputs), `disabled` (3) | `PlinthFieldset` → `enabled`. `PlinthIndicator` → `visible`, because it never disabled anything: it hides the dot, and an indicator isn't a control. `PlinthComboboxOption.disabled` **kept** — an option in a list is `disabled` in Mantine and in Flutter's own `DropdownMenuItem` |
| Leading / trailing | `leadingIcon` on 6, `icon` on ~15, `trailing` on 1 | Only `PlinthNavLink` and `PlinthFileInput` renamed. Most of the `icon` props are on components that *are* an icon, where there is no label to lead — sweeping them would have made the names worse |
| Axis | `vertical` (Divider), `direction: Axis` (Flex, ScrollArea, Splitter) | `PlinthDivider` → `direction: Axis`. One outlier, as billed |
| **Size vs dimension** *(not in the original table)* | `size: PlinthSize` on most components, `size: double` on three | `PlinthRingProgress`, `PlinthSemiCircleProgress`, `PlinthAngleSlider` → `diameter`. One prop name meaning two different types is worse than any of the rows above |

The rules are now in
[COMPONENTS.md § Naming rules](COMPONENTS.md#naming-rules) so the next
component doesn't reopen them. Every rename is a compile error rather
than a silent behaviour change.

## What 1.0 should mean

A proposal, not a decision:

1. ~~**Tier 1 closed.**~~ Done in 0.19.0 — loading states, progress
   sections, slider marks, tooltip position, clearable fields, and
   `radius` coverage. `size` coverage carried into the naming pass.
2. ~~**The naming table applied.**~~ Done in 0.20.0, and it is the last
   breaking change planned before 1.0.
3. **Tier 2 triaged**, not necessarily done: each item either built or
   written down as a deliberate exclusion, the way Carousel's absence
   was recorded (and then reversed once the reasoning was re-read).
4. **Golden coverage past the current 24 images.** Every visual bug
   this project has had was found by looking at rendered output — the
   rolling-number digits, the marquee overflow, the dropped ambient
   font, the one-letter-per-line home page. None were found by a unit
   test.

Beta, by contrast, is where the library is now: the API is stable
enough to build against, and the remaining changes are additive except
for the naming table.
