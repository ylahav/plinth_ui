# Plinth Core — Gap Analysis

*Analysis only. No source, test, dependency or version was changed. First written 26 Oct
2026 against `main` at `plinth_core` 1.11.0, then **revised the same day after a skeptical
maintainer review** (section 7). Flutter 3.47.8 locally, CI pinned to 3.44.8. Scores are
estimates, not market measurements.*

**Evidence labels:** **[V]** verified in source or by a probe I ran · **[D]** verified
deficiency (reproduced) · **[I]** inferred risk · **[U]** unverified.

> **Status, 26 Oct 2026.** Roadmap items **1** (dark-mode docs and test) and **5** (DTCG message) are
> committed (29daf8f). Item **2** (alpha-aware `validate()` and `textMuted` `0x8A` → `0x8C`) is done in the
> working tree: the smallest alpha that clears 4.5:1 on all three surfaces is `0x8C`, not the ~`0x91`
> estimated below — 4.55:1 worst case. Light goldens that paint muted text await regeneration on CI.
> Item **3** (`readableOn` direction) is committed (05cc506). Item **4** (SDK floors) is done and measured: see C-4, which turned out larger than predicted. Item 6 is not started.

> **What the review changed.** The first draft proposed eleven improvements, five of them
> new public APIs. The review kept **five**, none of which adds a public API, and removed
> six that would have increased the surface without removing a demonstrated problem. It
> also found a **new defect more serious than any in the first draft**: the README's
> own dark-mode snippet renders body text at **1.01:1**.

---

## 1. Executive summary

`plinth_core` is a small, well-tested engine (2,479 lines of `lib/`, 2,249 of tests, one
dependency). Its ideas work: ramps anchor to the brand colour exactly (0 misses in
200,000 random colours **[V]**), roles resolve against a named WCAG floor, `lerp`,
`copyWith` and `ThemeExtension` behave, and every hot path measures in microseconds
**[V]**. There is no performance work to do.

What needs attention is where the package's own *claims* are softest:

1. **The documented dark-mode setup is broken [D].** README line 141, the core README
   (line 114) and the `darkTheme` doc comment (`plinth_theme.dart:967`) all show
   `darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme])`. That leaves
   `ThemeData.brightness` light. `PlinthText` takes its colour from the inherited text
   style, so the text painted on a Plinth dark surface is `#1D1B20` on `#1A1B1E`:
   **1.01:1**, invisible. All four starter apps avoid it by setting
   `brightness: plinth.brightness`; the README does not. This is the failure I hit
   converting `gynescope-app`.
2. **`validate()` is blind to translucent text, and a shipped widget lands on the failing
   pair [D].** Light `textMuted` is 54 % black. Composited, it is 4.49:1 on `surfaceMuted`
   and 4.42:1 on `surfaceSunken`, under the 4.5:1 body floor. `validate()` returns `[]`
   because it measures the un-composited colour (17–21:1). `PlinthSegmentedControl` paints
   its track in `surfaceMuted` (`plinth_segmented_control.dart:259`) and its unselected
   labels in `textMuted` (`:358`).
3. **`readableOn` can miss a passing shade on mid-tone backgrounds [D]**, because it picks
   its search direction at luminance 0.5 rather than ≈ 0.18. Exposure is **adopters only**:
   38 of the library's 47 call sites pass `theme.surface`.
4. **The Flutter floor (`>=3.22.0`) is probably wrong [I]**: the source uses `Color.r` and
   `withValues`, introduced in 3.27. Unverified, so verify before editing.
5. **DTCG import mislabels a rejection [D]**: a valid path whose value is a 2025.10
   `{value, unit}` object is reported as "no Plinth token matches this path".

**Recommended direction: shrink, don't grow.** Five small changes, zero new public APIs,
in this order: fix the dark-mode docs and pin them with a test; make `validate()` composite
alpha and clear the two light-theme failures; fix `readableOn`'s direction; verify then
correct the SDK floor; fix one error message. Everything else in the first draft is
deferred or rejected, with reasons in sections 7 and 10.

---

## 2. Current architecture

`packages/plinth_core/` — 1.11.0, `sdk >=3.4.0 <4.0.0`, `flutter >=3.22.0`, depends only on
`flutter`. Six exports (`lib/plinth_core.dart`).

