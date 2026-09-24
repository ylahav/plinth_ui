# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

Unlike `plinth_core`, `plinth_components` and `plinth_hooks`, this
package is **not yet in the lockstep** those three keep from `1.0.0`
onward — see
[PUBLISHING.md](../../docs/PUBLISHING.md#decided-lockstep-from-10-onward).
Whether it joins, or versions on its own because a block catalogue will
churn while a token engine does not, is a decision for the first
release rather than one to inherit from the number below.

## 0.3.0

### Added

- **`PlinthPhotoHeader`** — a photograph across the top of a page with
  a dismiss control over it. The detail-page header.

  **Reported by somebody building a real screen**, who found the parts
  and not the arrangement: `PlinthBackgroundImage` does photo and
  scrim, `PlinthHeroBlock` does a marketing hero over a photograph, and
  neither is a page header with a close button. They built it from
  their own photo widget and a `PlinthActionIcon`.

  It takes the image as a **widget**, not a URL —
  `PlinthBackgroundImage` calls `Image.network`, which is why the
  reporter had their own photo widget at all. A widget costs the caller
  `Image.asset(...)` and buys every image source Flutter has.

  Three things it gets right that are easy to miss: the controls take
  the safe area and the photograph does not, because edge to edge is
  the point of the photograph and a close button under a notch is the
  point of nothing; the photograph is **decorative unless labelled**,
  since most detail-page photos repeat the title and "image" announced
  repeatedly is noise; and the close button is named through
  `PlinthLocalizations` rather than a hardcoded "Close".

## 0.2.2

### Added

- **An `example/`.** Worth 10 pub points, which this package had been
  losing since its first release without anything saying so — the dry
  run is silent about it and the score is computed after publishing.

### Changed

- **Requires `plinth_components` ^1.5.0**, not a preference: the
  password-strength block reads `context.plinthStrings`, which is new
  in that release, and does not compile against 1.4.0.

## 0.2.1

### Changed

- **`PlinthCharacterLimitField` enforces its limit with a formatter**,
  now that `plinth_components` 1.4.0 gives `PlinthTextarea`
  `inputFormatters`. It refuses an over-long paste rather than
  accepting and correcting one — the gap 0.2.0 recorded under "Known
  gap", closed.

  The dependency floor moves to `^1.4.0` for that reason, and only that
  reason.

## 0.2.0

**Four input blocks, chosen because they differ in *kind*.**

`docs/SHOWCASE.md` has Inputs at 14 against Mantine's, the one
subcategory more than two behind — and its own note says most of the
remainder are "styling variations on arrangements already here
(contained fields, floating labels)". Adding those would have closed
the number and taught nobody anything, so these four close the part
that was actually missing: asynchrony, variable arity, a hard limit,
and one field bounding another. Inputs goes 7 → 11, and the three
styling variants are declined rather than padded.

### Added

- **`PlinthAvailabilityField`** — asks another system whether a name is
  free. Usernames, workspace slugs, emails at signup.

  Three things go wrong in hand-rolled versions and each is handled
  and tested. It debounces, so typing `ada` is one request rather than
  three about prefixes nobody chose. **It drops answers that arrive out
  of order** — `ad` is slow and `ada` is fast, so the answer about `ad`
  lands last and overwrites the right one. That bug needs two requests
  in flight and a particular ordering to appear, which is why it
  survives review; a test removes the guard and proves it returns. And
  a failed check is *not* a taken name, because telling somebody their
  preferred name is gone when the network hiccuped is a different lie.

  The result is a live region; the spinner is not. The answer arrives
  after the user stopped typing, which is exactly when nothing else
  would tell a reader it came.

- **`PlinthRepeatableFields`** — rows you can add to and take away from.

  The visible part is a button and a list. The part that is usually
  wrong is that **adding leaves focus on the button** while a new empty
  field appears out of sight, and **removing destroys the row the user
  was in** and drops focus wherever Flutter decides. So adding focuses
  the new row, and removing says what went and how many remain.

- **`PlinthCharacterLimitField`** — a limit that is enforced, not
  merely reported. A counter that goes red while the field keeps
  accepting text is a counter that lied; the form rejects the value
  later, elsewhere, in different words.

  It counts graphemes rather than code units, so a flag emoji is one
  character to the limit as it is to the person typing it. It announces
  **once**, when the remaining count first crosses the threshold — a
  live region on a counter reads a number after every letter, which
  makes the field unusable with a screen reader.

- **`PlinthDependentSelects`** — two selects where the first determines
  the second's options.

  Pick Portugal, then Porto, then change the country to Spain: Porto is
  not in Spain, and the form now holds a combination that cannot exist.
  Clearing the child is the obvious half; **saying so** is the half
  that gets missed, because the reset happens below where the user is
  looking and a reader hears nothing at all. A parent with no children
  disables the child rather than opening it onto an empty menu.

### Known gap

`PlinthCharacterLimitField` enforces its limit by truncating in a
controller listener rather than with a `LengthLimitingTextInputFormatter`,
because `PlinthTextarea` does not take `inputFormatters` and
`PlinthTextInput` does. That disagreement is a real gap in
`plinth_components` rather than a decision. When it closes, this should
become a formatter — one runs before the value is committed, where this
runs after and corrects it.

## 0.1.0

Released 21 Sep 2026. The first blocks, and the shape the rest
will follow.

### Added

- `PlinthAuthCard` — the card the authentication blocks are built in,
  public because the four here are not the only auth screens an app
  has. A "check your email" interstitial or an SSO hand-off is the same
  card with different contents, and rebuilding it to add one is how a
  screen ends up not matching the others.
- `PlinthSignInBlock` — email, password, remember-me, a forgot-password
  link that is absent rather than inert when it has nowhere to go, and
  alternatives under a divider that only appears when there are any.
  Reports `(email, password, rememberMe)` on submit.
- `PlinthSignUpBlock` — name, email, password, terms. The terms gate
  the submit button when `requireTerms` is set: a disabled button says
  something is missing, where one that submits and then fails says the
  app is broken. Hiding the checkbox does not leave the gate shut.
- `PlinthPasswordResetBlock` — the request form and the confirmation
  that replaces it, switched by one `sent` bool. The confirmation is
  part of the block because it is the half that gets skipped, and it is
  worded not to say whether the address has an account, which would
  turn a public form into a way to enumerate who has registered.
- `PlinthTwoFactorBlock` — a pin input whose submit stays disabled
  until the code is the full length, because the button is the
  affordance that says how many digits are expected. `autoSubmit` is
  off by default: firing on a mistyped digit spends an attempt before
  the person has finished reading what they typed.
- `PlinthSplitAuthBlock` — the two-pane brand-and-form layout. The
  decoration pane drops below `breakpoint` rather than squeezing both
  halves onto a phone, and the form pane scrolls rather than clipping,
  which the original 620x300 arrangement did the moment a real sign-in
  card went in it.
- `PlinthErrorPageBlock` — one widget with `.notFound`,
  `.serverError`, `.maintenance` and `.permissionDenied` constructors,
  since those differ only in their words. Every default is
  overridable. The permission wording points at the admin who can
  actually grant access, because "access denied" alone leaves someone
  with nothing to do.
- `PlinthOfflineNotice` — deliberately *not* an error page. A dropped
  connection resolves itself, so this is a banner plus the state of the
  queue that the page keeps working around. Yellow rather than red:
  nothing has failed, work is being held.
- `PlinthBannerBlock` — the four banner shapes as one widget with a
  `notice` / `bar` layout. Ships **no default copy**, unlike the error
  pages: nothing can guess what your announcement says, and placeholder
  text in a banner is worse than a banner that refuses to build.
  Dismissal is carried by `onClose` being null or not, which makes the
  consent-versus-promo decision explicit rather than incidental — a
  prompt somebody can wave away has not obtained consent, and a promo
  that cannot be dismissed is a tax on everyone who has read it.
- `PlinthFaqBlock` — accordion or two-column, optionally searchable,
  with an optional footer. Search matches answers as well as questions,
  because people search for the word they remember and it is usually in
  the answer. A search that matches nothing says so; an empty list with
  no explanation reads as a broken filter.
- `PlinthHeroBlock` — the five hero arrangements as one widget:
  centred or split, optionally over a photograph. The headline is a
  `PlinthTitle`, not large text, because a landing page's claim *is*
  the page's heading and a document whose outline starts further down
  is one a screen reader cannot navigate. A split hero stacks below
  `minSplitWidth` rather than giving both halves a measure too narrow
  to read, and `aside` moves under the words rather than disappearing.
- `PlinthStatStrip` — the numbers under a claim. Each value and label
  is merged into one semantics node, so it is announced as "117
  components" and not as two strings that happen to be adjacent.
- `PlinthFeatureBlock` — grid, checklist and alternating-screenshot
  layouts on one item type. The checklist tick resolves against the
  surface rather than the `Color(0xFF40C057)` the showcase had frozen
  into it, and is hidden from assistive technology: the same mark on
  every row carries nothing, and read aloud it is thirty repetitions of
  the word "check". The alternation is computed, which is the point —
  by hand is where a row ends up on the same side as the one above it.
- `PlinthComparisonBlock` — a plans-by-features matrix. **Asserts that
  every row has one value per plan**, because a short row does not look
  broken: it shifts every answer after it one column left, which is a
  pricing page that lies. `bool` cells render as a tick or a cross with
  a label behind them, since an unlabelled tick is a cell that reads as
  nothing.
- `PlinthLogoStrip` — names under a caption, scrolling by default
  because a strip usually has more than fit. `scroll: false` when they
  do: motion that earns nothing is motion somebody has to sit through.
- `PlinthContactBlock` — the form, plus an `aside` for whatever
  surrounds it: an address, opening hours, other ways through. The
  aside moves under the form rather than squeezing beside it when
  narrow. `sent` swaps the form for an acknowledgement, for the same
  reason the password-reset block does: a form that submits and looks
  unchanged reads as broken, and the result is the same message sent
  four times.
- `PlinthSupportChannels` — ways to reach you as a grid of routes.
  Routing rather than a form, because when several channels exist the
  reader's first decision is which one, and a form presumes that answer
  for them. A channel with no `onTap` renders as a statement rather
  than as something to press.
- `PlinthTopBar` — brand, links, a flexible `center` for a search
  field, and actions. Links wrap rather than clipping: three of them
  plus a brand and a sign-in button do not fit a phone, and a bar that
  clips loses the last one.
- `PlinthSidebar` — the nav rail: sections with headings, sub-levels,
  an optional search box and footer, collapsible to icons.
  **Collapsed, every destination keeps its accessible name.** The
  version this was extracted from passed an empty string as the label
  when collapsed, which left a column of icons a screen reader
  announced as nothing at all — the rail narrowed and the destinations
  stopped existing for anyone not looking at it.
- `PlinthPageHeader` — breadcrumbs, title, a count beside it, actions,
  and a row underneath for tabs or filters. **The title is a
  `PlinthTitle`**: every header this replaced rendered it as
  `PlinthText` at `size: xl, weight: w700`, which looks the same and
  leaves the page's own name out of the outline a screen reader
  navigates by. The count is merged with the title rather than sitting
  in the actions, so "Issues, 128" is read as one fact about the page.
- `PlinthStickyHeader` — a fixed header over a scrolling body. A
  `Column` rather than a sliver arrangement, because the header never
  moves: there is no collapse behaviour to tune, and the body gets a
  bounded height so a plain `ListView` works inside it.
- `PlinthStatTile` and `PlinthStatGrid` — a dashboard figure with a
  label, a value, a movement and room for a bar, ring or breakdown
  under it. **Direction and sentiment are separate**: `trend` says
  which way it went, `higherIsBetter` says whether that is good. The
  version this replaced had one flag, so churn falling 0.4% rendered
  red with a downward arrow — bad news about the best number on the
  board. The movement is also spoken: each tile is one semantics node
  reading "Churn, 1.8%, down 0.4%", because a green arrow is not
  information anyone can hear. The arrow's colour resolves through
  `readableOn` rather than the raw `color(ramp, 6)` the showcase used,
  which sits under the floor for a 14px mark on white.
- `PlinthGoalRings` — separate targets as rings rather than bars,
  because they are not parts of one total and a row of bars implies
  they add up. Each ring and its label are one semantics node.
- `PlinthLeaderboard` — a ranked list whose **bars are measured
  against the leader, not the total**. The question a ranking answers
  is "how far behind is second", and dividing by a sum nobody sees
  renders a page with 40% of traffic and one with 4% as the same stub.
  An empty ranking says so rather than showing a blank card, which
  reads as a broken query.
- `PlinthUserTile` — the shape almost every user-facing row turns out
  to be: an account switcher, a team member, the signed-in user at the
  foot of a sidebar. The row is one semantics node — "Yair Lahav,
  yair@example.com, online" — while a `trailing` control keeps its own
  name and role, because a menu button inside a labelled row is still
  a button.

  **Presence is a word, not only a colour.** `PlinthPresence` carries
  the label with the palette key, so a green dot always arrives with
  "online" attached. A null presence renders no dot at all rather than
  a grey one, which would read as "offline" when it means "unknown".
- `PlinthProfileCard` — centred it is a profile, left-aligned it is a
  contact row, because those differ in alignment and in what fills the
  middle rather than in what they are. Counts reuse `PlinthStatStrip`
  and facts reuse `PlinthDataList`, so neither arrangement reimplements
  a thing this package already had.
- `PlinthMemberList` — a `PlinthUserTile` per person with their role as
  a badge, and the rest of the team collapsed into a `PlinthOverflowList`
  in the header. An empty team says so rather than rendering a blank
  card, which reads as one that failed to load.
- `PlinthPricingCard` — a plan, its price, what it includes and the
  way in. **The price is the card's heading, not the plan name**: it is
  what gets compared across a row of these, and it is how a reader
  tells three identical "Start trial" buttons apart. `price` is a
  string, because `Free` and `Let's talk` are prices too. `highlighted`
  draws a border rather than scaling the card, since a card that grows
  breaks the alignment of the row it sits in.
- `PlinthFooter` — the four footer arrangements: a row of links,
  columns of them, one with a newsletter form, and `dense` for a
  one-line app status bar with no card at all. Everything wraps rather
  than clipping; a footer that clips drops the last link, which is
  usually the one somebody was looking for.
- `PlinthPasswordStrength` — a meter and the checklist behind it.
  Each `PlinthPasswordRule` carries its label *and* its test, which is
  what stops a checklist drifting out of step with what actually
  passes. Three bands rather than a gradient, because the question is
  whether this will be accepted. Every rule stays on screen met or not,
  and each announces "met" or "not met" as a word rather than as a tick
  whose meaning is its shape. The defaults are a starting set, not a
  policy — your server's rules are the ones that decide.
- `PlinthSecretField` — a server-issued value you need back out
  intact. Masked for the screenshot rather than from its owner, and
  read-only by omitting `onChanged`, which is this library's way of
  saying "selectable but not editable" as opposed to `enabled: false`,
  which would take it out of the focus order. A `warning` renders as an
  alert: rotating a live key breaks whatever is using it, and that is
  not a footnote.
- `PlinthAsyncButton` — runs a future, shows it, and **cannot be
  started twice**, which is the bug every hand-rolled version has the
  first time somebody double-clicks Save. One piece of state drives the
  spinner and the disabling so they cannot disagree. `onError` exists
  because the button never holds the result: without it a failure has
  nowhere to go but the zone's handler, a long way from the button
  somebody just pressed. The reset is a cancellable `Timer`, not an
  awaited delay, so nothing is left running after dispose.
- `PlinthConfirmButton` — a destructive action that asks in place
  rather than in a modal, and **announces the question when it
  appears**. Pressing "Delete project" and having the control silently
  become three controls is the failure this avoids: a screen reader
  user would hear nothing and find the button gone.
- `PlinthKanbanBoard` — columns of cards that move between them.
  **Every move is available without a drag.** A drag is a pointer
  gesture, so a board that only accepts one cannot be operated by
  keyboard at all — WCAG 2.1.1, the same class of defect the `F-4` pass
  found by ear on this library's own anchors. Each card is a button
  that opens a menu of the other columns; dragging is the shortcut
  rather than the mechanism. A completed move is announced, because a
  card that silently leaves one column and appears in another has told
  the person watching and nobody else.
- `PlinthArticleCard` — stacked, horizontal or over an image, plus
  the dense list that is the same card without a picture. **The
  headline is a heading**: a feed is a list of documents and a reader
  skims it by heading, so a page of cards whose titles are bold text is
  one undifferentiated run. The image is excluded from semantics — the
  headline beside it already says what the article is.
- `PlinthCommentThread` — comments and their replies, built on
  `PlinthUserTile`. **The indent is only visual, so the nesting is said
  as well as shown**; without that a reply and a top-level comment
  sound identical. Nesting stops at `maxDepth`, because a thread that
  indents forever runs out of page and a reply four levels in answers
  something nobody can still see.
- `PlinthAddressForm` — street, city, postcode and country in a
  `PlinthFieldset`, so a field is announced as "Shipping address, City"
  rather than as a bare "City" — which matters most on the page that
  has a billing address under it. The postcode column is narrower than
  the street, because a field's width is the only hint about its length
  that arrives before you start typing. A country's `postcodeMask` is
  optional: a mask that is wrong rejects real addresses, which is worse
  than no mask at all.

### Notes

These were extracted from the demo app's showcase, where they were
fixed arrangements with `onPressed: () {}` throughout. Becoming a
package meant giving them the things a gallery never needed: values
reported back, disabled states that mean something, and every visible
string as a parameter.
