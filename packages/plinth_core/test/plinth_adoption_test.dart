// The APIs added because a real app needed them and could not get them.
// Each group cites the requirement it closes; see
// docs/ADOPTION_REQUIREMENTS.md.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

double _luminance(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double ratio(Color a, Color b) {
  final x = _luminance(a), y = _luminance(b);
  final hi = x > y ? x : y, lo = x > y ? y : x;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  final light = PlinthTheme.defaultTheme;
  final dark = PlinthTheme.darkTheme;

  group('PR-02 — the ramp generator is public', () {
    test('an app can build a ramp from its own brand colour', () {
      final ramp = PlinthTheme.generateShades(const Color(0xFFFF3B30));
      expect(ramp, hasLength(10));
      for (var i = 1; i < 10; i++) {
        expect(_luminance(ramp[i]), lessThan(_luminance(ramp[i - 1])),
            reason: 'shade $i should be darker than ${i - 1}');
      }
    });

    test('it is the same function the built-in palette uses', () {
      expect(
        PlinthTheme.generateShades(const Color(0xFF228BE6)),
        equals(light.colors['blue']),
      );
    });
  });

  group('PR-01 — a semantic token tier', () {
    // The app wrote 110 lines of app_tokens.dart to get this, and it
    // only worked because `colors` accepts arbitrary keys. These pin
    // the declared replacement.
    PlinthTheme withPoles(PlinthTheme base) => base.copyWith(
          colors: {
            ...base.colors,
            'expenseRamp': PlinthTheme.generateShades(const Color(0xFFFF3B30)),
            'incomeRamp': PlinthTheme.generateShades(const Color(0xFF34C759)),
          },
          semanticColors: {
            'expense': const PlinthSemanticColor('expenseRamp'),
            'income': const PlinthSemanticColor('incomeRamp'),
          },
        );

    final lightPoles = withPoles(light);
    final darkPoles = withPoles(dark);

    test('a role resolves to its ramp, not to the primary colour', () {
      expect(lightPoles.hasSemantic('expense'), isTrue);
      expect(
        lightPoles.semantic('expense'),
        equals(lightPoles.shaded('expenseRamp', 6)),
      );
      expect(
        lightPoles.semantic('expense'),
        isNot(equals(lightPoles.shaded(lightPoles.primaryColor, 6))),
      );
    });

    test('the three roles are three different colours', () {
      // The whole point of the tier: a fill is not a label is not a
      // panel background.
      final fill = lightPoles.semantic('expense');
      final label = lightPoles.semanticText('expense');
      final panel = lightPoles.semanticWash('expense');
      expect(fill, isNot(equals(label)));
      expect(fill, isNot(equals(panel)));
      expect(label, isNot(equals(panel)));
    });

    for (final entry in {'light': lightPoles, 'dark': darkPoles}.entries) {
      test('${entry.key}: semanticText clears its declared floor', () {
        final theme = entry.value;
        for (final role in ['expense', 'income']) {
          final got = ratio(theme.semanticText(role), theme.surface);
          expect(got, greaterThanOrEqualTo(PlinthContrast.body.ratio),
              reason: '$role label on surface in ${entry.key}');
        }
      });

      test('${entry.key}: semanticWash stays near the surface', () {
        final theme = entry.value;
        for (final role in ['expense', 'income']) {
          expect(ratio(theme.semanticWash(role), theme.surface), lessThan(1.5),
              reason: '$role wash should read as tinted surface');
        }
      });
    }

    test('a role can be held to the large-text floor instead', () {
      // Per-role because the floor is a fact about the content. A
      // heading-only role can honestly sit at 3.0.
      final heading = light.copyWith(
        colors: {
          ...light.colors,
          'brandRamp': PlinthTheme.generateShades(const Color(0xFF34C759)),
        },
        semanticColors: {
          'brand': const PlinthSemanticColor(
            'brandRamp',
            level: PlinthContrast.large,
          ),
        },
      );
      final got = ratio(heading.semanticText('brand'), heading.surface);
      expect(got, greaterThanOrEqualTo(PlinthContrast.large.ratio));
      // And it stays closer to brand than the body floor would allow.
      expect(got, lessThan(PlinthContrast.body.ratio));
    });

    test('an undeclared role falls back to reading the name as a ramp', () {
      // Keeps the pre-semanticColors smuggling pattern rendering as it
      // did, and keeps semantic('blue') meaningful.
      expect(light.hasSemantic('blue'), isFalse);
      expect(light.semantic('blue'), equals(light.shaded('blue', 6)));
    });

    test('roles do not collide with the ramps components hardcode', () {
      // PR-09's failure mode: an app repurposing `red` as its expense
      // pole silently restyles every component error state.
      final theme = lightPoles;
      expect(theme.semantic('expense'), isNot(equals(theme.shaded('red', 6))));
      expect(theme.shaded('red', 6), equals(light.shaded('red', 6)),
          reason: 'declaring roles must not disturb the component ramps');
    });

    test('copyWith round-trips the roles', () {
      expect(lightPoles.copyWith().semanticColors,
          equals(lightPoles.semanticColors));
      expect(light.copyWith().semanticColors, isEmpty);
    });
  });

  group('PR-05 — wash survives the brightness flip', () {
    // The bug this closes: shaded(name, 0) mirrors to shade 9 in a dark
    // theme, turning the lightest tint into the most saturated shade.
    for (final entry in {'light': light, 'dark': dark}.entries) {
      test('${entry.key}: every wash stays near its surface', () {
        final theme = entry.value;
        for (final key in theme.colors.keys) {
          expect(
            ratio(theme.wash(key), theme.surface),
            lessThan(1.5),
            reason: '$key wash is too strong in ${entry.key}',
          );
        }
      });
    }

    test('shaded(name, 0) is what it must NOT be, in dark', () {
      // Regression guard on the reason wash exists at all.
      expect(ratio(dark.shaded('green', 0), dark.surface),
          greaterThan(ratio(dark.wash('green'), dark.surface)));
    });

    test('alpha scales the tint', () {
      expect(ratio(light.wash('red', alpha: 0.2), light.surface),
          greaterThan(ratio(light.wash('red', alpha: 0.05), light.surface)));
    });
  });

  group('PR-06 — contrast floors are named', () {
    test('body is the default, and it is 4.5', () {
      expect(PlinthContrast.body.ratio, 4.5);
      expect(PlinthContrast.large.ratio, 3.0);
      expect(PlinthContrast.nonText.ratio, 3.0);
    });

    for (final entry in {'light': light, 'dark': dark}.entries) {
      test('${entry.key}: the default clears AA for body text', () {
        final theme = entry.value;
        for (final key in theme.colors.keys) {
          expect(
            ratio(theme.readableOn(key, theme.surface), theme.surface),
            greaterThanOrEqualTo(4.4), // 4.5 less float slack
            reason: '$key on the ${entry.key} surface',
          );
        }
      });
    }

    test('an explicit minRatio still overrides the level', () {
      expect(
        light.readableOn('blue', light.surface, minRatio: 3.0),
        isNot(light.readableOn('blue', light.surface)),
      );
    });

    test('large is looser than body', () {
      final body =
          ratio(light.readableOn('orange', light.surface), light.surface);
      final large = ratio(
          light.readableOn('orange', light.surface,
              level: PlinthContrast.large),
          light.surface);
      expect(body, greaterThan(large));
    });
  });

  group('PR-07 — a spacing scale that reaches the values in use', () {
    test('the base unit is 4', () {
      expect(kSpaceUnit, 4);
    });

    test('the const scale covers what the library and its adopters use', () {
      // 4 and 8 are the two values plinth_components rebuilds by hand
      // (xs * 0.4, xs * 0.8) and the app used 29 and 128 times.
      expect(PlinthSpacing.xxs, 4);
      expect(PlinthSpacing.xs, 8);
      expect(PlinthSpacing.sm, 12);
      expect(PlinthSpacing.md, 16);
      expect(PlinthSpacing.lg, 24);
      expect(PlinthSpacing.xl, 32);
    });

    test('every step is a whole multiple of the base unit', () {
      for (final v in [
        PlinthSpacing.xxs,
        PlinthSpacing.xs,
        PlinthSpacing.sm,
        PlinthSpacing.md,
        PlinthSpacing.lg,
        PlinthSpacing.xl,
      ]) {
        expect(v % kSpaceUnit, 0, reason: '$v is not on the grid');
      }
    });

    test('space() computes runtime multiples', () {
      expect(light.space(1), 4);
      expect(light.space(2), 8);
      expect(light.space(4), 16);
      expect(light.space(1.5), 6);
    });
  });

  group('PR-10 — ThemeData.plinth', () {
    testWidgets('a helper holding a ThemeData can reach the tokens',
        (tester) async {
      final themed = ThemeData(extensions: [light]);
      expect(themed.plinth, same(light));
    });

    test('falls back rather than throwing when unregistered', () {
      expect(ThemeData().plinth, same(PlinthTheme.defaultTheme));
    });

    testWidgets('context.plinth and ThemeData.plinth agree', (tester) async {
      late PlinthTheme viaContext;
      late PlinthTheme viaThemeData;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [dark]),
        home: Builder(builder: (context) {
          viaContext = context.plinth;
          viaThemeData = Theme.of(context).plinth;
          return const SizedBox();
        }),
      ));
      expect(viaContext, same(viaThemeData));
      expect(viaContext, same(dark));
    });
  });
}
