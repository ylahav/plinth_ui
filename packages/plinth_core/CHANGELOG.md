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

- **A categorical series palette** — ask for the *n*th distinguishable
  colour. (PR-04, the largest single category of hardcoding that
  survived the migration: **36 of the app's 91 colours were chart
  series**)

  ```dart
  theme.series(0);              // the first series colour
  theme.seriesFor('groceries'); // by domain key
  ```

  Neither a brand ramp nor a status colour. The property is separation,
  and the default sequence is picked to maximise it rather than chosen
  by eye: of the twelve non-neutral ramps, `kDefaultSeriesRamps` is the
  ten-subset with the largest **minimum pairwise CIE76 ΔE (30.5)**,
  ordered so the **minimum ΔE between neighbours (112.7)** is as large
  as it can be. Neighbours score separately because adjacent series are
  the ones a reader compares. `violet` and `green` are dropped — violet
  collides with `grape`, green with `teal` and `lime` — and `gray` is
  excluded because a neutral among the series makes one look disabled.

  **`seriesFor` takes a name, not a `Color`, and that is the point.**
  The layer that knows a slice is `'crypto'` is usually pure Dart with
  no `BuildContext`; the layer that paints it has one. A name crosses
  that boundary, a colour cannot without dragging the theme with it.

  Register domain keys with `seriesKeys` to pin them. Unregistered keys
  still resolve, deterministically — an explicit FNV-1a rather than
  `hashCode`, which Dart does not promise to keep stable across runs —
  so a chart does not reshuffle its colours on restart. **The hash is a
  floor, not a solution:** ten positions and an unbounded key space
  collide, and `'groceries'` and `'transport'` both land on 0. Register
  anything shown together.

  **Not verified for colour-vision deficiency.** The separation is
  measured in ordinary trichromatic vision, and the warm run — red,
  yellow, orange — is exactly where deuteranopia would show. Pass your
  own `seriesRamps` if you need a CVD-safe sequence.

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
