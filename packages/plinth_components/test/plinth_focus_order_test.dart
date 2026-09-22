/// Tab must visit controls in the order they are read, not the order
/// they happen to sit in the widget tree.
///
/// The third of three questions about keyboard use, and the last one
/// with no coverage. `plinth_keyboard_reachable_test.dart` asks whether
/// Tab can *reach* a control. `plinth_focus_visible_test.dart` asks
/// whether you can *see* where it landed. This asks whether the route
/// between them makes sense.
///
/// A control can be reachable and visible and still be reached fourth
/// when it looks second — which is the failure that turns a form into a
/// maze, and the one nobody notices with a mouse in their hand.
///
/// **Where it goes wrong is paint order versus tree order.** Flutter's
/// default policy reads geometry, so most layouts are right for free.
/// The exceptions are arrangements that deliberately render out of
/// order: a `Stack`, a row that flips on `textDirection`, anything that
/// takes a "put this on the other side" flag.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// Reading order: strictly above wins; otherwise, on the same line, the
/// leading edge wins.
///
/// [rtl] flips only the second half. Above is still above in Arabic.
bool _precedes(Rect a, Rect b, {required bool rtl}) {
  if (a.bottom <= b.top + 1) return true;
  if (b.bottom <= a.top + 1) return false;
  return rtl ? a.right > b.right : a.left < b.left;
}

/// Tabs [stops] times and returns where focus landed each time.
Future<List<Rect>> _walk(WidgetTester tester, int stops) async {
  final seen = <Rect>[];
  for (var i = 0; i < stops; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) continue;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) continue;
    seen.add(box.localToGlobal(Offset.zero) & box.size);
  }
  return seen;
}

Future<void> _expectReadingOrder(
  WidgetTester tester,
  Widget child, {
  required int stops,
  bool rtl = false,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(body: Center(child: child)),
    ),
  ));
  await tester.pumpAndSettle();

  final visited = await _walk(tester, stops);
  expect(visited.length, greaterThanOrEqualTo(2),
      reason: 'fewer than two stops — this proved nothing');

  for (var i = 1; i < visited.length; i++) {
    expect(
      _precedes(visited[i - 1], visited[i], rtl: rtl),
      isTrue,
      reason: 'Tab went from ${visited[i - 1]} to ${visited[i]}, '
          'which is backwards in reading order',
    );
  }
}

void main() {
  testWidgets('a column of fields is walked top to bottom', (tester) async {
    await _expectReadingOrder(
      tester,
      const SizedBox(
        width: 400,
        child: Column(
          children: [
            PlinthTextInput(label: 'First'),
            PlinthTextInput(label: 'Second'),
            PlinthTextInput(label: 'Third'),
          ],
        ),
      ),
      stops: 3,
    );
  });

  testWidgets('a row of controls is walked left to right', (tester) async {
    await _expectReadingOrder(
      tester,
      SizedBox(
        width: 420,
        child: Row(
          children: [
            PlinthButton(onPressed: () {}, child: const Text('One')),
            PlinthButton(onPressed: () {}, child: const Text('Two')),
            PlinthButton(onPressed: () {}, child: const Text('Three')),
          ],
        ),
      ),
      stops: 3,
    );
  });

  testWidgets('and right to left when the text is', (tester) async {
    // RTL already works for layout — the ROADMAP is explicit that RTL
    // is done and i18n is the open one. This checks the keyboard agrees
    // with the layout, which is a separate claim.
    await _expectReadingOrder(
      tester,
      SizedBox(
        width: 420,
        child: Row(
          children: [
            PlinthButton(onPressed: () {}, child: const Text('One')),
            PlinthButton(onPressed: () {}, child: const Text('Two')),
            PlinthButton(onPressed: () {}, child: const Text('Three')),
          ],
        ),
      ),
      stops: 3,
      rtl: true,
    );
  });

  testWidgets('a radio group is walked in the order it is written',
      (tester) async {
    await _expectReadingOrder(
      tester,
      SizedBox(
        width: 400,
        child: PlinthRadioGroup<int>(
          value: 1,
          onChanged: (_) {},
          options: const [
            PlinthRadioOption(1, 'One'),
            PlinthRadioOption(2, 'Two'),
            PlinthRadioOption(3, 'Three'),
          ],
        ),
      ),
      stops: 3,
    );
  });

  testWidgets('the check would notice if the order were wrong', (tester) async {
    // A negative control, because every other test in this file passes
    // and a check that cannot fail is not evidence of anything. Three
    // buttons laid out left to right, told to traverse right to left.
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: SizedBox(
              width: 420,
              child: Row(
                children: [
                  for (final (order, label) in const [
                    (3.0, 'One'),
                    (2.0, 'Two'),
                    (1.0, 'Three'),
                  ])
                    FocusTraversalOrder(
                      order: NumericFocusOrder(order),
                      child: PlinthButton(
                        onPressed: () {},
                        child: Text(label),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final visited = await _walk(tester, 3);
    expect(visited.length, 3);

    final backwards = [
      for (var i = 1; i < visited.length; i++)
        if (!_precedes(visited[i - 1], visited[i], rtl: false)) i,
    ];
    expect(
      backwards,
      isNotEmpty,
      reason: 'the harness walked a deliberately reversed layout and '
          'called it reading order — every other test here is vacuous',
    );
  });

  testWidgets('a field and the control beside it', (tester) async {
    await _expectReadingOrder(
      tester,
      SizedBox(
        width: 420,
        child: Row(
          children: [
            const Expanded(child: PlinthTextInput(label: 'Search')),
            PlinthCloseButton(onPressed: () {}, semanticLabel: 'Clear'),
          ],
        ),
      ),
      stops: 2,
    );
  });
}
