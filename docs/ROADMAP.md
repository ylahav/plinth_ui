# Plinth UI — Roadmap

*Last checked 23 Aug 2026, against `1.2.0`.*

> Task IDs like `B0c` appear only where something outside this file
> cites them — commit messages, or
> [B0C_SCREEN_READER_PASS.md](B0C_SCREEN_READER_PASS.md). Everything
> else is named rather than numbered, on purpose.

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
  flagship. Build them — component tokens, interaction-state tokens,
  breakpoints in the core — as table stakes; do not claim them.
- **Density.** Forui ships desktop/touch theme variants with per-platform
  font sizes and padding. Ours floors the tap target only, so it is the
  narrower answer.
- **CLI and i18n.** Forui has both. Catch-up, not a pitch.
- **Breadth.** Real against these two (115 vs 40+ and 24+), not against
  GetWidget. Evidence, not argument.

**Adoption is the open question, not features.** Two mature packages
hold adjacent ground with real usage, and none of the above is visible
from a pub.dev listing. Plinth is two weeks old, so its own numbers say
nothing yet either way — which is exactly why **anything somebody else
reports** is worth more than any further feature. Since 1.5.0 that no
longer means a whole app: the cheapest useful version is somebody
running `theme.validate()` against their own tokens, which costs them
an afternoon. See Next item 3.

---

## Done

| | |
|---|---|
| **All 19 adoption requirements** | Everything the real-app migration found, plus four that fixing them exposed |
| **Material reconciliation** | Replaced a planned `toThemeData()`, which the migration falsified — it was never reached for |
| **Control sizing + density** | Measured as one control, not every control |
| **Accessibility probes** (`B0a`, `B0b`, `B0d`) | Run and recorded |
| **The screen-reader pass** (`B0c`) | Run 22 Aug 2026. Two defects, both fixed; the nine form labels hold up in a real browser. [B0C_FINDINGS.md](B0C_FINDINGS.md) |
| **Focus containment** | `PlinthFocusTrap`; smaller than planned — Drawer never needed it |
| **Announcements** (`F-3`) | Built 22–23 Aug 2026 across validation, alerts, notifications, loading and progress, and **heard end to end** in a fourth NVDA pass. [F3_ANNOUNCEMENTS.md](F3_ANNOUNCEMENTS.md) |
| **Keyboard reachability** (`F-4`) | `PlinthAnchor` and `PlinthUnstyledButton` were clickable and announceable but not focusable — WCAG 2.1.1. Found by ear on 23 Aug 2026, and by nothing else: the semantics tree was correct |

## Next

**1. ~~The token hierarchy.~~ Done.** `PlinthToken`, `PlinthTier` and
`theme.tokens` — every token addressable by a stable path and sorted
into primitive or semantic. Purely additive; no field changed.

**Two tiers, not three.** Component tokens (`button.primary.background`)
do not exist yet, and an empty tier would have described an intention
rather than the theme. The enum gains a value when that lands.

**One thing it does not claim.** A `PlinthTheme` stores `surface` as a
`Color`, not as `{color.gray.0}`, so the enumeration reports resolved
values rather than references. A reference layer is a separate change
with a breaking edge, and claiming a reference the theme does not hold
would turn a round-tripping export into one that quietly flattens.

**2. ~~DTCG import.~~ Done, and export with it.** `PlinthDtcg.parse`
and `PlinthDtcg.export`. A mapping rather than a translation, because
the hierarchy already names types the way DTCG names them — which is
most of why it had to land first.

`parse` returns a **result, not a theme**: what it applied and what it
ignored, with a reason for each. An importer that silently drops half a
file produces a theme that looks right and is not, and the person who
finds out is whoever trusted the colours. References are resolved, and
a cycle is reported rather than overflowing the stack.

Still open: emitting *references* rather than resolved values on
export, which needs the reference layer above.

**3. Evidence from somebody else.** The discount comes from
*authorship*, not from scale: the validation app's author is also
Plinth's author, and that is applied everywhere it is cited.

This item said "one real app" until 1.5.0, which was the most expensive
form of the thing and — until 1.5.0 — the only available one. It is no
longer. `theme.validate()` and `PlinthDtcg.parse` both take somebody
else's *tokens* rather than their project, and tokens are a far smaller
thing to ask for than a migration.

