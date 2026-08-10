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
  group('PlinthTable', () {
    testWidgets('renders column headers and cell values', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTable(
            columns: ['Name', 'Role'],
            rows: [
              ['Alice', 'Engineer'],
              ['Bob', 'Designer'],
            ],
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Engineer'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Designer'), findsOneWidget);
    });

    testWidgets('renders with striping enabled without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTable(
            striped: true,
            columns: ['Name'],
            rows: [
              ['Alice'],
              ['Bob'],
              ['Carol'],
            ],
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('renders with an empty row list without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTable(columns: ['Name'], rows: []),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
    });
  });
}
