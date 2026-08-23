# F-3 — announcing what changes

*Written 22 Aug 2026, against `1.1.0`. The task list behind
[ROADMAP.md](ROADMAP.md) "Next 1", from
[B0C_FINDINGS.md](B0C_FINDINGS.md) F-3.*

Nothing that happens while the user holds still is spoken. Every probe
from `B0a` to `B0d` tested what could be *reached* — by Tab, or by
walking the tree — so all four were structurally blind to this.

Verified before writing this list, not assumed: `liveRegion` appears in
exactly one file, [plinth_pin_input.dart:178](../packages/plinth_components/lib/src/widgets/plinth_pin_input.dart),
and `SemanticsService.announce` appears nowhere in package source.

---

## The finding that reorders the work

**There is no shared field shell.** Each of the 17 inputs that take an
`error` renders its own error `PlinthText` inline, with its own
spacing. Nothing is wired through a common wrapper, so this cannot be
fixed in one place as it stands — which is why the roadmap calls the
migration "the long part".

That makes task 1 the whole game. Build the primitive first and the
other seventeen are mechanical; skip it and this is seventeen
independent judgement calls that will drift apart.

## The rule this list applies

| The message | What to use | Why |
|---|---|---|
| Is on screen and stays there | `PlinthLiveRegion` | There is a node to attach to; the flag is what makes a reader visit it without focus moving |
| Has no lasting visual, or leaves the tree | `PlinthAnnounce.say` | Nothing to attach to. A node that is gone announces nothing |

Both are needed. `liveRegion` alone cannot say "finished" about an
overlay whose disappearance *is* the event.

**Prefer the first wherever it fits**, and not only for tidiness:
Android reports `supportsAnnounce: false`, having deprecated
announcement events because TalkBack clears its speech queue to serve
them. The tree-carried path works everywhere; the imperative one is
silent on Android by platform policy. That is a design input for task
4, not a bug to work around.

---

## Tasks

### 1. The announcer primitive — the gate on everything below ✅

**Done.** [plinth_announce.dart](../packages/plinth_components/lib/src/widgets/plinth_announce.dart),
beside `PlinthVisuallyHidden`, which solves the adjacent problem of
text only a reader sees. Both halves shipped: `PlinthLiveRegion` and
`PlinthAnnounce.say`, exported and listed in
[COMPONENTS.md](COMPONENTS.md) — a helper for styling *your own*
fields is the product thesis, so keeping it internal was the wrong
trade. The count moved 115 → 116, and the README guard enforced it.

What it settles once, so seventeen call sites do not each decide:

- **Empty is not a message.** `''` and `null` both return the child
  untouched — no node, no announcement. A live region with nothing in
  it is a node a reader visits to hear silence.
- **The flag does not spread.** `container: true`, which is the one
  deliberate difference from the hand-written region in `PlinthPinInput`
  that `B0c` heard. Merged into a form field, `liveRegion` makes the
  *whole control* live and every rebuild re-speaks the label. Tested by
  asserting exactly one node in a field carries the flag.
- **Politeness.** `Assertiveness`, honoured on web; a validation error
  interrupting is usually right, a loading update is not.

**One thing this cannot settle, corrected from the first draft of this
list:** whether an unchanged message is spoken twice is decided by the
platform bridge, not the framework — on web the flag becomes
`aria-live`, which fires on text change. The controllable half is "no
message, no node", and that is what is guarded.

### 2. Validation messages — 17 widgets ✅

**Done.** Every control that takes an `error` now routes it through
`PlinthLiveRegion`, pinned by
[plinth_error_live_region_test.dart](../packages/plinth_components/test/plinth_error_live_region_test.dart)
— each of the eighteen asserted in both states, message and none. A
control added later with its own hand-rolled error line fails that
test, which is the drift the primitive exists to prevent.

Fourteen files changed rather than seventeen: **colour, JSON and mask
input render no error line of their own**, handing it to
`PlinthTextInput`. They are covered by the test anyway — what matters
is that the message is heard, not which widget drew it.

`pin_input` was migrated too. It was the reference, and leaving it
hand-written would have made the family one shape plus one exception.

`description` was left alone, as planned: static helper text that
arrives with the field is not a change, and making it live would speak
it twice.

**The double-speaking risk was real, and it landed where predicted.**
Checkbox, switch and radio hold their error *inside* the control's
merged label — verified by walking the tree, not assumed — so it was
spoken on focus and never on arrival. A live region needs its own
node, which takes the error back out of that name:

| | Before | After |
|---|---|---|
| Checkbox name | `Accept terms / You must agree / This field is required` | `Accept terms / You must agree` |
| The error | in the name, heard only on focus | its own live region, heard when it appears |

**The trade was taken deliberately, and is pinned by a test so it stays
visible.** It is what the text inputs have always done — the error as
an adjacent node, never part of the field's name — so the family now
reads one way instead of two. What is lost: a Tab-only user returning
to the control no longer hears the error again as part of its name.
What is gained: hearing it at all when it appears, which is the whole
of `F-3`. Worth a question on the next `B0c` pass rather than a
decision made once and forgotten.

### 3. Notifications and alerts ✅

**Done.** Both carried no `Semantics` wrapper at all. Both now take
`live`, defaulting to true, covering the title and body — never the
dismiss button, which is a control and would re-speak "Dismiss alert"
alongside every message.

`PlinthLiveRegion.always` was added for these. The default constructor
asks "is there anything to say?" of a string; a notification's content
is a widget, and its existence is the answer.

