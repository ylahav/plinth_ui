/// `loading` across the input family — the last Tier 1 item.
///
/// The claim being tested is not "a spinner appears". It is that a
/// loading field is **busy, not unavailable**: still enabled, still
/// focusable, still accepting what the user types. That distinction is
/// the whole design, and it is the opposite of `PlinthButton`, which
/// drops its callback while loading because a second press would
/// submit twice. A field has no such hazard, and going dead mid-request
/// would eat the keystroke that arrived during it.
///
/// Every test here pumps rather than settling. A spinner animates for
/// as long as it is on screen, so `pumpAndSettle` never returns — which
/// is not a flaw in the loader but a property of anything that spins.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: SizedBox(width: 420, child: child))),
    );

void _noopList(List<String> _) {}

/// Every field that takes `loading`, built both ways.
final _fields = <String, Widget Function({required bool loading})>{
  'PlinthTextInput': ({required loading}) =>
      PlinthTextInput(label: 'F', loading: loading),
  'PlinthTextarea': ({required loading}) =>
      PlinthTextarea(label: 'F', loading: loading),
  'PlinthPasswordInput': ({required loading}) =>
      PlinthPasswordInput(label: 'F', loading: loading),
  'PlinthNumberInput': ({required loading}) => PlinthNumberInput(
      label: 'F', value: 0, onChanged: (_) {}, loading: loading),
  'PlinthTagsInput': ({required loading}) => PlinthTagsInput(
      label: 'F', value: const [], onChanged: _noopList, loading: loading),
  'PlinthPillsInput': ({required loading}) =>
      PlinthPillsInput(label: 'F', children: const [], loading: loading),
  'PlinthAutocomplete': ({required loading}) => PlinthAutocomplete(
        label: 'F',
        value: '',
        options: const [],
        onChanged: (_) {},
        loading: loading,
      ),
  'PlinthSelect': ({required loading}) => PlinthSelect<String>(
        label: 'F',
        options: const [PlinthSelectOption('a', 'A')],
        value: null,
        onChanged: (_) {},
        loading: loading,
      ),
  'PlinthMultiSelect': ({required loading}) => PlinthMultiSelect<String>(
        label: 'F',
        options: const [PlinthMultiSelectOption('a', 'A')],
        value: const [],
        onChanged: (_) {},
        loading: loading,
      ),
  'PlinthFileInput': ({required loading}) => PlinthFileInput<String>(
        label: 'F',
        value: const [],
        onPick: () async => const <String>[],
        onChanged: (_) {},
        labelBuilder: (f) => f,
        loading: loading,
      ),
  'PlinthTreeSelect': ({required loading}) => PlinthTreeSelect(
        label: 'F',
        nodes: const [],
        value: null,
        onChanged: (_) {},
        loading: loading,
      ),
  'PlinthColorInput': ({required loading}) => PlinthColorInput(
        label: 'F',
        value: const Color(0xFF3B5BDB),
        onChanged: (_) {},
        loading: loading,
      ),
  'PlinthMaskInput': ({required loading}) => PlinthMaskInput(
        label: 'F',
        mask: '000-000',
        onChanged: (_) {},
        loading: loading,
      ),
};

void main() {
  group('shows a spinner only when loading', () {
    _fields.forEach((name, build) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_wrap(build(loading: false)));
        await tester.pumpAndSettle();
        expect(find.byType(PlinthLoader), findsNothing,
            reason: '$name: spun without being asked');

        await tester.pumpWidget(_wrap(build(loading: true)));
        await tester.pump();
        expect(find.byType(PlinthLoader), findsWidgets,
            reason: '$name: loading: true showed nothing');
      });
    });
  });

  group('a loading field is busy, not disabled', () {
    _fields.forEach((name, build) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(_wrap(build(loading: true)));
        await tester.pump();

        // Whatever the field is made of, nothing in it may have been
        // switched off by loading alone.
        for (final field in tester.widgetList<TextField>(
          find.byType(TextField),
        )) {
          expect(field.enabled, isNot(false),
              reason: '$name: loading disabled the text field');
        }
        expect(tester.takeException(), isNull);
      });
    });
  });

  testWidgets('a loading text field still accepts typing', (tester) async {
    // The point of the whole design, stated as the thing a user does.
    var typed = '';
    await tester.pumpWidget(
      _wrap(PlinthTextInput(
        label: 'Search',
        loading: true,
        onChanged: (v) => typed = v,
      )),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'porto');
    await tester.pump();

    expect(typed, 'porto');
  });

  testWidgets('the spinner says what it is', (tester) async {
    await tester.pumpWidget(
      _wrap(const PlinthTextInput(label: 'Search', loading: true)),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Loading'), findsWidgets);
  });

  testWidgets('loading takes the trailing slot rather than crowding it',
      (tester) async {
    // Both at once would put two controls where one fits. The spinner
    // wins while it runs: a clear button mid-fetch invites clearing the
    // thing being fetched.
    await tester.pumpWidget(
      _wrap(const PlinthTextInput(
        label: 'Search',
        loading: true,
        trailing: Icon(Icons.close, key: ValueKey('trailing')),
      )),
    );
    await tester.pump();

    expect(find.byType(PlinthLoader), findsOneWidget);
    expect(find.byKey(const ValueKey('trailing')), findsNothing);
  });

  testWidgets('a button, by contrast, does go dead', (tester) async {
    // Pinning the difference, so nobody "fixes" the inconsistency by
    // making fields behave like buttons.
    var pressed = 0;
    await tester.pumpWidget(
      _wrap(PlinthButton(
        loading: true,
        onPressed: () => pressed++,
        child: const Text('Save'),
      )),
    );
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(pressed, 0, reason: 'a loading button took a second press');
  });
}
