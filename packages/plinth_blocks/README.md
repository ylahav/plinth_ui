# plinth_blocks

**Composed sections for [Plinth UI](https://github.com/ylahav/plinth_ui)** —
a sign-in card, a navbar, a stat tile. The things a page is assembled
from, rather than the components they are made of.

Blocks are real widgets with real APIs, not snippets to paste. Dart
tree-shakes the ones your app never references, so a block you do not
use costs your binary nothing — which is why this is a package and not
a copy-in registry.

```bash
flutter pub add plinth_blocks
```

It re-exports `plinth_components`, so one import covers both:

```dart
import 'package:plinth_blocks/plinth_blocks.dart';
```

## Register the theme first

Every block resolves its colours, spacing and radii from a
`PlinthTheme`, exactly as the components do. Skip this and there are no
tokens to read:

```dart
MaterialApp(
  theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
  darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
)
```

## What's here

Every Page Sections arrangement, plus the navigation and page chrome:

| Block | What it is |
|---|---|
| `PlinthSignInBlock` | Email, password, remember-me, alternatives under a divider |
| `PlinthSignUpBlock` | Name, email, password, terms — the terms gate the submit |
| `PlinthPasswordResetBlock` | Request a link, and the confirmation that replaces it |
| `PlinthTwoFactorBlock` | A code input whose submit waits until the code is complete |
| `PlinthSplitAuthBlock` | Brand on one side, form on the other — one side on a phone |
| `PlinthAuthCard` | The card the others are built in, for the screens they don't cover |
| `PlinthErrorPageBlock` | `.notFound`, `.serverError`, `.maintenance`, `.permissionDenied` |
| `PlinthOfflineNotice` | A banner the page keeps working around, not a page that replaces it |
| `PlinthBannerBlock` | A page-level message, as a notice or a one-line bar |
| `PlinthFaqBlock` | Questions as an accordion or two columns, optionally searchable |
| `PlinthHeroBlock` | A claim, a sentence and something to do — centred, split, or over a photograph |
| `PlinthStatStrip` | Numbers under a claim, each pair announced as one thing |
| `PlinthFeatureBlock` | Features as a grid, a checklist, or alternating rows |
| `PlinthComparisonBlock` | A plans-by-features matrix that refuses a short row |
| `PlinthLogoStrip` | Customer names, scrolling only when they don't fit |
| `PlinthContactBlock` | A form, with room beside it for hours or an address |
| `PlinthSupportChannels` | Ways to reach you, as routes rather than a form |
| `PlinthTopBar` | Brand, links, a flexible middle, actions |
| `PlinthSidebar` | A nav rail: sections, sub-levels, collapsible to icons |
| `PlinthPageHeader` | Breadcrumbs, a real heading, actions, and a row beneath |
| `PlinthStickyHeader` | A header that stays while the body under it scrolls |
| `PlinthStatTile` | A dashboard figure that knows up from good |
| `PlinthStatGrid` | Those tiles in a row that becomes a column |
| `PlinthGoalRings` | Separate targets as rings, because they do not add up |
| `PlinthLeaderboard` | A ranking whose bars are measured against the leader |

```dart
PlinthSignInBlock(
  onSubmit: (values) => auth.signIn(values.email, values.password),
  onForgotPassword: () => router.go('/reset'),
  alternatives: [
    PlinthButton(
      variant: PlinthVariant.defaultVariant,
      fullWidth: true,
      onPressed: auth.google,
      child: const Text('Continue with Google'),
    ),
  ],
)
```

More are moving here from the demo app's showcase, which has 110 of
them — see
[SHOWCASE.md](https://github.com/ylahav/plinth_ui/blob/main/docs/SHOWCASE.md).

## Two things worth knowing

**Blocks hold their own field state.** `PlinthSignInBlock` tracks what
was typed and hands it back on submit, because making every caller wire
three controllers before they can see a form is most of the work the
block exists to remove. An app that already has form state can build
the same card from `PlinthAuthCard` and keep its own.

**Every visible string is a parameter.** The defaults are English
because something has to render before you have translated anything —
not because this assumes an English app. There is no localisation here
and no `intl` dependency; pass your own strings.

## Accessibility

The same contract as the rest of Plinth. Colour resolves against a WCAG
contrast floor at lookup time, so a block re-themed to your brand stays
legible rather than becoming your problem. A sign-in failure renders as
an alert rather than as an error on the password field, because it is
the attempt that failed and not the field — attaching it there tells a
screen reader the password is malformed when it is not.

## License

MIT
