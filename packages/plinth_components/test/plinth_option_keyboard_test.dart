/// An open list of options must be usable without a mouse.
///
/// `PlinthAutocomplete` and `PlinthMultiSelect` each opened a list that
/// a pointer could operate and a keyboard could not: arrows did
/// nothing, Enter did nothing, and the only way to choose was to click.
/// **WCAG 2.1.1** — the same guideline `F-4` broke, in a place no
/// existing test looked, because reachability and focus order are both
/// satisfied by a field whose *list* is inert.
///
/// `PlinthSelect` was never affected: it wraps Material's
/// `DropdownButton`, which brings its own keyboard support. The
/// ROADMAP's "the dropdown family leaks Tab" was one component too
/// broad, and that is recorded rather than quietly corrected.
///
/// The pattern is a highlight, not a focus trap. The keyboard stays in
/// the field — the user is still typing — and arrows move a
/// highlighted row that Enter commits.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _autocomplete(void Function(String) onChanged, String value) =>
    MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: PlinthAutocomplete(
              label: 'Company',
              value: value,
              options: const ['Alpha', 'Amber', 'Apex'],
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );

Future<void> _openAutocomplete(WidgetTester tester) async {
  await tester.tap(find.byType(TextField));
  await tester.enterText(find.byType(TextField), 'a');
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  group('PlinthAutocomplete', () {
    testWidgets('arrows and Enter choose an option', (tester) async {
      var value = '';
      await tester.pumpWidget(_autocomplete((v) => value = v, value));
      await _openAutocomplete(tester);

      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.enter);

      expect(value, 'Amber');
    });

    testWidgets('the first Down enters at the top', (tester) async {
      var value = '';
      await tester.pumpWidget(_autocomplete((v) => value = v, value));
      await _openAutocomplete(tester);

      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.enter);

      expect(value, 'Alpha');
    });

    testWidgets('the first Up enters at the bottom', (tester) async {
      // Entering the list from the end you came from, which is what
      // every native combobox does.
      var value = '';
      await tester.pumpWidget(_autocomplete((v) => value = v, value));
      await _openAutocomplete(tester);

      await _press(tester, LogicalKeyboardKey.arrowUp);
      await _press(tester, LogicalKeyboardKey.enter);

      expect(value, 'Apex');
    });

    testWidgets('Escape closes without choosing', (tester) async {
      var value = '';
      await tester.pumpWidget(_autocomplete((v) => value = v, value));
      await _openAutocomplete(tester);
      await _press(tester, LogicalKeyboardKey.arrowDown);

      await _press(tester, LogicalKeyboardKey.escape);

      expect(find.text('Alpha'), findsNothing);
      expect(value, 'a', reason: 'Escape committed a highlight');
    });

    testWidgets('typing resets the highlight', (tester) async {
      // The matches changed, so an index into the previous list points
      // at something else. Highlighting the wrong row is worse than
      // highlighting none.
      var value = '';
      await tester.pumpWidget(_autocomplete((v) => value = v, value));
      await _openAutocomplete(tester);
      await _press(tester, LogicalKeyboardKey.arrowDown);

      await tester.enterText(find.byType(TextField), 'am');
      await tester.pumpAndSettle();
      await _press(tester, LogicalKeyboardKey.enter);

      expect(value, 'am', reason: 'a stale highlight was committed');
    });
  });

  group('PlinthMultiSelect', () {
    testWidgets('arrows and Enter add an option', (tester) async {
      var picked = <String>[];
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) => SizedBox(
                width: 400,
                child: PlinthMultiSelect<String>(
                  label: 'Tags',
                  options: const [
                    PlinthMultiSelectOption('a', 'Alpha'),
                    PlinthMultiSelectOption('b', 'Beta'),
                  ],
                  value: picked,
                  onChanged: (v) => setState(() => picked = v),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('plinth_multi_select_field')));
      await tester.pumpAndSettle();

      // The tap moves focus and opens the overlay in the same gesture.
      // Without settling again, the first key event is dispatched
      // before the field is focused and is simply lost — which is a
      // property of the test harness, not of the widget: a person
      // cannot press a key in the same frame as their own click.
      await tester.pumpAndSettle();

      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.enter);

      expect(picked, ['b']);
    });
  });

  group('PlinthSelect was never broken', () {
    testWidgets('and still is not', (tester) async {
      // A regression guard on the one the ROADMAP wrongly implicated.
      String? picked = 'a';
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) => SizedBox(
                width: 400,
                child: PlinthSelect<String>(
                  label: 'Country',
                  options: const [
                    PlinthSelectOption('a', 'Alpha'),
                    PlinthSelectOption('b', 'Beta'),
                  ],
                  value: picked,
                  onChanged: (v) => setState(() => picked = v),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await _press(tester, LogicalKeyboardKey.tab);
      await _press(tester, LogicalKeyboardKey.enter);
      await _press(tester, LogicalKeyboardKey.arrowDown);
      await _press(tester, LogicalKeyboardKey.enter);

      expect(picked, 'b');
    });
  });
}
