// The sparkline.
//
// Most of this is about the sentence rather than the pixels: a chart
// with no text alternative is a blank to anyone not looking at it, and
// a summary that is written by hand can describe a different series to
// the one drawn.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_charts/plinth_charts.dart';

Widget _wrap(Widget child, {double width = 300}) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );

void main() {
  group('PlinthSparkline summary', () {
    test('it says where the series started, ended and went', () {
      const rising = PlinthSparkline(
        label: 'Monthly revenue',
        values: [12, 15, 38],
      );
      expect(rising.summary, equals('Monthly revenue, 12 to 38, rising'));

      const falling = PlinthSparkline(values: [38, 20, 12]);
      expect(falling.summary, equals('38 to 12, falling'));

      const flat = PlinthSparkline(values: [20, 25, 20]);
      expect(flat.summary, equals('20 to 20, flat'));
    });

    test('it is built from the data, so it cannot disagree with it', () {
      // The failure a hand-written label has: the series changes and
      // the sentence does not.
      const a = PlinthSparkline(values: [1, 2]);
      const b = PlinthSparkline(values: [1, 9]);
      expect(a.summary, isNot(equals(b.summary)));
    });

    test('describeValue formats the endpoints', () {
      final money = PlinthSparkline(
        label: 'Revenue',
        values: const [1200, 3800],
        describeValue: (v) => '\$${v.round()}',
      );
      expect(money.summary, equals(r'Revenue, $1200 to $3800, rising'));
    });

    test('semanticsLabel replaces it entirely', () {
      const custom = PlinthSparkline(
        values: [1, 2, 3],
        semanticsLabel: 'Trend over the last quarter',
      );
      expect(custom.summary, equals('Trend over the last quarter'));
    });

    test('the direction words are overridable', () {
      const swedish = PlinthSparkline(
        values: [1, 5],
        riseLabel: 'stigande',
      );
      expect(swedish.summary, contains('stigande'));
    });

    test('whole numbers do not gain a decimal point', () {
      const whole = PlinthSparkline(values: [12, 38]);
      expect(whole.summary, equals('12 to 38, rising'));

      const fractional = PlinthSparkline(values: [1.5, 2.5]);
      expect(fractional.summary, equals('1.5 to 2.5, rising'));
    });
  });

  group('PlinthSparkline rendering', () {
    testWidgets('the chart is an image with a label, not silent pixels',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthSparkline(label: 'Revenue', values: [12, 24, 38]),
      ));

      expect(
        find.bySemanticsLabel('Revenue, 12 to 38, rising'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('one point draws nothing rather than a flat line',
        (tester) async {
      // A single reading is a dot, not a trend, and a flat line would
      // claim a shape the data does not have.
      await tester.pumpWidget(_wrap(const PlinthSparkline(values: [12])));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty series does not crash', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthSparkline(values: [])));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a flat series does not divide by zero', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSparkline(values: [20, 20, 20]),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the line clears the contrast floor', (tester) async {
      // 2px is the thinnest mark in the library, and the raw shade is
      // under the floor for several ramps.
      final theme = PlinthTheme.defaultTheme;
      for (final ramp in ['yellow', 'cyan', 'blue']) {
        final resolved = theme.readableOn(ramp, theme.surface);
        expect(
          PlinthTheme.contrastRatio(resolved, theme.surface),
          greaterThanOrEqualTo(PlinthContrast.body.ratio),
          reason: ramp,
        );
      }
    });
  });
}
