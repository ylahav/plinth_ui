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
  group('PlinthAccordion', () {
    testWidgets('renders every item title, content hidden by default',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAccordion(
            items: const [
              PlinthAccordionItem(
                  value: 'a', title: 'First', content: Text('Content A')),
              PlinthAccordionItem(
                  value: 'b', title: 'Second', content: Text('Content B')),
            ],
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Content A'), findsNothing);
      expect(find.text('Content B'), findsNothing);
    });

    testWidgets('tapping a title reveals its content', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAccordion(
            items: const [
              PlinthAccordionItem(
                  value: 'a', title: 'First', content: Text('Content A')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();

      expect(find.text('Content A'), findsOneWidget);
    });

    testWidgets('single-open mode closes the previous item', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAccordion(
            items: const [
              PlinthAccordionItem(
                  value: 'a', title: 'First', content: Text('Content A')),
              PlinthAccordionItem(
                  value: 'b', title: 'Second', content: Text('Content B')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      expect(find.text('Content A'), findsOneWidget);

      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      expect(find.text('Content A'), findsNothing);
      expect(find.text('Content B'), findsOneWidget);
    });

    testWidgets('multiple mode keeps both items open', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAccordion(
            multiple: true,
            items: const [
              PlinthAccordionItem(
                  value: 'a', title: 'First', content: Text('Content A')),
              PlinthAccordionItem(
                  value: 'b', title: 'Second', content: Text('Content B')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      expect(find.text('Content A'), findsOneWidget);
      expect(find.text('Content B'), findsOneWidget);
    });

    testWidgets('tapping an open item closes it again', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAccordion(
            items: const [
              PlinthAccordionItem(
                  value: 'a', title: 'First', content: Text('Content A')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      expect(find.text('Content A'), findsOneWidget);

      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      expect(find.text('Content A'), findsNothing);
    });

    testWidgets('respects initiallyOpen', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAccordion(
            initiallyOpen: const {'a'},
            items: const [
              PlinthAccordionItem(
                  value: 'a', title: 'First', content: Text('Content A')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Content A'), findsOneWidget);
    });
  });
}
