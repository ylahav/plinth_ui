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
  });
}
