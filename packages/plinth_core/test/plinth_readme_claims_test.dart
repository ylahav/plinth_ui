// The figures quoted on plinth_core's pub.dev page, held to the theme.
//
// This exists because of readme_counts_test.dart's lesson, learned on
// the component count: a number in prose has nothing keeping it honest,
// and the README is the first thing a prospective adopter reads. The
// dartdoc on `readableOn` had drifted the same way — it claimed cyan
// shade 6 lands "near 2.2:1", and the measured figure is 2.79:1.
//
// Every snippet in the README is also exercised here, so a rename
// cannot leave the landing page showing code that no longer compiles.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

double _luminance(Color c) {
  double channel(double v) => v <= 0.03928
      ? v / 12.92
      : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

double _ratio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  final theme = PlinthTheme.defaultTheme;

  group('the README\'s contrast claims', () {
    test('exactly one ramp clears 4.5:1 at shade 6', () {
      final passing = [
        for (final name in theme.colors.keys)
          if (_ratio(theme.color(name, 6), theme.surface) >= 4.5) name,
      ];
      expect(passing, ['violet'],
          reason: 'the README says one ramp of thirteen passes, and '
              'names violet');
    });

    test('the three ratios it quotes', () {
      double on(String name) => _ratio(theme.color(name, 6), theme.surface);
      expect(on('violet'), closeTo(4.95, 0.005));
      expect(on('cyan'), closeTo(2.79, 0.005));
      expect(on('yellow'), closeTo(1.86, 0.005));
    });

    test('readableOn lifts cyan to the colour and ratio quoted', () {
      final fixed = theme.readableOn('cyan', theme.surface);
      expect(fixed, const Color(0xFF157785));
      expect(_ratio(fixed, theme.surface), closeTo(5.24, 0.005));
    });

    test('and returns violet untouched, because it already passed', () {
      expect(theme.readableOn('violet', theme.surface), theme.color('violet', 6));
    });

    test('#FF9500 on white is the 2.20:1 the role section quotes', () {
      expect(_ratio(const Color(0xFFFF9500), const Color(0xFFFFFFFF)),
          closeTo(2.20, 0.005));
    });
  });

  group('the README\'s snippets', () {
    test('the anchored ramp returns the brand colour at shade 6', () {
      expect(PlinthTheme.generateShades(const Color(0xFFFF3B30))[6],
          const Color(0xFFFF3B30));
    });

    test('a role resolves to three different colours', () {
      final t = theme.copyWith(
        semanticColors: const {
          'expense': PlinthSemanticColor('red'),
          'income': PlinthSemanticColor('green'),
        },
      );
      expect(t.semanticText('expense'), isNot(t.semantic('expense')),
          reason: 'the README says the fill and the label are '
              'deliberately different colours');
      expect(t.semanticWash('expense'), isNot(t.semantic('expense')));
      expect(_ratio(t.semanticText('expense'), t.surface),
          greaterThanOrEqualTo(4.5));
    });

    test('the disagreement check is empty against a derived scheme', () {
      expect(theme.colorSchemeDisagreements(theme.toColorScheme()), isEmpty);
    });

    test('the spacing scale agrees with itself', () {
      expect(PlinthSpacing.md, 16);
      expect(theme.spacing[PlinthSize.md], PlinthSpacing.md);
    });

    test('light and dark share the same ramps', () {
      expect(PlinthTheme.darkTheme.colors, same(theme.colors));
    });
  });
}
