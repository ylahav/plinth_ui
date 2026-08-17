import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child, {double width = 600}) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(
      body: Center(child: SizedBox(width: width, child: child)),
    ),
  );
}

/// The pre-1.0 audit's Tier 3, built in 0.24.0. Each of these was a
/// one-line entry on a list of "noted, not urgent" props; the tests
/// are here rather than spread across seven files because what they
/// have in common is the list, not the components.
void main() {
  group('PlinthAvatar.name', () {
    testWidgets('takes initials from the first and last word', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar(name: 'Ada Lovelace')));

      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('a single word gives one initial', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar(name: 'Prince')));

      expect(find.text('P'), findsOneWidget);
    });

    testWidgets('a middle name does not get a letter', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthAvatar(name: 'Ada  Byron   Lovelace')),
      );

      // Extra whitespace collapses too, which is what a name typed
      // into a form actually looks like.
      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('explicit initials win over a name', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthAvatar(name: 'Ada Lovelace', initials: 'ZZ')),
      );

      expect(find.text('ZZ'), findsOneWidget);
      expect(find.text('AL'), findsNothing);
    });

    test('the derived colour is stable across runs', () {
      // Dart randomises String.hashCode per isolate, so a hash-based
      // colour would move between launches of the same app. This is
      // the property that made the sum-of-code-units worth writing.
      const palette = ['blue', 'red', 'green', 'gray'];
      final first = PlinthAvatar.colorFor('Ada Lovelace', palette);

      expect(PlinthAvatar.colorFor('Ada Lovelace', palette), equals(first));
      expect(palette, contains(first));
    });

    test('different names generally get different colours', () {
      const palette = ['blue', 'red', 'green', 'gray'];
      final assigned = {
        for (final n in ['Ada Lovelace', 'Alan Turing', 'Grace Hopper'])
          n: PlinthAvatar.colorFor(n, palette),
      };

      expect(assigned.values.toSet().length, greaterThan(1));
    });

    testWidgets('a name with no explicit colour still renders', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar(name: 'Grace Hopper')));

      expect(find.text('GH'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthCode.block', () {
    testWidgets('keeps every line instead of collapsing them', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCode.block('flutter pub get\nflutter run')),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, contains('\n'));
      // Wrapping a line of code silently rewrites it, so a block
      // scrolls sideways rather than reflowing.
      expect(text.softWrap, isFalse);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('the inline form still wraps and does not scroll',
        (tester) async {
      await tester.pumpWidget(_wrap(const PlinthCode('flutter pub get')));

      expect(tester.widget<Text>(find.byType(Text)).softWrap, isTrue);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('a block fills the width, an inline snippet does not',
        (tester) async {
      // Aligned rather than sized: a tight SizedBox would force both
      // forms to the same width and prove nothing.
      await tester.pumpWidget(
        _wrap(const Align(
          alignment: Alignment.topLeft,
          child: PlinthCode.block('x'),
        )),
      );
      expect(tester.getSize(find.byType(PlinthCode)).width, equals(600));

      await tester.pumpWidget(
        _wrap(const Align(
          alignment: Alignment.topLeft,
          child: PlinthCode('x'),
        )),
      );
      expect(tester.getSize(find.byType(PlinthCode)).width, lessThan(600));
    });
  });

  group('PlinthContainer.fluid', () {
    /// The container's own constrained box, not one of the several an
    /// app scaffold puts above it.
    ///
    /// A ConstrainedBox sizes to its child rather than to its cap, so
    /// every fixture here gives it a child that wants all the width —
    /// otherwise this measures the child and always passes.
    double containerWidth(WidgetTester tester) => tester
        .getSize(find
            .descendant(
              of: find.byType(PlinthContainer),
              matching: find.byType(ConstrainedBox),
            )
            .first)
        .width;

    testWidgets('constrains to its size by default', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthContainer(
            size: PlinthContainerSize.xs,
            child: SizedBox(width: double.infinity, height: 10),
          ),
          width: 700,
        ),
      );

      expect(containerWidth(tester), equals(540));
    });

    testWidgets('fluid fills the width it is given', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthContainer(
            size: PlinthContainerSize.xs,
            fluid: true,
            child: SizedBox(width: double.infinity, height: 10),
          ),
          width: 700,
        ),
      );

      expect(containerWidth(tester), equals(700));
    });

    testWidgets('fluid keeps its horizontal padding', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthContainer(
            fluid: true,
            child: SizedBox(height: 10, child: Text('Body')),
          ),
          width: 700,
        ),
      );

      // The padding is the half of this that a plain SizedBox would
      // not have given you.
      expect(tester.getSize(find.text('Body')).width, lessThan(700));
    });
  });

  group('PlinthGroup.grow', () {
    testWidgets('children share the width equally', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthGroup(
            wrap: false,
            grow: true,
            children: [Text('One'), Text('Two'), Text('Three')],
          ),
        ),
      );

      final widths = ['One', 'Two', 'Three']
          .map((t) => tester.getSize(find.text(t)).width)
          .toList();
      expect(widths[0], closeTo(widths[1], 0.01));
      expect(widths[1], closeTo(widths[2], 0.01));
      // And they actually fill: three equal shares of 600 less gaps.
      expect(widths[0], greaterThan(150));
    });

    testWidgets('without grow each child takes its own width', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthGroup(
            wrap: false,
            children: [Text('One'), Text('Threeeeeeee')],
          ),
        ),
      );

      expect(
        tester.getSize(find.text('One')).width,
        lessThan(tester.getSize(find.text('Threeeeeeee')).width),
      );
    });

    testWidgets('grow inside a wrap asserts rather than silently doing nothing',
        (tester) async {
      expect(
        () => PlinthGroup(grow: true, children: const [Text('One')]),
        throwsAssertionError,
      );
    });
  });

  group('PlinthSimpleGrid.minColWidth', () {
    Widget grid(double width, {double? minColWidth, int columns = 4}) {
      return _wrap(
        PlinthSimpleGrid(
          columns: columns,
          minColWidth: minColWidth,
          children: const [
            Text('a'),
            Text('b'),
            Text('c'),
            Text('d'),
            Text('e'),
            Text('f'),
          ],
        ),
        width: width,
      );
    }

    testWidgets('fits as many columns as clear the minimum', (tester) async {
      await tester.pumpWidget(grid(600, minColWidth: 180));

      // 600 wide, 16px gaps: three 189px columns clear 180, four would
      // be 138 and do not.
      expect(
          tester
              .widget<PlinthSimpleGrid>(find.byType(PlinthSimpleGrid))
              .columnsFor(600),
          greaterThanOrEqualTo(3));
      expect(tester.getSize(find.text('a')).width, greaterThanOrEqualTo(180));
    });

    testWidgets('the gaps are counted, not ignored', (tester) async {
      // Naively 600 / 200 is exactly 3, but two 16px gaps leave 189
      // per column — under the minimum. It has to step down to 2.
      const g = PlinthSimpleGrid(columns: 4, minColWidth: 200, children: []);
      expect(g.columnsFor(600), equals(3));

      await tester.pumpWidget(grid(600, minColWidth: 200));
      expect(tester.getSize(find.text('a')).width, greaterThanOrEqualTo(200));
    });

    testWidgets('never drops below one column', (tester) async {
      await tester.pumpWidget(grid(100, minColWidth: 500));

      expect(find.text('a'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('overrides the explicit column count', (tester) async {
      await tester.pumpWidget(grid(600, minColWidth: 500, columns: 4));

      // One 500-wide column fits in 600, not four.
      expect(tester.getSize(find.text('a')).width, greaterThan(400));
    });

    testWidgets('without it, the column count still rules', (tester) async {
      await tester.pumpWidget(grid(600, columns: 2));

      expect(tester.getSize(find.text('a')).width, closeTo(292, 1));
    });
  });

  group('PlinthMarquee.fadeEdges', () {
    testWidgets('off by default, so no layer is saved', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthMarquee(child: Text('Logos'))),
      );
      await tester.pump();

      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('masks the strip when asked', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthMarquee(fadeEdges: true, child: Text('Logos'))),
      );
      await tester.pump();

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(
        tester.widget<ShaderMask>(find.byType(ShaderMask)).blendMode,
        // dstIn fades the content's own alpha; a gradient overlay
        // would have to know the page colour behind the strip.
        equals(BlendMode.dstIn),
      );
    });

    testWidgets('the fade survives the stationary path too', (tester) async {
      // Reduce-motion renders a different subtree, and an effect that
      // only applied to the moving one would vanish for exactly the
      // users most likely to have it on.
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: PlinthMarquee(fadeEdges: true, child: Text('Logos')),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });

  group('PlinthTimeline.align', () {
    const items = [
      PlinthTimelineItem(title: 'Created', description: 'by Ada'),
      PlinthTimelineItem(title: 'Merged'),
    ];

    testWidgets('start puts the rail left of the text', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTimeline(items: items)));

      final dot = tester.getRect(find.byType(Container).first);
      expect(tester.getRect(find.text('Created')).left, greaterThan(dot.left));
    });

    testWidgets('end puts the rail right of the text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTimeline(
            items: items,
            align: PlinthTimelineAlign.end,
          ),
        ),
      );

      final dot = tester.getRect(find.byType(Container).first);
      expect(tester.getRect(find.text('Created')).right, lessThan(dot.right));
    });

    testWidgets('end right-aligns the text with it', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTimeline(
            items: items,
            align: PlinthTimelineAlign.end,
          ),
        ),
      );

      // Ragged-left, so both lines end on the rail rather than
      // trailing away from it.
      expect(
        tester.getRect(find.text('Created')).right,
        closeTo(tester.getRect(find.text('by Ada')).right, 1),
      );
    });

    testWidgets('both alignments render every item', (tester) async {
      for (final align in PlinthTimelineAlign.values) {
        await tester.pumpWidget(
          _wrap(PlinthTimeline(items: items, align: align)),
        );

        expect(find.text('Created'), findsOneWidget);
        expect(find.text('Merged'), findsOneWidget);
      }
    });
  });
}
