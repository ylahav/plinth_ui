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

**Checked against the author's own apps, 25 Oct 2026.** Three apps use Plinth
(`financial-organizer`, `bClock`, `stayAble`); `gynescope-app`, `ygym` and
others do not. This carries the author-evidence discount described in
[ROADMAP.md](ROADMAP.md#conversion-which-is-not-on-the-ladder), and no outside
adopter has reported anything.

| Candidate | What the apps show | Verdict |
|---|---|---|
| Large-data table | `financial-organizer` uses `PlinthTable` in 8 places. The ones read repeat a hand-written `LayoutBuilder` + horizontal scroll + minimum-width `SizedBox` (cashflow 640, portfolio 720, trade log 800). Rows are a year of trades at most — nothing needs virtualization or sorting | **Open, but the gap is a scrolling table, not a big one.** Virtualization and sorting have no evidence |
| Date / time pickers | 6 call sites of Material `showDatePicker` / `showTimePicker` across four apps, none Plinth. The only picker anywhere in the portfolio | **Open, small.** Most-repeated missing primitive; a themed, RTL-correct wrapper rather than a new picker |
| Stepper with validation | The setup wizard validates in its own `_next()` and uses `PlinthStepper` only as the indicator. The earlier finding stands: the controlled pattern "dropped into a wizard" | **Drop.** Validation belongs to the caller |
| Rich text editor | No app uses one | **Not doing** |
| Adaptive layout | `financial-organizer` hand-rolls `_kWideBreakpoint = 1000` with `MediaQuery` while also using `PlinthAppShell` | **Unclear.** Either Plinth's breakpoints are not discoverable or they do not fit. `gynescope-app` (41 adaptive sites, no Plinth) is the best next test |
| Written UX guidance | Not testable from code | **Unverified** |

Not Plinth's job: Flutter's state-management and rebuild pitfalls. A design
system cannot fix them.

## Decisions this vision forces

[ROADMAP.md](ROADMAP.md#not-doing) currently says *no `plinth_dates`* and
*rich text is a separate project*, because both audiences already had them.
A goal of "the complete system" reopens both. Neither is decided here; both
sit in the *Unverified* table above until evidence moves them:

- **Date / time pickers** — open and small; a wrapper, not a new picker.
- **Rich text editor** — not doing; no app has asked.

## What it will not be

- A component-count race. Components are built when an app needs one.
- A tooling company. A CLI, theme previewer and playground are adopter
  conveniences, listed as *Later* and not committed.
- A marketplace. Nothing here has users yet.

## How direction is chosen

Evidence outranks comparison. Gaps come from converting real applications
([findings](ADOPTION_REQUIREMENTS.md)) and from outside adopters, in that
order of cost. A parity table can only find what another library already has.
