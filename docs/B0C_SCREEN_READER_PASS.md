# B0c — the screen-reader pass

The one task in Workstream B that no amount of code satisfies. Everything
else was static analysis and simulated semantics trees; **no screen
reader has actually spoken this library.**

Run against the deployed demo: <https://ylahav.github.io/plinth_ui/>
(NVDA on Windows, VoiceOver on macOS or iOS). Record the result either
way — *"already correct, here is the transcript"* is as useful an entry
as a fix, and is what `B0a` said too.

## Before you start

**Everything below was fixed on 19–20 Aug 2026 and has never been
heard.** The expected announcements are what the semantics tree
*contains*; whether a real screen reader reads it that way, in that
order, and whether it makes sense out loud, is exactly what this is for.

The demo's own `PlinthActionIcon` instances were unlabelled until this
document was written — 44 of them. If you had run this pass earlier you
would have heard 44 unnamed buttons and concluded the library was
broken, when it was the demo. They now carry labels.

**A page-level sweep ran first**, walking the semantics tree of all 25
demo pages in traversal order — the closest thing to this pass that a
test can do. It found **14 unlabelled tap targets out of 399**, four of
them library bugs now fixed (copy button, password toggle, number
steppers, carousel arrows). **Three remain**, all in the demo's own
composed blocks: one in Navbars and two in Buttons. Expect to hear them.

That sweep is not this pass. It cannot tell you whether the order makes
sense, whether an announcement is exhausting to listen to, or whether
"1 of 5" is clearer than what a real reader says. It only means you will
be listening for judgement calls rather than for missing names.

## What to check, and what you should hear

### 1. The controls that had nothing at all

| Control | Expected | Was |
|---|---|---|
| **Rating** | "1 of 5", "2 of 5" … and the current value marked selected | five anonymous tap targets, no label, no role |
| **PIN input** | "Digit 1 of 4", "Digit 2 of 4" … | four identical unnamed fields |
| **Action icons** | the action — "Edit", "Delete", "More actions" | announced as an unnamed button |

**Rating is the one to listen to hardest.** It was the worst in the
library: a user could reach all five stars and learn neither what
tapping did nor what the rating already was.

### 2. The controls that were announced as text

Each should now say it is a control, not just read its label.

- **Accordion** — a *button*, and says collapsed/expanded.
- **Breadcrumbs** — the crumbs with an action are *links*; the last one
  is not.
- **Stepper** — tappable steps are *buttons*.
- **Anchor** — a *link*.

### 3. Form fields — the label has to arrive with the field

Nine widgets rendered their label as a sibling of the field, which
showed it to you and to nobody else. Tab to each and listen for the
label *as you land on it*, not as a separate line above:

`TextInput`, `Textarea`, `NumberInput`, `PasswordInput`, `TagsInput`,
`Autocomplete`, `Select`, `MultiSelect`, `TreeSelect`.

A select should announce its label **and** its current value together.

### 4. Keyboard, which a screen-reader user lives in

- **Popover and Menu** — Tab must not walk out of the open panel onto
  the page behind it; Escape closes; focus returns to the trigger.
- **Modal and Drawer** — the same, which they already did via their
  route.
- Everywhere — Tab order should follow reading order.

### 5. Contrast, if you can see the screen while listening

Alert and notification icons and titles moved a long way this cycle. The
question is not whether they pass a ratio — that is asserted in tests —
but whether the result still looks like the alert's colour.

## What counts as a failure

- Any control announced as "button" or "" with no name.
- A form field whose label you only hear as separate static text.
- Tab leaving an open menu or popover.
- An announcement that is technically present but unusable out loud —
  "1 of 5" is fine, "PlinthRating star 1 InkWell" is not.

## Where the results go

`PHASE_MINUS_1_FINDINGS.md`'s style: what was predicted, what happened,
and prefer the findings that surprised. Then tick `B0c` in
`ROADMAP.md`.

**If this comes back clean**, the accessibility work has been heard by
something other than a test, and `1.0.0` stops being a promise made on
static analysis alone.
