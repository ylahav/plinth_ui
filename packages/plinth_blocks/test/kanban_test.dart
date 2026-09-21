// The kanban board.
//
// The point of extracting it is the keyboard route: a board that only
// accepts a drag cannot be operated without a pointer at all.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: child)),
    );

/// The board plus an open menu needs more than the default 800x600.
void _roomy(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

const _columns = [
  PlinthKanbanColumn(id: 'todo', title: 'To do', cards: ['Write tests']),
  PlinthKanbanColumn(id: 'done', title: 'Done', cards: ['Set up CI']),
];

void main() {
  group('PlinthKanbanBoard', () {
    testWidgets('columns and cards render', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthKanbanBoard(columns: _columns, onMove: (_, __, ___) {}),
      ));

      expect(find.text('To do'), findsOneWidget);
      expect(find.text('Write tests'), findsOneWidget);
      expect(find.text('Set up CI'), findsOneWidget);
    });

    testWidgets('a card can be moved without dragging', (tester) async {
      _roomy(tester);
      // WCAG 2.1.1: a drag is a pointer gesture, and a board that only
      // accepts one is unusable by keyboard.
      String? moved;
      String? target;

      await tester.pumpWidget(_wrap(
        PlinthKanbanBoard(
          columns: _columns,
          onMove: (card, from, to) {
            moved = card;
            target = to;
          },
        ),
      ));

      await tester.tap(find.text('Write tests'));
      await tester.pumpAndSettle();

      expect(find.text('Move to Done'), findsOneWidget);

      await tester.tap(find.text('Move to Done'));
      await tester.pumpAndSettle();

      expect(moved, equals('Write tests'));
      expect(target, equals('done'));
    });

    testWidgets('the menu offers every other column, not its own',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthKanbanBoard(
          columns: const [
            PlinthKanbanColumn(id: 'a', title: 'A', cards: ['card']),
            PlinthKanbanColumn(id: 'b', title: 'B', cards: []),
            PlinthKanbanColumn(id: 'c', title: 'C', cards: []),
          ],
          onMove: (_, __, ___) {},
        ),
      ));

      await tester.tap(find.text('card'));
      await tester.pumpAndSettle();

      expect(find.text('Move to B'), findsOneWidget);
      expect(find.text('Move to C'), findsOneWidget);
      expect(find.text('Move to A'), findsNothing);
    });

    testWidgets('a drag still works', (tester) async {
      // The shortcut, not the mechanism — but still the shortcut.
      String? target;

      await tester.pumpWidget(_wrap(
        PlinthKanbanBoard(
          columns: _columns,
          onMove: (card, from, to) => target = to,
        ),
      ));

      await tester.drag(find.text('Write tests'), const Offset(200, 0));
      await tester.pumpAndSettle();

      expect(target, equals('done'));
    });

    testWidgets('a read-only board renders cards but offers no moves',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthKanbanBoard(columns: _columns),
      ));

      expect(find.text('Write tests'), findsOneWidget);

      await tester.tap(find.text('Write tests'));
      await tester.pumpAndSettle();

      expect(find.text('Move to Done'), findsNothing);
    });

    testWidgets('an empty column says so', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthKanbanBoard(
          columns: const [
            PlinthKanbanColumn(id: 'todo', title: 'To do', cards: []),
          ],
          onMove: (_, __, ___) {},
        ),
      ));

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('a move to the same column is not a move', (tester) async {
      var moves = 0;

      await tester.pumpWidget(_wrap(
        PlinthKanbanBoard(
          columns: const [
            PlinthKanbanColumn(id: 'todo', title: 'To do', cards: ['card']),
          ],
          onMove: (_, __, ___) => moves++,
        ),
      ));

      // Only one column, so there is nowhere else to go and no menu.
      await tester.drag(find.text('card'), const Offset(10, 0));
      await tester.pumpAndSettle();

      expect(moves, isZero);
    });
  });
}
