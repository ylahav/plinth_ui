import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

/// Hosts an overlay component alongside a controller the test drives,
/// disposing it the way any real caller must.
class _Host extends StatefulWidget {
  const _Host({required this.builder});

  final Widget Function(PlinthDisclosureController controller) builder;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final controller = PlinthDisclosureController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(controller);
}

PlinthDisclosureController _controllerOf(WidgetTester tester) {
  return tester.state<_HostState>(find.byType(_Host)).controller;
}

void main() {
  final theme = PlinthTheme.defaultTheme;

  group('PlinthAlert', () {
    testWidgets('renders its title and body', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthAlert(
            title: 'Heads up',
            child: Text('Your changes were saved.'),
          ),
        ),
      );

      expect(find.text('Heads up'), findsOneWidget);
      expect(find.text('Your changes were saved.'), findsOneWidget);
    });

    testWidgets('renders without a title', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthAlert(child: Text('Body only'))),
      );

      expect(find.text('Body only'), findsOneWidget);
    });

    testWidgets('shows no close button unless onClose is given',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthAlert(child: Text('Body'))),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('a non-null onClose shows a close button that fires',
        (tester) async {
      var closed = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthAlert(onClose: () => closed++, child: const Text('Body')),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));

      expect(closed, 1);
    });

    testWidgets('defaults to blue rather than the theme primary',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthAlert(child: Text('Body'))),
      );

      // Deliberate: a feedback banner rendering in the brand colour
      // regardless of intent would be a worse default than a
      // conventional blue, so `color` is non-nullable here.
      final decoration = tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byType(PlinthAlert),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration! as BoxDecoration;
      expect(decoration.color, theme.color('blue', 0));
    });

    testWidgets('tints its background with the given color', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthAlert(color: 'red', child: Text('Body'))),
      );

      final decoration = tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byType(PlinthAlert),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration! as BoxDecoration;
      expect(decoration.color, theme.color('red', 0));
    });

    testWidgets('renders an icon when given one', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthAlert(
            icon: Icon(Icons.info_outline),
            child: Text('Body'),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  group('PlinthModal', () {
    testWidgets('renders nothing until the controller opens', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthModalHost(
              modal: PlinthModal(
                controller: controller,
                title: 'Confirm',
                child: const Text('Modal body'),
              ),
              child: const Text('Page'),
            ),
          ),
        ),
      );

      // The modal is route-based, so the host renders only its child
      // until something opens the controller.
      expect(find.text('Page'), findsOneWidget);
      expect(find.text('Modal body'), findsNothing);
    });

    testWidgets('the host shows it when the controller opens', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthModalHost(
              modal: PlinthModal(
                controller: controller,
                title: 'Confirm',
                child: const Text('Modal body'),
              ),
              child: const Text('Page'),
            ),
          ),
        ),
      );

      _controllerOf(tester).open();
      await tester.pumpAndSettle();

      expect(find.text('Modal body'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('the close button dismisses it and syncs the controller',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthModalHost(
              modal: PlinthModal(
                controller: controller,
                title: 'Confirm',
                child: const Text('Modal body'),
              ),
              child: const Text('Page'),
            ),
          ),
        ),
      );

      final controller = _controllerOf(tester);
      controller.open();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Modal body'), findsNothing);
      // Dismissing through the UI has to leave the controller closed,
      // or the next open() would be a no-op against stale state.
      expect(controller.isOpen, isFalse);
    });

    testWidgets('a backdrop tap dismisses it when allowed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthModalHost(
              modal: PlinthModal(
                controller: controller,
                child: const Text('Modal body'),
              ),
              child: const Text('Page'),
            ),
          ),
        ),
      );

      final controller = _controllerOf(tester);
      controller.open();
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Modal body'), findsNothing);
      expect(controller.isOpen, isFalse);
    });

    testWidgets('closeOnBackdropTap: false keeps it open', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthModalHost(
              modal: PlinthModal(
                controller: controller,
                closeOnBackdropTap: false,
                child: const Text('Modal body'),
              ),
              child: const Text('Page'),
            ),
          ),
        ),
      );

      _controllerOf(tester).open();
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Modal body'), findsOneWidget);
    });
  });

  group('PlinthDrawer', () {
    testWidgets('renders nothing until the controller opens', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthDrawerHost(
              drawer: PlinthDrawer(
                controller: controller,
                title: 'Filters',
                child: const Text('Drawer body'),
              ),
              child: const Text('Page'),
            ),
          ),
        ),
      );

      expect(find.text('Drawer body'), findsNothing);
    });

    testWidgets('the host shows it when the controller opens', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthDrawerHost(
              drawer: PlinthDrawer(
                controller: controller,
                title: 'Filters',
                child: const Text('Drawer body'),
              ),
              child: const Text('Page'),
            ),
          ),
        ),
      );

      _controllerOf(tester).open();
      await tester.pumpAndSettle();

      expect(find.text('Drawer body'), findsOneWidget);
      expect(find.text('Filters'), findsOneWidget);
    });

    testWidgets('every position opens', (tester) async {
      for (final position in PlinthDrawerPosition.values) {
        await tester.pumpWidget(
          _wrap(
            _Host(
              builder: (controller) => PlinthDrawerHost(
                drawer: PlinthDrawer(
                  controller: controller,
                  position: position,
                  child: Text('Drawer ${position.name}'),
                ),
                child: const Text('Page'),
              ),
            ),
          ),
        );

        _controllerOf(tester).open();
        await tester.pumpAndSettle();

        expect(find.text('Drawer ${position.name}'), findsOneWidget);

        // Leave the route popped so the next iteration starts clean.
        _controllerOf(tester).close();
        await tester.pumpAndSettle();
      }
    });
  });

  group('PlinthPopover', () {
    testWidgets('shows its target and hides its content until opened',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthPopover(
              controller: controller,
              target: const Text('Trigger'),
              content: const Text('Popover body'),
            ),
          ),
        ),
      );

      expect(find.text('Trigger'), findsOneWidget);
      expect(find.text('Popover body'), findsNothing);
    });

    testWidgets('tapping the target opens it', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthPopover(
              controller: controller,
              target: const Text('Trigger'),
              content: const Text('Popover body'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Popover body'), findsOneWidget);
    });

    testWidgets('repeated open/close cycles leave no stacked overlays',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthPopover(
              controller: controller,
              target: const Text('Trigger'),
              content: const Text('Popover body'),
            ),
          ),
        ),
      );

      final controller = _controllerOf(tester);
      for (var i = 0; i < 3; i++) {
        controller.open();
        await tester.pumpAndSettle();
        controller.close();
        await tester.pumpAndSettle();
      }

      controller.open();
      await tester.pumpAndSettle();

      // A _hide() missed on any cycle would leave an extra OverlayEntry
      // behind, and the content would be found more than once.
      expect(find.text('Popover body'), findsOneWidget);

      controller.close();
      await tester.pumpAndSettle();
    });

    testWidgets('removes its overlay entry when disposed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _Host(
            builder: (controller) => PlinthPopover(
              controller: controller,
              target: const Text('Trigger'),
              content: const Text('Popover body'),
            ),
          ),
        ),
      );

      _controllerOf(tester).open();
      await tester.pumpAndSettle();

      await tester.pumpWidget(_wrap(const Text('Replaced')));
      await tester.pumpAndSettle();

      expect(find.text('Popover body'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
