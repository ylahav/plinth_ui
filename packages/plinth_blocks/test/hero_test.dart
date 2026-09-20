// The hero block and the stat strip.
//
// Two things here are worth more than the rendering checks: that the
// headline is a heading rather than large text, and that a split hero
// stacks instead of squeezing two unreadable columns onto a phone.
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
  group('PlinthHeroBlock', () {
    testWidgets('the headline is a heading, not large text', (tester) async {
      // A landing page's claim is the page's heading. Rendered as a big
      // `Text` it leaves a document whose outline starts further down,
      // which is what a screen reader navigates by.
      await tester.pumpWidget(_wrap(
        const PlinthHeroBlock(headline: 'Build interfaces faster'),
      ));

      final title = tester.widget<PlinthTitle>(find.byType(PlinthTitle));
      expect(title.order, equals(2));
    });

    testWidgets('headlineOrder moves it down a nested page', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthHeroBlock(headline: 'Section claim', headlineOrder: 3),
      ));

      expect(
        tester.widget<PlinthTitle>(find.byType(PlinthTitle)).order,
        equals(3),
      );
    });

    testWidgets('a split hero shows both halves when there is room',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthHeroBlock(
          layout: PlinthHeroLayout.split,
          headline: 'Ship your product today',
          aside: Text('screenshot'),
        ),
      ));

      expect(find.text('screenshot'), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('a split hero stacks rather than squeezing', (tester) async {
      // Two columns on a phone gives each of them a measure too narrow
      // to read. The picture moves under the words; it is not dropped.
      await tester.pumpWidget(_wrap(
        const PlinthHeroBlock(
          layout: PlinthHeroLayout.split,
          headline: 'Ship your product today',
          aside: Text('screenshot'),
        ),
        width: 360,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('screenshot'), findsOneWidget);
      expect(find.text('Ship your product today'), findsOneWidget);
    });

    testWidgets('asideOnLeft swaps the halves', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthHeroBlock(
          layout: PlinthHeroLayout.split,
          asideOnLeft: true,
          headline: 'Headline',
          aside: Text('screenshot'),
        ),
      ));

      expect(
        tester.getCenter(find.text('screenshot')).dx,
        lessThan(tester.getCenter(find.text('Headline')).dx),
      );
    });

    testWidgets('eyebrow, subhead, actions and footer all render',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthHeroBlock(
          eyebrow: const PlinthBadge('New', color: 'grape'),
          headline: 'Build interfaces faster',
          subhead: 'A themeable Flutter component library.',
          actions: [
            PlinthButton(onPressed: () {}, child: const Text('Get started')),
          ],
          footer: const Text('Free while in beta'),
        ),
      ));

      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('Build interfaces faster'), findsOneWidget);
      expect(
          find.text('A themeable Flutter component library.'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Free while in beta'), findsOneWidget);
    });

    testWidgets('a background image carries a scrim by default',
        (tester) async {
      // "Legible over the photograph we tested" is the failure this
      // default exists to stop.
      await tester.pumpWidget(_wrap(
        const PlinthHeroBlock(
          headline: 'Build it once',
          backgroundImage: 'https://example.com/hero.jpg',
        ),
      ));

      final background = tester.widget<PlinthBackgroundImage>(
        find.byType(PlinthBackgroundImage),
      );
      expect(background.scrimOpacity, equals(0.5));
    });

    testWidgets('a centred hero puts aside underneath rather than dropping it',
        (tester) async {
      // A widget that vanishes because a layout flag disagrees with it
      // is an hour somebody spends looking for it.
      await tester.pumpWidget(_wrap(
        const PlinthHeroBlock(
          headline: 'Centred',
          aside: Text('screenshot'),
        ),
      ));

      expect(find.text('screenshot'), findsOneWidget);
      expect(
        tester.getCenter(find.text('screenshot')).dy,
        greaterThan(tester.getCenter(find.text('Centred')).dy),
      );
    });
  });

  group('PlinthStatStrip', () {
    testWidgets('each pair is announced as one thing', (tester) async {
      // "117 components", not two strings that happen to be near each
      // other.
      await tester.pumpWidget(_wrap(
        const PlinthStatStrip(
          stats: [
            PlinthStat(value: '117', label: 'components'),
            PlinthStat(value: '160', label: 'pub points'),
          ],
        ),
      ));

      expect(find.byType(MergeSemantics), findsNWidgets(2));
      expect(find.text('117'), findsOneWidget);
      expect(find.text('components'), findsOneWidget);
    });

    testWidgets('the divider is off by default', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthStatStrip(
          stats: [PlinthStat(value: '1', label: 'thing')],
        ),
      ));

      expect(find.byType(PlinthDivider), findsNothing);

      await tester.pumpWidget(_wrap(
        const PlinthStatStrip(
          divider: true,
          stats: [PlinthStat(value: '1', label: 'thing')],
        ),
      ));

      expect(find.byType(PlinthDivider), findsOneWidget);
    });

    testWidgets('an empty list does not crash', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthStatStrip(stats: [])));
      expect(tester.takeException(), isNull);
    });
  });
}
