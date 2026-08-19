# Plinth UI — Roadmap reconciliation

This file started as a standalone roadmap drafted against the project
from the outside. [POST_1_0_ROADMAP.md](POST_1_0_ROADMAP.md) was written
later, from inside the source and against one real app, and it reaches
different conclusions about who Plinth is for and what to build next.

Rather than leave two roadmaps contradicting each other, this file is
now the reconciliation: **what each one got right, which one wins where
they disagree, and the combined positioning that comes out of it.**

**POST_1_0_ROADMAP.md is the engineering plan.** Workstreams, task IDs
and sequencing live there. This file holds the four things it doesn't
cover — trust signals, distribution, i18n, and the DX tooling layer —
plus the public-description gate.

### Where the draft came from

Worth recording, because it explains the divergence rather than just
noting it.

The draft answered one question: **"is plinth_ui needed by the Flutter
community, and if not, can it become something useful?"** Its inputs
were a web search of the 2026 landscape — GetWidget, shadcn_ui, Forui,
Mix, the platform-specific ones — and a component count that was
already stale. It never read the source.

Given those inputs it reached a defensible answer: *not needed in the
abstract*, since shadcn_ui, Forui and Mix already occupy modern,
token-driven, highly-customizable territory; "needed" is the wrong bar
anyway; pick a wedge instead of trying to out-broad GetWidget and
out-token Mix at once.

**Then it picked out-token Mix as the wedge.** The same analysis had
just concluded that *"Mix already owns 'token-driven design system'"* —
and the roadmap that followed made a token-driven variant layer the
flagship differentiator. That is the one place its reasoning turns on
itself, and it is the reason its Phase 2 needs re-aiming rather than
just re-dating.

**The question it never asked** is the one the source raises. "Is
another component library needed?" — no. "Is a Flutter runtime that
consumes DTCG tokens and bridges to an existing `ThemeData` needed?" —
untested by any roundup, because no roundup is looking for it. That is
audience A, and it is the differentiation the draft asked for and could
not see from outside.

