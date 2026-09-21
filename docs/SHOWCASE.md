# Showcase — composed blocks

The example app's showcase (`example/lib/src/showcase/`) is Plinth's
answer to [Mantine UI](https://ui.mantine.dev): whole *sections* built
from components, not the components themselves. A navbar, a hero, an
article card — the things you assemble a page out of.

Two layers, two documents:

| Layer | Mantine | Plinth | Reference |
|---|---|---|---|
| Core components | mantine.dev | `plinth_components` | [COMPONENTS.md](COMPONENTS.md) |
| Composed blocks | ui.mantine.dev | `example/` showcase | this file |

They're separate concerns. A missing *component* means something can't
be built; a missing *block* just means nobody has assembled that
arrangement yet — usually from components that already exist.

## Where a block lives

Two places, and the split is being closed in one direction.

**`packages/plinth_blocks/`** is where a block ends up: a real widget
with a real API, which an app installs and calls. Twenty-six are there
so far: **the whole Page Sections category** — every one of its 32
arrangements — plus the navbars, headers, footers, most of the stats,
most of the people rows, the two structural inputs, the two
behavioural buttons and the board of Application UI.

| Widget | Replaces |
|---|---|
| `PlinthAuthCard` | the card the auth blocks share |
| `PlinthSignInBlock` | Sign in |
| `PlinthSignUpBlock` | Sign up |
| `PlinthPasswordResetBlock` | Password reset |
| `PlinthTwoFactorBlock` | Two-factor code |
| `PlinthSplitAuthBlock` | Split sign in |
| `PlinthErrorPageBlock` | 404, 500, Maintenance, Permission denied |
| `PlinthOfflineNotice` | Offline |
| `PlinthBannerBlock` | Announcement, Consent, Promo, Update available |
| `PlinthFaqBlock` | FAQ accordion, with contact, two-column, searchable |
| `PlinthHeroBlock` | Centered, split, with image, with signup, with proof |
| `PlinthStatStrip` | the proof strip under a hero, reusable on its own |
| `PlinthFeatureBlock` | Feature grid, feature list, alternating screenshots |
| `PlinthComparisonBlock` | Comparison table |
| `PlinthLogoStrip` | Logo strip |
| `PlinthContactBlock` | Contact form, with details, with hours |
| `PlinthSupportChannels` | Support channels |
| `PlinthTopBar` | Simple navbar, with avatar, with search |
| `PlinthSidebar` | Collapsible, sectioned, with sublevels, with user footer |
| `PlinthPageHeader` | Centered header, with breadcrumbs, with tabs, with filters |
| `PlinthStickyHeader` | Sticky header |
| `PlinthStatTile` | Stat tiles, with progress, breakdown |
| `PlinthStatGrid` | the row those tiles sit in |
| `PlinthGoalRings` | Goal rings |
| `PlinthLeaderboard` | Top pages leaderboard |
| `PlinthUserTile` | User button, Presence status, Account switcher |
| `PlinthProfileCard` | Profile card |
| `PlinthMemberList` | Member list |
| `PlinthPricingCard` | Pricing card |
| `PlinthFooter` | Simple footer, link columns, newsletter, minimal status |
| `PlinthPasswordStrength` | Password strength |
| `PlinthSecretField` | Secret field |
| `PlinthAsyncButton` | Async button |
| `PlinthConfirmButton` | Inline confirm |
| `PlinthKanbanBoard` | Kanban columns |

Four error pages became one widget with four named constructors,
because they differ only in their words. **Offline did not**, and that
is the interesting one: a dropped connection resolves itself, so the
page should keep working around a notice rather than replace itself
with an apology. The showcase had already made that call; collapsing it
into the error page would have thrown the decision away.

**`example/lib/src/showcase/`** is where the other 47 still are — the
rest of Application UI, and Blog UI — as
fixed arrangements built for the gallery — `onPressed: () {}`
throughout, hardcoded copy, no way for a caller to pass anything in.
They demonstrate that an arrangement works; they are not yet something
you can install.

A block moves by gaining the things a gallery never needed: values
reported back, disabled states that mean something, and every visible
string as a parameter rather than English baked in. Its showcase entry
then becomes a *use* of the package block, so the "Show code" panel
shows the call an adopter would write instead of the arrangement's
internals — which is the point of moving it.

## How it's structured

`showcase_data.dart` holds the tree: `CategoryData` → `SubcategoryData`
→ `ExampleEntry`. Each entry pairs a title, a builder, and the source
snippet its "Show code" panel displays. The widgets themselves live in
`examples.dart`, the snippets in `examples_code.dart`.

The snippets are **generated from the blocks themselves** by
`example/tool/generate_example_code.dart`, which parses `examples.dart`
and writes out each block's real source — the widget class, plus its
`State` class where it has one. Run it after changing a block:

```bash
cd example && dart run tool/generate_example_code.dart
```

`example/test/examples_code_fresh_test.dart` fails if you forget, so a
stale panel is a red build rather than something nobody notices.

They used to be hand-written literals, and had drifted three ways by
the time that was fixed: wrapped lines the formatter had since moved, a
`return` kept in half the blocks and stripped in the other half, and
stateful blocks whose panels referred to fields they never showed — so
the text behind the copy button could not compile if you pasted it.

**The component tour's snippets are still hand-maintained**, in
`example/lib/src/demo_code.dart`. Those mirror sections of `main.dart`
rather than whole classes, so the same extraction does not apply to
them yet.

## What exists

110 examples across 3 categories, borrowing Mantine UI's own category
names so the two are directly comparable.

| Category | Subcategory | Examples |
|---|---|---|
| Application UI | Navbars | Simple navbar, Navbar with avatar, Collapsible navbar, Sectioned navbar, Navbar with search, Navbar with sublevels, Navbar with user footer |
| Application UI | Headers | Centered header, Header with breadcrumbs, Header with tabs, Header with filters, Sticky header |
| Application UI | Stats | Stat tiles, Stat with progress, Live metrics, Stat by period, Stat breakdown, Goal rings, Stat with sparkline, Top pages leaderboard |
| Application UI | User Info & Controls | User button, Profile card, User menu, Member list, Presence status, Account switcher, Contact card |
| Application UI | Application Cards | Project card, Task card, Pricing card, Media card, Activity card |
| Application UI | Inputs | Search bar, Filter fields, Formatted fields, Password strength, Verification code, Secret field, Address form |
| Application UI | Buttons | Toolbar actions, Destructive actions, Split button, Async button, Inline confirm |
| Application UI | Sliders | Price range filter, Setting sliders, Slider with marks, Budget slider, Colour controls |
| Application UI | Grids | Dashboard grid, Card gallery, Asymmetric grid, Image gallery |
| Application UI | Tables | Member table, Invoice table, Sortable table |
| Application UI | Dropzones | File dropzone, Avatar upload |
| Application UI | Drag'n'Drop | Reorderable list, Kanban columns |
| Application UI | Carousels | Image carousel, Product shelf |
| Application UI | Footers | Simple footer, Footer with link columns, Footer with newsletter, Minimal status footer |
| Page Sections | Hero Sections | Centered hero, Split hero, Hero with image, Hero with signup, Hero with proof |
| Page Sections | Feature Sections | Feature grid, Feature list, Alternating screenshots, Comparison table, Logo strip |
| Page Sections | Authentication | Sign in, Sign up, Password reset, Two-factor code, Split sign in |
| Page Sections | FAQ | FAQ accordion, FAQ with contact, Two-column FAQ, Searchable FAQ |
| Page Sections | Banners | Announcement, Consent banner, Promo banner, Update available |
| Page Sections | Contact Us | Contact form, Contact with details, Support channels, Contact with hours |
| Page Sections | Error Pages | 404 not found, 500 server error, Maintenance, Permission denied, Offline |
| Blog UI | Article Cards | Simple article card, Article card with author, Horizontal card, Overlay card, Quote card, Article list |
| Blog UI | Comments | Single comment, Comment thread |
| Blog UI | Author Info | Inline author, Author card |
| Blog UI | Table of Contents | Article contents, Contents rail |

## What's missing

Mantine UI has ~123 blocks against these 110. The gap is now depth
rather than absence: **every subcategory has something in it.**

Almost none of it was ever blocked on missing components. The four
subcategories that were empty are done: Dropzones and Drag'n'Drop from
components that had shipped, Table of Contents once
`PlinthTableOfContents` landed in 0.14.0, and Carousels once
`PlinthCarousel` landed in 0.18.0 — the two entries here that were
genuinely waiting on one.

### Application UI

| Subcategory | Mantine UI | Plinth | Notes |
|---|---|---|---|
| Navbars | 9 | 7 | Sublevels and a two-ended navbar with a user footer added |
| Headers | 6 | 5 | Tabs, filters and a sticky variant added |
| Footers | 4 | 4 | Complete — newsletter signup and a one-line app footer added |
| Grids | 3 | 4 | Complete — twelve-column spans and a fixed-ratio gallery added |
| User info and controls | 8 | 7 | Account switching and a person-as-facts contact card added |
| Inputs | 14 | 7 | Live validation, code entry, a read-only secret and a spanned form |
| Buttons | 6 | 5 | Split, async and inline-confirm variants added |
| Sliders | 6 | 5 | Marks, formatted output and colour controls added |
| Application cards | 7 | 5 | Pricing, media and activity variants added |
| Stats | 9 | 8 | A sparkline (drawn with `CustomPaint`) and a ranked leaderboard added |
| Tables | 4 | 3 | Sorting and filtering landed in 0.14.0 |
| Dropzones | 1 | 2 | Done — `PlinthFileInput` and `PlinthFileButton` |
| Drag'n'Drop | 3 | 2 | Built on Flutter's own `Draggable`/`DragTarget` |
| Carousels | 2 | 2 | Complete — `PlinthCarousel` shipped in 0.18.0 |

### Page Sections

| Subcategory | Mantine UI | Plinth | Notes |
|---|---|---|---|
| Hero headers | 6 | 5 | Image-led, signup and social-proof variants added |
| Features section | 5 | 5 | Complete — alternating screenshots, comparison table and logo strip |
| Authentication | 4 | 5 | Complete — reset, two-factor and split-screen added |
| Frequently asked questions | 4 | 4 | Complete — two-column and searchable added |
| Contact us section | 3 | 4 | Complete — channel routing and reply expectations added |
| Error pages | 5 | 5 | Complete — maintenance, permission-denied and offline added |
| Banners | 3 | 4 | Complete — dismissible promo and update-available added |

### Blog UI

| Subcategory | Mantine UI | Plinth | Notes |
|---|---|---|---|
| Article cards | 7 | 6 | Horizontal, overlay, quote and dense-list variants added |
| Table of contents | 2 | 2 | Complete — `PlinthTableOfContents` shipped in 0.14.0 |
| Comments | 2 | 2 | Complete |

### Where to start

Ordered by value against effort, given what already ships:

No subcategory is more than two behind Mantine any more, Inputs aside,
so what's left is the thin end of depth rather than coverage. Worth
adding only where a variant differs in *kind* rather than in styling:

1. **Inputs** — 14 against 7, the one remaining wide number, and the
   softest: most of Mantine's remainder are styling variations on
   arrangements already here (contained fields, floating labels).
2. **Application cards**, **Buttons**, **Sliders**, **Headers**,
   **Hero headers** — each one or two behind. The obvious arrangements
   are taken; a sixth of any of them needs to earn its place.
3. **Tables**, **Dropzones**, **Drag'n'Drop** — already at or near
   parity; only worth extending if a specific arrangement is missing.

**Page Sections is complete** — all seven subcategories meet or exceed
Mantine's count. Fourteen subcategories overall are done. "Done" here
means the arrangements are covered, not that no variant could ever be
added.

Each variant differs in *kind* rather than styling — a navbar that
collapses, one you navigate *into*, three goal rings that deliberately
don't add up, a stat whose shape says what its percentage can't, a
field nobody types into, a card whose pull-quote *is* the card. That's
the bar worth holding new blocks to: a fifth restyled card teaches
nothing.

A block may reach past the library when the arrangement needs it —
the sparkline is a `CustomPaint`, because a line over twelve months
is not a component, it's a drawing. That's a licence for the *demo*,
not a hint that something is missing from `plinth_components`.

**Two gotchas worth knowing before you write one.** `PlinthGroup` wraps
by default, so it is a `Wrap` rather than a `Row`, and `Expanded` or
`Spacer` inside it throws "assertion thrown while applying parent
data" — reach for a plain `Row` when a child needs to flex, or pass
`wrap: false`. And blocks are laid out for a page, so a fixed width
that is 10px too narrow overflows in the smoke test rather than
wrapping; widen the block rather than shrinking its content, which
would misrepresent how much room the arrangement needs.

**Blocks keep their designed width on a phone.** The detail page gives
each preview at least 640 logical pixels and lets it pan sideways
inside its border, so a 560-wide block renders as intended on a 390px
screen rather than being squeezed into a shape nobody designed. That
width is bounded rather than unbounded, which is what keeps `Expanded`
and `Spacer` working inside it. The home page is the responsive part —
its tile grid is `columns: 1, columnsXs: 2, columnsMd: 3`.

**Nothing here is blocked on a missing component any more**, and no
subcategory is empty. Carousels was the last one, left out on the
grounds that Mantine ships its carousel as a separate package —
`PlinthCarousel` in 0.18.0 closed it, since Flutter's `PageView`
already provides what Mantine needed a third-party engine for.

## Adding an example

1. Write the widget in `examples.dart`, as a class named
   `<Something>Example`. The name is the key everything else uses.
2. Register an `ExampleEntry` in `showcase_data.dart` under the right
   subcategory, or add a new `SubcategoryData` if none fits. Each entry
   needs a one-line `WidgetBuilder` adapter beside the others at the
   bottom of that file — a constructor tear-off is
   `({Key? key}) -> Widget`, which is not assignable to `WidgetBuilder`.
3. Regenerate the snippets:

   ```bash
   cd example && dart run tool/generate_example_code.dart
   ```

Step 3 used to be "write the snippet out again by hand", which is why
they drifted. Nothing is transcribed now — the panel shows the class
the app compiles.

`example/test/showcase_smoke_test.dart` builds every block and asserts
none throws, so a new entry is covered the moment it is registered.
`examples_code_fresh_test.dart` covers the rest: that the committed
generated file is current, that every panel's text really appears in
`examples.dart`, and that no snippet is orphaned from a block or the
other way round.

That test widens the viewport to 1400x2000 before pumping. Blocks are
laid out for a page rather than a phone, and several would overflow the
default 800x600. Widening is the right fix rather than wrapping in a
horizontal scroller, which would hand them *unbounded* width and break
every `Row` with an `Expanded` or `Spacer` in it.
