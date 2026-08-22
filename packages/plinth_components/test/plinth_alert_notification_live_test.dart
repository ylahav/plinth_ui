// `F-3` task 3 — see docs/F3_ANNOUNCEMENTS.md.
//
// Alerts and notifications carried no `Semantics` at all, which made
// them the clearest case in the finding: a message that appears
// unprompted, and nothing telling a reader it did.
//
// The interesting test here is the last one. Flutter's own `SnackBar`
// already wraps its content in `Semantics(container: true,
// liveRegion: true)` — the same shape this library settled on — so the
// `show`/`showOn` path was never the gap, and adding a second region
// inside the first is the way to turn a fix into a stutter.
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

List<SemanticsNode> _nodes(WidgetTester tester) {
  final root = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
  return _walk(root).toList();
}

Future<List<SemanticsNode>> _tree(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
  await tester.pumpAndSettle();
  return _nodes(tester);
}

List<String> _live(List<SemanticsNode> nodes) => nodes
    .where((n) => n.flagsCollection.isLiveRegion)
    .map((n) => n.label)
    .toList();

void main() {
  group('PlinthAlert', () {
    testWidgets('speaks its title and body when it appears', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(
        tester,
        const PlinthAlert(
          title: 'Something went wrong',
          color: 'red',
          child: Text('Please try again in a few minutes.'),
        ),
      );

      expect(_live(nodes), [
        'Something went wrong\nPlease try again in a few minutes.',
      ]);
      handle.dispose();
    });

    testWidgets('the dismiss button is not part of what is spoken',
        (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(
        tester,
        PlinthAlert(
          title: 'Something went wrong',
          onClose: () {},
          child: const Text('Please try again.'),
        ),
      );

      expect(_live(nodes).single, isNot(contains('Dismiss')),
          reason: 'the close button is a control; folding it into the '
              'live region re-speaks "Dismiss alert" every time the '
              'message changes');
      expect(nodes.any((n) => n.label == 'Dismiss alert'), isTrue,
          reason: 'and it should still be reachable as a control');
      handle.dispose();
    });

    testWidgets('a standing callout can opt out', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(
        tester,
        const PlinthAlert(
          live: false,
          title: 'Scheduled maintenance',
          child: Text('Sunday, 02:00–04:00 UTC.'),
        ),
      );

      expect(_live(nodes), isEmpty,
          reason: 'a banner that is part of the page should not read '
              'itself aloud on arrival');
      handle.dispose();
    });
  });

  group('PlinthNotification', () {
    testWidgets('placed by hand, it speaks', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(
        tester,
        const PlinthNotification(
          title: 'Saved',
          child: Text('Your changes have been saved.'),
        ),
      );

      expect(_live(nodes), ['Saved\nYour changes have been saved.']);
      handle.dispose();
    });

    testWidgets('shown as a snack bar, it speaks exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => PlinthNotification.show(
                  context,
                  title: 'Saved',
                  child: const Text('Your changes have been saved.'),
                ),
                child: const Text('save'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('save'));
      await tester.pumpAndSettle();

      expect(_live(_nodes(tester)), hasLength(1),
          reason: "SnackBar is already a live region, so the shown path "
              'must not add a second one inside it — that is how a fix '
              'becomes a stutter');
      handle.dispose();
    });
  });
}
