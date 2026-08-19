// B1 — focus containment for the overlays Flutter does not contain.
//
// A route gets a FocusScope for free, so Modal and Drawer were already
// fine. An OverlayEntry shares the page's scope, so Popover, Menu and
// everything built on them leaked: the first Tab landed on content
// behind the panel, which the user cannot see.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

/// Opens [overlay] over a page that has its own focusable control, then
/// reports whether Tab ever reaches that control.
Future<({bool escaped, bool opened})> _probe(
  WidgetTester tester,
  Widget Function(PlinthDisclosureController) overlay, {
  int tabs = 10,
}) async {
  final controller = PlinthDisclosureController();
  final behind = FocusNode(debugLabel: 'BEHIND');
  addTearDown(behind.dispose);

  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(
      body: Column(children: [
        TextButton(
            focusNode: behind, onPressed: () {}, child: const Text('BEHIND')),
        overlay(controller),
      ]),
    ),
  ));
  await tester.pumpAndSettle();
  controller.open();
  await tester.pumpAndSettle();

  // Without this, "focus escaped" would also be the result for an
  // overlay that never opened — which is how the first version of this
  // probe reported a false failure for Modal and Drawer.
  if (find.text('inside').evaluate().isEmpty) {
    return (escaped: false, opened: false);
  }

  for (var i = 0; i < tabs; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    if (behind.hasFocus) return (escaped: true, opened: true);
  }
  return (escaped: false, opened: true);
}

void main() {
  group('B1 — overlays contain keyboard focus', () {
    testWidgets('Popover', (tester) async {
      final r = await _probe(
          tester,
          (c) => PlinthPopover(
                controller: c,
                target: const Text('t'),
                content:
                    TextButton(onPressed: () {}, child: const Text('inside')),
              ));
      expect(r.opened, isTrue);
      expect(r.escaped, isFalse);
    });

    testWidgets('Menu, which is built on Popover', (tester) async {
      final r = await _probe(
          tester,
          (c) => PlinthMenu(
                controller: c,
                target: const Text('t'),
                items: [
                  PlinthMenuItem(label: 'inside', onTap: () {}),
                  PlinthMenuItem(label: 'second', onTap: () {}),
                ],
              ));
      expect(r.opened, isTrue);
      expect(r.escaped, isFalse);
    });

    testWidgets('Modal was already contained by its route', (tester) async {
      // Recorded so the roadmap's claim stays checked rather than
      // assumed — and so nobody adds a second trap here.
      final r = await _probe(
          tester,
          (c) => PlinthModalHost(
                modal: PlinthModal(
                  controller: c,
                  title: 'M',
                  child:
                      TextButton(onPressed: () {}, child: const Text('inside')),
                ),
                child: const SizedBox(),
              ));
      expect(r.opened, isTrue);
      expect(r.escaped, isFalse);
    });

    testWidgets('Drawer was already contained too', (tester) async {
      // The roadmap scheduled Drawer as the *first* place to build the
      // trap. It uses showGeneralDialog like Modal and never needed one.
      final r = await _probe(
          tester,
          (c) => PlinthDrawerHost(
                drawer: PlinthDrawer(
                  controller: c,
                  title: 'D',
                  child:
                      TextButton(onPressed: () {}, child: const Text('inside')),
                ),
                child: const SizedBox(),
              ));
      expect(r.opened, isTrue);
      expect(r.escaped, isFalse);
    });
  });

  group('PlinthFocusTrap', () {
    testWidgets('Escape calls onEscape', (tester) async {
      var escapes = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlinthFocusTrap(
            onEscape: () => escapes++,
            child: TextButton(onPressed: () {}, child: const Text('inside')),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(escapes, 1);
    });

    testWidgets('focus goes back to the trigger when the trap closes',
        (tester) async {
      // The half a trap is usually missing: closing a menu should not
      // drop the user at the top of the page.
      final controller = PlinthDisclosureController();
      final trigger = FocusNode(debugLabel: 'TRIGGER');
      addTearDown(trigger.dispose);

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: Scaffold(
          body: PlinthPopover(
            controller: controller,
            target: TextButton(
                focusNode: trigger, onPressed: () {}, child: const Text('t')),
            content: TextButton(onPressed: () {}, child: const Text('inside')),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      trigger.requestFocus();
      await tester.pumpAndSettle();
      expect(trigger.hasFocus, isTrue);

      controller.open();
      await tester.pumpAndSettle();
      expect(trigger.hasFocus, isFalse, reason: 'focus moved into the panel');

      controller.close();
      await tester.pumpAndSettle();
      expect(trigger.hasFocus, isTrue, reason: 'focus handed back');
    });
  });
}
