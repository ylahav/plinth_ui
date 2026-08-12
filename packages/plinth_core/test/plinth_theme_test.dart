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

    test('light tokens keep the values components used to hardcode', () {
      // These were literals scattered across forty widget files before
      // they became tokens. Pinning them here is what makes that
      // extraction provably appearance-neutral — if one drifts, the
      // light theme changed and the goldens are stale.
      final theme = PlinthTheme.defaultTheme;
      expect(theme.surface, const Color(0xFFFFFFFF));
      expect(theme.surfaceMuted, const Color(0xFFF1F3F5));
      expect(theme.surfaceSunken, const Color(0xFFE9ECEF));
      expect(theme.border, const Color(0xFFCED4DA));
      expect(theme.borderMuted, const Color(0xFFDEE2E6));
      expect(theme.text, const Color(0xDD000000)); // was Colors.black87
      expect(theme.textMuted, const Color(0x8A000000)); // was black54
      expect(theme.textDisabled, const Color(0x42000000)); // was black26
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

  group('PlinthTheme.darkTheme', () {
    final light = PlinthTheme.defaultTheme;
    final dark = PlinthTheme.darkTheme;

    test('reports itself as dark', () {
      expect(dark.brightness, Brightness.dark);
      expect(light.brightness, Brightness.light);
    });

    test('inverts surfaces, text, and borders', () {
      expect(dark.surface, isNot(light.surface));
      expect(dark.surfaceMuted, isNot(light.surfaceMuted));
      expect(dark.surfaceSunken, isNot(light.surfaceSunken));
      expect(dark.border, isNot(light.border));
      expect(dark.text, isNot(light.text));
      expect(dark.textMuted, isNot(light.textMuted));
    });

    test('its surface is actually darker than its text', () {
      // The direction matters, not just the difference: swapping two
      // values would satisfy "they differ" while rendering dark text
      // on a dark panel.
      final surface = HSLColor.fromColor(dark.surface).lightness;
      final text = HSLColor.fromColor(dark.text).lightness;
      expect(surface, lessThan(text));
    });

    test('shares the color ramps rather than darkening them', () {
      // A blue button should be the same blue in either theme; what
      // changes is the neutral chrome around it.
      expect(dark.colors, same(light.colors));
      expect(dark.color('blue', 6), light.color('blue', 6));
    });

    test('keeps onFilled light in both themes', () {
      // A filled button is saturated either way, so its label stays
      // white. Flipping this with the theme is how you end up with
      // dark text on a dark-blue button.
      expect(dark.onFilled, light.onFilled);
    });

    test('copyWith carries the new tokens through', () {
      final custom = light.copyWith(surface: const Color(0xFF123456));
      expect(custom.surface, const Color(0xFF123456));
      // Untouched tokens must survive the copy.
      expect(custom.text, light.text);
      expect(custom.border, light.border);
    });
  });
}