**The gap was not where it looked.** Flutter's own `SnackBar` already
wraps its content in `Semantics(container: true, liveRegion: true)` —
the same shape this library settled on independently — so
`PlinthNotification.show`/`showOn` were never silent. They now pass
`live: false` explicitly, because a second region nested inside the
first is how a fix becomes a stutter. There is a test asserting the
shown path produces exactly one live region.

The default therefore serves the path nothing else covered: a
notification placed in a tree by hand.

**Alerts default to live, which is a judgement call.** The usual alert
is raised by something the user just did, and that is precisely what
`F-3` found nothing ever spoke. The cost is a page of standing
informational banners reading itself aloud — on the web close to zero,
since a live region registered during the initial render announces
nothing until it changes, but real on other platforms. `live: false` is
the escape hatch and is documented on both.

**Dismissal is silent, decided rather than left open.** The user
pressed the button, or a timer ran out on a message they were free to
ignore. Neither is worth interrupting for.

### 4. Loading completion ✅

**Done, and it is the task that justifies the imperative half.**

`PlinthLoadingOverlay` became stateful to see the edges, and speaks
them by two different mechanisms because it has to:

| Edge | Mechanism | Why |
|---|---|---|
| `visible` false → true | `loadingLabel` in a live region | There is a node; this works on every platform |
| `visible` true → false | `completeLabel` via `PlinthAnnounce.say` | The overlay is gone. Nothing is left to speak from |

A spinner is a picture of waiting and carries no text, so the label is
the whole of what there is to say. Either can be `''` to stay quiet.

`PlinthLoader` got `semanticLabel` (default `'Loading'`) and
**deliberately not a live region**: it usually sits inside something
whose own change is already spoken — a button going busy, a panel being
replaced — and a second voice would say the same thing twice. Before
this it read as nothing at all.

`PlinthSkeleton` was left alone after looking at it. It is a shimmering
box with no text, produces no semantics node, and has nothing to say —
"silent" is already correct there rather than a gap.

### 5. Progress — the one that needed restraint ✅

**Done, and it needed *less* than this list assumed.**

First, a correction: these did not have "no `Semantics` today". The
*sectioned* bar and ring already built a label from their parts. What
had nothing was the single-value form — the common one — which read as
nothing at all.

The rule inverts here, because progress is the only surface in the
finding that can change every frame:

| | What it gets | Why |
|---|---|---|
| The value | A semantic `value` — `'60%'` — plus `semanticLabel` to name it | Read when somebody visits. **Never a live region:** marked live, a bar narrates every frame of its own animation |
| Reaching 1.0 | `completeLabel`, spoken once via `PlinthAnnounceWhen` | The only moment worth interrupting for |

**`completeLabel` is opt-in, unlike everything else in this list.** Most
progress bars are statistics — storage used, quota reached — not
running operations. A default would have every dashboard announcing
completions that never happened.

**And it never fires on first build.** A bar rendered at 100% is a
number that was already there; announcing it reports an event that did
not occur. That is what `PlinthAnnounceWhen` holds state for, and there
is a test named after it.

Where a ring or gauge already has a centre label — which is usually the
percentage — no `value` is added, because the same number read twice is
worse than the number read once.

**New primitive:** `PlinthAnnounceWhen`, the edge neither half of the
original pair covered. The count moved 116 → 117.

---

## How it gets verified

[plinth_announced_state_test.dart](../packages/plinth_components/test/plinth_announced_state_test.dart)
already walks the **real** semantics tree rather than trusting
`getSemantics`, for the reason recorded in its header. Live regions go
there, in that style.

Announcements need the other technique, and **no helper had to be
written for it** — this list first said one did. `flutter_test` already
ships `tester.takeAnnouncements()` and the `isAccessibilityAnnouncement`
matcher, which capture the accessibility channel directly. Both are
used in [plinth_announce_test.dart](../packages/plinth_components/test/plinth_announce_test.dart).

The API to call is `SemanticsService.sendAnnouncement`, not `announce`
— the latter is deprecated as of 3.35 for reaching at the implicit
view, and asserts where there is not exactly one.

Both belong in the suite before the claim below is made.

## What this unlocks

The claims gate in [ROADMAP.md](ROADMAP.md) named one claim as resting
on nothing: *that nothing changing on screen goes unannounced.* All
five tasks have landed, so the code behind it exists.

**Partly heard, on 23 Aug 2026.** The pin input's result — the whole
chain, live region through shared primitive — was confirmed spoken in a
real browser, focus unmoved. Recorded in
[B0C_FINDINGS.md](B0C_FINDINGS.md#second-pass--23-aug-2026).

**The rest is not earned yet**, and the difference matters: everything
else here is verified against the semantics tree, which is exactly the
kind of evidence `B0c` was run to stop trusting on its own. That pass
proved the point again — `F-4`, two components clickable and
announceable but unreachable by Tab, was invisible to every test in
this repo *because the tree was correct*.

Four parts have not been listened to. Two are judgement calls rather
than mechanics:

- The **checkbox, switch and radio** label change in task 2 — the error
  left the control's name to become a live region.
- **Alerts defaulting to live**, and what a page of standing callouts
  sounds like on a platform that announces them on arrival.
- **Loading completion**, which goes through `sendAnnouncement` rather
  than a live region — a different mechanism from the one confirmed
  above, and silent on Android by that platform's policy.
- **Progress `completeLabel`.**

The gallery gained two use cases so the last three can be reached at
all: `PlinthAlert` → *Raised by an action* and `PlinthProgress` →
*Announced on completion*, both button-driven because `&preview` drops
the knobs panel.

Until those are heard, the honest claim is that the library *has*
announcements, tested — not that they are known to read well.

The comparison piece under *Trust and distribution* was waiting on
this. It can be written once the rest is confirmed.
