import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('PlinthDataList', () {
    testWidgets('renders every label and its value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthDataList(
            items: [
              PlinthDataListItem.text('Order', '#4021'),
              PlinthDataListItem.text('Placed', '12 Aug 2026'),
            ],
          ),
        ),
      );

      expect(find.text('Order'), findsOneWidget);
      expect(find.text('#4021'), findsOneWidget);
      expect(find.text('Placed'), findsOneWidget);
      expect(find.text('12 Aug 2026'), findsOneWidget);
    });

    testWidgets('a value can be an arbitrary widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthDataList(
            items: [
              PlinthDataListItem(
                label: 'Status',
                value: PlinthBadge('Active', color: 'green'),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(PlinthBadge), findsOneWidget);
    });

    testWidgets('horizontal aligns every value into one column', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 400,
            child: PlinthDataList(
              items: [
                PlinthDataListItem.text('ID', 'a1'),
                PlinthDataListItem.text('A much longer label', 'b2'),
              ],
            ),
          ),
        ),
      );

      // The point of the horizontal layout: labels share an intrinsic
      // column, so values line up without the caller measuring.
      expect(
        tester.getRect(find.text('a1')).left,
        closeTo(tester.getRect(find.text('b2')).left, 0.01),
      );
    });

    testWidgets('vertical puts each value below its label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthDataList(
            orientation: PlinthDataListOrientation.vertical,
            items: [PlinthDataListItem.text('Order', '#4021')],
          ),
        ),
      );

      expect(
        tester.getRect(find.text('#4021')).top,
        greaterThan(tester.getRect(find.text('Order')).bottom),
      );
    });

    testWidgets('stacked pairs are announced as one label/value run', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthDataList(
            orientation: PlinthDataListOrientation.vertical,
            items: [PlinthDataListItem.text('Order', '#4021')],
          ),
        ),
      );

      expect(find.byType(MergeSemantics), findsOneWidget);
    });

    testWidgets('renders an empty list without throwing', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthDataList(items: [])));

      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthRollingNumber', () {
    testWidgets('formats exactly as PlinthNumberFormatter does', (
      tester,
    ) async {
      const rolling = PlinthRollingNumber(
        value: 1234567.5,
        prefix: r'$',
        decimalScale: 2,
      );
      const formatter = PlinthNumberFormatter(
        value: 1234567.5,
        prefix: r'$',
        decimalScale: 2,
      );

      // Delegated rather than reimplemented, so the two can't drift.
      expect(rolling.formatted, formatter.formatted);
      expect(rolling.formatted, r'$1,234,567.50');
    });

    testWidgets('announces the whole number rather than each digit', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PlinthRollingNumber(value: 1200), reduceMotion: true),
      );
      await tester.pump();

      expect(find.bySemanticsLabel('1,200'), findsOneWidget);
    });

    testWidgets('reaches the new value after animating', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthRollingNumber(value: 999)));
      await tester.pump();

      await tester.pumpWidget(_wrap(const PlinthRollingNumber(value: 1000)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.bySemanticsLabel('1,000'), findsOneWidget);
    });

    testWidgets('reduce motion settles immediately', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthRollingNumber(value: 10), reduceMotion: true),
      );
      await tester.pump();

      await tester.pumpWidget(
        _wrap(const PlinthRollingNumber(value: 20), reduceMotion: true),
      );
      // A single frame, with no time advanced: a number that may change
      // often shouldn't move at all for someone who asked for less
      // motion.
      await tester.pump();

      expect(find.bySemanticsLabel('20'), findsOneWidget);
    });

    testWidgets('renders the separators and affixes as static text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthRollingNumber(
            value: 1500,
            prefix: r'$',
            suffix: ' km',
          ),
          reduceMotion: true,
        ),
      );
      await tester.pump();

      expect(find.text(r'$'), findsOneWidget);
      expect(find.text(','), findsOneWidget);
      // A digit inside a suffix is a label, not a place value.
      expect(find.bySemanticsLabel(r'$1,500 km'), findsOneWidget);
    });

    testWidgets('handles negatives, decimals, and zero', (tester) async {
      for (final value in [0, -42, -1234.5, 0.25]) {
        await tester.pumpWidget(
          _wrap(
            PlinthRollingNumber(value: value, decimalScale: 2),
            reduceMotion: true,
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      }
    });
  });
}
