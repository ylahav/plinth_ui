/// `readableOn` has to find a passing shade whenever the ramp has one.
///
/// It chose which way to walk the ramp by asking whether the background's
/// luminance was above 0.5. Contrast against black equals contrast against
/// white at a luminance of about 0.18, not 0.5, so for a background between
/// the two the walk headed for the light end when the dark end would have
/// passed, and returned a failing colour while a passing one sat on the
/// ramp. It never showed in the library's own widgets, which pass a surface
/// that is near white or near black; it showed for an adopter placing a
/// palette colour on a mid-tone fill.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

/// The algorithm as it was, kept to prove the change moves nothing that
/// shipped code relies on.
Color _before(PlinthTheme t, String name, Color bg,
    {int from = 6, double target = 4.5}) {
  final start = t.shadeFor(from);
  final step = PlinthTheme.relativeLuminance(bg) > 0.5 ? 1 : -1;
  for (var shade = start; shade >= 0 && shade <= 9; shade += step) {
    final candidate = t.color(name, shade);
    if (PlinthTheme.contrastRatio(candidate, bg) >= target) return candidate;
  }
  return t.color(name, step > 0 ? 9 : 0);
}

void main() {
  final themes = {
    'light': PlinthTheme.defaultTheme,
    'dark': PlinthTheme.darkTheme,
  };

  group('readableOn finds a passing shade whenever the ramp has one', () {
    for (final entry in themes.entries) {
      test('${entry.key}: every ramp on every grey, 0-255', () {
        final theme = entry.value;
        final misses = <String>[];

        for (var v = 0; v <= 255; v++) {
          final bg = Color.fromARGB(255, v, v, v);
          for (final name in theme.colors.keys) {
            final anyPasses = theme.colors[name]!.any((shade) =>
                PlinthTheme.contrastRatio(shade, bg) >=
                PlinthContrast.body.ratio);
            if (!anyPasses) continue;

            final got = theme.readableOn(name, bg);
            if (PlinthTheme.contrastRatio(got, bg) <
                PlinthContrast.body.ratio) {
              misses.add('$name on grey $v');
            }
          }
        }

        expect(misses, isEmpty,
            reason: '${misses.length} misses, first: ${misses.take(5)}');
      });
    }

    test('the case that found it: violet on a mid-tone grey', () {
      // Luminance 0.283: above the 0.18 crossover, below the old 0.5 cut.
      const bg = Color(0xFF909090);
      final theme = PlinthTheme.defaultTheme;

      expect(
        PlinthTheme.contrastRatio(theme.readableOn('violet', bg), bg),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('an impossible floor still returns the best the ramp can do', () {
      // Nothing passes 21:1, so the answer is the ramp's strongest end, the
      // same as before: the fallback was never the problem.
      const bg = Color(0xFF808080);
      final theme = PlinthTheme.defaultTheme;
      final got = theme.readableOn('gray', bg, minRatio: 21);
      final best = theme.colors['gray']!
          .map((c) => PlinthTheme.contrastRatio(c, bg))
          .reduce(math.max);

      expect(PlinthTheme.contrastRatio(got, bg), closeTo(best, 1e-9));
    });
  });

  group('and what shipped code relies on does not move', () {
    // The library's own call sites pass a surface: near white in the light
    // theme, near black in the dark. If the answer for any of them changed,
    // so would a golden image, so this compares against the old algorithm
    // for every ramp, every starting shade and both floors.
    for (final entry in themes.entries) {
      test('${entry.key}: every surface, ramp, shade and floor', () {
        final theme = entry.value;
        final surfaces = {
          'surface': theme.surface,
          'surfaceMuted': theme.surfaceMuted,
          'surfaceSunken': theme.surfaceSunken,
        };
        var compared = 0;

        for (final s in surfaces.entries) {
          for (final name in theme.colors.keys) {
            for (var from = 0; from <= 9; from++) {
              for (final level in PlinthContrast.values) {
                expect(
                  theme.readableOn(name, s.value, from: from, level: level),
                  _before(theme, name, s.value,
                      from: from, target: level.ratio),
                  reason: '$name shade $from ${level.name} on ${s.key}',
                );
                compared++;
              }
            }
          }
        }
        expect(compared, 3 * 13 * 10 * 3);
      });
    }

    test('the washes the alert and pill paint on, in both themes', () {
      for (final theme in themes.values) {
        for (final name in theme.colors.keys) {
          for (final shade in [0, 1]) {
            final bg = theme.shaded(name, shade);
            expect(
              theme.readableOn(name, bg),
              _before(theme, name, bg),
              reason: '$name on shaded($shade) in ${theme.brightness.name}',
            );
          }
        }
      }
    });
  });
}
