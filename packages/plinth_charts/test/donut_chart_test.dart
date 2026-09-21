// The donut.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_charts/plinth_charts.dart';

Widget _wrap(Widget child, {double width = 300}) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );

const _segments = [
  PlinthDonutSegment(label: 'Direct', value: 50),
  PlinthDonutSegment(label: 'Search', value: 30),
  PlinthDonutSegment(label: 'Social', value: 20),
];

void main() {
  group('arithmetic', () {
    test('shares are fractions of the total', () {
      const chart = PlinthDonutChart(segments: _segments);
      expect(chart.total, equals(100));
      expect(chart.shares, equals([0.5, 0.3, 0.2]));
    });

    test('a negative slice is treated as zero, not drawn backwards', () {
      // Drawing one backwards silently corrupts every slice after it.
      const chart = PlinthDonutChart(segments: [
        PlinthDonutSegment(label: 'bad', value: -10),
        PlinthDonutSegment(label: 'good', value: 10),
      ]);

      expect(chart.total, equals(10));
      expect(chart.shares, equals([0.0, 1.0]));
    });

    test('an all-zero donut does not divide by zero', () {
      const chart = PlinthDonutChart(segments: [
        PlinthDonutSegment(label: 'none', value: 0),
      ]);
      expect(chart.shares, equals([0.0]));
    });
  });

  group('rendering', () {
    testWidgets('the centre carries the total as one fact', (tester) async {
      // "9,100 sessions" rather than a number and a caption that
      // happen to be stacked.
      await tester.pumpWidget(_wrap(
        const PlinthDonutChart(
          segments: _segments,
          centreLabel: '100',
          centreCaption: 'sessions',
        ),
      ));

      expect(find.text('100'), findsOneWidget);
      expect(find.text('sessions'), findsOneWidget);
      expect(find.byType(MergeSemantics), findsOneWidget);
    });

    testWidgets('the legend carries the figures, not just the colours',
        (tester) async {
      // A slice is an angle, and an angle is not a number.
      await tester.pumpWidget(_wrap(
        const PlinthDonutChart(segments: _segments),
      ));

      expect(find.text('50 · 50%'), findsOneWidget);
      expect(find.text('20 · 20%'), findsOneWidget);
    });

    testWidgets('every slice is its own node', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthDonutChart(segments: _segments),
      ));

      expect(find.bySemanticsLabel('Direct, 50, 50%'), findsOneWidget);
      expect(find.bySemanticsLabel('Social, 20, 20%'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('an empty donut says so rather than drawing a ring',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthDonutChart(segments: []),
      ));

      expect(find.text('No data'), findsOneWidget);
      // No ring was laid out: the widget is a line of text, not the
      // 140px default diameter. `find.byType(CustomPaint)` would not
      // prove this — Scaffold ships several of its own.
      expect(
        tester.getSize(find.byType(PlinthDonutChart)).height,
        lessThan(100),
      );
    });

    testWidgets('an all-zero donut says so too', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthDonutChart(segments: [
          PlinthDonutSegment(label: 'none', value: 0),
        ]),
      ));

      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('one slice filling the ring still draws', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthDonutChart(segments: [
          PlinthDonutSegment(label: 'all', value: 10),
        ]),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('10 · 100%'), findsOneWidget);
    });

    testWidgets('describeValue reaches the legend and the speech',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        PlinthDonutChart(
          segments: _segments,
          showPercentages: false,
          describeValue: (v) => '${v.round()}k',
        ),
      ));

      expect(find.text('50k'), findsOneWidget);
      expect(find.bySemanticsLabel('Direct, 50k'), findsOneWidget);
      handle.dispose();
    });

    test('a seriesKey pins a slice colour across reordering', () {
      final theme = PlinthTheme.defaultTheme;

      const first = PlinthDonutChart(segments: [
        PlinthDonutSegment(label: 'a', value: 1, seriesKey: 'direct'),
        PlinthDonutSegment(label: 'b', value: 1, seriesKey: 'search'),
      ]);
      const swapped = PlinthDonutChart(segments: [
        PlinthDonutSegment(label: 'b', value: 1, seriesKey: 'search'),
        PlinthDonutSegment(label: 'a', value: 1, seriesKey: 'direct'),
      ]);

      expect(first.colorsFor(theme).first, equals(swapped.colorsFor(theme)[1]));
    });
  });
}
