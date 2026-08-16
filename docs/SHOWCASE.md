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

## How it's structured

`showcase_data.dart` holds the tree: `CategoryData` → `SubcategoryData`
→ `ExampleEntry`. Each entry pairs a title, a builder, and the source
snippet its "Show code" panel displays. The widgets themselves live in
`examples.dart`, the snippets in `examples_code.dart`.

The snippets are **hand-maintained string literals**, not extracted at
build time — edit the snippet alongside the example it mirrors, or the
code panel will quietly show something the demo no longer does.

## What exists

108 examples across 3 categories, borrowing Mantine UI's own category
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

Mantine UI has ~123 blocks against these 108. The gap is now depth
rather than absence: **every subcategory has something in it except
Carousels**, which is a deliberate scope call rather than a hole.

The point still holds — almost none of it was ever blocked on missing
components. The three subcategories that were empty are done: Dropzones
and Drag'n'Drop from components that had shipped, and Table of Contents
once `PlinthTableOfContents` landed in 0.14.0, which was the only entry
here genuinely waiting on one.

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
| Carousels | 2 | **0** | Mantine's is a separate package; same call applies here |

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

No subcategory is more than two behind Mantine any more, Inputs and
Carousels aside, so what's left is the thin end of depth rather than
coverage. Worth adding only where a variant differs in *kind* rather
than in styling:

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

**Nothing here is blocked on a missing component any more.** Carousels
is the one subcategory still empty, and deliberately: Mantine ships its
carousel as a separate package, and the same call applies here.

## Adding an example

1. Write the widget in `examples.dart`.
2. Add its source snippet to `examples_code.dart`, keyed by class name.
3. Register an `ExampleEntry` in `showcase_data.dart` under the right
   subcategory, or add a new `SubcategoryData` if none fits.

`example/test/showcase_smoke_test.dart` builds every block and asserts
none throws, so a new entry is covered the moment it is registered. It
also checks each block has a non-empty code snippet — easy to forget,
and a missing one renders an empty panel rather than failing.

That test widens the viewport to 1400x2000 before pumping. Blocks are
laid out for a page rather than a phone, and several would overflow the
default 800x600. Widening is the right fix rather than wrapping in a
horizontal scroller, which would hand them *unbounded* width and break
every `Row` with an `Expanded` or `Spacer` in it.
