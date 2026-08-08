import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

void main() {
  group('PlinthTheme.defaultTheme', () {
    test('generates exactly 10 shades per color', () {
      for (final ramp in PlinthTheme.defaultTheme.colors.values) {
        expect(ramp, hasLength(10));
      }
    });

    test('shade 0 is lighter than shade 9 for every color', () {
      for (final ramp in PlinthTheme.defaultTheme.colors.values) {
        final lightest = HSLColor.fromColor(ramp[0]).lightness;
        final darkest = HSLColor.fromColor(ramp[9]).lightness;
        expect(
          lightest,
          greaterThan(darkest),
          reason: 'shade 0 should read as lighter than shade 9',
        );
      }
    });

    test('color() falls back to primaryColor for an unknown name', () {
      final theme = PlinthTheme.defaultTheme;
      final fallback = theme.color('not-a-real-color', 6);
      final primary = theme.color(theme.primaryColor, 6);
      expect(fallback, equals(primary));
    });

    test('color() clamps out-of-range shade indices instead of throwing', () {
      final theme = PlinthTheme.defaultTheme;
      // Should not throw a RangeError for indices outside 0-9.
      expect(() => theme.color('blue', -5), returnsNormally);
      expect(() => theme.color('blue', 99), returnsNormally);
    });

    test('spacing/radius/fontSizes cover every PlinthSize', () {
      final theme = PlinthTheme.defaultTheme;
      for (final size in PlinthSize.values) {
        expect(theme.spacing[size], isNotNull, reason: 'missing spacing for $size');
        expect(theme.radius[size], isNotNull, reason: 'missing radius for $size');
        expect(theme.fontSizes[size], isNotNull, reason: 'missing fontSize for $size');
      }
    });
  });
}
