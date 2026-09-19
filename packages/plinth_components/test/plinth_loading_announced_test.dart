// `F-3` task 4 — see docs/F3_ANNOUNCEMENTS.md.
//
// The case a live region cannot express. When loading finishes the
// overlay is removed, so there is no node left to carry the message
// and no rebuild for a reader to notice — which is why the imperative
// half of the primitive exists at all.
//
// Both edges are tested, because only one of them is the interesting
// one: arrival is a node appearing, completion is a node that has
// gone.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

import 'helpers/semantics.dart';

Iterable<SemanticsNode> _walk(SemanticsNode node) sync* {
  yield node;
  final children = <SemanticsNode>[];
  node.visitChildren((child) {
    children.add(child);
    return true;
  });
  for (final child in children) {
    yield* _walk(child);
  }
}

List<SemanticsNode> _nodes(WidgetTester tester) {
  final root = rootSemanticsNode(tester);
  return _walk(root).toList();
}

List<String> _live(WidgetTester tester) => _nodes(tester)
    .where((n) => n.flagsCollection.isLiveRegion)
    .map((n) => n.label)
    .toList();

Future<void> _pump(
  WidgetTester tester, {
  required bool visible,
  String loading = 'Loading',
  String complete = 'Loading complete',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PlinthLoadingOverlay(
          visible: visible,
          loadingLabel: loading,
          completeLabel: complete,
          child: const Text('a form'),
        ),
      ),
    ),
  );
  // pump, not pumpAndSettle: the overlay's spinner animates forever,
  // so settling never arrives.
  await tester.pump();
}

void main() {
  group('PlinthLoadingOverlay', () {
    testWidgets('arriving is spoken from the tree', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, visible: false);
      expect(_live(tester), isEmpty);

      await _pump(tester, visible: true);

      expect(_live(tester), ['Loading'],
          reason: 'a spinner is a picture of waiting and says nothing '
              'on its own');
      expect(tester.takeAnnouncements(), isEmpty,
          reason: 'the rising edge has a node to carry it, so it does '
              'not need — and should not use — an announcement, which '
              'is the half that is silent on Android');
      handle.dispose();
    });

    testWidgets('finishing is announced, because its node is gone',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, visible: true);
      tester.takeAnnouncements();

      await _pump(tester, visible: false);

      expect(_live(tester), isEmpty,
          reason: 'the overlay left the tree, taking its live region');
      expect(tester.takeAnnouncements(),
          contains(isAccessibilityAnnouncement('Loading complete')),
          reason: 'which is exactly why this edge needs the imperative '
              'half: there is nothing left to speak from');
      handle.dispose();
    });

    testWidgets('an empty label says nothing on either edge', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, visible: false, loading: '', complete: '');
      await _pump(tester, visible: true, loading: '', complete: '');

      expect(_live(tester), isEmpty);

      await _pump(tester, visible: false, loading: '', complete: '');

      expect(tester.takeAnnouncements(), isEmpty,
          reason: 'an overlay whose arrival is already announced by '
              'whatever triggered it should be able to keep quiet');
      handle.dispose();
    });

    testWidgets('a rebuild that does not change visibility is silent',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, visible: false);
      await _pump(tester, visible: false);

      expect(tester.takeAnnouncements(), isEmpty,
          reason: 'only the falling edge announces — an overlay that '
              'was already gone did not just finish');
      handle.dispose();
    });
  });

  group('PlinthLoader', () {
    testWidgets('reads as something rather than nothing', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlinthLoader())),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(_nodes(tester).any((n) => n.label == 'Loading'), isTrue);
      expect(_live(tester), isEmpty,
          reason: 'a loader usually sits inside something whose own '
              'change is already spoken; a second voice would say the '
              'same thing twice');
      handle.dispose();
    });

    testWidgets('and can be silenced where even that is noise', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PlinthLoader(semanticLabel: '')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(_nodes(tester).any((n) => n.label == 'Loading'), isFalse);
      handle.dispose();
    });
  });
}
