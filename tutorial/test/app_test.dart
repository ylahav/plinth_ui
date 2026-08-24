// The app, driven end to end: pantry → suggestions → cooking → pantry.
//
// Two kinds of assertion here, and the second is the one worth copying.
// The first checks the app works. The second checks it can be *used* —
// that the controls say what they are and that a keyboard reaches them.
// The library's own history is the argument for the second: the defect
// that took longest to find had a perfectly correct semantics tree and
// no focus node, and no tree-walking test could see it.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:plinth_tutorial/main.dart';
import 'package:plinth_tutorial/src/screens/pantry.dart';

/// A window big enough for the shell's navbar and a content column.
Future<void> _pumpLarder(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const LarderApp());
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

/// What a screen reader would be told the current step is.
///
/// Read from the live region rather than from the badge on screen,
/// which `PlinthBadge` renders upper-cased. The message is the thing
/// that actually matters here, and it is the thing under test.
String _spokenStep(WidgetTester tester) {
  final regions = tester.widgetList<PlinthLiveRegion>(
    find.byType(PlinthLiveRegion),
  );
  return regions
      .map((r) => r.message ?? '')
      .firstWhere((m) => m.startsWith('Step '), orElse: () => '');
}

void main() {
  group('the pantry screen', () {
    testWidgets('opens on the pantry, with the seeded food in it',
        (tester) async {
      await _pumpLarder(tester);

      expect(find.text('Pantry'), findsWidgets);
      expect(find.text('Spinach'), findsOneWidget);
      expect(find.text('Coriander'), findsOneWidget);
    });

    testWidgets('warns about what is about to go off', (tester) async {
      await _pumpLarder(tester);

      // The seed always puts one item past its date and two close to
      // it, so the banner is never absent and never stale.
      expect(find.byType(PlinthAlert), findsOneWidget);
      expect(find.textContaining('past its date'), findsWidgets);
    });

    testWidgets('the freshness label is a word, not only a colour',
        (tester) async {
      await _pumpLarder(tester);

      // WCAG 1.4.1. A tinted row that says nothing is a row that says
      // nothing to anybody who cannot see the tint.
      expect(find.text('Expired yesterday'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
    });

    testWidgets('filtering to the expired slice keeps only that',
        (tester) async {
      await _pumpLarder(tester);
      await _tapText(tester, 'Expired (1)');

      expect(find.text('Coriander'), findsOneWidget);
      expect(find.text('Spinach'), findsNothing);
    });

    testWidgets('an empty filter offers a way out rather than a blank',
        (tester) async {
      await _pumpLarder(tester);
      await _tapText(tester, 'Expired (1)');
      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text('Coriander'),
            matching: find.byType(PantryRow),
          ),
          matching: find.byType(PlinthActionIcon),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlinthEmptyState), findsOneWidget);
      expect(find.text('Show everything'), findsOneWidget);
    });
  });

  group('suggestions', () {
    testWidgets('rank something cookable first', (tester) async {
      await _pumpLarder(tester);
      await _tapText(tester, 'Suggestions');

      expect(find.text('Cook this'), findsWidgets);
    });

    testWidgets('a recipe missing an ingredient cannot be started',
        (tester) async {
      await _pumpLarder(tester);
      await _tapText(tester, 'Suggestions');

      final blocked = tester.widgetList<PlinthButton>(
        find.ancestor(
          of: find.text('Missing ingredients'),
          matching: find.byType(PlinthButton),
        ),
      );

      expect(blocked, isNotEmpty);
      expect(blocked.every((b) => b.onPressed == null), isTrue,
          reason: 'a null callback disables it, and the library makes '
              'that visible rather than leaving a live-looking button '
              'that does nothing');
    });
  });

  group('cooking', () {
    testWidgets('walks the steps and finishes', (tester) async {
      await _pumpLarder(tester);
      await _tapText(tester, 'Suggestions');
      await _tapText(tester, 'Cook this');

      expect(_spokenStep(tester), startsWith('Step 1 of'));

      await _tapText(tester, 'Next step');
      expect(_spokenStep(tester), startsWith('Step 2 of'));

      // Walk to the end, however many steps this recipe has.
      while (find.text('Next step').evaluate().isNotEmpty) {
        await _tapText(tester, 'Next step');
      }

      await _tapText(tester, 'Finished cooking');
      expect(find.text('Was it any good?'), findsOneWidget);
    });

    testWidgets('finishing takes the ingredients out of the pantry',
        (tester) async {
      await _pumpLarder(tester);
      await _tapText(tester, 'Suggestions');
      await _tapText(tester, 'Cook this');

      while (find.text('Next step').evaluate().isNotEmpty) {
        await _tapText(tester, 'Next step');
      }
      await _tapText(tester, 'Finished cooking');
      await _tapText(tester, 'Back to the pantry');

      // The top suggestion is the one that rescues what is about to go
      // off, so the spinach is what gets used and what disappears.
      expect(find.text('Pantry'), findsWidgets);
      expect(find.text('Spinach'), findsNothing,
          reason: 'cooking the first suggestion should have used the '
              'spinach up, which is why it was suggested first');
    });

    testWidgets('the step card is a live region, so a change is spoken',
        (tester) async {
      await _pumpLarder(tester);
      await _tapText(tester, 'Suggestions');
      await _tapText(tester, 'Cook this');

      // Moving between steps moves no focus, so without a live region
      // the whole interaction is silent to a screen reader — and the
      // message has to carry the instruction, not only the number.
      final before = _spokenStep(tester);
      await _tapText(tester, 'Next step');
      final after = _spokenStep(tester);

      expect(before, isNotEmpty);
      expect(after, isNot(before));
      expect(after.split('. ').last, isNotEmpty,
          reason: 'the spoken message carries the instruction itself, so '
              'a reader hears what to do rather than only where it is');
    });
  });

  group('it can be used without a mouse', () {
    testWidgets('every remove button says which item it removes',
        (tester) async {
      await _pumpLarder(tester);

      // Fourteen buttons all announcing "button" is fourteen buttons a
      // screen-reader user cannot tell apart.
      expect(find.bySemanticsLabel('Remove Spinach'), findsOneWidget);
      expect(find.bySemanticsLabel('Remove Coriander'), findsOneWidget);
    });

    testWidgets('Tab reaches the add button and Enter opens the modal',
        (tester) async {
      await _pumpLarder(tester);

      // Focus the first thing, then walk forward until the add button
      // takes focus. Anything actionable has to be somewhere on this
      // path — that is the whole of WCAG 2.1.1.
      var reached = false;
      for (var i = 0; i < 12 && !reached; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        final focused = FocusManager.instance.primaryFocus?.context;
        if (focused == null) continue;
        focused.visitAncestorElements((element) {
          if (element.widget is PlinthButton &&
              (element.widget as PlinthButton).child is Text &&
              ((element.widget as PlinthButton).child as Text).data ==
                  'Add item') {
            reached = true;
            return false;
          }
          return true;
        });
      }

      expect(reached, isTrue,
          reason: 'Tab never reached the add button, so a keyboard user '
              'can never add anything');

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Add to the pantry'), findsWidgets);
    });
  });
}
