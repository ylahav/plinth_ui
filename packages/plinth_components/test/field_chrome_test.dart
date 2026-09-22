/// Every field wears the same chrome, asserted across all of them at
/// once.
///
/// Before `PlinthFieldChrome`, eleven inputs each carried their own
/// copy of the label/description/error block. They agreed — that was
/// the point, and why nothing caught it — but agreeing by coincidence
/// eleven times is a state one careless edit ends. These tests are the
/// thing that would notice.
///
/// Deliberately behavioural. A test that asserted "each of these uses
/// `PlinthFieldChrome`" would pin the implementation and say nothing
/// about what a user gets, and would pass just as well if the chrome
/// rendered nothing at all.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: SizedBox(width: 360, child: child))),
    );

/// One builder per field, so a new field is one line here.
const _label = 'Field label';
const _description = 'What this field is for.';
const _error = 'Something is wrong with it.';

final _fields = <String, Widget Function()>{
  'PlinthTextInput': () => const PlinthTextInput(
      label: _label, description: _description, error: _error),
  'PlinthTextarea': () => const PlinthTextarea(
      label: _label, description: _description, error: _error),
  'PlinthPasswordInput': () => const PlinthPasswordInput(
      label: _label, description: _description, error: _error),
  'PlinthNumberInput': () => PlinthNumberInput(
        label: _label,
        description: _description,
        error: _error,
        value: 0,
        onChanged: (_) {},
      ),
  'PlinthTagsInput': () => PlinthTagsInput(
        label: _label,
        description: _description,
        error: _error,
        value: const [],
        onChanged: (_) {},
      ),
  'PlinthAutocomplete': () => PlinthAutocomplete(
        label: _label,
        description: _description,
        error: _error,
        value: '',
        options: const [],
        onChanged: (_) {},
      ),
  'PlinthSelect': () => PlinthSelect<String>(
        label: _label,
        description: _description,
        error: _error,
        options: const [PlinthSelectOption('a', 'A')],
        value: null,
        onChanged: (_) {},
      ),
  'PlinthMultiSelect': () => PlinthMultiSelect<String>(
        label: _label,
        description: _description,
        error: _error,
        options: const [PlinthMultiSelectOption('a', 'A')],
        value: const [],
        onChanged: (_) {},
      ),
  'PlinthFileInput': () => PlinthFileInput<String>(
        label: _label,
        description: _description,
        error: _error,
        value: const [],
        onPick: () async => const <String>[],
        onChanged: (_) {},
        labelBuilder: (f) => f,
      ),
  'PlinthPillsInput': () => const PlinthPillsInput(
        label: _label,
        description: _description,
        error: _error,
        children: [],
      ),
  'PlinthTreeSelect': () => PlinthTreeSelect(
        label: _label,
        description: _description,
        error: _error,
        nodes: const [],
        value: null,
        onChanged: (_) {},
      ),
};

void main() {
  _textareaFormatters();

  group('every field renders the same chrome', () {
    _fields.forEach((name, build) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_wrap(build()));
        await tester.pumpAndSettle();

        expect(find.text(_label), findsWidgets, reason: '$name: no label');
        expect(find.text(_description), findsOneWidget,
            reason: '$name: no description');
        expect(find.text(_error), findsOneWidget, reason: '$name: no error');
      });
    });
  });

  group('the error message is a live region', () {
    // An error that appears after the field has been left is a change
    // nothing else announces. This was correct in all eleven before the
    // extraction; the risk is that a future field is written without it.
    _fields.forEach((name, build) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_wrap(build()));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(PlinthLiveRegion),
            matching: find.text(_error),
          ),
          findsOneWidget,
          reason: '$name: the error is drawn but not announced',
        );
      });
    });
  });

  testWidgets('an empty error string is not an error', (tester) async {
    // A caller clearing an error often passes '' rather than null.
    // Treating that as an error paints a red border around a field
    // with nothing wrong with it, under an empty message.
    await tester.pumpWidget(
      _wrap(const PlinthTextInput(label: _label, error: '')),
    );
    await tester.pumpAndSettle();

    final container = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere((c) => (c.decoration as BoxDecoration?)?.border != null);
    final border = (container.decoration! as BoxDecoration).border!;

    expect(
      border.top.color,
      PlinthTheme.defaultTheme.border,
      reason: 'an empty error string painted the error border',
    );
  });
}

void _textareaFormatters() {
  group('PlinthTextarea.inputFormatters', () {
    testWidgets('a length limit prevents rather than corrects', (tester) async {
      // The distinction the parameter exists for: a formatter runs
      // before the value is committed, so the over-long text never
      // lands. Truncating afterwards is visible as a flicker and
      // fights the caret.
      final controller = TextEditingController();
      await tester.pumpWidget(_wrap(PlinthTextarea(
        label: 'Bio',
        controller: controller,
        inputFormatters: [LengthLimitingTextInputFormatter(10)],
      )));

      await tester.enterText(find.byType(TextField), 'a' * 400);
      await tester.pumpAndSettle();

      expect(controller.text.length, 10);
    });

    testWidgets('a whitelist refuses what does not match', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrap(PlinthTextarea(
        label: 'Digits',
        controller: controller,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      )));

      await tester.enterText(find.byType(TextField), 'a1b2c3');
      await tester.pumpAndSettle();

      expect(controller.text, '123');
    });

    testWidgets('and nothing changes when none are given', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(PlinthTextarea(label: 'Bio', controller: controller)),
      );

      await tester.enterText(find.byType(TextField), 'anything at all');
      await tester.pumpAndSettle();

      expect(controller.text, 'anything at all');
    });
  });
}
