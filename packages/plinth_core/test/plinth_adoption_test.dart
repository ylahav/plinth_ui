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

/// CIE76 ΔE — perceptual distance, which is the thing a categorical
/// palette has to guarantee. Contrast ratio cannot answer it: two
/// colours can sit at the same luminance and be entirely different
/// colours, which is exactly the case a chart legend cares about.
List<double> _lab(Color c) {
  double inv(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  final r = inv(c.r), g = inv(c.g), b = inv(c.b);
  final x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047;
  final y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  final z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883;
  double f(double t) =>
      t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : 7.787 * t + 16 / 116;
  final fx = f(x), fy = f(y), fz = f(z);
  return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
}

double _deltaE(Color a, Color b) {
  final p = _lab(a), q = _lab(b);
  return math.sqrt(math.pow(p[0] - q[0], 2) +
      math.pow(p[1] - q[1], 2) +
      math.pow(p[2] - q[2], 2));
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

  group('PR-04 — a categorical series palette', () {
    // 36 of the app's 91 hardcoded colours were chart series, and they
    // were the hardest 36 to migrate. The property they needed was not
    // brand or status: adjacent slices must be tellable apart.

    test('the separation guarantee holds, and is what is documented', () {
      // The claim in kDefaultSeriesRamps' doc, asserted rather than
      // asserted-in-prose. If someone reorders the list or swaps a
      // ramp, this is what says the palette got worse.
      final colors = [
        for (var i = 0; i < kDefaultSeriesRamps.length; i++) light.series(i)
      ];

      var minPair = double.infinity;
      var minAdjacent = double.infinity;
      for (var i = 0; i < colors.length; i++) {
        for (var j = i + 1; j < colors.length; j++) {
          final d = _deltaE(colors[i], colors[j]);
          if (d < minPair) minPair = d;
          if (j == i + 1 && d < minAdjacent) minAdjacent = d;
        }
      }
      expect(minPair, greaterThan(30.0), reason: 'worst pair, CIE76 ΔE');
      expect(minAdjacent, greaterThan(110.0), reason: 'closest neighbours');
    });

    test('gray is not in the sequence', () {
      // A neutral among the series makes one look disabled.
      expect(kDefaultSeriesRamps, isNot(contains('gray')));
    });

    test('series wraps rather than throwing past the end', () {
      final n = kDefaultSeriesRamps.length;
      expect(light.series(n), equals(light.series(0)));
      expect(light.series(n * 3 + 2), equals(light.series(2)));
    });

    test('a registered key gets its pinned colour', () {
      final t = light.copyWith(seriesKeys: const {'groceries': 3});
      expect(t.hasSeriesKey('groceries'), isTrue);
      expect(t.seriesIndexFor('groceries'), 3);
      expect(t.seriesFor('groceries'), equals(t.series(3)));
    });

    test('an unregistered key still resolves, and stays put', () {
      // The failure this prevents: a chart whose colours reshuffle on
      // restart. Values are pinned, not just compared to themselves,
      // so a change to the hash shows up here.
      expect(light.hasSeriesKey('crypto'), isFalse);
      expect(light.seriesIndexFor('crypto'), 2);
      expect(light.seriesIndexFor('il'), 8);
      expect(light.seriesIndexFor('emerging'), 3);
      expect(light.seriesIndexFor('gold'), 5);
      expect(light.seriesIndexFor('us'), 9);
      expect(light.seriesIndexFor(''), 1);
    });

    test('two keys can collide, which is why registration exists', () {
      // Recorded rather than hidden: the hash spreads keys, it does not
      // separate them. 'transport' and 'groceries' both land on 0, and
      // an app charting both must pin at least one.
      expect(light.seriesIndexFor('transport'), 0);
      expect(light.seriesIndexFor('groceries'), 0);
      expect(
          light.seriesFor('transport'), equals(light.seriesFor('groceries')));

      final pinned = light.copyWith(seriesKeys: const {'groceries': 4});
      expect(pinned.seriesFor('transport'),
          isNot(equals(pinned.seriesFor('groceries'))));
    });

    test('registration overrides the hash for that key only', () {
      final t = light.copyWith(seriesKeys: const {'crypto': 0});
      expect(t.seriesIndexFor('crypto'), 0);
      expect(t.seriesIndexFor('il'), light.seriesIndexFor('il'));
    });

    test('a name survives the layer boundary the engine cannot cross', () {
      // The constraint PR-04 records: the engine layer is pure Dart and
      // must not import a theme, so what crosses is a key.
      const fromPureDartEngine = 'transport';
      expect(
          light.seriesFor(fromPureDartEngine),
          equals(dark
              .copyWith(brightness: Brightness.light)
              .series(light.seriesIndexFor(fromPureDartEngine))));
    });

    test('series follows the theme into dark', () {
      // shaded() mirrors, so a series colour is the dark-theme member of
      // the same ramp rather than the identical pixel.
      expect(dark.series(0), equals(dark.shaded(kDefaultSeriesRamps[0], 6)));
      expect(dark.series(0), isNot(equals(light.series(0))));
    });

    test('an empty sequence degrades instead of crashing', () {
      final t = light.copyWith(seriesRamps: const []);
      expect(t.series(0), equals(t.shaded(t.primaryColor, 6)));
      expect(t.seriesIndexFor('anything'), 0);
    });

    test('copyWith round-trips both fields', () {
      expect(light.copyWith().seriesRamps, same(light.seriesRamps));
      expect(light.copyWith().seriesKeys, same(light.seriesKeys));
    });
  });

  group('PR-03 — a supplied brand colour comes back out', () {
    // The whole point: shade 6 is what every component defaults to, so
    // "my brand colour" and "what a filled button paints" have to be
    // the same colour.
    const brands = {
      'expense': 0xFFFF3B30,
      'income': 0xFF34C759,
      'warn': 0xFFFF9500,
      'pension': 0xFFAF52DE,
      'material-green-800': 0xFF2E7D32,
    };

    for (final entry in brands.entries) {
      test('${entry.key} is returned exactly at shade 6', () {
        final base = Color(entry.value);
        expect(PlinthTheme.generateShades(base)[6], equals(base));
      });
    }

    test('the ramp stays monotonic for every brand colour', () {
      for (final value in brands.values) {
        final ramp = PlinthTheme.generateShades(Color(value));
        for (var i = 1; i < 10; i++) {
          expect(_luminance(ramp[i]), lessThan(_luminance(ramp[i - 1])),
              reason: 'shade $i of ${value.toRadixString(16)}');
        }
      }
    });

    test('both endpoints stay put, so shade 0 is still a tint', () {
      // Only the interior stretches. A wash reads as tinted surface
      // whatever colour was fed in.
      for (final value in brands.values) {
        final ramp = PlinthTheme.generateShades(Color(value));
        expect(ratio(ramp[0], const Color(0xFFFFFFFF)), lessThan(1.5),
            reason: 'shade 0 of ${value.toRadixString(16)} is not a tint');
      }
    });

    test('a near-white or near-black base still anchors', () {
      // Degenerate but honest: a near-white base has no lighter tint,
      // so the endpoint widens rather than the anchor moving.
      for (final v in [0xFFFAFAFA, 0xFF0A0A0A]) {
        final base = Color(v);
        expect(PlinthTheme.generateShades(base)[6], equals(base));
      }
    });
  });

  group('PR-16 — the built-in palette is really Mantine', () {
    // The ramps are seeded with Mantine's own shade-6 values and, before
    // anchoring, none of them survived the generator: red came back
    // #E90707 rather than #FA5252, violet #4511DF rather than #7950F2.
    const mantineShade6 = {
      'gray': 0xFF868E96,
      'red': 0xFFFA5252,
      'pink': 0xFFE64980,
      'grape': 0xFFBE4BDB,
      'violet': 0xFF7950F2,
      'indigo': 0xFF4C6EF5,
      'blue': 0xFF228BE6,
      'cyan': 0xFF15AABF,
      'teal': 0xFF12B886,
      'green': 0xFF40C057,
      'lime': 0xFF82C91E,
      'yellow': 0xFFFAB005,
      'orange': 0xFFFD7E14,
    };

    for (final entry in mantineShade6.entries) {
      test('${entry.key}.6 matches Mantine', () {
        expect(light.color(entry.key, 6), equals(Color(entry.value)));
      });
    }

    test('every documented ramp is covered by this check', () {
      expect(light.colors.keys.toSet(), equals(mantineShade6.keys.toSet()));
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
