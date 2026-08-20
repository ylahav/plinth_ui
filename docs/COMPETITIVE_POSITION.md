# Where Plinth actually sits

Checked against the packages themselves on **20 Aug 2026**, not against a
search summary. That distinction is the reason this file exists: the
original roadmap's competitive claims came from a web-search digest and
were never verified, and one of them was load-bearing for the whole
strategy.

Everything below is dated, because all of it will rot.

## The two that matter

| | **Forui** | **Mix** (+ Remix) | **Plinth** |
|---|---|---|---|
| Version | 0.25.0, ~3 Aug 2026 | Mix 2.1.0, ~26 Jun 2026 | 1.0.0-beta.2 |
| pub.dev likes | **430** | Mix **416**, Remix 9 | **0** |
| Components | 40+ | Remix 24+ | **115** |
| Positioning | "minimalistic widgets for desktop & touch", shadcn/ui-inspired | "expressive way to build design systems" — a styling engine | token engine + the components that prove it |

Remix is the component set built on Mix. Its 9 likes against Mix's 416
says the styling engine is what people adopt, not the components on top.

## What they have that we do not

**This is the part the original roadmap got backwards**, and it is worth
being blunt about.

### Mix owns the variant layer — by name

Mix ships `onHovered`, `onPressed`, `onFocused`, `onDisabled`, `onDark`,
`onLight`, `onBreakpoint`, `onMobile`, `onTablet`, `onDesktop`.

Those are **the exact identifiers** the original roadmap proposed as
Plinth's flagship differentiator. Not a similar idea under another
name — the same names. Building that wedge would have been
reimplementing a competitor's public API, in a package with 416 likes to
our 0.

The same document had already written *"Mix already owns 'token-driven
design system'"* and then made a token-driven variant layer the wedge
anyway. Verifying it turns a suspected contradiction into a measured
one.

**So `A0b` / `A1e` / `A3` should not be pitched as differentiation.**
They are still worth building — a component library needs interaction
states — but as table stakes, not as the reason to choose Plinth.

### Forui owns density, and has the DX we listed as future work

`FThemes.neutral.light.desktop` and `.touch` are separate variants with
"font sizes and padding optimized for their respective platforms."

That is a **more complete answer than `A1c`**, which only floors the tap
target and deliberately changes neither type size nor padding. Forui also
ships a **CLI** for generating themes and styling boilerplate, and
**i18n** — `X1` and `X3` on our own list.

So Phase 3 of the original roadmap (CLI, theme previewer, i18n) is
**catch-up, not differentiation.** Worth doing for adopters; worth
nothing as a pitch.

### Both bridge to Material, in the direction we also cover

- Forui: `toApproximateMaterialTheme()` — its own docs call the mapping
  "best-effort" and say it "may not capture all nuances."
- Mix: `ContextToken<T>` reads straight from `BuildContext`, so tokens
  track the ambient `ThemeData` without duplication. Material → Mix.

## What we have that they do not

Checked against Mix's own token documentation, which makes **no mention**
of any of the following:

| | Forui | Mix | Plinth |
|---|---|---|---|
| **WCAG contrast resolution in token lookup** | not documented | **no** | `readableOn`, `contrastingOn`, named floors |
| **Seed → 10-shade ramp, anchored** | not documented | **no** | `generateShades`, shade 6 returns the seed exactly |
| **Semantic role tier** | colour *pairs* (colour + foreground) | **no** | `semanticColors`, role → ramp + shade + floor |
| **Categorical series palette** | — | — | CVD-scored across 8 contexts |
| **Agreement check against an existing `ColorScheme`** | approximates instead | bridges instead | `colorSchemeDisagreements` |
| **DTCG import** | — | **no** | not yet — `E1` |

**The sharpest one is the last row, and it is a difference in kind.**
Forui and Mix both answer *"how do I get my tokens into Material?"*
Neither answers *"are the two palettes I already have actually the same
colours?"* — which is the question an app with an existing `ThemeData`
and its own widgets actually has. Forui's own word for its mapping is
*approximate*; Plinth's comparison is exact and returns the specific
fields that disagree.

**The second sharpest is contrast.** Plinth resolves colour *through* a
WCAG floor at lookup time — `readableOn(key, background)` walks the ramp
until it clears 4.5:1. Neither competitor documents anything equivalent.
That is not a small feature: it is what caught the alert icons failing
at 1.74:1 and Mantine's own `blue.6` failing AA behind a white label.

## The honest read

**Breadth is real against these two specifically** — 115 against 40+ and
24+. It is not real against GetWidget, and it was correctly retired as
*the* pitch. Keep it as evidence, not as the argument.

**The wedge is accessibility-grade colour, not variants.** Everything
Plinth has that neither competitor does sits in one place: colour that
is resolved against a contrast floor, anchored to a real seed, named by
role, and checkable against the theme you already have. That is a
narrower claim than "token-driven design system" and, unlike it, is not
already owned.

**And 0 likes against 430 and 416 is the number that matters most.** Two
mature packages with real adoption occupy adjacent ground. The
differentiators above are genuine and none of them is visible from a
pub.dev listing, which makes `P1` — one real app somebody else built —
worth more than any further feature.

## What this changes

- `A0b` / `A1e` / `A3` — **build, do not pitch.** Table stakes; Mix got there first and named them the same thing.
- `A1c` density — **shipped and narrower than Forui's.** Do not claim it as a differentiator.
- `X1` CLI, `X3` i18n — **catch-up with Forui.** Adopter value, not pitch value.
- `E1` DTCG — **the one planned item nobody else has.** It moves from "audience B enabler" to the strongest remaining differentiator, and should be re-ranked accordingly.
- `T2` comparison article — **now writable**, on these verified facts rather than a search digest.

---

*Re-check before quoting any of this. Forui shipped 0.25.0 seventeen days
before this was written; Mix 2.1.0 about two months before. A file like
this is wrong within a quarter.*
