# Post-1.0 roadmap — design tokens for Flutter teams

[PRE_1_0_AUDIT.md](PRE_1_0_AUDIT.md) answered *"of the components that
exist, how much of each one exists?"* and closed with an empty list.
This document answers what comes after, and it starts from the question
that turned out to matter more than any feature list:

**When a team lands on the pub.dev page, who did we hope it was?**

> **This document is the engineering plan** — workstreams, task IDs and
> sequencing. [plinth-ui-roadmap.md](plinth-ui-roadmap.md) holds the
> four things it deliberately doesn't cover (trust signals,
> distribution, i18n, DX tooling), the reconciliation with the earlier
> outside-in draft, and the gate on the public description. Where the
> two disagreed, this one wins on audience and sequencing; the one open
> disagreement — whether repositioning really waits until Phase 5 — is
> recorded at the end of that file.

## Who this is for

Two answers, and they are one audience at two depths.

**A — a Flutter team with an existing app and their own widgets.** They
are not starting fresh and will not rewrite their UI layer. They have
`ThemeData`, a pile of hardcoded values, and a designer asking why the
dark mode looks wrong. They want their *own* widgets to be themeable,
consistent, and correct at 200% text scale.

**B — a team standardizing design across Flutter and web.** Everything
A needs, plus one source of truth shared with a codebase that is not
Flutter. They already have tokens somewhere — Figma variables, Tokens
Studio, a Style Dictionary build. What they lack is a Flutter runtime
that consumes them properly.

**B is A plus interop**, which is why this is one sequence rather than
two. Neither is a solo developer starting a greenfield app, and that
single fact reorders most of what follows.

### What both of them are not

Not someone shopping for the biggest widget count. Both audiences have
existing code and adopt incrementally; **nobody installs 112 components
on day one.** For audience A, `plinth_components` may never be
installed at all.

That makes `plinth_core` the product and `plinth_components` the
evidence — 112 real components are how a team evaluating the tokens
sees them working at scale. Both matter. They are not equally the
point.

## What this answer changed

Recorded because several of these reverse earlier positions, and a
reversal is worth more written down than quietly applied.

| Item | Before | After the audience answer |
|---|---|---|
| **`toThemeData()`** | Task A8, a compatibility nicety | **The main product surface.** For a team with their own widgets, this is how anything gets themed at all |
| **Component tokens** | Part of the interaction-state axis | **The primary consumption API.** They need `button.primary.background` for *their* button |
| **DTCG import** | Not on the list | **Disqualifying if absent.** Audience B cannot be served by hand-written Dart config |
| **Form and dates** | Moved *up*, "days per app" | **Dropped.** Both audiences already have forms. The earlier ranking assumed a greenfield builder |
| **Hooks** | A phase of its own | **Mostly declined.** A team has its own state utilities |
| **A "five-minute path"** | `pub add` to a new themed app | Rewritten: `pub add` to an **existing** app's theme improving without a rewrite |
| **Component count** | Retired | Still retired |

## Method, and how far to trust it

Every number below is a grep against the source at `1.0.0-beta.1`:

```bash
grep -c "^export 'src/widgets" packages/plinth_components/lib/plinth_components.dart
cd packages/plinth_components/lib/src/widgets && grep -L "Semantics(" *.dart
grep -ho "spacing\[[^]]*\]! \* [0-9.]*" *.dart | sed 's/.*\* //' | sort | uniq -c
grep -ho "Duration(milliseconds: [0-9]*)" *.dart | sort | uniq -c
grep -ho "FontWeight\.w\?[a-z0-9]*" *.dart | sort | uniq -c
```

Sizes are ratios, not dates: **S** is an afternoon, **M** a day or two,
**L** a week or more.

**Every item is a lead from a grep, not evidence.** Check each against
the source before building it. The 0.24.0 → 0.25.0 `PlinthTabs`
correction is what happens when you don't, and the `Blockquote.cite`
entry is what happens when a list is never re-read.

## Where `plinth_core` stands today

476 lines. Its only dependency is `flutter` — no dependency on
`plinth_components` or `plinth_hooks` — and it is already separately
published. **It is a standalone token package today**, simply not built
or documented as one. Its pubspec description reads *"…for Plinth UI"*,
which is the old framing baked into the metadata.

