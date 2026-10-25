# Plinth UI — Vision

*Set 25 Oct 2026. Replaces the "build an app and keep it correct" thesis in
[ROADMAP.md](ROADMAP.md#who-it-is-for), which is now one consequence of this
goal rather than the goal.*

## The goal

**Plinth UI is the enterprise design system Flutter does not have — one where
accessibility holds when the brand changes.**

Flutter ships Material and Cupertino. It has no equivalent of Ant Design,
Fluent or Mantine: a complete, opinionated system for data-heavy,
multi-platform applications. Teams build one in-house, or stitch one together,
and the colours stop meeting WCAG the first time a brand colour changes.

Plinth answers both halves: the system, and the guarantee.

## What it commits to

| Commitment | What it means | Where it is proven |
|---|---|---|
| **A complete system** | Tokens, components, composed blocks and starters that share one theme | `plinth_core`, `plinth_components`, `plinth_blocks`, `templates/` |
| **Accessible by construction** | Colour is resolved against a WCAG floor at lookup time, so a rebrand cannot silently break contrast | `readableOn`, `theme.validate()`, [B0C findings](B0C_SCREEN_READER_PASS.md) |
| **Bring your own brand** | Adopters supply tokens (seed colour, DTCG) and keep the guarantee | `PlinthDtcg`, `colorSchemeDisagreements` |
| **Honest about its state** | Claims are checked against source; unverified work is listed as such | [The claims gate](ROADMAP.md#the-claims-gate) |

## What is missing in Flutter, and where Plinth stands

**The gap Plinth claims.** Flutter has third-party design systems (Fluent UI,
Forui, and copy-paste kits such as flutterbits and dashcn). The gap is not that
none exist. It is that none make accessibility survive a rebrand: colour
resolved against a WCAG floor at lookup time, checkable against the theme you
already have. That is the claim to defend; "no enterprise design system" is not.
*Competitor details are unverified here — the comparison in
[ROADMAP.md](ROADMAP.md#what-makes-it-different) was checked 20 Aug 2026 against
Forui and Mix only.*

**Closed — Flutter lacks it, Plinth ships it.** Breakpoints, grid and app
shell; tree view; dashboard pieces (stat tiles, charts); multi-select and
autocomplete.

**Open — a confirmed gap in Plinth.**
- Large-data table: virtualization, sorting, filtering. `PlinthTable` is
  non-virtualized by design.
- Stepper with per-step validation. `PlinthStepper` is visual-only.

**Unverified — decide after checking.**

| Candidate | What to check first |
|---|---|
| Date / time pickers | Plinth has none. Flutter ships Material `showDatePicker`, so the question is whether a token-themed, range-capable picker is needed. Look for it in conversion findings |
| Rich text editor | `flutter_quill` and `super_editor` exist. Only if a converted app needs one |
| Adaptive layout presets | `AppShell` and the dashboard starter exist; whether a multi-pane preset is still missing is untested |
| Written UX guidance (spacing, hierarchy, navigation) | [SHOWCASE.md](SHOWCASE.md) has none, but blocks and starters may teach it implicitly |

Not Plinth's job: Flutter's state-management and rebuild pitfalls. A design
system cannot fix them.

## Decisions this vision forces

[ROADMAP.md](ROADMAP.md#not-doing) currently says *no `plinth_dates`* and
*rich text is a separate project*, because both audiences already had them.
A goal of "the complete system" reopens both. Neither is decided here; both
sit in the *Unverified* table above until evidence moves them:

- **Date / time pickers** — an enterprise form without one is arguably not
  complete, but Material ships one, so evidence comes first.
- **Rich text editor** — a project of its own. Only if conversion evidence
  asks for it.

## What it will not be

- A component-count race. Components are built when an app needs one.
- A tooling company. A CLI, theme previewer and playground are adopter
  conveniences, listed as *Later* and not committed.
- A marketplace. Nothing here has users yet.

## How direction is chosen

Evidence outranks comparison. Gaps come from converting real applications
([findings](ADOPTION_REQUIREMENTS.md)) and from outside adopters, in that
order of cost. A parity table can only find what another library already has.
