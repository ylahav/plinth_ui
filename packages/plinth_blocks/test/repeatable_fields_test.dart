/// Adding and removing rows, and the two things that are invisible in a
/// screenshot: where focus goes, and what a reader is told.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

/// A host that owns the data, as a caller would.
class _Host extends StatefulWidget {
  const _Host({this.initial = 1, this.minRows = 1, this.maxRows});
  final int initial;
  final int minRows;
  final int? maxRows;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late var _values = List.generate(widget.initial, (i) => 'row $i');

  List<String> get values => _values;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 420,
              child: PlinthRepeatableFields(
                label: 'Phone numbers',
                rowName: 'phone number',
                minRows: widget.minRows,
                maxRows: widget.maxRows,
                count: _values.length,
                onAdd: () => setState(() => _values = [..._values, '']),
                onRemove: (i) => setState(
                  () => _values = [..._values]..removeAt(i),
                ),
                rowBuilder: (context, i) => PlinthTextInput(
                  label: 'Phone ${i + 1}',
                  controller: TextEditingController(text: _values[i]),
                ),
              ),
            ),
          ),
        ),
      );
}

void main() {
  testWidgets('adds and removes rows', (tester) async {
    await tester.pumpWidget(const _Host());
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text('Add another'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel('Remove phone number 1'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('adding focuses the row that was added', (tester) async {
    // Otherwise a new empty field appears below the fold and focus
    // stays on the button that made it, so the next keystroke goes
    // nowhere the user expects.
    await tester.pumpWidget(const _Host());
    await tester.tap(find.text('Add another'));
    await tester.pumpAndSettle();

    final focused = FocusManager.instance.primaryFocus;
    expect(focused, isNotNull, reason: 'nothing was focused at all');

    // Not merely "something has focus" — the focused subtree must be
    // the row that was just added. Focus left on the add button, or
    // parked on row 1, both satisfy a null check and neither is right.
    expect(
      find.descendant(
        of: find.byElementPredicate((e) => identical(e, focused!.context)),
        matching: find.text('Phone 2'),
      ),
      findsOneWidget,
      reason: 'focus is not inside the row that was just added',
    );
  });

  testWidgets('the remove button says which row it removes', (tester) async {
    // An unlabelled bin icon beside an unnamed field is two mysteries.
    await tester.pumpWidget(const _Host(initial: 3));
    await tester.pumpAndSettle();

    for (final n in [1, 2, 3]) {
      expect(find.bySemanticsLabel('Remove phone number $n'), findsOneWidget);
    }
  });

  testWidgets('the last row cannot be removed', (tester) async {
    // A control that is always there and never works is worse than one
    // that is absent until it applies.
    await tester.pumpWidget(const _Host());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Remove phone number 1'), findsNothing);
  });

  testWidgets('minRows is a floor, not just a special case of one',
      (tester) async {
    // Two rows with minRows: 2 must show no remove buttons at all --
    // the rule is "you may not go below the floor", not "you may not
    // empty the list".
    await tester.pumpWidget(const _Host(initial: 2, minRows: 2));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Remove phone number 1'), findsNothing);
    expect(find.bySemanticsLabel('Remove phone number 2'), findsNothing);

    await tester.tap(find.text('Add another'));
    await tester.pumpAndSettle();

    // A third row puts it above the floor, so all three become
    // removable -- including the two that were pinned a moment ago.
    for (final n in [1, 2, 3]) {
      expect(find.bySemanticsLabel('Remove phone number $n'), findsOneWidget);
    }
  });

  testWidgets('maxRows disables adding rather than hiding it', (tester) async {
    // The opposite call from removing, on purpose: the button explains
    // the ceiling exists, where a vanished button would just look like
    // a missing feature.
    await tester.pumpWidget(const _Host(initial: 2, maxRows: 2));
    await tester.pumpAndSettle();

    expect(find.text('Add another'), findsOneWidget);
    final button = tester.widget<PlinthButton>(find.byType(PlinthButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('removing announces what went and what is left', (tester) async {
    await tester.pumpWidget(const _Host(initial: 3));
    await tester.pumpAndSettle();

    final announced = <String>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility, (message) async {
      final m = message as Map<dynamic, dynamic>;
      if (m['type'] == 'announce') {
        announced
            .add((m['data'] as Map<dynamic, dynamic>)['message'] as String);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockDecodedMessageHandler<dynamic>(
            SystemChannels.accessibility, null));

    await tester.tap(find.bySemanticsLabel('Remove phone number 2'));
    await tester.pumpAndSettle();

    expect(
      announced,
      contains('phone number 2 removed, 2 phone numbers remaining'),
      reason: 'the row vanished silently',
    );
  });

  testWidgets('the announcement counts in singular when one is left',
      (tester) async {
    await tester.pumpWidget(const _Host(initial: 2));
    await tester.pumpAndSettle();

    final announced = <String>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility, (message) async {
      final m = message as Map<dynamic, dynamic>;
      if (m['type'] == 'announce') {
        announced
            .add((m['data'] as Map<dynamic, dynamic>)['message'] as String);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockDecodedMessageHandler<dynamic>(
            SystemChannels.accessibility, null));

    await tester.tap(find.bySemanticsLabel('Remove phone number 1'));
    await tester.pumpAndSettle();

    expect(announced.single, endsWith('1 phone number remaining'));
  });
}
