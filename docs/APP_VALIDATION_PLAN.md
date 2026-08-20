# Validating Plinth against `financial-organizer`

How one real app is used as a standing test harness for `plinth_core`
and `plinth_components`. Findings from these tracks are collected as numbered requirements in
[ADOPTION_REQUIREMENTS.md](ADOPTION_REQUIREMENTS.md). Companion to
[TESTING.md](TESTING.md) (which covers the unit/golden tests *inside*
this repo) and [PHASE_MINUS_1_FINDINGS.md](PHASE_MINUS_1_FINDINGS.md)
(the first run of track T2 below).

> **Status, 20 Aug 2026.** Track T2 has run once, and produced the
> fifteen requirements in ADOPTION_REQUIREMENTS.md — **all now closed**,
> along with four more that closing them exposed. The harness itself is
> still live: the value of a standing harness is the *second* run,
> against packages that have changed underneath it. Nothing here is
> historical.

**The distinction that matters:** TESTING.md tests Plinth against
itself. This plan tests Plinth against something that does not care
about Plinth — an app with its own deadlines, its own palette, its own
Hebrew, and 202 tests of its own that will not be rewritten to make a
component pass.

## The subject, and what it is worth

`C:\projects\flutter\financial-organizer` — private local-first
personal-finance app for an Israeli household. Hebrew/English with RTL,
70 Dart files, 202 tests, desktop + mobile targets.

Coverage it actually gives, measured 18 Aug 2026 at
`plinth_components 0.25.0`:

| | Count |
|---|---|
| Components in `plinth_components` | 115 |
| Components the app uses | **32 (28%)** |
| Plinth symbol references in app code | 546 |
| Heaviest: `PlinthText` / `PlinthButton` / `PlinthTitle` | 101 / 44 / 27 |

### What the 28% buys

The app is a **data-dense, read-heavy desktop app with forms**. It
exercises exactly that slice, hard and with real data:

`PlinthAppShell` `PlinthNavLink` `PlinthDrawer` `PlinthBurger`
`PlinthTable` `PlinthDataList` `PlinthCard` `PlinthPaper`
`PlinthText` `PlinthTitle` `PlinthButton` `PlinthActionIcon`
`PlinthSelect` `PlinthTextInput` `PlinthNumberInput`
`PlinthPasswordInput` `PlinthFileButton` `PlinthSwitch`
`PlinthSegmentedControl` `PlinthModal` `PlinthMenu` `PlinthTooltip`
`PlinthAlert` `PlinthBadge` `PlinthChip` `PlinthEmptyState`
`PlinthProgress` `PlinthRingProgress` `PlinthRollingNumber`
`PlinthScroller` `PlinthThemeIcon` `PlinthNotification`

### What it does not cover — state this every time

83 components are never instantiated. The gaps cluster, and the
clusters matter:

| Cluster | Untested | Includes |
|---|---|---|
| Forms beyond the basics | 17 | `checkbox`, `radio`, `slider`, `range_slider`, `autocomplete`, `combobox`, `multi_select`, `tags_input`, `pin_input`, `rating`, `textarea`, `fieldset`, `cascader`, `tree_select` |
| Layout primitives | 12 | `flex`, `grid`, `simple_grid`, `stack`, `group`, `splitter`, `space` |
| Overlays | 9 | `popover`, `hover_card`, `dialog`, `floating_window`, `loading_overlay` |
| Navigation | 7 | `tabs`, `stepper`, `pagination`, `breadcrumbs`, `menubar`, `tree` |
| Colour pickers | 6 | the entire `color_*` / `*_slider` family |
| Display / content | ~27 | `avatar`, `timeline`, `carousel`, `skeleton`, `loader`, `code`, `kbd`, `pill` |

**`checkbox` and `radio` being absent is the sharpest hole** — they are
among the most accessibility-sensitive widgets in the set, and this app
will never tell you anything about them.

So: this app is a *depth* instrument, not a *breadth* one. It cannot
replace the 65 test files in `packages/*/test`. It tests things those
files structurally cannot.

