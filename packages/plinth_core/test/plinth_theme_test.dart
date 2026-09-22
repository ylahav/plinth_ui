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
      //
      // `border` has since drifted on purpose. It was #CED4DA, which
      // is 1.49:1 on `surface` and 1.26:1 on `surfaceSunken`, and it
      // is the resting boundary of every input in the library — WCAG
      // 1.4.11 asks 3:1 of that. `theme.validate()` found it against
      // this library's own defaults. This line is still here to catch
      // the *next* drift, which will not be deliberate.
      final theme = PlinthTheme.defaultTheme;
      expect(theme.surface, const Color(0xFFFFFFFF));
      expect(theme.surfaceMuted, const Color(0xFFF1F3F5));
      expect(theme.surfaceSunken, const Color(0xFFE9ECEF));
      expect(theme.border, const Color(0xFF808890));
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

    test('durations and borderWidths cover every PlinthSize', () {
      final theme = PlinthTheme.defaultTheme;
      for (final size in PlinthSize.values) {
        expect(theme.durations[size], isNotNull,
            reason: 'missing duration for $size');
        expect(theme.borderWidths[size], isNotNull,
            reason: 'missing borderWidth for $size');
      }
    });

    test('weights, curves and elevations cover their own enums', () {
      final theme = PlinthTheme.defaultTheme;
      for (final w in PlinthWeight.values) {
        expect(theme.fontWeights[w], isNotNull, reason: 'missing weight $w');
      }
      for (final c in PlinthCurve.values) {
        expect(theme.curves[c], isNotNull, reason: 'missing curve $c');
      }
      for (final e in PlinthShadow.values) {
        expect(theme.elevations[e], isNotNull, reason: 'missing elevation $e');
      }
    });

    test('a partial override falls back rather than throwing', () {
      // A caller who sets one weight should not lose the other three.
      // The lookups take a fallback instead of `!` precisely so a
      // partial map degrades to the default rather than crashing in a
      // build method, where the stack trace says nothing useful.
      final theme = PlinthTheme.defaultTheme.copyWith(
        fontWeights: const {PlinthWeight.bold: FontWeight.w900},
        durations: const {PlinthSize.md: Duration(milliseconds: 1)},
        borderWidths: const {PlinthSize.md: 99},
        curves: const {PlinthCurve.standard: Curves.bounceIn},
        elevations: const {},
      );

      expect(theme.weight(PlinthWeight.bold), FontWeight.w900);
      expect(theme.weight(PlinthWeight.regular), FontWeight.w400);
      expect(theme.duration(PlinthSize.md), const Duration(milliseconds: 1));
      expect(theme.duration(PlinthSize.lg), const Duration(milliseconds: 300));
      expect(theme.borderWidth(PlinthSize.md), 99);
      expect(theme.borderWidth(PlinthSize.xs), 1);
      expect(theme.curve(PlinthCurve.standard), Curves.bounceIn);
      expect(theme.curve(PlinthCurve.linear), Curves.linear);
      expect(theme.elevation(PlinthShadow.md), isNotEmpty);
    });

    test('elevation paints in the theme shadow colour, not black', () {
      // The bug this scale exists to fix: `PlinthPaper` built its
      // shadows from a hardcoded `Colors.black`, so `PlinthTheme.shadow`
      // was a documented token that nothing ever painted with.
      final blue = PlinthTheme.defaultTheme.copyWith(
        shadow: const Color(0xFF0000FF),
      );
      final shadows = blue.elevation(PlinthShadow.md);

      expect(shadows, hasLength(1));
      expect(shadows.single.color.r, 0);
      expect(shadows.single.color.b, 1);
      expect(shadows.single.blurRadius, 10);
      expect(shadows.single.offset, const Offset(0, 4));
    });

    test('elevation none paints nothing at all', () {
      // Not a transparent shadow — an empty list. A BoxShadow that
      // paints nothing still costs a layer.
      expect(PlinthTheme.defaultTheme.elevation(PlinthShadow.none), isEmpty);
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
