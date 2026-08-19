# Requirements from adoption

Changes `plinth_core` and `plinth_components` need, each one traced to a
specific thing a real app had to work around.

Nothing here is speculative. Every requirement below was produced by
migrating [`financial-organizer`](APP_VALIDATION_PLAN.md) onto the
packages — 91 colour values, 42 notifications, one wizard — and
recording where the API and ordinary Flutter practice pulled apart.
Provenance for each is in
[PHASE_MINUS_1_FINDINGS.md](PHASE_MINUS_1_FINDINGS.md) (tracks T2/T6)
and [APP_VALIDATION_PLAN.md](APP_VALIDATION_PLAN.md).

Requirements are `PR-##`, mirroring the app's own `MR-##` convention so
the two can be cited against each other.

## How to read the priority column

| | Meaning |
|---|---|
| **Blocker** | An adopter cannot do the thing at all without writing package-shaped code themselves |
| **High** | Doable, but the workaround is silent or wrong-by-default — the failure mode is not noticing |
| **Medium** | Real friction, visible, worked around once and then forgotten |
| **Low** | Papercut or docs |

## Status

Seventeen landed: five on 18 Aug 2026, then PR-01, PR-03, PR-16, PR-04,
PR-12, PR-08, PR-09, PR-13, PR-14, PR-15, PR-11, PR-17 and PR-18 on
19 Aug.
**Everything the migration itself found is now closed** — every
Blocker, every High, every Medium and the one Low. So is everything this
round's work filed against itself, except **PR-19**, which PR-17's
measurements turned up and which is the highest-priority item left.

**The 18 Aug five were behaviour-preserving.** Verified by re-running
the subject app's own harness against the changed packages: 225/225 app
tests, 48 core tests, 643 component tests, and the T4 palette snapshot
**unchanged**.

**Only PR-03 and PR-16 changed rendering, and the palette snapshot no
longer holds because of them.** PR-03 anchors the ramp generator, which moves every interior
shade of all 13 built-in ramps — that is the point of PR-16, since the
ramps had never actually matched the Mantine values they are seeded
with. Shades 0 and 9 are unmoved (both endpoints are held), so washes
and the darkest shades render as before; shades 1–8 shift, most visibly
on `red` and `violet`.

**Everything else on 19 Aug leaves rendering alone.** PR-01 and PR-04
add a map that defaults to empty or a sequence nothing reads unless
asked; PR-12 adds an overload and routes the existing one through it;
PR-08 is a new extension nothing in the library calls; PR-13 is a new
widget; PR-14 and PR-15 are documentation. PR-09 is the only one that
touched component source in bulk — 53 call sites — and its defaults
resolve to the exact ramps that were hardcoded, which a test asserts
across every role and shade in both themes.

Current: 120 core tests, 656 component tests, `dart analyze` and
`dart format` clean. One component test changed — `PlinthText`'s
"resolves a color key at shade 6" asserted `color('red', 6)` and passed
only because the un-anchored generator over-darkened the ramp; the
widget correctly routes text through `readableOn`, and Mantine's real
`red.6` does not clear the body floor on white.

**Goldens regenerated on Linux and reviewed: 32 of 43 moved.** They are
skipped on Windows by design, so a local run proves nothing about them;
these came from `.github/workflows/regenerate-goldens.yml`. Unlike the
18 Aug work, a golden diff here was *expected* rather than a bug — and
reviewing them rather than accepting the batch is what caught the
following, which no test asserted:

**Filled buttons in blue and red now carry a dark label instead of a
white one.** `contrastingOn` maximises contrast, and on the corrected
fills the light foreground stops winning:

| Ramp | Old fill | white / dark | New fill | white / dark |
|---|---|---|---|---|
| `blue` | `#187FD7` | 4.15 / 4.15 → white | `#228BE6` | **3.56** / 4.84 → dark |
| `red` | `#E90707` | 4.67 / 3.69 → white | `#FA5252` | **3.28** / 5.24 → dark |
| `violet` | `#4511DF` | 8.75 / 1.97 → white | `#7950F2` | 4.95 / 3.48 → white |
| `green` | `#3BB451` | 2.68 / 6.42 → dark | `#40C057` | 2.36 / 7.29 → dark |

New for `blue` and `red` only — green, yellow and teal already had dark
labels, violet keeps white. Blue was a literal 4.15 tie and fell to
white on the tiebreak; it is now decisively dark. Since `blue` is the
default `primaryColor`, **this changes the library's default button.**

Accepted deliberately. **White on Mantine's true `blue.6` is 3.56:1 and
fails AA for body text** — so Mantine's own filled buttons do not clear
AA with white labels, and the distorted palette had been hiding it. The
cost is honest and worth stating: Plinth's filled buttons now look
unlike Mantine's at the moment the palette finally matches Mantine's.

