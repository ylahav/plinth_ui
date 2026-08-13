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
  group('PlinthMaskInput', () {
    testWidgets('inserts the mask literals as you type', (tester) async {
      String? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthMaskInput(
            mask: '(###) ###-####',
            onChanged: (v) => reported = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '5551234567');
      await tester.pump();

      expect(reported, '(555) 123-4567');
    });

    testWidgets('rejects characters the mask has no slot for', (tester) async {
      String? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthMaskInput(mask: '###', onChanged: (v) => reported = v),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ab12cd3');
      await tester.pump();

      // Letters are skipped rather than discarding the whole paste.
      expect(reported, '123');
    });

    testWidgets('a partial value stops at what was typed', (tester) async {
      String? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthMaskInput(
            mask: '(###) ###-####',
            onChanged: (v) => reported = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '555');
      await tester.pump();

      expect(reported, '(555');
    });

    testWidgets('letter and wildcard slots', (tester) async {
      String? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthMaskInput(mask: 'AA-**', onChanged: (v) => reported = v),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ab1c');
      await tester.pump();

      expect(reported, 'ab-1c');
    });

    test('unmask strips the literals back out', () {
      expect(
        PlinthMaskInput.unmask('(555) 123-4567', '(###) ###-####'),
        '5551234567',
      );
    });
  });

  group('PlinthJsonInput', () {
    test('isValid accepts empty and well-formed JSON', () {
      expect(PlinthJsonInput.isValid(''), isTrue);
      expect(PlinthJsonInput.isValid('{"a": 1}'), isTrue);
      expect(PlinthJsonInput.isValid('[1, 2]'), isTrue);
      expect(PlinthJsonInput.isValid('{"a": }'), isFalse);
      expect(PlinthJsonInput.isValid('not json'), isFalse);
    });

    test('format pretty-prints, and leaves broken text alone', () {
      expect(PlinthJsonInput.format('{"a":1}'), '{\n  "a": 1\n}');
      expect(PlinthJsonInput.format('{"a":'), '{"a":');
    });

    testWidgets('validates on blur, not on every keystroke', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              PlinthJsonInput(label: 'Payload'),
              PlinthTextInput(label: 'Elsewhere'),
            ],
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, '{"a":');
      await tester.pump();

      // Half-typed JSON is invalid by definition — showing the error
      // now would mean showing it the whole time somebody is writing.
      expect(find.text('Invalid JSON'), findsNothing);

      await tester.tap(find.byType(TextField).last);
      await tester.pumpAndSettle();

      expect(find.text('Invalid JSON'), findsOneWidget);
    });

    testWidgets('formats valid JSON when focus leaves', (tester) async {
      String? reported;
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              PlinthJsonInput(onChanged: (v) => reported = v),
              const PlinthTextInput(label: 'Elsewhere'),
            ],
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, '{"a":1}');
      await tester.tap(find.byType(TextField).last);
      await tester.pumpAndSettle();

      expect(reported, '{\n  "a": 1\n}');
      expect(find.text('Invalid JSON'), findsNothing);
    });

    testWidgets('the caller error outranks the parse error', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              PlinthJsonInput(error: 'Schema mismatch'),
              PlinthTextInput(label: 'Elsewhere'),
            ],
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'nope');
      await tester.tap(find.byType(TextField).last);
      await tester.pumpAndSettle();

      expect(find.text('Schema mismatch'), findsOneWidget);
      expect(find.text('Invalid JSON'), findsNothing);
    });
  });

  group('PlinthFileButton', () {
    testWidgets('reports what the picker returned', (tester) async {
      List<String>? picked;
      await tester.pumpWidget(
        _wrap(
          PlinthFileButton<String>(
            onPick: () async => ['a.png'],
            onChanged: (f) => picked = f,
            child: const Text('Upload'),
          ),
        ),
      );

      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();

      expect(picked, ['a.png']);
    });

    testWidgets('a cancelled pick reports nothing', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthFileButton<String>(
            onPick: () async => null,
            onChanged: (_) => calls++,
            child: const Text('Upload'),
          ),
        ),
      );

      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();

      // Cancelling should not clear a previous selection.
      expect(calls, 0);
    });

    testWidgets('a second tap while picking is ignored', (tester) async {
      var picks = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthFileButton<String>(
            onPick: () async {
              picks++;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              return ['a.png'];
            },
            onChanged: (_) {},
            child: const Text('Upload'),
          ),
        ),
      );

      await tester.tap(find.text('Upload'));
      await tester.pump();
      await tester.tap(find.text('Upload'), warnIfMissed: false);
      await tester.pump();

      // Two open pickers is a state nobody handles.
      expect(picks, 1);
      await tester.pumpAndSettle();
    });
  });

  group('PlinthSplitter', () {
    testWidgets('renders both panes at the initial fraction', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 400,
            height: 200,
            child: PlinthSplitter(
              initialFraction: 0.25,
              first: SizedBox.expand(key: Key('pane'), child: Text('left')),
              second: Text('right'),
            ),
          ),
        ),
      );

      expect(find.text('left'), findsOneWidget);
      expect(find.text('right'), findsOneWidget);

      // 0.25 of the 392px left after the 8px divider.
      expect(
          tester.getSize(find.byKey(const Key('pane'))).width, closeTo(98, 1));
    });

    testWidgets('dragging the divider resizes and reports', (tester) async {
      double? reported;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 400,
            height: 200,
            child: PlinthSplitter(
              onFractionChanged: (f) => reported = f,
              first: const Text('left'),
              second: const Text('right'),
            ),
          ),
        ),
      );

      await tester.drag(find.byKey(const Key('plinth_splitter_divider')),
          const Offset(80, 0));
      await tester.pump();

      expect(reported, isNotNull);
      expect(reported, greaterThan(0.5));
    });

    testWidgets('the drag is clamped so a pane cannot vanish', (tester) async {
      double? reported;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 400,
            height: 200,
            child: PlinthSplitter(
              minFraction: 0.2,
              maxFraction: 0.8,
              onFractionChanged: (f) => reported = f,
              first: const Text('left'),
              second: const Text('right'),
            ),
          ),
        ),
      );

      await tester.drag(find.byKey(const Key('plinth_splitter_divider')),
          const Offset(1000, 0));
      await tester.pump();

      // Otherwise the handle ends up somewhere it can't be grabbed back.
      expect(reported, 0.8);
    });
  });

  group('PlinthScroller', () {
    Widget scroller(ScrollController controller) => _wrap(
          SizedBox(
            height: 300,
            child: PlinthScroller(
              controller: controller,
              child: ListView.builder(
                controller: controller,
                itemCount: 60,
                itemBuilder: (context, i) =>
                    SizedBox(height: 40, child: Text('row $i')),
              ),
            ),
          ),
        );

    testWidgets('appears past the threshold and hides below it', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(scroller(controller));

      double opacity() =>
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

      expect(opacity(), 0);

      controller.jumpTo(400);
      await tester.pumpAndSettle();
      expect(opacity(), 1);

      controller.jumpTo(10);
      await tester.pumpAndSettle();
      expect(opacity(), 0);
    });

    testWidgets('tapping it returns to the top', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(scroller(controller));
      controller.jumpTo(400);
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Back to top'));
      await tester.pumpAndSettle();

      expect(controller.offset, 0);
    });

    testWidgets('the hidden button takes no taps', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(scroller(controller));

      final ignoring = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(IgnorePointer),
        ),
      );
      // Invisible but tappable is worse than absent.
      expect(ignoring.ignoring, isTrue);
    });
  });

  group('PlinthMenubar', () {
    final menus = [
      PlinthMenubarMenu(
        label: 'File',
        items: [PlinthMenuItem(label: 'New', onTap: () {})],
      ),
      PlinthMenubarMenu(
        label: 'Edit',
        items: [PlinthMenuItem(label: 'Undo', onTap: () {})],
      ),
    ];

    testWidgets('renders every top-level label', (tester) async {
      await tester.pumpWidget(_wrap(PlinthMenubar(menus: menus)));

      expect(find.text('File'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('New'), findsNothing);
    });

    testWidgets('tapping opens that menu', (tester) async {
      await tester.pumpWidget(_wrap(PlinthMenubar(menus: menus)));

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();

      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('hovering a sibling while open switches to it', (tester) async {
      await tester.pumpWidget(_wrap(PlinthMenubar(menus: menus)));

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      expect(find.text('New'), findsOneWidget);

      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.text('Edit'))),
      );
      await tester.pumpAndSettle();

      // The behaviour that makes a menubar a menubar: no second click.
      expect(find.text('New'), findsNothing);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('hovering with nothing open opens nothing', (tester) async {
      await tester.pumpWidget(_wrap(PlinthMenubar(menus: menus)));

      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.text('Edit'))),
      );
      await tester.pumpAndSettle();

      // Otherwise merely crossing the bar would open menus.
      expect(find.text('Undo'), findsNothing);
    });
  });

  group('PlinthFloatingWindow', () {
    testWidgets('renders its title and child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 600,
            height: 400,
            child: PlinthFloatingWindow(
              title: 'Inspector',
              child: Text('contents'),
            ),
          ),
        ),
      );

      expect(find.text('Inspector'), findsOneWidget);
      expect(find.text('contents'), findsOneWidget);
    });

    testWidgets('dragging the header moves it and reports', (tester) async {
      Offset? moved;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 600,
            height: 400,
            child: PlinthFloatingWindow(
              title: 'Inspector',
              onMoved: (o) => moved = o,
              child: const Text('contents'),
            ),
          ),
        ),
      );

      final before = tester.getTopLeft(find.text('contents'));
      await tester.drag(find.text('Inspector'), const Offset(60, 40));
      await tester.pump();

      expect(moved, isNotNull);
      expect(
          tester.getTopLeft(find.text('contents')).dx, greaterThan(before.dx));
    });

    testWidgets('it cannot be dragged out of its parent', (tester) async {
      Offset? moved;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 600,
            height: 400,
            child: PlinthFloatingWindow(
              title: 'Inspector',
              initialSize: const Size(200, 150),
              onMoved: (o) => moved = o,
              child: const Text('contents'),
            ),
          ),
        ),
      );

      await tester.drag(find.text('Inspector'), const Offset(5000, 5000));
      await tester.pump();

      // A window whose header lands off-screen can never be dragged back.
      expect(moved!.dx, lessThanOrEqualTo(400));
      expect(moved!.dy, lessThanOrEqualTo(250));
    });

    testWidgets('the close button names the window it closes', (tester) async {
      var closed = 0;
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 600,
            height: 400,
            child: PlinthFloatingWindow(
              title: 'Inspector',
              onClose: () => closed++,
              child: const Text('contents'),
            ),
          ),
        ),
      );

      // Named after its window: "Close" alone is ambiguous once
      // several of these are open at once.
      expect(
        tester.getSemantics(find.byType(PlinthCloseButton)).label,
        contains('Inspector'),
      );

      await tester.tap(find.byType(PlinthCloseButton));
      await tester.pump();

      expect(closed, 1);
    });

    testWidgets('no onClose means no close button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 600,
            height: 400,
            child: PlinthFloatingWindow(title: 'Fixed', child: Text('x')),
          ),
        ),
      );

      expect(find.byType(PlinthCloseButton), findsNothing);
    });
  });
}
