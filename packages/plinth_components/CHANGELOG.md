# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

The three Plinth packages move in lockstep from `1.0.0` onward — see
[PUBLISHING.md](../../docs/PUBLISHING.md#decided-lockstep-from-10-onward).
A release where this package itself did not change says so rather than
inventing one. Before `1.0.0`, minor bumps could carry breaking
changes; from `1.0.0` they cannot.

## Unreleased

### Added

- **`PlinthTapTarget`, and controls honour `PlinthDensity`.** (A1c)

  `PlinthButton`, `PlinthActionIcon`, `PlinthCloseButton` and
  `PlinthChip` now grow their hit area to the theme's density floor.
  **The painted control does not grow** — the extra room is transparent
  padding, the way Flutter's own `MaterialTapTargetSize` works, so a
  button at `touch` is a 39px button in a 48px target rather than a 48px
  slab.

  Exported, because an app building its own control needs the same
  floor and cannot reach it from outside.

  Nothing changes at the default `standard` density, which a test pins
  per control.

- **`PlinthFocusTrap`, and keyboard focus no longer escapes a popover.**
  (B1)

  ```dart
  PlinthFocusTrap(onEscape: controller.close, child: myPanel)
  ```

  A route gets a `FocusScope` from Flutter for free, so `PlinthModal`
  and `PlinthDrawer` already contained Tab. An `OverlayEntry` does not —
  it sits in the same route and the same focus scope as the page behind
  it. Measured before the fix: **Popover, Menu and Combobox all leaked
  on the first Tab**, putting focus on content the user cannot see.

  Applied to `PlinthPopover`, which covers `PlinthMenu`,
  `PlinthHoverCard`, `PlinthColorInput` and `PlinthTreeSelect`.
  Focus moves into the panel on open, **returns to the trigger on
  close** — the half a trap is usually missing — and Escape dismisses.

  Exported, because an app building its own `OverlayEntry` panel has
  exactly the same problem.

  **Not applied to `PlinthDialog` or `PlinthPortal`**, deliberately: a
  Plinth dialog is non-blocking by design, and Portal is a raw primitive
  with no trigger to hand focus back to. **Not applied to the dropdown
  family** either — focus belongs in the text field while the list is
  open, and trapping them would make them worse.

### Changed

- **Every form field now exposes its label to assistive technology.**

  Nine widgets rendered their label as a *sibling* of the field, which
  shows it to sighted users and to nobody else: `PlinthTextInput`,
  `PlinthTextarea`, `PlinthNumberInput`, `PlinthPasswordInput`,
  `PlinthTagsInput`, `PlinthAutocomplete`, `PlinthSelect`,
  `PlinthMultiSelect`. A screen reader reached each one as an unnamed
  field.

  `PlinthTreeSelect` already did this correctly and is the shape the
  rest now follow — the label on the control, alongside its value, so a
  select announces both.

  Found by probing rather than reported: `PlinthAutocomplete` turned up
  unlabelled *despite* being given a `label`, and a grep for the same
  pattern found eight more with no `Semantics` in the file at all.
  Pinned per widget, so a new field cannot quietly join them.

- **`PlinthPagination` no longer clips its page numbers at large text
  scales.** (A1c)

  Its cells were a fixed `dimension`. At `textScaler` 2.0 a *single*
  digit already measured **28x32 inside a 32x32 cell** — flush to the
  edge, with a two-digit page or any larger scale clipping outright.
  The size is now a **minimum**: the cell grows to its content, and is
  unchanged at ordinary scales where the digit has room to spare.

  Most of the library never had this problem. Control heights come from
  padding rather than being fixed, so they already scaled — Button
  39→62, Checkbox 32→54, Chip 36→56 between 1.0 and 2.0. Pagination was
  the exception, which is why the fix is one widget rather than a
  library-wide sweep.

- **Interactive controls now carry a name and a role.** (B0a, B0b)

  Found by running the accessibility probes rather than by anyone
  reporting it — see
  [POST_1_0_ROADMAP § What B0 found](../../docs/POST_1_0_ROADMAP.md#what-b0-found).

  - **`PlinthRating` was the worst in the library**: five tappable
    stars, none labelled, none with a role. Each region now announces
    the value it sets — "3 of 5" — and marks itself selected when it is
    the current one.
  - **`PlinthPinInput`** — four identical unlabelled fields, now "Digit
    1 of 4" and so on.
  - **`PlinthAutocomplete`** — unlabelled *despite* being given a
    `label`, because the label was rendered as a sibling of the field
    and reached sighted users only. It is now on the field.
  - **`PlinthAccordion`, `PlinthBreadcrumbs`, `PlinthStepper`** — were
    labelled but roleless, so they announced as text rather than as
    controls. Accordion also reports expanded/collapsed.
  - **`PlinthAnchor`** now reports as a link.

- **`PlinthActionIcon` gains `semanticLabel`.** It had no such parameter
  at all, so an icon-only button was announced as an unnamed button.
  There is no default to infer from an `Icon`, so it stays the caller's
  responsibility — Flutter's `labeledTapTargetGuideline` fails the
  widget without it.

- **`PlinthAnchor` was short on two counts, each by a margin only
  measurement finds.**

  It painted `shaded(colorKey, 6)` — a raw shade for a *foreground* —
  putting the default blue at **3.56:1** on white, under the body floor.
  That is the same mistake as PR-17's alert icons and PR-19's
  `PlinthText`: the **third** component found with it. It now resolves
  through `readableOn`.

  Its tap target was **23px**, one pixel under WCAG 2.2 SC 2.5.8's
  24x24. Now 24, centred on the text so nothing around it shifts.

- **Text now resolves its contrast against the background it actually
  sits on.** (PR-19)

  `PlinthText` takes an `on:` parameter naming that background, and
  defaults to the surface — so nothing changes for text on a page.

  Two components were resolving against the surface while rendering on
  a tint, which is the silent kind of miss: `readableOn` was called, a
  floor was cleared, and the floor was measured against a background the
  text never touched.

  - **`PlinthAlert` titles** — 3 of 13 ramps under the floor in light,
    1 in dark, at 4.35–4.48. Marginal, which is why nobody noticed.
  - **`PlinthHighlight`** — **9 of 13 in light and 13 of 13 in dark.**
    Its matched runs get a mark colour and the rest stay on the surface
    under one style, so the run the widget exists for was the one that
    failed. Matched runs now carry their own foreground.

  **`PlinthHighlight`'s mark also changed**, from `shaded(color, 2)` to
  `wash(color, alpha: 0.30)`. Shade 2 mirrors to shade 7 in a dark
  theme, giving a saturated block instead of a highlight — the same
  trap `wash` was added for in `1.0.0-beta.2` — and no text colour could
  clear it. The alpha was chosen to sit closest to the old light-mode
  mark (mean ΔE 3.3), so light barely moves and dark is fixed.

- **Every internal use of the `red`, `gray` and `green` ramps now goes
  through `PlinthRole`.** (PR-09)

  53 call sites: error borders and messages, muted descriptions and
  separators, the copy button's success flash. **Nothing renders
  differently** — `kDefaultRoleRamps` maps the three roles to exactly
  the ramps that were hardcoded, and no golden moved.

  What changes is that an app can now take the `red` key for its own
  meaning without restyling every form field in the library, by pointing
  `PlinthRole.error` somewhere else.

- **Banner icons now meet WCAG 1.4.11, and headings pick their contrast
  floor by measurement.** (PR-17)

  `PlinthAlert` and `PlinthNotification` painted their icon at a raw
  `shaded(color, 6)`. Against the alert's own tinted background **7 of
  13 ramps failed the 3:1 an icon needs** — yellow at **1.74:1**, lime
  1.91, green 2.19. Both now resolve through `readableOn` at
  `PlinthContrast.nonText` against what is actually behind them, so
  those icons get darker in the light theme.

  `PlinthTitle` orders 1–3 (34/26/22px at w700) clear WCAG's large-text
  threshold and now take the looser 3:1 floor, keeping them nearer the
  brand colour. Orders 4–6 (18/16/14px at w600) do not clear it and are
  unchanged.

  **Alert and notification titles are unchanged**, and that is the
  finding rather than an omission: at 16px w700 they are 2.67px short of
  the 18.67px a bold face needs, so the body floor is correct for them
  and the muted colours they took on in `1.0.0-beta.2` were right.

  Icons outside the banners — `PlinthActionIcon`, `PlinthThemeIcon`,
  `PlinthCloseButton` — already resolved at 4.5:1 and were left there.
  Loosening them would trade contrast for brand fidelity with no
  accessibility gain.

### Added

- **`PlinthLtr`** — pins a subtree to left-to-right inside an RTL page.
  (PR-13)

  ```dart
  PlinthLtr(child: CustomPaint(painter: BarsPainter(months)))
  ```

  Charts, time axes and currency figures have no direction of their own
  and must not flip with the page. Every bidirectional app writes
  `Directionality(textDirection: TextDirection.ltr, …)` by hand; this is
  that line with a name, so the next reader can tell the direction was
  pinned on purpose.

  **This was the only concrete RTL gap the validation found**, and worth
  stating plainly because the prediction was the opposite: Plinth was
  expected to break in Hebrew and did not. 12 of 12 page × language
  combinations rendered clean, and a setup wizard walked end to end at
  `textScaler` 2.0 in both directions. Reach for this narrowly — it is
  not a fix for RTL problems.


- **`PlinthNotification.showOn(messenger, …)`** — show a notification
  against a `ScaffoldMessengerState` you already hold, rather than a
  live `BuildContext`. (PR-12)

  Flutter's idiom for feedback after an `await` is to capture the
  messenger *before* it, so nothing needs a context once the work
  finishes:

  ```dart
  final messenger = ScaffoldMessenger.of(context);
  await store.applyImport(file);
  PlinthNotification.showOn(messenger, child: const Text('Imported'));
  ```

  `show(context, …)` could not express that, and one real app had to
  delete **13** such captures and replace them with
  `if (!context.mounted) return;`. That is a behaviour change rather
  than a rewrite: the captured messenger still delivers when the widget
  has gone away, and the guard silently drops the message. For "import
  finished" the guard is often the wrong answer — and either way it
  should be the app's choice, not a consequence of the signature.

  `show` now delegates to `showOn`, so the messenger-taking form is the
  primitive and the context-taking one is a lookup in front of it.
  Nothing changes for existing `show` callers.

## 1.0.0-beta.2

**No API changes. Every component looks different.**

`plinth_core`'s ramp generator now anchors a seed colour at shade 6, so
the 13 built-in ramps finally return the Mantine values they are seeded
with — see that package's changelog for the measurements. Nothing here
changed to cause it, and nothing here needs changing to consume it, but
the rendered output moves: **32 of the 43 golden images were
rebaselined.**

### Changed

- **Filled buttons in blue and red now carry a dark label, not a white
  one.** `contrastingOn` picks whichever foreground contrasts better,
  and on the corrected fills the light one stops winning: white on
  `blue.6` falls from 4.15:1 to 3.56:1 while the dark foreground reaches
  4.84:1. New for blue and red only — green, yellow and teal already had
  dark labels, violet keeps white. **`blue` is the default
  `primaryColor`, so this changes the default button.**

  Deliberate, and the reason is uncomfortable enough to state plainly:
  white on Mantine's real `blue.6` fails AA for body text, so Mantine's
  own filled buttons do not clear it either. The distorted palette had
  been hiding that. Override `onFilled` / `onFilledInverse` to get the
  old pairing back.

- **Alert and notification titles drift toward muted on the
  low-luminance ramps** — a yellow alert title now lands on dark
  olive-brown. `readableOn` is holding them to the 4.5:1 body floor.
  Whether a title is body text or a heading is filed as `PR-17` and not
  yet decided; if it becomes `large` (3.0), these move back toward
  brand.

- `PlinthVariant.light` is unaffected. The four components that pin it
  to `PlinthContrast.large` still render exactly as they did.

## 1.0.0-beta.1

The first release with all three Plinth packages on one version line,
and the rehearsal for 1.0.0.

**No component changes.** Everything here is release plumbing.

The `1.0.0-beta` line is the rehearsal for that promise, not the
promise itself: the API is what 1.0.0 intends to ship, and the beta
exists so the three-package release sequence gets run once while a
mistake is still cheap. `flutter pub add` still resolves the last
stable release unless a prerelease is asked for.

### Changed

- **`plinth_core` and `plinth_hooks` constraints are now `^1.0.0-beta.1`.**
  Below 1.0.0 a caret pins the *minor* — `^0.2.0` means `<0.3.0` — so
  lockstep on the 0.x line would have forced all three to be
  republished for every components-only change. Above it, `^1.0.0`
  means `<2.0.0` and the leaf packages can sit still while this one
  moves. That is the concrete reason the version line starts at 1.0
  rather than at 0.26.

## 0.25.0

Keyboard navigation for the two single-selection strips, which is the
last item on the [pre-1.0 audit](../../docs/PRE_1_0_AUDIT.md)'s
remaining list that is code rather than a decision. Additive; no
migration.

### Correction to 0.24.0

0.24.0's notes said `PlinthTabs` "has no keyboard handling at all" and
the audit called a tap-only strip something that "locks out anyone not
using a pointer". **Both overstated the problem**, and checking rather
than reasoning is what caught it: Material's `InkWell` supplies focus
and Enter-activation on its own, so these components have been
keyboard-*reachable* all along. A probe against the untouched
`PlinthStepper` confirmed it — `Tab` focuses a step and `Enter` fires
its callback with no code of ours involved.

The real gap was narrower and still worth closing: the strips didn't
follow the tablist pattern. Every tab was its own stop in the tab
order, so a twelve-tab settings page cost twelve presses to walk past,
and there were no arrow keys, no `Home`/`End`, and nothing announcing
which tab was selected.

### Added

- **Roving focus and arrow-key navigation on `PlinthTabs` and
  `PlinthSegmentedControl`.** The strip is one stop in the tab order
  rather than one per item. Inside it, the arrows along the strip's own
  axis move between items, `Home` and `End` reach the ends, and the new
  **`loop`** (default `true`) decides whether the ends wrap.

  The arrows are direction-aware, so in an RTL locale the left arrow
  still moves the way the strip reads. A vertical `PlinthTabs` responds
  only to up/down, leaving left/right to whatever else is on the page.

  Moving selects, rather than only moving a focus ring — the
  automatic-activation half of the ARIA pattern, which is right for
  panels as cheap as `PlinthTabView`'s.

- **Selection is now announced.** Each tab reports its selected state;
  each segment additionally reports being in a mutually exclusive
  group, which is what ARIA calls a radio group.

- **`loop` on both**, closing the Tier 3 item that 0.24.0 declined
  because it governed navigation that did not yet exist.

### Not changed, deliberately

**`PlinthStepper`** was assessed and left alone. Its steps are
independent buttons rather than a single-selection group —
`onStepTapped` is a notification and `currentStep` stays the caller's —
so each step being its own tab stop is correct rather than a bug.

## 0.24.0

Closes the [pre-1.0 audit](../../docs/PRE_1_0_AUDIT.md)'s Tier 3, and
with it the last of the three tiers. All additive; no migration.

### Fixed

- **`PlinthPopover` now flips away from a screen edge.** Its anchors
  were fixed, so a `bottom` popover on a target near the bottom of the
  viewport rendered off it — and every assertion about it still passed,
  because a behaviour test can only ask whether the panel is in the
  tree. `PlinthTooltip` had flipped all along, because Flutter's own
  tooltip does; the two are consistent now.

  `position` is therefore a preference rather than an instruction. Only
  the requested axis flips — `bottom` becomes `top`, never `left` — and
  if neither side fits, the requested one wins.

  It costs one frame: the panel's height isn't knowable until it has
  been laid out, and which side fits depends on that height, so the
  first frame after opening lays it out invisibly to measure and the
  second shows it in the resolved place. The alternative is placing it
  visibly and then moving it, which is the jump this avoids.

### Added

- **`PlinthAvatar.name`** — initials from the first and last word, so
  "Ada Lovelace" reads AL and "Prince" reads P. Explicit `initials`
  still win.

  With no `color` either, the palette key is derived from the name, so
  a list of people comes out varied without anyone assigning colours.
  The derivation is a sum of code units rather than `hashCode`: Dart
  randomises string hashes per isolate, so a hash would have changed
  someone's colour between launches of the same app.

- **`PlinthCode.block`** — the multi-line form, full width with roomier
  padding. Lines are deliberately not wrapped, since a wrapped line of
  code is a line that has been silently rewritten; a block scrolls
  sideways instead, the way every code viewer does.

- **`PlinthContainer.fluid`** — drops the max width, keeps the padding,
  for the full-bleed sections a page puts between its constrained ones.

- **`PlinthGroup.grow`** — divides the leftover width equally between
  the children. Asserts on `wrap: true`, because a `Wrap` lays each run
  out at the widths its children ask for and has no leftover space to
  divide.

- **`PlinthSimpleGrid.minColWidth`** — fits as many columns as will
  hold a cell that wide. A different question from the breakpoint
  props, not a shorthand: those measure the screen, this measures the
  space the grid was handed, so a grid in a sidebar gets narrow cells
  from one and desktop cells from the other. Gaps are counted.

- **`PlinthMarquee.fadeEdges`** — fades the strip out at both ends
  rather than cutting it off. Off by default because it costs a
  `saveLayer`. Masks with `dstIn` rather than painting a gradient
  overlay, which would have to know the page colour behind the strip.

- **`PlinthTimeline.align`** — `PlinthTimelineAlign.start`/`.end` picks
  which side the rail of dots runs down. Directional rather than
  left/right, so an RTL locale isn't the one place this component
  ignores direction.

### Declined

Recorded in the audit with reasons: `Spoiler` expand refs (this library
already decided that expanded state is presentation-local, for
`PlinthAccordion`), `Menu.trigger: hover` (`PlinthHoverCard` is the
hover-triggered panel, and a hover-only menu is unreachable on touch),
and `Table.layout` (`auto` means intrinsic column widths, and 0.22.0's
sticky header works *because* every column is an equal-flex share).

`Blockquote.cite` turned out to be **already shipped**, spelled
`citation` — the list had never been re-read against the source.

### Known gap, newly named

`Tabs.loop` was declined because it governs arrow-key navigation that
**does not exist**: `PlinthTabs` has no keyboard handling at all.
Shipping `loop` would have added a prop that does nothing to an absence
nobody had noticed. Keyboard navigation for the tab strip is now
recorded in the audit as the one real accessibility hole it has found,
deliberately not filed as a Tier 3 item because it is larger than all
twelve of them together.

## 0.23.0

Closes the last open item in the [pre-1.0 audit](../../docs/PRE_1_0_AUDIT.md)'s
Tier 1 — `size` coverage, deferred since 0.19.0 — and the three
`PlinthIndicator` props that were written down in the audit's reference
list but never reached its triage table.

Measuring what these components already drew turned up two bugs, both
of which changed pixels. **If you have golden images covering
`PlinthIndicator` or a horizontal `PlinthStepper`, they need
regenerating.**

### Fixed

- **`PlinthIndicator`'s dot was the size of the thing it marked.** A
  `Container` with an `alignment` expands to fill whatever bounded
  constraints it is given, and the corner this sits in — a
  `Positioned.fill` inside a `Stack` — hands it the child's full size.
  A 48px icon got a 48px disc over it rather than a dot on it; the
  `minWidth: 16` was a floor the box sailed straight past. The label is
  now centred with `textAlign`, which centres text without resizing the
  box around it.

  Three tests covered the component and all three passed — they asked
  whether it rendered, never how big it was — and the committed
  `plinth_pill_defaults.png` golden had been certifying the blob for
  several releases.

- **`PlinthStepper` drew its markers on two different lines** when only
  some steps carried a `description`. `Row` centres each child against
  the tallest, and a step with a description is taller than one
  without, so the circles sat 8.5px apart. Steps are aligned to the top
  now, and the connector is positioned from the circle's own radius
  rather than a fixed bottom margin that only suited one size.

### Added

- **`size` on `PlinthDivider`**, stepping the rule's thickness on a
  1–5px ramp. `xs` is the hairline it drew before, so nothing moves
  unless asked. The space a rule occupies always equals the line it
  draws, so a thicker rule never adds padding it doesn't paint.

  Its `height` stays, and means the *length* of a vertical rule — a
  different question from thickness, which is why both props exist
  rather than one replacing the other.

- **`size` on `PlinthIndicator`**, stepping the dot 8–24px with `md`
  the existing 16. A `label` still widens the badge past that to fit
  its text.

- **`offset` on `PlinthIndicator`**, pulling the dot in from its corner
  toward the child's centre, in logical pixels. The default placement
  straddles the corner of the child's *bounding box*, which is right
  for a square icon and wrong for a round avatar — a circle's edge is
  well inside its box's corner. Measured rather than a scale step,
  because what it clears is a radius rather than a size.

- **`withBorder` on `PlinthIndicator`**, ringing the dot in the surface
  colour so it stays legible on a photo. The surface rather than a
  palette colour, so it reads as a gap rather than an outline.

- **`size` on `PlinthStepper`**, scaling the marker and the text with
  it — disc, number or tick, label and description all move together,
  so a larger stepper isn't a big circle over small type.

### Declined

- **`size` on the colour sliders.** They spell it `height`, which the
  0.20.0 naming rules already make correct: a measured dimension takes
  its own name, and a track's height is measured. Adding
  `size: PlinthSize` alongside would give one component two ways to say
  how tall it is — the exact fault the naming pass fixed.

## 0.22.0

Closes the [pre-1.0 audit](../../docs/PRE_1_0_AUDIT.md)'s Tier 2. Every
item on that list is now built or declined with a reason — nothing is
left as "planned". All additive; no migration.

### Added

- **`maxHeight` on `PlinthTable`**, which is the sticky header. Mantine
  spells it `stickyHeader`, a flag on top of the page's own scrolling;
  Flutter has no page scroll to stick to, so the table has to own one
  and a scroll view needs a height. A separate `stickyHeader: true`
  could then only throw when the height it needs is missing, which is a
  prop that can be set wrong — so it is one prop that can't be.

  The header and the body become two `Table`s, which works only because
  every column is an equal-flex share of the available width: the
  column edges come from the space, not from the content, so the two
  can't drift. Below `maxHeight` the table is its natural height, so a
  short table doesn't grow to fill it.

- **`highlightOnHover` on `PlinthTable`.** The hover region sits on the
  cells rather than the row, because a `TableRow` is configuration
  rather than a widget and there is nothing spanning a row to wrap.
  Entering any cell claims the row and only leaving the whole table
  gives it up, so the few pixels a short cell doesn't cover in a tall
  row don't make the highlight flicker.

- **`direction` on `PlinthTabs` and `PlinthStepper`**, typed `Axis` per
  the [naming rules](../../docs/COMPONENTS.md#naming-rules). Vertical
  tabs move the divider and the active indicator to the trailing edge;
  a vertical stepper puts each label beside its circle rather than
  under it, which is what gives a step description a line's width to
  sit on.

- **`children` on `PlinthNavLink`**, with `opened`, `onOpenedChanged`
  and `childrenOffset`. `onTap` stays separate and a parent with both
  calls both — that's what lets a parent which is only a grouping
  heading stay unreachable as a route. The chevron is supplied unless
  `trailing` fills the slot.

  The showcase's **Navbar with sublevels** block built this by hand out
  of `PlinthCollapse` and a padded column; it now calls the component,
  which is the point of having noticed.

- **`withEdges` on `PlinthPagination`** — first/last controls outside
  the previous/next pair, for the jump the ellipsis hides once the
  range collapses. Every icon-only control also gained a semantic
  label, which none of them had.

- **`fractions` on `PlinthRating`**, for selecting the half-stars it
  has always been able to *render*. It splits each star into that many
  hit regions. Empty, half and full keep Material's drawn glyphs — a
  designed half-star beats a clipped one — and anything between them is
  a clipped fill.

### Fixed

- **`PlinthPagination.radius` did nothing.** Added in 0.19.0's coverage
  pass and never wired up: the cells hardcoded `4`, which happens to
  equal the default theme's `sm`, so nothing looked wrong and nothing
  worked. It now resolves through the theme like every other `radius`,
  which also means a theme with a different `defaultRadius` reaches the
  pager for the first time.

### Changed

- **`PlinthPagination.onChanged` is nullable.** Passing null disables
  every control, which is how this library spells disabled everywhere
  else. Existing calls compile unchanged.

## 0.21.1

### Fixed

- **Two `assert(sections.length > 0, …)` calls became
  `assert(sections.isNotEmpty, …)`**, in `PlinthProgress.sections` and
  `PlinthRingProgress.sections`. Behaviour is identical; pub.dev
  deducted 10 points from 0.21.0 for them, taking the score to 150/160.

  The real fix is the second half: this package had no
  `analysis_options.yaml` at all, so `melos run analyze` ran the SDK
  defaults while pana analyses every published package against
  `package:lints/core.yaml`. CI reported clean on code the score
  docked. It now includes core lints, so the next one fails locally
  instead of a release later.

## 0.21.0

Start of the [pre-1.0 audit](../../docs/PRE_1_0_AUDIT.md)'s Tier 2,
which is now triaged: every remaining item in that list is either built
or declined with a reason, so nothing is left as an unexplained
absence.

### Added

- **`description` and `error` on `PlinthCheckbox`, `PlinthRadio` and
  `PlinthSwitch`.** Every text input has had both from the start; the
  boolean controls took a bare `label`. A consent checkbox needs the
  explaining sentence more than most fields do, and an error under the
  one control a form rejected is the whole point of field-level errors.

- **`indeterminate` on `PlinthCheckbox`**, for the "some of the
  children are selected" state a parent checkbox has no other way to
  say.

  It draws filled with a dash rather than empty — an empty box would
  claim "none of them", which is the one thing this state exists to
  deny — and reports `CheckedState.mixed` to assistive technology,
  which has its own word for it. What a *tap* reports still comes from
  `value`, so the caller decides what resolving the mixed state means
  for their tree.

## 0.20.0

The naming pass from the [pre-1.0 audit](../../docs/PRE_1_0_AUDIT.md).
**Breaking**, deliberately and all at once: these are the changes a 1.0
closes the door on, and spreading them over several releases would mean
several migrations instead of one.

The rules they follow are now written down in
[COMPONENTS.md § Naming rules](../../docs/COMPONENTS.md#naming-rules),
so the next component doesn't reopen them.

### Changed — migration

| Before | After | Why |
|---|---|---|
| `PlinthDivider(vertical: true)` | `PlinthDivider(direction: Axis.vertical)` | `PlinthFlex`, `PlinthScrollArea` and `PlinthSplitter` already took `direction: Axis`; the divider was the outlier |
| `PlinthFieldset(disabled: true)` | `PlinthFieldset(enabled: false)` | `enabled` is what fifteen inputs already spell it |
| `PlinthIndicator(disabled: true)` | `PlinthIndicator(visible: false)` | It never disabled anything — it hides the dot. An indicator isn't a control |
| `PlinthRingProgress(size: 80)` | `PlinthRingProgress(diameter: 80)` | `size` means a step on the `PlinthSize` scale everywhere else |
| `PlinthSemiCircleProgress(size: 160)` | `PlinthSemiCircleProgress(diameter: 160)` | as above |
| `PlinthAngleSlider(size: 60)` | `PlinthAngleSlider(diameter: 60)` | as above |
| `PlinthNavLink(icon: …)` | `PlinthNavLink(leadingIcon: …)` | it has a `trailing` too, so its icon is leading something |
| `PlinthFileInput(icon: …)` | `PlinthFileInput(leadingIcon: …)` | as above |

Every rename is a compile error rather than a silent behaviour change,
so an upgrade either builds or tells you exactly where to look. Nothing
else about these components moved.

**Two things deliberately did not change.** `PlinthComboboxOption.disabled`
stays: an option in a list is `disabled` in both Mantine and Flutter's
own `DropdownMenuItem`. And `icon` stays on the components that *are* an
icon — `PlinthActionIcon`, `PlinthThemeIcon`, `PlinthAlert`,
`PlinthTimelineItem` — where there is no label for it to lead. The audit
had proposed sweeping both; looking at the call sites said otherwise.

## 0.19.0

First batch of the [pre-1.0 audit](../../docs/PRE_1_0_AUDIT.md), which
compared each component against Mantine's own props rather than asking
which components were missing.

### Added

- **`loading` on `PlinthButton` and `PlinthActionIcon`.** A spinner in
  place of the leading icon (or of the icon itself), and taps ignored
  while it is set, so a slow request can't be submitted twice.

  It keeps the button's own colors rather than the disabled ones: busy
  is not unavailable, and greying the button out would suggest the
  press never landed. The spinner is sized to the label's font size, so
  a button doesn't change height when it starts loading.

- **`PlinthLoader` takes `colorValue` and `dimension`** — exact
  overrides for `color` and `size`. Both exist because a spinner inside
  a filled button needs the foreground `contrastingOn` resolved for
  that fill, which the palette can't name, at the label's line height,
  which isn't a step on the size scale.

- **`PlinthProgress.sections` and `PlinthRingProgress.sections`**, with
  a shared `PlinthProgressSection` (`value`, `color`, `label`). A
  part-to-whole bar or donut, matching Mantine's `Progress.Section`.

  Section values are fractions of the whole, not of each other: 0.5,
  0.3 and 0.1 leave a tenth of the track empty, which is how this kind
  of bar says "and this much is neither". Widths come from the
  available width rather than `Expanded` flexes, which would normalise
  the parts and quietly lose that remainder. Values summing above 1
  assert instead — scaling raw counts is the caller's job.

  Labelled sections are joined into one semantics label, since a bar
  with no text in it reads as nothing at all.

  Found by the audit noticing that the **Stat breakdown** showcase
  block hand-rolled this out of `Row` + `Expanded` + `ClipRRect`. That
  block now uses the component, which is the whole point.

- **`marks` on `PlinthSlider` and `PlinthRangeSlider`**, plus
  `restrictToMarks` on the former, matching Mantine's `marks` and
  `restrictToMarks`.

  Each `PlinthSliderMark` names a position in the slider's own units,
  and its label renders centred on that position — allowing for the
  thumb radius Flutter insets the track by at each end, which is what
  hand-spread labels get wrong at exactly the two ends people check.
  A slider with no marks lays out as before: no wrapper, no extra
  height.

  Labels rather than ticks: the ticks are Flutter's own, from
  `divisions`. Painting a second set would mean guessing at the track
  geometry of a widget this only themes.

  `restrictToMarks` snaps reported values to the nearest mark, for
  scales whose steps aren't evenly spaced — 1, 2, 5, 10 — which
  `divisions` can't express.

  The **Slider with marks** showcase block aligned its labels by hand
  with a `spaceBetween` row, and now doesn't. A golden covers the
  placement, since only an image shows whether the end labels line up
  with the ends of the track.

- **`PlinthTooltip` takes `position`, `offset`, `openDelay` and
  `color`.** Three of the four overlay components already took a
  `position`; this one took none, and its 400ms delay was fixed — too
  slow for a toolbar of icons, too fast for a tooltip repeating a label
  you can already see.

  `position` is `PlinthTooltipPosition` (`top`/`bottom`), not the
  four-sided `PlinthPopoverPosition`. Flutter's tooltip decides its own
  horizontal placement and exposes only a vertical preference, and
  offering `left`/`right` would mean re-deriving hover, long-press,
  focus and dismissal on our own overlay — the work this component
  exists to avoid. Flutter still flips to the other side when the
  preferred one doesn't fit, which is the part that mattered.

  `color` fills the tooltip from the palette for warnings, with the
  label resolved against that fill rather than the theme's text color.

- **`clearable` on `PlinthSelect`, `PlinthMultiSelect`,
  `PlinthTagsInput`, `PlinthFileInput` and `PlinthAutocomplete`.**
  Mantine offers it on seven inputs; Plinth had it on none, so "I chose
  a value and now want none" meant building the affordance outside the
  field.

  Off by default everywhere: a required field that can be emptied
  invites the state the form then has to reject. The button appears
  only when there is something to clear and the field is enabled.

  Three of the five needed care about where the tap lands. On
  `PlinthSelect` the button sits *outside* the `DropdownButton` rather
  than in its `icon` slot, which is inside the dropdown's hit area — a
  tap there would open the menu it is meant to be clearing. On
  `PlinthFileInput` it stops the tap reaching the field, which would
  otherwise clear the files and immediately ask for new ones. And
  `PlinthAutocomplete` clears its own controller as well as reporting
  the empty value, since it owns the text it displays.

  **Not on `PlinthColorInput`**, whose value is a non-nullable `Color`:
  there is no such thing as no colour, and a clear button would have to
  invent one.

- **`radius` on thirteen more components**: Badge, Chip, ColorSwatch,
  Indicator, Pagination, PinInput, Stepper, Switch, Popover, HoverCard,
  Combobox, Cascader and Menubar.

  The theme has a radius scale and a `defaultRadius`, so a component
  that took neither wasn't unstyled — it was un-overridable, and which
  ones those were had no pattern to it. Twenty-six components round
  their corners; these are the ones where Mantine also offers the prop
  or where a bordered surface is the component's own chrome. The rest
  are shapes rather than surfaces (a burger's bars, a loader's dots) and
  are left alone deliberately.

  **Every default is unchanged.** The pill-shaped ones stay pills unless
  given a radius, `PlinthColorSwatch` keeps its squarer 6px, and the
  ones that already followed `defaultRadius` still do. That's what makes
  this additive rather than a restyle, and it's what the new tests
  check — both directions, per component.

### Fixed

- **Disabled buttons looked enabled.** `PlinthButton` and
  `PlinthActionIcon` took a null `onPressed` — the library's convention
  for disabled — and changed nothing but the semantics. To anyone not
  using a screen reader, including the person wondering why their tap
  does nothing, a disabled button was indistinguishable from a live
  one.

  Both now use the `surfaceMuted`/`textDisabled` tokens the theme has
  had all along and `PlinthCloseButton`, `PlinthTextInput` and
  `PlinthSelect` were already using. The variants that draw nothing
  (`subtle`, `transparent`) keep drawing nothing — a grey plate behind
  a disabled subtle button would make it *more* prominent than its
  enabled self.

  A muted fill rather than an opacity wrapper, so a disabled button
  doesn't read differently on a card than on a photograph. The
  `plinth_button_disabled` golden was recording the bug and has been
  regenerated.

## 0.18.0

### Added

- **`PlinthCarousel` + `PlinthCarouselController`.** Swipeable slides
  with arrows, dot indicators, looping, and `slideSize` for letting the
  neighbouring slides peek in — matching Mantine's `Carousel`.

  Mantine ships its carousel as a separate package because it wraps
  Embla, a whole scrolling engine. Flutter already has that in
  `PageView`, so this is a themed arrangement over it rather than a
  library in disguise, and it belongs in `plinth_components`.

  Position is presentation-local, so it manages the index internally
  like `PlinthAccordion` rather than demanding a `value`/`onChanged`
  pair like `PlinthTabs`; `onSlideChanged` reports it, and the
  controller drives it from elsewhere on the page. Looping is an
  endless page list mapped back onto the slides by remainder — the
  origin is rounded to a whole number of laps, without which a
  three-slide carousel opens on its second slide.

  Arrow keys work once it has focus, controls disable at each end when
  not looping, and a single-slide carousel renders neither arrows nor
  dots.

  **No autoplay**, deliberately: slides that move on their own take
  content away from a slow reader, and doing it properly means pausing
  on hover, on focus, on `MediaQuery.disableAnimations`, and while the
  tab is hidden. Mantine's is a plugin for the same reason.

## 0.17.0

### Added

- **`PlinthSimpleGrid` takes per-breakpoint column counts.** `columns`
  is joined by `columnsXs` through `columnsXl`, matching Mantine's
  `cols={{ base: 1, md: 3 }}` and reusing the mobile-first direction
  and `kDefaultBreakpoints` that `PlinthGridCol`'s spans already use:
  the unqualified `columns` is the smallest case, and each breakpoint
  applies from its width upward.

  A grid could previously only be told one column count, so any
  responsive layout had to be assembled from a `LayoutBuilder` and a
  count computed by the caller — which is what the example app was
  missing, and why its home page put three tiles across a phone.

  Existing callers are unaffected: with no breakpoint set, `columns: 3`
  still means three at every width, which a test now pins.

### Fixed

- **`PlinthTabs` overflowed when the tabs were wider than the box.**
  Four tabs is more than a phone fits, and the strip was a plain `Row`,
  so it reported a `RenderFlex overflowed` error and clipped the last
  tab out of reach. It now scrolls horizontally — the platform answer
  to more tabs than fit, and the one Material's `TabBar` uses.

  The strip fills the width it is given now rather than shrink-wrapping
  to the tabs, so the underline runs the full width of its container,
  which is what Mantine's `Tabs.List` does. A tab bar in a `Row`
  without an `Expanded` gets unbounded width, which no scroll view can
  take — that case keeps the plain strip, since nothing can overflow a
  width that isn't there.

- **`PlinthCascader` overflowed once its panels outgrew the box.**
  Three levels at the default panel width needs 482 logical pixels, and
  drilling in only adds more, so a phone hit this on the second level.
  The panels now pan sideways, the way every column browser handles
  the same problem.

  Only when they don't fit: a scroll viewport fills whatever width it
  is offered, which would have stretched the border past the last panel
  on a wide screen. What the panels need is arithmetic — fixed widths
  and single-pixel dividers — so this needs no measuring pass.

## 0.16.4

### Fixed

- **`PlinthMarquee` overflowed while stationary.** The still branch —
  the first frame for everyone, and permanently for anyone with
  reduce-motion on — wrapped its child in an `Align`, which hands over
  the strip's own width. Content wider than the strip is the *normal*
  case for a marquee, so any `Row` inside one reported a
  `RenderFlex overflowed` error, and under reduce-motion it stayed
  broken rather than scrolling.

  It now uses a non-scrolling horizontal scroll view: unbounded width
  for the child, clipping for what doesn't fit, and its own height
  still derived from the child — which an `OverflowBox` can't do before
  the child has been measured.

  Found by putting a logo strip in the showcase, which is the arrangement
  the component exists for. The regression test uses a `Row` rather than
  a lone `SizedBox` on purpose: only a flex *reports* an overflow, so
  the obvious version of the test passed against the unfixed widget.

## 0.16.3

### Fixed

- **`PlinthButton`, `PlinthAlert` and `PlinthNotification` discarded
  the ambient text style**, `fontFamily` above all. They wrapped their
  content in `DefaultTextStyle(style: …)`, which *replaces* rather than
  merges, so anything the widget didn't restate was dropped. In an app
  setting brand typography those three fell back to the platform font
  while everything around them didn't — a mismatch that reads as a
  rendering glitch rather than a library bug.

  Four other components already used `.merge`, so the right pattern
  was established and these three were simply inconsistent with it.

  Found while rendering the pub.dev screenshots: every label came out
  in Roboto except the button's, which arrived in the fallback font.
  The regression test sets the family on the *theme* rather than a
  `DefaultTextStyle` wrapper, because `Material` re-applies the theme's
  own style beneath any wrapper and a wrapper alone can't tell a
  replace from a merge.

  Ten golden images were regenerated for it — five alert, five button.
  Text input is untouched, which is the blast radius you'd expect.

### Added

- **pub.dev listing metadata**: four screenshots, `topics`, a fuller
  description, and a `homepage` pointing at the live demo rather than
  the source, since `repository` already covers that.

  The screenshots are rendered by `example/tool/generate_screenshots.dart`
  rather than captured by hand, so they can be regenerated when the
  theme moves. It loads the real Roboto and MaterialIcons from the SDK
  cache first: golden images are unusable here precisely because the
  placeholder test font draws text as solid blocks.

## 0.16.2

### Fixed

- **`PlinthRollingNumber` rendered the wrong digits at rest.** Each
  wheel's position was `value / 10^place`, which leaves every wheel
  above the units carrying the fraction contributed by the digits
  below it. At 58,210 the ten-thousands wheel sat at 5.82 — four
  fifths of a line out of place, showing mostly the 6 above the 5, so
  the number read closer to 68,210 than to what it was given. The
  further left the digit, the worse it got.

  A real odometer's tens wheel only turns while the units wheel passes
  9 back to 0, and it now works that way: the fraction is applied over
  the last tenth of the wheel below rather than continuously. Rest
  positions are exact, and the roll still carries across a power of
  ten.

  Found by looking at the example app's Live metrics block, which is
  the argument for the showcase existing at all — 494 passing tests
  didn't catch it, because none of them asked where the glyphs
  actually sat. One now does, checked against the unfixed widget: it
  reports only `10` of `58210` settled.

## 0.16.1

### Fixed

- **`PlinthHoverCard` never rebuilt its overlay panel when its content
  changed.** An open card was frozen at whatever it was built with, so
  content arriving after the pointer did — the loaded profile, the
  fetched preview — never appeared. That is close to the whole point of
  a hover card, which is what makes this worth a patch release rather
  than waiting.

  Same fix and same wrinkle as `PlinthPopover` in 0.14.0:
  `didUpdateWidget` runs *during* the build phase, and marking an
  `OverlayEntry` dirty then is illegal because the entry isn't a
  descendant, so the rebuild is deferred to a post-frame callback.

  The regression test was checked against the unfixed widget rather
  than assumed: without the change it fails.

### Not a bug after all

`PlinthMenu` was flagged alongside the hover card as sharing this
problem, on the evidence that it too had no `didUpdateWidget`. It
doesn't need one — it's a `StatelessWidget` built on `PlinthPopover`,
so it inherited that fix in 0.14.0. A test now pins that, so the
delegation can't quietly stop covering it.

## 0.16.0

### Added — the last batch of the Mantine gap

Seven components, closing every remaining entry on the gap list that
was ever going to be built.

- **`PlinthMaskInput`** — formats as you type. The formatter rebuilds
  the whole value on every edit rather than patching it: patching is
  where masked inputs usually go wrong, leaving literals in the wrong
  places after a mid-string delete or a paste. Characters that can't
  fill a slot are skipped rather than rejecting the edit, so a stray
  space in a pasted phone number doesn't discard the paste.

  It is a formatter over `PlinthTextInput`, not a new field — which
  needed `inputFormatters` and `keyboardType` passed through, added
  here. Reproducing the chrome to attach a formatter would have been
  the worse trade.

- **`PlinthJsonInput`** — **validates on blur, not on every
  keystroke.** Half-typed JSON is invalid by definition, so validating
  as you type means showing an error for the entire time somebody is
  writing. Focusing again clears it rather than leaving a red field
  while it's being fixed, and `formatOnBlur` pretty-prints at the one
  moment reformatting doesn't move the caret out from under you.

- **`PlinthFileButton`** — the trigger-only counterpart to
  `PlinthFileInput`, with the same "the picker is yours" contract. It
  disables itself while `onPick` is in flight, which is the one thing
  a plain button gets wrong: a picker is slow enough to invite a second
  tap, and two open pickers is a state nobody handles.

- **`PlinthSplitter`** — two resizable panes. The divider position is
  presentation-local and kept internally, like `PlinthSpoiler`'s
  expanded state; the drag is clamped so a pane can't be dragged away
  entirely and left with no handle to drag back.

- **`PlinthScroller`** — a back-to-top button that appears once there
  is something to go back to. State changes only when the offset
  crosses the threshold, never per scroll pixel, and the hidden button
  is wrapped in an `IgnorePointer`: invisible but tappable is worse
  than absent.

- **`PlinthMenubar`** — the behaviour that makes it a menubar rather
  than a row of `PlinthMenu`s: **once one menu is open, moving the
  pointer across the bar opens the next** without a second click.
  Hovering with nothing open does nothing, which is the other half of
  the rule — otherwise merely crossing the bar would open menus.

- **`PlinthFloatingWindow`** — a draggable, resizable panel that isn't
  a modal: it stays put, several can be open, nothing behind it is
  blocked. Movement and resizing are clamped to the parent, so a window
  can't be stranded with its header off-screen.

### The gap list is closed

What remains on it is what was always meant to remain: `PlinthInput`
and `PlinthNativeSelect` (architectural mismatches rather than missing
widgets), `PlinthFloatingIndicator` (a change of approach `PlinthTabs`
deliberately doesn't take), and the "deliberately not planned" set
where Flutter's own answer is better.

111 components, 106 playgrounds, 225 Widgetbook use cases.

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
