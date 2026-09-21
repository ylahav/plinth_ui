# Mobile list–detail starter

A searchable list that pushes a route on a phone and becomes a two-pane
layout on a tablet. Built on
[Plinth UI](https://github.com/ylahav/plinth_ui).

```bash
cp -r templates/mobile my-app && cd my-app
flutter create .          # adds the platform folders, which are not committed here
flutter run
```

Then open `lib/src/theme.dart` and change one line:

```dart
const brandColor = Color(0xFFE8590C);
```

## What it is showing you

| File | The thing worth copying |
|---|---|
| [lib/src/app.dart](lib/src/app.dart) | One place decides route-or-pane. Neither screen knows which it is in |
| [lib/src/screens/shipment_list.dart](lib/src/screens/shipment_list.dart) | `selected` is a parameter, not state — a phone has no selection to show |
| [lib/src/screens/shipment_detail.dart](lib/src/screens/shipment_detail.dart) | One layout, because the shell absorbed the difference |

## The one that earns its keep

Most list–detail starters pick an arrangement and commit to it. Pick
two panes and a phone shows a cramped one. Pick a route and a tablet
shows a phone layout with 400px of wasted margin — and either way the
back button is wrong on one of them.

Here the shell decides, and it decides by *pushing an actual route* on a
phone:

```dart
Navigator.of(context).push(MaterialPageRoute(builder: ...));
```

not by swapping a widget and drawing a back arrow. That distinction is
the reason Android's back gesture and the system back button work
without this app implementing either. The test asserts it the same way
the OS would — `handlePopRoute()` — rather than by tapping a button
this app drew.

Below the breakpoint the shell passes `selected: null`, so the list
highlights nothing. A phone has no selection to show; the detail is on
top of it.

## Tests

```bash
flutter test
```

Ten. Two of them are the layouts: that a phone push hides the list and
returns on system back, and that a tablet tap leaves the list on screen.
A starter that gets this backwards looks correct in a screenshot of
either one, which is exactly why it is worth a test rather than an eye.

The rest cover searching (announced, not only drawn), the empty state,
and that all four statuses clear 4.5:1 on both surfaces — `delayed` is
amber, about 1.9:1 at shade 6 on white, and it clears because the theme
names a role rather than a colour.