So this is a ladder, cheapest first. Every rung produces evidence this
repo cannot write for itself, and the bottom rung costs an afternoon:

| Rung | The ask | What it proves |
|---|---|---|
| **Run the validator** | `expect(ourTheme.validate(), isEmpty)` against their own tokens. No adoption, no migration, no dependency on anything Plinth paints | That the contrast machinery finds real failures in a palette nobody here chose. It found two in Plinth's own defaults, so it will find some |
| **Import a real design file** | `PlinthDtcg.parse` on their Figma export, and report what landed in `ignored` | That the format claim survives a file this repo did not author. `ignored` is the interesting half — it is the list of things the reader does not understand yet |
| **Rebrand a starter** | `cp -r templates/dashboard`, change `brandColor`, say whether anything became unreadable | The rebrand-survival claim, exercised by somebody with no stake in it holding |
| **Build an app** | The original item | Everything above, plus whatever nobody thought to ask |

### Conversion, which is not on the ladder

**Plinth's author is converting his own applications onto it.** That is
not a rung above — it carries exactly the discount this section is
about, the same one the validation app carries. Nobody outside has
reported anything yet.

It is worth its own heading anyway, because it produces a *different
kind* of finding from everything else here, and the difference survives
the discount:

> A gap list built by comparison can only find what the other library
> has.

`COMPONENTS.md` and `SHOWCASE.md` both compare against Mantine, and
Mantine has no full-screen-sheet entry to be missing. The first two
conversion findings were exactly that shape — `PlinthDrawer` topping
out at 600px so a covering bottom sheet was impossible, and no page
header putting a photograph edge to edge with a close button over it.
Neither appeared in any audit, parity table or roadmap, and neither
could have.

So: **conversion finds gaps that comparison cannot, and outside
adoption finds what conversion cannot.** They are different axes, not
the same axis at different strengths, and this section previously had
only the second one written down.

**Which app, if it gets that far.** Not any app — the shape decides how
much it is worth:

- **White-label or multi-tenant, one brand colour per customer.** The
  only shape that exercises rebrand survival *continuously* rather than
  once, and the only one where a failure is reported by a customer
  rather than noticed by the author.
- **Something audited under Israeli accessibility law** (IS 5568 / the
  Equal Rights for Persons with Disabilities regulations). A
  third-party auditor renders a verdict on precisely the claim this
  library makes. An audit report is evidence that cannot be
  self-issued.
- **A team with an existing Figma design system**, which exercises the
  token hierarchy and DTCG against a file written elsewhere.

The four starters in `templates/` **still do not close this** — they are
written by Plinth's author and carry the same discount. What they
changed is the cost of the first hour, which is the third rung above,
not the fourth.

## Later

**None of this blocks 1.0.** Ordered roughly by value, not by phase.

### Adopter tooling

| | What it is | Notes |
|---|---|---|
| **CLI** | `plinth theme create` — scaffold a light/dark theme from one seed colour | A thin shell over `PlinthTheme.fromSeed`, which does not exist yet either. Forui already ships a CLI, so this is catch-up |
| ~~**i18n / l10n**~~ | **The seam is in.** `PlinthLocalizations` + `PlinthStrings`, with every widget falling back to it and every explicit label parameter still winning | Twenty-one strings were hardcoded, and **every one was a screen-reader label** — an English string a Spanish user could not see was wrong. Those are now overridable. **No translations ship, and no `intl` dependency was taken**: the library provides the seam an app cannot add from outside, and the app provides the language. Still open: locale-aware **number and date formatting** (10 `toStringAsFixed` sites), and **plurals** in the four interpolated announcements, both of which genuinely need `intl` and belong in the app |
| **Theme previewer** | Try seed colours against real components in a browser before installing | Mostly the token explorer below, with a component view attached. Reuse the Widgetbook build |

### Tokens

