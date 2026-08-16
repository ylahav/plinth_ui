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

88 examples across 3 categories, borrowing Mantine UI's own category
names so the two are directly comparable.

| Category | Subcategory | Examples |
|---|---|---|
| Application UI | Navbars | Simple navbar, Navbar with avatar, Collapsible navbar, Sectioned navbar, Navbar with search |
| Application UI | Headers | Centered header, Header with breadcrumbs, Header with tabs, Header with filters, Sticky header |
| Application UI | Stats | Stat tiles, Stat with progress, Live metrics, Stat by period, Stat breakdown, Goal rings |
| Application UI | User Info & Controls | User button, Profile card, User menu, Member list, Presence status |
| Application UI | Application Cards | Project card, Task card, Pricing card, Media card, Activity card |
| Application UI | Inputs | Search bar, Filter fields, Formatted fields |
| Application UI | Buttons | Toolbar actions, Destructive actions, Split button, Async button, Inline confirm |
| Application UI | Sliders | Price range filter, Setting sliders, Slider with marks, Budget slider, Colour controls |
| Application UI | Grids | Dashboard grid, Card gallery |
| Application UI | Tables | Member table, Invoice table, Sortable table |
| Application UI | Dropzones | File dropzone, Avatar upload |
| Application UI | Drag'n'Drop | Reorderable list, Kanban columns |
| Application UI | Footers | Simple footer, Footer with link columns |
| Page Sections | Hero Sections | Centered hero, Split hero, Hero with image, Hero with signup, Hero with proof |
| Page Sections | Feature Sections | Feature grid, Feature list, Alternating screenshots, Comparison table, Logo strip |
| Page Sections | Authentication | Sign in, Sign up, Password reset, Two-factor code, Split sign in |
| Page Sections | FAQ | FAQ accordion, FAQ with contact |
| Page Sections | Banners | Announcement, Consent banner |
| Page Sections | Contact Us | Contact form, Contact with details |
| Page Sections | Error Pages | 404 not found, 500 server error, Maintenance, Permission denied, Offline |
| Blog UI | Article Cards | Simple article card, Article card with author, Horizontal card, Overlay card, Quote card, Article list |
| Blog UI | Comments | Single comment, Comment thread |
| Blog UI | Author Info | Inline author, Author card |
| Blog UI | Table of Contents | Article contents, Contents rail |

## What's missing

Mantine UI has ~123 blocks against these 88. The gap is now depth
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
| Navbars | 9 | 5 | Collapsible, sectioned and search variants added |
| Headers | 6 | 5 | Tabs, filters and a sticky variant added |
| Footers | 4 | 2 | |
| Grids | 3 | 2 | |
| User info and controls | 8 | 5 | Menu, member list and presence variants added |
| Inputs | 14 | 3 | Composed field arrangements, not new inputs |
| Buttons | 6 | 5 | Split, async and inline-confirm variants added |
| Sliders | 6 | 5 | Marks, formatted output and colour controls added |
| Application cards | 7 | 5 | Pricing, media and activity variants added |
| Stats | 9 | 6 | Period switcher, part-to-whole breakdown and goal rings added |
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
| Frequently asked questions | 4 | 2 | |
| Contact us section | 3 | 2 | |
| Error pages | 5 | 5 | Complete — maintenance, permission-denied and offline added |
| Banners | 3 | 2 | |

### Blog UI

| Subcategory | Mantine UI | Plinth | Notes |
|---|---|---|---|
| Article cards | 7 | 6 | Horizontal, overlay, quote and dense-list variants added |
| Table of contents | 2 | 2 | Complete — `PlinthTableOfContents` shipped in 0.14.0 |
| Comments | 2 | 2 | Complete |

### Where to start

Ordered by value against effort, given what already ships:

Every subcategory except Carousels now has at least two examples, so
what remains is depth rather than coverage — Mantine offers 6–9
variants where this has 2 or 3. Worth adding where a variant differs
in *kind* rather than in styling:

1. **FAQ**, **Contact us** and **Banners** — 4, 3 and 3 against 2. The
   last of the Page Sections gaps, and all small.
2. **Footers** and **Grids** — 4 and 3 against 2.
3. **Inputs** — 14 against 3 on paper, the widest number, but the
   softest target: most of Mantine's are styling variations rather
   than different arrangements, so counting them overstates the gap.
4. **Tables**, **Dropzones**, **Drag'n'Drop** — already at or near
   parity; only worth extending if a specific arrangement is missing.

**Nine subcategories are done** — Heroes, Features, Authentication,
Error pages, Article cards, Buttons, Sliders, Comments and Table of
contents each meet or nearly meet Mantine's count. "Done" here means
the arrangements are covered, not that no variant could ever be added.

Every subcategory except Carousels now has at least five examples in
the areas people actually copy from. Each new variant differs in *kind*
rather than styling — a navbar that collapses, a card whose body is a
sequence, three goal rings that deliberately don't add up, a card whose
pull-quote *is* the card. That's the bar worth holding new blocks to: a
fifth restyled card teaches nothing.

**Two gotchas worth knowing before you write one.** `PlinthGroup` wraps
by default, so it is a `Wrap` rather than a `Row`, and `Expanded` or
`Spacer` inside it throws "assertion thrown while applying parent
data" — reach for a plain `Row` when a child needs to flex, or pass
`wrap: false`. And blocks are laid out for a page, so a fixed width
that is 10px too narrow overflows in the smoke test rather than
wrapping; widen the block rather than shrinking its content, which
would misrepresent how much room the arrangement needs.

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
