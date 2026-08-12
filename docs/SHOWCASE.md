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

12 examples across 3 categories, borrowing Mantine UI's own category
names so the two are directly comparable.

| Category | Subcategory | Examples |
|---|---|---|
| Application UI | Navbars | Simple navbar, Navbar with avatar |
| Application UI | Headers | Centered header, Header with breadcrumbs |
| Page Sections | Hero Sections | Centered hero, Split hero |
| Page Sections | Feature Sections | Feature grid, Feature list |
| Blog UI | Article Cards | Simple article card, Article card with author |
| Blog UI | Author Info | Inline author, Author card |

## What's missing

Mantine UI has ~123 blocks against these 12. The gap is mostly whole
subcategories with nothing in them, and — this is the point — **almost
none of it is blocked on missing components.** An auth form is
`PlinthTextInput` + `PlinthPasswordInput` + `PlinthButton` +
`PlinthCard`, all of which ship today.

### Application UI

| Subcategory | Mantine UI | Plinth | Notes |
|---|---|---|---|
| Navbars | 9 | 2 | Collapsible and sectioned variants are the obvious next ones, now that `PlinthAppShell` exists |
| Headers | 6 | 2 | |
| Footers | 4 | **0** | Nothing blocking — `PlinthGroup` + `PlinthAnchor` |
| Grids | 3 | **0** | `PlinthGrid` landed in 0.5.0, so these are now buildable |
| User info and controls | 8 | **0** | `PlinthAvatar` + `PlinthMenu` cover it |
| Inputs | 14 | **0** | Composed field arrangements, not new inputs |
| Buttons | 6 | **0** | |
| Sliders | 6 | **0** | |
| Application cards | 7 | **0** | `PlinthCard` + `PlinthGroup` |
| Stats | 9 | **0** | Stat tiles with a label, value, and trend — high value, nothing blocking |
| Tables | 4 | **0** | `PlinthTable` takes plain strings only, so richer cells would need it extended first |
| Dropzones | 1 | **0** | Needs `PlinthFileInput`, which doesn't exist yet |
| Drag'n'Drop | 3 | **0** | Flutter's own `Draggable`/`DragTarget` |
| Carousels | 2 | **0** | Mantine's is a separate package; same call applies here |

### Page Sections

| Subcategory | Mantine UI | Plinth | Notes |
|---|---|---|---|
| Hero headers | 6 | 2 | |
| Features section | 5 | 2 | |
| Authentication | 4 | **0** | Sign-in and sign-up forms. Highest value here — every app needs one and every part exists |
| Frequently asked questions | 4 | **0** | `PlinthAccordion` already does the work |
| Contact us section | 3 | **0** | |
| Error pages | 5 | **0** | 404 and 500 layouts. Cheap and widely reused |
| Banners | 3 | **0** | |

### Blog UI

| Subcategory | Mantine UI | Plinth | Notes |
|---|---|---|---|
| Article cards | 7 | 2 | |
| Table of contents | 2 | **0** | Would pair with a `PlinthTableOfContents` component, which also doesn't exist |
| Comments | 2 | **0** | `PlinthAvatar` + `PlinthPaper` |

### Where to start

Ordered by value against effort, given what already ships:

1. **Authentication** — sign-in, sign-up, password reset. Every app
   needs them, and every component exists.
2. **Stats** — label/value/trend tiles. Small, reusable, and the most
   copied kind of block in practice.
3. **Error pages** — 404 and 500. Nearly free to build.
4. **Footers** — the counterpart to the navbars already here.
5. **FAQ** — `PlinthAccordion` with content wrapped around it.

Three are blocked on component work rather than composition:
**Dropzones** needs `PlinthFileInput`, **Tables** needs `PlinthTable` to
accept widget cells rather than strings, and **Table of contents** wants
a `PlinthTableOfContents`. See
[COMPONENTS.md § Coming soon](COMPONENTS.md#coming-soon).

## Adding an example

1. Write the widget in `examples.dart`.
2. Add its source snippet to `examples_code.dart`, keyed by class name.
3. Register an `ExampleEntry` in `showcase_data.dart` under the right
   subcategory, or add a new `SubcategoryData` if none fits.

The gallery's smoke test doesn't cover these — it walks the Widgetbook
tree, which is components only. `example/test/` is where a showcase
test would go.
