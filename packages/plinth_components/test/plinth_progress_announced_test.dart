// `F-3` task 5 — see docs/F3_ANNOUNCEMENTS.md.
//
// The one surface in the finding that needed *less* than the others.
// Progress is the only thing here that can change every frame, and a
// live region on an animated value is a reader that will not stop
// talking. So the rule inverts: the value is there to be read when
// somebody visits, and only the finish is worth interrupting for.
//
// The tests that matter are the negative ones — that nothing is a live
// region, and that a bar already at 100% does not claim to have just
// got there.
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

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
  // pump, not pumpAndSettle: the fill animates on every value change.
  await tester.pump();
}

void main() {
  group('a progress bar can be read', () {
    testWidgets('the percentage is a value, not nothing', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const PlinthProgress(value: 0.6, semanticLabel: 'Upload'),
      );

      final bar = _nodes(tester).firstWhere((n) => n.value.isNotEmpty);
      expect(bar.value, '60%');
      expect(bar.label, 'Upload',
          reason: 'a bare percentage arrives out of context; the label '
              'is what says which number this is');
      handle.dispose();
    });

    testWidgets('and it is never a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const PlinthProgress(value: 0.2));
      await _pump(tester, const PlinthProgress(value: 0.5));
      await _pump(tester, const PlinthProgress(value: 0.9));

      expect(_nodes(tester).any((n) => n.flagsCollection.isLiveRegion), isFalse,
          reason: 'marked live, a bar narrates every frame of its own '
              'animation — the fastest way to make somebody switch '
              'announcements off entirely');
      handle.dispose();
    });

    testWidgets('the ring keeps quiet where its centre already speaks',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const PlinthRingProgress(value: 0.72, label: Text('72%')),
      );

      final values =
          _nodes(tester).map((n) => n.value).where((v) => v.isNotEmpty);
      expect(values, isEmpty,
          reason: 'the centre label is the percentage; a value beside '
              'it would read the same number twice');
      expect(_nodes(tester).any((n) => n.label.contains('72%')), isTrue,
          reason: 'and it should still be readable');
      handle.dispose();
    });

    testWidgets('but supplies one when the centre is empty', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const PlinthRingProgress(value: 0.72));

      expect(_nodes(tester).any((n) => n.value == '72%'), isTrue);
      handle.dispose();
    });
  });

  group('only the finish is announced', () {
    testWidgets('reaching 1.0 speaks once', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const PlinthProgress(value: 0.9, completeLabel: 'Upload complete'),
      );
      expect(tester.takeAnnouncements(), isEmpty);

      await _pump(
        tester,
        const PlinthProgress(value: 1, completeLabel: 'Upload complete'),
      );

      expect(tester.takeAnnouncements(),
          contains(isAccessibilityAnnouncement('Upload complete')));
      handle.dispose();
    });

    testWidgets('and does not keep saying it', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const PlinthProgress(value: 0.9, completeLabel: 'Upload complete'),
      );
      await _pump(
        tester,
        const PlinthProgress(value: 1, completeLabel: 'Upload complete'),
      );
      tester.takeAnnouncements();

      await _pump(
        tester,
        const PlinthProgress(value: 1, completeLabel: 'Upload complete'),
      );

      expect(tester.takeAnnouncements(), isEmpty, reason: 'it finished once');
      handle.dispose();
    });

    testWidgets('a bar that starts full is a statistic, not an event',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const PlinthProgress(value: 1, completeLabel: 'Storage full'),
      );

      expect(tester.takeAnnouncements(), isEmpty,
          reason: 'nothing just happened — the number was already '
              'there, and announcing it reports an event that never '
              'occurred');
      handle.dispose();
    });

    testWidgets('without a label there is nothing to say', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const PlinthProgress(value: 0.9));
      await _pump(tester, const PlinthProgress(value: 1));

      expect(tester.takeAnnouncements(), isEmpty,
          reason: 'completion is opt-in: most bars are statistics');
      handle.dispose();
    });

    testWidgets('the ring and the gauge do it too', (tester) async {
      final handle = tester.ensureSemantics();

      await _pump(
        tester,
        const PlinthRingProgress(value: 0.5, completeLabel: 'Ring done'),
      );
      await _pump(
        tester,
        const PlinthRingProgress(value: 1, completeLabel: 'Ring done'),
      );
      expect(tester.takeAnnouncements(),
          contains(isAccessibilityAnnouncement('Ring done')));

      await _pump(
        tester,
        const PlinthSemiCircleProgress(value: 0.5, completeLabel: 'Gauge done'),
      );
      await _pump(
        tester,
        const PlinthSemiCircleProgress(value: 1, completeLabel: 'Gauge done'),
      );
      expect(tester.takeAnnouncements(),
          contains(isAccessibilityAnnouncement('Gauge done')));

      handle.dispose();
    });
  });
}
