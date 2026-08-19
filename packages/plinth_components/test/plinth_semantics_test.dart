// B0a/B0b — every interactive control carries a name and a role.
//
// The probe that produced this found the opposite: PlinthRating exposed
// five tappable stars with no label and no role between them, so a
// screen-reader user could reach every one and learn nothing from any —
// not what tapping did, and not what the rating already was.
//
// These assert the state after that pass, so the gap cannot reopen
// quietly. `labelled == tappable` is the whole check: a control you can
// reach and cannot identify is worse than one you cannot reach.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: child)),
    );

({int tappable, int labelled, int roled}) _survey(WidgetTester tester) {
  var tappable = 0, labelled = 0, roled = 0;
  void walk(SemanticsNode n) {
    final d = n.getSemanticsData();
    if (d.hasAction(SemanticsAction.tap)) {
      tappable++;
      if (d.label.isNotEmpty) labelled++;
      if (d.flagsCollection.isButton ||
          d.flagsCollection.isTextField ||
          d.flagsCollection.isLink) roled++;
    }
    n.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return (tappable: tappable, labelled: labelled, roled: roled);
}

void main() {
  final cases = <String, Widget>{
    'PlinthAutocomplete': PlinthAutocomplete(
        value: '', onChanged: (_) {}, options: const ['Alpha'], label: 'Find'),
    'PlinthAccordion': PlinthAccordion(items: [
      PlinthAccordionItem(
          value: 'a', title: 'Section', content: const Text('Body')),
    ]),
    'PlinthRating': PlinthRating(value: 3, onChanged: (_) {}),
    'PlinthPinInput': PlinthPinInput(length: 4, onChanged: (_) {}),
    'PlinthBreadcrumbs': PlinthBreadcrumbs(items: [
      PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
      const PlinthBreadcrumbItem(label: 'Here'),
    ]),
    'PlinthStepper': PlinthStepper(
        steps: const [PlinthStep(label: 'One'), PlinthStep(label: 'Two')],
        currentStep: 0,
        onStepTapped: (_) {}),
    'PlinthActionIcon': PlinthActionIcon(
        onPressed: () {}, icon: const Icon(Icons.edit), semanticLabel: 'Edit'),
    'PlinthAnchor': PlinthAnchor('Link', onTap: () {}),
  };

  for (final entry in cases.entries) {
    testWidgets('${entry.key} names every target it exposes', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(entry.value));
      await tester.pumpAndSettle();
      final s = _survey(tester);
      expect(s.tappable, greaterThan(0), reason: 'nothing tappable found');
      expect(s.labelled, s.tappable, reason: 'unlabelled tap targets');
      handle.dispose();
    });
  }

  testWidgets('PlinthRating names each star with the value it sets',
      (tester) async {
    // The label has to say what tapping *does*, not merely exist.
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(PlinthRating(value: 3, onChanged: (_) {})));
    await tester.pumpAndSettle();
    final labels = <String>[];
    void walk(SemanticsNode n) {
      final d = n.getSemanticsData();
      if (d.hasAction(SemanticsAction.tap)) labels.add(d.label);
      n.visitChildren((c) {
        walk(c);
        return true;
      });
    }

    walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    expect(labels, ['1 of 5', '2 of 5', '3 of 5', '4 of 5', '5 of 5']);
    handle.dispose();
  });

  testWidgets('PlinthActionIcon without a label is the caller\'s choice',
      (tester) async {
    // Recorded rather than asserted away: the parameter exists, and an
    // icon-only button with no label still builds. Flutter's own
    // labeledTapTargetGuideline is what fails it, which is the right
    // place for that to surface.
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(PlinthActionIcon(onPressed: () {}, icon: const Icon(Icons.edit))),
    );
    expect(_survey(tester).labelled, 0);
    handle.dispose();
  });

  testWidgets('PlinthAnchor clears WCAG 2.2 AA tap target and contrast',
      (tester) async {
    // It was 23px and 3.56:1 -- short on both, each by a margin only a
    // measurement finds.
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(PlinthAnchor('Link', onTap: () {})));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    expect(tester.getSemantics(find.text('Link')).rect.height,
        greaterThanOrEqualTo(24.0));
    handle.dispose();
  });
}