| | What it is |
|---|---|
| **Component tokens** | `button.primary.background`, with hover / pressed / focus / disabled states. How a team styles *their own* widgets from Plinth |
| **The missing axes** | ~~Motion, typography, elevation, border width~~ — **shipped in 1.3.0**, each as a token *and* a migration of the literals it replaced. Still open: opacity, interaction state, platform flags (`boldText`, `highContrast`). `lineHeights` was planned and dropped: the library sets an explicit line height in one place, which is one widget rather than an axis |
| **Nested overrides** | A theme override for one subtree — sections, embedded brands |
| **`fromSeed`** | Promote the ramp generator to a public constructor |

### Interop

| | What it is |
|---|---|
| **DTCG export** | Emit tokens a web codebase can consume, the reverse of the import above |
| ~~**Theme validation**~~ | **Done.** `theme.validate()` returns every pair that falls short of its floor, worst first, naming tokens by their hierarchy path. Pointed at Plinth's own defaults it found two real problems — `border` at 1.26–1.49:1 where WCAG 1.4.11 asks 3:1 of a control boundary, and dark-theme `textMuted` on `surfaceSunken` at 4.36:1 — **both recorded and left alone**, because fixing either changes the look of every app already on Plinth. Pinned by a test that fails in either direction |
| ~~**Token explorer**~~ | **Done**, as `docs/TOKENS.md` — generated, committed, and held fresh by `token_usage_fresh_test.dart`. All three parts: every token, both themes side by side, and which components read each. The third needed writing because `theme.surface`, `theme.spacing[PlinthSize.md]` and `theme.space(4)` are all token reads and none of them look alike. Dynamic reads (`theme.shaded(colorKey, 6)`) are reported as a *kind* rather than guessed at — assuming `color.blue.6` because blue is the default would be a lie that survives until somebody rebrands |
| **Golden helpers** | Let an adopter pin their own token usage the way this repo pins its own |

### Accessibility

| | What it is |
|---|---|
| ~~**Roving focus**~~ | **Done for the dropdown family.** Extracted to `option_keyboard.dart` and wired into `PlinthAutocomplete` and `PlinthMultiSelect`, which opened lists a pointer could use and a keyboard could not — arrows and Enter both did nothing. **WCAG 2.1.1**, in a place no existing test looked: reachability and focus order are both satisfied by a field whose *list* is inert. The shape is as predicted — a highlight, not a focus trap, because the keyboard belongs in the field. **One correction: `PlinthSelect` was never affected**, since it wraps Material's `DropdownButton`. Still open: folding `PlinthTabs` and `PlinthSegmentedControl` onto the same helper, which is tidying rather than a defect |
| ~~**A second keyboard sweep**~~ | **Done.** `F-4` was found by ear, not by any test, because every accessibility test here walks the semantics tree and the tree was right. All three keyboard questions now have coverage: `plinth_keyboard_reachable_test.dart` (can Tab reach it), `plinth_focus_visible_test.dart` (can you see where it landed — found five controls that were reachable and invisible, fixed in 1.3.1), and `plinth_focus_order_test.dart` + `plinth_blocks/test/focus_order_test.dart` (is the route between them sane — **no defects found**, and the check carries a negative control so that means something) |

### Trust and distribution

Comparison piece (writable now, on verified facts); surface
`plinth_hooks`, which exists and is under-marketed; pub points and
coverage badges; GitHub Discussions; Flutter Gems and awesome-flutter
submissions; adoption milestones as they happen.

## Not doing

| | Why |
|---|---|
| A token *compiler* | Style Dictionary emits static constants, which cannot express `textScaler`, density, `WidgetStateProperty`, per-subtree overrides or `readableOn`. Consume the standard; do not rebuild the pipeline |
| `plinth_form`, `plinth_dates` | Both audiences already have forms and dates |
| Charts, rich text | Separate projects |
| ~30 DOM-only hooks | Web-only, in a library that is not |
| Most of `plinth_hooks` | A team has its own state utilities. `use-focus-trap` and `use-roving-index` survive because roving focus needs them |
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
`@mantine/core` because its answer was right; five exist because
Flutter asked a question a web library never had to — `PlinthLtr`,
`PlinthFocusTrap`, `PlinthTapTarget`, and now `PlinthLiveRegion` and
`PlinthAnnounceWhen`. The last two are the clearest case of the whole
pattern: the web spells a live region as an attribute, so Mantine never
needed a component for it and Flutter has nothing at all.

