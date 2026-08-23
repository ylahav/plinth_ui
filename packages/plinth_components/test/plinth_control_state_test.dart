// State a control is in, as a reader hears it.
//
// From the third listening pass, 23 Aug 2026. Two reports, both of the
// same shape and neither about a missing label:
//
//   "stepper - works fine - one exception - when selecting a step
//    (space key) - it does not say it"
//
//   "collapse - when changing value - nothing"
//
// The stepper announced every step as its label and the word button,
// whichever state it was in — the fill and the check mark carried
// "done" and "you are here" alone. Its two siblings, PlinthTabs and
// PlinthSegmentedControl, both already carried `selected`; the stepper
// was the one in the family that did not.
//
// PlinthSpoiler's toggle was a bare InkWell around text: reachable,
// tappable, and announcing as neither a control nor as something that
// opens anything. The same defect B0c found on the accordion header,
// in the widget next door.
// Tri-state rather than bool: "not selected" and "selectedness does not
// apply here" are different things to a reader, and dart:ui is where
// the enum lives — neither material nor semantics re-exports it.
import 'dart:ui' show Tristate;

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
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
  await tester.pumpAndSettle();
  final root = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
  return _walk(root).toList();
}

/// Finds the node whose label *contains* [label].
///
/// Not equality: a step's circle draws its number, and that number
/// merges into the accessible name — the second step reads "2
/// Shipping". Worth knowing, and not what these are testing.
SemanticsNode _labelled(List<SemanticsNode> nodes, String label) =>
    nodes.firstWhere(
      (n) => n.label.contains(label),
      orElse: () => throw TestFailure('no node labelled "$label": '
          '${nodes.map((n) => n.label).where((l) => l.isNotEmpty).toList()}'),
    );

Widget _stepper({int current = 1}) => PlinthStepper(
      currentStep: current,
      onStepTapped: (_) {},
      steps: const [
        PlinthStep(label: 'Account'),
        PlinthStep(label: 'Shipping'),
        PlinthStep(label: 'Confirm'),
      ],
    );

void main() {
  group('PlinthStepper says which state each step is in', () {
    testWidgets('done, here, and ahead are three different readings',
        (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(tester, _stepper());

      expect(_labelled(nodes, 'Account').value, 'completed');
      expect(_labelled(nodes, 'Shipping').value, 'current step');
      expect(_labelled(nodes, 'Confirm').value, 'not completed');
      handle.dispose();
    });

    testWidgets('only the current step is marked selected', (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(tester, _stepper());

      expect(_labelled(nodes, 'Shipping').flagsCollection.isSelected,
          Tristate.isTrue);
      // Null rather than false on the others: marking every step
      // explicitly not-selected has a reader say so on each one.
      expect(_labelled(nodes, 'Account').flagsCollection.isSelected,
          Tristate.none);
      handle.dispose();
    });

    testWidgets('and the readings move with the step', (tester) async {
      final handle = tester.ensureSemantics();
      await _tree(tester, _stepper());
      final nodes = await _tree(tester, _stepper(current: 2));

      expect(_labelled(nodes, 'Shipping').value, 'completed',
          reason: 'what used to be current is now behind, and nothing '
              'in the tree said so before this');
      expect(_labelled(nodes, 'Confirm').value, 'current step');
      handle.dispose();
    });
  });

  group('PlinthSpoiler says it is a control, and which way it is', () {
    testWidgets('the toggle is a button that reports collapsed',
        (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(
        tester,
        const PlinthSpoiler(
          maxHeight: 40,
          showLabel: 'Show more',
          hideLabel: 'Show less',
          child: Text('A long stretch of text that runs past the fold.'),
        ),
      );

      final toggle = _labelled(nodes, 'Show more');
      expect(toggle.flagsCollection.isButton, isTrue,
          reason: 'it announced as text before: reachable, tappable, '
              'and giving no clue it was a control');
      expect(toggle.flagsCollection.isExpanded, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('and reports expanded once it is', (tester) async {
      final handle = tester.ensureSemantics();
      await _tree(
        tester,
        const PlinthSpoiler(
          maxHeight: 40,
          showLabel: 'Show more',
          hideLabel: 'Show less',
          child: Text('A long stretch of text that runs past the fold.'),
        ),
      );

      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();

      final root =
          tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
      final toggle = _labelled(_walk(root).toList(), 'Show less');
      expect(toggle.flagsCollection.isExpanded, Tristate.isTrue);
      handle.dispose();
    });
  });
}
