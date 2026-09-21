// The bar chart.
//
// The distinction from the line chart is the one worth testing: a line
// is a shape and reads as a summary, a bar chart is a list of figures
// and should be walkable.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_charts/plinth_charts.dart';

Widget _wrap(Widget child, {double width = 400}) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );

const _bars = [
  PlinthBar(label: 'Direct', value: 5200),
  PlinthBar(label: 'Search', value: 3100),
  PlinthBar(label: 'Social', value: 800),
];

void main() {
  group('PlinthBarChart', () {
    testWidgets('every bar is its own node, not one long sentence',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthBarChart(label: 'Sessions', bars: _bars),
      ));

      expect(find.bySemanticsLabel('Direct, 5200'), findsOneWidget);
      expect(find.bySemanticsLabel('Search, 3100'), findsOneWidget);
      expect(find.bySemanticsLabel('Social, 800'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the value is written beside the bar', (tester) async {
      // So the chart does not depend on anyone estimating a length
      // against an axis.
      await tester.pumpWidget(_wrap(
        const PlinthBarChart(bars: _bars),
      ));

      expect(find.text('5200'), findsOneWidget);
      expect(find.text('800'), findsOneWidget);
    });

    testWidgets('describeValue formats both the label and the speech',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        PlinthBarChart(
          bars: _bars,
          describeValue: (v) => '${(v / 1000).toStringAsFixed(1)}k',
        ),
      ));

      expect(find.text('5.2k'), findsOneWidget);
      expect(find.bySemanticsLabel('Direct, 5.2k'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('bars are measured against the largest, not a total',
        (tester) async {
      // A bar chart asks how the categories compare; dividing by a sum
      // nobody sees makes a long tail out of every one of them.
      await tester.pumpWidget(_wrap(
        const PlinthBarChart(bars: _bars),
      ));

      final boxes = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .toList();

      expect(boxes, hasLength(3));
      expect(boxes.first.widthFactor, equals(1.0));
      expect(boxes[1].widthFactor, closeTo(3100 / 5200, 0.001));
    });

    testWidgets('an all-zero chart does not divide by zero', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthBarChart(bars: [PlinthBar(label: 'none', value: 0)]),
      ));

      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
            .widthFactor,
        equals(0),
      );
    });

    testWidgets('an empty chart says so', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthBarChart(bars: [])));
      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('a negative value does not draw backwards', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthBarChart(bars: [
          PlinthBar(label: 'loss', value: -5),
          PlinthBar(label: 'gain', value: 10),
        ]),
      ));

      expect(tester.takeException(), isNull);
      final boxes = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .toList();
      expect(boxes.first.widthFactor, greaterThanOrEqualTo(0));
    });

    test('bar colours come from the palette unlifted', () {
      // Bars are large areas, not thin marks: lifting them would
      // flatten the lightness variation the palette exists to provide,
      // and a filled rectangle at 2:1 is still perfectly visible.
      final theme = PlinthTheme.defaultTheme;
      const chart = PlinthBarChart(bars: _bars);

      expect(chart.colorsFor(theme).first, equals(theme.series(0)));
    });

    test('a seriesKey pins a bar colour across reordering', () {
      final theme = PlinthTheme.defaultTheme;

      const first = PlinthBarChart(bars: [
        PlinthBar(label: 'Direct', value: 1, seriesKey: 'direct'),
        PlinthBar(label: 'Search', value: 1, seriesKey: 'search'),
      ]);
      const reordered = PlinthBarChart(bars: [
        PlinthBar(label: 'Search', value: 1, seriesKey: 'search'),
        PlinthBar(label: 'Direct', value: 1, seriesKey: 'direct'),
      ]);

      expect(
          first.colorsFor(theme).first, equals(reordered.colorsFor(theme)[1]));
    });
  });
}
