// The stat tile.
//
// Two things here are the reason it is a widget rather than an
// arrangement: a falling number is not automatically bad news, and a
// green arrow is not information anyone can hear.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 600}) => MaterialApp(
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

Color _arrowColour(WidgetTester tester) =>
    tester.widgetList<Icon>(find.byType(Icon)).first.color!;

void main() {
  group('PlinthStatTile', () {
    testWidgets('a rise in a higher-is-better figure reads as good',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthStatTile(
          label: 'Revenue',
          value: r'$13,456',
          delta: '12.4%',
          trend: PlinthTrend.up,
        ),
      ));

      final theme = PlinthTheme.defaultTheme;
      expect(
        _arrowColour(tester),
        equals(theme.readableOn('green', theme.surface)),
      );
    });

    testWidgets('a fall in churn is good news, not bad', (tester) async {
      // The bug this block exists to fix. The version it replaced had a
      // single up/down flag, so churn dropping 0.4% came out red with a
      // downward arrow — bad news about the best number on the board.
      await tester.pumpWidget(_wrap(
        const PlinthStatTile(
          label: 'Churn',
          value: '1.8%',
          delta: '0.4%',
          trend: PlinthTrend.down,
          higherIsBetter: false,
        ),
      ));

      final theme = PlinthTheme.defaultTheme;
      expect(
        _arrowColour(tester),
        equals(theme.readableOn('green', theme.surface)),
        reason: 'falling churn was coloured as a loss',
      );
    });

    testWidgets('a fall in a higher-is-better figure reads as bad',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthStatTile(
          label: 'Active users',
          value: '2,340',
          delta: '3.1%',
          trend: PlinthTrend.down,
        ),
      ));

      final theme = PlinthTheme.defaultTheme;
      expect(
        _arrowColour(tester),
        equals(theme.readableOn('red', theme.surface)),
      );
    });

    testWidgets('the arrow colour clears the contrast floor', (tester) async {
      // `color(ramp, 6)` is the raw shade and sits under the floor for a
      // 14px mark on white, which is what the showcase version used.
      await tester.pumpWidget(_wrap(
        const PlinthStatTile(
          label: 'Revenue',
          value: r'$1',
          delta: '1%',
          trend: PlinthTrend.up,
        ),
      ));

      final theme = PlinthTheme.defaultTheme;
      expect(
        PlinthTheme.contrastRatio(_arrowColour(tester), theme.surface),
        greaterThanOrEqualTo(PlinthContrast.body.ratio),
      );
    });

    testWidgets('the movement is spoken, not only coloured', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthStatTile(
          label: 'Churn',
          value: '1.8%',
          delta: '0.4%',
          trend: PlinthTrend.down,
          higherIsBetter: false,
        ),
      ));

      expect(find.bySemanticsLabel('Churn, 1.8%, down 0.4%'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('flat gets no arrow', (tester) async {
      // An arrow meaning "no change" is an arrow read as change.
      await tester.pumpWidget(_wrap(
        const PlinthStatTile(
          label: 'Uptime',
          value: '99.9%',
          delta: '0%',
        ),
      ));

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('the spoken label keeps the case you wrote', (tester) async {
      // Displayed in capitals; a reader handed REVENUE may spell it out.
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthStatTile(label: 'Revenue', value: r'$13,456'),
      ));

      expect(find.text('REVENUE'), findsOneWidget);
      expect(find.bySemanticsLabel('Revenue, \$13,456'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the value is the tile heading', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthStatTile(label: 'Revenue', value: r'$13,456'),
      ));

      expect(
        tester.widget<PlinthTitle>(find.byType(PlinthTitle)).order,
        equals(3),
      );
    });

    testWidgets('badge, caption, visual and action all render', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthStatTile(
          label: 'Storage used',
          value: '68%',
          badge: const PlinthBadge('Pro', color: 'grape'),
          caption: '68 GB of 100 GB',
          visual: const PlinthProgress(value: 0.68),
          action: PlinthAnchor('Manage plan', onTap: () {}),
        ),
      ));

      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('68 GB of 100 GB'), findsOneWidget);
      expect(find.byType(PlinthProgress), findsOneWidget);
      expect(find.text('Manage plan'), findsOneWidget);
    });
  });

  group('PlinthStatGrid', () {
    testWidgets('it drops to one column when narrow', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthStatGrid(
          tiles: [
            PlinthStatTile(label: 'A', value: '1'),
            PlinthStatTile(label: 'B', value: '2'),
            PlinthStatTile(label: 'C', value: '3'),
          ],
        ),
        width: 200,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('A'.toUpperCase()), findsOneWidget);
    });

    testWidgets('no tiles is not a crash', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthStatGrid(tiles: [])));
      expect(tester.takeException(), isNull);
    });
  });
}
