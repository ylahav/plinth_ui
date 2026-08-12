import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

const _plans = [
  PlinthRadioOption('free', 'Free'),
  PlinthRadioOption('pro', 'Pro'),
  PlinthRadioOption('team', 'Team'),
];

const _countries = [
  PlinthSelectOption('us', 'United States'),
  PlinthSelectOption('il', 'Israel'),
];

void main() {
  group('PlinthRadioGroup', () {
    testWidgets('renders its label and every option', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthRadioGroup<String>(
            label: 'Plan',
            value: 'free',
            onChanged: (_) {},
            options: _plans,
          ),
        ),
      );

      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      expect(find.text('Team'), findsOneWidget);
    });

    testWidgets('renders a description when given one', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthRadioGroup<String>(
            label: 'Plan',
            description: 'You can change this later.',
            value: 'free',
            onChanged: (_) {},
            options: _plans,
          ),
        ),
      );

      expect(find.text('You can change this later.'), findsOneWidget);
    });

    testWidgets('tapping an option reports its value', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlinthRadioGroup<String>(
            value: 'free',
            onChanged: changes.add,
            options: _plans,
          ),
        ),
      );

      await tester.tap(find.text('Pro'));

      // Controlled, like every other selection component here: it
      // reports the choice and leaves the caller to apply it.
      expect(changes, ['pro']);
    });

    testWidgets('marks only the selected option as checked', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthRadioGroup<String>(
            value: 'pro',
            onChanged: (_) {},
            options: _plans,
          ),
        ),
      );

      final radios = find.byType(PlinthRadio<String>);
      expect(
        tester.getSemantics(radios.at(0)).flagsCollection.isChecked,
        CheckedState.isFalse,
      );
      expect(
        tester.getSemantics(radios.at(1)).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
    });

    testWidgets('announces options as mutually exclusive', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthRadioGroup<String>(
            value: 'free',
            onChanged: (_) {},
            options: _plans,
          ),
        ),
      );

      // What tells a screen reader this is a radio group rather than a
      // column of independent checkboxes.
      final semantics =
          tester.getSemantics(find.byType(PlinthRadio<String>).first);
      expect(semantics.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    });

    testWidgets('a null onChanged disables every option', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthRadioGroup<String>(
            value: 'free',
            onChanged: null,
            options: _plans,
          ),
        ),
      );

      await tester.tap(find.text('Pro'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        tester
            .getSemantics(find.byType(PlinthRadio<String>).first)
            .flagsCollection
            .isEnabled,
        Tristate.isFalse,
      );
    });

    testWidgets('works with a non-string value type', (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(
        _wrap(
          PlinthRadioGroup<int>(
            value: 1,
            onChanged: changes.add,
            options: const [
              PlinthRadioOption(1, 'One'),
              PlinthRadioOption(2, 'Two'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Two'));

      expect(changes, [2]);
    });
  });

  group('PlinthSelect', () {
    testWidgets('shows the placeholder with no selection', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthSelect<String>(
            label: 'Country',
            placeholder: 'Choose a country',
            value: null,
            onChanged: (_) {},
            options: _countries,
          ),
        ),
      );

      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Choose a country'), findsOneWidget);
    });

    testWidgets('shows the selected option label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthSelect<String>(
            value: 'il',
            onChanged: (_) {},
            options: _countries,
          ),
        ),
      );

      expect(find.text('Israel'), findsWidgets);
    });

    testWidgets('renders description and error text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthSelect<String>(
            label: 'Country',
            description: 'Where you are billed.',
            error: 'Please select a country',
            value: null,
            onChanged: (_) {},
            options: _countries,
          ),
        ),
      );

      expect(find.text('Where you are billed.'), findsOneWidget);
      expect(find.text('Please select a country'), findsOneWidget);
    });

    testWidgets('opening the menu and choosing reports the value',
        (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(
        _wrap(
          PlinthSelect<String>(
            value: null,
            placeholder: 'Choose',
            onChanged: changes.add,
            options: _countries,
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Israel').last);
      await tester.pumpAndSettle();

      expect(changes, ['il']);
    });

    testWidgets('enabled: false stops the menu opening', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthSelect<String>(
            value: null,
            placeholder: 'Choose',
            enabled: false,
            onChanged: (_) {},
            options: _countries,
          ),
        ),
      );

      expect(
        tester
            .widget<DropdownButton<String>>(
              find.byType(DropdownButton<String>),
            )
            .onChanged,
        isNull,
      );
    });

    testWidgets('hides the default dropdown underline', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthSelect<String>(
            value: null,
            onChanged: (_) {},
            options: _countries,
          ),
        ),
      );

      // The field draws its own border, so Material's underline would
      // double up on it.
      expect(find.byType(DropdownButtonHideUnderline), findsOneWidget);
    });
  });
}
