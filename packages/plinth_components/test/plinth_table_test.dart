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
          const PlinthTable.text(
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

    testWidgets('renders with striping enabled without throwing',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTable.text(
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

    testWidgets('renders with an empty row list without throwing',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTable.text(columns: ['Name'], rows: []),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('takes arbitrary widgets as cells', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthTable(
            columns: const ['Person', 'Status', ''],
            rows: [
              [
                const PlinthAvatar(initials: 'AB', size: PlinthSize.sm),
                const PlinthBadge('Active', color: 'green'),
                PlinthActionIcon(
                  icon: const Icon(Icons.more_horiz, size: 16),
                  onPressed: () {},
                ),
              ],
            ],
          ),
        ),
      );

      // The limitation this replaced: cells were plain strings, so a
      // status column could not hold a badge and an actions column
      // could not hold a button.
      expect(find.byType(PlinthAvatar), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.byType(PlinthActionIcon), findsOneWidget);
    });

    testWidgets('a widget cell stays interactive', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthTable(
            columns: const ['Actions'],
            rows: [
              [
                PlinthButton(
                  onPressed: () => taps++,
                  size: PlinthSize.xs,
                  child: const Text('Edit'),
                ),
              ],
            ],
          ),
        ),
      );

      await tester.tap(find.text('Edit'));
      expect(taps, 1);
    });

    testWidgets('a bare Text cell inherits the table text style',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTable(
            size: PlinthSize.lg,
            columns: ['Name'],
            rows: [
              [Text('Alice')],
            ],
          ),
        ),
      );

      // Otherwise an unstyled Text in a widget row would render at
      // Material's default size next to a correctly-sized text cell.
      final style = DefaultTextStyle.of(
        tester.element(find.text('Alice')),
      ).style;
      expect(style.fontSize, PlinthTheme.defaultTheme.fontSizes[PlinthSize.lg]);
    });

    testWidgets('both constructors report the same row count', (tester) async {
      const text = PlinthTable.text(
        columns: ['A'],
        rows: [
          ['1'],
          ['2'],
        ],
      );
      const widgets = PlinthTable(
        columns: ['A'],
        rows: [
          [Text('1')],
          [Text('2')],
        ],
      );

      expect(text.rowCount, 2);
      expect(widgets.rowCount, 2);
    });
  });
}
