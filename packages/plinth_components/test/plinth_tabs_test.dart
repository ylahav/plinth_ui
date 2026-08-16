import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PlinthTabs', () {
    testWidgets('renders every tab label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthTabs<String>(
            value: 'a',
            onChanged: (_) {},
            tabs: const [
              PlinthTabItem('a', 'First'),
              PlinthTabItem('b', 'Second'),
            ],
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('calls onChanged with the tapped tab value', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          PlinthTabs<String>(
            value: 'a',
            onChanged: (v) => selected = v,
            tabs: const [
              PlinthTabItem('a', 'First'),
              PlinthTabItem('b', 'Second'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Second'));
      await tester.pump();

      expect(selected, equals('b'));
    });

    testWidgets('a strip wider than its box scrolls instead of overflowing',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            child: PlinthTabs<String>(
              value: 'a',
              onChanged: (_) {},
              tabs: const [
                PlinthTabItem('a', 'Overview'),
                PlinthTabItem('b', 'Activity'),
                PlinthTabItem('c', 'Settings'),
                PlinthTabItem('d', 'Integrations'),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      // The last tab is off-screen until it is scrolled to, which is
      // the point — it exists rather than being clipped away.
      await tester.scrollUntilVisible(find.text('Integrations'), 100,
          scrollable: find.byType(Scrollable).last);
      expect(find.text('Integrations'), findsOneWidget);
    });

    testWidgets('a strip inside an unbounded row still lays out',
        (tester) async {
      // A header that puts tabs in a `Row` without an `Expanded` hands
      // them unbounded width, which a scroll viewport cannot take.
      await tester.pumpWidget(
        _wrap(
          Row(
            children: [
              PlinthTabs<String>(
                value: 'a',
                onChanged: (_) {},
                tabs: const [
                  PlinthTabItem('a', 'First'),
                  PlinthTabItem('b', 'Second'),
                ],
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Second'), findsOneWidget);
    });
  });

  group('PlinthTabView', () {
    testWidgets('shows the child matching value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTabView<String>(
            value: 'b',
            children: {
              'a': Text('Panel A'),
              'b': Text('Panel B'),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Panel B'), findsOneWidget);
      expect(find.text('Panel A'), findsNothing);
    });

    testWidgets('renders nothing for a value with no matching child',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTabView<String>(
            value: 'missing',
            children: {'a': Text('Panel A')},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not throw, and should render no panel text.
      expect(find.text('Panel A'), findsNothing);
    });
  });
}
