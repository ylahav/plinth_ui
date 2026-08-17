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

~~**`size` is still open**~~ — **closed in 0.23.0**, and the guess that
"two of those are really the naming question in disguise" was right.
The 0.20.0 rules decided it; this applied them.

| Component | Call |
|---|---|
| `PlinthDivider` | **Built.** `size` is the thickness, a 1–5px ramp with `xs` the existing hairline. Its `height` stays and means the *length* of a vertical rule — a different question, so both props survive rather than one being renamed |
| `PlinthIndicator` | **Built.** `size` steps the dot 8–24px, `md` being the existing 16 |
| `PlinthStepper` | **Built.** `size` scales the marker and its text together |
| The colour sliders | **Declined.** `height` is already correct under the naming rules: a measured dimension takes its own name, and a colour slider's track height is measured. Adding `size: PlinthSize` alongside would give one component two ways to say how tall it is — the exact fault the naming pass fixed when `size` meant both a scale step and a raw number |

Two of the three "built" rows turned out to be bug fixes wearing a
prop's clothes, which is the section below.

## Tier 2 — closed

Each item is **built** or **declined**, with the reason. That is what
triage meant here: the point wasn't to build everything, it's that
nothing is left as an unexplained absence. Carousel is the precedent —
it sat as a written-down exclusion until the reasoning was re-read and
turned out to be wrong, which is only possible if the reasoning was
written down at all.

As of 0.22.0 nothing on this list is still "planned".

| Item | Call | Why |
|---|---|---|
| `description`/`error` on Checkbox, Radio, Switch | **Built** (0.21.0) | Every text input had them from the start; a consent checkbox needs the explaining sentence more than most fields do |
| `indeterminate` on Checkbox | **Built** (0.21.0) | A parent checkbox over a list of children has no other way to say "some" |
| Sticky table header | **Built** (0.22.0) | Real, and the complaint that follows any long table. It did want `PlinthTable` to own a scroll view — see the note below on why it is spelled `maxHeight` |
| `highlightOnHover` on Table | **Built** (0.22.0) | Cheap, and pairs with the above |
| Vertical Tabs and Stepper | **Built** (0.22.0) | The two people actually ask for, both spelled `direction: Axis` per the naming rules. Progress, Slider and SegmentedControl can still wait for someone to ask |
| `PlinthNavLink` children | **Built** (0.22.0) | The showcase built it by hand out of `PlinthCollapse`, which is the same signal that found three Tier 1 items. That block now calls the component |
| `withEdges` on Pagination | **Built** (0.22.0) | First/last controls, as billed. Its `radius` prop turned out to be accepted and ignored, which the same commit fixed |
| `fractions` on Rating | **Built** (0.22.0) | It already rendered halves; only selecting them was missing |
| `processing` on Indicator | **Declined** | A pulsing dot is an animation with no off-switch for reduce-motion unless it takes one, and the same effect is a `PlinthLoader` beside the thing |
| `labelPosition` on the boolean controls | **Declined** | A `Row` with the children swapped is three lines at the call site, and the prop would double the layout branches inside four components |
| Searchable `PlinthSelect` | **Declined** | `PlinthAutocomplete` is the searchable one. A searchable *multi* select is the real gap, and that's a new component rather than a prop |
| Mantine's remaining Input props | **Declined** | `inputContainer`, `inputWrapperOrder`, `*Props` pass-throughs and the rest exist because React composes by spreading props onto inner DOM nodes. A Flutter caller composes with widgets |

### Why the sticky header is spelled `maxHeight`

Mantine's `stickyHeader` is a flag on top of the page's own scrolling.
Flutter has no page scroll to stick to, so the table has to own one,
and a scroll view needs a height. That makes `stickyHeader: true` a
flag that can only throw when the height it needs is missing — the
`withCloseButton` + `onClose` case again, and settled the same way:
**one prop that cannot be set wrong**. `maxHeight` gives the table a
ceiling, and the header stays because there is now something for the
rows to scroll under.

The part that made it cheap rather than structural: every column is an
equal-flex share of the available width, so splitting the header and
the body into two `Table`s doesn't drift — flex widths come from the
space, not from the content.

### Two bugs that a size prop walked into

Adding `size` to `PlinthIndicator` and `PlinthStepper` meant measuring
what they already drew. Neither measured what it claimed.

**The indicator's dot was the size of the thing it marked.** A
`Container` with an `alignment` expands to fill whatever bounded
constraints it is handed, and the corner this sits in — a
`Positioned.fill` inside a `Stack` — hands it the child's full size. So
a 48px icon got a 48px disc over it, not a dot on it. The
`minWidth: 16` was a floor the box sailed past.

Three tests covered this component and all three passed: they asked
whether it rendered, never how big it was. **And `plinth_pill_defaults.png`
had certified the blob for several releases** — the exact lesson
`TESTING.md` already records from `plinth_button_disabled`, hit a
second time. A golden is only as good as someone having looked at it.