The same `readableOn` correction made alert titles drift toward muddy —
filed as [PR-17](#pr-17--decide-the-contrast-floor-for-headings-on-tinted-surfaces)
rather than fixed here.

## Summary

| ID | Requirement | Package | Priority | Status |
|---|---|---|---|---|
| [PR-01](#pr-01--a-semantic-token-tier) | A semantic token tier | core | **Blocker** | **Done** |
| [PR-02](#pr-02--publish-the-ramp-generator) | Publish the ramp generator | core | **Blocker** | **Done** |
| [PR-03](#pr-03--anchor-a-supplied-brand-colour) | Anchor a supplied brand colour | core | **High** | **Done** |
| [PR-04](#pr-04--a-categorical-series-palette) | A categorical series palette | core | **High** | **Done** |
| [PR-05](#pr-05--a-wash-role-that-survives-dark-mode) | A `wash` role that survives dark mode | core | **High** | **Done** |
| [PR-06](#pr-06--readableons-default-floor-is-wrong) | `readableOn`'s default floor is wrong | core | **High** | **Done** |
| [PR-07](#pr-07--a-spacing-scale-for-dense-ui) | A spacing scale for dense UI | core | **High** | **Done** |
| [PR-08](#pr-08--reconcile-with-materials-colorscheme) | Reconcile with Material's `ColorScheme` | core | **Medium** | **Done** |
| [PR-09](#pr-09--separate-the-app-and-component-ramp-namespaces) | Separate app and component ramp namespaces | core | **Medium** | **Done** |
| [PR-10](#pr-10--themedataplinth) | `ThemeData.plinth` | core | **Low** | **Done** |
| [PR-11](#pr-11--make-lerp-real-or-say-it-isnt) | Make `lerp` real, or say it isn't | core | **Low** | **Done** |
| [PR-12](#pr-12--showon-for-messenger-backed-apis) | `showOn` for messenger-backed APIs | components | **High** | **Done** |
| [PR-13](#pr-13--a-numerals-stay-ltr-primitive) | A "numerals stay LTR" primitive | components | **Medium** | **Done** |
| [PR-14](#pr-14--path-dependencies-are-unusable) | Path dependencies are unusable | both | **Medium** | **Done** |
| [PR-15](#pr-15--a-migration-guide-for-the-const-and-context-tax) | A migration guide for the `const`/context tax | docs | **Medium** | **Done** |
| [PR-16](#pr-16--the-built-in-palette-is-not-mantines) | The built-in palette is not Mantine's | core | **High** | **Done** |
| [PR-17](#pr-17--decide-the-contrast-floor-for-headings-on-tinted-surfaces) | Contrast floor for headings on tinted surfaces | components | **Medium** | **Done** |
| [PR-19](#pr-19--plinthtext-resolves-contrast-against-the-wrong-background) | `PlinthText` resolves contrast against the wrong background | components | **High** | Open |
| [PR-18](#pr-18--the-series-palette-is-unverified-for-colour-vision-deficiency) | Series palette unverified for colour-vision deficiency | core | **Medium** | **Done** |

---

## Core: the token layer

### PR-01 — A semantic token tier

**`PlinthTheme` must let an app name a colour by role, not only by hue.**

*Evidence.* A finance app does not think in "red shade 6"; it thinks in
*expense* and *income*. To migrate 91 hardcoded colours the app had to
write `lib/theme/app_tokens.dart` — 110 lines of ramp anchors, semantic
getters, and resolvers — which is a design-token layer sitting on top of
a design-token package.

It worked **only** because `colors` accepts arbitrary string keys, so
semantic names could be smuggled in as ramps. That is an accident, not
an API: nothing documents it, nothing validates it, and it collides with
the component namespace (see [PR-09](#pr-09--separate-the-app-and-component-ramp-namespaces)).

*Shape.* A declared semantic map alongside `colors`, resolving a role
name to a ramp key plus a shade, so `theme.semantic('expense')` is a
first-class lookup. The app's own tier is a working prototype of what
this needs to cover: **three roles per pole** — a fill, a text variant
that clears a contrast floor, a wash — and nothing else. Seven of the
ten shades in each ramp were never read.

*Priority.* **Blocker.** This is the single largest gap the whole
exercise found.

> **Done.** `PlinthSemanticColor(ramp, {shade = 6, level})` declared in
> a `semanticColors` map alongside `colors`, with the three roles the
> app actually read as first-class lookups: `semantic()` (fill),
> `semanticText()` (clears the role's contrast floor), `semanticWash()`.
> The floor is **per role** rather than per call, because it is a fact
> about the content — a heading-only role can honestly sit at
> `PlinthContrast.large` and a table cell cannot.
>
> Two notes on what this does and does not close:
>
> - **The namespace half of [PR-09](#pr-09--separate-the-app-and-component-ramp-namespaces)
>   comes free.** Roles live in their own map, so an app declaring
>   `expense` no longer has to spend the `red` key that
>   `plinth_components` hardcodes in 12 places. What remains open in
>   PR-09 is the *ramp* collision — two apps still share one `colors`
>   namespace with the library.
> - **It does not retire the app's `app_tokens.dart` on its own.**
>   The roles resolve against a ramp, and
>   [PR-03](#pr-03--anchor-a-supplied-brand-colour) is still what makes
>   a supplied brand colour come back out of that ramp unchanged. Until
>   then an adopter declares roles but still gets a normalised hue —
>   the same closes-less-than-expected shape PR-02 hit.

### PR-02 — Publish the ramp generator

**`_generateShades` must be public.**

*Evidence.* An app supplying its own brand colour cannot reach the
function that built the library's own palette. The migration copied the
algorithm — both constant tables and the HSL loop — verbatim into the
app, because there was no other way to produce a ten-shade ramp from
`#FF3B30`.

Copied code does not track upstream fixes. If the curve is ever tuned,
every app that did this silently diverges.

*Shape.* `PlinthTheme.rampFrom(Color base)`, or a top-level
`plinthRamp(Color)`. It is already written and already tested; it just
has an underscore on it.

*Priority.* **Blocker**, and among the cheapest fixes here.

> **Done — and it does not go as far as it looked like it would.**
> `generateShades` is public, but it still normalises onto fixed stops
> rather than anchoring, so the app **could not delete its copy**.
> [PR-03](#pr-03--anchor-a-supplied-brand-colour) is what actually
> retires it. Worth recording: publishing the function was the obvious
> fix and it closed less than expected.

### PR-03 — Anchor a supplied brand colour

**Feeding a colour to the generator and asking for shade 6 must return
that colour.**

*Evidence.* It does not. The lightness stops are absolute, so a base
colour is normalised onto the curve rather than anchored to it:

| Input | `_generateShades(x)[6]` | Nearest shade | RGB error at best |
|---|---|---|---|
| `#FF3B30` | `#F00D00` | `[5]` | 30.4 |
| `#34C759` | `#32BE55` | `[6]` | 10.0 |
| `#FF9500` | `#F08C00` | `[6]` | 17.5 |
| `#AF52DE` | `#9326C9` | `[5]` | 22.3 |
| `#2E7D32` | `#40AF46` | `[8]` | 9.3 |

The best-matching index isn't even consistent — 5, 6, 7 or 8 depending
on hue — so there is no shade a caller can reliably ask for. The app had
to write a re-anchoring curve that shifts the stops so shade 6 is exact,
tapering to zero at both ends to keep shade 0 a usable tint.

This matters more than it looks: shade 6 is what every Plinth component
defaults to, so "my brand colour" and "what a filled button paints" are
guaranteed to differ.

*Shape.* Anchor the supplied colour at its role shade and derive the
rest around it. The app's taper is one approach; any is better than
none.

*Priority.* **High.**

> **Done, and it took the built-in palette with it — see
> [PR-16](#pr-16--the-built-in-palette-is-not-mantines).**
>
> Implemented as a piecewise rescale rather than the app's taper. Each
> side of the anchor is rescaled independently: shades 0–6 map the
> stop curve onto `[base, stop0]` and shades 6–9 onto `[stop9, base]`.
> **Both endpoints are held**, so shade 0 stays a usable tint and shade
> 9 a usable dark, and only the interior stretches.
>
> Rescaling was chosen over shifting because it keeps the ramp
> monotonic *by construction* for any base colour. A taper cannot
> promise that — a near-white base shifts shade 1 past shade 0. Where
> the base sits outside an endpoint (near-white, near-black) the
> endpoint widens instead of the anchor moving, so `[6] == base` holds
> even in the degenerate case, at the cost of a spread the colour
> cannot have anyway.
>
> Only lightness needed anchoring: hue was already carried through and
> `saturationMultipliers[6]` was already `1.0`.
>
> **This retires the app's copied generator**, which is what PR-02 was
> supposed to do and could not.

### PR-04 — A categorical series palette

**There must be a way to ask for the *n*th distinguishable colour.**

*Evidence.* **36 of the app's 91 hardcoded colours — 40% — were chart
series**, and they were the hardest 36 to migrate. Three
`const Map<String, int>` palettes (asset class, geography, look-through
exposure) plus `categoryColor()` plus `NamedAmount.color`, keyed by
domain concept: `'il'`, `'us'`, `'emerging'`, `'crypto'`, `'gold'`,
`'Groceries'`, `'Transport'`.

They needed **five hues that appear nowhere in the semantic palette** —
`#FF2D55`, `#007AFF`, `#5856D6`, `#30B0C7`, `#5AC8FA` — chosen for one
property only: adjacent slices must be tellable apart. That is neither
a brand ramp nor a status colour, and `plinth_core` has no concept for
it. Thirteen named brand ramps answer a different question.

*Shape.* An ordered categorical sequence with a separation guarantee —
`theme.series(i)` — plus a documented way to register a domain-keyed
one. Note the constraint the app hit: the engine layer is pure Dart and
must not import a theme, so the resolvable unit has to be a **name**
the widget layer looks up, not a `Color` the engine picks.

*Priority.* **High**, and the largest single category of hardcoding
that survived the migration.

> **Done**, then **revised by
> [PR-18](#pr-18--the-series-palette-is-unverified-for-colour-vision-deficiency)**,
> which found the first sequence unusable for colour-blind readers and
> changed both the API and the default. What follows describes the
> shipped result.
>
> `seriesColors` (an ordered list of `PlinthSeriesColor` — a ramp plus a
> shade) and `seriesKeys` (domain key → position), read through
> `series(i)`, `seriesFor(key)` and `seriesIndexFor(key)`.
>
> **The default sequence was chosen by measurement, not taste** — and
> the first measurement was the wrong one. PR-04 optimised for normal
> vision alone and got 30.5 minimum pairwise ΔE; PR-18 showed that same
> sequence scores 2.3 under tritanopia. The shipped default is scored
> across both themes and four vision types at once: **13.5 worst pair,
> 33.1 worst neighbours.** `gray` is excluded from both sequences,
> because a neutral among the series makes one look disabled.
>
> **The name-not-colour constraint is honoured.** `seriesFor(String)` is
> the API, so a pure-Dart engine layer emits `'crypto'` and the widget
> layer resolves it — nothing has to import a theme to pick a colour.
>
> Two limits, both deliberate and both tested:
>
> - **The hash is a floor, not a solution.** An unregistered key
>   resolves deterministically (explicit FNV-1a, not `hashCode`, which
>   Dart does not promise to keep stable across runs) so a chart does
>   not reshuffle on restart. But ten positions and an unbounded key
>   space collide by pigeonhole, and not hypothetically: **`'groceries'`
>   and `'transport'` both land on 0.** Any set of categories shown
>   together must be registered.
> - **Colour-vision deficiency is now covered**, which it was not when
>   this requirement first closed. See
>   [PR-18](#pr-18--the-series-palette-is-unverified-for-colour-vision-deficiency)
>   for what the gap turned out to be.

### PR-05 — A `wash` role that survives dark mode

**A subtle background tint must not invert into a saturated panel.**

*Evidence.* `shaded(name, 0)` is the obvious way to get a wash. It is
wrong in dark mode: `shadeFor` mirrors 0 → 9, turning the *lightest*
shade into the *most saturated*.

| | Light | Dark |
|---|---|---|
| `shaded('income', 0)` | `#F2F8F3` — correct | `#245B2E` — a saturated green panel |
| Alpha-over-surface (what the app does) | `#EFFBF2` | `#1C2923` |

Mirroring preserves a shade's *role* only for foregrounds. For a wash
the role is "barely distinguishable from the surface", and mirroring
inverts exactly that. The app hand-wrote `_wash()`, compositing the
ramp colour over `surface` at 8%.

*Shape.* A `wash(name, {double alpha})` role that composites over
`surface` rather than indexing the ramp. Ship it with the assertion the
app now uses as a test: a wash must stay under 1.5:1 against its
surface.

*Priority.* **High** — the wrong answer is the obvious one.

> **Done.** `PlinthTheme.wash(name, {alpha})`. The app deleted its
> hand-rolled `_wash` and its palette snapshot did not move a single
> value — which is the check that the upstream version matches what the
> app had worked out for itself.

### PR-06 — `readableOn`'s default floor is wrong

**The default `minRatio: 3.0` silently gives large-text contrast to body
text.**

*Evidence.* `readableOn` is the strongest thing in the package — it
found and fixed three WCAG failures the app had been shipping unnoticed
(income 2.22:1, warn 2.20:1, caution 1.51:1), with no per-colour tuning.

But 3.0 is WCAG's *large text* threshold. The app's figures are ₪
amounts in 13px table cells — body text, which needs 4.5. At the
default, **six of seven tokens landed in "large text only"** and only
`info` cleared AA, by accident. The obviously-correct call site,
`readableOn(name, surface)`, gets the wrong floor and says nothing.

Passing 4.5 explicitly fixes all seven in both themes, so the ramps are
deep enough — the default is the whole problem.

*Shape.* Either default to 4.5 with an opt-out, or replace the bare
number with a named role (`PlinthTextRole.body` / `.large` /
`.nonText`) so the choice is made rather than inherited. A bare `double`
is a parameter callers leave alone.

*Related:* the same 3.0 applies to non-text UI (WCAG 1.4.11), and the
app's *fills* — income, warn, caution — are at 2.22, 2.20 and 1.51
against white. Wherever a fill carries meaning alone (a chart bar, a
legend dot), it is currently below the line. A role-based API would
make that expressible too.

*Priority.* **High.** The failure mode is not noticing.

> **Done, with one thing learned.** `PlinthContrast.body` (4.5) is the
> new default; `.large` and `.nonText` name the other floors; an
> explicit `minRatio:` still overrides.
>
> But raising it globally is **too blunt**. On a *tint* background in a
> dark theme, walking to 4.5 lands on near-white and the accent stops
> reading as its colour: `cyan #90DFEA → #F0F8F9`, `teal → #F0F9F7`.
> 19 of 26 ramp/background pairings moved in light, 11 of 26 in dark.
> `plinth_components` now pins its four `PlinthVariant.light` pairings
> to `.large`, so that variant is unchanged.
>
> The underlying tension is real and still open: a same-hue label on a
> same-hue tint cannot be both AA and recognisably that hue.

### PR-07 — A spacing scale for dense UI

**The scale starts one step too coarse.**

*Evidence.* Across the app's own widget code:

| | Hardcoded literals | `plinth.*` token uses |
|---|---|---|
| Spacing (`SizedBox`, `EdgeInsets`) | 355 | **0** |
| Radius (`BorderRadius.circular`) | 15 | **0** |

Zero out of 370, and not from indifference:

| | App's actual values | `plinth_core` offers |
|---|---|---|
| Spacing | **4** (29×), **6** (17×), **8** (128×), 12 (92×), 16 (24×) | 10, 12, 16, 20, 32 |
| Radius | 2, **3**, **6**, 8, **10** | 2, 4, 8, 16, 32 |

**The two most-used values, `8` (128 uses) and `4` (29 uses), do not
exist in the scale**, which starts at `xs: 10`. Mapping `8 → xs(10)`
moves 128 gaps by 2px each: not a migration, a restyle. Radius is the
same — `3`, `6` and `10` have no token, while `4`, which Plinth offers,
the app never uses.

*Shape.* Add steps below 10 (`2xs: 4`, `xs: 8`, renumbering upward), or
accept that the scale is for marketing-density layouts and say so. It
was inherited from Mantine, which targets exactly that.

*Priority.* **High.** Until this lands, component tokens built on the
scale are unusable for the same reason — do not build them first.

> **Done, and the evidence got worse on inspection.** The library is not
> merely missing steps an app wanted: **80 of its own 87 spacing
> multipliers resolve below 10**. `spacing[PlinthSize.xs]! * 0.4` (38
> uses) is 4px; `* 0.8` (8 uses) is 8px. It has been rebuilding a
> sub-`xs` scale out of fractions of a 10 base, producing an accidental
> {3,4,5,6,7,8}. The roadmap already calls these "hand-rolled `calc()`";
> the sharper reading is that they are a **missing scale**, not a
> missing unit system.
>
> Shipped as `PlinthSpacing` **constants** on a 4px base, not a theme
> lookup — applying it to 314 sites is what showed why. A lookup needs a
> `BuildContext`, so it would have traded 314 `const` widgets for
> runtime ones to express a value that does not vary by theme.
> `PlinthTheme.space(steps)` covers runtime multiples.
>
> The grid covered **314 of 353** literals. The 39 that missed cluster
> on half-steps (`6` ×20, `2` ×10, `10` ×8) — either a missing 2px
> sub-unit, or drift worth normalising.

### PR-08 — Reconcile with Material's `ColorScheme`

**The need is not `toThemeData()`. It is agreement.**

*Evidence.* `toThemeData()` is the roadmap's top-ranked task and was
**never reached for** during migration. The app's hand-written
`ThemeData` is six lines and worked; replacing it wholesale is riskier
than the six lines it saves.

What is actually broken is that the app now reads colour from two
systems at once:

| Source | Lookups |
|---|---|
| `plinth.*` tokens | 58 |
| Material `colorScheme.*` | 31 |
| Material `textTheme.*` | 80 |
| `plinth.fontSizes` | **0** |
| `plinth.surface` / `text` / `border` / … (11 chrome fields) | **0** |

`colorScheme.error` — Material's red, from the seed — sits in the same
tables as `plinth.expense`, the app's red. Nothing keeps them in
agreement. Meanwhile **11 of `PlinthTheme`'s 19 fields went entirely
unread**, because Material's `ColorScheme` already answers those
questions.

*Shape.* A bridge that derives a `ColorScheme` *from* the Plinth palette
(or validates that an existing one agrees), and the same for
`textTheme`/`fontSizes`. Shipping `toThemeData()` as a convenience
constructor will be ignored by the audience it was written for.

*Priority.* **Medium** — but it should displace `toThemeData()` in the
roadmap rather than sit beside it.

> **Done**, and it displaced `toThemeData()` rather than sitting beside
> it — `A8` in [POST_1_0_ROADMAP.md](POST_1_0_ROADMAP.md) is struck out
> and `A8'` is this.
>
> Shipped as an extension, `PlinthMaterialBridge`, in both directions:
>
> - **`colorSchemeDisagreements(scheme)`** — keep your own `ThemeData`
>   and get a list of where the two disagree. This is the half the
>   migration actually wanted: assert it is empty in a test and the
>   drift cannot come back silently.
> - **`toColorScheme()` / `toTextTheme({base})`** — derive Material's
>   types from Plinth, for an app willing to hand over the decision.
>
> **The scope of "agreement" is stated rather than implied.** Plinth has
> no opinion about `secondary`, `tertiary`, the container roles or the
> inverse roles, so `toColorScheme` takes those from
> `ColorScheme.fromSeed` and the checker ignores them —
> `ownedSchemeFields` names the ten it does decide. Reporting a
> disagreement about a field Plinth never had a view on would train
> people to ignore the list.
>
> Same discipline on type: `fontSizes` runs 12 to 20, so `toTextTheme`
> fills the body, title and label roles and **leaves `headline` and
> `display` exactly as the base had them** rather than inventing a
> number for them.
>
> `error` maps to the `red` ramp because `plinth_components` already
> hardcodes `shaded('red', …)` for destructive state in 12 places — red
> was the error ramp whether or not anyone declared it.
>
> Comparison is exact, deliberately. A tolerance would decide for the
> caller how much drift is acceptable, which is the judgement this
> exists to surface rather than make.

### PR-09 — Separate the app and component ramp namespaces

**`colors` is shared between the library and its consumer, and neither
knows.**

*Evidence.* `plinth_components` hardcodes `shaded('red', …)` in 12
places, `shaded('gray', …)` in 3, `shaded('green', …)` in 1. So `red`
is already spoken for as the destructive/error ramp.

An app that repurposes `red` as its expense pole silently restyles every
component error state. An app that doesn't ends up with two different
reds on screen — which is what happened here, and is now visible as
`colorScheme.error` sitting beside `plinth.expense`.

*Shape.* Either reserve the component-facing keys explicitly (and let
apps register into a separate namespace), or let components take their
role ramps from a configurable mapping so `error` can point wherever the
app wants.

*Priority.* **Medium.** Falls out naturally if [PR-01](#pr-01--a-semantic-token-tier) is done properly.

> **Done**, in two halves and only half of it fell out of PR-01 as
> predicted.
>
> PR-01 gave the *app* its own namespace (`semanticColors`), which
> stopped role names being smuggled in as ramps. It did **not** stop the
> library reaching into `colors` for `'red'`, `'gray'` and `'green'` —
> so the collision that actually bit remained.
>
> This closes it with the second shape the requirement offered: a
> configurable role mapping. `PlinthRole { error, neutral, success }` —
> the three the library genuinely uses — resolved through `roleRamps`,
> read with `rampFor(role)` and `roleShaded(role, shade)`.
>
> **The counts in the evidence above were stale**, which is worth
> recording since they were the basis for calling this Medium. Measured
> again at the time of the fix: **31 `error` sites** (13 theme lookups
> plus 18 `color: 'red'` props), **26 `neutral`**, and **1 `success`** —
> not 12/3/1. `error` alone is every form field's border *and* its
> message.
>
> **53 call sites swept, and the defaults are unchanged**, so this is
> value-preserving by construction: `kDefaultRoleRamps` maps
> `error → red`, `neutral → gray`, `success → green`, exactly what the
> widgets hardcoded. A test asserts equality across all three roles and
> all ten shades in both themes, and no golden moved.
>
> A partial map falls back per role rather than blanking the rest —
> `copyWith(roleRamps: {error: 'pink'})` replaces the whole map, so
> without the fallback every muted description in the library would
> have gone primary-coloured.
>
> [PR-08](#pr-08--reconcile-with-materials-colorscheme)'s bridge was
> corrected as part of this: it had hardcoded `shaded('red', 6)` for
> `ColorScheme.error` the same way, one commit earlier. It now follows
> the role, so remapping moves Material's error colour with it.

### PR-10 — `ThemeData.plinth`

**`context.plinth` is the only accessor, and it isn't always available.**

*Evidence.* Helpers written the idiomatic Flutter way already receive
the theme:

```dart
Widget _homeBadge(ThemeData theme, bool residence, bool he) { … }
```

Such a helper holds everything it needs and still cannot reach the
tokens — it has to grow a `BuildContext` parameter, which then ripples
to every call site. Seven helpers in this app took that change.

*Shape.* `extension on ThemeData { PlinthTheme get plinth => … }`. One
line.

*Priority.* **Low**, trivially cheap.

> **Done.** One extension, four lines.

### PR-11 — Make `lerp` real, or say it isn't

**`PlinthTheme.lerp` snaps at the midpoint.**

*Evidence.* Straight from the source:

```dart
// Colors/spacing maps aren't meaningfully lerped key-by-key here;
// snap at the midpoint.
return t < 0.5 ? this : other;
```

Any app animating a theme transition gets a hard cut halfway through
rather than a cross-fade. This app never noticed, because it toggles
theme instantly — but that is luck, not design.

*Shape.* Per-key `Color.lerp` for the chrome fields and ramps, or a
documented statement in the class doc that theme transitions are not
animated. Both are acceptable; the current silence is not.

*Priority.* **Low.**

> **Done — made real, not documented away.** Chrome colours, ramp shades
> and the numeric scales (`spacing`, `radius`, `fontSizes`) all
> interpolate.
>
> **What still snaps, and why it is not a shortcut:** `brightness`,
> `primaryColor`, `defaultRadius` and the four lookup maps
> (`semanticColors`, `roleRamps`, `seriesColors`, `seriesKeys`). There is
> no half-step between two brightnesses or two ramp *names*, so these
> change over at the midpoint.
>
> **One consequence is worth knowing rather than discovering, and it
> hits the most common transition there is.** `defaultTheme` and
> `darkTheme` **share the same ramp map** — a light versus dark palette
> colour differs only through `shadeFor` mirroring, which follows
> `brightness`. So on a light↔dark toggle the chrome cross-fades
> smoothly while palette colours still change over at the midpoint.
> Documented on `lerp` itself and pinned by a test, so the doc comment
> cannot quietly become a lie.
>
> That same sharing gives the fast path its point: `_lerpRamps`
> short-circuits on `identical`, so the commonest transition never
> rebuilds 13 ten-colour lists per frame. A test asserts the sharing
> holds, because if it ever stops the optimisation is dead and nobody
> would notice.
>
> Proven end to end rather than at the unit: a widget test pumps a
> `MaterialApp` through a theme change and asserts a frame 100 ms in is
> **neither** endpoint. Under the old `t < 0.5 ? this : other` it would
> always have been one of them.

### PR-16 — The built-in palette is not Mantine's

**The ramps are seeded with Mantine's published shade-6 values and none
of them survived the generator.**

*Evidence.* Found while implementing
[PR-03](#pr-03--anchor-a-supplied-brand-colour), not during the
migration — this one is a defect in the library rather than a gap an
adopter hit, and it is recorded separately for that reason.

`defaultTheme` seeds each ramp with the corresponding Mantine `.6`
value. Asking for shade 6 back returned something else every time:

| Ramp | Seed (Mantine `.6`) | `generateShades(seed)[6]` before |
|---|---|---|
| `red` | `#FA5252` | `#E90707` |
| `violet` | `#7950F2` | `#4511DF` |
| `blue` | `#228BE6` | `#187FD7` |
| `gray` | `#868E96` | `#6F7880` |
| `green` | `#40C057` | `#3BB451` |
| `yellow` | `#FAB005` | `#EBA505` |

So "Mantine-inspired, on Mantine's palette" — which the README and both
pubspec descriptions claim — was not true of the rendered colours. The
distortion is worst on `red` and `violet`, the two most saturated seeds,
and it ran in the same direction every time: **darker and more
saturated than Mantine.**

*Consequence beyond the mismatch.* The over-darkening was masking a real
accessibility fact. Mantine's true `red.6` is ~3.6:1 on white and does
not clear the body-text floor; the old ramp's `#E90707` did, so
`readableOn` had nothing to correct. With the palette fixed,
`readableOn` now does the work [PR-06](#pr-06--readableons-default-floor-is-wrong)
built it for. A component test asserting `color('red', 6)` had been
passing on that accident.

*Shape.* Closed by PR-03's anchoring — no separate change. Pinned by a
test asserting all 13 ramps against Mantine's published values, so this
cannot drift again silently.

*Priority.* **High.** A palette claim in published package metadata that
the code does not honour.

> **Done.** All 13 ramps now return their Mantine seed at shade 6
> exactly, pinned per-ramp in `plinth_adoption_test.dart` with a guard
> asserting the ramp list itself is fully covered.

### PR-18 — The series palette is unverified for colour-vision deficiency

**`kDefaultSeriesRamps` guarantees separation in trichromatic vision
only.**

*Evidence.* Raised by building
[PR-04](#pr-04--a-categorical-series-palette), and recorded rather than
quietly shipped. The ten-ramp sequence is optimised for minimum
pairwise CIE76 ΔE, computed in sRGB with no CVD simulation. Its warm
run — `red`, `yellow`, `orange` — is precisely the cluster that
collapses under deuteranopia and protanopia, which together affect
roughly 8% of men.

A categorical palette whose entire purpose is "these are tellable
apart" that is not tellable apart for 1 in 12 male readers is failing
at its one job, for those readers.

*Shape.* Simulate the common deficiencies (Brettel or Viénot is enough
— this does not need to be perfect to be useful), re-score the subset
and ordering under each, and either find a sequence that holds up
across all of them or ship a second named sequence and say plainly
which is which. **The scoring harness from PR-04 already exists;** what
is missing is the simulation step in front of it.

Worth settling as part of it: whether the default should be the
CVD-safe sequence outright. Optimising for the 92% by default is a
choice, not a neutral starting point.

*Priority.* **Medium.** Nothing is broken for most readers, and the
escape hatch exists — an app can pass its own sequence today.

> **Done, and the worry was an understatement.** Simulating the three
> dichromacies (Viénot–Brettel–Mollon 1999) and re-scoring PR-04's
> sequence:
>
> | View | min pairwise ΔE | closest pair |
> |---|---|---|
> | normal | 30.5 | yellow / orange |
> | deuteranopia | 6.6 | teal / pink |
> | protanopia | **3.3** | lime / yellow |
> | tritanopia | **2.3** | indigo / cyan |
>
> **2.3 is roughly the just-noticeable difference.** Two of the ten
> series were not two colours for a reader with tritanopia. A
> categorical palette whose one job is separation was failing that job
> completely, not marginally.
>
> **No sequence of ten ramps at a fixed shade can fix it.** The best
> ten-subset available scores 4.0 in the worst case — the twelve ramps
> were chosen for hue spread, and hue is the channel dichromats lose.
>
> **Letting the shade vary is what fixes it**, because lightness is the
> channel that remains. That needed an API change, and `seriesRamps`
> (`List<String>`) became `seriesColors`
> (`List<PlinthSeriesColor>`, a ramp plus a shade). **Free of charge:**
> PR-04 shipped on this branch and was never published, so nothing
> depends on the old shape.
>
> The new default is scored across **eight contexts** — both themes ×
> four vision types, because `shadeFor` mirroring means the dark theme
> is a different set of colours and had to be optimised jointly:
> **13.5 worst pair, 33.1 worst neighbours.**
>
> **The default is now the CVD-safe sequence**, which settles the
> question this requirement raised. It is not a close call once
> measured: the vivid sequence is better for typical colour vision
> (30.5 against 19.9, both far above any threshold) and *broken* for
> everyone else (2.3). Trading comfortable for still-comfortable to
> move broken to working is not a trade-off so much as a bug fix. The
> old sequence survives as `kVividSeriesColors` for callers who know
> their audience or whose series carry redundant labels.
>
> The simulation is **reimplemented in the test suite**, not just used
> once to pick values, so the guarantee is asserted on every run rather
> than being a number somebody wrote down.

### PR-17 — Decide the contrast floor for headings on tinted surfaces

**An alert title is a heading, and it is being held to the body-text
floor.**

*Evidence.* Found while reviewing the goldens PR-03 moved — like PR-16,
a defect surfaced by fixing the palette rather than a gap an adopter
hit.

With the ramps corrected, `readableOn` has real work to do, and it does
it uniformly at 4.5:1. On the low-luminance ramps that walks a title a
long way from brand:

| Alert | Title before | Title after |
|---|---|---|
| `yellow` | mid amber | dark olive-brown |
| `red` | bright red | deep red |

The colour is correct and the *reading* of it is the question: WCAG's
4.5 floor is for body text, and 3.0 (`PlinthContrast.large`) applies at
~18pt regular / ~14pt bold. An alert title is rendered larger and
bolder than the body beneath it, so it plausibly qualifies — which
would keep it recognisably the alert's colour.

This is the same call already made for `PlinthVariant.light` during
PR-06, where four components pin `large` explicitly because a same-hue
label on a same-hue tint cannot reach 4.5 and stay that colour. The
question is whether alert and notification titles belong in that set.

*Shape.* Audit which components render text that is a *heading* rather
than body, and pin those to `PlinthContrast.large`. Do not do it by
component — do it by what the text is, and record the ones deliberately
left at `body`.

Two things to settle rather than assume:

- **Measure the actual rendered size** before claiming `large`. The
  floor is defined by pt size and weight, not by the word "title", and
  a title that does not clear ~18pt regular / ~14pt bold does not
  qualify however heading-like it looks.
- **`nonText` (3.0) may be the right answer for icons** in the same
  banners, which is a separate judgement from the title.

*Priority.* **Medium.** Visible, and wrong in the safe direction — the
current colours are over-corrected rather than illegible.

> **Done, and the premise was wrong.** The requirement said to measure
> before claiming `large`. Measuring says an alert title does **not**
> qualify, and says something worse about the icon beside it.
>
> **WCAG's large-text floor is ≥18pt regular or ≥14pt bold** — 24px and
> 18.67px in logical pixels. Against that:
>
> | Text | Size / weight | Large? |
> |---|---|---|
> | `PlinthTitle` order 1 | 34px w700 | **yes** |
> | `PlinthTitle` order 2 | 26px w700 | **yes** |
> | `PlinthTitle` order 3 | 22px w700 | **yes** |
> | `PlinthTitle` order 4 | 18px w600 | no — short on both readings |
> | `PlinthTitle` order 5 | 16px w600 | no |
> | `PlinthTitle` order 6 | 14px w600 | no |
> | Alert / notification title | **16px w700** | **no** — 2.67px short |
>
> So the muddy alert titles are **correct**, not over-corrected, and
> nothing about them changed. `PlinthTitle` now picks its floor from the
> measurement rather than from the word "title": orders 1–3 take
> `large`, 4–6 keep `body`.
>
> **The icons were the real defect, and in the opposite direction to
> what this requirement guessed.** They were not over-corrected — they
> were not corrected at all, painted at a raw `shaded(color, 6)`.
> Against the alert's own tinted background, **7 of 13 ramps failed WCAG
> 1.4.11's 3:1**: yellow at **1.74:1**, lime 1.91, green 2.19, teal
> 2.38, cyan 2.59, red 2.94. Both banner icons now resolve through
> `readableOn(..., level: PlinthContrast.nonText)` against what is
> actually behind them.
>
> **Icons elsewhere were deliberately left alone.**
> `PlinthActionIcon`, `PlinthThemeIcon` and `PlinthCloseButton` already
> resolve at `body` (4.5). Loosening them to `nonText` would trade
> contrast for brand fidelity with no accessibility gain — over-
> correcting an icon is safe, under-correcting is not. Tighten where
> failing; do not loosen where passing.
>
> One thing this surfaced about [PR-11](#pr-11--make-lerp-real-or-say-it-isnt):
> a widget test that swaps the theme extension between pumps is now
> **mid-transition** unless it settles, so `context.plinth` holds a
> lerped theme. The first draft of this requirement's test failed for
> exactly that reason. Worth knowing before writing any test that
> compares two themes in one tree.

---

## Components

### PR-12 — `showOn` for messenger-backed APIs

**`PlinthNotification.show` requires a live `BuildContext`, and the
standard async idiom doesn't have one.**

*Evidence.* The Flutter pattern for feedback after an `await` is to
capture the messenger *before* it, precisely so no context is needed
afterwards:

```dart
final messenger = ScaffoldMessenger.of(context);   // before
await store.applyImport(…);
messenger.showSnackBar(…);                         // after — no context
```

The app had **13 such captures**. Every one had to be deleted and
replaced with an `if (!context.mounted) return;` guard, because `show`
accepts only a context.

That is a **behaviour change, not just a rewrite**: the old code still
showed its message after the widget went away; the new code silently
drops it. For "import finished" that is arguably better — it should
still be the app's choice, not a consequence of the signature.

*Shape.* `PlinthNotification.showOn(ScaffoldMessengerState, …)`. `show`
already does `ScaffoldMessenger.of(context)` internally, so the
messenger-taking form is the more primitive of the two and costs a few
lines. Apply the same to any future `show`-style API.

*Priority.* **High** for anything overlay-shaped.

> **Done.** `PlinthNotification.showOn(ScaffoldMessengerState, …)`, with
> `show(context, …)` now delegating to it — so the messenger-taking form
> is the primitive and the context-taking one is a lookup in front of
> it, as the shape above called for.
>
> `PlinthNotification.show` was the **only** messenger-backed API in the
> library, so "apply the same to any future `show`-style API" has
> nothing else to apply to today. The modal and drawer overlays go
> through `Navigator`/`OverlayEntry` and a `PlinthDisclosureController`
> rather than a messenger, which is a different problem.
>
> The behaviour difference is what the tests pin, not just the
> signature: one shows a notification from a captured messenger **after
> the originating widget has been disposed**, which is exactly the case
> `show(context, …)` cannot express and the `context.mounted` guard
> silently drops. Another asserts `show` and `showOn` build an identical
> `PlinthNotification`, so the delegation cannot drift.

### PR-13 — A "numerals stay LTR" primitive

**Every bidirectional app hand-rolls the same wrapper.**

*Evidence.* This app writes it by hand:

```dart
Directionality(
  textDirection: TextDirection.ltr,   // cashflow_page.dart
  child: CustomPaint(painter: _BarsPainter(…)),
)
```

Charts, currency, and time axes must stay LTR inside an RTL page. Only
3 of the 115 component files touch `Directionality` at all, and
`plinth_number_formatter` — the component most obviously about
numerals — does not mention `TextDirection` anywhere.

This is the **only** concrete RTL gap the validation found. Worth
stating plainly: the RTL prediction was that Plinth would break in
Hebrew, and it did not — 12 of 12 page × language combinations rendered
clean, and the setup wizard walks end to end at textScaler 2.0 in both
directions. The anxiety was unfounded; this one small primitive is
what's actually missing.

*Shape.* `PlinthLtr(child:)`, or a `direction` escape hatch on the
numeric widgets. Small, cheap, obviously correct.

*Priority.* **Medium.**

> **Done.** `PlinthLtr(child:)`, the first of the two shapes.
>
> The `direction` escape hatch was **not** added, deliberately. It would
> mean a flag on every numeric widget for a case the wrapper already
> covers, and the wrapper works for the thing the evidence actually
> showed — a `CustomPaint` chart, which no per-widget flag reaches.
>
> **Nothing existing was changed to use it.** The temptation was to wrap
> `PlinthNumberFormatter` and `PlinthRollingNumber` in it internally,
> and that would have been wrong: the validation found RTL already
> correct, so auto-pinning would be an unrequested behaviour change
> justified by no evidence — and it would take the *caller's* ability to
> choose away. The docs on both widgets point at the wrapper instead.
>
> Tested with a control case, because a directionality wrapper is easy
> to assert vacuously: one test checks a `Row` lays out left-to-right
> inside it, and a second checks the *same* `Row` reverses without it.
> Without the second, the first would pass even if `PlinthLtr` did
> nothing.

### PR-19 — `PlinthText` resolves contrast against the wrong background

**A colour prop is checked against the surface, wherever the text
actually sits.**

*Evidence.* Found while measuring for
[PR-17](#pr-17--decide-the-contrast-floor-for-headings-on-tinted-surfaces).

`PlinthText` resolves `readableOn(color, theme.surface)` — always the
surface, with no way to say otherwise. That is right for text on a page
and wrong everywhere else, and the library puts it everywhere else:
`PlinthAlert` renders its title with `PlinthText` on a **tinted**
background of `shaded(color, 0)`.

Measured against the background the title is really on, **3 of 13 ramps
fall below 4.5:1 in the light theme** — the contrast machinery reports
a pass while the rendered text does not clear the floor it claims.

It is a small miss, and it is the *silent* kind: everything looks
deliberate, `readableOn` was called, and the number it cleared was
against a surface the text never touches.

*Shape.* `PlinthText` needs a way to name the background it sits on —
an `on:` parameter taking a `Color`, defaulting to the surface. Then
`PlinthAlert` and `PlinthNotification` pass their own background, and
any app compositing text over a tint can do the same.

Worth deciding as part of it: whether `readableOn`'s signature should
make the background *required* rather than defaulted, so the question
cannot be skipped by accident. That is a wider breaking change and
belongs to the same conversation.

*Priority.* **High.** It is a correctness bug in the accessibility
machinery itself, which is the part most likely to be trusted without
checking.

---

## Distribution and docs

### PR-14 — Path dependencies are unusable

**An app that already uses published `plinth_components` cannot add
`plinth_core` as a path dependency.**

*Evidence.* This is the first thing the validation hit, before any Dart
was written:

```
Because financial_organizer depends on plinth_components ^0.16.1 which
depends on plinth_core ^0.2.0, plinth_core from hosted is required.
So, because financial_organizer depends on plinth_core from path,
version solving failed.
```

The only way through is `dependency_overrides`, which the packages
document nowhere. This is exactly the shape of problem a first external
adopter hits the moment they try to patch the core locally to debug
something.

*Consolation worth recording:* with the override in place,
`plinth_components 0.16.1` — compiled against `plinth_core 0.2.0` — ran
clean against `1.0.0-beta.1`. The core's API has stayed genuinely
backward compatible across a major version bump.

*Shape.* Document the `dependency_overrides` recipe in the README, and
consider whether the inter-package constraints need to be looser.

*Priority.* **Medium**, and it is a README change.

> **Done** — [README § 4. Running against a local checkout](../README.md#4-running-against-a-local-checkout).
>
> **The second half of the shape was a red herring, and it is worth
> recording as one.** "Consider whether the inter-package constraints
> need to be looser" is the natural first guess and it is wrong: pub
> permits one *source* per package in a resolution, so a path dependency
> in the app conflicts with the hosted one `plinth_components` pulls in
> **regardless of the version range**. No constraint we could write
> would fix it.
>
> Checked rather than reasoned about, because publishing a claim about
> someone else's resolver on the strength of an argument is how the
> stale counts in PR-09 happened. Three runs against a scratch app
> outside the workspace:
>
> | Setup | Result |
> |---|---|
> | `plinth_components ^1.0.0-beta.2` + `plinth_core` from path | fails, with the error quoted above |
> | same, but `plinth_core: any` from **hosted** | **resolves** |
> | same, but path moved into `dependency_overrides` | **resolves**, and the lockfile records `source: path` |
>
> The middle row is the one that settles it: the version constraint is
> at its loosest possible and it still resolves, so the source is the
> only variable that matters.
>
> The README entry also warns to remove the overrides before shipping.
> `dependency_overrides` is root-only and ignored for anyone consuming
> your package, so one that quietly became load-bearing is a bug you do
> not see until somebody else builds your code.

### PR-15 — A migration guide for the `const`/context tax

**Adopting tokens costs an app its `const` widget trees, and nothing
says so.**

*Evidence.* Every token lookup needs a `BuildContext`, so it cannot be
`const`. Migrating this app required rewriting:

- `static const _actionColors = {…}` → a method taking `PlinthTheme`
- `const TextStyle(color: Color(0xFFFF3B30))` → non-`const`
- `const Icon(Icons.delete_outline, color: …)` → non-`const`
- `Color flowColor(String flow)` → `flowColor(PlinthTheme t, String flow)`
- seven helper methods grew a `BuildContext` parameter, rippling to
  every call site
- two `CustomPainter`s grew colour constructor parameters, a painter
  having no context

None of it is hard, all of it is unavoidable, none of it is documented.

Two further items belong in the same guide:

**Colour becomes state.** Once colour comes from a theme, every
`shouldRepaint` that ignores it becomes a stale-render hazard.
`_FirePainter` already had this latent — it compared `years`,
`retireAge` and `unlockAge` but not the themed colour it already took —
and threading three more colours through made the omission live.

**A wrapper's internal guard doesn't satisfy the lint.**
`use_build_context_synchronously` cannot see through a function
boundary, so an app that wraps a Plinth `show`-style API still needs a
visible `context.mounted` check at every call site after an `await`.

*Shape.* One page: "what adopting tokens costs you", with these five
patterns and their fixes.

*Priority.* **Medium.** It converts an hour of rediscovery per adopter
into a five-minute read.

> **Done** — [ADOPTING_TOKENS.md](ADOPTING_TOKENS.md), with all five
> patterns and two things the requirement did not ask for:
>
> - **The tax is smaller than it was when this was written.**
>   [PR-07](#pr-07--a-spacing-scale-for-dense-ui) shipped `PlinthSpacing`
>   as compile-time constants, so spacing keeps its `const`. The guide
>   leads with that, because the app's **355 spacing literals** were the
>   bulk of the surface and routing them through a theme would have
>   traded 355 `const` widgets for 355 runtime ones and bought nothing.
>   The honest headline is "colour needs a context, spacing does not" —
>   not "tokens cost you `const`".
> - **Pattern 5's answer changed.** The requirement recorded that
>   `use_build_context_synchronously` cannot see through a function
>   boundary, so a wrapper still needs a visible guard.
>   [PR-12](#pr-12--showon-for-messenger-backed-apis) has since made the
>   guard unnecessary for notifications: capture the messenger before
>   the `await` and no context is involved. The guide gives that as the
>   preferred answer and explains that it is different *behaviour*, not
>   just a quieter lint.
>
> **`radius` is called out as a real remaining gap.** There is no const
> equivalent of `PlinthSpacing` for it, so `theme.radius[…]` still costs
> a context. Said plainly rather than left for an adopter to hit.
>
> The examples are **compile-checked**
> (`plinth_components/test/adopting_tokens_doc_test.dart`). A guide
> exists to be pasted from, so a stale example is worse than none — and
> this repo already has the other kind: the example app's
> `demo_code.dart` snippets are hand-maintained strings that still
> compile and still render after they drift.
>
> The guide closes on the finding that should worry an adopter most:
> **colour drift will not fail your tests.** The subject app's 202 tests
> passed before, after, and through intermediate states where the
> palette was materially different, because not one asserted on a
> colour.

---

## What this list is not

- **Not a component wishlist.** 83 of 115 components were never
  instantiated by the subject app. Their absence here means untested,
  not fine.
- **Not breadth-validated.** `checkbox` and `radio` — the most
  accessibility-sensitive widgets in the set — have no home in this app
  at all, so nothing here reflects them.
- **Not independent.** The app's author is Plinth's author. This
  validates the shape of the problems, not that a stranger would hit
  them in the same order.

## What went right

Worth recording next to the gaps, because it is the case for the whole
approach:

- **`readableOn` fixed three real WCAG failures automatically**, with
  no per-colour tuning. One argument change moved an entire app from
  three shipping failures to AA on every figure.
- **RTL did not break**, anywhere, in any combination tested.
- **The 0.20.0 rename pass cost 3 lines** across nine minor versions,
  and every break was a compile error — exactly as the changelog
  promised.
- **`PlinthStepper`'s controlled-component pattern was right.**
  `currentStep` stays owned by the caller, so it dropped into a wizard
  that already had its own step state with no restructuring at all.
- **Arbitrary keys in `colors`** are the reason the token migration
  completed rather than stopping. The extension point should be made
  deliberate ([PR-01](#pr-01--a-semantic-token-tier)) rather than removed.