**Where the two disagree, Flutter wins.** Filled buttons carry a dark
label because white on Mantine's own `blue.6` is 3.56:1 and fails AA.
Looking less like Mantine and being more correct on a platform with a
system-level accessibility contract is the trade this library takes on
purpose.

## The claims gate

**Do not publish interaction-state or variant language** — it does not
exist here, and it is Mix's, by name.

Today's checkable claim: *118 components on a shared token system — 112
tracking `@mantine/core`, five answering questions only Flutter has, one
found by converting an app onto it — with 43 golden images and 87 test
files behind them.*

Alongside them, and counted separately because they version separately:
*43 blocks in `plinth_blocks` and 4 charts in `plinth_charts`, with 28
and 4 test files behind them.* The demo app browses **117**
arrangements across 3 categories, of which the 38 are the ones that
have become real widgets with real APIs; the rest are still component
demos and [SHOWCASE.md](SHOWCASE.md) says which, and why.

**Derive these, do not edit them.** Three of the numbers above were
wrong before 1.7.0 — blocks read 43 against an actual 41, and the two
test-file counts were stale by 11 and 1 — because each was hand-updated
in one place and not the others. The commands are the definition:

```bash
# components — the barrel and the reference must agree, and do
grep -c "^export 'src/" packages/plinth_components/lib/plinth_components.dart
grep -cE '^#{2,3} `?Plinth' docs/COMPONENTS.md
# blocks, charts
grep -c "^export 'src/" packages/plinth_blocks/lib/plinth_blocks.dart
grep -c "^export 'src/" packages/plinth_charts/lib/plinth_charts.dart
# tests, goldens
ls packages/plinth_components/test/*_test.dart | wc -l
ls packages/plinth_blocks/test/*_test.dart | wc -l
ls packages/plinth_components/test/goldens/*.png | wc -l
```

That the component count and the reference-doc count are the same number
is not a coincidence and is worth keeping: a component with no entry in
[COMPONENTS.md](COMPONENTS.md) is undocumented, and the two counts
diverging is how you find out.

The token engine carries **nine** scales, not four: colour, spacing,
radius and font size, plus font weight, duration, curve, border width
and elevation as of 1.3.0. The last five are checkable in a stronger
sense than the others — `plinth_token_axes_test.dart` overrides each
one and asserts what *rendered* changed, so "the theme drives it" is
tested rather than assumed. That test exists because `shadow` was a
public, documented, `lerp`-carried token that painted nothing for three
releases.

And four starter apps in `templates/` — dashboard, account, blog,
mobile list–detail — with **36 tests** between them. They are melos
packages, so CI compiles and tests them with everything else.

**What the template tests are, and are not.** They do not test Plinth;
the packages test themselves. They assert that each app still compiles
against the current API, still navigates at phone width, still
announces what it changes, and that every role in it clears 4.5:1 on
both surfaces. So *"the starters still work"* is a checkable claim
rather than an assumption, which is the only reason to keep starters in
a repository instead of in a gist.

**Do not quote a block count from another document.** These packages
are moving, every count above is derived from source, and the one
number that has gone stale in every past round is this one.

**`B0c` has run**, so the token-engine framing is publishable: the
accessibility work has been heard, not only asserted against simulated
semantics trees.

**`F-3` is now heard end to end**, on both of its mechanisms, in a
collaborative NVDA pass on 23 Aug 2026 — validation errors,
notifications, alerts, loading completion and progress completion, no
defects. Including both judgement calls: the error that left the
checkbox's name, and alerts announcing themselves by default. See
[B0C_FINDINGS.md](B0C_FINDINGS.md#fourth-pass--23-aug-2026).

So **that nothing changing on screen goes unannounced is now a
publishable claim** — heard, not asserted against a semantics tree.

Two caveats belong with it wherever it is made. Announcements are
silent on Android by that platform's own policy, so the tree-carried
half is what reaches every platform. And *heard* means heard on the web
with NVDA; no other reader has been in the room.

**A caution the second pass earned.** `F-4` — two components that were
clickable, announceable, and unreachable by Tab — was found by ear and
by nothing else, because every accessibility test here walks the
semantics tree and the tree was correct. Passing tests are evidence
about the tree, not about the app.
