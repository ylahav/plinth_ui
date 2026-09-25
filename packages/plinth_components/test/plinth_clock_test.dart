/// A duration as a display number.
///
/// Found while converting an existing app onto Plinth, where a rest
/// timer was a hand-rolled `GymClock` because `PlinthText` sized to 72
/// twitches sideways every second — proportional digits are different
/// widths.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Future<TextStyle> _styleOf(
  WidgetTester tester,
  PlinthClock clock, {
  PlinthTheme? theme,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [theme ?? PlinthTheme.defaultTheme]),
    home: Scaffold(body: Center(child: clock)),
  ));
  return tester.widget<Text>(find.byType(Text)).style!;
}

void main() {
  group('display type', () {
    testWidgets('digits are tabular, so the number does not shift',
        (tester) async {
      final style = await _styleOf(tester, const PlinthClock('01:30'));
      expect(
        style.fontFeatures,
        contains(const FontFeature.tabularFigures()),
        reason: 'the whole reason this is not PlinthText',
      );
    });

    testWidgets('line height is 1 and tracking is tight', (tester) async {
      final style =
          await _styleOf(tester, const PlinthClock('01:30', size: 72));
      expect(style.height, 1);
      expect(style.fontSize, 72);
      expect(style.letterSpacing, lessThan(0));
    });

    testWidgets('weight is 700 by default', (tester) async {
      final style = await _styleOf(tester, const PlinthClock('01:30'));
      expect(style.fontWeight, FontWeight.w700);
    });
  });

  group('the contrast floor follows the size', () {
    // yellow is the case that matters: it is light, so the large-text
    // floor and the body floor land on visibly different shades.
    testWidgets('a display size takes the large-text floor (3:1)',
        (tester) async {
      final theme = PlinthTheme.defaultTheme;
      final style =
          await _styleOf(tester, const PlinthClock('01:30', color: 'yellow'));

      expect(
          style.color,
          theme.readableOn('yellow', theme.surface,
              level: PlinthContrast.large),
          reason: '72px bold is large text; 4.5:1 would cost brand fidelity '
              'for nothing');
      expect(
        PlinthTheme.contrastRatio(style.color!, theme.surface),
        greaterThanOrEqualTo(3.0),
      );
    });

    testWidgets('but a small one falls back to body (4.5:1)', (tester) async {
      final theme = PlinthTheme.defaultTheme;
      final style = await _styleOf(
          tester,
          const PlinthClock('01:30',
              color: 'yellow', size: 14, weight: FontWeight.w400));

      expect(style.color,
          theme.readableOn('yellow', theme.surface, level: PlinthContrast.body),
          reason: 'at 14px regular it is body text, whatever it is called');
      expect(
        PlinthTheme.contrastRatio(style.color!, theme.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('bold lowers the large-text threshold, as WCAG does',
        (tester) async {
      final theme = PlinthTheme.defaultTheme;
      // 20px: large when bold, body when not.
      final bold = await _styleOf(
          tester, const PlinthClock('01:30', size: 20, color: 'yellow'));
      final regular = await _styleOf(
          tester,
          const PlinthClock('01:30',
              size: 20, color: 'yellow', weight: FontWeight.w400));

      expect(
          bold.color,
          theme.readableOn('yellow', theme.surface,
              level: PlinthContrast.large));
      expect(
          regular.color,
          theme.readableOn('yellow', theme.surface,
              level: PlinthContrast.body));
      expect(bold.color, isNot(regular.color),
          reason: 'if these matched the test would prove nothing');
    });

    testWidgets('no colour takes the theme text colour', (tester) async {
      final style = await _styleOf(tester, const PlinthClock('01:30'));
      expect(style.color, PlinthTheme.defaultTheme.text);
    });

    testWidgets('and it resolves against a dark surface too', (tester) async {
      final dark = PlinthTheme.darkTheme;
      final style = await _styleOf(
          tester, const PlinthClock('01:30', color: 'yellow'),
          theme: dark);
      expect(PlinthTheme.contrastRatio(style.color!, dark.surface),
          greaterThanOrEqualTo(3.0));
    });
  });

  group('what a screen reader hears', () {
    testWidgets('the raw value, when nothing better is given', (tester) async {
      await _styleOf(tester, const PlinthClock('01:30'));
      expect(find.text('01:30'), findsOneWidget);
    });

    testWidgets('a semanticLabel replaces it rather than doubling it',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: const Scaffold(
          body: Center(
            child: PlinthClock('01:30',
                semanticLabel: '1 minute 30 seconds remaining'),
          ),
        ),
      ));

      expect(find.bySemanticsLabel('1 minute 30 seconds remaining'),
          findsOneWidget);
      expect(find.bySemanticsLabel('01:30'), findsNothing,
          reason: 'announcing both would read the digits twice');
      handle.dispose();
    });
  });

  testWidgets('it does not tick', (tester) async {
    await _styleOf(tester, const PlinthClock('01:30'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('01:30'), findsOneWidget,
        reason: 'the caller owns the timer');
  });
}
