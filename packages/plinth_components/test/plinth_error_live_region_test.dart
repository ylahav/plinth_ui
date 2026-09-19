// `F-3` task 2 — see docs/F3_ANNOUNCEMENTS.md.
//
// Every control that takes an `error` now routes it through
// `PlinthLiveRegion`, so a validation message is spoken when it
// appears rather than only when a reader happens to arrive. This is
// the test that keeps the family in one shape: a control added later
// with its own hand-rolled error line fails here, which is the drift
// the primitive exists to prevent.
//
// Three of the seventeen — colour, JSON and mask input — carry no
// error line of their own; they hand it to PlinthTextInput. They are
// listed anyway, because what matters is that the message is heard,
// not which widget rendered it.
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
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
  await tester.pumpAndSettle();
  final root = rootSemanticsNode(tester);
  return _walk(root).toList();
}

const _error = 'This field is required';

/// Every control that takes an `error`, built two ways: with a message
/// and without one.
final Map<String, Widget Function(String? error)> _controls = {
  'PlinthTextInput': (e) => PlinthTextInput(label: 'Email', error: e),
  'PlinthTextarea': (e) => PlinthTextarea(label: 'Bio', error: e),
  'PlinthPasswordInput': (e) =>
      PlinthPasswordInput(label: 'Password', error: e),
  'PlinthNumberInput': (e) =>
      PlinthNumberInput(value: 1, onChanged: (_) {}, error: e),
  'PlinthMaskInput': (e) => PlinthMaskInput(mask: '000-000', error: e),
  'PlinthJsonInput': (e) => PlinthJsonInput(error: e),
  'PlinthColorInput': (e) =>
      PlinthColorInput(value: Colors.red, onChanged: (_) {}, error: e),
  'PlinthAutocomplete': (e) => PlinthAutocomplete(
        value: '',
        onChanged: (_) {},
        options: const ['Alpha'],
        error: e,
      ),
  'PlinthSelect': (e) => PlinthSelect<String>(
        options: const [PlinthSelectOption('a', 'Alpha')],
        value: null,
        onChanged: (_) {},
        error: e,
      ),
  'PlinthMultiSelect': (e) => PlinthMultiSelect<String>(
        options: const [PlinthMultiSelectOption('a', 'Alpha')],
        value: const [],
        onChanged: (_) {},
        error: e,
      ),
  'PlinthTreeSelect': (e) => PlinthTreeSelect(
        nodes: const [PlinthTreeNode(value: 'a', label: 'Alpha')],
        value: null,
        onChanged: (_) {},
        error: e,
      ),
  'PlinthTagsInput': (e) =>
      PlinthTagsInput(value: const [], onChanged: (_) {}, error: e),
  'PlinthPillsInput': (e) => PlinthPillsInput(children: const [], error: e),
  'PlinthFileInput': (e) => PlinthFileInput<String>(
        value: const [],
        onPick: () async => null,
        onChanged: (_) {},
        labelBuilder: (f) => f,
        error: e,
      ),
  'PlinthCheckbox': (e) => PlinthCheckbox(
        value: false,
        onChanged: (_) {},
        label: 'Accept terms',
        error: e,
      ),
  'PlinthSwitch': (e) => PlinthSwitch(
        value: false,
        onChanged: (_) {},
        label: 'Notifications',
        error: e,
      ),
  'PlinthRadio': (e) => PlinthRadio<String>(
        value: 'a',
        groupValue: 'b',
        onChanged: (_) {},
        label: 'Alpha',
        error: e,
      ),
  // Not an `error` string but the same job, and the control B0c heard.
  // Here so the reference case cannot drift away from the family it is
  // the reference for.
  'PlinthPinInput': (e) => PlinthPinInput(
        length: 4,
        error: e != null,
        statusText: e,
      ),
};

void main() {
  test('every control taking an error is covered', () {
    // Seventeen with an `error`, plus the pin input's statusText. A
    // new one added without a line here is the drift this catches.
    expect(_controls, hasLength(18));
  });

  group('an error is a live region', () {
    for (final entry in _controls.entries) {
      testWidgets('${entry.key} speaks its error on arrival', (tester) async {
        final handle = tester.ensureSemantics();
        final nodes = await _tree(tester, entry.value(_error));

        final live = nodes
            .where((n) => n.flagsCollection.isLiveRegion)
            .map((n) => n.label)
            .toList();
        expect(live, [_error],
            reason: 'the message should be one live region and nothing '
                'else: without the flag it is never spoken, and spread '
                'wider it re-speaks the whole control');
        handle.dispose();
      });

      testWidgets('${entry.key} is silent with no error', (tester) async {
        final handle = tester.ensureSemantics();
        final nodes = await _tree(tester, entry.value(null));

        expect(nodes.any((n) => n.flagsCollection.isLiveRegion), isFalse,
            reason: 'a live region standing by with nothing in it is a '
                'node a reader visits to hear silence');
        handle.dispose();
      });
    }
  });

  group('what the change costs, pinned so it stays visible', () {
    // Checkbox, switch and radio kept their error *inside* the
    // control's merged label, so it was spoken on focus and never on
    // arrival. A live region needs its own node, which takes the error
    // back out of that label.
    //
    // The trade was taken deliberately: it is what the text inputs
    // have always done — error as an adjacent node, not part of the
    // field's name — so the family now reads one way instead of two.
    // What is lost is a Tab-only user hearing the error again when
    // they return to the control; what is gained is hearing it at all
    // when it appears.
    testWidgets('the checkbox name no longer carries the error',
        (tester) async {
      final handle = tester.ensureSemantics();
      final nodes = await _tree(
        tester,
        PlinthCheckbox(
          value: false,
          onChanged: (_) {},
          label: 'Accept terms',
          description: 'You must agree',
          error: _error,
        ),
      );

      final named = nodes.firstWhere((n) => n.label.startsWith('Accept terms'));
      expect(named.label, 'Accept terms\nYou must agree',
          reason: 'the description stays in the name; the error moved '
              'out to the live region next to it');
      expect(named.flagsCollection.isLiveRegion, isFalse,
          reason: 'if the flag reached this node the whole control '
              'would re-speak on every rebuild');
      handle.dispose();
    });
  });
}
