import 'dart:ui' show PointerDeviceKind;

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
  group('PlinthBurger', () {
    testWidgets('renders without throwing in both states', (tester) async {
      await tester
          .pumpWidget(_wrap(PlinthBurger(opened: false, onPressed: () {})));
      expect(find.byType(PlinthBurger), findsOneWidget);

      await tester
          .pumpWidget(_wrap(PlinthBurger(opened: true, onPressed: () {})));
      await tester.pumpAndSettle();
      expect(find.byType(PlinthBurger), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PlinthBurger(opened: false, onPressed: () => tapped = true)),
      );

      await tester.tap(find.byType(PlinthBurger));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does nothing when onPressed is null', (tester) async {
      await tester.pumpWidget(
          _wrap(const PlinthBurger(opened: false, onPressed: null)));

      await tester.tap(find.byType(PlinthBurger), warnIfMissed: false);
      await tester.pump();
      // No assertion beyond "didn't throw" — null onPressed should
      // simply make the burger non-interactive.
    });
  });

  group('PlinthRangeSlider', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthRangeSlider(
            values: const RangeValues(20, 80),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(RangeSlider), findsOneWidget);
    });

    testWidgets('renders disabled without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthRangeSlider(
            values: RangeValues(20, 80),
            onChanged: null,
          ),
        ),
      );

      expect(find.byType(RangeSlider), findsOneWidget);
    });
  });

  group('PlinthHoverCard', () {
    testWidgets('renders only the target by default (card not shown)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthHoverCard(
            target: const Text('Hover me'),
            content: const Text('Card content'),
          ),
        ),
      );

      expect(find.text('Hover me'), findsOneWidget);
      expect(find.text('Card content'), findsNothing);
    });

    testWidgets('an open card follows content replaced underneath it', (
      tester,
    ) async {
      Widget card(String body) => _wrap(
            Center(
              child: PlinthHoverCard(
                target: const Text('Hover me'),
                content: Text(body),
              ),
            ),
          );

      await tester.pumpWidget(card('First'));

      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.text('Hover me'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);

      // The card lives in an OverlayEntry, which doesn't rebuild just
      // because this widget did — content arriving after the pointer
      // does is exactly what a hover card is usually for.
      await tester.pumpWidget(card('Second'));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
    });
  });

  group('PlinthMenu overlay refresh', () {
    testWidgets('an open menu follows items replaced underneath it', (
      tester,
    ) async {
      final controller = PlinthDisclosureController();
      addTearDown(controller.dispose);

      Widget menu(String label) => _wrap(
            Center(
              child: PlinthMenu(
                controller: controller,
                target: PlinthButton(
                  onPressed: controller.toggle,
                  child: const Text('Open'),
                ),
                items: [PlinthMenuItem(label: label, onTap: () {})],
              ),
            ),
          );

      await tester.pumpWidget(menu('First'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);

      // PlinthMenu is stateless and delegates to PlinthPopover, so it
      // inherits the popover's refresh rather than needing its own.
      await tester.pumpWidget(menu('Second'));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
    });
  });
}
