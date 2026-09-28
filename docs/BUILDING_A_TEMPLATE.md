# Anatomy of a template

*What a Plinth starter is made of — read it to add a fifth, or to
understand the one you just copied. The four in [`templates/`](../templates)
are the specification; everything below is derived from them, and
`templates_shape_test.dart` fails if they drift apart.*

This is not [the tutorial](TUTORIAL_LARDER_APP.md). That builds an app
from nothing to teach you the library. This describes the *shape* the
four starters share, because that shape is a contract and nothing else
writes it down.

**A template has two halves, and they matter equally.** What it is
assembled from — blocks, then components, then charts — and how it is
themed. Get the first right and a screen is fifty lines instead of five
hundred; get the second right and it survives a rebrand. A starter that
hand-rolls its widgets demonstrates nothing, and a beautifully composed
one with a hardcoded palette breaks the moment somebody changes the
brand.

---

## What a template is

A real Flutter app, in this repository, that compiles and is tested in
CI alongside the packages. Not a screenshot and not a snippet.

It is **not** a framework. There is no `plinth_template` package, no base
class, nothing to keep in sync. You copy the directory and it becomes
yours, including the parts you delete.

```bash
cp -r templates/dashboard my-app && cd my-app
flutter create .
flutter run
```

`flutter create .` writes the platform folders, which are not committed —
see [`.gitignore`](#the-seven-files-every-template-has) below.

## What a template is assembled from

**Blocks first.** `plinth_blocks` is where a whole arrangement lives — a
sign-in form, a sidebar, a stat grid, a page header with its heading
level already right. Reach for one before writing a `Column`. None of the
four starters builds a page header, a top bar or a sign-in form by hand,
and none should:

| Template | Blocks it leans on |
|---|---|
| `account` | `PlinthSignInBlock`, `PlinthSplitAuthBlock`, `PlinthPasswordStrength`, `PlinthProfileCard`, `PlinthConfirmButton`, `PlinthPageHeader`, `PlinthTopBar`, `PlinthTopBarBrand`, `PlinthUserTile` |
| `blog` | `PlinthArticleCard`, `PlinthCommentThread`, `PlinthCommentData`, `PlinthFooter`, `PlinthPageHeader`, `PlinthTopBar`, `PlinthTopBarBrand`, `PlinthUserTile` |
| `dashboard` | `PlinthSidebar`, `PlinthNavSection`, `PlinthNavItem`, `PlinthStatGrid`, `PlinthStatTile`, `PlinthAsyncButton`, `PlinthPageHeader`, `PlinthTopBar`, `PlinthTopBarBrand` |
| `mobile` | `PlinthStatGrid`, `PlinthStatTile`, `PlinthAsyncButton`, `PlinthUserTile` |

`templates_shape_test.dart` holds that table in **both** directions:
every block named is really used by the template it sits under, and every
block a template uses is named. So it is a list rather than a sample, and
adding a block to a starter without adding it here fails the build.

**The recurring spine** is `PlinthPageHeader`, `PlinthTopBar` +
`PlinthTopBarBrand`, and `PlinthUserTile` — three of the four use each.
If you are starting a fifth, start there. `PlinthPage` (0.4.0) now wraps
the header in the whole screen shell, which is the newer way to do what
these templates do by hand, and is what a new starter should reach for.

**Then components.** Seven to twelve per template — `PlinthTable`,
`PlinthSelect`, `PlinthBadge`, `PlinthTextInput`, `PlinthEmptyState`,
`PlinthLiveRegion`. See [COMPONENTS.md](COMPONENTS.md).

**Then charts, only if it charts.** `dashboard` takes four
(`PlinthLineChart`, `PlinthDonutChart` and their data types), `mobile`
one (`PlinthSparkline`), and the other two do not take the dependency at
all.

The proportion is the point: **a template is mostly assembly.** `mobile`
is the leanest at four blocks and nine components, and it is still a
searchable master–detail app that works on a phone and a tablet.

## The seven files every template has

Eleven to thirteen files are tracked per template. Seven of them are
fixed:

| File | What it is |
|---|---|
| `pubspec.yaml` | `publish_to: none`, path dependencies, `flutter_lints` |
| `analysis_options.yaml` | `package:flutter_lints/flutter.yaml`, with the platform folders excluded |
| `.gitignore` | Also excludes `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`, `pubspec.lock` and `pubspec_overrides.yaml` |
| `README.md` | ~65 lines: what it starts you with, how to run it, what to change first |
| `lib/main.dart` | Six lines. Builds the themes and hands them to the app |
| `lib/src/theme.dart` | **The only file that names a colour.** See below |
| `test/<name>_test.dart` | One file. Holds the contract |

The rest varies with the app:

- **a shell** — `lib/src/app.dart`, or `app_shell.dart` where there is
  real navigation chrome
- **a data or state file** — `data.dart`, `content.dart`, `session.dart`.
  Free of Flutter imports, which is why roles and series cross that
  boundary as *strings* rather than as `Color`s
- **`lib/src/screens/*.dart`** — two to four

Nothing else. No `widgets/` folder, no `utils.dart`, no barrel file. Four
apps have not needed them, and a starter with scaffolding you have to
understand before you can delete it is worse than one without.

### `pubspec.yaml`

```yaml
name: plinth_template_dashboard        # plinth_template_<dir>
description: >-
  Admin dashboard starter for Plinth UI — sidebar shell, overview with
  charts, a sortable orders table, and a settings form. Copy the
  directory, run `flutter create .`, and change the brand colour in
  lib/src/theme.dart.
publish_to: none                       # a starter is copied, not depended on
version: 0.1.0

environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter
  plinth_blocks:
    path: ../../packages/plinth_blocks
  plinth_charts:                       # only if it draws a chart
    path: ../../packages/plinth_charts

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

**`plinth_blocks` only.** It re-exports `plinth_components`, which
re-exports `plinth_core`, so one dependency reaches all three and a
template never lists `plinth_components` directly. `plinth_charts` is
separate because it versions separately.

**Path dependencies, not hosted.** A template tests against the packages
*in this repository*, so an API change breaks it in the same commit
rather than at the next release. Someone who copies the directory changes
these two lines to hosted versions — and the template's README says so.

## `theme.dart` — the other half

Composition gets you the screen. This is what keeps it legible when the
brand changes — every template puts its whole identity in one file.

```dart
/// The one colour to change.
const brandColor = Color(0xFF3B5BDB);

/// Order states as roles, not colours.
const orderRoles = <String, PlinthSemanticColor>{
  'paid': PlinthSemanticColor('green'),
  'shipped': PlinthSemanticColor('yellow'),
  'refunded': PlinthSemanticColor('red'),
};

PlinthTheme _brand(PlinthTheme base) => base.copyWith(
      primaryColor: 'brand',
      colors: {...base.colors, 'brand': PlinthTheme.generateShades(brandColor)},
      semanticColors: orderRoles,
      seriesKeys: channelSeries,
    );

final dashboardLight = _brand(PlinthTheme.defaultTheme);
final dashboardDark = _brand(PlinthTheme.darkTheme);
```

Three things to copy exactly:

1. **One `brandColor`, and no hue below this file.** Nothing in
   `screens/` asks for a colour, so nothing in `screens/` is revisited
   when the brand changes. This is the claim the starters exist to
   demonstrate, and it only holds if you keep it.
2. **Domain values become roles, not colours.** `'shipped'` is the one
   that earns the indirection: amber shade 6 is about 1.9:1 on white.
   Declared as a role, `semanticText('shipped')` walks the ramp until it
   clears 4.5:1, and no screen knows that happened. A status mapped
   straight to a `Color` is a label somebody cannot read.
3. **Series keyed by name.** Charts read `theme.seriesFor('web')`, which
   is what lets `data.dart` stay free of any Flutter import — a string
   crosses that boundary, a `Color` cannot.

`ThemeData` is *not* generated from the Plinth theme. The two are kept in
agreement about the fields Plinth owns, and the test asserts it:

```dart
ThemeData dashboardThemeData(PlinthTheme plinth) => ThemeData(
      useMaterial3: true,
      brightness: plinth.brightness,
      colorScheme: plinth.toColorScheme(),
      scaffoldBackgroundColor: plinth.surfaceSunken,
      extensions: [plinth],
    );
```

## The theme contract its test holds

Easy to leave out, expensive to leave out. All four templates end with
**the same three plain `test()` assertions**, worded for their own
domain:

```dart
test('the brand colour is the one the theme paints', () {
  // generateShades anchors shade 6 to the given colour exactly. If that
  // stopped being true, every screen would paint a near-miss of the
  // brand and nothing would say so.
  expect(dashboardLight.colors['brand']![6], brandColor);
});

test('every order status is a declared role', () {
  // A status with no role resolves to the primary ramp and looks
  // deliberate. This catches a status added to data.dart and not to
  // theme.dart.
  for (final status in {'paid', 'shipped', 'refunded'}) {
    expect(orderRoles, contains(status));
  }
});

test('roles clear the contrast floor on both surfaces', () {
  for (final theme in [dashboardLight, dashboardDark]) {
    for (final role in orderRoles.keys) {
      final ratio =
          PlinthTheme.contrastRatio(theme.semanticText(role), theme.surface);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: '$role is ${ratio.toStringAsFixed(2)}:1 on this surface');
    }
  }
});
```

Together they are the rebrand-survival claim, checkable: **the brand is
exactly what you asked for, every domain value has a role, and every role
is readable in both themes.** Change `brandColor` to something pale and
the third test tells you before a user does.

Alongside them, widget tests covering four things:

| Assertion | Why it is there | Example |
|---|---|---|
| **Every screen builds** | A starter that throws on one tab is found by whoever tries to start with it | `every section builds`, `every post opens without throwing` |
| **Navigation round-trips** | Forward *and* back, because back is the one that gets broken | `opening a post shows it, and back returns` |
| **The layout changes at its breakpoint** | Only where it has one — the account starter is a centred form and has none | `the sidebar gives way to a drawer on a phone`, `on a tablet both panes are on screen` |
| **A state change is announced** | Filtering a list silently is the defect a semantics tree will not show you | `filtering the orders table narrows it, out loud`, `replies are announced as replies` |

And one that reads as cosmetic and is not: **`a status is a word, not only
a colour`** — the status text is findable, so a colour-blind reader is not
guessing at a hue.

## Registering it

`melos.yaml` already globs `templates/*`:

```yaml
  # Starter apps. They are here so `analyze`, `format` and `test` cover
  # them: a template that no longer compiles against the current API is
  # worse than no template, because it is found by the person trying to
  # start with it.
  - templates/*
```

So a new directory is picked up with no registration. Then:

1. `melos bootstrap`
2. Add a row to [`templates/README.md`](../templates/README.md)
3. Update the template count and test total in the claims gate at the end
   of [ROADMAP.md](ROADMAP.md) — and **derive** them, do not edit the
   number in place. That section says how.
4. `melos run format`, `analyze`, `test`

## Copying one

What to change, in order:

1. **`pubspec.yaml`** — `name`, `description`, and the path dependencies
   become hosted (`plinth_blocks: ^0.4.0`)
2. **`flutter create .`** — writes the platform folders
3. **`lib/src/theme.dart`** — your `brandColor`, your roles, your series
   keys. Everything re-skins from here
4. **Keep the test file.** It is yours now, and its three theme
   assertions are what tell you a brand change broke legibility. Rename
   the domain values; do not delete the checks
5. **Delete the screens you do not want**, then the data they used

### When you outgrow it

The starters stop at one shell, a handful of screens and in-memory data —
deliberately, because a starter carrying a router, a state-management
choice and a network layer has made three decisions for you that you were
going to make differently. Those are the three things to add first, and
none of them touch `theme.dart`.

## What keeps this honest

`templates_shape_test.dart` asserts, for every directory in
`templates/`:

- the seven fixed files exist, and there is exactly one test file named
  after the directory
- `publish_to: none`, and a `plinth_blocks` dependency with no direct
  `plinth_components` one
- it uses at least one block — a starter that composes nothing
  demonstrates nothing
- the block table above is right in both directions
- the test file holds all three theme assertions

Sixty-one checks, each with a negative control run against it, because a
structural check that cannot fail is worse than none.

It does **not** check prose. If you change the shape and not this
document, the test tells you about the files and nobody tells you about
the paragraphs — so change both.