About 19 more of the 83 could be adopted honestly, taking coverage to ~43% —
see [Adoption backlog](#adoption-backlog). The rest never will be.

## Wiring

The app consumes published packages by default. To point it at working
copies, add to the app's `pubspec.yaml`:

```yaml
dependency_overrides:
  plinth_core:
    path: ../plinth_ui/packages/plinth_core
  plinth_components:
    path: ../plinth_ui/packages/plinth_components
  plinth_hooks:
    path: ../plinth_ui/packages/plinth_hooks
```

**It must be `dependency_overrides`, not `dependencies`.** A path
dependency in `dependencies` fails version solving outright whenever a
published Plinth package depends on another by version constraint —
this is the first thing Phase −1 hit, before any Dart was written:

```
Because financial_organizer depends on plinth_components ^0.16.1 which
depends on plinth_core ^0.2.0, plinth_core from hosted is required.
So, ... version solving failed.
```

Remove the overrides to test the *published* packages instead. Both
modes are useful and they answer different questions (see T1).

> **Watch the pubspec.** Something in this workspace — most likely the
> VS Code Dart extension acting on an open `pubspec.yaml` — rewrote the
> app's version constraints twice unprompted during the Phase −1
> session, once mid-run. If a test result looks impossible, check
> `.dart_tool/package_config.json` for the version actually resolved
> before believing it.

## The six tracks

Each track answers a question the in-repo tests cannot. T1–T5 run on a
cadence; T6 is whatever the [adoption backlog](#adoption-backlog)
turns up along the way.

### T1 — Upgrade friction

*Does a version bump cost the adopter anything, and is the cost
findable?*

**Method.** Point the app at the new version, run `flutter analyze`,
`flutter test`, `flutter build windows --debug`. Record every call site
that had to change, and whether the compiler found it or a human did.

**Why it is the highest-value track:** it is the only one that measures
the promise Plinth makes in its own changelog — *"Every rename is a
compile error rather than a silent behaviour change, so an upgrade
either builds or tells you exactly where to look."* That claim is
testable exactly once per release, only from outside, and only against
code that was not updated in lockstep.

**Result so far.** 0.16.1 → 0.25.0, nine minor versions including the
deliberate 0.20.0 naming break: **2 call sites, 3 lines, both caught by
the compiler.** `PlinthNavLink(icon:` → `leadingIcon:`,
`PlinthRingProgress(size:` → `diameter:`. Six other 0.20.0 renames
didn't apply. Claim held.

**Pass:** every break is a compile error; none is a silent visual or
behavioural change.
**Fail:** anything that compiles and looks different. Escalate — that
is the class of bug this track exists to find.

### T2 — Token adoption

*Can an app with its own palette actually move onto the token layer,
and what does it have to build itself to get there?*

**Method.** Take a category of hardcoded value in the app and try to
express it through `PlinthTheme`. Record where it stops, what had to be
hand-written, and what the app kept hardcoding anyway. Full protocol and
first results in [PHASE_MINUS_1_FINDINGS.md](PHASE_MINUS_1_FINDINGS.md).

**Status: colour is done.** All 91 hardcoded colour values migrated;
the app now carries `lib/theme/app_tokens.dart` (110 lines) supplying
the semantic tier `plinth_core` does not define.

**Next, in order of what Phase −1 says will hurt most:**

1. ~~**Spacing.**~~ **Done 18 Aug 2026**, once `plinth_core` grew
   `PlinthSpacing` on a 4px base
   ([PR-07](ADOPTION_REQUIREMENTS.md#pr-07--a-spacing-scale-for-dense-ui)).
   314 of 353 literals converted, every one still `const`, T3's 54 cells
   unchanged. The 39 that missed the grid cluster on half-steps
   (`6` ×20, `2` ×10, `10` ×8) — the next question is whether those are
   a missing 2px sub-unit or drift to normalise.
2. **Radius** — 15 literals; `3`, `6`, `10` have no token.
3. **Typography** — 80 `textTheme` lookups, 0 `plinth.fontSizes`. This
   is where the Material-vs-Plinth reconciliation question (V-1) gets
   answered for real. Blocked on
   [PR-08](ADOPTION_REQUIREMENTS.md#pr-08--reconcile-with-materials-colorscheme).

**Pass:** the migration completes using only public API, and the
app-side token file gets *smaller*.
**Fail:** the app has to copy private code out of the package again
(as it did with `_generateShades`).

### T3 — The environment matrix

*Do the components survive conditions the in-repo tests never set?*

**Method.** Pump the app's six data-dense pages with real sample data
across the full cross-product, catching every `FlutterError` — layout
exceptions and overflows included.

| Axis | Values |
|---|---|
| Direction | `he`/RTL, `en`/LTR |
| Theme | light, dark |
| `textScaler` | 1.0, 1.3, 2.0 |
| `boldText` | off, on |
| Width | 1280 (desktop), 390 (mobile) |

**Built.** `test/plinth_matrix_test.dart` in the app — 4 test cases
covering 48 cells, asserted against a `kBaseline` map. A cell that gets
worse fails with the actual layout error; a cell that gets *better* also
fails, so the baseline is re-set deliberately rather than drifting.

**Baseline, 18 Aug 2026** — anything different is a regression:

| Condition | Result |
|---|---|
| RTL × LTR, 6 pages | **12/12 clean** |
| Dark theme, 6 pages | 6/6 clean |
| `textScaler` 1.0, 1.3 | clean |
| `textScaler` 2.0 | Portfolio overflows 26px *(pre-existing)* |
| `boldText` | clean, all 6 |
| 390px @ 1.0 | dashboard 36px, life-plan 78px, portfolio 26px *(pre-existing)* |
| 390px @ 1.3 | assets 18px *(pre-existing)* |

**Always separate "the app's bug" from "Plinth's bug"** by running the
harness against the app with the overrides removed. Phase −1 did this
and found the overflows byte-identical — which is what makes them
attributable at all.

**Pass:** no new exception under any cell.
**Fail:** any cell that is clean on published Plinth and dirty on the
working copy.

### T4 — Visual and palette drift

*Did anything change on screen that no test noticed?*

This track exists because of the most uncomfortable Phase −1 finding:
**the app's 202 tests passed, unchanged, through every intermediate
state of a full palette migration — including states where the rendered
colours were materially different.** Not one test asserts on a colour.
The suite would have signed off on a broken palette.

**Built.** `test/plinth_tokens_test.dart` in the app, 7 test cases.
Both live in the app rather than here, because they are about what an
*adopter* would see:

**T4a — Resolved-token snapshot.** 36 tokens per theme — fills, text
variants, washes, the 13 series colours, plus 4 of `plinth_core`'s own
chrome tokens as a canary — pinned as hex against a committed fixture.
A drift failure prints the changed keys *and* a paste-ready replacement
block, so re-baselining is one copy but never an accident.

**T4b — Contrast audit.** Three assertions per theme:

1. **Hard floor** — every text token ≥ 3.0:1 against its surface.
2. **Body-text set** — *which* tokens clear 4.5:1 is pinned as an exact
   set. As of 18 Aug 2026 that is **all seven, in both themes**: the app
   now calls `readableOn(minRatio: kBodyTextContrast)`. A token dropping
   out of the set fails.
3. **Washes stay washes** — every wash < 1.5:1 against its surface. This
   is the assertion that catches the brightness-mirroring bug, where
   `shaded(name, 0)` becomes the ramp's most saturated shade on a dark
   surface.

Phase −1 found three real failures here that had been shipping unnoticed
(income 2.22:1, warn 2.20:1, caution 1.51:1). **The app took the fix.**
Six of seven light-theme text tokens moved; the saturated *fills* were
deliberately left on the brand hues, so badges, icons and chart series
still read `#FF3B30` / `#34C759` while the figures beside them are
legible:

| Token | Fill (unchanged) | Text | Light | Dark |
|---|---|---|---|---|
| expense | `#FF3B30` | `#EB1206` | 4.54 | 8.96 |
| income | `#34C759` | `#277F3E` | 5.01 | 11.22 |
| warn | `#FF9500` | `#A06108` | 4.99 | 11.19 |
| caution | `#FFCC00` | `#76600A` | 6.09 | 13.08 |
| pension | `#AF52DE` | `#932BC7` | 6.16 | 9.23 |
| neutral | `#8E8E93` | `#717176` | 4.85 | 10.31 |
| info | `#0071E3` | `#0071E3` | 4.70 | 8.32 |

**This is the strongest single result `plinth_core` has produced.** One
argument change moved an entire app from three shipping WCAG failures to
AA on every figure, with no per-colour tuning — and it argues hard that
`readableOn`'s 3.0 default should be reconsidered, since the obviously
correct call site got the wrong floor silently.

**Pass:** snapshot matches, every text token ≥ 4.5:1 in both themes.
**Fail:** either. A snapshot diff is not automatically a bug — but it
must be looked at and re-baselined deliberately, never silently.

### T5 — Manual run

*The things no widget test sees.*

Everything above runs headless. These do not, and the list is short on
purpose — it should be runnable in ten minutes before a release.

`flutter run -d windows`, then:

1. Toggle light/dark. Watch for panels that do not repaint. *(Colour
   became state during T2; any `shouldRepaint` that ignores colour is
   now a stale-render hazard — `_FirePainter` had exactly this latent.)*
2. Switch HE ↔ EN. Check chart axes, icon direction, and ₪ figures
   inside RTL text — **T3 proves RTL does not throw; it proves nothing
   about RTL being correct.** This is the only place that gets checked.
3. Open a modal, a drawer, and the ⋯ menu. Focus, dismiss, Escape.
4. Resize from maximised down to ~400px, slowly.
5. Tab through the Configuration dialog end to end.

> **Never drive the app with blind synthetic clicks.** Scripted mouse
> input against this app once triggered an accidental real-data import.
> T5 is a human track.

### T6 — API friction, found by migrating

*What does a component's API cost an app that already has working code?*

**Method.** Every entry in the [adoption backlog](#adoption-backlog)
produces this for free. Record what the migration had to work around —
not bugs, but places where the API and ordinary Flutter practice pull
in different directions.

Unlike T1, which measures the cost of a *version bump*, this measures
the cost of *first adoption*, and it can only be collected by someone
converting real code they did not write for Plinth.

**From `PlinthNotification` (42 sites, 12 files, 18 Aug 2026):**

**1. `show()` requires a live `BuildContext`, and the async idiom
doesn't have one.** The standard Flutter pattern for showing feedback
after an `await` is to capture the messenger *before* it, precisely so
no context is needed afterwards:

```dart
final messenger = ScaffoldMessenger.of(context);   // before
await store.applyImport(...);
messenger.showSnackBar(...);                       // after — no context
```

The app had **13 such captures**. All had to be deleted and replaced
with `if (!context.mounted) return;` guards, because
`PlinthNotification.show` accepts only a context. That is a behavioural
change, not just a rewrite: the old code would still show its message
after the widget went away, the new code silently drops it. For
"import finished" that is arguably better; it should still be a choice.

*Suggested:* a `PlinthNotification.showOn(ScaffoldMessengerState, …)`
overload. `show(context, …)` already does
`ScaffoldMessenger.of(context)` internally, so the messenger-taking form
is the more primitive one and costs a few lines.

**2. A guard inside a helper does not satisfy the lint.** The app wraps
`show()` in its own `notify()`, which checks `context.mounted` first.
`use_build_context_synchronously` cannot see through a function
boundary, so every call site after an `await` still needs its own
visible guard — the internal check is a runtime backstop only. Any app
that wraps a Plinth `show`-style API will hit this. One line in the
docs saves the discovery.

**Neither is a bug.** Both are the kind of thing only an adopter finds,
and the kind that quietly decides whether adoption feels smooth or
fiddly. Filed as [PR-12](ADOPTION_REQUIREMENTS.md#pr-12--showon-for-messenger-backed-apis)
and [PR-15](ADOPTION_REQUIREMENTS.md#pr-15--a-migration-guide-for-the-constcontext-tax).

**From `PlinthStepper` (setup wizard, 18 Aug 2026): nothing.** The
controlled-component shape — `currentStep` owned by the caller,
`onStepTapped` advisory — dropped into a wizard that already had its own
`int _step` with no restructuring. Five labelled steps fit a 420px
dialog in Hebrew and English at textScaler 1.0/1.3/2.0. A clean adoption
is a result too, and it is the counter-example that keeps the T6 list
honest.

## Cadence

| When | Run |
|---|---|
| Any change to `plinth_core` tokens | T3, T4 |
| Any component API change | T1 (path-override mode), T3 |
| Before publishing any Plinth version | T1 (published mode), T3, T4, T5 |
| Per roadmap phase | the relevant T2 migration |
| Whenever a backlog item is adopted | record T6 findings while they are fresh |

Full sweep, from the app directory:

```bash
flutter pub get
flutter analyze                    # T1
flutter test                       # T1, T3, T4
flutter build windows --debug      # T1 — catches what analyze doesn't
flutter run -d windows             # T5
```

`flutter analyze` alone is not sufficient for T1: the Phase −1 session
had analyze pass while the Windows build failed, because the two were
resolving different package versions.

## Known baseline — 18 Aug 2026

Record for drift detection. App at `plinth_components 0.25.0`,
`plinth_core 1.0.0-beta.1` (path override), post-colour-migration.

| Signal | Value |
|---|---|
| `flutter analyze` | clean |
| `flutter test` | **225/225** (202 app + 5 T3 + 7 T4 + 9 notify + 2 stepper) |
| `flutter build windows --debug` | succeeds |
| Hardcoded colour literals outside `app_tokens.dart` | **0** |
| Colour anchors in `app_tokens.dart` | 13 |
| Hardcoded spacing literals / spacing token uses | **39 / 310** (was 355 / 0) |
| `PlinthTheme` fields never read by the app | **11 of 19** |
| T3 matrix | as tabulated above |

## Adoption backlog

Coverage is 27% because the app adopted Plinth's *chrome* — shell, cards,
buttons, text — and left its *forms* on Material. Closing that raises T1
and T3 coverage from **31 to ~50 of 115 (43%)**.

Measured in the app on 18 Aug 2026.

### Tier 1 — components already in use, under-adopted

No new component surface; these are consistency fixes that widen the
sample T1 and T3 run against.

| Material in use | Plinth equivalent | Already used | Concentrated in |
|---|---|---|---|
| `TextField` **×72** | `PlinthTextInput` | **2** | portfolio 18, assets 14, FIRE 8, wizard 7, life-plan 7 |
| `FilledButton`/`TextButton`/`OutlinedButton` ×50 | `PlinthButton` | 44 | everywhere |
| `AlertDialog` ×19 | `PlinthModal` / `PlinthDialog` | 5 | dialogs, sheets |
| `IconButton` ×19 | `PlinthActionIcon` | 6 | tables, toolbars |
| `Card` ×13 | `PlinthCard` | 2 | behind `SectionCard` |
| `Chip` ×3 | `PlinthChip` | 3 | filters |

**72 `TextField` against 2 `PlinthTextInput` is the single largest item
in this document.** The app's forms are ~97% Material. Until that
changes, T1 and T3 say almost nothing about the input family — which is
also the family most exposed to `textScaler`, RTL, and focus behaviour.

### Tier 2 — unused components with an honest home

Each of these replaces something hand-rolled or Material-shaped that
already exists. None is a feature invention.

| Component | Replaces | Where |
|---|---|---|
| ~~`PlinthNotification`~~ | ~~`SnackBar` ×42~~ | **Done 18 Aug 2026** — all 42 sites, 12 files |
| `PlinthStepper` | hand-rolled `int _step = 0` + Next/Finish | `setup_wizard.dart` |
| `PlinthList` | `ListTile` ×11 | settings and detail rows |
| `PlinthGroup` / `PlinthFlex` | `Wrap` ×12 | chip rows, button rows |
| `PlinthLoader` / `PlinthLoadingOverlay` | `CircularProgressIndicator` ×6 | assets, config, dashboard fetch |
| `PlinthDivider` | `Divider` ×5 | cards, lists |
| `PlinthProgress` | `LinearProgressIndicator` ×1 | import progress |
| `PlinthAnchor` | raw `launchUrl` | `tax_page.dart` Kol-Zchut links |
| `PlinthPagination` | bare `ListView` on unbounded lists | `transactions_sheet`, `log_page` |
| `PlinthTimeline` | ad-hoc chronological rows | trade log, Life Plan events |
| `PlinthPopover` / `PlinthHoverCard` | modal-on-click for a "?" | `widgets/help_tip.dart` |
| `PlinthSkeleton` | nothing — currently a spinner or empty | any async page |
| `PlinthAvatar` | nothing — names rendered as text | household, kids |

`PlinthMenu` already replaces `PopupMenuButton` in the shell; two
`PopupMenuButton` sites remain.

### Tier 3 — no honest home in this app

Do not force these. Roughly 30 components will never be exercised here,
and the plan should keep saying so rather than quietly hoping:

the whole `color_*` / `*_slider` picker family (6) · `code` · `kbd` ·
`mark` · `highlight` · `carousel` · `marquee` · `cascader` · `tree` ·
`tree_select` · `rating` · `pin_input` · `floating_window` ·
`splitter` · `spoiler` · `angle_slider` · `background_image` ·
`aspect_ratio`

**`PlinthCheckbox` and `PlinthRadio` belong in this tier today, and that
is the most uncomfortable line in this document.** They are the most
accessibility-sensitive widgets in the set and the sharpest hole in T3's
coverage — but the app has no multi-select anywhere. The obvious
candidate, the import review sheet, has no row-level include/exclude.
Adding one to give the checkbox a home would be inventing a feature to
serve a test, which is backwards. **Breadth here needs a second subject
or the widgetbook, not a bigger financial-organizer.**

### Sequencing

Two constraints, both learned the hard way.

1. **T4 before any Tier 1 migration.** A 72-site form migration is
   precisely the change the app's 202 tests would pass silently — the
   same failure mode that let a full palette migration through
   unnoticed. Write T4a/T4b first, then migrate.
2. **Adopt for the app, not for the coverage number.** Where consistency
   and coverage align (forms, notifications, the stepper), do it. Where
   only coverage argues for it, don't — a component adopted to be
   measured tells you nothing about whether anyone would reach for it.

Suggested order: ~~`PlinthNotification`~~ **done** → `PlinthStepper`
(one file, high visual payoff) → `PlinthTextInput` (the big one, and T4
is now in place to catch it) → Tier 2 remainder as pages are touched.

**What the notification migration actually cost**, for calibrating the
rest: 42 sites across 12 files, plus a 95-line app-side helper
(`lib/widgets/notify.dart`) and 9 tests. Two findings came out of it —
see [T6](#t6--api-friction-found-by-migrating).

## What this plan cannot tell you

Worth re-reading before any conclusion drawn from it is quoted
elsewhere.

- **84 of 115 components are never exercised.** Silence about them is
  silence, not a pass.
- **The app's author is Plinth's author.** Every result here validates
  audience A's *shape*, not their existence. A stranger's app would be
  worth more; this is worth far more than nothing.
- **No touch, no screen reader, no real device.** Semantics-tree and
  assistive-tech behaviour are completely untested by anything in this
  plan.
- **No performance measurement.** Nothing here would catch a component
  that got 3× slower.
- **One locale pair.** Hebrew and English. Nothing about CJK line
  breaking, Arabic shaping, or Devanagari.

## First actions

1. ~~Promote the T3 harness into `test/`.~~ **Done** —
   `test/plinth_matrix_test.dart`, 48 cells asserted.
2. ~~Write T4a and T4b.~~ **Done** — `test/plinth_tokens_test.dart`,
   7 cases. Both failure paths were verified by deliberately breaking
   them, so neither is vacuously green.
3. ~~Leave T2/spacing alone until the scale grows a step below 10.~~
   **Scale shipped and migration done** — see T2 above.
4. ~~Start the [Adoption backlog](#adoption-backlog) at
   `PlinthNotification`.~~ **Done** — 42 sites, 12 files, zero
   `SnackBar` left outside the helper. Next is `PlinthStepper`.

**Decision taken 18 Aug 2026:** `app_tokens.dart` passes
`minRatio: kBodyTextContrast` (4.5). Fills keep the brand hues; only
text variants darken. Recorded in T4b above.
