/// `showPlinthModal` and `showPlinthConfirm`: a modal whose answer comes
/// back to the line that asked.
///
/// Found converting a production clinical app, whose thirty dialogs are all
/// `showDialog` + `Navigator.pop(value)`. `PlinthModal` is controller-driven
/// and cannot return a value, so every one of them kept Material's `Dialog`.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _app({
  required Future<void> Function(BuildContext) onOpen,
  LocalizationsDelegate<PlinthLocalizations>? delegate,
}) =>
    MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      localizationsDelegates: delegate == null ? null : [delegate],
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: PlinthButton(
              onPressed: () => onOpen(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('showPlinthModal', () {
    testWidgets('completes with the value it is popped with', (tester) async {
      String? result;
      await tester.pumpWidget(_app(onOpen: (context) async {
        result = await showPlinthModal<String>(
          context,
          title: 'Rename',
          builder: (context) => PlinthButton(
            onPressed: () => Navigator.pop(context, 'new name'),
            child: const Text('save'),
          ),
        );
      }));
      await _open(tester);

      expect(find.text('Rename'), findsOneWidget);
      await tester.tap(find.text('save'));
      await tester.pumpAndSettle();

      expect(result, 'new name');
      expect(find.text('save'), findsNothing);
    });

    testWidgets('the close button completes with null', (tester) async {
      String? result = 'unset';
      await tester.pumpWidget(_app(onOpen: (context) async {
        result = await showPlinthModal<String>(
          context,
          title: 'Rename',
          builder: (_) => const Text('body'),
        );
      }));
      await _open(tester);

      await tester.tap(find.byType(PlinthCloseButton));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('a backdrop tap dismisses it, unless told not to',
        (tester) async {
      var closed = false;
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthModal<void>(
          context,
          closeOnBackdropTap: false,
          builder: (_) => const Text('body'),
        );
        closed = true;
      }));
      await _open(tester);

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();

      expect(closed, isFalse);
      expect(find.text('body'), findsOneWidget);
    });

    testWidgets('Escape dismisses it', (tester) async {
      var closed = false;
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthModal<void>(context, builder: (_) => const Text('b'));
        closed = true;
      }));
      await _open(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });

    testWidgets('fits a phone without overflowing', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthModal<void>(
          context,
          title: 'A title that is long enough to want a second line here',
          size: PlinthSize.xl,
          builder: (_) => const Text('body'),
        );
      }));
      await _open(tester);

      expect(tester.takeException(), isNull);
      final surface = tester.getRect(find.byType(Material).last);
      expect(surface.width, lessThanOrEqualTo(320));
    });

    testWidgets('a modal taller than the screen scrolls and keeps its title',
        (tester) async {
      tester.view.physicalSize = const Size(360, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthModal<void>(
          context,
          title: 'Long form',
          scrollable: true,
          builder: (_) => Column(
            children: [
              for (var i = 0; i < 30; i++)
                SizedBox(height: 40, child: Text('row $i')),
            ],
          ),
        );
      }));
      await _open(tester);

      // Nothing overflowed, the surface stays inside the screen, and the last
      // row is reachable by scrolling.
      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.byType(Material).last).height,
          lessThanOrEqualTo(400));
      expect(find.text('Long form'), findsOneWidget);
      await tester.dragUntilVisible(
        find.text('row 29'),
        find.byType(SingleChildScrollView).last,
        const Offset(0, -80),
      );
      expect(find.text('row 29'), findsOneWidget);
      expect(find.text('Long form'), findsOneWidget);
    });

    testWidgets('unscrollable bodies get bounded height, so Expanded works',
        (tester) async {
      tester.view.physicalSize = const Size(360, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthModal<void>(
          context,
          title: 'List',
          builder: (_) => Column(children: [
            Expanded(
              child: ListView(children: [
                for (var i = 0; i < 30; i++) Text('row $i'),
              ]),
            ),
          ]),
        );
      }));
      await _open(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('row 0'), findsOneWidget);
    });

    testWidgets('keeps a margin from the screen edge', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthModal<void>(context, builder: (_) => const Text('b'));
      }));
      await _open(tester);

      final rect = tester.getRect(find.byType(Material).last);
      expect(rect.left, greaterThan(0));
      expect(rect.right, lessThan(320));
    });

    testWidgets('maxWidth widens it past the largest size', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthModal<void>(
          context,
          size: PlinthSize.xl,
          maxWidth: 1200,
          builder: (_) => const SizedBox(width: 2000, child: Text('wide')),
        );
      }));
      await _open(tester);

      expect(tester.getRect(find.byType(Material).last).width, 1200);
    });

    testWidgets('PlinthModal.show still closes its controller', (tester) async {
      final controller = PlinthDisclosureController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_app(onOpen: (context) async {
        controller.open();
        await PlinthModal(
          controller: controller,
          title: 'Hi',
          child: const Text('body'),
        ).show(context);
      }));
      await _open(tester);
      expect(controller.isOpen, isTrue);

      await tester.tap(find.byType(PlinthCloseButton));
      await tester.pumpAndSettle();

      expect(controller.isOpen, isFalse);
    });
  });

  group('showPlinthConfirm', () {
    testWidgets('confirm completes with true', (tester) async {
      bool? answer;
      await tester.pumpWidget(_app(onOpen: (context) async {
        answer = await showPlinthConfirm(context, title: 'Sure?');
      }));
      await _open(tester);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(answer, isTrue);
    });

    testWidgets('cancel, close, Escape and the backdrop all give false',
        (tester) async {
      final dismissals = <String, Future<void> Function()>{
        'cancel': () => tester.tap(find.text('Cancel')),
        'close button': () => tester.tap(find.byType(PlinthCloseButton)),
        'escape': () => tester.sendKeyEvent(LogicalKeyboardKey.escape),
        'backdrop': () => tester.tapAt(const Offset(4, 4)),
      };
      for (final entry in dismissals.entries) {
        bool? answer;
        await tester.pumpWidget(_app(onOpen: (context) async {
          answer = await showPlinthConfirm(context, title: 'Sure?');
        }));
        await _open(tester);

        await entry.value();
        await tester.pumpAndSettle();

        expect(answer, isFalse, reason: entry.key);
      }
    });

    testWidgets('shows the title and message', (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthConfirm(
          context,
          title: 'Delete station?',
          message: 'Its history goes too.',
        );
      }));
      await _open(tester);

      expect(find.text('Delete station?'), findsOneWidget);
      expect(find.text('Its history goes too.'), findsOneWidget);
    });

    testWidgets('the label the caller gives replaces the default',
        (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthConfirm(context,
            title: 'Sure?', confirmLabel: 'Delete', cancelLabel: 'Keep');
      }));
      await _open(tester);

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);
      expect(find.text('Confirm'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('default labels come from PlinthStrings', (tester) async {
      await tester.pumpWidget(_app(
        delegate: PlinthLocalizations.override(
          const PlinthStrings(cancel: 'Cancelar', confirm: 'Confirmar'),
        ),
        onOpen: (context) async {
          await showPlinthConfirm(context, title: 'Sure?');
        },
      ));
      await tester.pumpAndSettle();
      await _open(tester);

      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);
    });

    testWidgets('destructive paints the confirm button red', (tester) async {
      Color fillOf(String label) => tester
          .widget<Material>(find
              .descendant(
                  of: find.widgetWithText(PlinthButton, label),
                  matching: find.byType(Material))
              .first)
          .color!;

      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthConfirm(context, title: 'Sure?');
      }));
      await _open(tester);
      final normal = fillOf('Confirm');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthConfirm(context, title: 'Sure?', destructive: true);
      }));
      await _open(tester);
      final danger = fillOf('Confirm');

      expect(danger, isNot(normal));
      expect(danger, PlinthTheme.defaultTheme.color('red', 6));
    });

    testWidgets('content can stand in for the message', (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showPlinthConfirm(
          context,
          title: 'Sure?',
          content: const Text('custom body'),
        );
      }));
      await _open(tester);

      expect(find.text('custom body'), findsOneWidget);
    });
  });
}
