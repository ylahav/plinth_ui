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

    test('defines every color the components and demos reference', () {
      final theme = PlinthTheme.defaultTheme;
      // An unrecognized key resolves to the primary color silently, so
      // a missing ramp doesn't fail — it renders the wrong colour with
      // no complaint. These are the keys used as defaults inside
      // components (red for errors, yellow for Mark, gray for Code)
      // plus the ones the example app and gallery reach for.
      const expected = [
        'gray',
        'red',
        'pink',
        'grape',
        'violet',
        'indigo',
        'blue',
        'cyan',
        'teal',
        'green',
        'lime',
        'yellow',
        'orange',
      ];
      for (final name in expected) {
        expect(theme.hasColor(name), isTrue, reason: 'missing ramp: $name');
      }
    });

    test('hasColor distinguishes a real ramp from the fallback', () {
      final theme = PlinthTheme.defaultTheme;
      expect(theme.hasColor('blue'), isTrue);
      expect(theme.hasColor('not-a-real-color'), isFalse);
    });

    test('every ramp is distinct at shade 6', () {
      // Shade 6 is what components use for their base colour, so two
      // palette entries colliding there would make them interchangeable
      // in practice.
      final theme = PlinthTheme.defaultTheme;
      final bases = theme.colors.keys.map((k) => theme.color(k, 6)).toSet();
      expect(bases, hasLength(theme.colors.length));
    });

    test('spacing/radius/fontSizes cover every PlinthSize', () {
      final theme = PlinthTheme.defaultTheme;
      for (final size in PlinthSize.values) {
        expect(theme.spacing[size], isNotNull,
            reason: 'missing spacing for $size');
        expect(theme.radius[size], isNotNull,
            reason: 'missing radius for $size');
        expect(theme.fontSizes[size], isNotNull,
            reason: 'missing fontSize for $size');
      }
    });
  });
}
