# Build Larder — a real app with Plinth UI

*You will build an app that tracks the food in your house, works out
what you can cook from it, and talks you through cooking it. Six parts,
about ninety minutes, and at the end you will have something that works
in the dark, on a keyboard, and out loud.*

The finished app is in [`tutorial/`](../tutorial). Every code block
below is from it — [`tutorial/test/`](../tutorial/test) compiles and
runs all of it in CI, so nothing here is a snippet that used to work.

```bash
git clone https://github.com/ylahav/plinth_ui
cd plinth_ui/tutorial
flutter run -d chrome
```

## What you are building

| Screen | What it does | What it teaches |
|---|---|---|
| **Pantry** | Everything in the house, sorted by what is about to go off | Semantic colour roles, the categorical palette, live regions |
| **Suggestions** | Recipes ranked by what you can actually cook, and what it rescues | Cards, ring progress, disabled states that look disabled |
| **Cooking** | Step by step, with timers | The stepper, and the two different ways to say something out loud |

Three screens is enough to hit every interesting thing in the library
and small enough to finish. It is not a component gallery — for that
there is the [live demo](https://ylahav.github.io/plinth_ui/) and the
[Widgetbook](https://ylahav.github.io/plinth_ui/widgetbook/). This is an
app, and the difference matters: a gallery shows you that a component
exists, and an app shows you which one to reach for.

---

## Part 0 — One package, three imports you do not need

```yaml
dependencies:
  plinth_components: ^1.2.0
```

That is the whole dependency list. `plinth_components` re-exports
`plinth_core` (the tokens) and `plinth_hooks` (the controllers), so one
import line reaches everything:

```dart
import 'package:plinth_components/plinth_components.dart';
```

If you add `plinth_core` or `plinth_hooks` explicitly the analyzer will
tell you they are redundant. Add them to your `pubspec.yaml` only if you
want a package that uses the tokens *without* the widgets — which is a
real and supported thing to want, and not what this tutorial is doing.

---

## Part 1 — The theme, which is the whole colour decision

Most component libraries start with "here is a button". Plinth starts
one level down, and it is worth the ten minutes.

Open [`tutorial/lib/src/larder_theme.dart`](../tutorial/lib/src/larder_theme.dart).
It is sixty lines and it contains **every colour decision the app
makes.** Nothing else in the codebase names a hue.

### Your brand colour, and getting it back

```dart
const larderGreen = Color(0xFF2F6F4E);

PlinthTheme.defaultTheme.copyWith(
  primaryColor: 'larder',
  colors: {
    ...PlinthTheme.defaultTheme.colors,
    'larder': PlinthTheme.generateShades(larderGreen),
  },
)
```

`generateShades` turns one colour into a ten-shade ramp: light tints for
backgrounds, dark shades for text, and **shade 6 is exactly the colour
you passed in.** That last part sounds obvious and most generators do
not do it — normalising a base colour onto a fixed lightness curve turns
`#FA5252` into `#E90707`, and leaves no shade you can reliably ask for.

Every component defaults to shade 6, so this is the difference between
your buttons being your brand colour and being *near* your brand colour.
There is a test for it, and you should keep it:

```dart
test('shade 6 is exactly the colour that was fed in', () {
  expect(larderLight.shaded('larder', 6), larderGreen);
});
```

### Three roles instead of three colours

Food is fresh, about to go off, or past it. Those are the app's
concepts. `green`, `yellow` and `red` are not:

```dart
const larderRoles = <String, PlinthSemanticColor>{
  'fresh': PlinthSemanticColor('green'),
  'soon': PlinthSemanticColor('yellow'),
  'expired': PlinthSemanticColor('red'),
};
```

A `PlinthSemanticColor` is three things: a ramp, a shade on it, and the
**contrast floor the role is held to**. That third one is the part doing
real work, and Part 3 is where you see it.

### One colour per shelf

```dart
const larderShelves = <String, int>{
  'produce': 0, 'dairy': 1, 'protein': 2,
  'grain': 3, 'pantry': 4, 'spice': 5,
};
```

Read back with `theme.seriesFor('dairy')`. Note the unit: **a name, not
a `Color`.** [`model.dart`](../tutorial/lib/src/model.dart) has no
Flutter import and no `BuildContext`, so it could never hand a colour to
anything — but it can hand over the string `'dairy'`, and the widget
layer resolves it. That boundary is the reason the API is shaped this
way.

### Mounting it beside your own `ThemeData`

```dart
ThemeData larderThemeData(PlinthTheme plinth) => ThemeData(
      useMaterial3: true,
      brightness: plinth.brightness,
      colorScheme: plinth.toColorScheme(),
      scaffoldBackgroundColor: plinth.surfaceSunken,
      extensions: [plinth],
    );
```

`PlinthTheme` is a `ThemeExtension`. It rides along with the `ThemeData`
you already have rather than replacing it — which matters enormously if
you are adding this to an existing app, because you are not going to
rewrite your theme on day one.

Larder is new, so it lets Plinth generate the `ColorScheme`. **An
existing app should not.** Keep your own and add this test instead:

```dart
test('the two palettes agree', () {
  expect(myPlinthTheme.colorSchemeDisagreements(myScheme), isEmpty);
});
```

You get back every field where your `ColorScheme` and your tokens
disagree, with both values. Assert it is empty in CI and the two cannot
drift apart silently. This is the direction that a real migration
actually wanted — a wholesale `toThemeData()` was this library's
top-priority roadmap item and, during the migration that was meant to
prove it, was never reached for once.

Read from anywhere with `context.plinth`.

---

## Part 2 — The pantry list

[`tutorial/lib/src/screens/pantry.dart`](../tutorial/lib/src/screens/pantry.dart).

Standard stuff, quickly: `PlinthAppShell` for the page scaffold,
`PlinthNavLink` for the sidebar, `PlinthSegmentedControl` for the
filter, `PlinthModal` for the add form, `PlinthEmptyState` when a filter
matches nothing.

Four things worth stopping on.

**The empty state has a way out.**

```dart
PlinthEmptyState(
  title: 'Nothing needs using up',
  description: 'Nothing in this slice of the pantry.',
  icon: const Icon(Icons.inventory_2_outlined),
  action: PlinthButton(
    onPressed: () => setState(() => _filter = PantryFilter.all),
    variant: PlinthVariant.light,
    child: const Text('Show everything'),
  ),
)
```

Pass `action`. An empty state without one tells somebody their situation
and not what to do about it.

**The modal does not render inline.** `PlinthModal` needs a host:

```dart
PlinthModalHost(
  modal: PlinthModal(controller: _addModal, title: '…', child: …),
  child: /* your page */,
)
```

The controller is a `PlinthDisclosureController` — call `.open()` from
the button and `.close()` when the form submits. Dispose it.

**The part-to-whole bar is one bar, not three.**

```dart
PlinthProgress.sections(
  sections: [
    PlinthProgressSection(value: fresh / total, color: 'green', label: '…'),
    PlinthProgressSection(value: soon / total, color: 'yellow', label: '…'),
  ],
)
```

Section values are fractions **of the whole bar**, so they say "and this
much is neither" by leaving track empty. Values summing over 1 assert
rather than silently normalising.

**Icon-only buttons need a label.** This one is not a nicety:

```dart
PlinthActionIcon(
  icon: const Icon(Icons.close),
  onPressed: onRemove,
  semanticLabel: 'Remove ${item.name}',
)
```

Without it, fourteen rows give a screen-reader user fourteen controls
that all announce as "button" and nothing else. There is a test:

```dart
expect(find.bySemanticsLabel('Remove Spinach'), findsOneWidget);
```

---

## Part 3 — Colour that is legible, which is not automatic

This is the part that is different from every other Flutter component
library, so it gets its own section.

A pantry row shows freshness as a tinted pill. The naive version:

```dart
Container(
  color: Colors.amber.shade50,
  child: Text('Tomorrow', style: TextStyle(color: Colors.amber)),
)
```

That amber text is **1.86:1** against white. You can see it. You cannot
read it, and neither can anyone with ordinary middle-aged eyes in
ordinary daylight. It fails WCAG AA by a factor of two and no linter in
Flutter will say a word.

Here is the version in the app:

```dart
Container(
  decoration: BoxDecoration(
    color: theme.semanticWash(state.role),
    borderRadius: BorderRadius.circular(theme.radius[PlinthSize.sm]!),
  ),
  child: Text(
    label,
    style: TextStyle(color: theme.semanticText(state.role)),
  ),
)
```

Three calls, three different colours from one role, and each answers a
different question:

| Call | What it is for | Why not the others |
|---|---|---|
| `semantic('soon')` | A **fill** — a badge, a bar, a dot | Unreadable as text; it is the raw shade |
| `semanticText('soon')` | **Text or an icon** | Walks the ramp until it clears 4.5:1 against the background |
| `semanticWash('soon')` | A **tint** behind a row | Composites over the surface, so it survives dark mode |

`semanticText` is the one carrying the load. It starts at the role's
shade and walks toward whichever end contrasts, returning the first
shade that clears the floor. Amber's fill and amber's label are
genuinely different colours — and **your UI never has to know that**.

Two consequences worth internalising:

**Expect it to drift from brand.** Clearing 4.5:1 moves a bright brand
green from `#34C759` to `#277F3E`. Nothing here can resolve the
brand-fidelity-versus-legibility conflict; it can only surface it, and
surfacing it is the point.

**`wash` is not `shaded(name, 0)`.** In a dark theme, shade 0 mirrors to
shade 9 — because a *shade's role* should survive the flip — and the
lightest tint becomes the most saturated colour on the ramp. Your
barely-there tinted row turns into a saturated green panel.
`semanticWash` composites over the surface instead, so it keeps meaning
"almost the same as the background" in both themes.

The test file is the interesting half:

```dart
for (final theme in [larderLight, larderDark]) {
  for (final state in Freshness.values) {
    test('${state.role} is readable on its own wash', () {
      final wash = theme.semanticWash(state.role);
      expect(_ratio(theme.semanticText(state.role, on: wash), wash),
          greaterThanOrEqualTo(4.5));
    });
  }
}
```

Note `on: wash`. The label does not sit on the page — it sits on the
tint. Resolving against the wrong background is the silent kind of miss:
`readableOn` was called, a number was cleared, and the number was
against a surface the text never touches.

**And say it in words as well.** Colour is not allowed to be the only
channel (WCAG 1.4.1), so the pill reads `Tomorrow` or `Expired
yesterday`, not just amber or red. The tint says it quickly; the text
says it at all.

---

## Part 4 — Suggestions

[`tutorial/lib/src/screens/suggestions.dart`](../tutorial/lib/src/screens/suggestions.dart).

The ranking lives in plain Dart and is four lines of opinion: cookable
first, then whatever rescues the most food that is about to go off, then
best-covered, then quickest. "You can cook this" beats "this rescues two
things", because a suggestion you cannot act on is not a suggestion.

Two UI notes.

**A grid that measures the space, not the screen:**

```dart
PlinthSimpleGrid(columns: 1, minColWidth: 360, children: [...])
```

`minColWidth` fits as many columns as will hold a cell that wide, and
that is a genuinely different question from the breakpoint props — those
measure the *screen*, this measures the space the grid was handed. A
grid inside a sidebar gets narrow cells from this and desktop-sized ones
from breakpoints, because the screen is still wide.

**A disabled button should look disabled:**

```dart
PlinthButton(
  onPressed: match.canCook ? onCook : null,
  child: Text(match.canCook ? 'Cook this' : 'Missing ingredients'),
)
```

A null callback disables it — Flutter's own convention — and the library
makes that *visible* with a muted fill rather than leaving a
full-strength button that silently does nothing. The label changes too,
because a greyed button that does not say why is a puzzle.

While you are here, one thing the tutorial hit for real: **`trailing` on
a `PlinthNavLink` is not flexible.** The label is the row's `Expanded`
child; `trailing` takes its natural width. Put a count there, not a
name, or a long one overflows the navbar. This was found by a test
failing, not by reading the docs, which is the usual way.

---

## Part 5 — Cooking, and the two ways to speak

[`tutorial/lib/src/screens/cook.dart`](../tutorial/lib/src/screens/cook.dart).

The stepper is straightforward — it is a controlled component, so you
own `currentStep` and it just draws:

```dart
PlinthStepper(
  currentStep: _step,
  onStepTapped: _go,
  direction: Axis.vertical,
  steps: [for (…) PlinthStep(label: 'Step ${i + 1}', description: …)],
)
```

Tapping a step calls `onStepTapped` and does **not** move
`currentStep` itself. Same pattern as `PlinthTabs`: you own the state.

Now the part worth the whole tutorial.

### Something changed and nobody moved

Both of these happen on this screen:

1. You press **Next step** and the instruction card changes.
2. A twelve-minute timer runs out.

Neither moves focus. A screen reader has no reason to look at either
one, so by default **both are completely silent** — and no
semantics-tree test can catch that, because there is nothing wrong with
the tree. It is just never revisited.

Plinth gives you two mechanisms, and choosing between them is not a
style question:

**The step changed → `PlinthLiveRegion`.**

```dart
PlinthLiveRegion(
  message: 'Step ${_step + 1} of $total. ${_current.instruction}',
  child: PlinthCard(…),
)
```

There is something lasting on screen to read. A live region marks it as
text the reader should revisit when the message changes, without focus
moving. The message travels **in the semantics tree**, so this path
works on every platform.

Pass the message *and* the widget. `null` and `''` return the child
untouched, because a live region with nothing in it is a node a reader
visits in order to hear silence.

**The timer finished → `PlinthAnnounceWhen`.**

```dart
PlinthAnnounceWhen(
  when: done,
  message: 'Timer finished. Move on to the next step.',
  child: PlinthProgress(value: elapsed, semanticLabel: 'Time elapsed'),
)
```

Nothing lasting appears, so there is no node to visit; the message has
to be *pushed*. Two things about this:

- **Never mark a progress bar as a live region.** It would narrate every
  frame of its own animation. `PlinthAnnounceWhen` fires once, on the
  edge, and never on first build — a bar sitting at 100% is usually a
  statistic rather than something that just finished.
- **This path is silent on Android**, by that platform's own policy:
  TalkBack clears its speech queue to serve announcements, cutting off
  whatever was being read. `MediaQuery.supportsAnnounceOf` is false
  there and `PlinthAnnounce.say` returns `false` rather than degrading
  the platform's behaviour.

**The rule:** if there is something on screen to read, put the message
in the tree with `PlinthLiveRegion`. Use the announcement only where the
first cannot work.

### Testing what a reader would hear

The step badge on screen is upper-cased by `PlinthBadge`, so asserting
on it is asserting on a text transform. Assert on the message instead —
it is what actually matters:

```dart
String _spokenStep(WidgetTester tester) => tester
    .widgetList<PlinthLiveRegion>(find.byType(PlinthLiveRegion))
    .map((r) => r.message ?? '')
    .firstWhere((m) => m.startsWith('Step '), orElse: () => '');

await _tapText(tester, 'Next step');
expect(_spokenStep(tester), startsWith('Step 2 of'));
```

---

## Part 6 — Dark mode, and the keyboard

Dark mode is one switch, because Part 1 did the work:

```dart
MaterialApp(
  theme: larderThemeData(larderLight),
  darkTheme: larderThemeData(larderDark),
  themeMode: _mode,
)
```

Light and dark **share the same ramps**. A shade's *role* is mirrored
for the brightness rather than the palette being swapped, so your green
button stays your green and only the chrome around it changes. Every
`semanticText` call re-resolves against the new surface, so nothing goes
unreadable in the flip — and the test loop from Part 3 runs over both
themes for exactly that reason.

Then the keyboard. Tab through the whole app. Every control should take
focus, in an order that makes sense, with a visible ring.

This library learned that one the hard way. Its `PlinthAnchor` was
`Semantics(link: true)` wrapped around a `GestureDetector` — a link a
mouse could click, a screen reader could activate, and **Tab walked
straight past**, because a `GestureDetector` supplies a tap action and
no focus node. Every accessibility test passed; the semantics tree was
correct. The whole story is in
[The semantics tree was right](POST_THE_TREE_WAS_RIGHT.md).

The test that catches it is worth ten lines in your own suite:

```dart
// Tab forward until the control takes focus. Anything actionable has
// to be somewhere on this path — that is the whole of WCAG 2.1.1.
for (var i = 0; i < 12 && !reached; i++) {
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();
  // …check whether the add button now has focus
}
expect(reached, isTrue);
```

**Testing with a real screen reader?** Flutter web builds its
accessibility tree only on demand, behind an invisible "Enable
accessibility" button. Press `Tab` once from the top of the page and
`Enter` before anything else, or every control is silent and you will
think you broke something. Full instructions are in
[B0C_SCREEN_READER_PASS.md](B0C_SCREEN_READER_PASS.md).

---

## What to take away

Three things, if you remember nothing else.

**Name colours by role, once.** `'fresh'` and `'expired'` are declared
in one file and read everywhere. Rebrand by editing that file. Nothing
else in the app knows what colour anything is.

**Ask for text colour differently from fill colour.** They are not the
same colour and treating them as one is how a UI ends up with amber text
at 1.86:1. `semantic` fills, `semanticText` reads, `semanticWash` tints.

**Announcements are a separate axis from semantics.** A perfect
semantics tree still says nothing when something changes and nobody
moved. `PlinthLiveRegion` where there is something to read,
`PlinthAnnounceWhen` where there is not.

## Where to go next

- **[Component reference](COMPONENTS.md)** — all 117, with props
- **[Adopting tokens](ADOPTING_TOKENS.md)** — what it costs to put
  `plinth_core` into an app that already exists, including the
  `const`/context tax nobody budgets for
- **[Live demo](https://ylahav.github.io/plinth_ui/)** ·
  **[Widgetbook](https://ylahav.github.io/plinth_ui/widgetbook/)**
- **[The semantics tree was right](POST_THE_TREE_WAS_RIGHT.md)** — the
  accessibility bug no test could find, and the one that does

Found something wrong here, or something Larder should do?
[Open an issue](https://github.com/ylahav/plinth_ui/issues) — the app in
`tutorial/` is compiled and tested by CI, so a broken snippet is a bug
like any other.