It covers four axes well: colour ramps, spacing, radius, font size. The
contrast machinery — `readableOn`, `contrastingOn`, real WCAG relative
luminance — is better than most token layers ship, and is currently
buried in a support package.

---

## Workstream A — The token layer

### A0 — Structure before values

**New, and it comes first.** `PlinthTheme` is a flat class mixing two
different kinds of token: the colour ramps are *primitive* (`blue.6` is
a fact about a colour), while `surface`, `textMuted` and `border` are
*semantic* (`surface` is a decision about a role).

Both audiences need that split made explicit — A for coherent theming,
B because every interop format is built on it.

- [ ] **A0a** Formalise primitive / semantic / component tiers as a documented hierarchy that `PlinthTheme` implements. **L.** Design work, not typing, and the DTCG mapping in Workstream E falls out of it.
- [ ] **A0b** Component tokens — `button.primary.background`, with `hover` / `pressed` / `focus` / `disabled` / `selected` states. **L.** For audience A this is *the* consumption API: it is how a team styles their own widgets. It is also the Flutter answer to Mantine's Styles API, and the reason a caller no longer has to fork a component to restyle one instance.

### A1 / A2 — The missing axes

`fontSizes` is the control case: because the token exists, 34 files read
it and only 5 hardcode a size. Every row below is that same absence,
measured.

Each `A1*` is purely additive to `plinth_core`; each `A2*` is the
mechanical sweep that follows. Landing them as pairs keeps every commit
revertable.

**Token migration is value-preserving.** Defaults are chosen so
rendered output is byte-identical, exactly as the 0.19.0 radius work
was: *"every default is unchanged, which is what the tests pin in both
directions."* **A golden diff during an `A2*` task is a bug**, not
expected churn. `A2e` is the sole exception — it is a design change and
will move pixels.

| Axis | Leakage today |
|---|---|
| **Control sizing** | **87 sites** of `spacing[size]! * <fraction>`, seven multipliers — 0.4 (38×), 0.5 (20×), 0.6 (14×), 0.8 (8×), 0.7 (3×), 2.2 (3×), 0.3 (1×) |
| **Font weight** | 58 literals — `w600` ×35, `w700` ×16, `w400` ×7 |
| **Motion** | ~30 `Duration` literals across 24 files, 11 distinct values, 150 ms appearing 13 times |
| **Opacity** | 20+ distinct alpha literals |
| **Elevation** | 11 `BoxShadow`s across 9 files, 8 distinct blur radii |
| **Interaction state** | None. Only 2 files use `WidgetStateProperty` |
| **Typeface** | No `fontFamily` token at all |
| **Border width** | `width: 1` and `width: 2` as literals |
| **Breakpoints** | `kDefaultBreakpoints` lives in `plinth_grid.dart`, in the wrong package |

