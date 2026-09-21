// The user tile.
//
// The point of it is that a row about a person reads as a person, and
// that presence is a word rather than only a colour.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 400}) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );

void main() {
  group('PlinthUserTile', () {
    testWidgets('name and detail render', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthUserTile(
          initials: 'YL',
          name: 'Yair Lahav',
          detail: 'yair@example.com',
        ),
      ));

      expect(find.text('Yair Lahav'), findsOneWidget);
      expect(find.text('yair@example.com'), findsOneWidget);
      expect(find.text('YL'), findsOneWidget);
    });

    testWidgets('the row is one person, not three fragments', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthUserTile(
          initials: 'YL',
          name: 'Yair Lahav',
          detail: 'yair@example.com',
        ),
      ));

      expect(
        find.bySemanticsLabel('Yair Lahav, yair@example.com'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('presence is announced as a word, not a colour',
        (tester) async {
      // A green dot is a fact only to people who can see colour.
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthUserTile(
          initials: 'YL',
          name: 'Yair Lahav',
          presence: PlinthPresence.online,
        ),
      ));

      expect(find.bySemanticsLabel('Yair Lahav, online'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('presenceLabel overrides the English', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthUserTile(
          name: 'Yair Lahav',
          presence: PlinthPresence.busy,
          presenceLabel: 'upptagen',
        ),
      ));

      expect(find.bySemanticsLabel('Yair Lahav, upptagen'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('no presence means no dot at all', (tester) async {
      // Rather than a grey one, which reads as "offline" when it means
      // "we do not know".
      await tester.pumpWidget(_wrap(
        const PlinthUserTile(initials: 'YL', name: 'Yair Lahav'),
      ));

      expect(find.byType(PlinthIndicator), findsNothing);
    });

    testWidgets('offline is a dot, because that is known', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthUserTile(
          initials: 'YL',
          name: 'Yair Lahav',
          presence: PlinthPresence.offline,
        ),
      ));

      expect(find.byType(PlinthIndicator), findsOneWidget);
    });

    testWidgets('onTap makes it a button; without one it is not',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthUserTile(name: 'Yair Lahav'),
      ));
      expect(find.byType(PlinthUnstyledButton), findsNothing);

      var taps = 0;
      await tester.pumpWidget(_wrap(
        PlinthUserTile(name: 'Yair Lahav', onTap: () => taps++),
      ));
      await tester.tap(find.byType(PlinthUnstyledButton));
      await tester.pump();

      expect(taps, equals(1));
    });

    testWidgets('a trailing control keeps its own semantics', (tester) async {
      // A menu button inside a labelled row is still a button.
      await tester.pumpWidget(_wrap(
        PlinthUserTile(
          name: 'Yair Lahav',
          trailing: PlinthActionIcon(
            semanticLabel: 'Open menu',
            icon: const Icon(Icons.more_horiz, size: 16),
            onPressed: () {},
          ),
        ),
      ));

      expect(find.bySemanticsLabel('Open menu'), findsOneWidget);
    });

    testWidgets('a long detail ellipsizes rather than overflowing',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthUserTile(
          initials: 'YL',
          name: 'Yair Lahav',
          detail: 'a.very.long.address.that.will.not.fit@example.com',
        ),
        width: 200,
      ));

      expect(tester.takeException(), isNull);
    });
  });
}
