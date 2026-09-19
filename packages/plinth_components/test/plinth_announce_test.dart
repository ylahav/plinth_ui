// The primitive behind `F-3` — see docs/F3_ANNOUNCEMENTS.md.
//
// Both halves are tested the way the thing they check actually
// surfaces, which is not the same way:
//
// A live region is a flag on a node, so these walk the real semantics
// tree rather than using `getSemantics`. That is the lesson recorded in
// plinth_announced_state_test.dart — the merged view reports a label no
// screen reader ever reaches, and here the merge *is* the question: the
// flag landing on the whole field instead of on the message is the
// failure mode `container: true` exists to prevent.
//
// An announcement leaves no trace in the tree at all. It goes out on
// SystemChannels.accessibility, and `tester.takeAnnouncements()` is
// what catches it.
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

Future<List<SemanticsNode>> _tree(WidgetTester tester, Widget child) async {
  await tester
      .pumpWidget(MaterialApp(home: Scaffold(body: Center(child: child))));
  await tester.pumpAndSettle();
  final root = rootSemanticsNode(tester);
  return _walk(root).toList();
}

/// A live region as the 17 inputs will use it: an error line under a
/// labelled field, which is the arrangement that can merge wrongly.
Widget _fieldWithError(String? error) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        textField: true,
        label: 'Email',
        child: const SizedBox(width: 100, height: 20),
      ),
      PlinthLiveRegion(
        message: error,
        child: Text(error ?? ''),
      ),
    ],
  );
}

void main() {
  group('PlinthLiveRegion marks the message', () {
    testWidgets('the message is a live region', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(tester, _fieldWithError('Email is required'));

      final message = nodes.firstWhere(
        (n) => n.label == 'Email is required',
        orElse: () => throw TestFailure('the error was not in the tree at all: '
            '${nodes.map((n) => n.label).where((l) => l.isNotEmpty).toList()}'),
      );
      expect(message.flagsCollection.isLiveRegion, isTrue,
          reason: 'without the flag nothing is spoken: focus has not '
              'moved, and validation is exactly the change a reader has '
              'no reason to go looking for');
      handle.dispose();
    });

    testWidgets('and nothing else in the field is', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(tester, _fieldWithError('Email is required'));

      final live = nodes.where((n) => n.flagsCollection.isLiveRegion).toList();
      expect(live, hasLength(1),
          reason: 'a flag that merges into the field makes the whole '
              'control live, so every rebuild re-speaks the label — the '
              'reason this widget sets container: true');
      expect(live.single.label, 'Email is required',
          reason: 'the live node should be exactly as wide as the '
              'message it carries');
      handle.dispose();
    });

    testWidgets('an empty message is no live region at all', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(tester, _fieldWithError(''));

      expect(nodes.any((n) => n.flagsCollection.isLiveRegion), isFalse,
          reason: 'a live region with nothing in it is a node a reader '
              'visits to hear silence');
      handle.dispose();
    });

    testWidgets('and neither is a null one', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(tester, _fieldWithError(null));

      expect(nodes.any((n) => n.flagsCollection.isLiveRegion), isFalse);
      handle.dispose();
    });

    testWidgets('the child renders either way', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlinthLiveRegion(message: null, child: Text('still here')),
          ),
        ),
      );

      expect(find.text('still here'), findsOneWidget,
          reason: 'the empty case returns the child untouched rather '
              'than nothing — what to render is the call site to decide');
    });
  });

  group('PlinthAnnounce.say speaks what has no node', () {
    /// Pumps a host and hands back its context, since `say` needs one
    /// for the view, the direction and the platform check.
    Future<BuildContext> host(
      WidgetTester tester, {
      TextDirection direction = TextDirection.ltr,
    }) async {
      late BuildContext captured;
      await tester.pumpWidget(MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Builder(builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          }),
        ),
      ));
      return captured;
    }

    testWidgets('a message reaches the platform', (tester) async {
      final context = await host(tester);
      final sent = await PlinthAnnounce.say(context, 'Loading complete');

      expect(sent, isTrue);
      expect(tester.takeAnnouncements(),
          contains(isAccessibilityAnnouncement('Loading complete')));
    });

    testWidgets('nothing is said when there is nothing to say', (tester) async {
      final context = await host(tester);

      expect(await PlinthAnnounce.say(context, null), isFalse);
      expect(await PlinthAnnounce.say(context, ''), isFalse);
      expect(tester.takeAnnouncements(), isEmpty);
    });

    testWidgets('and nothing where the platform does not take announcements',
        (tester) async {
      // Android, in practice: it deprecated announcement events because
      // TalkBack clears its speech queue to serve them. Staying quiet
      // here is the correct behaviour, not a gap.
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures();
      addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

      final context = await host(tester);
      final sent = await PlinthAnnounce.say(context, 'Loading complete');

      expect(sent, isFalse,
          reason: 'the caller has no other way to find out — an '
              'announcement leaves no trace to inspect');
      expect(tester.takeAnnouncements(), isEmpty);
    });

    testWidgets('assertiveness is carried, not dropped', (tester) async {
      final context = await host(tester);
      await PlinthAnnounce.say(context, 'Email is required',
          assertiveness: Assertiveness.assertive);

      expect(
          tester.takeAnnouncements(),
          contains(isAccessibilityAnnouncement('Email is required',
              assertiveness: Assertiveness.assertive)));
    });

    testWidgets('the direction comes from the context', (tester) async {
      final context = await host(tester, direction: TextDirection.rtl);
      await PlinthAnnounce.say(context, 'Saved');

      expect(
          tester.takeAnnouncements(),
          contains(isAccessibilityAnnouncement('Saved',
              textDirection: TextDirection.rtl)),
          reason: 'RTL already works for layout; an announcement that '
              'hardcoded ltr would be the one place it did not');
    });
  });
}
