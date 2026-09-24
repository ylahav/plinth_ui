# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

The three Plinth packages move in lockstep from `1.0.0` onward — see
[PUBLISHING.md](../../docs/PUBLISHING.md#decided-lockstep-from-10-onward).
A release where this package itself did not change says so rather than
inventing one. Before `1.0.0`, minor bumps could carry breaking
changes; from `1.0.0` they cannot.

## 1.7.0

No change in this package. Released in lockstep with
`plinth_components` 1.7.0, which completes the full-screen sheet:
`PlinthDrawer` can now hand its child the whole panel, which
`extent` alone did not do.

## 1.6.0

No change in this package. Released in lockstep with
`plinth_components` 1.6.0, which adds `PlinthDrawer.extent` — the
full-screen sheet the size scale could not express, found while
converting an existing app onto Plinth.

This also brings the three back into line after `plinth_core` 1.5.1,
which went out alone because the bug it fixed was core's alone.

## 1.5.1

### Fixed

- **`PlinthDtcg.parse` dropped 46 of the 191 tokens `export` writes.**
  Border widths, durations, font weights, curves and *every* semantic
  colour came back as "no Plinth token matches this path", so a
  round-trip through this library's own format silently flattened a
  theme to its ramps and three scales.

  All of them now read back, and `parse` reports `surface`, `text`,
  `border` and the rest as applied rather than ignored.

  Three kinds still cannot come back and now say so *specifically*
  rather than falling through the catch-all: `series` and `role` export
  the colour they resolved to, where a theme stores a ramp name plus a
  shade — the name is not recoverable from a colour without the
  reference layer the hierarchy deliberately does not claim. DTCG
  shadow import is unimplemented.

  **Found by running the round trip against the published 1.5.0 with a
  stricter assertion than the repo's own.** The original test checked
  colours and three scales and passed while everything else was
  dropped; it now asserts that nothing lands in `ignored` except those
  three kinds, and that the *values* survive rather than only the
  paths.

## 1.5.0

**Your borders will look different, and that is the headline.**

`border` was `#CED4DA`, which is **1.49:1** against `surface` and
1.26:1 against `surfaceSunken`. `plinthFieldBorderColor` returns it for
every input that is neither focused nor in error, so it is the resting
boundary of every field in the library — and WCAG 1.4.11 asks **3:1**
of the visual information required to identify a component. It is now
`#808890`: 3.59, 3.23 and 3.03 against the three surfaces.

Every input, card outline and divider will read noticeably stronger.
There is no version of this fix that looks the same, and the old value
was short by a factor of two.

Chosen as the lightest colour on the ramp's own hue line that clears
3:1 everywhere, because the job was to meet the floor rather than to
restyle. Gray shade 6 was the obvious candidate and misses by 0.01 on
`surfaceMuted`; shade 7 clears at 7:1 and would have painted a far
heavier border than anybody asked for.

### Fixed

- **`border` contrast**, as above. Dark likewise: `#373A40` →
  `#71777F`, which was 1.19:1 on `surfaceSunken`.

- **Dark `textMuted`** `#909296` → `#939599`. It was **4.36:1** on
  `surfaceSunken` against a 4.5 floor — a miss small enough that nobody
  checking by eye would ever have caught it, which is the whole
  argument for checking by arithmetic.

  Both were found by `theme.validate()`, below, pointed at this
  library's own defaults one commit after it was written. A validator
  that passes its author's theme and fails everyone else's is one
  nobody should trust.

### Added

- **`theme.validate()`** — the contrast machinery pointed at a theme
  instead of a colour. Returns every pair that falls short of its
  floor, worst first, naming tokens by their `PlinthToken` path so a
  finding can be looked up or grepped for in the design file it came
  from.

  The tokens it checks are the ones an adopter sets **by hand**:
  `text`, `surface`, `border` and the series palette are literal
  colours that nothing lifts, because they are the input. Everything
  routed through `readableOn` passes by construction and is not worth
  reporting.

  Pointed at Plinth's own defaults it finds two things, both left
  as-is: `border` is 1.26–1.49:1 against the three surfaces where WCAG
  1.4.11 asks 3:1 of a control boundary, and the dark theme's
  `textMuted` on `surfaceSunken` is 4.36:1 against a 4.5 floor. A
  validator that passes its author's theme and fails everyone else's is
  one nobody trusts.

- **The token hierarchy** — `PlinthToken`, `PlinthTier`,
  `PlinthTokenType`, and `theme.tokens`. Every token in a theme,
  addressable by a stable path (`color.blue.6`, `spacing.md`,
  `surface`) and sorted into primitive or semantic.

  `docs/ROADMAP.md` calls this the gate on everything in interop, and
  the reason is narrow: a `PlinthTheme` was thirty-odd fields that only
  Dart could read. You could ask it for `surface`; you could not ask it
  *what it has*. Export, a token explorer and theme validation all need
  the second question.

  Two tiers, not three. Component tokens do not exist yet, and an empty
  tier would describe an intention rather than the theme.

  Purely additive: no field changed and nothing is deprecated.

- **DTCG, both directions** — `PlinthDtcg.export` and
  `PlinthDtcg.parse`. A design team publishes tokens from Figma as DTCG
  JSON and a web codebase consumes them through Style Dictionary; a
  Flutter app in the same organisation had to re-type the palette by
  hand and drift from it quietly.

  **`parse` returns a result, not a theme.** It reports what it applied
  *and what it ignored, with a reason for each* — because an importer
  that silently drops what it does not understand produces a theme that
  looks right and is not, and the person who finds out is whoever
  trusted the colours. References (`{color.blue.6}`) are resolved, and
  a reference cycle is reported rather than overflowing the stack.

  Curves export as names rather than control points: `Curves.bounceIn`
  is piecewise and has no four-number cubic-bézier form, and a name
  that round-trips is worth more than four numbers wrong for half the
  values.

  What the enumeration reports is **resolved values, not references**.
  A theme stores `surface` as a `Color`, so that is what it can
  honestly report; emitting references needs a reference layer, which
  is a separate change with a breaking edge to it.

## 1.4.0

No change in this package. Released in lockstep with
`plinth_components` 1.4.0, which adds `inputFormatters` to
`PlinthTextarea` — the one parameter that kept `PlinthCharacterLimitField`
correcting a committed value instead of refusing one.

## 1.3.1

No change in this package. Released in lockstep with
`plinth_components` 1.3.1, which fixes five controls that were
reachable by keyboard and invisible once reached — WCAG 2.4.7.

The constraint on this package is deliberately still `^1.3.0`. Nothing
here moved, so a consumer who already has 1.3.0 has no reason to be
made to take 1.3.1; lockstep is a release convention, not a reason to
force an upgrade that buys nobody anything.

## 1.3.0

**The token engine went from four scales to nine, and one of the four
turned out to have been painting nothing.**

Colour, spacing, radius and font size are joined by font weight,
duration, curve, border width and elevation — each driven by what
`plinth_components` was already hardcoding rather than by what a token
system usually has, so the defaults are the values that were there and
nothing moved on screen.

`shadow` is the other half. It has been public, documented, and carried
through `copyWith` and `lerp` since `1.0.0`, while `PlinthPaper` built
its shadows from a hardcoded `Colors.black`. A theme that set it got
black shadows anyway. Elevation now resolves through it, and a test in
`plinth_components` overrides each of the five new fields and asserts
what *rendered* changed — because reading a value back off the theme
only proves that a map holds what was put in it.

**The contrast machinery also became askable, not just answerable.**
This package's whole claim is a number — 4.5:1 — and until now a caller
could only receive the answer. `readableOn` hands back a colour;
nothing let you ask what the ratio actually was. Every contrast test in
this repo, and the tutorial app's theme test, had re-implemented the
WCAG formula locally to check its own work.

### Added

- **Four token axes, as five fields: `fontWeights`, `durations` and
  `curves` (motion is both), `borderWidths`, `elevations`.** Read through `weight()`,
  `duration()`, `curve()`, `borderWidth()` and `elevation()`, each of
  which falls back to the default rather than throwing, so a caller who
  overrides one entry does not lose the rest.

  Driven by what the library was already hardcoding rather than by what
  a token system usually has: 59 `FontWeight` literals across three
  distinct values, 33 `Duration`s clustering on 150ms and 200ms, 13
  `Curves`, and border widths of 1, 1.5, 2, 3 and 4. The defaults are
  those values, so adopting the scales changes nothing on screen.

  `lineHeights` was planned alongside these and is **not** here. The
  library sets an explicit line height in exactly one place, which is
  not evidence of an axis — it is evidence of one widget.

- **`PlinthElevation`** — blur, offset, opacity and spread, with the
  colour left out on purpose. `elevation(step)` resolves it against the
  theme's `shadow`.

- **`PlinthWeight`, `PlinthCurve`** — roles for the two axes that are
  not size scales. `PlinthShadow` moved here from `plinth_components`
  so `elevations` could be keyed by it; it is unchanged, and still
  importable from that package, which re-exports this one.

- **`PlinthTheme.contrastRatio(a, b)`** - the WCAG contrast ratio
  between two opaque colours, 1.0 to 21.0. This is the function
  `readableOn` and `contrastingOn` resolve with, exposed so an app can
  verify a pair rather than take it on trust - including for colours
  Plinth never picked.

  ```dart
  final ratio = PlinthTheme.contrastRatio(theme.text, theme.surface);
  expect(ratio, greaterThanOrEqualTo(PlinthContrast.body.ratio));
  ```

  Both colours must be opaque. Compose a translucent one onto its
  background first (`Color.alphaBlend`) - a ratio taken against an
  alpha channel measures a colour nothing renders.

- **`PlinthTheme.relativeLuminance(c)`** - WCAG relative luminance,
  public for the same reason: a caller checking its own colours needs
  the arithmetic the library resolves with, not a second implementation
  that might round differently. It agrees with Flutter's own
  `Color.computeLuminance`, which a test pins.

This is the first piece of the roadmap's *"ship the contrast machinery
as something a team runs in CI against its own tokens"*, and it arrived
the way that roadmap says core work should - demanded by something
being built rather than picked off a list. What demanded it was the
demo app's new rebrand control, which reports what a chosen brand
colour actually measures.

### Fixed

- **`PlinthTheme.shadow` was a token that painted nothing.** It was
  public, documented, and carried through `copyWith` and `lerp` — while
  `PlinthPaper` built its shadows from a hardcoded `Colors.black`. A
  theme that set `shadow` got black shadows anyway. Elevation now
  resolves through it, so it does what it always said it did.

  A regression test in `plinth_components` now overrides each of the
  five fields and asserts what *rendered* changed, rather than reading
  the value back off the theme — which would only prove that a map
  holds what was put in it.

## 1.2.0

No change in this package. Released in lockstep with `plinth_components`
1.2.0, which builds out `F-3` - the announcement work - and fixes two
components that could not be reached by keyboard. See
[B0C_FINDINGS.md](../../docs/B0C_FINDINGS.md#second-pass--23-aug-2026).

## 1.1.0

No change in this package. Released in lockstep with
`plinth_components` 1.1.0, which carries the fixes from the
[B0c screen-reader pass](../../docs/B0C_FINDINGS.md).

## 1.0.1

### Fixed

- **The pubspec description was 202 characters, and pub.dev caps it at
  180.** That cost 10 pub points — `Provide a valid pubspec.yaml` scored
  0/10 — dropping the package from 160 to 150.

  No code changed. The description says the same things more briefly.

## 1.0.0

**The first stable release.** Everything below shipped across the two
betas and is collected here; the sections after this entry are the
betas themselves, kept for anyone tracking what moved when.

**What 1.0.0 promises:** no breaking *source* change without a 2.0.0.
Rendered output is not covered — a minor may correct a colour, a size or
an announcement, which this library has already done several times and
will do again. See
[PUBLISHING.md](../../docs/PUBLISHING.md#what-100-promises). Pin goldens
to a version, not a range.

**`B0c`, the manual screen-reader pass, had not run when this shipped.**
Everything accessibility-related is verified by tests and simulated
semantics trees and has not been heard aloud. Its findings will land as
corrections in a `1.x`.

### Added

- **`PlinthDensity`** — a tap-target floor, so an app can say whether it
  is a desktop tool or a phone. (A1c)

  ```dart
  PlinthTheme.defaultTheme.copyWith(density: PlinthDensity.touch)
  ```

  Plinth sizes like the web library it is modelled on. Measured across
  eleven controls at default size: **every one clears WCAG 2.2 AA's
  24x24, and none clears iOS's 44 or Android's 48.** That is the right
  answer for a dense admin table and the wrong one for a phone, and
  there was no way to say which.

  | | floor |
  |---|---|
  | `standard` (default) | 24 — WCAG 2.2 SC 2.5.8 |
  | `comfortable` | 44 — iOS HIG |
  | `touch` | 48 — Android Material |

  **`standard` is a no-op**, asserted rather than assumed: every control
  already cleared 24, so the default density cannot restyle anything.

- **`lerp` is real, so theme changes animate.** (PR-11)

  It used to be `return t < 0.5 ? this : other;` — a hard cut halfway
  through any transition. Chrome colours, ramp shades and the numeric
  scales now interpolate, driven by the `AnimatedTheme` that
  `MaterialApp` already installs.

  `brightness`, `primaryColor`, `defaultRadius` and the four lookup maps
  still change over at the midpoint, because there is no half-step
  between two brightnesses or two ramp names.

  **Expect a light↔dark toggle to be a partial cross-fade.**
  `defaultTheme` and `darkTheme` share one ramp map, so a light versus
  dark palette colour differs only through `shadeFor` mirroring — which
  follows `brightness` and therefore snaps. The chrome fades; the
  accents change over. That is a limit of shade mirroring, not of the
  interpolation.

- **`PlinthRole` and `roleRamps`** — the component library resolves its
  own colour roles through a mapping instead of reaching into `colors`
  for `'red'`, `'gray'` and `'green'`. (PR-09)

  ```dart
  // Keep 'red' for your own meaning; the library still has an error colour.
  theme.copyWith(roleRamps: const {PlinthRole.error: 'brandDanger'});
  ```

  `colors` was a namespace shared between the library and its consumer
  where **neither knew**. An app that repurposed `red` as its expense
  pole silently restyled every form field's error state; an app that did
  not ended up with two different reds on screen. Both happened in the
  same migration.

  Three roles, because three is what the library actually uses:
  `error` (every field's border and message), `neutral` (descriptions,
  separators, empty states), `success` (the copy button's flash).

  **Value-preserving.** `kDefaultRoleRamps` maps them to `red`, `gray`
  and `green` — exactly what was hardcoded — and a test asserts equality
  across all three roles and all ten shades in both themes. 53 call
  sites moved; no golden did.

  A partial map falls back per role, so remapping one does not blank the
  other two.

- **A Material bridge** — `PlinthMaterialBridge`, an extension on
  `PlinthTheme` for reconciling it with `ThemeData`. (PR-08)

  ```dart
  // Keep your own ThemeData, and assert the two agree.
  test('palettes agree', () {
    expect(myTheme.colorSchemeDisagreements(myScheme), isEmpty);
  });

  // Or derive Material's types from Plinth.
  ThemeData(colorScheme: myTheme.toColorScheme(),
            textTheme: myTheme.toTextTheme());
  ```

  **The need was agreement, not generation**, and that reverses what
  was planned. A `toThemeData()` was the roadmap's top-ranked task and
  during the migration it was **never reached for** — the app already
  had six working lines of `ThemeData`, and replacing that wholesale is
  riskier than the six lines it saves. What actually broke was reading
  colour from two systems at once: 58 `plinth.*` lookups beside 31
  `colorScheme.*` and 80 `textTheme.*`, with Material's seeded red
  sitting in the same tables as the app's red and nothing keeping them
  in agreement.

  **What Plinth does not have an opinion about is named, not guessed.**
  `toColorScheme` takes `secondary`, `tertiary`, the container roles and
  the inverse roles from `ColorScheme.fromSeed`, and the checker ignores
  them; `ownedSchemeFields` lists the ten it decides. Reporting a
  disagreement about a field Plinth never had a view on would train
  people to ignore the list. Likewise `toTextTheme` fills the body,
  title and label roles and leaves `headline`/`display` as the base had
  them, because `fontSizes` runs 12 to 20 and cannot answer what a
  display size is without inventing one.

  `error` maps to the `red` ramp because `plinth_components` already
  hardcodes `shaded('red', …)` for destructive state in 12 places.

  Comparison is exact, deliberately: a tolerance would decide for you
  how much drift is acceptable, which is the judgement this exists to
  surface rather than make.

- **A categorical series palette, built to survive colour-vision
  deficiency.** (PR-04, PR-18)

  ```dart
  theme.series(0);              // the nth series colour
  theme.seriesFor('groceries'); // by domain key
  ```

  36 of the subject app's 91 hardcoded colours were chart series — the
  largest single category of hardcoding the migration left behind, and
  a property neither a brand ramp nor a status colour has.

  `kDefaultSeriesColors` is scored across **eight contexts**: the light
  and dark themes, each under normal vision plus simulated protanopia,
  deuteranopia and tritanopia (Viénot–Brettel–Mollon 1999). Worst case
  across all eight: **13.5 ΔE between any two, 33.1 between
  neighbours.**

  **The shades vary rather than sitting at 6, and that is the whole
  mechanism.** Dichromats lose hue discrimination but keep lightness
  discrimination, so a palette separated only by hue collapses for them
  and one that also moves through lightness does not.

  `kVividSeriesColors` is the hue-only alternative: ten ramps at shade 6
  with the largest pairwise separation for normal vision (30.5). It is
  **not** the default because it scores **2.3 under tritanopia and 3.3
  under protanopia** — 2.3 is about the just-noticeable difference, so
  two of its series are the same colour to a reader with tritanopia.
  Use it when colour is decoration beside a label rather than the
  information itself.

  **`seriesFor` takes a name, not a `Color`, and that is the point.**
  The layer that knows a slice is `'crypto'` is usually pure Dart with
  no `BuildContext`; the layer that paints it has one. A name crosses
  that boundary, a colour cannot without dragging the theme with it.

  Register domain keys with `seriesKeys` to pin them. Unregistered keys
  resolve deterministically — an explicit FNV-1a rather than
  `hashCode`, which Dart does not promise to keep stable across runs —
  so a chart does not reshuffle on restart. **The hash is a floor, not
  a solution:** ten positions and an unbounded key space collide, and
  `'groceries'` and `'transport'` both land on 0. Register anything
  shown together.

## 1.0.0-beta.2

**A second beta rather than 1.0.0, deliberately.** Everything below is
breaking, and `PR-17` — whether a heading on a tinted surface belongs at
the body floor or the large-text one — is still open and would move
colours again. 1.0.0 promises no breaking change without a 2.0.0, and
spending that promise the week it is made is worse than one more beta.

Everything here came from migrating one real app onto the packages and
recording where it had to work around them — see
[ADOPTION_REQUIREMENTS.md](../../docs/ADOPTION_REQUIREMENTS.md), which
numbers each gap, and
[APP_VALIDATION_PLAN.md](../../docs/APP_VALIDATION_PLAN.md) for how the
evidence was gathered.

### Breaking

- **`generateShades` anchors the supplied colour at shade 6, which
  repaints every built-in ramp.** (PR-03, PR-16)

  Feed a colour in, ask for shade 6 — the shade every component
  defaults to — and you now get that colour back. Before, the lightness
  stops were absolute, so a base was *normalised onto* the curve rather
  than anchored to it, and the best-matching index was not even
  consistent (anywhere from 5 to 8 depending on hue). There was no
  shade a caller could reliably ask for.

  **This is a visible restyle, not a refactor.** The 13 built-in ramps
  are seeded with Mantine's own published `.6` values and none of them
  survived the old generator:

  | Ramp | Seed | Was | Now |
  |---|---|---|---|
  | `red` | `#FA5252` | `#E90707` | `#FA5252` |
  | `violet` | `#7950F2` | `#4511DF` | `#7950F2` |
  | `blue` | `#228BE6` | `#187FD7` | `#228BE6` |

  The distortion ran one way — darker and more saturated than Mantine —
  so the palette gets lighter and truer. **Shades 0 and 9 do not move**
  (both endpoints are held), so washes and the darkest shades render as
  before; shades 1–8 shift, most visibly on `red` and `violet`.

  Two knock-on effects worth expecting:

  - **`readableOn` now does more work.** Mantine's real `red.6` is
    ~3.6:1 on white and does not clear the body floor, where the old
    over-darkened `#E90707` did. Text taking a palette colour will
    darken where it previously did not — which is the PR-06 floor
    working, not a regression.
  - **Anything pinned to a literal shade value will move.** If you
    screenshot-test or hardcode a generated shade, re-baseline it.
  - **Filled buttons in blue and red now carry a dark label, not a
    white one.** `contrastingOn` picks whichever foreground contrasts
    better, and on the corrected fills the light one stops winning:
    white on `blue.6` goes from 4.15:1 to **3.56:1** while the dark
    foreground reaches 4.84:1. New for blue and red only — green,
    yellow and teal already had dark labels and violet keeps white.
    Since `blue` is the default `primaryColor`, this changes the
    default button.

    Deliberate. White on Mantine's real `blue.6` fails AA for body
    text, so Mantine's own filled buttons do not clear it either; the
    distorted palette had been hiding that. Plinth is now more
    accessible than the palette it copies, and looks less like it.
    Override `onFilled` / `onFilledInverse` if you want the old
    pairing back.

  An app supplying its own brand colour can now delete any re-anchoring
  curve it wrote — which is what publishing `generateShades` was
  supposed to achieve and could not.

- **`readableOn` now defaults to a body-text contrast floor (4.5:1)
  instead of 3.0:1.** (PR-06) 3.0 is WCAG's *large text* threshold — right
  for a heading, wrong for the table cell most callers are actually
  painting. On the subject app, six of seven text tokens were sitting in
  "large text only" and nobody had noticed.

  The floor is now named rather than numeric: `PlinthContrast.body`
  (4.5), `.large` (3.0), `.nonText` (3.0), passed as `level:`. An
  explicit `minRatio:` still overrides it, so existing callers that
  passed a number are unaffected.

  **What moves:** accent colours darken where they were between 3.0 and
  4.5 — 19 of 26 ramp/background pairings in the light theme, 11 of 26
  in dark. `plinth_components` pins its `PlinthVariant.light` pairings
  to `.large` explicitly, so that variant looks exactly as it did: a
  same-hue label on a same-hue tint cannot reach 4.5 and stay
  recognisably that colour, since in a dark theme walking to body
  contrast lands on near-white (`cyan #90DFEA → #F0F8F9`).

  **Golden images need regenerating on Linux.** The goldens are skipped
  on Windows and macOS by design, so this change could not be verified
  visually where it was made.

### Added

- **A semantic token tier** — name a colour by the role it plays rather
  than by its hue. (PR-01, the largest gap the adoption exercise found)

  ```dart
  PlinthTheme.defaultTheme.copyWith(
    colors: {
      ...PlinthTheme.defaultTheme.colors,
      'expenseRamp': PlinthTheme.generateShades(const Color(0xFFFF3B30)),
    },
    semanticColors: {'expense': const PlinthSemanticColor('expenseRamp')},
  );

  theme.semantic('expense');      // the fill
  theme.semanticText('expense');  // legible as a label on the surface
  theme.semanticWash('expense');  // a panel or row tint
  ```

  Three roles, because three is what a real app read — migrating it
  used a fill, a text variant and a wash per pole and reached for
  nothing else, leaving **7 of each ramp's 10 shades unread.** It cost
  110 lines of hand-written `app_tokens.dart` to get them, and that
  only worked because `colors` accepts arbitrary string keys, so role
  names could be smuggled in as ramps — an accident rather than an API.

  `PlinthSemanticColor` carries the contrast floor per role
  (`level:`, default `PlinthContrast.body`) rather than per call site,
  since the floor is a fact about the content: a heading-only role can
  honestly sit at `.large`, a table cell cannot.

  Roles live in their own map, so declaring `expense` no longer spends
  the `red` key `plinth_components` hardcodes in 12 places for error
  states. An undeclared role falls back to reading the name as a ramp
  key, so `semantic('blue')` works and the pre-existing smuggling
  pattern renders as it did.

  **Additive** — `semanticColors` defaults to empty and no component
  declares a role, so nothing renders differently until an app opts in.
  It does **not** on its own retire an adopter's hand-written tier: the
  roles resolve against a ramp, and PR-03 (anchoring a supplied brand
  colour so shade 6 returns what you fed it) is still open.

- **`PlinthSpacing`** — the spacing scale as compile-time constants
  (`xxs` 4, `xs` 8, `sm` 12, `md` 16, `lg` 24, `xl` 32), on a 4px base
  unit exposed as `kSpaceUnit`. (PR-07)

  The named `spacing` map starts at `xs: 10`, above the values both this
  library and its adopters reach for most: `plinth_components` writes
  `spacing[PlinthSize.xs]! * 0.4` in 38 places and `* 0.8` in 8 more —
  4px and 8px — and **80 of its 87 spacing multipliers resolve below
  10**. The library has been rebuilding a sub-`xs` scale out of
  fractions.

  Constants rather than a theme lookup on purpose: spacing does not vary
  by theme, and a lookup costs a `BuildContext` and forces the widget out
  of `const`. Applying this to the subject app converted 314 literals
  and every one stayed `const`. `PlinthTheme.space(steps)` is there for
  runtime multiples.

- **`PlinthTheme.wash(name, {alpha})`** — a background tint that survives
  the brightness flip. (PR-05) `shaded(name, 0)` mirrors to shade 9 in a
  dark theme, turning the lightest tint into the most saturated shade:
  `shaded('green', 0)` is `#F2F8F3` in light and `#245B2E` in dark, a
  saturated panel where a wash was wanted. `wash` composites over
  `surface` instead, so the role holds in both themes.

- **`PlinthTheme.generateShades`** is public. (PR-02) It was private, so
  an app supplying its own brand colour could not reach the function that
  built the library's own palette and had to copy it.

- **`ThemeData.plinth`** — the same lookup as `context.plinth` for code
  that already holds a `ThemeData`. (PR-10) A helper written the
  idiomatic Flutter way (`Widget _badge(ThemeData theme, …)`) had the
  theme and still had to grow a `BuildContext` parameter.

### Known gaps

- `generateShades` still normalises a base colour onto fixed lightness
  stops rather than anchoring it, so feeding it `#FF3B30` and asking for
  shade 6 returns `#F00D00`. Making it public does not yet let an app
  retire its own copy — that needs PR-03.
- The 4px grid covered 314 of the subject app's 353 spacing literals.
  The 39 that did not fit cluster on half-steps (`6` ×20, `2` ×10,
  `10` ×8), which is either a missing 2px sub-unit or drift worth
  normalising.

## 1.0.0-beta.1

**No changes to this package.** The version moves because the three
Plinth packages are now released in lockstep, and this is the first
release under that convention.

The `1.0.0-beta` line is the rehearsal for that promise, not the
promise itself: the API is what 1.0.0 intends to ship, and the beta
exists so the three-package release sequence gets run once while a
mistake is still cheap. `flutter pub add` still resolves the last
stable release unless a prerelease is asked for.

## 0.2.1

### Added
- An `example/`, so pub.dev's Example tab shows how to register the
  theme and read tokens from it rather than sending people to the repo.
  Since this package has no widgets, the example is plain Flutter
  styled entirely from `PlinthTheme` — including `shaded`,
  `contrastingOn`, and `readableOn`, which are the parts hardest to
  infer from the API alone.

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
