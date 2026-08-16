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
  group('PlinthContainer', () {
    testWidgets('renders its child', (tester) async {
      await tester
          .pumpWidget(_wrap(const PlinthContainer(child: Text('Content'))));

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('constrains width to the size preset', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthContainer(
            size: PlinthContainerSize.xs,
            child: Container(
                key: const Key('inner'), color: Colors.red, height: 10),
          ),
        ),
      );

      final size = tester.getSize(find.byKey(const Key('inner')));
      // xs max-width is 540, minus default md padding (16) on each side.
      expect(size.width, lessThanOrEqualTo(540));
    });
  });

  group('PlinthSpace', () {
    testWidgets('reserves the given height', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Above'),
              PlinthSpace(h: PlinthSize.lg),
              Text('Below'),
            ],
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('Above'), findsOneWidget);
      expect(find.text('Below'), findsOneWidget);
    });
  });

  group('PlinthUnstyledButton', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthUnstyledButton(
            onPressed: () {}, child: const Text('Custom'))),
      );

      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          PlinthUnstyledButton(
              onPressed: () => tapped = true, child: const Text('Custom')),
        ),
      );

      await tester.tap(find.text('Custom'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('is marked as a button for accessibility', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthUnstyledButton(
            onPressed: () {}, child: const Text('Custom'))),
      );

      final semantics = tester.getSemantics(find.text('Custom'));
      expect(semantics.flagsCollection.isButton, isTrue);
    });
  });

  group('PlinthSimpleGrid', () {
    testWidgets('renders every child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthSimpleGrid(
            columns: 2,
            children: [Text('One'), Text('Two'), Text('Three')],
          ),
        ),
      );

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);
    });

    testWidgets('divides available width evenly across columns',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 300,
            child: PlinthSimpleGrid(
              columns: 3,
              spacing: PlinthSize.md,
              children: [
                Container(key: const Key('cell'), height: 10),
                Container(height: 10),
                Container(height: 10),
              ],
            ),
          ),
        ),
      );

      final theme = PlinthTheme.defaultTheme;
      final gap = theme.spacing[PlinthSize.md]!;
      final expectedWidth = (300 - gap * 2) / 3;
      final size = tester.getSize(find.byKey(const Key('cell')));
      expect(size.width, closeTo(expectedWidth, 0.5));
    });

    testWidgets('per-breakpoint counts apply from that width upward',
        (tester) async {
      // 700 clears xs (576) but not md (992), so the xs count wins
      // over both the base and the wider md.
      const grid = PlinthSimpleGrid(
        columns: 1,
        columnsXs: 2,
        columnsMd: 4,
        children: [Text('a')],
      );

      expect(grid.columnsFor(400), 1);
      expect(grid.columnsFor(700), 2);
      expect(grid.columnsFor(1000), 4);
    });

    testWidgets('a breakpoint count changes how wide each cell is',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 300,
            child: PlinthSimpleGrid(
              columns: 1,
              columnsMd: 3,
              spacing: PlinthSize.md,
              children: [
                Container(key: const Key('narrow'), height: 10),
                Container(height: 10),
              ],
            ),
          ),
        ),
      );

      // 300 is below every breakpoint, so the base count of 1 applies
      // and the cell takes the full width rather than a third of it.
      expect(
        tester.getSize(find.byKey(const Key('narrow'))).width,
        closeTo(300, 0.5),
      );
    });

    testWidgets('an unqualified count still applies at every width',
        (tester) async {
      // Guards the existing callers: adding breakpoints must not
      // change what `columns: 3` on its own means.
      const grid = PlinthSimpleGrid(columns: 3, children: [Text('a')]);

      expect(grid.columnsFor(320), 3);
      expect(grid.columnsFor(1600), 3);
    });
  });
}
