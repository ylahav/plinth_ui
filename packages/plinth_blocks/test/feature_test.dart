// The feature, comparison and logo blocks.
//
// Three things here are the reason these are widgets rather than
// arrangements: a tick that resolves against the theme instead of being
// frozen at one hex, a matrix that refuses to render a short row, and
// an alternation that cannot get out of step.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 800, bool dark = false}) =>
    MaterialApp(
      theme: ThemeData(
        extensions: [dark ? PlinthTheme.darkTheme : PlinthTheme.defaultTheme],
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );

const _features = [
  PlinthFeature(
    icon: Icon(Icons.bolt_outlined),
    title: 'Fast',
    description: 'Optimised rebuilds with no widget churn.',
  ),
  PlinthFeature(
    icon: Icon(Icons.palette_outlined),
    title: 'Themeable',
    description: 'Every token is overridable.',
  ),
];

void main() {
  group('PlinthFeatureBlock', () {
    testWidgets('the grid shows icons, titles and descriptions',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthFeatureBlock(features: _features, title: 'Why Plinth'),
      ));

      expect(find.text('Why Plinth'), findsOneWidget);
      expect(find.text('Fast'), findsOneWidget);
      expect(find.text('Optimised rebuilds with no widget churn.'),
          findsOneWidget);
    });

    testWidgets('the checklist tick follows the theme rather than a hex',
        (tester) async {
      // The showcase version hardcoded Color(0xFF40C057) — Mantine's
      // green 6, frozen at one shade whatever the surface behind it.
      //
      // Features with no icon of their own, so the default tick is what
      // renders: a feature that brings its own icon keeps it.
      const plain = [
        PlinthFeature(title: 'Themeable, with no lock-in'),
        PlinthFeature(title: 'Published on pub.dev'),
      ];

      Color tick() =>
          tester.widgetList<Icon>(find.byIcon(Icons.check_circle)).first.color!;

      await tester.pumpWidget(_wrap(
        const PlinthFeatureBlock(
          features: plain,
          layout: PlinthFeatureLayout.list,
        ),
      ));
      final inLight = tick();

      await tester.pumpWidget(_wrap(
        const PlinthFeatureBlock(
          features: plain,
          layout: PlinthFeatureLayout.list,
        ),
        dark: true,
      ));
      // Settled, not pumped once: MaterialApp cross-fades a theme
      // change through AnimatedTheme, and PlinthTheme.lerp means one
      // frame in the tick is still almost entirely the old colour.
      await tester.pumpAndSettle();
      final inDark = tick();

      expect(inLight, isNot(equals(inDark)),
          reason: 'the tick did not move when the theme did');
    });

    testWidgets('the default tick is hidden from assistive technology',
        (tester) async {
      // The same mark on every row carries nothing a reader does not
      // already have, and read aloud it is thirty repetitions of the
      // word "check".
      await tester.pumpWidget(_wrap(
        const PlinthFeatureBlock(
          features: _features,
          layout: PlinthFeatureLayout.list,
        ),
      ));

      expect(find.byType(ExcludeSemantics), findsWidgets);
    });

    testWidgets('alternating rows swap sides', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthFeatureBlock(
          layout: PlinthFeatureLayout.alternating,
          features: [
            PlinthFeature(title: 'One', media: Text('media-one')),
            PlinthFeature(title: 'Two', media: Text('media-two')),
          ],
        ),
      ));

      final first = tester.getCenter(find.text('media-one')).dx;
      final second = tester.getCenter(find.text('media-two')).dx;

      // Doing this by hand is where a row ends up on the same side as
      // the one above it.
      expect(first, isNot(closeTo(second, 1)));
    });

    testWidgets('alternating stacks when there is no room', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthFeatureBlock(
          layout: PlinthFeatureLayout.alternating,
          features: [PlinthFeature(title: 'One', media: Text('media-one'))],
        ),
        width: 360,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('media-one'), findsOneWidget);
    });

    testWidgets('an alternating item with no media renders full width',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthFeatureBlock(
          layout: PlinthFeatureLayout.alternating,
          features: [PlinthFeature(title: 'No picture')],
        ),
      ));

      expect(find.text('No picture'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty feature list does not crash', (tester) async {
      for (final layout in PlinthFeatureLayout.values) {
        await tester.pumpWidget(_wrap(
          PlinthFeatureBlock(features: const [], layout: layout),
        ));
        expect(tester.takeException(), isNull, reason: layout.name);
      }
    });
  });

  group('PlinthComparisonBlock', () {
    testWidgets('it renders the matrix', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthComparisonBlock(
          title: 'Compare plans',
          plans: const ['Free', 'Pro'],
          rows: const [
            PlinthComparisonRow(label: 'Components', values: ['All', 'All']),
            PlinthComparisonRow(label: 'Private themes', values: [false, true]),
          ],
        ),
      ));

      expect(find.text('Compare plans'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Components'), findsOneWidget);
    });

    testWidgets('a bool cell carries a label a reader can hear',
        (tester) async {
      // An unlabelled tick is a cell that reads as nothing, and a row
      // of them is a table nobody can answer the question with.
      await tester.pumpWidget(_wrap(
        PlinthComparisonBlock(
          plans: const ['Free', 'Pro'],
          rows: const [
            PlinthComparisonRow(label: 'Themes', values: [false, true]),
          ],
        ),
      ));

      expect(find.bySemanticsLabel('Included'), findsOneWidget);
      expect(find.bySemanticsLabel('Not included'), findsOneWidget);
    });

    testWidgets('a short row is refused rather than silently shifted',
        (tester) async {
      // A matrix with a short row does not look broken. It moves every
      // answer after it one column left, which is a pricing page that
      // lies.
      expect(
        () => PlinthComparisonBlock(
          plans: const ['Free', 'Pro', 'Team'],
          rows: const [
            PlinthComparisonRow(label: 'Themes', values: [true, false]),
          ],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('no rows is fine', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthComparisonBlock(plans: const ['Free'], rows: const []),
      ));
      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthLogoStrip', () {
    testWidgets('it scrolls by default', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthLogoStrip(
          label: 'BUILT WITH PLINTH',
          logos: [Text('ACME'), Text('Globex')],
        ),
      ));

      expect(find.byType(PlinthMarquee), findsOneWidget);
      expect(find.text('BUILT WITH PLINTH'), findsOneWidget);
    });

    testWidgets('scroll false is a static row', (tester) async {
      // Motion that earns nothing is motion somebody has to sit through.
      await tester.pumpWidget(_wrap(
        const PlinthLogoStrip(
          scroll: false,
          logos: [Text('ACME'), Text('Globex')],
        ),
      ));

      expect(find.byType(PlinthMarquee), findsNothing);
      expect(find.text('ACME'), findsOneWidget);
    });
  });
}
