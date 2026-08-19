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

Six landed as of 19 Aug 2026 (five on 18 Aug, PR-01 on 19 Aug), verified by re-running the subject app's own
harness against the changed packages: 225/225 app tests, 48 core tests,
643 component tests, and the T4 palette snapshot **unchanged** — the
fixes are behaviour-preserving for an adopter already on the old API.

Golden images still need regenerating on Linux; they are skipped on
Windows by design, so the one visual check for PR-06 could not run where
the change was made.

## Summary

| ID | Requirement | Package | Priority | Status |
|---|---|---|---|---|
| [PR-01](#pr-01--a-semantic-token-tier) | A semantic token tier | core | **Blocker** | **Done** |
| [PR-02](#pr-02--publish-the-ramp-generator) | Publish the ramp generator | core | **Blocker** | **Done** |
| [PR-03](#pr-03--anchor-a-supplied-brand-colour) | Anchor a supplied brand colour | core | **High** | Open |
| [PR-04](#pr-04--a-categorical-series-palette) | A categorical series palette | core | **High** | Open |
| [PR-05](#pr-05--a-wash-role-that-survives-dark-mode) | A `wash` role that survives dark mode | core | **High** | **Done** |
| [PR-06](#pr-06--readableons-default-floor-is-wrong) | `readableOn`'s default floor is wrong | core | **High** | **Done** |
| [PR-07](#pr-07--a-spacing-scale-for-dense-ui) | A spacing scale for dense UI | core | **High** | **Done** |
| [PR-08](#pr-08--reconcile-with-materials-colorscheme) | Reconcile with Material's `ColorScheme` | core | **Medium** | Open |
| [PR-09](#pr-09--separate-the-app-and-component-ramp-namespaces) | Separate app and component ramp namespaces | core | **Medium** | Open |
| [PR-10](#pr-10--themedataplinth) | `ThemeData.plinth` | core | **Low** | **Done** |
| [PR-11](#pr-11--make-lerp-real-or-say-it-isnt) | Make `lerp` real, or say it isn't | core | **Low** | Open |
| [PR-12](#pr-12--showon-for-messenger-backed-apis) | `showOn` for messenger-backed APIs | components | **High** | Open |
| [PR-13](#pr-13--a-numerals-stay-ltr-primitive) | A "numerals stay LTR" primitive | components | **Medium** | Open |
| [PR-14](#pr-14--path-dependencies-are-unusable) | Path dependencies are unusable | both | **Medium** | Open |
| [PR-15](#pr-15--a-migration-guide-for-the-const-and-context-tax) | A migration guide for the `const`/context tax | docs | **Medium** | Open |

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