**The draft's skepticism is narrowed by this, not refuted — and it has
since been tested.** POST_1_0_ROADMAP wrote Phase −1 as an experiment
against *"a user nobody has met."* **That experiment ran.**
`financial-organizer` was migrated onto the packages, and the friction
it hit is written up as 15 numbered requirements in
[ADOPTION_REQUIREMENTS.md](ADOPTION_REQUIREMENTS.md) — two of them
blockers, one of which (`readableOn`'s contrast floor) was a
wrong-by-default the library had shipped without noticing.

So the disagreement resolves unevenly:

- **On the product, the draft was simply working blind** — stale count,
  a wedge already planned, six components it did not know existed.
- **On the market, it is still the only one of the two that looked.**
  Nothing in this repo has checked what Forui, Mix or shadcn_ui
  actually do.
- **On users, neither position holds any more.** The relevant evidence
  is no longer absent, it is *discounted* — one app, whose author is
  also Plinth's author, and the validation plan applies that discount
  explicitly rather than claiming more than it has. **P1 remains the
  only item that would produce undiscounted evidence.**

**Still owed, and not yet done:** the draft's competitive claims about
Forui, Mix and shadcn_ui are second-hand. Before **T2** ships a
comparison section, check them against those packages directly — a
comparison built on a search summary is exactly the kind of unbacked
claim both documents exist to avoid.

---

## Corrections to the original draft

Every number below is a check against the source at `1.0.0-beta.1`, not
a re-estimate.

| The draft said | Actually |
|---|---|
| 71 components | **112** — 115 widget files, 114 exports. The count in `pubspec.yaml` and the README is the audited one |
| "Target: 75+ components before publishing the description" | **Cleared long ago, and retired as a goal.** POST_1_0_ROADMAP: *"A count borrowed from another project's marketing was never a goal"* |
| Phase 2 wedge: a variant layer to build | Already planned, better specified, as **A0b + A1e + A3** — see the mapping below |
| Phase 3: extract tokens into a standalone `plinth_tokens` package | **Unnecessary.** `plinth_core` is 476 lines, depends only on `flutter`, and is separately published. It *is* a standalone token package today — it is just not documented as one |
| Phase 4: six missing components | **All six ship.** `plinth_table`, `plinth_pagination`, `plinth_autocomplete` (and `plinth_combobox`), `plinth_app_shell`, `plinth_color_input`, `plinth_carousel` |

One more worth stating plainly, because the public copy leaned on it:
`PlinthVariant` in `plinth_core/lib/src/tokens.dart` is Mantine's
**appearance** enum — `filled`, `light`, `outline`, `subtle`,
`transparent` — resolved inside each widget. It is not a state-variant
resolution layer. Hover is hand-wired in 7 of 115 widget files, and
breakpoints exist only as layout spans inside `plinth_grid.dart`.
**There is no `onHovered` / `onPressed` / `onBreakpoint` today.**

---

## The combined positioning

The two documents disagreed about the pitch. The draft led with breadth
(112 components, admin panels and dashboards). POST_1_0_ROADMAP retired
the count and led with the token layer, for teams who already have an
app and their own widgets.

**Both hold at once, in one order:** the token engine is the product,
and the component library is the evidence it works at scale. The draft's
error was never *mentioning* the breadth — it was making breadth the
reason to adopt. A team evaluating a token system wants proof it
survives contact with 112 real components; that is exactly what
`plinth_components` is for.

> **Plinth is a design-token engine for Flutter — and 112 components
> built on it, which is how you can tell it holds up.**

That framing keeps what each roadmap was actually right about:

- **From POST_1_0_ROADMAP** — `plinth_core` is the product,
  `plinth_components` is the evidence; the audience is a team with an
  existing app, not a greenfield builder; nobody installs 112
  components on day one.
- **From this draft** — don't hide the breadth. It is the single most
  checkable trust signal the project has, and burying it forfeits the
  one thing no competing Flutter token package can match.

### Copy, when the gate below clears

Not applied to the README or any `pubspec.yaml` yet — recorded here so
there is one source to apply from.

**pub.dev** (`plinth_core`, 60–180 chars):

> A design-token engine for Flutter: curve-based colour ramps, WCAG
> contrast built in, and 112 components proving it at scale.

**GitHub repo description:**

> A design-token engine for Flutter, with the 112-component library
> that proves it works — curve-based ramps from one seed colour,
> WCAG-checked, light and dark, fully tested and CI-verified.

**Topics:** `flutter` `dart` `design-tokens` `design-system`
`ui-library` `component-library` `flutter-widgets` `theming`
`flutter-package` `ui-kit`

**Who Plinth is for** — use POST_1_0_ROADMAP § Who this is for
verbatim (audiences A and B). The draft's version described a
greenfield team choosing a component set, which is the audience that
document specifically retired.

---

## Where the draft's Phase 2 actually went

The draft called a token-resolved variant layer the flagship
differentiator. That was right, and it is already in the engineering
plan under different names — with the Flutter-specific detail the draft
couldn't have known:

| Draft item | Real task | The detail that matters |
|---|---|---|
| `onHovered`, `onPressed`, `onFocused`, `onDisabled` | **A1e** + **A0b** | Ships as `WidgetStateProperty` **factories, not `Color` values** — a raw colour is a token no component can consume |
| `onBreakpoint` | **A3** | `kDefaultBreakpoints` moves from `plinth_grid.dart` into `plinth_core`, re-exported so nothing breaks |
| `onDark` / `onLight` | Already shipped | `PlinthTheme.darkTheme` — the ramps are shared, only the chrome inverts |
| Semantic + core token layers | **A0a** | The tier split is the gate on everything else, including DTCG interop |

So: keep the wedge, drop the parallel plan. Track it as A0a → A0b/A1e
in POST_1_0_ROADMAP.

---

## What this file still owns

Four things POST_1_0_ROADMAP doesn't cover. None of them block its
critical path, and all can run alongside.

### T — Trust signals

Cheap, and none of it needs code.

- [ ] **T1** Keep this file and POST_1_0_ROADMAP linked from the README as the public roadmap
- [ ] **T2** A README section comparing Plinth to Forui and Mix — fair, not disparaging. Honest shape: Forui is minimal and opinionated, Mix is a styling engine without the components, Plinth is the token engine *with* them
- [ ] **T3** Surface `plinth_hooks` in the README — it exists and is under-marketed
- [ ] **T4** Add pub points and coverage badges next to the existing CI badge
- [ ] **T5** Open GitHub Discussions

### X — DX tooling

The draft wanted a CLI and a theme previewer. Both are wrappers over
APIs already planned, so they follow rather than lead:

- [ ] **X1** `plinth theme create` CLI — scaffolds a light/dark pair from a seed. **Depends on A5** (`PlinthTheme.fromSeed`), which is the actual API; the CLI is a thin shell over it
- [ ] **X2** In-browser seed-colour previewer against real components — largely **E4** (the token explorer) with a component view attached; reuse the Widgetbook infrastructure
- [ ] **X3** **i18n / l10n.** *The one genuinely untracked item in this file.* POST_1_0_ROADMAP never covers it, and it is a hard blocker for non-English-first teams. Note the RTL work (**B0d**) is adjacent but not the same thing — RTL is layout correctness, i18n is strings and formats

### P — Proof and distribution

Gated on having a differentiator to point at, per both documents.

- [ ] **P1** Link one real app built on Plinth. **Candidate: the `financial-organizer` validation app from Phase −1** — but apply POST_1_0_ROADMAP's own discount, since its author is Plinth's author. A stranger's app is worth more
- [ ] **P2** Submit to Flutter Gems, awesome-flutter, and pub.dev categories
- [ ] **P3** Publish the Plinth vs Forui vs Mix piece — **after** A0b/A1e land, so it has something to argue
- [ ] **P4** Track adoption milestones as they happen

---

## The gate on the public description

The draft's gate was *"Phase 2 live AND 75+ components."* Half of it is
obsolete — the count cleared and was retired as a goal. The other half
survives, restated against real tasks:

**Do not publish state-variant claims until `A0b` and `A1e` have
shipped.** Today's checkable claim is the one POST_1_0_ROADMAP already
records: 112 components at parity with `@mantine/core`, on a shared
token system, with 42 golden images and 59 test files behind them.

The token-engine framing above is publishable now — it describes what
`plinth_core` is, not what it will become. The hover/press/breakpoint
variant language is not.

**Decided: repositioning waits for Phase 5.** The disagreement was
whether to reposition now or last. POST_1_0_ROADMAP put it last,
reasoning that *"announcing a token foundation before building one is
precisely the unbacked claim this document exists to avoid."* This file
argued the token-engine line is already true of a 476-line package that
ships WCAG machinery most token layers don't, and that leaving
`plinth_core`'s description reading *"…for Plinth UI"* costs discovery
in the meantime.

**POST_1_0_ROADMAP wins.** Nothing in the README, the three
`pubspec.yaml` descriptions, or the GitHub listing changes until Phase
5. The copy above is staged, not pending — do not apply it early
because it happens to be written.

Two consequences worth holding onto:

- The **T-items are still safe to run now**, and are the whole reason
  they are tracked separately from the copy. A comparison section, a
  badge, and Discussions make no claim about the token layer. **T2 is
  the one to watch** — a comparison is where repositioning language
  leaks in early without anyone deciding to.
- Discovery cost is real and is now an accepted cost, not an oversight.
  If `plinth_core` is still invisible by the time Phase 3 lands,
  that is evidence about the sequencing, not a reason to reopen this
  mid-phase.
