import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

void main() {
  final theme = PlinthTheme.defaultTheme;

  group('PlinthAvatar', () {
    testWidgets('shows initials, uppercased', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar(initials: 'yl')));

      expect(find.text('YL'), findsOneWidget);
    });

    testWidgets('falls back to a person icon with no initials', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar()));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('treats empty initials as absent', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar(initials: '')));

      // Otherwise an empty string from a user record would render a
      // blank circle rather than the icon fallback.
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('every size renders', (tester) async {
      for (final size in PlinthSize.values) {
        await tester.pumpWidget(
          _wrap(PlinthAvatar(initials: 'AB', size: size)),
        );

        expect(find.text('AB'), findsOneWidget);
      }
    });

    testWidgets('is circular unless given a radius', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar(initials: 'AB')));
      final circular = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(PlinthAvatar),
          matching: find.byType(ClipRRect),
        ),
      );

      await tester.pumpWidget(
        _wrap(const PlinthAvatar(initials: 'AB', radius: PlinthSize.xs)),
      );
      final rounded = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(PlinthAvatar),
          matching: find.byType(ClipRRect),
        ),
      );

      expect(circular.borderRadius, isNot(rounded.borderRadius));
    });
  });

  group('PlinthBadge', () {
    testWidgets('renders its label uppercased', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthBadge('New')));

      // Uppercasing is the component's own styling, not something the
      // caller passes in — pass 'New' and get 'NEW'.
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('New'), findsNothing);
    });

    testWidgets('every variant renders without an unhandled case',
        (tester) async {
      for (final variant in PlinthVariant.values) {
        await tester.pumpWidget(
          _wrap(PlinthBadge(variant.name, variant: variant)),
        );

        expect(find.text(variant.name.toUpperCase()), findsOneWidget);
      }
    });

    testWidgets('the filled variant paints the base color', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBadge(
            'New',
            variant: PlinthVariant.filled,
            color: 'green',
          ),
        ),
      );

      final decoration = tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byType(PlinthBadge),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration! as BoxDecoration;
      expect(decoration.color, theme.color('green', 6));
    });

    testWidgets('the outline variant is transparent with a border',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBadge('New', variant: PlinthVariant.outline)),
      );

      final decoration = tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byType(PlinthBadge),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration! as BoxDecoration;
      expect(decoration.color, Colors.transparent);
      expect(decoration.border, isNotNull);
    });

    testWidgets('renders a leading icon', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBadge('New', leadingIcon: Icon(Icons.star))),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('PlinthProgress', () {
    testWidgets('renders at a valid value', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthProgress(value: 0.5)));

      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts both ends of the range', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthProgress(value: 0)));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_wrap(const PlinthProgress(value: 1)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects a value outside 0..1', (tester) async {
      // Asserted rather than clamped: a fraction above 1 means the
      // caller computed it wrong, and silently flooring it would hide
      // that.
      expect(() => PlinthProgress(value: 1.5), throwsAssertionError);
      expect(() => PlinthProgress(value: -0.1), throwsAssertionError);
    });

    testWidgets('fills the fraction it was given', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthProgress(value: 0.25)));
      await tester.pumpAndSettle();

      final box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, closeTo(0.25, 0.001));
    });

    testWidgets('uses the track color it was given', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthProgress(value: 0.5, trackColor: Color(0xFF123456)),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PlinthProgress),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.color, const Color(0xFF123456));
    });
  });

  group('PlinthProgress.sections', () {
    const parts = [
      PlinthProgressSection(value: 0.5, color: 'blue', label: 'Direct'),
      PlinthProgressSection(value: 0.3, color: 'teal', label: 'Search'),
    ];

    /// The widths the sections actually take inside a known-width bar.
    List<double> widths(WidgetTester tester) => tester
        .widgetList<AnimatedContainer>(
          find.descendant(
            of: find.byType(PlinthProgress),
            matching: find.byType(AnimatedContainer),
          ),
        )
        .map((c) => (c.constraints?.maxWidth) ?? double.nan)
        .toList();

    testWidgets('each part takes its fraction of the whole bar',
        (tester) async {
      await tester.pumpWidget(
        _wrap(SizedBox(
          width: 200,
          child: PlinthProgress.sections(sections: parts),
        )),
      );
      await tester.pumpAndSettle();

      // 0.5 and 0.3 of 200, *not* 5/8 and 3/8 of it: the parts are
      // fractions of the bar, so the last fifth stays track. Flex
      // would have normalised them and lost that.
      expect(widths(tester), [closeTo(100, 0.5), closeTo(60, 0.5)]);
    });

    testWidgets('parts summing above the whole are rejected', (tester) async {
      // Scaling raw counts is the caller's job — silently normalising
      // would turn "these are fractions" into "these are ratios"
      // depending on the data.
      expect(
        () => PlinthProgress.sections(
          sections: const [
            PlinthProgressSection(value: 0.8, color: 'blue'),
            PlinthProgressSection(value: 0.4, color: 'teal'),
          ],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('labelled parts are readable to a screen reader',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthProgress.sections(sections: parts)),
      );

      // A bar with no text in it otherwise reads as nothing at all.
      expect(find.bySemanticsLabel('Direct: 50%, Search: 30%'), findsOneWidget);
    });

    testWidgets('a ring takes the same sections', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthRingProgress.sections(sections: parts)),
      );

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Direct: 50%, Search: 30%'), findsOneWidget);
    });
  });

  group('PlinthText', () {
    testWidgets('renders its data', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthText('Hello')));

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('resolves size through the theme font scale', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthText('Hello', size: PlinthSize.xl)),
      );

      // The point of the component: a PlinthSize rather than a raw
      // fontSize double, so a theme swap restyles every label at once.
      final style = tester.widget<Text>(find.text('Hello')).style!;
      expect(style.fontSize, theme.fontSizes[PlinthSize.xl]);
    });

    testWidgets('resolves a color key to a legible shade', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthText('Hello', color: 'red')),
      );

      final style = tester.widget<Text>(find.text('Hello')).style!;
      // Not `color('red', 6)`. This is text, so it goes through
      // readableOn — and once the ramp generator was anchored, shade 6
      // became Mantine's actual red (#FA5252), which is ~3.6:1 on white
      // and does not clear the body-text floor. The old assertion
      // passed only because the un-anchored generator over-darkened
      // every ramp, hiding the gap.
      expect(style.color, theme.readableOn('red', theme.surface));
      expect(style.color, isNot(theme.color('red', 6)));
    });

    testWidgets('leaves color null to inherit the ambient style',
        (tester) async {
      await tester.pumpWidget(_wrap(const PlinthText('Hello')));

      final style = tester.widget<Text>(find.text('Hello')).style!;
      expect(style.color, isNull);
    });

    testWidgets('passes italic, weight, maxLines, and align through',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthText(
            'Hello',
            italic: true,
            weight: FontWeight.w700,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Hello'));
      expect(text.style!.fontStyle, FontStyle.italic);
      expect(text.style!.fontWeight, FontWeight.w700);
      expect(text.maxLines, 2);
      expect(text.textAlign, TextAlign.center);
    });
  });
}
