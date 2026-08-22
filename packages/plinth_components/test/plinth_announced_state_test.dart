// What B0c heard, turned into tests.
//
// Both bugs here shared a shape: the semantics were checked with
// `getSemantics`, which returns a *merged* view and so reported a label
// that a real screen reader never reached, or reported nothing missing
// because the missing thing was an announcement rather than a node.
// These walk the real tree instead.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

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

Future<List<SemanticsNode>> _tree(WidgetTester tester, Widget child) async {
  await tester
      .pumpWidget(MaterialApp(home: Scaffold(body: Center(child: child))));
  await tester.pumpAndSettle();
  final root = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
  return _walk(root).toList();
}

void main() {
  group('read-only rating states its value', () {
    testWidgets('one node, carrying the value rather than the scale',
        (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(tester, const PlinthRating(value: 3.5));

      final labelled = nodes.where((n) => n.label.isNotEmpty).toList();
      expect(labelled, hasLength(1),
          reason: 'a read-only rating is one readable thing, not five. '
              'Five nodes read as "1 of 5, 2 of 5, 3 of 5..." and never '
              'say the rating: ${labelled.map((n) => n.label).toList()}');
      expect(labelled.single.label, 'Rating');
      expect(labelled.single.value, '3.5 of 5');
      handle.dispose();
    });

    testWidgets('a whole number loses the decimal', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(tester, const PlinthRating(value: 4));
      expect(nodes.firstWhere((n) => n.label == 'Rating').value, '4 of 5');
      handle.dispose();
    });

    testWidgets('the interactive one keeps its per-star buttons',
        (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(
        tester,
        PlinthRating(value: 3, onChanged: (_) {}),
      );
      final labels =
          nodes.where((n) => n.label.isNotEmpty).map((n) => n.label).toList();
      expect(labels, ['1 of 5', '2 of 5', '3 of 5', '4 of 5', '5 of 5']);
      handle.dispose();
    });
  });

  group('pin input announces its result', () {
    testWidgets('statusText is a live region, so it is spoken on arrival',
        (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(
        tester,
        const PlinthPinInput(
            length: 6, error: true, statusText: 'Incorrect code'),
      );

      final status = nodes.firstWhere((n) => n.label == 'Incorrect code',
          orElse: () => throw TestFailure(
              'the result was not in the tree at all: '
              '${nodes.map((n) => n.label).where((l) => l.isNotEmpty).toList()}'));
      expect(status.flagsCollection.isLiveRegion, isTrue,
          reason: 'without liveRegion nothing is spoken: the boxes are '
              'full, focus has not moved, and the only change is a '
              'border colour');
      handle.dispose();
    });

    testWidgets('success reads too, not only failure', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(
        tester,
        const PlinthPinInput(length: 6, statusText: 'Code verified'),
      );
      expect(nodes.any((n) => n.label == 'Code verified'), isTrue);
      handle.dispose();
    });

    testWidgets('no status, no extra node', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(tester, const PlinthPinInput(length: 4));
      final labels =
          nodes.where((n) => n.label.isNotEmpty).map((n) => n.label).toList();
      expect(labels, [
        'Digit 1 of 4',
        'Digit 2 of 4',
        'Digit 3 of 4',
        'Digit 4 of 4',
      ]);
      handle.dispose();
    });
  });
}
