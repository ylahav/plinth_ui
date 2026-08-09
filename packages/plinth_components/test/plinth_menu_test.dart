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
  group('PlinthMenu', () {
    testWidgets('items are not visible before the controller opens',
        (tester) async {
      final controller = PlinthDisclosureController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          PlinthMenu(
            controller: controller,
            target: const Icon(Icons.more_vert),
            items: [PlinthMenuItem(label: 'Edit', onTap: () {})],
          ),
        ),
      );

      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('items appear once the controller opens', (tester) async {
      final controller = PlinthDisclosureController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          PlinthMenu(
            controller: controller,
            target: const Icon(Icons.more_vert),
            items: [PlinthMenuItem(label: 'Edit', onTap: () {})],
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('tapping an item fires its onTap and closes the controller',
        (tester) async {
      final controller = PlinthDisclosureController();
      addTearDown(controller.dispose);
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          PlinthMenu(
            controller: controller,
            target: const Icon(Icons.more_vert),
            items: [PlinthMenuItem(label: 'Edit', onTap: () => tapped = true)],
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      expect(controller.isOpen, isFalse);
    });

    testWidgets('tapping the target toggles the controller', (tester) async {
      final controller = PlinthDisclosureController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          PlinthMenu(
            controller: controller,
            target: const Icon(Icons.more_vert),
            items: [PlinthMenuItem(label: 'Edit', onTap: () {})],
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(controller.isOpen, isTrue);
      expect(find.text('Edit'), findsOneWidget);
    });
  });
}
