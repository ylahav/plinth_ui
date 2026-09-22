/// Every focusable control must *look* focused — WCAG 2.4.7.
///
/// `plinth_keyboard_reachable_test.dart` proves Tab can reach these
/// controls. It cannot tell you whether a sighted keyboard user can see
/// where Tab landed, because it walks the semantics tree, and a focus
/// ring is not in the semantics tree. It is paint.
///
/// So this compares **pixels**: render the control, press Tab, render it
/// again, and require the two images to differ. Nothing else answers
/// the question. A render-tree diff under-reports, because Material
/// paints `InkWell`'s focus highlight on an ancestor rather than on the
/// widget; a whole-tree diff over-reports, because focus state appears
/// in the tree as data whether or not anything is drawn.
///
/// This found five controls — close button, checkbox, radio, switch and
/// chip — that were reachable, announced, and completely invisible once
/// reached. Same shape as `F-4`, one layer over: the tree was right and
/// the screen was wrong.
///
/// Not a golden test. It compares an image to *another image of the
/// same widget* rather than to a committed reference, so it runs
/// everywhere rather than on Linux only.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

const _key = ValueKey('focus-visible-probe');

/// Every control a keyboard can land on.
final Map<String, Widget> _focusable = {
  'PlinthButton': PlinthButton(onPressed: () {}, child: const Text('Go')),
  'PlinthActionIcon': PlinthActionIcon(
    icon: const Icon(Icons.edit),
    onPressed: () {},
    semanticLabel: 'Edit',
  ),
  'PlinthCloseButton':
      PlinthCloseButton(onPressed: () {}, semanticLabel: 'Close'),
  'PlinthAnchor': PlinthAnchor('Link', onTap: () {}),
  'PlinthNavLink': PlinthNavLink(label: 'Home', onTap: () {}),
  'PlinthUnstyledButton':
      PlinthUnstyledButton(onPressed: () {}, child: const Text('x')),
  'PlinthCheckbox': PlinthCheckbox(value: false, onChanged: (_) {}),
  'PlinthSwitch': PlinthSwitch(value: false, onChanged: (_) {}),
  'PlinthRadio': PlinthRadio<int>(value: 1, groupValue: 2, onChanged: (_) {}),
  'PlinthChip': PlinthChip(label: 'Tag', selected: false, onSelected: (_) {}),
  'PlinthTextInput': const PlinthTextInput(label: 'Email'),
};

Future<List<int>> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_key));
  late List<int> bytes;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ImageByteFormat.rawRgba);
    bytes = data!.buffer.asUint8List();
    image.dispose();
  });
  return bytes;
}

void main() {
  _focusable.forEach((name, widget) {
    testWidgets('$name looks different once focused', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: Scaffold(
          body: Center(child: RepaintBoundary(key: _key, child: widget)),
        ),
      ));
      await tester.pumpAndSettle();

      final before = await _pixels(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final after = await _pixels(tester);

      // Focus has to have landed, or the comparison proves nothing.
      final focused = FocusManager.instance.primaryFocus;
      expect(
        focused?.context != null &&
            find
                .descendant(
                  of: find.byKey(_key),
                  matching: find.byElementPredicate(
                      (e) => identical(e, focused!.context)),
                )
                .evaluate()
                .isNotEmpty,
        isTrue,
        reason: '$name was never focused, so this test proved nothing',
      );

      var differing = 0;
      for (var i = 0; i < before.length; i++) {
        if (before[i] != after[i]) differing++;
      }

      expect(
        differing,
        greaterThan(0),
        reason: '$name is reachable by Tab and paints nothing to say so — '
            'a sighted keyboard user cannot see where they are',
      );
    });
  });
}
