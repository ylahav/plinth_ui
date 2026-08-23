// Everything that can be activated must be reachable by keyboard.
//
// Found by ear, not by any test here: PlinthAnchor was
// `Semantics(link: true) > GestureDetector`, which supplies a tap
// *action* but no focus node. A mouse could click it and a screen
// reader could activate it in browse mode, while Tab walked straight
// past — WCAG 2.1.1. PlinthUnstyledButton had the identical shape, and
// worse for being named a button.
//
// Neither existing check could see it. NVDA's elements list showed the
// link, because the semantics were there; B0c tested that Tab-reachable
// controls are *named*, not that everything actionable is reachable.
// This is the missing direction.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// The interactive components, including several that were already
/// right — a sweep is only worth having if it would notice a
/// regression in the ones nobody is currently worried about.
final Map<String, Widget Function(VoidCallback onTap)> _interactive = {
  'PlinthAnchor': (onTap) => PlinthAnchor('Send a new code', onTap: onTap),
  'PlinthUnstyledButton': (onTap) => PlinthUnstyledButton(
        onPressed: onTap,
        child: const Text('custom'),
      ),
  'PlinthButton': (onTap) =>
      PlinthButton(onPressed: onTap, child: const Text('Verify')),
  'PlinthActionIcon': (onTap) => PlinthActionIcon(
        icon: const Icon(Icons.edit),
        onPressed: onTap,
        semanticLabel: 'Edit',
      ),
  'PlinthCloseButton': (onTap) =>
      PlinthCloseButton(onPressed: onTap, semanticLabel: 'Close'),
  'PlinthNavLink': (onTap) => PlinthNavLink(label: 'Home', onTap: onTap),
};

/// Pumps [child] between two text fields, focuses the first, and
/// reports what a single Tab reaches.
Future<String> _tabFrom(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'before')),
            child,
            const TextField(decoration: InputDecoration(labelText: 'after')),
          ],
        ),
      ),
    ),
  );

  await tester.tap(find.byType(TextField).first);
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();

  final context = FocusManager.instance.primaryFocus?.context;
  var landed = 'nothing';
  context?.visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is TextField) {
      landed = 'the ${widget.decoration?.labelText} field';
      return false;
    }
    return true;
  });
  return landed;
}

void main() {
  group('a single Tab reaches the control, not past it', () {
    for (final entry in _interactive.entries) {
      testWidgets(entry.key, (tester) async {
        final landed = await _tabFrom(tester, entry.value(() {}));

        expect(landed, isNot('the after field'),
            reason: 'Tab skipped ${entry.key} entirely, so a keyboard '
                'user can never operate it — WCAG 2.1.1. Anything with '
                'an onTap needs a focus node, not only a tap action');
      });
    }
  });

  group('and the keys that activate it work', () {
    /// Tabs onto [child] and presses [key].
    Future<int> _press(
      WidgetTester tester,
      Widget Function(VoidCallback) build,
      LogicalKeyboardKey key,
    ) async {
      var taps = 0;
      await _tabFrom(tester, build(() => taps++));
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
      return taps;
    }

    testWidgets('PlinthAnchor takes Enter', (tester) async {
      expect(
        await _press(
            tester, _interactive['PlinthAnchor']!, LogicalKeyboardKey.enter),
        1,
      );
    });

    testWidgets('PlinthAnchor takes Space', (tester) async {
      expect(
        await _press(
            tester, _interactive['PlinthAnchor']!, LogicalKeyboardKey.space),
        1,
      );
    });

    testWidgets('PlinthUnstyledButton takes Enter', (tester) async {
      expect(
        await _press(tester, _interactive['PlinthUnstyledButton']!,
            LogicalKeyboardKey.enter),
        1,
      );
    });

    testWidgets('PlinthUnstyledButton takes Space', (tester) async {
      expect(
        await _press(tester, _interactive['PlinthUnstyledButton']!,
            LogicalKeyboardKey.space),
        1,
      );
    });

    // The web is the platform this library is demoed on, and it routes
    // Enter to ButtonActivateIntent rather than ActivateIntent. That
    // map is chosen by `kIsWeb` and cannot be switched on in a test, so
    // the intent is invoked directly: handling only one of the two
    // would leave a key dead on some platform and nothing else here
    // would notice.
    testWidgets('and ButtonActivateIntent, which is how the web sends Enter',
        (tester) async {
      var taps = 0;
      await _tabFrom(
          tester, PlinthAnchor('Send a new code', onTap: () => taps++));

      final context = FocusManager.instance.primaryFocus!.context!;
      Actions.invoke(context, const ButtonActivateIntent());
      await tester.pumpAndSettle();

      expect(taps, 1);
    });
  });

  group('a disabled control is not in the way', () {
    testWidgets('PlinthAnchor with no onTap is skipped', (tester) async {
      final landed = await _tabFrom(
        tester,
        const PlinthAnchor('Send a new code', onTap: null),
      );

      expect(landed, 'the after field',
          reason: 'focusable and dead is worse than unfocusable: it '
              'stops a keyboard user on something that does nothing');
    });
  });
}
