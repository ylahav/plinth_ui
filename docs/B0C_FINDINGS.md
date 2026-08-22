# B0c findings — heard, not asserted

Results, not plan. The script is
[B0C_SCREEN_READER_PASS.md](B0C_SCREEN_READER_PASS.md); this is what
happened when somebody ran it.

**Status:** run 22 Aug 2026 against the published demos, NVDA on
Windows, Chrome. Every accessibility claim in this repo before today
rested on tests and simulated semantics trees. This is the first time
any of it was heard.

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
unannounced, which is F-3 and is open.

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
