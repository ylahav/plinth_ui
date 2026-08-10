import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('PlinthMultiSelect', () {
    testWidgets('shows placeholder when nothing is selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthMultiSelect<String>(
            placeholder: 'Choose skills',
            value: const [],
            onChanged: (_) {},
            options: const [
              PlinthMultiSelectOption('dart', 'Dart'),
              PlinthMultiSelectOption('flutter', 'Flutter'),
            ],
          ),
        ),
      );

      expect(find.text('Choose skills'), findsOneWidget);
    });

    testWidgets('renders a chip for each selected value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthMultiSelect<String>(
            value: const ['dart'],
            onChanged: (_) {},
            options: const [
              PlinthMultiSelectOption('dart', 'Dart'),
              PlinthMultiSelectOption('flutter', 'Flutter'),
            ],
          ),
        ),
      );

      expect(find.text('Dart'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('tapping the field opens a dropdown of unselected options',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthMultiSelect<String>(
            value: const ['dart'],
            onChanged: (_) {},
            options: const [
              PlinthMultiSelectOption('dart', 'Dart'),
              PlinthMultiSelectOption('flutter', 'Flutter'),
            ],
          ),
        ),
      );

      // "Dart" is already selected (shown as a chip) — tap the field
      // to open the dropdown, which should offer only "Flutter".
      await tester.tap(find.byType(PlinthMultiSelect<String>));
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('selecting an option from the dropdown calls onChanged',
        (tester) async {
      List<String>? changed;
      await tester.pumpWidget(
        _wrap(
          PlinthMultiSelect<String>(
            value: const [],
            onChanged: (v) => changed = v,
            options: const [
              PlinthMultiSelectOption('dart', 'Dart'),
              PlinthMultiSelectOption('flutter', 'Flutter'),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(PlinthMultiSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dart'));
      await tester.pumpAndSettle();

      expect(changed, equals(['dart']));
    });

    testWidgets('deleting a chip calls onChanged without that value',
        (tester) async {
      List<String>? changed;
      await tester.pumpWidget(
        _wrap(
          PlinthMultiSelect<String>(
            value: const ['dart', 'flutter'],
            onChanged: (v) => changed = v,
            options: const [
              PlinthMultiSelectOption('dart', 'Dart'),
              PlinthMultiSelectOption('flutter', 'Flutter'),
            ],
          ),
        ),
      );

      // Chip's delete icon.
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();

      expect(changed, isNotNull);
      expect(changed!.length, equals(1));
    });
  });
}
