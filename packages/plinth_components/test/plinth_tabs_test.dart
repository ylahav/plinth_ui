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

    testWidgets('renders nothing for a value with no matching child', (tester) async {
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
