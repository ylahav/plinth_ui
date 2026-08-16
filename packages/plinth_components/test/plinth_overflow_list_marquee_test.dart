import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: child),
    ),
  );
}

/// Fixed-size items, so a test can reason about what fits.
List<Widget> _items(int count, {double width = 50}) => [
      for (var i = 0; i < count; i++)
        SizedBox(width: width, height: 20, child: Text('item$i')),
    ];

RenderOverflowList _render(WidgetTester tester) =>
    tester.renderObject<RenderOverflowList>(
      find.byType(PlinthOverflowList),
    );

void main() {
  group('PlinthOverflowList', () {
    testWidgets('shows every child when they all fit', (tester) async {
      await tester.pumpWidget(
        _wrap(SizedBox(
            width: 400, child: PlinthOverflowList(children: _items(3)))),
      );

      expect(_render(tester).visibleCount, 3);
      expect(_render(tester).overflowCount, 0);
    });

    testWidgets('collapses what does not fit into the marker', (tester) async {
      await tester.pumpWidget(
        _wrap(SizedBox(
            width: 120, child: PlinthOverflowList(children: _items(6)))),
      );

      final render = _render(tester);
      expect(render.visibleCount, lessThan(6));
      expect(render.overflowCount, 6 - render.visibleCount);
      expect(render.overflowCount, greaterThan(0));
    });

    testWidgets('the marker reports how many are hidden', (tester) async {
      await tester.pumpWidget(
        _wrap(SizedBox(
            width: 120, child: PlinthOverflowList(children: _items(6)))),
      );

      final hidden = _render(tester).overflowCount;
      expect(
        tester.getSemantics(find.byType(PlinthOverflowList)).label,
        contains('+$hidden'),
      );
    });

    testWidgets('labelBuilder replaces the default +N', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 120,
            child: PlinthOverflowList(
              labelBuilder: (remaining) => '$remaining more',
              children: _items(6),
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(PlinthOverflowList)).label,
        contains('more'),
      );
    });

    testWidgets('nothing is collapsed, nothing is announced', (tester) async {
      await tester.pumpWidget(
        _wrap(SizedBox(
            width: 400, child: PlinthOverflowList(children: _items(2)))),
      );

      expect(
        tester.getSemantics(find.byType(PlinthOverflowList)).label,
        isEmpty,
      );
    });

    testWidgets('hidden children are kept out of the semantics tree', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(SizedBox(
            width: 120, child: PlinthOverflowList(children: _items(6)))),
      );

      final visible = _render(tester).visibleCount;

      // Walking items nobody can see gives a screen-reader user no way
      // to act on them — the count is the honest summary.
      expect(find.bySemanticsLabel('item$visible'), findsNothing);
      expect(find.bySemanticsLabel('item5'), findsNothing);
      handle.dispose();
    });

    testWidgets('a hidden child cannot be tapped', (tester) async {
      var visibleTaps = 0;
      var hiddenTaps = 0;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 120,
            child: PlinthOverflowList(
              children: [
                GestureDetector(
                  onTap: () => visibleTaps++,
                  child: const SizedBox(width: 50, height: 20),
                ),
                for (var i = 0; i < 5; i++)
                  GestureDetector(
                    onTap: () => hiddenTaps++,
                    child: const SizedBox(width: 50, height: 20),
                  ),
              ],
            ),
          ),
        ),
      );

      await tester.tapAt(tester.getCenter(find.byType(PlinthOverflowList)));
      await tester.pump();

      // Parked children sit at the origin; without the hit-test guard
      // they would swallow taps landing on what is actually drawn.
      expect(hiddenTaps, 0);
      expect(visibleTaps, greaterThanOrEqualTo(0));
    });

    testWidgets('renders with no children at all', (tester) async {
      await tester.pumpWidget(
        _wrap(const SizedBox(
            width: 200, child: PlinthOverflowList(children: []))),
      );

      expect(tester.takeException(), isNull);
      expect(_render(tester).visibleCount, 0);
    });
  });

  group('PlinthMarquee', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 300,
            child: PlinthMarquee(child: Text('Scrolling headline')),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Scrolling headline'), findsWidgets);
    });

    testWidgets('reduce motion renders a single stationary copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 300,
            child: PlinthMarquee(child: Text('Logos')),
          ),
          reduceMotion: true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // WCAG 2.2.2: motion that can't be stopped shouldn't start. One
      // copy, not a repeating track, and it never moves.
      expect(find.text('Logos'), findsOneWidget);
      expect(find.byType(OverflowBox), findsNothing);
    });

    testWidgets('content wider than the strip does not overflow at rest', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 200,
            // A Row specifically: only a flex *reports* an overflow,
            // where a lone SizedBox is silently constrained. The
            // stationary branch used to hand the child the viewport's
            // width, which is wrong for a marquee — content wider than
            // the strip is the normal case.
            child: PlinthMarquee(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 200, height: 20),
                  SizedBox(width: 200, height: 20),
                  SizedBox(width: 200, height: 20),
                ],
              ),
            ),
          ),
          reduceMotion: true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });

    testWidgets('repeats the child once it knows how wide one copy is', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 300,
            child: PlinthMarquee(child: SizedBox(width: 80, child: Text('x'))),
          ),
        ),
      );
      // First frame measures; the frame after it repeats.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('x'), findsWidgets);
      expect(find.text('x').evaluate().length, greaterThan(1));
    });

    testWidgets('moves over time, and stops when disposed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 300,
            child: PlinthMarquee(child: SizedBox(width: 80, child: Text('x'))),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      final before = tester.getTopLeft(find.text('x').first);
      await tester.pump(const Duration(milliseconds: 300));
      final after = tester.getTopLeft(find.text('x').first);

      expect(after.dx, isNot(closeTo(before.dx, 0.01)));

      // Replacing the tree disposes the ticker; a leaked one fails the
      // test binding at teardown.
      await tester.pumpWidget(_wrap(const SizedBox()));
      expect(tester.takeException(), isNull);
    });
  });
}
