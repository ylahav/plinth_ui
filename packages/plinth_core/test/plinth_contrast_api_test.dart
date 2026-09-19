// `contrastRatio` and `relativeLuminance` as public API.
//
// The library's whole pitch is a number — 4.5:1 — and until now a
// caller could only receive the answer (`readableOn` hands back a
// colour) and never ask the question. Every test in this repo, and the
// tutorial app's theme test, re-implemented the WCAG formula locally to
// check its own work. These pin the exposed version against the same
// published constants those local copies were written from, so the two
// cannot drift.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

void main() {
  group('PlinthTheme.contrastRatio', () {
    test('black on white is 21:1, the maximum the scale can express', () {
      expect(
        PlinthTheme.contrastRatio(
          const Color(0xFF000000),
          const Color(0xFFFFFFFF),
        ),
        closeTo(21.0, 0.01),
      );
    });

    test('a colour against itself is 1:1', () {
      expect(
        PlinthTheme.contrastRatio(
          const Color(0xFF228BE6),
          const Color(0xFF228BE6),
        ),
        closeTo(1.0, 0.0001),
      );
    });

    test('argument order does not matter', () {
      const a = Color(0xFF15AABF);
      const b = Color(0xFFFFFFFF);
      expect(
        PlinthTheme.contrastRatio(a, b),
        closeTo(PlinthTheme.contrastRatio(b, a), 0.0001),
      );
    });

    test('it reports the three ratios the README quotes', () {
      // The same numbers `plinth_readme_claims_test.dart` pins with its
      // own local implementation — if these two ever disagree, one of
      // them is wrong and the public one is what adopters will use.
      const white = Color(0xFFFFFFFF);
      final theme = PlinthTheme.defaultTheme;

      expect(
        PlinthTheme.contrastRatio(theme.color('violet', 6), white),
        closeTo(4.95, 0.01),
      );
      expect(
        PlinthTheme.contrastRatio(theme.color('cyan', 6), white),
        closeTo(2.79, 0.01),
      );
      expect(
        PlinthTheme.contrastRatio(theme.color('yellow', 6), white),
        closeTo(1.86, 0.01),
      );
    });

    test('it agrees with what readableOn resolved', () {
      // `readableOn` walks the ramp until it clears the floor. The point
      // of exposing the ratio is that a caller can verify that claim
      // rather than take it, so: resolve, then measure.
      final theme = PlinthTheme.defaultTheme;

      for (final ramp in theme.colors.keys) {
        final resolved = theme.readableOn(ramp, theme.surface);
        expect(
          PlinthTheme.contrastRatio(resolved, theme.surface),
          greaterThanOrEqualTo(PlinthContrast.body.ratio),
          reason: '$ramp resolved to a colour under the body floor',
        );
      }
    });
  });

  group('PlinthTheme.relativeLuminance', () {
    test('black is 0 and white is 1', () {
      expect(
        PlinthTheme.relativeLuminance(const Color(0xFF000000)),
        closeTo(0.0, 0.0001),
      );
      expect(
        PlinthTheme.relativeLuminance(const Color(0xFFFFFFFF)),
        closeTo(1.0, 0.0001),
      );
    });

    test('it matches Flutter\'s own computeLuminance', () {
      // Flutter implements the same WCAG formula. Agreeing with it is
      // not required, but disagreeing would mean one of us has the
      // sRGB transfer function wrong.
      for (final color in [
        const Color(0xFF228BE6),
        const Color(0xFFFFD43B),
        const Color(0xFF12B886),
        const Color(0xFF7950F2),
      ]) {
        expect(
          PlinthTheme.relativeLuminance(color),
          closeTo(color.computeLuminance(), 0.0001),
          reason: '$color',
        );
      }
    });
  });
}
