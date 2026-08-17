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
  group('PlinthPagination', () {
    testWidgets('renders every page number when total is small',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPagination(page: 1, total: 5, onChanged: (_) {})),
      );

      for (var i = 1; i <= 5; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
      expect(find.text('…'), findsNothing);
    });

    testWidgets('collapses into an ellipsis for large totals', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPagination(page: 10, total: 20, onChanged: (_) {})),
      );

      // Page 1 and the last page should always be visible.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      // Current page and its immediate neighbors.
      expect(find.text('9'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      // Far-away pages should not be rendered.
      expect(find.text('5'), findsNothing);
      expect(find.text('15'), findsNothing);
      // Two ellipses — one on each side of the current-page cluster.
      expect(find.text('…'), findsNWidgets(2));
    });

    testWidgets('tapping a page number calls onChanged with that page',
        (tester) async {
      int? changed;
      await tester.pumpWidget(
        _wrap(
            PlinthPagination(page: 1, total: 5, onChanged: (p) => changed = p)),
      );

      await tester.tap(find.text('3'));
      await tester.pump();

      expect(changed, equals(3));
    });

    testWidgets('previous button is disabled on the first page',
        (tester) async {
      int? changed;
      await tester.pumpWidget(
        _wrap(
            PlinthPagination(page: 1, total: 5, onChanged: (p) => changed = p)),
      );

      await tester.tap(find.byIcon(Icons.chevron_left), warnIfMissed: false);
      await tester.pump();

      expect(changed, isNull);
    });

    testWidgets('next button is disabled on the last page', (tester) async {
      int? changed;
      await tester.pumpWidget(
        _wrap(
            PlinthPagination(page: 5, total: 5, onChanged: (p) => changed = p)),
      );

      await tester.tap(find.byIcon(Icons.chevron_right), warnIfMissed: false);
      await tester.pump();

      expect(changed, isNull);
    });

    testWidgets('next button advances the page', (tester) async {
      int? changed;
      await tester.pumpWidget(
        _wrap(
            PlinthPagination(page: 2, total: 5, onChanged: (p) => changed = p)),
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(changed, equals(3));
    });

    testWidgets('handles total of 1 without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPagination(page: 1, total: 1, onChanged: (_) {})),
      );

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('withEdges is off by default', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPagination(page: 5, total: 20, onChanged: (_) {})),
      );

      expect(find.byIcon(Icons.first_page), findsNothing);
      expect(find.byIcon(Icons.last_page), findsNothing);
    });

    testWidgets('withEdges jumps to the first and last page', (tester) async {
      int? changed;
      await tester.pumpWidget(
        _wrap(PlinthPagination(
          page: 10,
          total: 20,
          withEdges: true,
          onChanged: (p) => changed = p,
        )),
      );

      await tester.tap(find.byIcon(Icons.first_page));
      await tester.pump();
      expect(changed, equals(1));

      await tester.tap(find.byIcon(Icons.last_page));
      await tester.pump();
      expect(changed, equals(20));
    });

    testWidgets('the edge controls are dead at the ends of the range',
        (tester) async {
      int? changed;
      await tester.pumpWidget(
        _wrap(PlinthPagination(
          page: 1,
          total: 20,
          withEdges: true,
          onChanged: (p) => changed = p,
        )),
      );

      await tester.tap(find.byIcon(Icons.first_page));
      await tester.pump();

      // Already on page 1 — there is nowhere to jump to, and firing
      // onChanged(1) would be a spurious rebuild of the same page.
      expect(changed, isNull);
    });

    testWidgets('a null onChanged silences every control', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthPagination(
          page: 3,
          total: 20,
          withEdges: true,
          onChanged: null,
        )),
      );

      for (final icon in [
        Icons.first_page,
        Icons.chevron_left,
        Icons.chevron_right,
        Icons.last_page,
      ]) {
        await tester.tap(find.byIcon(icon));
      }
      await tester.tap(find.text('2'));
      await tester.pump();

      // Nothing to assert beyond "didn't throw and had nowhere to
      // report to" — a null callback is how this library spells
      // disabled.
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('radius reaches the cells it is given to', (tester) async {
      // It was an accepted-and-ignored prop until 0.22.0: the cells
      // hardcoded a 4, which happens to equal the default theme's
      // `sm`, so nothing looked wrong and nothing worked either.
      double cellRadius(WidgetTester tester) {
        final container = tester
            .widgetList<Container>(find.descendant(
              of: find.byType(PlinthPagination),
              matching: find.byType(Container),
            ))
            .first;
        final decoration = container.decoration! as BoxDecoration;
        return decoration.borderRadius!.resolve(null).topLeft.x;
      }

      await tester.pumpWidget(
        _wrap(PlinthPagination(page: 1, total: 5, onChanged: (_) {})),
      );
      expect(
        cellRadius(tester),
        PlinthTheme.defaultTheme.radius[PlinthTheme.defaultTheme.defaultRadius],
      );

      await tester.pumpWidget(
        _wrap(PlinthPagination(
          page: 1,
          total: 5,
          radius: PlinthSize.xl,
          onChanged: (_) {},
        )),
      );
      expect(
          cellRadius(tester), PlinthTheme.defaultTheme.radius[PlinthSize.xl]);
    });
  });
}
