# Phase −1 findings — `plinth_core` against a real app

Results, not plan. The plan is
[ROADMAP.md § Phase −1](ROADMAP.md);
this file is what actually happened.

**Status:** run 18 Aug 2026. The experiment did **not** stop early — see
[Where it actually stopped](#where-it-actually-stopped).

## The subject

`C:\projects\flutter\financial-organizer` — a private, local-first
personal-finance app for an Israeli household. Hebrew/English with RTL,
70 Dart files, its own widgets.

Why it qualifies as audience A, measured on 18 Aug 2026 before any work:

| Trait | Measured |
|---|---|
| Own widgets | 70 Dart files |
| Theme | `ThemeData(` twice, inline in `main.dart`. **No theme file exists** |
| Hardcoded colour | **55 `Color(0x…)` literals**, zero `Colors.*` — but see below, the real figure is **91** |
| An unnamed semantic layer | `0xFFFF3B30` ×17 (expense), `0xFF34C759` ×15 (income) |
| Opacity, hand-rolled | `0x22FF9500`, `0x14FF9500`, `0x1434C759` |
| Drift | `0xFF2E7D32`, `0xFFB26A00` — matching nothing else in the palette. **One of these is not drift**, see [V-3](#v-3--do-expense--income-want-names-rather-than-hex) |

### Correction to the measurement above

`grep "Color(0x"` counts the *widget* layer only. The app also keeps colour
as bare `int` in its Flutter-free engine layer, which that pattern cannot see:

| Where | Form | Count |
|---|---|---|
| `lib/pages/*`, `lib/main.dart` | `Color(0x…)` | 55 |
| `engine/valuation.dart` | `const Map<String, int>` × 3, `NamedAmount.color` | 27 |
| `engine/categories.dart` | `categoryColor()` → `int`, `kCreditCardColor` | 9 |

**91 hardcoded colour values, not 55.** The 36 the audit missed turned out to
be the harder 36 — every one of them a *chart series* colour living in pure
Dart that must not import a theme. An audit by grep undercounts by 40% and
undercounts in the direction that matters.

## What `plinth_core` offers today

So the experiment starts from fact rather than from the roadmap's
aspirations. At `1.0.0-beta.1`, `PlinthTheme` is a `ThemeExtension`
with:

- **Fields:** `colors` (named 10-shade ramps), `primaryColor`,
  `spacing`, `radius`, `fontSizes`, `defaultRadius`, `brightness`,
  `surface`, `surfaceMuted`, `surfaceSunken`, `border`, `borderMuted`,
  `text`, `textMuted`, `textDisabled`, `onFilled`, `onFilledInverse`,
  `shadow`, `scrim`
- **Methods:** `color()`, `shaded()`, `shadeFor()`, `readableOn()`,
  `contrastingOn()`, `hasColor()`
- **Presets:** `PlinthTheme.defaultTheme`, `PlinthTheme.darkTheme`
- **Access:** `context.plinth`

**No `toThemeData()`. No semantic tier. No component tokens. No
motion, elevation, state, density or textScaler awareness.** The ramps
are shaped for a brand palette, not a two-pole expense/income one.

The experiment was expected to stop early. **Where it stops is the
result** — and it did not stop where predicted; see
[Where it actually stopped](#where-it-actually-stopped).

## Findings

One section per prediction. **Record the outcome either way** —
"predicted correctly" is a weaker finding than "predicted wrongly", and
both beat silence. Follow the audit's habit: if the gap turns out
smaller than written, record the correction rather than quietly fixing
it.

### Where it actually stopped

It didn't. All **91** hardcoded colour values were removed — 55 in the
widget layer, 36 in the engines — and the app builds, analyzes clean,
and passes its full suite (202 tests, unchanged) with **zero `0x…`
colour literals outside a single new 110-line token file**.

That is the headline, and it was not the prediction. The forecast was
that `plinth_core` would run out of road. Instead the one extension
point it does have — `colors` accepting arbitrary string keys — turned
out to be enough to carry a semantic tier that the package itself does
not define.

The cost is the finding. To get there the app had to write:

| What it had to write | Why `plinth_core` couldn't supply it |
|---|---|
| 13 ramp anchors as raw hex | No way to name a colour semantically |
| A copy of the shade-ramp generator | `_generateShades` is private and unexported |
| A re-anchoring curve on top of that copy | The generator does not round-trip a brand colour |
| 19 semantic getters | No semantic tier |
| A `_wash()` helper | Brightness mirroring destroys shade-0 tints |
| A `series()` resolver | No categorical/series palette concept |

**110 lines of app-side token layer in order to adopt a token package.**
Net change across the app's own files was **+62 / −139** over 14 files —
the migration removed more code than it added everywhere except the one
new file that reimplements the missing tier.

Verified by: `flutter analyze` clean; `flutter test` 202/202; six real
pages pumped in light and dark, `he` and `en`, at textScaler 1.0/1.3/2.0,
with `boldText`, and at 390 px width.

### Before it could start: version solving

The instructed pubspec change fails outright:

```yaml
  plinth_core:
    path: ../plinth_ui/packages/plinth_core
```

```
Because financial_organizer depends on plinth_components ^0.16.1 which
depends on plinth_core ^0.2.0, plinth_core from hosted is required.
So, because financial_organizer depends on plinth_core from path,
version solving failed.
```

An app that already uses published `plinth_components` **cannot add
`plinth_core` as a path dependency at all.** It needs
`dependency_overrides`, which the package documents nowhere. Worth
recording because it is exactly the shape of problem a first external
adopter hits the moment they try to patch the core locally to fix
something.

Two consolations, both worth keeping:

- With the override in place, `plinth_components 0.16.1` — compiled
  against `plinth_core 0.2.0` — analyzes and runs clean against
  `1.0.0-beta.1`. The core's API has stayed genuinely backward
  compatible across a major version bump.
- Nothing else broke. No runtime surprises from the swap.
- In the current app manifest, this is represented as a
  `dependency_overrides:` block pointing at the local package; without it,
  `pub get` fails for the exact version-conflict reason above.

### V-1 — Is `toThemeData()` reached for immediately?

*Predicted: yes. It is currently ranked the highest-priority task in
the roadmap, and if that is wrong, Phase 1 is wrong.*

> **Predicted wrongly.** It was never reached for, at any point in the
> migration.

The app already had this in `main.dart`, and it already worked:

```dart
theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: seed),
  extensions: [_plinthLight],
),
```

Six hand-written lines, zero friction. `toThemeData()` would have saved
those six lines and nothing else. It was not the blocker; the blocker
was three tiers up.

**The roadmap's instinct is not wrong — it has the wrong reason.** After
migration the app reads colour from two systems at once:

| Source | Lookups |
|---|---|
| `plinth.*` tokens | 58 |
| Material `colorScheme.*` | 31 |
| Material `textTheme.*` | 80 |
| `plinth.fontSizes` | **0** |
| `plinth.surface` / `text` / `border` / … (11 chrome fields) | **0** |

`colorScheme.error` — Material's red, derived from the seed — now sits
in the same tables as `plinth.expense`, the app's red. `colorScheme.primary`
sits beside the `brand` ramp. Nothing keeps any of them in agreement.

So the real requirement is not *generation*, which is six lines the app
can write itself. It is **reconciliation**: a guarantee that Material's
`ColorScheme` and the Plinth palette are the same colours, and that
`textTheme` and `fontSizes` are the same scale. If `toThemeData()` ships
as a convenience constructor, it will be ignored by exactly the audience
it was written for — they already have a working `ThemeData`, and
replacing it wholesale is riskier than the six lines it saves.

Note also: **11 of `PlinthTheme`'s 19 fields went completely unused.**
The entire neutral-chrome tier (`surface`, `surfaceMuted`,
`surfaceSunken`, `border`, `borderMuted`, `text`, `textMuted`,
`textDisabled`, `onFilled`, `onFilledInverse`, `scrim`) was never read,
because Material's `ColorScheme` already answers those questions and the
app was already using it. In any app that keeps Material — which is
every app in audience A — the chrome tier is duplicated, not additive.

### V-2 — Are component tokens the main thing attempted?

*Predicted: yes — styling their own widgets from tokens.*

> **Predicted wrongly.** Colour was attempted exclusively. Spacing,
> radius and font-size tokens were not reached for once — and when the
> reason was measured, it was not indifference.

Counted in the app's own widget code:

| | Hardcoded literals | `plinth.*` token uses |
|---|---|---|
| Spacing (`SizedBox`, `EdgeInsets`) | 355 | **0** |
| Radius (`BorderRadius.circular`) | 15 | **0** |
| Font size | 80 `textTheme` lookups | **0** |

Zero out of 370. That reads as apathy until the scales are lined up:

| | App's actual values | `plinth_core` offers |
|---|---|---|
| Spacing | **4** (29×), **6** (17×), **8** (128×), 12 (92×), 16 (24×) | 10, 12, 16, 20, 32 |
| Radius | 2, **3**, **6**, 8, **10** | 2, 4, 8, 16, 32 |

**The app's two most-used spacing values — `8` (128 uses) and `4` (29
uses) — do not exist in Plinth's scale at all.** The scale starts at
`xs: 10`, above the value this app reaches for more often than any
other. Mapping `8 → xs(10)` would move 128 gaps by 2px each; there is no
correct answer there, only a restyle. Radius is the same story: `3`, `6`
and `10` have no token, and `4`, which Plinth does offer, the app never
uses.

This is a more useful result than "component tokens wanted". The scale
is not too small — it is **shifted one step too coarse for dense data
UI**. A finance table is built out of 4px and 8px gaps. Mantine's scale
was designed for marketing-density web pages and was inherited
wholesale. Until the primitive scale grows a `2xs`/`xs` at 4 and 8,
every component token built on top of it will be unusable for exactly
the same reason.

### V-3 — Do `expense` / `income` want names rather than hex?

*Predicted: yes, and the 10-shade ramps are the wrong shape for a
two-pole financial palette.*

> **Predicted correctly on both counts**, and the second half is worse
> than written — but the audit's own premise needs one correction.

**The correction first.** The subject table lists `0xFFB26A00` as
"drift — matching nothing else in the palette". It is not drift:

| | Hue | Saturation | Lightness |
|---|---|---|---|
| `0xFFFF9500` (warn) | 35.1° | 1.000 | 0.500 |
| `0xFFB26A00` ("drift") | 35.7° | 1.000 | **0.349** |

Same hue, same saturation, darker. It appears exactly once, in
`assets_page._staleColor()`, where an orange staleness warning has to be
legible **as text on white** — and `#FF9500` on white is 2.20:1. The
author hand-computed a darker orange because the bright one was
unreadable.

That is `readableOn()`, implemented by hand, before `readableOn()`
existed. It is the strongest single piece of evidence in this experiment
that the function solves a real problem.

(The other listed drift, `0xFF2E7D32`, *is* real drift — hue 123°,
saturation 0.46, against income's 135°/0.59. It is Material Green 800,
the `ColorScheme.fromSeed` seed, unrelated to the income pole.)

**The ramp-shape problem.** Three separate failures, each measured.

*1. The generator does not round-trip a brand colour.* Feed a colour in,
ask for shade 6 — the shade every Plinth component defaults to — and you
do not get it back:

| Input | `_generateShades(x)[6]` | Nearest shade | RGB error at best |
|---|---|---|---|
| `#FF3B30` | `#F00D00` | `[5]` | 30.4 |
| `#34C759` | `#32BE55` | `[6]` | 10.0 |
| `#FF9500` | `#F08C00` | `[6]` | 17.5 |
| `#AF52DE` | `#9326C9` | `[5]` | 22.3 |
| `#2E7D32` | `#40AF46` | `[8]` | 9.3 |

The lightness stops are absolute, so a base colour is normalised onto
the curve rather than anchored to it. The best-matching index is not
even consistent — 5, 6, 7 or 8 depending on hue. There is no way to say
"my expense colour is `#FF3B30`" and get `#FF3B30` back; the app had to
write its own re-anchoring curve to pin the anchor at shade 6.

*2. The stock ramps are nowhere near the app's palette.* Skipping custom
ramps and just using `shaded('red', 6)`:

| App colour | Nearest stock shade | RGB distance | Distance at shade 6 |
|---|---|---|---|
| `#FF3B30` expense | `red[5]` | 32.0 | 69.8 |
| `#FF9500` warn | `orange[5]` | 33.1 | 43.5 |
| `#FFCC00` caution | `yellow[5]` | 36.3 | 44.1 |
| `#AF52DE` pension | `grape[5]` | 21.7 | 47.9 |

Adopting the stock palette is a full restyle — and the best matches
cluster at shade **5**, not the shade 6 components default to.

*3. The ramp namespace is shared with the component library.*
`plinth_components 0.16.1` hardcodes `shaded('red', …)` in 12 places,
`shaded('gray', …)` in 3, `shaded('green', …)` in 1. `red` is already
spoken for as the destructive/error ramp. An app that repurposes `red`
as its expense pole silently restyles every component error state; an
app that doesn't ends up with two different reds on screen — which is
what happened here, and is now visible as `colorScheme.error` sitting
beside `plinth.expense`.

**What the two-pole shape actually needs.** Not ten shades. Per pole the
app used exactly three roles — a fill, a text variant that clears a
contrast floor, and a wash — and reached for nothing else:

```dart
Color get expense     => shaded('expense', 6);
Color get expenseText => readableOn('expense', surface);
Color get expenseWash => Color.alphaBlend(
    color('expense', 6).withValues(alpha: 0.08), surface);
```

Three roles × 13 poles. The ramp is doing the work of a 3-token triad,
and 7 of its 10 shades were never read.

### V-4 — Does Plinth break in Hebrew?

*Predicted: yes. 7 of 115 widget files touch `Directionality`, and the
RTL story has never been checked against a real bidirectional app.*
**Highest-value item here.**

> **Predicted wrongly, decisively.** Zero failures. Six real pages
> (dashboard, cashflow, life-plan, liabilities, portfolio, assets), each
> pumped with real sample data under `he`/RTL and `en`/LTR: **12 of 12
> clean.** No layout exceptions, no overflow, no crash, in either
> direction.

This was flagged the highest-value item in the file and it came back
negative. That is worth more than a confirmed bug would have been: the
RTL anxiety was unfounded, and the roadmap should stop budgeting for it
on suspicion.

**Scope this honestly.** What was tested is that RTL does not *break* —
no exceptions, no overflow. What was **not** tested is whether RTL is
*correct*: mirroring of chart axes, icon direction, alignment of Hebrew
labels against LTR-formatted ₪ figures. Those need eyes or goldens, and
neither was applied. The claim is "Plinth survives Hebrew", not "Plinth
is right in Hebrew".

One adjacent gap did surface. The app wraps its own charts by hand:

```dart
Directionality(
  textDirection: TextDirection.ltr,   // cashflow_page.dart
  child: CustomPaint(painter: _BarsPainter(...)),
)
```

Numbers, currency and time axes stay LTR inside an RTL page. Every
bidirectional app needs this, and every one writes it by hand. There is
no Plinth primitive for "this subtree is always LTR" — small, cheap,
obviously correct, and the only concrete RTL finding here.

### V-5 — Do the Flutter-only axes bite in practice?

*Predicted: at least one of `textScaler`, density or `boldText`
produces a visible problem in a real financial table.*

> **Predicted correctly.** `textScaler` bites; `boldText` does not.

Same six pages, all combinations:

| Axis | Result |
|---|---|
| `textScaler` 1.0, 1.3 | clean, all six pages |
| `textScaler` **2.0** | **Portfolio table: RenderFlex overflowed by 26px** |
| `boldText: true` | clean, all six pages |
| 390 px width, scale 1.0 | **dashboard 36px, life-plan 78px, portfolio 26px** |
| 390 px width, scale 1.3 | **assets 18px** |

So it is `textScaler` — at 2.0, in exactly the place predicted, a dense
financial table. `boldText` never bit at all across six pages of tables.
Density was not separately testable, there being no Plinth density axis
yet.

**Two caveats that matter.**

First: **every one of these overflows is pre-existing.** The identical
harness run against the unmigrated app produced byte-identical output.
The token migration introduced zero layout regressions — good news for
the migration, but it means these are the app's bugs, not Plinth's. What
they establish is that the *class* of problem is real, and that a token
layer alone does not address it.

Second, and more interesting: the app breaks at 390px far more often
than at textScaler 2.0 — four pages against one. Mobile is a first-class
target for this app (MR-130/131). If Plinth grows a Flutter-only axis,
**responsive/container-width awareness looks a more urgent gap than
density**, on this evidence.

A third, subtler finding, introduced *by* tokenization: once colour
comes from a theme, colour becomes state, and every `shouldRepaint` that
ignores it becomes a stale-render hazard. `_FirePainter` already had
this latent —

```dart
bool shouldRepaint(_FirePainter old) =>
    old.years != years || old.retireAge != retireAge || old.unlockAge != unlockAge;
    // accessibleColor, already themed, was never compared
```

— and threading three more themed colours through it made the omission
live. Any migration guide Plinth ships must say this out loud.

### V-6 — What got hardcoded anyway?

*No prediction. Whatever gets hardcoded despite the tokens being
available is a missing token found by need instead of by grep — the
most trustworthy row this research will produce.*

Four things, in descending order of what they cost.

**1. Categorical series palettes — 36 values, 40% of the app's colour.**

The largest single category, and the one grep missed entirely. Three
`const Map<String, int>` palettes in `engine/valuation.dart` (asset
class, geography, look-through exposure), plus `categoryColor()` in
`engine/categories.dart`, plus `NamedAmount.color`. Domain-keyed chart
series: `'il'`, `'us'`, `'emerging'`, `'crypto'`, `'gold'`,
`'Groceries'`, `'Transport'`.

These need **five hues that appear nowhere in the semantic palette** —
`#FF2D55`, `#007AFF`, `#5856D6`, `#30B0C7`, `#5AC8FA` — chosen for one
property only: adjacent slices must be distinguishable. That is neither
a brand ramp nor a status colour. `plinth_core` has **no concept of a
categorical palette**: no "give me the Nth distinguishable colour", no
ordered sequence, no separation guarantee. Thirteen named brand ramps
answer a different question.

They were also the hardest to reach, for a structural reason: they live
in pure-Dart engine files that must not import a theme. What worked was
making the engine emit a **token name** and resolving it at the widget
layer:

```dart
// engine/categories.dart — pure Dart, no Flutter import
String categoryColor(String category) => switch (category) {
  'Groceries' || 'Restaurants' => 'series-pink',
  ...
};

// widget layer
color: context.plinth.series(categoryColor(c.category)),
```

That is precisely the semantic-name indirection the package lacks, and
it worked only because `colors` accepts arbitrary keys.

**2. Washes — because brightness mirroring breaks them.**

`shaded(name, 0)` is the obvious way to get a subtle tint. It is wrong
in dark mode: `shadeFor` mirrors 0 → 9, so the *lightest* shade becomes
the *most saturated* one.

| | Light | Dark |
|---|---|---|
| `shaded('income', 0)` | `#F2F8F3` — correct | `#245B2E` — a saturated green panel |
| Alpha-over-surface (what the app does) | `#EFFBF2` | `#1C2923` |

Mirroring preserves a shade's *role* only for foregrounds. For a
background wash the role is "barely distinguishable from the surface",
and mirroring inverts exactly that. `_wash()` had to be hand-written. A
`wash`/`tint` role that composites over `surface` instead of indexing
the ramp is a genuinely missing token.

**3. `const` widget trees — a mechanical tax, paid everywhere.**

Every token lookup needs a `BuildContext`, so it cannot be `const`. All
of these had to be rewritten:

- `static const _actionColors = {...}` → a method taking `PlinthTheme`
- `const TextStyle(color: Color(0xFFFF3B30))` → non-`const`
- `const Icon(Icons.delete_outline, color: …)` → non-`const`
- `Color flowColor(String flow)` → `flowColor(PlinthTheme t, String flow)`
- Seven helper methods (`_toneBg`, `_toneFg`, `_percentileTile`,
  `_scenarioRow`, `_categoriesView`, `_homeBadge`, `_staleColor`) grew a
  `BuildContext` parameter, rippling to every call site
- Two `CustomPainter`s grew colour constructor parameters, a painter
  having no context

None of this is hard, all of it is unavoidable, and none of it is
mentioned anywhere in the package. A migration note that simply said
"expect to lose `const`, and to thread `BuildContext` into helpers you
thought were pure" would save every adopter the same hour.

One small API gap surfaced here too: `context.plinth` is the *only*
accessor. A helper written the idiomatic Flutter way —
`Widget _homeBadge(ThemeData theme, …)` — already holds the theme and
still cannot reach the tokens. `ThemeData.plinth` would cost one line.

**4. The anchors themselves — 13 hex literals, and that is fine.**

To remove 91 scattered literals the app wrote 13 in one file. That is
the trade a token layer is supposed to make, and the one piece of
hardcoding that should stay hardcoded.

### An unpredicted result: `readableOn()` works, and its default is wrong

Not one of the six, but the most actionable thing measured.

The app's palette had real WCAG failures nobody had noticed, because a
hardcoded literal cannot know what it is sitting on:

| Token | As text on white, before | After `readableOn()` |
|---|---|---|
| income `#34C759` | **2.22:1** | 3.33:1 |
| warn `#FF9500` | **2.20:1** | 3.33:1 |
| caution `#FFCC00` | **1.51:1** | 3.69:1 |

`readableOn()` found and fixed all three automatically, with no
per-colour tuning. That is the clearest win `plinth_core` produced in
this experiment, and it should be said plainly.

**But the default floor is wrong for the job.** `minRatio: 3.0` is the
WCAG *large-text* threshold. These are ₪ amounts in 13px table cells —
body text, which needs 4.5:1. At the default, **6 of 7 tokens land in
"large text only"**; only `info` clears AA, and by accident.

Passing `minRatio: 4.5` explicitly fixes every one, in both themes:

| Token | Light | Dark |
|---|---|---|
| expense | `#EB1206` 4.54 | `#F7A6A2` 8.96 |
| income | `#277F3E` 5.01 | `#A0DFB0` 11.22 |
| warn | `#A06108` 4.99 | `#F6C98B` 11.19 |
| caution | `#76600A` 6.09 | `#F6E08B` 13.08 |
| neutral | `#717176` 4.85 | `#C8C8CA` 10.31 |

So the mechanism is sound and the ramps are deep enough. The trap is
that a caller who reaches for the obviously-correct method gets
large-text contrast for body text and is never told. Either the default
should be 4.5 with an opt-out for large text, or the parameter should be
a named role (`PlinthTextRole.body` / `.large`) rather than a bare
number callers will leave alone.

The tension is worth stating honestly: at 4.5 the colours drift a long
way from brand — income goes `#34C759` → `#277F3E`. `readableOn()`
surfaces the brand-fidelity-versus-legibility conflict; it does not
resolve it, and no token layer can.

### A silent risk the tests could not see

The full suite — 202 tests, including page-level widget tests for every
migrated page — passed **before and after**, unchanged, including
through intermediate states where the palette was materially different.
Not one test asserts on a colour.

An app can be fully migrated onto a token layer, have its rendered
palette shift, and show a green suite throughout. If Plinth wants
adopters to trust migrations it needs to ship something that makes
palette drift visible — a golden helper, a contrast-audit test, or a
documented pattern. "The tests pass" is not evidence here, and this
experiment would have produced a false all-clear if the before/after
deltas had not been measured by hand.

## How to read these results

The app's author is also Plinth's author. That validates audience A's
*shape* rather than their existence: someone who already thinks in
these terms will reach for the tokens this library happens to have.

Worth far more than zero users. Worth less than a stranger. **Prefer
the findings that surprised.**

Four of the six predictions were tested and two held (V-3, V-5). V-1,
V-2 and V-4 were all predicted wrongly, and V-4 — flagged the
highest-value item in this file — came back completely clean. The
roadmap's top-ranked task (`toThemeData()`) was never reached for. The
things that actually cost time were a missing semantic tier, a spacing
scale that starts above the app's most-used value, and an absent
categorical palette — none of which had a prediction attached.

---

This run is track T2 of [APP_VALIDATION_PLAN.md](APP_VALIDATION_PLAN.md),
which turns the same app into a standing harness for both packages.
The gaps recorded above are filed as numbered requirements in
[ADOPTION_REQUIREMENTS.md](ADOPTION_REQUIREMENTS.md).