**The stepper's markers sat on two different lines.** `Row` centres
each child against the tallest, and a step carrying a `description` is
taller than one without — so a stepper where only some steps have one
drew its circles 8.5px apart, with a connector that could be on the
right line for at most one of them. `size` would have widened the gap
at every step up.

Both are now pinned by assertions on rendered geometry rather than on
widget presence, and both were confirmed by reintroducing the bug and
watching the new test fail.

### The prop that was there and did nothing

`radius` was added to `PlinthPagination` in 0.19.0's coverage pass and
never wired up; the cells hardcoded `4`, which happens to equal the
default theme's `sm`. Nothing looked wrong, and nothing worked.

Worth recording because of *how* it survived: the 0.19.0 radius test
covers Cascader, PinInput, ColorSwatch, Badge, Chip and Switch, but
never Pagination — and a prop with no test is indistinguishable from a
prop with no implementation. It is tested in both directions now.

### The original Tier 2 list, for reference

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
  *Fully resolved:* `disabled` → `visible` in 0.20.0, `processing`
  declined in 0.21.0, `size`/`offset`/`withBorder` built in 0.23.0.
  This bullet is the one place `offset` and `withBorder` were ever
  written down — they never reached the Tier 2 triage table, which is
  how they stayed open through two releases that thought they were
  closing things.
- **Searchable selects.** Mantine's Select/MultiSelect take
  `searchable` + `nothingFoundMessage`; Plinth splits that into a
  separate `PlinthAutocomplete`. Defensible, but it means a searchable
  *multi* select isn't reachable at all.

## Tier 3 — triaged and closed in 0.24.0

Twelve one-line entries, each now built or declined with a reason. The
first thing re-reading them against the source turned up: **one was
already done**, which is the same lesson Carousel taught — a written-down
absence is only useful if it gets re-read.

| Item | Call | Why |
|---|---|---|
| `Blockquote.cite` | **Already shipped** | It has been there all along, spelled `citation`. The list was never checked against the source after it was written |
| `Avatar.name` | **Built** | Initials from the first and last word, and the palette key derived from the name when no `color` is given. The derivation is a sum of code units rather than `hashCode`, because Dart randomises string hashes per isolate — a person would have changed colour between launches |
| `Code.block` | **Built** | `PlinthCode.block`, a named constructor like `PlinthTable.text`. Lines are not wrapped and the block scrolls sideways instead: a wrapped line of code is a line that has been silently rewritten |
| `Container.fluid` | **Built** | Drops the max width, keeps the padding — the full-bleed section a page puts between its constrained ones |
| `Group.grow` | **Built** | Asserts on `wrap: true`, because a `Wrap` lays each run out at its children's widths and has no leftover space to divide |
| `SimpleGrid.minColWidth` | **Built** | The container-query mode, and genuinely a different question from the breakpoint props: those measure the *screen*, this measures the space the grid was handed. A grid in a sidebar gets narrow cells from one and desktop cells from the other |
| `Marquee.fadeEdges` | **Built** | A `dstIn` shader mask rather than a gradient overlay — an overlay would have to know the page colour behind the strip and be wrong on any other |
| `Timeline.align` | **Built** | `PlinthTimelineAlign.start`/`.end` rather than left/right, so an RTL locale isn't the one place this component ignores direction |
| `Spoiler` expand control refs | **Declined** | A React ref for imperative expansion. The Plinth equivalent would be a controller, and this library already decided that case: `PlinthAccordion` "manages its own open/closed state internally — there's no external controller, since expanded state is presentation-local". Spoiler is the same shape |
| `Tabs.loop` | **Declined in 0.24.0, built in 0.25.0** | `loop` governs whether arrow-key navigation wraps around, and there was no arrow-key navigation to wrap. Shipping it alone would have been a prop that did nothing. The navigation landed in 0.25.0 and `loop` came with it, on `PlinthTabs` and `PlinthSegmentedControl` both. See below |
| `Menu.trigger: hover` | **Declined** | `PlinthHoverCard` is the hover-triggered floating panel, the same split this library already made for `PlinthTooltip`. A hover-only menu is also unreachable on touch |
| `Table.layout` | **Declined** | `layout: auto` means intrinsic column widths, and 0.22.0's sticky header works *because* every column is an equal-flex share — that is what lets the header and body be two tables that cannot drift. `auto` would break it silently whenever `maxHeight` was set. Per-column widths are the honest version of this request, if anyone asks |

### The gap `Tabs.loop` was standing in front of — **built in 0.25.0**

**A correction first, because 0.24.0 shipped this section overstating
the problem.** It said a tab strip that only answers taps "locks out
anyone not using a pointer". That was wrong, and checking rather than
reasoning is what caught it: Material's `InkWell` supplies focus and
Enter-activation on its own, so every one of these components has been
keyboard-*reachable* all along. A probe against the untouched
`PlinthStepper` confirmed it — `Tab` focuses a step, `Enter` fires its
callback, with no code of ours involved.