| File | Lines | Responsibility |
|---|---|---|
| `lib/src/plinth_theme.dart` | 1322 | `PlinthTheme` (`ThemeExtension`), default/dark themes, `generateShades`, contrast and role resolution, `copyWith`, `lerp`, `context.plinth`, `ThemeData.plinth` |
| `lib/src/plinth_dtcg.dart` | 418 | `PlinthDtcg.export` / `parse`; result carries `applied` and `ignored` |
| `lib/src/plinth_token.dart` | 255 | `PlinthToken`, tiers, types, `theme.tokens` |
| `lib/src/material_bridge.dart` | 188 | `toColorScheme`, `toTextTheme`, `colorSchemeDisagreements` |
| `lib/src/plinth_validation.dart` | 149 | `theme.validate()` |
| `lib/src/tokens.dart` | 138 | `PlinthSize`, `PlinthVariant`, `PlinthRole`, `PlinthDensity`, `PlinthWeight`, `PlinthCurve`, `PlinthShadow` |

**Token model [V].** Named ramps (13 built in × 10 shades), `primaryColor`, an app-owned
role namespace (`semanticColors`), a library-owned one (`roleRamps`: error, neutral,
success), a categorical series palette, five enum-keyed scales (spacing, radius, font
size, border width, duration), weights, curves, elevations, a density floor and twelve
neutral colours. A const spacing scale, `PlinthSpacing`, sits outside the theme.

**Dependents [V], counted from source:**

| Core API | components | blocks | charts | templates |
|---|---|---|---|---|
| `context.plinth` / `.plinth` | 159 | 34 | 6 | 14 |
| `readableOn(` | 35 | 8 | 4 | 0 |
| `contrastingOn(` | 14 | 0 | 0 | 0 |
| `.shaded(` | 69 | 2 | 2 | 0 |
| `spacing[` / `.space(` | 156 / 1 | 6 / 72 | 3 / 9 | 0 / 52 |
| `fontSizes[` | 37 | 3 | 11 | 0 |
| `.semantic*` / `.series(` | 0 / 0 | 0 / 0 | 0 / 4 | 4 / 1 |
| `generateShades` | 0 | 0 | 0 | 6 |
| `validate()` / `colorSchemeDisagreements` | 0 | 0 | 0 | 0 |
| `PlinthSpacing.` | 0 | 0 | 0 | 0 |

Two readings matter. **Nothing in the ecosystem calls `validate()` or
`colorSchemeDisagreements`**, so the headline checks run only in their own tests; they
cannot have caught anything in a shipped widget. And **the const `PlinthSpacing` scale has
zero users**, against 134 non-const `.space()` calls. Version constraints:
`plinth_components` pins `plinth_core ^1.5.0`, `plinth_charts` `^1.3.0`, lockstep releases.

---

## 3. Capability matrix

| Area | Status | Existing implementation | Gap | Evidence | Priority |
|---|---|---|---|---|---|
| **A. Token model** | PARTIAL | Colour, spacing (two scales), radius, border width, elevation, motion, font size and weight; open `colors` / `semanticColors` maps | No line height, letter spacing, family, opacity or sizing; scales keyed by a five-value enum. **None of these has a demonstrated user problem** | `plinth_theme.dart:537-564`; conversion findings | none |
| — Component tokens | NOT NEEDED | — | Every conversion gap was composition, not tokens | `docs/ROADMAP.md` | REJECT |
| — Opacity | NOT NEEDED | — | `withValues(alpha:)` is the platform's answer | `plinth_theme.dart:97,745` | REJECT |
| **B. Colour generation** | COMPLETE for the claim | HSL ramp re-anchored so shade 6 is the input | Near-white / near-black bases collapse part of the ramp (152 of 200,000 random colours < 8 distinct shades); documented trade-off | `:1010-1089`; probes C, D | none |
| **C. Contrast** | PARTIAL | WCAG 2.x arithmetic, three floors, `readableOn`, `contrastingOn` | Two bugs (§4: C-2, C-3) | `:714-796`; probes A, B | **P0** |
| **D. Semantic roles** | COMPLETE for demonstrated use | `semanticColors` (ramp, shade, floor); `semantic`, `semanticText`, `semanticWash` | No warning/info role in `PlinthRole`; app roles cover it | `:400-431,820-859` | none |
| **E. Typography / non-colour** | PARTIAL | Size and weight; `toTextTheme` | Stops at size and weight; no evidence it hurts | `material_bridge.dart` | none |
| **F. Flutter integration** | PARTIAL | `ThemeExtension`, `copyWith` (29 fields), `lerp`, `ThemeData.plinth`, Material bridge | **The documented dark setup is wrong (C-1)** | `:1092-1223,1319`; probe H | **P0** |
| **G. Validation** | PARTIAL | `validate()` over text, muted text, border × 3 surfaces + series | Alpha-blind (C-2) | `plinth_validation.dart:72-148` | **P0** |
| **H. Extensibility** | COMPLETE for demonstrated use | Custom ramps, roles, series, any scale via `copyWith` | Nested overrides: Flutter's `Theme` already does it | — | none |
| **I. Performance** | COMPLETE | Sub-millisecond everywhere (probe E) | None | probe E | none |
| **J. Compatibility** | PARTIAL | Lockstep, additive discipline, README claims pinned by tests | SDK floor untested and probably wrong (C-4) | `pubspec.yaml:23-24`; `ci.yml:30` | P1 |
| **DTCG interop** | PARTIAL, honest | Reads references and group `$type`; reports `ignored` | Reads/writes the pre-2025.10 string syntax and says so nowhere; one mislabelled message (C-5) | `plinth_dtcg.dart`; probe G | P2 |

