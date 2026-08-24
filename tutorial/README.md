# Larder — the tutorial app

The app built step by step in
[docs/TUTORIAL_LARDER_APP.md](../docs/TUTORIAL_LARDER_APP.md). It tracks
what food is in the house, works out what can be cooked from it, and
talks you through cooking it.

**Start with the tutorial, not with this directory.** The code is
arranged so each file is one part of it.

```bash
flutter run -d chrome    # or -d windows / -d macos / -d linux
flutter test
```

Try it without cloning: **[live build](https://ylahav.github.io/plinth_ui/tutorial/)**.

## What is where

| | Part | What it shows |
|---|---|---|
| [`lib/src/larder_theme.dart`](lib/src/larder_theme.dart) | 1 | Every colour decision the app makes — an anchored brand ramp, three semantic roles, one colour per shelf |
| [`lib/src/model.dart`](lib/src/model.dart) | — | Plain Dart. No Flutter import, no `BuildContext`, no colours: the boundary that makes `seriesFor('dairy')` take a name rather than a `Color` |
| [`lib/src/screens/pantry.dart`](lib/src/screens/pantry.dart) | 2, 3 | The list, and the role lookups that keep a tinted row readable |
| [`lib/src/screens/suggestions.dart`](lib/src/screens/suggestions.dart) | 4 | Cards, ring progress, and a disabled button that looks disabled |
| [`lib/src/screens/cook.dart`](lib/src/screens/cook.dart) | 5 | The stepper, and the two different ways to say something out loud |
| [`lib/main.dart`](lib/main.dart) | 1, 6 | The shell, navigation, and dark mode |

## The tests are half the point

```bash
flutter test
```

Fifty of them, in three files, and they are the reason nothing in the
tutorial is a snippet that used to work:

- [`test/model_test.dart`](test/model_test.dart) — the freshness and
  ranking rules, against a fixed Tuesday rather than the clock
- [`test/larder_theme_test.dart`](test/larder_theme_test.dart) — that
  the brand colour survives the ramp, and that **every role clears 4.5:1
  in both themes, on the page and on its own tint**
- [`test/app_test.dart`](test/app_test.dart) — the flow end to end, plus
  what a screen reader would hear and whether `Tab` gets there

The second file is the one worth copying into your own project. It
checks a claim the UI relies on everywhere and verifies nowhere else.

## Notes

The seed pantry is dated relative to launch, so one item is always past
its date and two are always close to it. That is deliberate: the
freshness roles are visible the moment the app opens, and the demo never
goes stale.

Cooking timers are real minutes with a **Skip the wait** link beside
them. A tutorial nobody can finish in under twenty minutes is a tutorial
nobody finishes.
