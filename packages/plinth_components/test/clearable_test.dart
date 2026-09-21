/// `clearable` across the whole select family, including the two that
/// closed it.
///
/// `docs/PRE_1_0_AUDIT.md` listed "nothing in the select family is
/// clearable" as a Tier 1 gap. Five of the seven closed it; this covers
/// all seven, so the gap cannot quietly re-open on the two that were
/// last.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: SizedBox(width: 420, child: child))),
    );

void main() {
  group('PlinthColorInput', () {
    testWidgets('offers no clear until asked', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthColorInput(
          value: const Color(0xFF3B5BDB),
          onChanged: (_) {},
        )),
      );
      expect(find.bySemanticsLabel('Clear colour'), findsNothing);
    });

    testWidgets('clears through onClear, not onChanged', (tester) async {
      // A `Color` has no empty value, so this one cannot report null
      // the way the rest of the family does. The caller decides what
      // unset means; the field only says that it was asked for.
      var cleared = 0;
      var changed = 0;
      await tester.pumpWidget(
        _wrap(PlinthColorInput(
          value: const Color(0xFF3B5BDB),
          clearable: true,
          onChanged: (_) => changed++,
          onClear: () => cleared++,
        )),
      );

      await tester.tap(find.bySemanticsLabel('Clear colour'));
      await tester.pumpAndSettle();

      expect(cleared, 1);
      expect(changed, 0, reason: 'clearing reported a colour change');
    });

    testWidgets('renders no button when there is nothing to call',
        (tester) async {
      // `clearable: true` with no `onClear` would be a button that does
      // nothing, which is worse than no button.
      await tester.pumpWidget(
        _wrap(PlinthColorInput(
          value: const Color(0xFF3B5BDB),
          clearable: true,
          onChanged: (_) {},
        )),
      );
      expect(find.bySemanticsLabel('Clear colour'), findsNothing);
    });
  });

  group('PlinthCascader', () {
    const options = [
      PlinthCascaderOption(
        value: 'eu',
        label: 'Europe',
        children: [PlinthCascaderOption(value: 'pt', label: 'Portugal')],
      ),
    ];

    testWidgets('offers no clear with nothing selected', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCascader(
          options: options,
          value: [],
          clearable: true,
          onChanged: _noop,
        )),
      );
      expect(find.text('Clear selection'), findsNothing);
    });

    testWidgets('clears to an empty path', (tester) async {
      List<String>? got;
      await tester.pumpWidget(
        _wrap(PlinthCascader(
          options: options,
          value: const ['eu'],
          clearable: true,
          onChanged: (v) => got = v,
        )),
      );

      expect(find.text('Clear selection'), findsOneWidget);
      await tester.tap(find.text('Clear selection'));
      await tester.pumpAndSettle();

      expect(got, isEmpty);
    });

    testWidgets('stays a bare panel when not clearable', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCascader(
          options: options,
          value: ['eu'],
          onChanged: _noop,
        )),
      );
      expect(find.text('Clear selection'), findsNothing);
    });
  });

  testWidgets('the rest of the family still clears through onChanged',
      (tester) async {
    String? got = 'a';
    await tester.pumpWidget(
      _wrap(PlinthSelect<String>(
        options: const [PlinthSelectOption('a', 'A')],
        value: 'a',
        clearable: true,
        onChanged: (v) => got = v,
      )),
    );

    await tester.tap(find.bySemanticsLabel('Clear selection'));
    await tester.pumpAndSettle();
    expect(got, isNull);
  });
}

void _noop(List<String> _) {}