---

## 4. Correctness and testing findings

### Confirmed

**C-1 — The documented dark-mode setup renders unreadable text.** [D] *(new in revision)*
- *Where:* `README.md:141`, `packages/plinth_core/README.md:114`,
  `plinth_theme.dart:967`, all `darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme])`;
  README line 148 adds "Registering `darkTheme` is all dark mode takes."
- *Why it fails:* `ThemeData()` defaults to light, and `MaterialApp` does not force the
  `darkTheme` slot's brightness. `PlinthText` passes `color: null` unless asked
  (`plinth_text.dart:56-65`), so it inherits Material's text style, which follows
  `ThemeData.brightness`.
- *Reproduction (probe H, snippet verbatim, `themeMode: dark`):* `ThemeData.brightness`
  light, `PlinthTheme.brightness` dark; painted text `#1D1B20`, `PlinthTheme.surface`
  `#1A1B1E`, **1.01:1**; scaffold background `#FEF7FF` (light).
- *Control (probe I, the starters' recipe):* adding `brightness: plinth.brightness` and
  `colorScheme: plinth.toColorScheme()` gives painted text `#C1C2C5` on the surface,
  **9.67:1**. All four starters already do this
  (`templates/*/lib/src/theme.dart`, e.g. `blog` line 36).
- *Why nothing caught it:* no test builds the README snippet. `plinth_readme_claims_test.dart`
  pins the *numbers* the README quotes, not the snippets' behaviour.
- *Real-world hit:* converting `gynescope-app` produced black text on a dark page until its
  `ThemeData` got `brightness: Brightness.dark`.

**C-2 — `validate()` cannot see translucent tokens, and a shipped widget lands on the
failing pair.** [D]
- *Where:* `plinth_validation.dart:85` passes the raw token to `contrastRatio`;
  `kLightText = 0xDD000000`, `kLightTextMuted = 0x8A000000` (`plinth_theme.dart:220-221`);
  `contrastRatio` documents "both colours must be opaque" (`:782`).
- *Reproduction (probe A):*

  | pair | `validate()` computes | composited |
  |---|---|---|
  | `textMuted` on `surface` | 21.00 | 4.61 |
  | `textMuted` on `surfaceMuted` | 18.88 | **4.49** |
  | `textMuted` on `surfaceSunken` | 17.71 | **4.42** |

- *Existing tests miss it:* `plinth_contrast_test.dart:44-58` composites correctly but only
  against `surface`; `plinth_validation_test.dart:15` passes because `validate()` returns `[]`.
- *Live pair:* `PlinthSegmentedControl` — track `theme.surfaceMuted` (`:259`), unselected
  label `theme.textMuted` (`:358`) — is 4.49:1 in the light theme [D by code reading].
  `plinth_stepper`, `plinth_timeline` and `plinth_cascader` use `textMuted` and
  `surfaceSunken` in the same file; whether those two meet on screen is [U].

**C-3 — `readableOn` chooses direction at luminance 0.5.** [D]
- `plinth_theme.dart:724`. Contrast against black equals contrast against white at ≈ 0.179,
  so between 0.179 and 0.5 the code lightens when it should darken.
- Probe B: greys 0–255 step 5 × 13 ramps → **40 of 676 results fail 4.5:1 while a passing
  shade exists** (e.g. `violet` on luminance 0.283 returns 2.79:1).
- **Exposure is adopter-only [V]:** of the library's call sites, 38 pass `theme.surface`,
  one `surfaceMuted`, and the rest tinted washes (`plinth_alert.dart:95`,
  `plinth_pill.dart:66` use `shaded(color, 0)` and `shaded(color, 1)`, a light tint in the light theme and its mirrored dark in the dark one). No shipped widget calls
  it on a mid-tone fill.

**C-4 — The declared SDK floor was wrong in four of five packages, and for
`plinth_components` by sixteen minor versions (3.22 to 3.38).** [D] *(measured; was inferred)*
- Every package declared `flutter >=3.22.0`, `sdk >=3.4.0`. I installed real SDKs side by
  side and compiled each package's `lib/` (`flutter analyze lib`) from a clean `git archive`
  of `HEAD`, so no lockfile or build output of the working tree was involved:

  | Flutter | `plinth_core` | `plinth_components` | what is missing |
  |---|---|---|---|
  | 3.24.5 (last stable before 3.27) | **14 errors** | — | `Color.r/.g/.b/.a`, `Color.withValues` |
  | 3.27.0 | clean | **9 errors** | `Color.toARGB32` (7), `supportsAnnounceOf`, `sendAnnouncement` |
  | 3.32.0 | clean | **2 errors** | `supportsAnnounceOf`, `sendAnnouncement` |
  | 3.35.0 | clean | **1 error** | `sendAnnouncement` |
  | 3.38.0 | clean | clean | — |
  | 3.41.0 | clean | clean | — |

  `plinth_hooks` passes its tests on 3.24.5 and `plinth_charts` is clean on 3.27.0, so
  hooks keeps its floor and charts follows core.
- **Measured floors:** `plinth_core` and `plinth_charts` **3.27.0**; `plinth_components`
  and `plinth_blocks` (which builds on it) **3.38.0**; `plinth_hooks` unchanged. CI tested
  only 3.44.8 (`ci.yml:30`), which is why none of this was ever seen.
- **A trap found while fixing it:** `sdk: ">=3.10.0"` is *refused* by Flutter 3.38.0, whose
  bundled Dart reports itself as `3.10.0-290.4.beta`, a pre-release that sorts below
  `3.10.0`. The `flutter:` constraint is the real gate, so the Dart bound for
  components and blocks is `>=3.9.0`. Each new constraint was checked both ways: `pub get`
  refuses below the floor with a clear Flutter-version message and resolves at it.
- **Limits of the fix:** versions already published (components 1.5–1.11) keep their wrong
  declarations, and pub can still fall back to one of them. Only releases from 1.12 on are
  protected.
- **Side finding, dev-only:** `flutter_lints >=6.0.0` in `dev_dependencies` needs Dart 3.8,
  so contributors need a Flutter newer than 3.32 to run `pub get` in the repo. It does not
  reach consumers.

**C-5 — DTCG import mislabels a valid path.** [D]
- Probe G: `spacing.md` as `{value: 18, unit: px}` and `duration.sm` as
  `{value: 120, unit: ms}` are reported as `no Plinth token matches this path`
  (`plinth_dtcg.dart:276`). Both paths exist; the *value shape* was rejected. Group-level
  `$type` inheritance works, and the colour object case is labelled correctly
  (`:175,193`).

### Known limitations, not proposals

- **DTCG export is not 2025.10-conformant** [D]: colour as `"#228be6"`, dimension as
  `"16px"`, curve as the name `"easeOut"`, a non-conformant shadow
  ([Format](https://www.designtokens.org/TR/2025.10/format/),
  [Color](https://www.designtokens.org/TR/2025.10/color/) modules). The review concluded
  this is a *documentation* problem until a consumer of the file exists (section 7).
- **Ramps collapse at extreme bases** [D] (probe D) — documented in the source comment.
- **A missing `primaryColor` key throws a bare `_TypeError`; any other unknown ramp
  silently becomes the primary colour** [D], and `validate()` checks neither.
- **`readableOn` returns the ramp extreme with no signal when nothing clears the floor**
  [V]; `contrastRatio` is public, so a caller can check in one line.
- **No `==`/`hashCode` on `PlinthTheme`** [I], and **`Color.r` may leave 0–1 for wide-gamut
  colours** [I]. Neither was measured.

### What the tests do cover well [V]
Anchor round trip, ramp monotonicity, every ramp against both themes for fills, accents and
tints, role floors, wash staying near the surface, series colour-blindness scoring, `lerp`
including its documented light↔dark limit, README *numbers*, and DTCG round trips.

---

## 5. Competitive analysis

Fetched 26 Oct 2026 from pub.dev. "Not stated" means the page did not say, not that the
capability is absent.

| | `plinth_core` 1.11.0 | `design_builder` 1.0.1 | `design_tokens_generator` 1.0.5 |
|---|---|---|---|
| Published | 8 days ago | ~5 months ago | ~14 months ago |
| Likes / points / downloads | 0 / 160 / 897 total | 1 / 160 / 53 | 1 / 140 / 59 |
| Approach | Runtime `ThemeExtension` | **Build-time** codegen of a `ThemeExtension` from W3C-style tokens | **Build-time** codegen of M3 theme and Dart classes |
| Colour generation | Anchored 10-shade ramps | Not stated | Resolves references; picks M3 seed colours |
| Contrast-aware resolution | **Yes** | Not mentioned | Not mentioned |
| Validation | `validate()`, `colorSchemeDisagreements` | Not stated | Not stated |
| Import / export | DTCG parse + export (pre-2025.10 syntax) | JSON import with `$variables`; export not mentioned | DTCG / Style Dictionary / Figma not mentioned |
| Runtime customisation | `copyWith`, `lerp` | `applyOverrides` / `clearOverrides` | Not stated |
| Code generation | None | Yes | Yes |

Sources: [plinth_core](https://pub.dev/packages/plinth_core),
[design_builder](https://pub.dev/packages/design_builder),
[design_tokens_generator](https://pub.dev/packages/design_tokens_generator).

The two alternatives are *translators*: they turn a token file into Dart. Neither page
mentions contrast, validating an existing theme, or deriving colour from a brand.
`plinth_core` is a *runtime engine that judges colours*; they are adjacent rather than
competing. Not re-verified today **[U]**: Forui and Mix, named in `docs/ROADMAP.md`'s
internal comparison (checked 20 Aug 2026). Adoption is tiny everywhere, so no package is
the incumbent.

---

## 6. Recommended positioning

**Primary statement:** *The Flutter token engine that tells you when your brand colours
stop being readable — and fixes the ones it can.*

**Evidence:** it is the one capability the verified alternatives do not mention; its own
history shows `validate()` finding real defects in Plinth's defaults (border 1.26:1, dark
`textMuted` 4.36:1); and this audit found a third that the validator itself could not
see. **That last point is the honest limit of the positioning today:** the claim is only as
strong as the validator, and nothing in the ecosystem calls the validator (§2).

**Who benefits:** a team with designer-chosen brand colours, an existing `ThemeData`, and
an accessibility obligation. **Avoid becoming** a token compiler, a runtime JSON theme
loader, a general theming framework, or a component-token system.

**Accessibility claims stay narrow.** Contrast arithmetic checks colour pairs; it does not
make an interface WCAG-compliant. Criteria involved: 1.4.3 Contrast (Minimum) — 4.5:1
normal text, 3:1 large; 1.4.11 Non-text Contrast — 3:1; 2.5.8 Target Size (Minimum) —
24 × 24, which `PlinthDensity.standard` encodes.

---

## 7. Skeptical maintainer review of every proposal

*Perspective: a maintainer who would rather delete code than add it. For each proposal from
the first draft: is there a user problem with evidence, what is the simplest alternative,
and does it belong in core?*

| # | First-draft proposal | Real problem? | Simplest alternative | Belongs in core? | Verdict |
|---|---|---|---|---|---|
| 1 | Alpha-aware `validate()` + fix light `textMuted` | **Yes.** 4.49 / 4.42 verified; a shipped widget (segmented control) paints the pair | (a) make the light tokens opaque, so no alpha reaches the validator; (b) only nudge the alpha | **Yes** — validator and tokens both live here | **KEEP, reshaped.** Composite alpha in `validate()` (3 lines) *and* fix the token. (a) alone is rejected: an adopter's own translucent tokens would still fool the validator, which is the product |
| 2 | Fix `readableOn` direction | **Yes, adopters only** (0 shipped call sites on mid-tones) | Pick the direction by comparing the contrast at the two ramp ends; no new API | **Yes** — it is a bug in a documented contract ("first shade that clears the floor") | **KEEP, lower urgency.** A few lines; no golden impact; no API |
| 3 | Correct and test the SDK floor | **Probably** [I] — unverified | Edit the constraint number; skip the CI matrix | **Yes** — `pubspec.yaml` | **KEEP as verify-then-edit.** Compile once on 3.26 and 3.27 by hand (~30 min); only then edit four pubspecs. **Drop the CI matrix cell** until a second reason appears *(revisited after measuring: the floors were off by up to sixteen minor versions, so a cheap job that runs `flutter analyze lib` on core at 3.27.0 and on components at 3.38.0 is now justified; the tests cannot run there, they use `toARGB32`. Not added)* |
| 4a | `validate()` checks roles resolve | **No evidence.** `readableOn` already walks to a passing shade; a role that cannot pass needs an impossible floor | A test in the adopter's own suite using `contrastRatio` | Marginal | **REMOVE** |
| 4b | `validate()` checks references (primary / role / series ramps exist) | **Weak.** One documented footgun, no incident | `hasColor()` already exists | Yes, but it is a new surface | **REMOVE.** Reopen on a real report |
| 4c | Brightness mismatch in `colorSchemeDisagreements` | **Yes, but wrong fix.** Nobody calls `colorSchemeDisagreements` (§2); the real cause is the docs (C-1) | Fix the README snippet; pin it with a test | Docs | **REPLACED by C-1's docs fix** |
| 5 | `readableOnChecked` | **No.** Nobody reported a silent-fallback harm | `PlinthTheme.contrastRatio(readableOn(...), bg) >= floor` — public, one line | Duplicates existing API | **REMOVE** |
| 6 | `PlinthTheme.fromSeed(...)` | **No.** `generateShades` is already public (the ROADMAP item was "promote the generator"). Each starter's `_brand` is ~6 lines: `copyWith(primaryColor, colors: {...base.colors, 'brand': generateShades(c)})`. `fromSeed` would save about four | A documented recipe | Sugar | **REMOVE.** Feature count only. Four starters by one author is also one data point |
| 7 | Debug warning in `ThemeData.plinth` when unregistered | **No evidence** anyone forgot registration; README step 1 says it is required | Docs | — | **REMOVE.** The failure that actually bit was brightness, not registration |
| 8 | Breakpoint tokens + `context` query | **Weak.** Three apps already write `MediaQuery.sizeOf(context).width >= N` — Flutter's own answer. Their thresholds (1000; 850 / 1100; 760) match neither each other nor Mantine's, so a shared token would not have helped any of them | One line per use | **No.** It needs layout context; if it exists at all it is a `plinth_components` convenience | **REMOVE from core.** ⚠ I added a "breakpoint query and builder" item to `docs/ROADMAP.md` and `docs/VISION.md` on 25 Oct from the same evidence; this review does not support it. See "Follow-ups" |
| 9a | Fix the mislabelled DTCG rejection message | **Yes** — sends a user hunting for a typo | None needed | Yes | **KEEP.** One string |
| 9b | Read 2025.10 object forms | **Unproven.** No design file has ever been offered (ROADMAP rung 2 has no taker) | Document which syntax is supported | Yes, if ever | **DEFER** until a real file arrives |
| 9c | Write 2025.10 on export | **No consumer.** It would change output for anyone consuming today's strings | Document the limitation | — | **REMOVE** |
| 10 | Diagnostic for collapsed ramps | **Rare** — 0.08 % of random colours, only extreme brand colours | The source comment already explains it | — | **REMOVE** |
| 11 | Typography tokens (line height, letter spacing, family) | **No evidence in core.** Flutter's `TextTheme` carries all three, and the Material bridge exists | The adopter's own `TextTheme` | Duplicates Flutter | **REMOVE** |
| — | *New:* fix the dark-mode docs and pin them | **Yes.** C-1: 1.01:1 from the project's own snippet, and my own conversion hit it | Edit three snippets; add one test that builds the README example | **Yes** — first five minutes of adoption | **ADD, P0** |

**Result:** 11 proposals → **5 kept** (the docs fix, #1, #2, #3, #9a), 0 new public APIs.
The first draft would have added `readableOnChecked`, `fromSeed`, `validateStructure`,
`breakpoints` and a 2025.10 writer.

**Two things the review would not let me assume.**
- *The weighted scores in the first draft were too kind to features.* "Differentiation 4/5"
  for DTCG 2025.10 export rests on a competitor claim I could not verify, and "user value
  3–4" for `fromSeed` and breakpoints rested on the author's own apps, which carry the
  discount the ROADMAP already names. Scores are dropped for the kept items; the table
  above is the decision.
- *Plinth's own validator is not used by Plinth.* Before proposing a broader `validate()`,
  the maintainer question is why `validate()` runs in zero shipped places (§2). The cheapest
  way to make it matter is to run it in the starters' tests — which would have surfaced
  C-2 months ago — not to add checks.

---

## 8. Prioritised roadmap (after review)

Do not assign dates. Each item is independent unless noted.

| Order | Change | Class | Size | Public API | Why this order |
|---|---|---|---|---|---|
| 1 | Fix the dark-mode snippet in three places; add a test that builds it | P0 | XS | none | Worst finding, cheapest fix, no golden impact. Also *explains* the gynescope failure |
| 2 | Composite alpha in `validate()`; then raise light `textMuted` until all three surfaces clear 4.5 | P0 | S | none | Order matters: land the validator change first and watch it fail, then fix the token |
| 3 | `readableOn`: choose direction by end-of-ramp contrast | P0 (minor) | XS | none | Adopter-facing only; no shipped widget moves |
| 4 | ~~Verify the SDK floor~~ **Done:** measured on 3.24.5 / 3.27.0 / 3.32.0 / 3.35.0 / 3.38.0 / 3.41.0; four pubspecs corrected | P1 | XS | none | Cheap once verified |
| 5 | DTCG: report "value shape not understood" instead of "no token matches this path"; add one README sentence naming the supported syntax | P2 | XS | none | Honesty fix |
| 6 | *(Process, not code)* Run `theme.validate()` in the four starters' tests | P1 | XS | none | Gives the validator its first real caller |

**Deferred, with a trigger:** DTCG 2025.10 *read* support — when a real design file is
offered; reference/role validation — when an adopter reports a typo that rendered silently;
`PlinthTheme` equality — after measuring avoidable rebuilds.

---

## 9. Proposed changes

*Proposals, not existing code.*

**1 — docs (the three snippets, and a test).**
```dart
darkTheme: ThemeData(
  brightness: PlinthTheme.darkTheme.brightness,
  colorScheme: PlinthTheme.darkTheme.toColorScheme(),
  extensions: [PlinthTheme.darkTheme],
),
```
mirroring the starters. Replace "Registering `darkTheme` is all dark mode takes" with what
is true: the extension *and* matching `ThemeData` brightness.

**2 — alpha-aware validation, no signature change.**
```dart
final fg = foreground.a < 1 ? Color.alphaBlend(foreground, background) : foreground;
final ratio = PlinthTheme.contrastRatio(fg, background);
```
then raise `kLightTextMuted`'s alpha from `0x8A` until the worst surface clears 4.5. The
required value must be computed, not guessed.

**3 — direction by outcome.**
```dart
// readableOn: step toward whichever end of the ramp has more contrast with the
// background, instead of testing relativeLuminance(background) > 0.5.
```

No new public API is proposed in this revision.

---

## 10. Testing and acceptance criteria

| # | Test | Acceptance |
|---|---|---|
| 1 | Widget test that builds the README dark snippet verbatim and asserts the painted `PlinthText` colour clears 4.5:1 on `PlinthTheme.surface` | Fails on today's snippet (1.01:1); passes on the corrected one (≥ 9:1) |
| 2 | (a) `validate()` returns the C-2 finding for the **current** light theme; (b) after the token fix it is `[]`; (c) a deliberately failing translucent token is caught | (a) is written first and seen to fail. Then component goldens (`PlinthSegmentedControl` and any other `textMuted` consumer) regenerated and reviewed |
| 3 | Property test: for every ramp × grey 0–255, `readableOn` passes whenever any shade passes | 0 misses (was 40 / 676); `plinth_contrast_test.dart` and the README claims test unchanged |
| 4 | Manual compile of `plinth_core` at Flutter 3.26 and 3.27 | Decision recorded in the changelog either way |
| 5 | Unit: `parse` on a `{value, unit}` dimension yields a *shape* reason, never "no Plinth token matches" | No misleading message for a valid path |
| 6 | Starters' tests call `theme.validate()` | Starters stay green after #2 |

Compatibility gate for #2 and #3: run `plinth_components`, `plinth_blocks`,
`plinth_charts` and all four `templates/` against the changed core. **Core tests passing is
not sufficient** — `readableOn` and `textMuted` feed 159+ widget reads and 43 golden
images. Performance tests are not justified (probe E: `readableOn` ≈ 0.27 µs, `generateShades`
≈ 1.5 µs, `tokens` ≈ 34 µs, `validate` ≈ 10 µs per call).

---

## 11. Rejected ideas

Original rejections, unchanged: **a token compiler / codegen pipeline** (`design_builder`
covers it; the ROADMAP's "Not doing" argues static constants cannot express `textScaler`,
density or `readableOn`); **runtime JSON theme loading** (no evidence anyone needs
server-driven theming); **component tokens in core** (no conversion finding was a token
gap); **opacity tokens** (`withValues` is the platform's answer); **a perceptual / OKLCH
ramp** (changes every app's palette, no measured defect, and a hue-drift tweak was already
tried and reverted at `plinth_theme.dart:994-1009`); **caching** (nothing to save); **a
general diagnostics framework**; **a nested-override widget** (`Theme(data: ...copyWith(
extensions: ...))` is Flutter's answer).

**Added by the review:** `readableOnChecked`; `PlinthTheme.fromSeed`; a debug warning in
`ThemeData.plinth`; breakpoint tokens and a breakpoint query; reference and role checks in
`validate()`; a collapsed-ramp diagnostic; typography tokens; and a 2025.10 *export*. Each
either solves a problem nobody has reported, duplicates an existing one-line idiom, or
belongs outside core.

---

## 12. Final recommendation

**Single highest-priority improvement:** fix the dark-mode snippet in the READMEs and the
`darkTheme` doc comment, and pin it with a test. It is the only finding that every adopter
following the documentation will hit, it takes minutes, and it needs no release-risk
decisions.

**Next three:** (2) alpha-aware `validate()` then the `textMuted` fix; (3) `readableOn`
direction; (4) verify the SDK floor on 3.26 / 3.27.

**Work that should not be undertaken:** everything in section 11, plus any new public API
this quarter.

**Follow-ups outside this report**
- `docs/ROADMAP.md` (Goal section and the "Backlog it adds" list) and `docs/VISION.md`
  (the adaptive-layout row) say a breakpoint query and builder is an *open* item. The
  review does not support that; both should be reworded once you agree. I did not edit
  them: you asked for this report only.
- `plinth_components` question: should `PlinthText` and other widgets that print text with
  no colour fall back to `theme.text` rather than the inherited text style? That would have
  made C-1 harmless. It is a components change with a behaviour risk for apps that rely on
  inherited styles, so it is raised, not recommended.

**Unresolved questions for a human:**
1. **Raise the light `textMuted` alpha** (secondary text slightly darker in every light app,
   goldens move) **or document an exception?** The project has precedent for changing
   defaults when `validate()` finds a failure.
2. **Is `PlinthSegmentedControl`'s 4.49:1 acceptable until the token changes?** It misses by
   0.01, which is in the range where a rounding difference decides pass or fail.
3. **What Flutter minimum do you want to support?** Answered by item 4 once measured.
4. **Does `stepper` / `timeline` / `cascader` paint `textMuted` on `surfaceSunken`?**
   Not traced.
5. **`PlinthTheme` equality** — worth measuring?

---

## Appendix — probes (outside the repo)

`scratchpad/probe`, Flutter 3.47.8. Nothing under `packages/` was modified.

| Probe | Result |
|---|---|
| A — translucent text | validate arithmetic 17.71–21.00; composited `textMuted` 4.61 / 4.49 / 4.42; `validate()` → `[]` |
| B — `readableOn`, greys 0–255 step 5 × 13 ramps | 40 / 676 miss a passing shade, from luminance ≈ 0.28 |
| C — extreme bases | `#FFFFFF` 4 distinct shades; `#FFFFF0` 7; `#000000` 7; `#0A0A0A` 7; hue-extreme colours 10 |
| D — 200,000 random colours | 0 anchor misses; 0 non-monotonic; 152 with < 8 distinct shades |
| E — timing | `generateShades` 20,000× = 30 ms; `readableOn` 100,000× = 27 ms; `tokens` 1,000× = 34 ms (191 tokens); `validate` 200× = 2 ms; `lerp` 20,000× = 13 ms |
| F — fallbacks | unknown ramp → primary (silent); missing primary → `_TypeError`; impossible 7:1 floor → 3.62:1 returned; translucent background accepted |
| G — DTCG | group `$type` inheritance works; `{colorSpace, components}` colour rejected correctly; `{value, unit}` dimension and duration rejected with a **wrong** reason; export emits `"#228be6"`, `"16px"`, `"easeOut"` |
| H — README dark snippet, verbatim | `ThemeData.brightness` light, `PlinthTheme.brightness` dark; painted text `#1D1B20` on `#1A1B1E` = **1.01:1**; scaffold `#FEF7FF` |
| I — starters' recipe | painted text `#C1C2C5` on surface = **9.67:1** |

**Limits.** Older Flutter versions were not installed, so C-4 is inferred. Whether `stepper`,
`timeline` and `cascader` paint the failing pair on screen was not traced. Competitor facts
come only from their pub.dev pages. Timings are VM-test microbenchmarks. The review itself
is one reviewer's judgement; where it removed a proposal for lack of evidence, the trigger
for reopening it is stated.
