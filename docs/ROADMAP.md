# Plinth UI — Roadmap

*Last checked 20 Aug 2026, against `1.0.0-beta.2`.*

The single plan. Evidence lives in
[ADOPTION_REQUIREMENTS.md](ADOPTION_REQUIREMENTS.md) (what a real app
needed) and [PHASE_MINUS_1_FINDINGS.md](PHASE_MINUS_1_FINDINGS.md) (what
happened when it was tried); this file is what to do about it.

---

## Who it is for

**A — a Flutter team with an existing app and their own widgets.** They
will not rewrite their UI layer. They have `ThemeData`, a pile of
hardcoded colours, and a designer asking why dark mode looks wrong. They
want *their* widgets themeable, consistent, and correct at 200% text
scale.

**B — a team standardising design across Flutter and web.** Everything A
needs, plus one source of truth shared with a codebase that is not
Flutter. They already have tokens in Figma or Style Dictionary; what
they lack is a Flutter runtime that consumes them properly.

**B is A plus interop**, which is why this is one sequence.

Neither is a solo developer starting greenfield, and that reorders
everything: **`plinth_core` is the product, `plinth_components` is the
evidence.** Nobody installs 115 components on day one. For audience A,
`plinth_components` may never be installed at all.

## What makes it different

Checked against Forui 0.25.0 and Mix 2.1.0 on 20 Aug 2026 — **internal
rationale, not a comparison to publish.** It sets what to build and what
not to claim.

**The wedge is accessibility-grade colour, checkable against the theme
you already have.** Four things neither competitor documents:

- Colour resolved against a **WCAG floor at lookup time** —
  `readableOn` walks the ramp until it clears 4.5:1. This is what caught
  alert icons at 1.74:1.
- **Anchored seed ramps** — feed in a brand colour, shade 6 returns it.
- A **semantic role tier** — role → ramp + shade + contrast floor.
- **`colorSchemeDisagreements`** — the difference in *kind*. Forui's
  `toApproximateMaterialTheme()` and Mix's `ContextToken` both answer
  "get my tokens into Material". Neither answers "are the two palettes I
  already have the same colours?" — which is audience A's actual
  question. Forui's own word for its mapping is *approximate*.

**What is not a differentiator, and must not be pitched as one:**

- **Interaction-state variants.** Mix ships `onHovered`, `onPressed`,
  `onFocused`, `onDisabled`, `onDark`, `onLight`, `onBreakpoint` today —
  the exact names an earlier draft of this roadmap proposed as our
  flagship. Build them (`A0b`, `A1e`, `A3`) as table stakes; do not
  claim them.
- **Density.** Forui ships desktop/touch theme variants with per-platform
  font sizes and padding. Ours floors the tap target only, so it is the
  narrower answer.
- **CLI and i18n.** Forui has both. Catch-up, not a pitch.
- **Breadth.** Real against these two (115 vs 40+ and 24+), not against
  GetWidget. Evidence, not argument.

**Adoption is the open question, not features.** Two mature packages
hold adjacent ground with real usage, and none of the above is visible
from a pub.dev listing. Plinth is two weeks old, so its own numbers say
nothing yet either way — which is exactly why `P1` (one real app
somebody else built) is worth more than any further feature.

---

## Done

| | |
|---|---|
| **All 19 adoption requirements** | Everything the real-app migration found, plus four that fixing them exposed |
| **A8′** Material reconciliation | Replaced `A8` (`toThemeData`), which the migration falsified — it was never reached for |
| **A1c** Control sizing + density | Measured as one control, not every control |
| **B0a / B0b / B0d** | Accessibility probes run and recorded |
| **B1** Focus containment | `PlinthFocusTrap`; smaller than planned — Drawer never needed it |

## Next

**1. `B0c` — the screen-reader pass.** The only thing left before 1.0,
and the only task here a person has to do rather than a test.
Everything above is verified by tests and simulated semantics trees and
**has never been heard.** Script: [B0C_SCREEN_READER_PASS.md](B0C_SCREEN_READER_PASS.md).

**2. `A0a` — the token hierarchy.** Formalise primitive / semantic /
component tiers. The gate on everything in interop, and the last
structural piece.