- [ ] **A1a** Motion — `durations` + `curves`. **S**
- [ ] **A2a** Migrate ~30 `Duration` literals. **M**
- [ ] **A1b** Typography — `fontWeights`, `headings`, `fontFamily`. **S**, plus a decision: bundle a typeface as a pubspec asset, or name one and document the fallback. Flutter has no CDN `@font-face`.
- [ ] **A2b** Migrate 58 `FontWeight` literals; move `PlinthTitle`'s private `_titleStyles` map onto `headings`. **M**
- [ ] **A1c** Control sizing — `controlHeight` / `controlPadding` as **textScaler-aware minimums, not constants**, fed by a `density` axis. **L.** The most design-heavy axis; see the Flutter section.
- [ ] **A2c** Migrate the 87 multiplier sites. **L — the riskiest task here.** Per component family, goldens after each, and add one golden pinned at a large `textScaler`.
- [ ] **A1d** Elevation, border width, opacity. **S.** Spacing tokens return `EdgeInsetsDirectional`, so RTL is correct by construction.
- [ ] **A2d** Migrate 11 `BoxShadow`s and the 20+ alpha literals. **M**
- [ ] **A1e** Interaction state as **`WidgetStateProperty` factories, not `Color` values**, plus the focus-ring token. **M.** Feeds A0b and Workstream B.
- [ ] **A2e** Adopt state tokens where components inherit Material's defaults. **L**, and this one *will* move goldens — review each.
- [ ] **A1f** Platform accessibility flags — `disableAnimations`, `boldText`, `highContrast` from `MediaQuery`. **M**
- [ ] **A3** Move `kDefaultBreakpoints` into `plinth_core`, re-exporting so no caller breaks. **S**
- [ ] **A4** `PlinthThemeScope` — nested token override over a subtree. **M.** Teams have sections, brands and embedded contexts; app-global tokens cannot express any of them.
- [ ] **A5** `PlinthTheme.fromSeed(Color)` — promote `_generateShades` to a public constructor. **S**
- [ ] **A6** Per-key `lerp` so theme transitions animate. **S**, best done once the axes stop changing.
- [ ] **A7** Rewrite [COMPONENTS.md § Theme tokens](COMPONENTS.md#theme-tokens). **S**, not optional — an undocumented token is a token nobody uses.
- [ ] **A8** ~~`PlinthTheme.toThemeData()`. **L**, and **the highest-priority task in this document.**~~ **Down-ranked by Phase −1, which was designed to test exactly this.** `V-1` predicted the bridge would be reached for immediately; **it was never reached for at any point.** The app already had six hand-written lines of `ThemeData` and zero friction, and `toThemeData()` would have saved those six lines and nothing else. Shipped as a convenience constructor it would be ignored by the audience it was written for, who already have a working `ThemeData` that is riskier to replace than to keep. **The instinct was right and the reason was wrong:** what the migration actually needed is *reconciliation*, not generation — see `A8'`.
- [x] **A8'** **Reconcile with Material's `ColorScheme` and `textTheme`** — **done**, see [PR-08](ADOPTION_REQUIREMENTS.md#pr-08--reconcile-with-materials-colorscheme). It *replaced* A8 rather than sitting beside it. The problem it closes: after migration the app read colour from two systems at once — 58 `plinth.*` lookups against 31 `colorScheme.*` and 80 `textTheme.*` — with `colorScheme.error` (Material's red, from the seed) in the same tables as `plinth.expense` (the app's red), and nothing keeping them in agreement. Shipped as the `PlinthMaterialBridge` extension: **`colorSchemeDisagreements`** for an app that keeps its own `ThemeData` — the half the migration actually wanted — plus `toColorScheme` / `toTextTheme` for one willing to derive. What Plinth has *no* opinion about is named rather than guessed: `ownedSchemeFields` lists the ten it decides, and `toTextTheme` leaves `headline`/`display` alone because `fontSizes` stops at 20.
- [ ] **A9** **Decide what the neutral-chrome tier is for.** **M**, and new — nothing predicted it. **11 of `PlinthTheme`'s 19 fields went entirely unread** during the migration: the whole `surface` / `border` / `text` / `onFilled` / `scrim` tier, because Material's `ColorScheme` already answers those questions. In any app that keeps Material — every app in audience A — that tier is **duplicated, not additive.** Either it earns its place against `ColorScheme` or it becomes an internal detail of `plinth_components`. Do not migrate or extend it before answering this.

---

## Workstream E — Interop and governance

**New, and it is what makes audience B possible.** None of it appeared
in earlier versions of this plan, because earlier versions were aimed
at a different person.

- [ ] **E1** `PlinthTheme.fromDtcg(json)` — consume the W3C Design Tokens Community Group format, which Tokens Studio and Style Dictionary both target. **M.** A team standardizing across platforms already has a token source; **if Plinth can only be configured by hand-written Dart, it is disqualified for audience B outright.** Depends on A0a.
- [ ] **E2** Export the other way — emit DTCG from a `PlinthTheme`, so a Flutter-first team can hand tokens to their web side. **M**
- [ ] **E3** Theme validation shipped to users — contrast failures, missing references, unresolvable aliases, in a form a team can run in CI. **M.** The WCAG machinery already exists internally; this exposes it. Governance is a team problem, which is exactly why it did not rank before.
- [ ] **E4** A token explorer — every token, its value in each theme, and which components consume it. **M.** The Widgetbook and demo infrastructure already exists; this is a *token* view rather than a component one, and it is what lets designers and developers share a vocabulary.
- [ ] **E5** Golden-test helpers for users, so a team can pin its own token usage. **M.** Turns this project's strongest internal practice into a product feature, and nothing in the CSS world can offer the equivalent.

### Not building a token compiler

Recorded as a deliberate exclusion. A build-time pipeline
(Style Dictionary and friends) emits **static constants** —
`static const primary = Color(0xFF2563EB)`. That cannot express
`textScaler`, `density`, `boldText`, `WidgetStateProperty`, a
per-subtree override, `lerp`, or `readableOn`, which needs the runtime
background to answer at all.

Both target audiences already have a token source. The gap is a Flutter
runtime that consumes one well — not another compiler competing with
mature incumbents. **Consume the standard; do not rebuild the
pipeline.**

---

## What B0 found

Ran 19 Aug 2026, against `74f5f99`. **B0c is still open** — it needs a
person at a screen reader, which no probe substitutes for.

### B0d — clean

**0 of 232** gallery use cases threw when built right-to-left. Kept as a
permanent test, reusing the gallery's own use-case walk so coverage is
the whole component surface rather than a sample. It corroborates the
stronger evidence already on file: a real Hebrew/English app rendered 12
of 12 page x language combinations clean.

This closes the RTL anxiety properly. What it does *not* cover is
whether the text reads well, which needs a reader.

### B0b — the tap-target result depends entirely on which bar

The raw guideline run looks alarming and mostly is not. Measured against
the three standards that actually exist:

| Standard | Result |
|---|---|
| **WCAG 2.2 AA** (SC 2.5.8, 24x24) | **10 of 11 pass** |
| **iOS HIG** (44) | 0 of 11 |
| **Android Material** (48) | 0 of 11 |

Heights at default size: Button 39, TextInput 40, ActionIcon 36, Chip
36, Checkbox/Switch/Radio/Pagination 32, CloseButton 24, Anchor 23.

**So Plinth is a web/desktop-density library that does not meet mobile
touch guidelines at default size** — which is what matching Mantine's
sizing implies, and is a positioning question rather than a pile of
bugs. It is the argument for **A1c** (control sizing fed by a density
axis), and A1c is an **L**.

Three genuine defects, separate from the density question:

- **`PlinthAnchor` fails even the 24x24 AA bar**, at 23px. By one pixel,
  which is the kind of miss only a measurement finds.
- **`PlinthAnchor` fails text contrast** because it paints
  `shaded(colorKey, 6)` — a raw shade for a *foreground*. Blue 6 on
  white is 3.56:1. This is the same class as PR-17's alert icons and
  PR-19's `PlinthText`, in a component neither touched. **Third
  instance of the same bug.**
- **`PlinthActionIcon` has no `semanticLabel` parameter at all.** It
  wraps in `Semantics(button: true)` with no name, so an icon-only
  button is announced as an unlabelled button. `PlinthCloseButton` has
  the parameter; this does not.

`PlinthBadge` also fails text contrast, and that one is **deliberate**:
`PlinthVariant.light` is pinned to `PlinthContrast.large` because a
same-hue label on a same-hue tint cannot reach 4.5 and stay that colour.
Recorded so it is not rediscovered as a bug.

### B0a — labels are the gap, not roles

Probing the composite controls for tappable nodes, how many carry a
label, and how many carry a role:

| Control | tappable | labelled | roled |
|---|---|---|---|
| Select | 1 | 1 | 1 |
| MultiSelect | 2 | 2 | 1 |
| Breadcrumbs | 1 | 1 | 0 |
| Stepper | 2 | 2 | 0 |
| Accordion | 1 | 1 | 0 |
| **Autocomplete** | 1 | **0** | 1 |
| **PinInput** | 4 | **0** | 4 |
| **Rating** | 5 | **0** | 0 |

**`PlinthRating` is the worst in the library**: five tappable stars,
none labelled, none with a role. A screen-reader user gets five
anonymous tappable things and no way to know the current value.
`PlinthPinInput` is four unlabelled fields. `PlinthAutocomplete` is
unlabelled *despite* being given a `label`, so the label is not reaching
semantics.

Accordion, Breadcrumbs and Stepper are labelled but carry no role, so
they are announced as text rather than as controls.

**The pattern across B0a and B0b is one thing:** icon-only and
repeated-element controls do not carry names. That is a coherent, fixable
piece of work rather than a scattering.

### Fixed in the pass that followed

All eight labelling and role gaps, plus both `PlinthAnchor` defects and
`PlinthActionIcon`'s missing parameter. Pinned by
`plinth_components/test/plinth_semantics_test.dart`, which asserts
`labelled == tappable` per control — a target you can reach and cannot
identify is worse than one you cannot reach.

**Still open, and deliberately not touched here:**

- **The form-label pattern is wider than B0a's list.** Eight more
  widgets — `PlinthSelect`, `PlinthMultiSelect`, `PlinthTextarea`,
  `PlinthNumberInput`, `PlinthPasswordInput`, `PlinthPillsInput`,
  `PlinthTagsInput`, `PlinthTreeSelect` — render a visual label with no
  `Semantics` in the file at all. `PlinthAutocomplete` was one of nine,
  not one of one. Same fix, eight more times.
- **B1 focus containment**, unchanged at 0 of 116 files.
- **A1c density**, unchanged.

### What this means for 1.0.0

`1.0.0` promises no breaking change without a `2.0.0`, and this repo has
treated visual changes as breaking — that is why `1.0.0-beta.2` exists.
B0 found work that will move pixels and change behaviour:

- Labelling the unlabelled controls (**B0a**) — additive, safe.
- Fixing `PlinthAnchor`'s height and colour — visual.
- `PlinthActionIcon`'s missing parameter — additive API.
- Focus containment (**B1**) — still **0 of 116 files**, still known
  broken without needing a probe.
- The density question (**A1c**) — **L**, and moves every control.

The first three are small. B1 and A1c are not, and A1c in particular
cannot land inside a `1.x` under the current promise.

---

## Workstream B — Accessibility

Unchanged by the audience answer, and it survives every version of this
plan. A team cannot retrofit it, and `highContrast` / `boldText` /
`textScaler` are token concerns as much as widget ones.

- [x] **B0a** **RAN — see § What B0 found.** Semantics probe on the 11 composite controls with neither explicit nor inherited semantics: Select, Autocomplete, MultiSelect, Menu, Menubar, Accordion, PinInput, Rating, Breadcrumbs, Stepper, Drawer. 37 of 115 files reference `Semantics`; some absences are correct (layout), some inherited (Material-wrapping). **M.** Record the result either way — "already correct, here is the probe" is as useful an entry as a fix.
- [x] **B0b** **RAN — see § What B0 found.** Run `textContrastGuideline`, `androidTapTargetGuideline` and `labeledTapTargetGuideline` across the library; add the passing set to CI. **M.** Currently **1 of 59 test files** asserts anything about accessibility.
- [ ] **B0c** Manual NVDA and VoiceOver pass against the deployed demo. **M.** The only task here that cannot be satisfied by writing code.
- [x] **B0d** **RAN — clean, 0 of 232 gallery use cases threw in RTL; kept as `widgetbook/test/gallery_rtl_smoke_test.dart`.** RTL golden pass. **S** to run; 7 of 115 files touch `Directionality`, so the other 108 are unverified rather than known-broken.
- [ ] **B1** Focus containment — **zero** uses of `FocusTraversalGroup`, `FocusScope`, `Shortcuts` or `Actions` across 115 files. Drawer first, as a reusable trap, then Popover, Menu, HoverCard. Modal already gets it from `showGeneralDialog`. **M**
- [ ] **B2a** Extract the roving-focus logic welded inside `PlinthTabs` since 0.25.0 into a reusable controller. **M.** Three tasks below consume it.
- [ ] **B2b–d** Roving focus on Menu/Menubar, the listbox family (Select, Combobox, MultiSelect — the largest, since the trigger/popup split doubles the focus cases), then Tree, Pagination, Accordion. **L**
- [ ] **B3** Fix whatever B0d turned up. **?**
- [ ] **B4** Record the outcome in `PRE_1_0_AUDIT.md`'s style, including every probe that found nothing wrong. **S**

**`PlinthStepper` stays excluded**, reason already recorded: its steps
are independent buttons, not a single-selection group.

---

## What a Flutter token layer needs that a CSS one doesn't

Audience B arrives with web instincts, so this section is also the one
to hand them. Nothing in it came from a comparison.

### The reframe: the 87 multipliers are hand-rolled `calc()`

CSS has `em`, `rem`, `calc()` and `clamp()`. Dart has none, so every
relative value is computed at build time — which is exactly what
`theme.spacing[size]! * 0.5` *is*. The 87 sites are not sloppiness;
they are 87 hand-rolled `calc()` expressions with no unit system to
hold them.

### Free in CSS, built by hand in Flutter

| CSS gives you | Flutter makes you build it | Consequence |
|---|---|---|
| The cascade | No cascade; `DefaultTextStyle` is opt-in per subtree | A `fontFamily` token needs a widget that propagates it — half of why **A4** matters |
| `:hover`, `:focus-visible`, `:active` | Each is a `WidgetState` wired per widget | **A1e ships `WidgetStateProperty` factories.** A raw `Color` is a token no component can consume |
| Logical properties | `EdgeInsetsDirectional` is opt-in; `EdgeInsets.only(left:)` silently breaks RTL | Spacing tokens return directional insets |
| Transitions | `ThemeExtension.lerp` is a method you write | Why **A6** exists |
| Free re-render | `Theme.of(context)` registers a rebuild dependency | Token classes need cheap `==`; **A4**'s `updateShouldNotify` decides subtree vs app rebuild |
| `@font-face` from any URL | Fonts ship as pubspec assets, counted against package size | **A1b** carries an asset decision |
| `<button>` *is* the semantics | Semantics is a wrapper, never implied | No "role" token, because there is no markup |

### No web analogue at all

Not gaps against anything — the axes a Flutter token layer needs on top
of the web list, and the clearest answer to *"why not just use Style
Dictionary?"*

- **Text scaling.** `MediaQuery.textScaler` is a system setting,
  commonly 200%+. **This is what makes a static `controlHeight`
  dangerous** — fixed height plus scaled text clips or overflows. CSS
  gets it free via `rem` and browser zoom.
- **Density.** Touch, pointer and desktop from one codebase. The web
  answers this with `@media (pointer: coarse)` and never thinks about
  it; Flutter has `VisualDensity` because it cannot.
- **Platform accessibility flags.** `disableAnimations` has a CSS
  analogue; **`boldText` and `highContrast` are iOS and Android system
  settings with no web equivalent at all.**
- **`TargetPlatform`.** Scroll physics, back-gesture behaviour, the
  expected default typeface. Needs a documented stance at minimum.
- **The Material bridge.** `ThemeData` is a second styling system that
  has to be reconciled. No web token system has this problem, and for
  audience A it is the whole job.

### One thing Flutter gets that CSS does not

**The tokens are pixel-testable.** The golden suite can pin an 87-site
migration in both directions — a guarantee no CSS-variable refactor can
offer, and the reason `A2c` is safe to attempt at all. Every visual bug
this project has had was found by looking at rendered output.

---

## Workstream D — Components, and what is declined

`plinth_components` stays at parity with `@mantine/core` and stays the
evidence that the tokens work. What changed is that nothing here is a
priority for either target audience.

| Item | Call |
|---|---|
| `plinth_form`, `plinth_dates` | **Dropped from the plan.** Both audiences have forms and date handling already. These ranked highly under a greenfield-builder assumption the audience answer retired |
| Notifications / modals managers | Optional. Small, mostly written, and not what either audience came for |
| Dropzone, spotlight, nprogress, code-highlight | Optional |
| Charts, tiptap | **Declined.** Separate projects |
| ~30 DOM-only hooks | **Declined.** `dart:js_interop`, web-only, in a library that is not |
| The rest of `plinth_hooks` | **Mostly declined.** A team has its own state utilities. `use-focus-trap` and `use-roving-index` still get built — Workstream B needs them — and should be made public, since the work is done |
| ~8 components to reach 120 | **Retired.** A count borrowed from another project's marketing was never a goal. Components get built when an app needs one |

### Not gaps — divergences to record

React/DOM concerns with no Flutter analogue: SSR and hydration, CSS
modules, per-component tree-shaking, the polymorphic `component` prop,
`renderRoot`, and `*Props` pass-throughs.

---

## Sequencing

### Phase −1 — Validate against one real app ✅ RAN, 18 Aug 2026

> **This ran, and it moved things.** Results:
> [PHASE_MINUS_1_FINDINGS.md](PHASE_MINUS_1_FINDINGS.md); gaps filed as
> 15 numbered requirements in
> [ADOPTION_REQUIREMENTS.md](ADOPTION_REQUIREMENTS.md), of which five
> have landed. **Four of the six predictions below were tested and only
> two held.** V-1, V-2 and V-4 were all predicted wrongly — and the
> tasks that actually cost the migration time (a semantic tier, a
> spacing scale that starts above the app's most-used value, an absent
> categorical palette) **had no prediction attached at all.** Read the
> rest of this section as the record of a bet that was placed, not as
> current ranking.

**Everything below this line is reasoning about a user nobody has met.**
Every finding in this document came from reading Plinth's own source,
not from someone hitting a problem. That is a different risk from being
wrong, and it is cheap to retire.

The subject is `financial-organizer` — a private local-first finance app
in the adjacent directory. It qualifies as audience A on every count,
measured rather than assumed:

| Audience A trait | In that app |
|---|---|
| Existing app, own widgets | 70 Dart files |
| `ThemeData` and a pile of hardcoded values | `ThemeData(` twice, inline in `main.dart`; **55 `Color(0x…)` literals**, zero `Colors.*` |
| A semantic layer they never got to name | `0xFFFF3B30` ×17 (expense), `0xFF34C759` ×15 (income) |
| The opacity axis, hand-rolled | `0x22FF9500`, `0x14FF9500`, `0x1434C759` |
| Drift, because there was no token to reach for | `0xFF2E7D32`, `0xFFB26A00` — matching nothing else |
| **RTL, for real** | Hebrew/English with `flutter_localizations` wired |

Results go in [PHASE_MINUS_1_FINDINGS.md](PHASE_MINUS_1_FINDINGS.md),
not here — this file is the plan, that one is what happened.

**The task:** theme it with `plinth_core` as it exists today. Not to
succeed — `plinth_core` is 476 lines and has no `toThemeData()`, so it
will stop being useful quickly. **Where it stops is the data.**

#### What this plan predicts, so the experiment can falsify it

- [ ] **V-1** `A8` is ranked the highest-priority task here. **Prediction:** with an existing `ThemeData` and 70 files of their own widgets, the bridge is wanted immediately. *If it isn't reached for, A8 is over-ranked and Phase 1 is wrong.*
- [ ] **V-2** `A0b` is called the primary consumption API. **Prediction:** styling their own widgets from tokens is the main thing attempted.
- [ ] **V-3** `A0a`'s semantic tier matters. **Prediction:** `expense` and `income` want names, not hex — and the ramps are the wrong shape for a two-pole financial palette.
- [ ] **V-4** The RTL story is unverified — 7 of 115 files touch `Directionality`. **Prediction: Plinth breaks in Hebrew.** This is the highest-value finding available and answers `B0d` with real evidence rather than a golden.
- [ ] **V-5** The Flutter-only axes matter in practice, not only in theory. **Prediction:** at least one of textScaler, density or `boldText` produces a visible problem in a real financial table.
- [ ] **V-6** Record **whatever gets hardcoded anyway.** That is a missing token found by need instead of by grep, and it is the most trustworthy row this document will ever get.

**One caveat on the evidence.** The app's author is also Plinth's
author, so this validates audience A's *shape* rather than their
existence — someone who already thinks in these terms will reach for
the tokens this library happens to have. Worth far more than zero
users; worth less than a stranger. Read the results with that
discount applied, and prefer the findings that surprised.

### Phase 0 — Ship 1.0.0

- [ ] **P0-1** Execute [PUBLISHING.md § The 1.0.0 release sequence](PUBLISHING.md#the-100-release-sequence). **S**, and the dependency order is the part that has already broken once.

### Phase 1 — Structure and the bridge

**Re-ranked by Phase −1.** `A0a` (**and `PR-01`, which is the same
task arriving from evidence**) first and alone at the top, then `A8'`,
then `A9`. `B0` still runs in parallel because it is reading rather
than writing. **`A0b` is no longer in this phase** — `V-2` predicted
component tokens would be the main thing attempted and they were not
reached for once; colour was attempted exclusively.

**This is still the phase that decides whether either audience can use
the library at all — for a different reason than originally written.**
The migration's largest single cost was writing `app_tokens.dart`: 110
lines of ramp anchors, semantic getters and resolvers, i.e. a design
token layer built on top of a design token package. It worked only
because `colors` happens to accept arbitrary string keys, so semantic
names could be smuggled in as ramps — *an accident, not an API*.
Nothing documents it, nothing validates it, and it collides with the
component namespace (`A9`/`PR-09`). Close that and the rest of this
document has something coherent to build on; leave it and every later
axis inherits the same workaround.

### Phase 2 — The axes

`A1*` / `A2*` in pairs, plus `A3`–`A7`. Ends with the token axes closed
including the three Flutter-only ones, and goldens unchanged except
where `A2e` deliberately moved them.

### Phase 3 — Interop and governance

Workstream E. `E1` first — it is the disqualifying one. This is the
phase that turns audience A into audience B, and it depends on `A0a`
having been done properly.

### Phase 4 — Accessibility

`B1`, `B2`, `B3`, sized by whatever `B0` found rather than by the
greps. Later than in earlier drafts only because `B0` — the part that
produces knowledge rather than code — already ran in Phase 1.

### Phase 5 — Repositioning, and whatever is left

The README, pubspec descriptions and pub.dev listings, once there is
something to reposition *around*. **Deliberately last:** `plinth_core`
is 476 lines today, and announcing a token foundation before building
one is precisely the unbacked claim this document exists to avoid.

Then the optional items from Workstream D, if anyone asks for them.

### The critical path

| Gate | Blocks |
|---|---|
| **A0a** (the token hierarchy) | A0b, E1, E2 — the structure has to be right before anything maps onto it |
| ~~**A8** (`toThemeData()`)~~ → **A0a** (the semantic tier) | Audience A entirely. Phase −1 reassigned this gate: the bridge was never reached for, and the migration's largest cost was a **missing semantic tier** — 110 lines of app-side token layer written on top of a token package. See [PR-01](ADOPTION_REQUIREMENTS.md#pr-01--a-semantic-token-tier) |
| **A8'** (Material reconciliation) | Whether an app that keeps Material can trust either palette |
| **A1c → A2c** (control sizing) | The textScaler and density story, and every component touched afterwards |
| **A1e** (state tokens) | A0b and all of Workstream B |
| **E1** (DTCG import) | Audience B entirely |
| **B2a** (roving-focus extraction) | B2b, B2c, B2d |

---

## What each phase lets you say

Claims a team could check, not features.

**Today, unqualified:**

> 112 components at parity with `@mantine/core`, on a shared token
> system, with 42 golden images and 59 test files behind them.

**After Phase 1:**

> Theme your existing Flutter app from one source. Your widgets, not
> ours — `toThemeData()` covers what you already have, and component
> tokens cover what you build.

**After Phase 2:**

> And it stays right at 200% text scale, on a touch target, in RTL, in
> dark mode, with `boldText` and `highContrast` on.

Not one clause of that is available from `ThemeData` or a bare
`ThemeExtension`.

**After Phase 3:**

> Import the tokens you already have from Figma or Tokens Studio.
> Validate them in CI — contrast failures, broken references — before
> they reach a screen.

**After Phase 4:** add *"accessible"*, and mean something checkable by
it. Only add *"web"* if `B0c` came back clean.

---

## One note on how to use this

The audit's most valuable entry read: **"Already shipped — it has been
there all along, spelled `citation`. The list was never checked against
the source after it was written."**

This document is a written-down absence and will rot the same way.
Check each item against the source before building it, and when the
check says the gap is smaller than written — as it did for
`PlinthTabs` in 0.25.0 — record the correction rather than the fix.

This roadmap went through four framings before the audience question
was asked. The work list barely moved across them; the ordering moved a
great deal. Worth remembering next time a plan feels wrong: **the
question was who it was for, not what to call it.**