The real gap was narrower and still worth closing: **the strip did not
follow the tablist pattern.** Every tab was its own stop in the tab
order, so a twelve-tab settings page cost twelve presses to walk past,
and there were no arrow keys, no `Home`/`End`, and nothing announcing
which tab was selected.

`PlinthTabs` and `PlinthSegmentedControl` now use roving focus — one
stop for the strip, arrows along its own axis, `Home`/`End`, `loop` to
decide whether the ends wrap, and direction-aware arrows so RTL reads
correctly. Selection follows the arrow (automatic activation), which is
the right half of the ARIA pattern for panels as cheap as
[PlinthTabView]'s.

**`PlinthStepper` is deliberately left alone.** Its steps are
independent buttons rather than a single-selection group — `onStepTapped`
is a notification, not a selection, and `currentStep` stays the
caller's. A set of independent buttons each being its own tab stop is
correct, not a bug.

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
   `radius` coverage. `size` coverage was carried forward and finally
   closed in 0.23.0, which is the last of Tier 1 to land.
2. ~~**The naming table applied.**~~ Done in 0.20.0, and it is the last
   breaking change planned before 1.0.
3. ~~**Tier 2 triaged**, not necessarily done.~~ Triaged in 0.21.0 and
   closed in 0.22.0: every item is built or written down as a
   deliberate exclusion, the way Carousel's absence was recorded (and
   then reversed once the reasoning was re-read). Tier 3 is what is
   left, and it is a list of small additions rather than gaps.
4. ~~**Golden coverage past the current 24 images.**~~ Widened to 31,
   and more usefully re-aimed: three of the six files now cover a
   *kind* of failure rather than a component — computed layout, states
   paired with the state they must not resemble, and the dark theme
   across several components at once. Every visual bug this project has
   had was found by looking at rendered output — the rolling-number
   digits, the marquee overflow, the dropped ambient font, the
   one-letter-per-line home page, the disabled button that looked
   enabled. None were found by a unit test.

   ~~Still worth doing: the overlay components (menu, popover, drawer,
   modal), which no image covers because each needs an interaction
   pumped first.~~ **Done** — eight images in
   `plinth_overlay_golden_test.dart`, 42 across eight files.

   The interaction turned out to be the smaller half of the problem: a
   controller opened and a `pumpAndSettle` is one line. The real
   obstacle was that `goldenWrap` puts its boundary *inside* the
   scaffold, and every one of these renders into the app's `Overlay` or
   a dialog route — above it. Shooting that boundary photographs the
   trigger and an empty page. `overlayGoldenWrap` puts the boundary
   outside the app instead, which makes the image the whole surface
   rather than a crop, and therefore also makes the page something the
   helper has to paint.

**With that, every item on this list is closed** — and Tier 3 followed
in 0.24.0, so all three tiers are now triaged. What remains before 1.0
is not a gap list:

1. ~~**Keyboard navigation on `PlinthTabs`**~~ — done in 0.25.0, on
   `PlinthSegmentedControl` too. `PlinthStepper` was assessed and left
   alone with a reason. See the correction below: 0.24.0 described this
   gap as worse than it was.
2. ~~**A decision** about whether the two leaf packages move onto a
   matching version line.~~ **Decided: lockstep.** All three packages
   go to 1.0.0 together and move together after that; the reasoning
   and the ordered release sequence are in
   [PUBLISHING.md](PUBLISHING.md#decided-lockstep-from-10-onward).

**This list is now empty.** Everything this audit set out to find has
been found, and everything it found has been built or written down as a
deliberate exclusion. What remains before 1.0 is the release itself.

Beta, by contrast, is where the library is now: the API is stable
enough to build against, and the remaining changes are additive except
for the naming table.

### What the overlay images are actually for

A popover is placed by `CompositedTransformFollower` against a
`LayerLink` — arithmetic on two anchors and an offset. A behaviour test
can only ask whether the content is in the tree, and `find.text('Edit')`
passes just as happily when the panel is behind its own trigger, off
the side of the screen, or on the wrong edge entirely. Three of this
library's bugs were exactly that shape (the rolling number's wheels,
the vertical stepper's connectors, the indicator dot at its child's
full size), and none was caught by a unit test.

Two things the images turned up immediately, neither a bug:

- **`PlinthPopover` did not flip near an edge** — fixed in 0.24.0. Its
  anchors were fixed, so a `bottom` popover on a target near the bottom
  of the screen rendered off it, and every assertion about it still
  passed. `PlinthTooltip` had flipped all along because Flutter's own
  tooltip does, which is the Tier 1 tooltip note read from the other
  side: the same behaviour was recorded as handled in one component
  while missing in its sibling. The image is what put the two side by
  side.
- **The hard black band on the drawer's edge is `debugDisableShadows`**,
  which `flutter_test` sets, painting an elevation as a solid rectangle
  rather than a blurred one. Confirmed by rendering with shadows on.
  Left at the default, so these images pin the shadow's extent and not
  its softness.
