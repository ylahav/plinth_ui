// The contact form and the channel grid.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 800}) => MaterialApp(
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
  group('PlinthContactBlock', () {
    testWidgets('it reports what was typed', (tester) async {
      PlinthContactValues? sent;

      await tester.pumpWidget(_wrap(
        PlinthContactBlock(onSubmit: (values) => sent = values),
      ));

      final fields = find.byType(PlinthTextInput);
      await tester.enterText(fields.at(0), 'Ada');
      await tester.enterText(fields.at(1), 'ada@example.com');
      await tester.enterText(find.byType(PlinthTextarea), 'Hello there.');
      await tester.tap(find.text('Send'));
      await tester.pump();

      expect(sent?.name, equals('Ada'));
      expect(sent?.email, equals('ada@example.com'));
      expect(sent?.message, equals('Hello there.'));
    });

    testWidgets('showName false drops the field', (tester) async {
      // Every field is one more reason not to send.
      await tester.pumpWidget(_wrap(
        PlinthContactBlock(showName: false, onSubmit: (_) {}),
      ));

      expect(find.byType(PlinthTextInput), findsOneWidget);
      expect(find.text('Name'), findsNothing);
    });

    testWidgets('a null onSubmit disables sending', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthContactBlock()));

      expect(
        tester.widget<PlinthButton>(find.byType(PlinthButton)).onPressed,
        isNull,
      );
    });

    testWidgets('sent swaps the form for an acknowledgement', (tester) async {
      // A form that submits and looks unchanged reads as broken, and
      // the result is the same message sent four times.
      await tester.pumpWidget(_wrap(
        PlinthContactBlock(sent: true, onSubmit: (_) {}),
      ));

      expect(find.text('Thanks — that is with us'), findsOneWidget);
      expect(find.byType(PlinthTextarea), findsNothing);
      expect(find.text('Send'), findsNothing);
    });

    testWidgets('an aside sits beside the form when there is room',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthContactBlock(
          onSubmit: (_) {},
          aside: const Text('Weekdays, 9–17 UTC'),
        ),
      ));

      expect(find.text('Weekdays, 9–17 UTC'), findsOneWidget);
      expect(
        tester.getCenter(find.text('Weekdays, 9–17 UTC')).dx,
        greaterThan(tester.getCenter(find.byType(PlinthTextarea)).dx),
      );
    });

    testWidgets('the aside moves under the form when narrow', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthContactBlock(
          onSubmit: (_) {},
          aside: const Text('Weekdays, 9–17 UTC'),
        ),
        width: 360,
      ));

      expect(tester.takeException(), isNull);
      expect(
        tester.getCenter(find.text('Weekdays, 9–17 UTC')).dy,
        greaterThan(tester.getCenter(find.byType(PlinthTextarea)).dy),
      );
    });

    testWidgets('asideOnLeft swaps the sides', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthContactBlock(
          onSubmit: (_) {},
          asideOnLeft: true,
          aside: const Text('Weekdays, 9–17 UTC'),
        ),
      ));

      expect(
        tester.getCenter(find.text('Weekdays, 9–17 UTC')).dx,
        lessThan(tester.getCenter(find.byType(PlinthTextarea)).dx),
      );
    });
  });

  group('PlinthSupportChannels', () {
    const channels = [
      PlinthSupportChannel(
        icon: Icon(Icons.chat_bubble_outline),
        title: 'Live chat',
        detail: 'Weekdays, 9–17 UTC',
        color: 'blue',
      ),
      PlinthSupportChannel(
        icon: Icon(Icons.mail_outline),
        title: 'Email',
        detail: 'Replies within a day',
        color: 'teal',
      ),
    ];

    testWidgets('each tile is one thing to a screen reader', (tester) async {
      // Not an icon, a heading and a caption announced as three
      // unrelated fragments.
      await tester.pumpWidget(_wrap(
        const PlinthSupportChannels(channels: channels),
      ));

      expect(find.byType(MergeSemantics), findsNWidgets(2));
      expect(find.text('Live chat'), findsOneWidget);
      expect(find.text('Weekdays, 9–17 UTC'), findsOneWidget);
    });

    testWidgets('a channel with onTap is pressable', (tester) async {
      var opened = 0;

      await tester.pumpWidget(_wrap(
        PlinthSupportChannels(
          channels: [
            PlinthSupportChannel(
              title: 'Live chat',
              detail: 'Now',
              onTap: () => opened++,
            ),
          ],
        ),
      ));

      await tester.tap(find.text('Live chat'));
      await tester.pump();

      expect(opened, equals(1));
    });

    testWidgets('a channel without onTap is not a button', (tester) async {
      // A tile that looks tappable and is not is worse than one that
      // plainly is not.
      await tester.pumpWidget(_wrap(
        const PlinthSupportChannels(channels: channels),
      ));

      expect(find.byType(PlinthUnstyledButton), findsNothing);
    });

    testWidgets('an empty list does not crash', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSupportChannels(channels: []),
      ));
      expect(tester.takeException(), isNull);
    });
  });
}
