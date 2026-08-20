// A form field's visible label has to reach assistive technology.
//
// Every one of these renders its label as a *sibling* of the field —
// which shows it to sighted users and to nobody else. `PlinthAutocomplete`
// was found this way (PR-19's probe reported it unlabelled despite being
// given a `label`), and a grep then found eight more widgets with no
// `Semantics` in the file at all.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: child)),
    );

/// Every label reachable in the semantics tree.
List<String> _labels(WidgetTester tester) {
  final found = <String>[];
  void walk(SemanticsNode n) {
    final label = n.getSemanticsData().label;
    if (label.isNotEmpty) found.add(label);
    n.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

void main() {
  const label = 'Field label';

  final cases = <String, Widget>{
    'PlinthTextInput': const PlinthTextInput(label: label),
    'PlinthTextarea': const PlinthTextarea(label: label),
    'PlinthNumberInput':
        PlinthNumberInput(label: label, value: 1, onChanged: (_) {}),
    'PlinthPasswordInput': const PlinthPasswordInput(label: label),
    'PlinthTagsInput':
        PlinthTagsInput(label: label, value: const ['a'], onChanged: (_) {}),
    'PlinthAutocomplete': PlinthAutocomplete(
        label: label, value: '', onChanged: (_) {}, options: const ['a']),
    'PlinthSelect': PlinthSelect<String>(
        label: label,
        options: const [PlinthSelectOption('a', 'Alpha')],
        value: 'a',
        onChanged: (_) {}),
    'PlinthMultiSelect': PlinthMultiSelect<String>(
        label: label,
        options: const [PlinthMultiSelectOption('a', 'Alpha')],
        value: const ['a'],
        onChanged: (_) {}),
    'PlinthTreeSelect': PlinthTreeSelect(
        label: label,
        nodes: const [PlinthTreeNode(value: 'a', label: 'Alpha')],
        value: 'a',
        onChanged: (_) {}),
  };

  group('a form field exposes its label to assistive technology', () {
    for (final entry in cases.entries) {
      testWidgets(entry.key, (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_wrap(entry.value));
        await tester.pumpAndSettle();

        // The label reaching the tree at all is not enough — it is
        // painted, so a `Text` node carries it either way. It has to be
        // on a node that is *not* just the rendered caption, which is
        // what associates it with the control.
        //
        // `contains` rather than `==`: a control that also has a value
        // merges the two, so a select announces the label and the
        // chosen option together. That is the correct reading for a
        // screen reader, not a near miss.
        final onControl = <String>[];
        void walk(SemanticsNode n) {
          final d = n.getSemanticsData();
          if (d.label.contains(label) &&
              (d.hasAction(SemanticsAction.tap) ||
                  d.flagsCollection.isTextField ||
                  d.flagsCollection.isButton)) {
            onControl.add(d.label);
          }
          n.visitChildren((c) {
            walk(c);
            return true;
          });
        }

        walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
        expect(onControl, isNotEmpty,
            reason: '${entry.key}: the label reaches the tree as '
                '${_labels(tester)} but not on the control');
        handle.dispose();
      });
    }
  });
}
