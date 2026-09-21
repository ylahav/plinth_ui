# Dashboard starter

An admin dashboard on [Plinth UI](https://github.com/ylahav/plinth_ui):
a sidebar shell, an overview with charts, a filterable orders table, and
a settings form.

```bash
cp -r templates/dashboard my-app && cd my-app
flutter create .          # adds the platform folders, which are not committed here
flutter run
```

Then open `lib/src/theme.dart` and change one line:

```dart
const brandColor = Color(0xFF3B5BDB);
```

Everything re-skins — buttons, chart series, the sidebar's active row,
the status badges. **Nothing else in the app names a colour**, so there
is nothing else to revisit.

## What it is showing you

| File | The thing worth copying |
|---|---|
| [lib/src/theme.dart](lib/src/theme.dart) | One brand colour, three states as *roles*, four chart series held by name |
| [lib/src/data.dart](lib/src/data.dart) | No Flutter import — it names `'paid'` and `'web'`, and the widget layer resolves them |
| [lib/src/app_shell.dart](lib/src/app_shell.dart) | Sidebar above 900px, drawer below, one source of truth for the current section |
| [lib/src/screens/orders.dart](lib/src/screens/orders.dart) | A filtered table whose row count is announced, not only drawn |
| [lib/src/screens/settings.dart](lib/src/screens/settings.dart) | `PlinthAsyncButton` — runs the future, cannot be started twice |

## The one that earns its keep

`shipped` is amber. Amber at shade 6 is about **1.9:1** on white — not
readable, and the colour every dashboard uses for "in progress" anyway.

`theme.dart` never says amber. It says:

```dart
'shipped': PlinthSemanticColor('yellow'),
```

and the badge asks for the *role*. `semanticText('shipped')` walks the
yellow ramp until it clears 4.5:1 and returns that. Change the brand,
switch to dark mode, or swap the ramp — the floor holds, because it is
enforced at lookup rather than baked into a palette someone chose once.

`test/dashboard_test.dart` asserts exactly this, for every role against
both surfaces. That test is the reason to start from this template
rather than from a screenshot of it.

## Tests

```bash
flutter test
```

Eight of them, and they are not testing Plinth — Plinth tests itself.
They test that *this app* still compiles against the current API, still
navigates on a phone, still announces its filtering, and still clears
the contrast floor. A starter that has quietly stopped doing any of
those is worse than no starter, because the person who finds out is the
one trying to begin.
