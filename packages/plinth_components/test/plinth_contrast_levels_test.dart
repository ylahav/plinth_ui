// PR-17 — which text is a heading, and which icons are non-text UI.
//
// The requirement's premise was that an alert title "plausibly
// qualifies" for WCAG's large-text floor. Measurement says it does not,
// and says something worse about the icons beside it. These pin the
// measurements so the audit cannot rot back into a guess.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double _cr(Color a, Color b) {
  final x = _lum(a), y = _lum(b);
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

/// WCAG 2.x large text: >= 18pt regular or >= 14pt bold. In logical
/// pixels at 96dpi that is 24 and 18.67.
const _largeRegularPx = 24.0;
const _largeBoldPx = 18.666666666666668;

bool _isLargeText(double px, FontWeight w) =>
    px >= _largeRegularPx ||
    (px >= _largeBoldPx && w.value >= FontWeight.w700.value);

Widget _wrap(Widget child, {PlinthTheme? theme}) => MaterialApp(
      theme: ThemeData(extensions: [theme ?? PlinthTheme.defaultTheme]),
      home: Scaffold(body: child),
    );

void main() {
  final light = PlinthTheme.defaultTheme;
  final dark = PlinthTheme.darkTheme;

  group('PR-17 — the heading threshold, measured', () {
    test('PlinthTitle orders 1-3 are large text and 4-6 are not', () {
      // 34/26/22 at w700; 18/16/14 at w600.
      expect(_isLargeText(34, FontWeight.w700), isTrue);
      expect(_isLargeText(26, FontWeight.w700), isTrue);
      expect(_isLargeText(22, FontWeight.w700), isTrue);
      expect(_isLargeText(18, FontWeight.w600), isFalse);
      expect(_isLargeText(16, FontWeight.w600), isFalse);
      expect(_isLargeText(14, FontWeight.w600), isFalse);
    });

    test('an alert title does NOT qualify, which is the finding', () {
      // PlinthText defaults to PlinthSize.md (16px); the banners pass
      // w700. 16 is short of the 18.67 a bold face needs, so the
      // requirement's premise was wrong and the muted title colours are
      // correct rather than over-corrected.
      expect(light.fontSizes[PlinthSize.md], 16);
      expect(_isLargeText(16, FontWeight.w700), isFalse);
    });

    testWidgets('a large title takes the looser floor', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTitle('Heading', order: 1, color: 'yellow')),
      );
      final style = tester.widget<Text>(find.text('Heading')).style!;
      expect(
          style.color,
          light.readableOn('yellow', light.surface,
              level: PlinthContrast.large));
      // And it stays nearer the brand than the body floor would allow.
      expect(_cr(style.color!, light.surface),
          lessThan(PlinthContrast.body.ratio));
    });

    testWidgets('a small title keeps the body floor', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTitle('Heading', order: 5, color: 'yellow')),
      );
      final style = tester.widget<Text>(find.text('Heading')).style!;
      expect(style.color, light.readableOn('yellow', light.surface));
      expect(_cr(style.color!, light.surface),
          greaterThanOrEqualTo(PlinthContrast.body.ratio - 0.1));
    });
  });

  group('PR-17 — banner icons are non-text UI', () {
    testWidgets('every alert icon clears 3:1 against its own background',
        (tester) async {
      // Before this, the icon was painted at a raw shade 6 and 7 of the
      // 13 ramps failed: yellow at 1.74:1, lime 1.91, green 2.19.
      for (final entry in {'light': light, 'dark': dark}.entries) {
        final theme = entry.value;
        for (final key in theme.colors.keys) {
          await tester.pumpWidget(
            _wrap(
              PlinthAlert(
                color: key,
                icon: const Icon(Icons.info_outline),
                child: const Text('Body'),
              ),
              theme: theme,
            ),
          );
          // PR-11 made theme changes animate, so a pump straight after
          // swapping the extension leaves the tree mid-transition and
          // `context.plinth` holding a lerped theme. Settle first.
          await tester.pumpAndSettle();
          final iconTheme = tester.widget<IconTheme>(
            find
                .ancestor(
                  of: find.byIcon(Icons.info_outline),
                  matching: find.byType(IconTheme),
                )
                .first,
          );
          expect(
            _cr(iconTheme.data.color!, theme.shaded(key, 0)),
            greaterThanOrEqualTo(PlinthContrast.nonText.ratio - 0.01),
            reason: '$key alert icon in ${entry.key}',
          );
        }
      }
    });

    testWidgets('every notification icon clears 3:1 against the surface',
        (tester) async {
      for (final entry in {'light': light, 'dark': dark}.entries) {
        final theme = entry.value;
        for (final key in theme.colors.keys) {
          await tester.pumpWidget(
            _wrap(
              PlinthNotification(
                color: key,
                icon: const Icon(Icons.info_outline),
                child: const Text('Body'),
              ),
              theme: theme,
            ),
          );
          // PR-11 made theme changes animate, so a pump straight after
          // swapping the extension leaves the tree mid-transition and
          // `context.plinth` holding a lerped theme. Settle first.
          await tester.pumpAndSettle();
          final iconTheme = tester.widget<IconTheme>(
            find
                .ancestor(
                  of: find.byIcon(Icons.info_outline),
                  matching: find.byType(IconTheme),
                )
                .first,
          );
          expect(
            _cr(iconTheme.data.color!, theme.surface),
            greaterThanOrEqualTo(PlinthContrast.nonText.ratio - 0.01),
            reason: '$key notification icon in ${entry.key}',
          );
        }
      }
    });
  });
}
