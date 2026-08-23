# B0c findings — heard, not asserted

Results, not plan. The script is
[B0C_SCREEN_READER_PASS.md](B0C_SCREEN_READER_PASS.md); this is what
happened when somebody ran it.

**Status:** run 22 Aug 2026 against the published demos, NVDA on
Windows, Chrome. Every accessibility claim in this repo before today
rested on tests and simulated semantics trees. This is the first time
any of it was heard.

**Second pass 23 Aug 2026**, against the `F-3` work built in between —
same setup, different listener. It found one more library defect, one
demo defect, and repeated one of the false alarms below. See
[the second pass](#second-pass--23-aug-2026) at the end.

## The headline

**Two real defects out of roughly seventeen controls checked.** Both in
the same blind spot, and neither was reachable by the kind of test that
had been written.

Everything the nine form-label fixes did — the largest single piece of
accessibility work in the library — **holds up in a real browser.**
That was the gate on the token-engine framing, and it is clear.

## What was found

### F-1 — a read-only rating enumerates the scale and never states the value

**Predicted:** nothing. Rating was fixed earlier this cycle and the
interactive form was verified.

**Heard:** silence on Tab, and in browse mode `"1 of 5, 2 of 5, 3 of 5,
4 of 5, 5 of 5"` for a rating whose value is 3.5.

Read-only, `onChanged` is null, so no node is focusable and Tab skips
the widget entirely — correct, it is not a control. But the five
per-star labels survive without their buttons, so what remains is a
recitation of the scale with the answer left out.

**Why no test caught it:** `plinth_semantics_test.dart` only ever built
`PlinthRating` **with** `onChanged`. The read-only form was tested for
star rendering and never for semantics, and the B0 probes inherited the
hole.

**Fixed:** read-only emits one node — `label: "Rating"`,
`value: "3.5 of 5"` — and excludes the stars.

### F-2 — the pin input never says whether the code was accepted

**Predicted:** nothing; this was not on the script at all. It came from
a question — *after the last digit, what about the result?*

**Heard:** nothing, which was the point.

`error` was a `bool` that recoloured a border. Type the last digit and
`onCompleted` fires, focus does not move, the border turns red, and a
screen reader has no reason to look at any of it. The outcome of the
whole interaction was carried by one colour.

**This is also a plain WCAG 1.4.1 failure**, sighted. Colour was the
only channel. No test could catch that either: a red border passes the
3:1 non-text contrast check comfortably, and the contrast suite asks
whether a border is visible, never whether it is the only thing
speaking.

**Fixed:** a `statusText` slot, rendered under the boxes and marked
`liveRegion` so it is spoken on arrival without focus moving. It reads
success as well as failure.

### F-3 — nothing asynchronous is announced anywhere in the library

The general form of F-2, and the finding that outlives both.

`liveRegion` and `SemanticsService.announce` appear **zero times**
across all package source. Every probe from B0a to B0d tested what
could be *reached* — by Tab, or by walking the tree — so all four were
structurally blind to anything that happens without the user moving.

F-2 is fixed where it was found. Validation messages, notifications and
loading completion elsewhere in the library have the same gap.
**Open**, and now on the roadmap.

> **Built 22–23 Aug 2026** — see
> [F3_ANNOUNCEMENTS.md](F3_ANNOUNCEMENTS.md). Partly heard in the
> second pass below; most of it is still tree-verified only.

## What was checked and was right

| | |
|---|---|
| **The nine form fields** | Label arrives with the field, not as text beside it. The whole point of the work, heard |
| **Menu and popover** | Tab stays inside, Escape closes, focus returns to the trigger |
| **Accordion** | Correct in both states — closed, the content is not in the tree at all; open, the header reports expanded and the answer appears |
| **Interactive rating** | Five buttons, `"1 of 5"` … `"5 of 5"`, current value marked selected |
| **Semantics reach the DOM** | On the showcase and the gallery both |

## Three false alarms, and what each was worth

Every one came from the same misunderstanding, and each produced a rule
the script had been missing.

| Reported | Actually | Now written down |
|---|---|---|
| "Rating does not talk" | Correct for Tab — a read-only rating is not a control. Browsing it then exposed F-1 | Tab reaches controls; arrows read everything else |
| "Accordion does not read the content" | Correct in both states. Tab goes header to header; the answer is content, reached by arrowing | — as above |
| `Failed to update ui::AXTree` | [flutter/flutter#182444](https://github.com/flutter/flutter/issues/182444), open, P2, Windows desktop only. `ListView` + `Tooltip`'s `OverlayPortal`. Not ours, and absent on web | Named in the script so it is not filed as a Plinth bug |

**The false alarms were worth having.** A first-time screen-reader pass
produces them by construction, and the fix is not to be more careful —
it is to write down the distinction that caused them. All three are now
in the script, before the checklist rather than after it.

## What this changes

The claims gate said the token-engine framing was publishable once B0c
came back clean. It came back with two defects, both now fixed, and
everything else correct.

**The accessibility claims no longer rest on static analysis alone.**
What can still not be claimed: that nothing changing on screen goes
unannounced, which is F-3. It is now built, and one part of it has been
heard — see below — but most of it has not.

## Method notes, for whoever runs this next

- **Flutter web ships semantics switched off.** Not knowing this
  produces a false total failure. See the script.
- **NVDA's Speech Viewer** turns the pass from recollection into
  transcripts.
- **Run the gallery with `&preview`**, or most of what you hear is
  Widgetbook's own navigation tree.
- **Ask questions the script does not contain.** F-2 — the more
  valuable of the two defects — was not a checklist item. It came from
  wondering what happens after the last digit.

---

# Second pass — 23 Aug 2026

Against the `F-3` announcement work, on the showcase. Same setup, a
different listener, which turned out to matter.

## The headline

**One library defect, one demo defect, and one repeat false alarm.**
The defect is the interesting one: it is the first thing found here
that **no amount of walking the semantics tree could have caught**,
because the semantics were correct.

## F-4 — a link a mouse could click and a keyboard could never reach

**Reported as:** "Tab from the last digit of the PIN input does not
jump to *Send a new code*, it goes to the next link outside."

**Was:** exactly that, and not the PIN input's doing. `PlinthAnchor`
was `Semantics(link: true) > GestureDetector`. A `GestureDetector`
supplies a tap *action* but no focus node, so the link was clickable by
mouse, activatable by a screen reader in browse mode, and invisible to
Tab. **WCAG 2.1.1, failed outright.**

`PlinthUnstyledButton` had the identical shape, and worse for being
named a button. A sweep for `GestureDetector` with no focus mechanism
found those two and nothing else.

**Why nothing caught it, which is the part worth keeping:**

- **NVDA's elements list showed the link.** The semantics were right —
  that is what made it invisible.
- **`B0c` checked that Tab-reachable controls are named.** Not that
  everything actionable is Tab-reachable. Nobody was looking in that
  direction.
- **No tree-walking test could have found it.** Every accessibility
  test in this repo inspects the semantics tree, and the tree was
  correct. The missing thing was a *focus node*, which lives somewhere
  else entirely.

**Fixed:** both use `FocusableActionDetector` — focus node, Enter and
Space, and a ring while focused, drawn as a foreground decoration so
nothing shifts. `ActivateIntent` and `ButtonActivateIntent` are both
handled, because the web routes Enter to the second and Space to the
first while other platforms send the first for both.

**And a new sweep**, `plinth_keyboard_reachable_test.dart`: every
interactive component, asserting a single Tab lands on the control
rather than past it. A disabled anchor is asserted *skipped* —
focusable and dead is worse than unfocusable.

## F-5 — the demo bypassing the fix it existed to show

**Reported as:** "it does not read the results" of the PIN input.

**Was:** true of the demo, false of the library. The showcase's "Enter
your code" example rendered its result as a `PlinthText` **sibling** of
the PIN input rather than passing `statusText` — and `statusText` is
the live region, the whole of what `F-2` added. So the message appeared
in silence, and the library took the blame.

It looks identical on screen. There is no way to tell the two apart
from outside the code, which is what makes it worth a number.

**This is the second time.** The script already warns about the 44
unlabelled `PlinthActionIcon`s in the demo, for exactly this reason:
*the demo is where somebody forms their first opinion about whether any
of this works.* A demo that does not use the library's own affordance
is a demo that reports the library as broken.

**Fixed** in the showcase, and in the displayed source beside it, which
is a hand-maintained copy an adopter reads as the recommended way.

## What was heard and was right

| | |
|---|---|
| **The PIN input result** | `"Verified"` / `"That code has expired or is wrong"` spoken on arrival, focus unmoved — `F-2`'s fix and `F-3`'s primitive, working end to end in a real browser, once `F-5` stopped hiding it |
| **The anchor, after `F-4`** | Tab reaches it, Enter fires it |

## The fourth false alarm — the same as the second

| Reported | Actually |
|---|---|
| "Accordion says expanded but does not read the content" | Correct. Tab goes header to header; the body is content, reached by arrowing |

**It was already written down** — it is the second row of the false
alarm table above, from the first pass. It recurred anyway, with a
different listener.

What that is worth: **writing a distinction down does not stop it
recurring; it has to reach the listener before they start.** The answer
took ten seconds *because* it was written down, and the tree dump
confirming it took two minutes. That is the value, and it is a
different value from prevention.

The practical rule: **ask a new listener which navigation mode they are
in before treating any "it does not read X" as a finding.** Tab is
focus mode. Arrows are browse mode. Most first reports are the
difference between them.

## What is still not heard

The `F-3` work is built and tested against the semantics tree. Four
parts of it have not been listened to, and two are judgement calls
rather than mechanics:

- **The checkbox, switch and radio label change.** Their error left the
  control's merged name to become its own live region. The tree says
  this is right; whether it *sounds* right is open.
- **Alerts defaulting to `live: true`**, and what a page of standing
  callouts sounds like on a platform that announces on arrival.
- **Loading completion**, which goes through
  `SemanticsService.sendAnnouncement` rather than a live region — a
  different mechanism from everything heard so far, and silent on
  Android by that platform's policy.
- **Progress `completeLabel`.**

The gallery gained two use cases so the last three can be reached at
all: `PlinthAlert` → *Raised by an action*, and `PlinthProgress` →
*Announced on completion*. Both are button-driven rather than
knob-driven, because `&preview` — which the script asks for — drops the
knobs panel.

Until those are heard, the honest claim is that the library **has**
announcements, tested — not that they are known to read well.
