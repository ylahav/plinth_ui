// The line chart.
//
// Two claims carry this widget: that a series is distinguishable
// without colour, and that no line is too faint to see.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_charts/plinth_charts.dart';

Widget _wrap(Widget child, {double width = 400, bool dark = false}) =>
    MaterialApp(
      theme: ThemeData(
        extensions: [dark ? PlinthTheme.darkTheme : PlinthTheme.defaultTheme],
      ),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );

const _two = [
  PlinthChartSeries(name: 'Direct', values: [4, 9, 7, 12]),
  PlinthChartSeries(name: 'Search', values: [2, 3, 6, 8]),
];

void main() {
  group('summary', () {
    test('it names every line', () {
      const chart = PlinthLineChart(label: 'Traffic', series: _two);
      expect(
        chart.summary,
        equals('Traffic. Direct, 4 to 12, rising. Search, 2 to 8, rising'),
      );
    });

    test('it cannot describe a different chart to the one drawn', () {
      const a = PlinthLineChart(series: _two);
      const b = PlinthLineChart(series: [
        PlinthChartSeries(name: 'Direct', values: [12, 4]),
      ]);
      expect(a.summary, isNot(equals(b.summary)));
    });

    test('an empty chart says so', () {
      const empty = PlinthLineChart(label: 'Traffic', series: []);
      expect(empty.summary, equals('Traffic. No data'));
    });
  });

  group('colour is not load-bearing', () {
    test('every series gets its own dash pattern', () {
      // A legend mapping colour to name is no help to a reader who
      // cannot see the difference.
      final patterns = <List<double>>[];
      for (var i = 0; i < 6; i++) {
        patterns.add(PlinthLineChart.dashPatterns[i]);
      }
      final asStrings = patterns.map((p) => p.join(',')).toList();
      expect(asStrings.toSet(), hasLength(asStrings.length));
    });

    testWidgets('the legend swatch carries the pattern, not just a dot',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthLineChart(series: _two),
      ));

      expect(find.text('Direct'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      // One painter for the chart, one per legend swatch.
      expect(find.byType(CustomPaint), findsAtLeast(3));
    });
  });

  group('no line is too faint to see', () {
    test('every default series clears the non-text floor', () {
      // The palette varies lightness so dichromats keep a second
      // channel; four of its six defaults are under 3:1 on white, and a
      // 2px line at 1.5:1 is faint for everybody.
      for (final theme in [PlinthTheme.defaultTheme, PlinthTheme.darkTheme]) {
        const chart = PlinthLineChart(
          series: [
            PlinthChartSeries(name: 'a', values: [1, 2]),
            PlinthChartSeries(name: 'b', values: [1, 2]),
            PlinthChartSeries(name: 'c', values: [1, 2]),
            PlinthChartSeries(name: 'd', values: [1, 2]),
            PlinthChartSeries(name: 'e', values: [1, 2]),
            PlinthChartSeries(name: 'f', values: [1, 2]),
          ],
        );

        for (final (index, color) in chart.colorsFor(theme).indexed) {
          expect(
            PlinthTheme.contrastRatio(color, theme.surface),
            greaterThanOrEqualTo(PlinthContrast.nonText.ratio),
            reason: '${theme.brightness.name} series $index',
          );
        }
      }
    });

    test('a colour already clearing the floor is left alone', () {
      // Lifting one that did not need it would flatten the lightness
      // ordering the CVD work depends on.
      final theme = PlinthTheme.defaultTheme;
      final entry = theme.seriesColors[2];
      final raw = theme.shaded(entry.ramp, entry.shade);
      expect(
        PlinthTheme.contrastRatio(raw, theme.surface),
        greaterThanOrEqualTo(PlinthContrast.nonText.ratio),
        reason: 'fixture assumes series 2 already passes',
      );

      const chart = PlinthLineChart(series: [
        PlinthChartSeries(name: 'a', values: [1, 2]),
        PlinthChartSeries(name: 'b', values: [1, 2]),
        PlinthChartSeries(name: 'c', values: [1, 2]),
      ]);
      expect(chart.colorsFor(theme)[2], equals(raw));
    });
  });

  group('rendering', () {
    testWidgets('it draws, with and without an area fill', (tester) async {
      for (final area in [true, false]) {
        await tester.pumpWidget(_wrap(
          PlinthLineChart(series: _two, showArea: area),
        ));
        expect(tester.takeException(), isNull, reason: 'showArea: $area');
      }
    });

    testWidgets('a single-point series is skipped, not crashed on',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthLineChart(series: [
          PlinthChartSeries(name: 'one', values: [5]),
          PlinthChartSeries(name: 'two', values: [1, 9]),
        ]),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a flat chart does not divide by zero', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthLineChart(series: [
          PlinthChartSeries(name: 'flat', values: [7, 7, 7]),
        ]),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the chart announces its summary', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthLineChart(label: 'Traffic', series: _two),
      ));

      expect(
        find.bySemanticsLabel(
          'Traffic. Direct, 4 to 12, rising. Search, 2 to 8, rising',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
