# Blog starter

An article list, an article with a table of contents that follows the
scroll, and a comment thread. Built on
[Plinth UI](https://github.com/ylahav/plinth_ui).

```bash
cp -r templates/blog my-app && cd my-app
flutter create .          # adds the platform folders, which are not committed here
flutter run
```

Then open `lib/src/theme.dart` and change one line:

```dart
const brandColor = Color(0xFF0B7285);
```

## What it is showing you

| File | The thing worth copying |
|---|---|
| [lib/src/content.dart](lib/src/content.dart) | A post's headings *are* its table of contents. There is no second list |
| [lib/src/screens/post_detail.dart](lib/src/screens/post_detail.dart) | The caller decides which heading is active, and why that is the right split |
| [lib/src/app.dart](lib/src/app.dart) | Swapping the body announces itself — nothing else would |

## The one that earns its keep

A table of contents is usually written twice: once as the headings, once
as the list of links. Rename a heading and the contents point at
something that no longer exists — silently, because nothing checks.

Here the headings *are* the list:

```dart
items: [
  for (var i = 0; i < post.sections.length; i++)
    PlinthTocItem(
      label: post.sections[i].heading,
      order: post.sections[i].order,
      targetKey: _keys[i],
    ),
]
```

One source, so they cannot disagree. The test asserts each heading
appears exactly twice — once in the article, once in the contents — and
would catch a refactor that broke the derivation.

`PlinthTableOfContents` takes `activeIndex` rather than working it out
itself, which looks like work pushed onto the caller and is not. "On
screen" means something different under a sticky header than in a plain
scroll view, and a widget that guessed would be confidently wrong in one
of them. `post_detail.dart` has the twelve lines that decide it here.

## Tests

```bash
flutter test
```

Nine. Two are worth calling out. One asserts the contents sit *above*
the article at phone width — contents you have to scroll past the
article to reach are not contents. The other asserts the comment thread
says "reply" out loud, because nesting is indentation and indentation is
not audible.

Both a layout bug and a test bug turned up writing them: the top bar
overflowed at 420px, and the loop that opened every post was reusing the
previous article's state. Which is the argument for templates being in
CI at all.
