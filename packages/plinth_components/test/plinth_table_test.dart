import 'package:flutter/gestures.dart';
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

  group('PlinthTable sorting', () {
    /// Row order as rendered, read top to bottom from the first column.
    List<String> renderedFirstColumn(WidgetTester tester) {
      return tester
          .widgetList<PlinthText>(find.byType(PlinthText))
          .map((t) => t.data)
          .where((d) => d != 'Name' && d != 'Score')
          .where((d) => !RegExp(r'^\d+$').hasMatch(d))
          .toList();
    }

    Widget table({
      bool sortable = true,
      void Function(int, bool)? onSortChanged,
      int? sortColumn,
      bool sortAscending = true,
    }) {
      return _wrap(
        PlinthTable.text(
          columns: const ['Name', 'Score'],
          sortable: sortable,
          onSortChanged: onSortChanged,
          sortColumn: sortColumn,
          sortAscending: sortAscending,
          rows: const [
            ['Carol', '9'],
            ['Alice', '10'],
            ['Bob', '2'],
          ],
        ),
      );
    }

    testWidgets('tapping a header sorts, tapping again reverses', (
      tester,
    ) async {
      await tester.pumpWidget(table());

      expect(renderedFirstColumn(tester), ['Carol', 'Alice', 'Bob']);

      await tester.tap(find.bySemanticsLabel('Name, not sorted'));
      await tester.pump();
      expect(renderedFirstColumn(tester), ['Alice', 'Bob', 'Carol']);

      await tester.tap(find.bySemanticsLabel('Name, sorted ascending'));
      await tester.pump();
      expect(renderedFirstColumn(tester), ['Carol', 'Bob', 'Alice']);
    });

    testWidgets('numeric columns sort as numbers, not as text', (tester) async {
      await tester.pumpWidget(table());

      await tester.tap(find.bySemanticsLabel('Score, not sorted'));
      await tester.pump();

      // Sorted as text this is 10, 2, 9 — the classic wrong answer.
      expect(renderedFirstColumn(tester), ['Bob', 'Carol', 'Alice']);
    });

    testWidgets('headers announce their sort state', (tester) async {
      await tester.pumpWidget(table());

      expect(find.bySemanticsLabel('Name, not sorted'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Name, not sorted'));
      await tester.pump();

      expect(find.bySemanticsLabel('Name, sorted ascending'), findsOneWidget);
      expect(find.bySemanticsLabel('Score, not sorted'), findsOneWidget);
    });

    testWidgets('onSortChanged takes over and the table stops reordering', (
      tester,
    ) async {
      int? column;
      bool? ascending;

      await tester.pumpWidget(
        table(
          onSortChanged: (c, a) {
            column = c;
            ascending = a;
          },
        ),
      );

      await tester.tap(find.bySemanticsLabel('Name, not sorted'));
      await tester.pump();

      // Reported, not applied — what a server-side table needs.
      expect(column, 0);
      expect(ascending, isTrue);
      expect(renderedFirstColumn(tester), ['Carol', 'Alice', 'Bob']);
    });

    testWidgets('a controlled table still shows the caller\'s direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        table(onSortChanged: (_, __) {}, sortColumn: 1, sortAscending: false),
      );

      expect(find.bySemanticsLabel('Score, sorted descending'), findsOneWidget);
    });

    testWidgets('headers are inert when sortable is false', (tester) async {
      await tester.pumpWidget(table(sortable: false));

      expect(find.bySemanticsLabel('Name, not sorted'), findsNothing);
      expect(find.text('Name'), findsOneWidget);
    });
  });

  group('PlinthTable filtering', () {
    Widget filtered(String? filter, {Widget? emptyState}) {
      return _wrap(
        PlinthTable.text(
          columns: const ['Name', 'Role'],
          filter: filter,
          emptyState: emptyState,
          rows: const [
            ['Alice', 'Engineer'],
            ['Bob', 'Designer'],
            ['Carol', 'Engineer'],
          ],
        ),
      );
    }

    testWidgets('keeps only rows matching the query', (tester) async {
      await tester.pumpWidget(filtered('engineer'));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
    });

    testWidgets('matches case insensitively across every column', (
      tester,
    ) async {
      await tester.pumpWidget(filtered('BOB'));

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('null and empty filters show everything', (tester) async {
      await tester.pumpWidget(filtered(null));
      expect(find.text('Bob'), findsOneWidget);

      await tester.pumpWidget(filtered('   '));
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows the empty state when nothing matches', (tester) async {
      await tester.pumpWidget(
        filtered(
          'nobody',
          emptyState: const PlinthEmptyState(title: 'No matches'),
        ),
      );

      expect(find.text('No matches'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
      // The header stays: it's what tells you what you filtered.
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('without an empty state it just renders no rows', (
      tester,
    ) async {
      await tester.pumpWidget(filtered('nobody'));

      expect(find.text('Alice'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('widget rows sort and filter through sortValues', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTable(
            columns: ['Name', 'Status'],
            filter: 'invited',
            rows: [
              [PlinthText('Alice'), PlinthBadge('Active', color: 'green')],
              [PlinthText('Bob'), PlinthBadge('Invited', color: 'gray')],
            ],
            // A widget cell has no value to compare, so the plain
            // strings behind them have to come along.
            sortValues: [
              ['Alice', 'Active'],
              ['Bob', 'Invited'],
            ],
          ),
        ),
      );

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    });
  });

  group('PlinthTable maxHeight', () {
    final manyRows = [
      for (var i = 0; i < 40; i++) ['Person $i', 'Role $i'],
    ];

    testWidgets('splits into a fixed header and a scrolling body',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthTable.text(
          columns: const ['Name', 'Role'],
          rows: manyRows,
          maxHeight: 200,
        )),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.getSize(find.byType(PlinthTable)).height, equals(200));

      final headerBefore = tester.getRect(find.text('Name'));
      final rowBefore = tester.getRect(find.text('Person 0'));

      await tester.drag(find.text('Person 0'), const Offset(0, -300));
      await tester.pump();

      // The rows moved; the header did not. That is the whole feature.
      expect(tester.getRect(find.text('Name')), equals(headerBefore));
      expect(
        tester.getRect(find.text('Person 0')).top,
        lessThan(rowBefore.top - 200),
      );
    });

    testWidgets('the header and the body agree on column edges',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthTable.text(
          // A short header over a long cell is exactly where two
          // independently-sized tables would drift apart.
          columns: const ['A', 'Description'],
          rows: const [
            ['x', 'a considerably longer piece of text than the header'],
          ],
          maxHeight: 200,
        )),
      );

      expect(
        tester.getRect(find.text('Description')).left,
        equals(tester
            .getRect(find.text(
              'a considerably longer piece of text than the header',
            ))
            .left),
      );
    });

    testWidgets('stays its natural height when the rows do not fill it',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthTable.text(
          columns: const ['Name', 'Role'],
          rows: const [
            ['Alice', 'Engineer'],
          ],
          maxHeight: 400,
        )),
      );

      expect(tester.getSize(find.byType(PlinthTable)).height, lessThan(400));
    });

    testWidgets('an empty result still shows the header and empty state',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthTable.text(
          columns: const ['Name', 'Role'],
          filter: 'nobody',
          rows: const [
            ['Alice', 'Engineer'],
          ],
          maxHeight: 200,
          emptyState: const Text('No matches'),
        )),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('No matches'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('sorting a capped table still works', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthTable.text(
          columns: const ['Name'],
          sortable: true,
          rows: const [
            ['Charlie'],
            ['Alice'],
          ],
          maxHeight: 300,
        )),
      );

      await tester.tap(find.text('Name'));
      await tester.pump();

      expect(
        tester.getRect(find.text('Alice')).top,
        lessThan(tester.getRect(find.text('Charlie')).top),
      );
    });
  });

  group('PlinthTable highlightOnHover', () {
    /// The decoration of the row holding [cell], read off the TableRow
    /// rather than the painted output — the colour is the assertion,
    /// and TableRow is where it is set.
    Color? rowColorFor(WidgetTester tester, int row) {
      final table = tester.widgetList<Table>(find.byType(Table)).last;
      return (table.children[row].decoration as BoxDecoration?)?.color;
    }

    testWidgets('tints the row under the pointer and clears on exit',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTable.text(
          columns: ['Name', 'Role'],
          highlightOnHover: true,
          rows: [
            ['Alice', 'Engineer'],
            ['Bob', 'Designer'],
          ],
        )),
      );

      // Row 0 here is the header; body rows follow it.
      expect(rowColorFor(tester, 2), isNull);

      final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: Offset.zero);
      addTearDown(pointer.removePointer);

      await pointer.moveTo(tester.getCenter(find.text('Bob')));
      await tester.pump();
      expect(
        rowColorFor(tester, 2),
        equals(PlinthTheme.defaultTheme.surfaceSunken),
      );
      // Only the row the pointer is on.
      expect(rowColorFor(tester, 1), isNull);

      await pointer.moveTo(const Offset(-100, -100));
      await tester.pump();
      expect(rowColorFor(tester, 2), isNull);
    });

    testWidgets('a hovered striped row is still distinguishable',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTable.text(
          columns: ['Name'],
          striped: true,
          highlightOnHover: true,
          rows: [
            ['Alice'],
            ['Bob'],
          ],
        )),
      );

      final striped = rowColorFor(tester, 2);
      expect(striped, equals(PlinthTheme.defaultTheme.surfaceMuted));

      final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: Offset.zero);
      addTearDown(pointer.removePointer);

      await pointer.moveTo(tester.getCenter(find.text('Bob')));
      await tester.pump();

      expect(rowColorFor(tester, 2), isNot(equals(striped)));
    });

    testWidgets('off by default, so hovering paints nothing', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTable.text(
          columns: ['Name'],
          rows: [
            ['Alice'],
          ],
        )),
      );

      final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: Offset.zero);
      addTearDown(pointer.removePointer);

      await pointer.moveTo(tester.getCenter(find.text('Alice')));
      await tester.pump();

      expect(rowColorFor(tester, 1), isNull);
    });
  });
}
