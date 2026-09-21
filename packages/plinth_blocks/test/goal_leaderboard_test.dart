// Goal rings and the leaderboard.
//
// Both carry a design decision the showcase had written in a comment
// and nothing enforced: rings because these targets do not add up, and
// bars measured against the leader because a ranking answers "how far
// behind is second".
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

void main() {
  group('PlinthGoalRings', () {
    testWidgets('one ring per goal, with its percentage', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthGoalRings(
          title: 'Quarter targets',
          goals: [
            PlinthGoal(label: 'Signups', value: 0.82, color: 'teal'),
            PlinthGoal(label: 'Activation', value: 0.46, color: 'blue'),
          ],
        ),
      ));

      expect(find.byType(PlinthRingProgress), findsNWidgets(2));
      expect(find.text('82%'), findsOneWidget);
      expect(find.text('Quarter targets'), findsOneWidget);
    });

    testWidgets('a ring and its label are one thing to a reader',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthGoalRings(
          goals: [PlinthGoal(label: 'Signups', value: 0.82)],
        ),
      ));

      expect(find.bySemanticsLabel('Signups, 82 percent'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a caption replaces the percentage', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthGoalRings(
          goals: [
            PlinthGoal(label: 'Storage', value: 0.68, caption: '68 GB'),
          ],
        ),
      ));

      expect(find.text('68 GB'), findsOneWidget);
      expect(find.text('68%'), findsNothing);
    });

    testWidgets('no goals is not a crash', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthGoalRings(goals: [])));
      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthLeaderboard', () {
    const rows = [
      PlinthLeaderboardRow(label: '/docs', value: 8420, display: '8,420'),
      PlinthLeaderboardRow(label: '/button', value: 4210, display: '4,210'),
      PlinthLeaderboardRow(label: '/pricing', value: 1240, display: '1,240'),
    ];

    testWidgets('the leader gets a full bar', (tester) async {
      // Against the leader, not the total: dividing by a sum nobody
      // sees makes every bar a stub.
      await tester.pumpWidget(_wrap(
        const PlinthLeaderboard(title: 'Top pages', rows: rows),
      ));

      final bars = tester
          .widgetList<PlinthProgress>(find.byType(PlinthProgress))
          .toList();

      expect(bars, hasLength(3));
      expect(bars.first.value, equals(1.0));
      expect(bars[1].value, closeTo(4210 / 8420, 0.001));
      expect(bars.last.value, closeTo(1240 / 8420, 0.001));
    });

    testWidgets('each row is announced with its figure', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthLeaderboard(rows: rows),
      ));

      expect(find.bySemanticsLabel('/docs, 8,420'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('an empty ranking says so', (tester) async {
      // A ranking with no rows and no explanation reads as a broken
      // query.
      await tester.pumpWidget(_wrap(const PlinthLeaderboard(rows: [])));

      expect(find.text('Nothing to rank yet.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a row with onTap is pressable', (tester) async {
      var opened = 0;

      await tester.pumpWidget(_wrap(
        PlinthLeaderboard(
          rows: [
            PlinthLeaderboardRow(
              label: '/docs',
              value: 10,
              onTap: () => opened++,
            ),
          ],
        ),
      ));

      await tester.tap(find.byType(PlinthUnstyledButton));
      await tester.pump();

      expect(opened, equals(1));
    });

    testWidgets('all-zero values do not divide by zero', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthLeaderboard(
          rows: [PlinthLeaderboardRow(label: 'none', value: 0)],
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(
        tester.widget<PlinthProgress>(find.byType(PlinthProgress)).value,
        equals(0),
      );
    });
  });
}