**3. `E1` — DTCG import.** `PlinthTheme.fromDtcg(json)`. **Re-ranked up:**
it is the one planned item neither competitor has, which makes it the
strongest remaining differentiator rather than only an audience-B
enabler. Depends on `A0a`.

**4. `P1` — one real app, built by somebody else.** The only thing that
produces undiscounted evidence. The validation app's author is also
Plinth's author, and that discount is applied everywhere it is cited.

## Later

**Tokens.** `A0b` component tokens; `A1a`–`A1f` and their `A2*` migration
pairs (motion, typography, control sizing, elevation, interaction state,
platform flags); `A3`–`A7`.

**Interop.** `E2` DTCG export, `E3` theme validation in CI, `E4` token
explorer, `E5` golden helpers for users.

**Accessibility.** `B2` roving focus — starting with extracting the
logic welded inside `PlinthTabs`. Note the dropdown family leaks Tab and
a focus *trap* is the wrong fix: focus belongs in the text field with
arrow keys moving a highlighted option. `B3`, `B4`.

**Adopter DX.** `X1` CLI (`plinth theme create`, thin shell over `A5`);
`X2` in-browser theme previewer (largely `E4`); `X3` i18n — genuinely
untracked, and a hard blocker for non-English-first teams. All three are
**post-1.0**; none blocks the version.

**Trust and distribution.** `T2` comparison piece (writable now, on the
verified facts); `T3` surface `plinth_hooks`; `T4` badges; `T5`
Discussions; `P2` Flutter Gems and awesome-flutter; `P3`, `P4`.

## Not doing

| | Why |
|---|---|
| A token *compiler* | Style Dictionary emits static constants, which cannot express `textScaler`, density, `WidgetStateProperty`, per-subtree overrides or `readableOn`. Consume the standard; do not rebuild the pipeline |
| `plinth_form`, `plinth_dates` | Both audiences already have forms and dates |
| Charts, rich text | Separate projects |
| ~30 DOM-only hooks | Web-only, in a library that is not |
| Most of `plinth_hooks` | A team has its own state utilities. `use-focus-trap` and `use-roving-index` survive because `B2` needs them |
| A component count target | Borrowed from another project's marketing. Components get built when an app needs one |

---

## What a Flutter token layer needs that a CSS one does not

The clearest answer to *"why not just use Style Dictionary?"*, and the
reason several tasks above exist at all.

| CSS gives you | Flutter makes you build it |
|---|---|
| The cascade | No cascade; `DefaultTextStyle` is opt-in per subtree — half of why `A4` matters |
| `:hover`, `:focus-visible` | Each is a `WidgetState` wired per widget — `A1e` ships `WidgetStateProperty` factories, because a raw `Color` is a token no component can consume |
| Logical properties | `EdgeInsets.only(left:)` silently breaks RTL |
| Transitions | `ThemeExtension.lerp` is a method you write — why `A6`, and `A11`'s fix, existed |
| `<button>` *is* the semantics | Semantics is a wrapper, never implied — which is why B0 found eight controls with no name |

And four axes with **no web analogue at all**: `textScaler` (a system
setting, commonly 200%+), density, the `boldText` / `highContrast`
platform flags, and the Material bridge itself.

One thing Flutter gets that CSS does not: **the tokens are
pixel-testable.** A golden suite can pin a token migration in both
directions, which no CSS-variable refactor can offer.

## On Mantine

A starting point, not a specification. 112 components track
`@mantine/core` because its answer was right; three exist because
Flutter asked a question a web library never had to — `PlinthLtr`,
`PlinthFocusTrap`, `PlinthTapTarget`.

**Where the two disagree, Flutter wins.** Filled buttons carry a dark
label because white on Mantine's own `blue.6` is 3.56:1 and fails AA.
Looking less like Mantine and being more correct on a platform with a
system-level accessibility contract is the trade this library takes on
purpose.

## The claims gate

**Do not publish interaction-state or variant language** — it does not
exist here, and it is Mix's, by name.

Today's checkable claim: *115 components on a shared token system — 112
tracking `@mantine/core`, three answering questions only Flutter has —
with 43 golden images and 65 test files behind them.*

The token-engine framing is publishable once `B0c` is clean. Before
that, every accessibility claim rests on tests and simulated semantics
trees, which is not the same as having been heard.
