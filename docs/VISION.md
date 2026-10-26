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
| Large-data table | `financial-organizer` uses `PlinthTable` in 8 places. The ones read repeat a hand-written `LayoutBuilder` + horizontal scroll + minimum-width `SizedBox` (cashflow 640, portfolio 720, trade log 800). Rows are a year of trades at most — nothing needs virtualization or sorting | **Done (unreleased): `PlinthTable.minWidth`.** The gap was a scrolling table, not a big one. Sorting, filtering and a sticky header already exist; virtualization has no evidence |
| Date / time pickers | 6 call sites of Material `showDatePicker` / `showTimePicker` across four apps, none Plinth. The only picker anywhere in the portfolio | **Not doing.** Run in `financial-organizer` on Windows (Hebrew, light theme, empty data): Material's picker takes the app's green and surface, and its RTL layout is correct. Nothing clashes. The only repeated code is `bClock`'s 24-hour builder, worth a helper only if a second app needs it. Dark mode and the time picker were not checked |
| Stepper with validation | The setup wizard validates in its own `_next()` and uses `PlinthStepper` only as the indicator. The earlier finding stands: the controlled pattern "dropped into a wizard" | **Drop.** Validation belongs to the caller |
| Rich text editor | No app uses one | **Not doing** |
| Adaptive layout | Two apps hand-roll the same thing with `MediaQuery`: `financial-organizer` a single `_kWideBreakpoint = 1000`; `gynescope-app` (read only, not converted) a `Responsive` widget with `isMobile / isTablet / isDesktop` at 850 / 1100. Plinth has Mantine's breakpoints (`kDefaultBreakpoints`, 576–1408) but only inside `PlinthGrid` and `PlinthSimpleGrid`: there is no way to ask "which breakpoint am I at?" or to build one layout per breakpoint. Neither app's thresholds match Plinth's | **Not doing.** Reviewed 26 Oct 2026 ([PLINTH_CORE_GAP_ANALYSIS.md](PLINTH_CORE_GAP_ANALYSIS.md)): each app already writes one `MediaQuery` comparison, which is Flutter's own answer, and the three thresholds (1000; 850 / 1100; 760) match neither each other nor Plinth's, so a shared token would have helped none. Most of `gynescope-app`'s other 40-odd sites are screen-fraction sizing (`width * .8`), which a design system should not encourage rather than serve. Reconsider if an adopter asks |
| Written UX guidance | Not testable from code | **Unverified** |

Not Plinth's job: Flutter's state-management and rebuild pitfalls. A design
system cannot fix them.

## Decisions this vision forces

[ROADMAP.md](ROADMAP.md#not-doing) said *no `plinth_dates`* and *rich text is
a separate project*. "The complete system" reopened both; the check of the
author's apps closed them again, on evidence rather than on the old reasoning:

- **Date / time pickers** — not doing. Material's picker already fits.
- **Rich text editor** — not doing; no app has asked.

Either returns if an outside adopter, or an app that converts later, reports
a gap.

## What it will not be

- A component-count race. Components are built when an app needs one.
- A tooling company. A CLI, theme previewer and playground are adopter
  conveniences, listed as *Later* and not committed.
- A marketplace. Nothing here has users yet.

## How direction is chosen

Evidence outranks comparison. Gaps come from converting real applications
([findings](ADOPTION_REQUIREMENTS.md)) and from outside adopters, in that
order of cost. A parity table can only find what another library already has.
