/// Tab must walk a *form* in the order it reads.
///
/// `plinth_components` checks this for arrangements of primitives. This
/// checks it where it actually bites: a sign-in card, a split layout
/// that can put its panes either way round, a list of rows each with
/// its own remove button. A control reached fourth when it looks second
/// turns a form into a maze, and nobody with a mouse ever notices.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

bool _precedes(Rect a, Rect b) {
  if (a.bottom <= b.top + 1) return true;
  if (b.bottom <= a.top + 1) return false;
  return a.left < b.left;
}

Future<void> _expectReadingOrder(
  WidgetTester tester,
  Widget child, {
  required int stops,
  Size size = const Size(900, 1400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: Center(child: child)),
  ));
  await tester.pumpAndSettle();

  final visited = <Rect>[];
  for (var i = 0; i < stops; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final context = FocusManager.instance.primaryFocus?.context;
    final box = context?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) continue;
    visited.add(box.localToGlobal(Offset.zero) & box.size);
  }

  expect(visited.length, greaterThanOrEqualTo(2),
      reason: 'fewer than two stops — this proved nothing');

  for (var i = 1; i < visited.length; i++) {
    expect(
      _precedes(visited[i - 1], visited[i]),
      isTrue,
      reason: 'Tab went from ${visited[i - 1]} to ${visited[i]}, '
          'which is backwards in reading order',
    );
  }
}

void main() {
  testWidgets('a sign-in card', (tester) async {
    await _expectReadingOrder(
      tester,
      PlinthSignInBlock(
        onSubmit: (_) {},
        onForgotPassword: () {},
        alternatives: [
          PlinthButton(onPressed: () {}, child: const Text('Google')),
        ],
      ),
      stops: 5,
    );
  });

  testWidgets('a split layout, decoration on the left', (tester) async {
    await _expectReadingOrder(
      tester,
      PlinthSplitAuthBlock(
        decoration: PlinthAnchor('Brand link', onTap: () {}),
        child: PlinthSignInBlock(onSubmit: (_) {}),
      ),
      stops: 4,
    );
  });

  testWidgets('a split layout, decoration on the right', (tester) async {
    // The flag reverses the child list rather than only the painting,
    // so the keyboard follows the eye. A version that flipped the
    // layout and left the tree alone would read the brand pane first
    // while it sat on the right.
    await _expectReadingOrder(
      tester,
      PlinthSplitAuthBlock(
        decorationOnRight: true,
        decoration: PlinthAnchor('Brand link', onTap: () {}),
        child: PlinthSignInBlock(onSubmit: (_) {}),
      ),
      stops: 4,
    );
  });

  testWidgets('repeatable rows, each with its own remove button',
      (tester) async {
    // Field, its remove button, then the next field — not every field
    // and then every button, which is what a naive two-column layout
    // would produce.
    await _expectReadingOrder(
      tester,
      _RepeatableHost(),
      stops: 6,
    );
  });

  testWidgets('a page header with actions beside the title', (tester) async {
    await _expectReadingOrder(
      tester,
      PlinthPageHeader(
        title: 'Orders',
        actions: [
          PlinthButton(onPressed: () {}, child: const Text('Export')),
          PlinthButton(onPressed: () {}, child: const Text('New')),
        ],
      ),
      stops: 2,
    );
  });

  testWidgets('a top bar: brand, then links, then actions', (tester) async {
    await _expectReadingOrder(
      tester,
      PlinthTopBar(
        brand: PlinthTopBarBrand(title: 'Acme', onTap: () {}),
        links: [
          PlinthAnchor('Docs', onTap: () {}),
          PlinthAnchor('Pricing', onTap: () {}),
        ],
        actions: [
          PlinthButton(onPressed: () {}, child: const Text('Sign in')),
        ],
      ),
      stops: 4,
    );
  });
}

class _RepeatableHost extends StatefulWidget {
  @override
  State<_RepeatableHost> createState() => _RepeatableHostState();
}

class _RepeatableHostState extends State<_RepeatableHost> {
  var _rows = 3;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 500,
        child: PlinthRepeatableFields(
          label: 'Emails',
          rowName: 'email',
          count: _rows,
          onAdd: () => setState(() => _rows++),
          onRemove: (_) => setState(() => _rows--),
          rowBuilder: (context, i) => PlinthTextInput(label: 'Email ${i + 1}'),
        ),
      );
}
