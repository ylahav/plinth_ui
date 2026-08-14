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

57 examples across 3 categories, borrowing Mantine UI's own category
names so the two are directly comparable.

| Category | Subcategory | Examples |
|---|---|---|
| Application UI | Navbars | Simple navbar, Navbar with avatar, Collapsible navbar, Sectioned navbar, Navbar with search |
| Application UI | Headers | Centered header, Header with breadcrumbs, Header with tabs, Header with filters, Sticky header |
| Application UI | Stats | Stat tiles, Stat with progress, Live metrics |
| Application UI | Inputs | Search bar, Filter fields, Formatted fields |
| Application UI | Buttons | Toolbar actions, Destructive actions |
| Application UI | Sliders | Price range filter, Setting sliders |
| Application UI | Grids | Dashboard grid, Card gallery |
| Application UI | Tables | Member table, Invoice table, Sortable table |
| Application UI | Dropzones | File dropzone, Avatar upload |
| Application UI | Drag'n'Drop | Reorderable list, Kanban columns |
| Application UI | User Info & Controls | User button, Profile card |
| Application UI | Application Cards | Project card, Task card |
| Application UI | Footers | Simple footer, Footer with link columns |
| Page Sections | Hero Sections | Centered hero, Split hero |
| Page Sections | Feature Sections | Feature grid, Feature list |
| Page Sections | Authentication | Sign in, Sign up |
| Page Sections | FAQ | FAQ accordion, FAQ with contact |
| Page Sections | Banners | Announcement, Consent banner |
| Page Sections | Contact Us | Contact form, Contact with details |
| Page Sections | Error Pages | 404 not found, 500 server error |
| Blog UI | Article Cards | Simple article card, Article card with author |
| Blog UI | Comments | Single comment, Comment thread |
| Blog UI | Author Info | Inline author, Author card |
| Blog UI | Table of Contents | Article contents, Contents rail |

## What's missing

Mantine UI has ~123 blocks against these 57. The gap is now depth
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
| User info and controls | 8 | 2 | |
| Inputs | 14 | 3 | Composed field arrangements, not new inputs |
| Buttons | 6 | 2 | |
| Sliders | 6 | 2 | |
| Application cards | 7 | 2 | |
| Stats | 9 | 3 | |
| Tables | 4 | 3 | Sorting and filtering landed in 0.14.0 |
| Dropzones | 1 | 2 | Done — `PlinthFileInput` and `PlinthFileButton` |
| Drag'n'Drop | 3 | 2 | Built on Flutter's own `Draggable`/`DragTarget` |
| Carousels | 2 | **0** | Mantine's is a separate package; same call applies here |

### Page Sections

| Subcategory | Mantine UI | Plinth | Notes |
|---|---|---|---|
| Hero headers | 6 | 2 | |
| Features section | 5 | 2 | |
| Authentication | 4 | 2 | Sign-in and sign-up; password reset and a split-screen variant are the obvious next ones |
| Frequently asked questions | 4 | 2 | |
| Contact us section | 3 | 2 | |
| Error pages | 5 | 2 | 404 and 500; maintenance and permission-denied remain |
| Banners | 3 | 2 | |

### Blog UI

| Subcategory | Mantine UI | Plinth | Notes |
|---|---|---|---|
| Article cards | 7 | 2 | |
| Table of contents | 2 | 2 | Complete — `PlinthTableOfContents` shipped in 0.14.0 |
| Comments | 2 | 2 | Complete |

### Where to start

Ordered by value against effort, given what already ships:

Every subcategory except Carousels now has at least two examples, so
what remains is depth rather than coverage — Mantine offers 6–9
variants where this has 2 or 3. Worth adding where a variant differs
in *kind* rather than in styling:

1. **User info and controls** — 8 against 2, now the widest gap in
   Application UI.
2. **Application cards** and **Stats** — the kinds most often copied
   into real apps, so more variants pay off fastest (7 and 9 against
   2 and 3).
3. **Authentication** and **Error pages** — password reset, a
   split-screen sign-in, maintenance and permission-denied.
4. **Inputs** — 14 against 3, though many of Mantine's are variations
   in styling rather than arrangement, so the real gap is smaller than
   the number suggests.

Navbars and Headers were the thinnest and are now at 5 each. The three
navbar variants differ in *kind* rather than styling — one collapses,
one groups under headings, one carries a search control — which is the
bar worth holding new blocks to.

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
