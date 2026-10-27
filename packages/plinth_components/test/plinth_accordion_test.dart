import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

    group('header items', () {
      Widget accordion(List<String> taps) => _wrap(
            PlinthAccordion(
              items: [
                for (final v in ['a', 'b'])
                  PlinthAccordionItem(
                    value: v,
                    toggleLabel: 'Show $v',
                    header: TextButton(
                      onPressed: () => taps.add(v),
                      child: Text('Header $v'),
                    ),
                    content: Text('Content $v'),
                  ),
              ],
            ),
          );

      testWidgets('tapping the header runs its own control, not the toggle',
          (tester) async {
        final taps = <String>[];
        await tester.pumpWidget(accordion(taps));

        await tester.tap(find.text('Header a'));
        await tester.pumpAndSettle();

        expect(taps, ['a']);
        expect(find.text('Content a'), findsNothing);
      });

      testWidgets('the chevron toggles, one at a time', (tester) async {
        await tester.pumpWidget(accordion([]));

        await tester.tap(find.bySemanticsLabel('Show a'));
        await tester.pumpAndSettle();
        expect(find.text('Content a'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Show b'));
        await tester.pumpAndSettle();
        expect(find.text('Content a'), findsNothing);
        expect(find.text('Content b'), findsOneWidget);

        await tester.tap(find.bySemanticsLabel('Show b'));
        await tester.pumpAndSettle();
        expect(find.text('Content b'), findsNothing);
      });

      testWidgets('the chevron is a button that reports expanded',
          (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(accordion([]));

        SemanticsNode node() =>
            tester.getSemantics(find.bySemanticsLabel('Show a'));
        expect(node().flagsCollection.isButton, isTrue);
        expect(node().flagsCollection.isExpanded, Tristate.isFalse);

        await tester.tap(find.bySemanticsLabel('Show a'));
        await tester.pumpAndSettle();
        expect(node().flagsCollection.isExpanded, Tristate.isTrue);
        handle.dispose();
      });

      test('an item needs exactly one of title and header', () {
        expect(
          () => PlinthAccordionItem(value: 'x', content: const SizedBox()),
          throwsAssertionError,
        );
        expect(
          () => PlinthAccordionItem(
            value: 'x',
            title: 't',
            header: const SizedBox(),
            content: const SizedBox(),
          ),
          throwsAssertionError,
        );
      });
    });
  });
}
