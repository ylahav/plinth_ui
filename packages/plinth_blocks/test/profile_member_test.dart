// The profile card and the member list.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 400}) => MaterialApp(
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
  group('PlinthProfileCard', () {
    testWidgets('centred: avatar, name, badge and counts', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthProfileCard(
          initials: 'YL',
          name: 'Yair Lahav',
          badge: const PlinthBadge('Maintainer', color: 'grape'),
          stats: const [
            PlinthStat(value: '128', label: 'Posts'),
            PlinthStat(value: '2.4k', label: 'Followers'),
          ],
          actions: [
            PlinthButton(onPressed: () {}, child: const Text('Follow')),
          ],
        ),
      ));

      expect(find.text('Yair Lahav'), findsOneWidget);
      expect(find.text('MAINTAINER'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('the name is a heading', (tester) async {
      // How a screen reader finds one card among a page of them.
      await tester.pumpWidget(_wrap(
        const PlinthProfileCard(name: 'Yair Lahav'),
      ));

      expect(
        tester.widget<PlinthTitle>(find.byType(PlinthTitle)).order,
        equals(4),
      );
    });

    testWidgets('counts are announced as one thing each', (tester) async {
      // Reused from PlinthStatStrip, which merges value and label.
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthProfileCard(
          name: 'Yair Lahav',
          stats: [PlinthStat(value: '128', label: 'Posts')],
        ),
      ));

      expect(find.byType(MergeSemantics), findsWidgets);
      handle.dispose();
    });

    testWidgets('left-aligned is the contact arrangement', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthProfileCard(
          centered: false,
          initials: 'CD',
          name: 'Cara Diaz',
          detail: 'Field engineer · Lisbon',
          details: [
            PlinthDataListItem.text('Email', 'cara@example.com'),
            PlinthDataListItem.text('Timezone', 'WET'),
          ],
        ),
      ));

      expect(find.text('Cara Diaz'), findsOneWidget);
      expect(find.text('cara@example.com'), findsOneWidget);
      // The avatar sits beside the name rather than above it.
      expect(
        tester.getCenter(find.text('CD')).dx,
        lessThan(tester.getCenter(find.text('Cara Diaz')).dx),
      );
    });

    testWidgets('a bare card does not crash', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthProfileCard(name: 'A')));
      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthMemberList', () {
    const members = [
      PlinthMember(initials: 'AN', name: 'Alice Nguyen', role: 'Owner'),
      PlinthMember(initials: 'BK', name: 'Ben Kaur', role: 'Editor'),
    ];

    testWidgets('a row per member, each with its role', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthMemberList(title: 'Members', members: members),
      ));

      expect(find.text('Alice Nguyen'), findsOneWidget);
      expect(find.text('OWNER'), findsOneWidget);
      expect(find.byType(PlinthUserTile), findsNWidgets(2));
    });

    testWidgets('overflow avatars summarise the rest', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthMemberList(
          title: 'Members',
          members: members,
          overflowAvatars: [
            PlinthAvatar(initials: 'AN', size: PlinthSize.sm),
            PlinthAvatar(initials: 'BK', size: PlinthSize.sm),
            PlinthAvatar(initials: 'CD', size: PlinthSize.sm),
          ],
        ),
      ));

      expect(find.byType(PlinthOverflowList), findsOneWidget);
    });

    testWidgets('an empty team says so', (tester) async {
      // A card that renders nothing reads as one that failed to load.
      await tester.pumpWidget(_wrap(
        const PlinthMemberList(title: 'Members', members: []),
      ));

      expect(find.text('Nobody here yet.'), findsOneWidget);
    });

    testWidgets('a member with no role gets no badge', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthMemberList(
          members: [PlinthMember(initials: 'AN', name: 'Alice Nguyen')],
        ),
      ));

      expect(find.byType(PlinthBadge), findsNothing);
    });
  });
}
