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

## How to actually run it

### Before anything: turn Flutter's semantics on

**Flutter web ships its accessibility tree switched off.** The page
contains a button labelled **"Enable accessibility"** that is invisible
on screen but present in the DOM, and until it is activated Flutter's
semantics are *not in the DOM at all*.

Skip this and every control is silent. You would conclude the library
has no accessibility whatsoever, when what you measured was the
placeholder.

**Do this before anything else, and confirm it worked.**

#### The normal way — with NVDA running

1. **Start NVDA first**, then open the demo. Order matters: the button
   is placed for a screen reader, and some Flutter versions enable
   semantics automatically once one is detected.
2. **Click once on the page itself** — anywhere in the white area. This
   moves focus out of the browser's address bar and into the document.
3. Press **`Tab`**. NVDA should say something like
   **"Enable accessibility button"**.
4. Press **`Enter`**.

If step 3 says something else — a link, a heading, the demo's own first
control — then either semantics are already on, or focus is not where
you think. Check with the next section rather than guessing.

#### Confirm it worked — no screen reader needed

Press **`F12`** for devtools, open the **Elements** tab, and press
`Ctrl+F` to search the DOM for:

```
flt-semantics
```

- **Only `<flt-semantics-placeholder>`** — accessibility is still
  **off**. The button has not been activated.
- **A tree of `<flt-semantics>` elements** — it is **on**, and those
  elements are the accessible DOM Flutter builds from the semantics
  tree. Each control you have been reading about in this document is one
  of them.

This is worth doing once even if step 4 seemed to work, because it turns
"I think it is on" into something you can see.

#### If Tab will not find the button

Open the devtools **Console** (`F12` → Console) and run:

```js
document.querySelector('flt-semantics-placeholder')?.click();
```

Then re-run the `flt-semantics` search above. This activates the same
button directly and avoids fighting focus order — useful when the page
has just reloaded, or when you are re-checking one page repeatedly.

**Re-enable after every page load.** It does not persist across a
refresh or a navigation, and forgetting is the most likely way to record
a false failure.

### NVDA, on Windows

1. Install from [nvaccess.org](https://www.nvaccess.org/download/). The
   **portable copy** works and needs no install.
2. `Ctrl` stops speech mid-sentence. Use it constantly.
3. The NVDA modifier key is `Insert` (or `CapsLock`, if you chose that
   at install).

**Turn on the Speech Viewer before you start** — NVDA menu (`NVDA+N`) →
*Tools* → *Speech Viewer*. It prints everything spoken as text in a
window you can read and copy.

That single setting is what makes this pass worth doing rather than
exhausting: you can paste real transcripts into the findings instead of
writing down what you think you heard, and a transcript is checkable
by someone who was not there.

| Key | What it does |
|---|---|
| `Tab` / `Shift+Tab` | Next / previous focusable control — **the main tool here** |
| `NVDA+F7` | Elements list: every button, link and form field with its name. Fastest way to spot an unnamed one |
| `NVDA+↓` | Read continuously from here |
| `Ctrl` | Stop talking |

### VoiceOver, on macOS

`Cmd+F5` toggles it. The VO modifier is `Ctrl+Option`.

| Key | What it does |
|---|---|
| `Tab` | Next focusable control |
| `VO+→` | Next item, including things Tab skips |
| `VO+U` | Rotor — browse by control type |
| `Ctrl` | Stop talking |

### One Flutter-specific thing to expect

Flutter does not emit HTML `<label>` elements, so a text field announces
as **"edit, blank"** when it has no accessible name of its own.

**That is the exact thing nine widgets were fixed for**, and it makes a
sharp test. Tab to any Plinth form field and you should hear the label
*with* the field — "Email, edit, blank". If you hear a bare "edit,
blank", the label is not reaching the DOM and the fix did not work in a
real browser, whatever the tests say.

### Suggested route, about 30 minutes

1. Open the demo, Tab once, Enter — accessibility on.
2. `NVDA+F7` on two or three pages. Anything with an empty name is a
   finding, and this catches them far faster than listening.
3. Then Tab through one whole page slowly, listening for order and for
   announcements that are technically correct and unusable.
4. Open a menu and a popover: Tab must not escape, Escape must close,
   focus must come back to the trigger.
5. Rating and the PIN input by hand — they were the worst, and the fix
   is the least like anything else.

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
- A text field that says "edit, blank" with no name in front of it.
- A form field whose label you only hear as separate static text.
- Tab leaving an open menu or popover.
- An announcement that is technically present but unusable out loud —
  "1 of 5" is fine, "PlinthRating star 1 InkWell" is not.

## Where the results go

`PHASE_MINUS_1_FINDINGS.md`'s style: what was predicted, what happened,
and prefer the findings that surprised. Paste the Speech Viewer
transcript for anything that failed — a quotation is worth more than a
description, and it lets a fix be checked against the same words.

Then tick `B0c` in `ROADMAP.md`.

Findings ship as `1.x` corrections: `1.0.0` promises the API, not
rendered output or announcements. Batch them with the README and topics
changes already sitting unpublished on `main`.

**If this comes back clean**, the accessibility work has been heard by
something other than a test, and `1.0.0` stops being a promise made on
static analysis alone.
