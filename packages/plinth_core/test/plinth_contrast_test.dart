import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

/// WCAG 2.x relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG contrast ratio, 1.0 (identical) to 21.0 (black on white).
double _ratio(Color fg, Color bg) {
  final a = _luminance(fg);
  final b = _luminance(bg);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

/// Composites a translucent foreground over its background, since the
/// light theme's text tokens carry alpha.
Color _flatten(Color fg, Color bg) => Color.from(
      alpha: 1,
      red: fg.r * fg.a + bg.r * (1 - fg.a),
      green: fg.g * fg.a + bg.g * (1 - fg.a),
      blue: fg.b * fg.a + bg.b * (1 - fg.a),
    );

// WCAG AA: 4.5 for body text, 3.0 for large text and UI components.
const _aaText = 4.5;
const _aaLarge = 3.0;

void main() {
  final themes = {
    'light': PlinthTheme.defaultTheme,
    'dark': PlinthTheme.darkTheme,
  };

  group('body text contrast', () {
    for (final entry in themes.entries) {
      final theme = entry.value;

      test('${entry.key}: text on surface meets AA', () {
        expect(
          _ratio(_flatten(theme.text, theme.surface), theme.surface),
          greaterThanOrEqualTo(_aaText),
        );
      });

      test('${entry.key}: muted text on surface meets AA', () {
        // Secondary text is still body text — descriptions and captions
        // have to be readable, not merely present.
        expect(
          _ratio(_flatten(theme.textMuted, theme.surface), theme.surface),
          greaterThanOrEqualTo(_aaText),
        );
      });
    }
  });

  group('filled components', () {
    for (final entry in themes.entries) {
      final theme = entry.value;

      test('${entry.key}: every palette fill carries a legible label', () {
        // The reason contrastingOn exists. A fixed white foreground put
        // yellow at 2.12 and teal at 1.82 — visible as a pale smear
        // rather than a label. Picking per fill keeps every colour in
        // the palette usable for a filled button or badge.
        for (final key in theme.colors.keys) {
          final fill = theme.shaded(key, 6);
          final fg = theme.contrastingOn(fill);
          expect(
            _ratio(fg, fill),
            greaterThanOrEqualTo(_aaLarge),
            reason: '$key at shade 6 in ${entry.key}',
          );
        }
      });

      test('${entry.key}: contrastingOn never picks the worse option', () {
        for (final key in theme.colors.keys) {
          final fill = theme.shaded(key, 6);
          final chosen = _ratio(theme.contrastingOn(fill), fill);
          final rejected = theme.contrastingOn(fill) == theme.onFilled
              ? _ratio(theme.onFilledInverse, fill)
              : _ratio(theme.onFilled, fill);
          expect(chosen, greaterThanOrEqualTo(rejected), reason: key);
        }
      });
    }
  });

  group('accent text', () {
    for (final entry in themes.entries) {
      final theme = entry.value;

      test('${entry.key}: palette accents are legible on the surface', () {
        // Two separate corrections are needed here. Mirroring fixes the
        // theme half — an unmirrored shade 6 put violet at 1.97 against
        // the dark surface. readableOn fixes the palette half: no
        // single shade index serves every hue, since cyan at shade 6 is
        // far lighter than violet at shade 6.
        for (final key in theme.colors.keys) {
          expect(
            _ratio(theme.readableOn(key, theme.surface), theme.surface),
            greaterThanOrEqualTo(_aaLarge),
            reason: '$key accent in ${entry.key}',
          );
        }
      });

      test('${entry.key}: accent-on-tint stays legible', () {
        // The `light` variant pairs a tint fill with an accent label,
        // and both mirror together — so the pairing has to survive the
        // flip as well as the hue differences.
        for (final key in theme.colors.keys) {
          final tint = theme.shaded(key, 1);
          expect(
            _ratio(theme.readableOn(key, tint), tint),
            greaterThanOrEqualTo(_aaLarge),
            reason: '$key light-variant in ${entry.key}',
          );
        }
      });
    }
  });

  group('shade mirroring', () {
    test('light leaves shades untouched', () {
      expect(PlinthTheme.defaultTheme.shadeFor(6), 6);
      expect(PlinthTheme.defaultTheme.shadeFor(0), 0);
    });

    test('dark mirrors across the ramp', () {
      expect(PlinthTheme.darkTheme.shadeFor(6), 3);
      expect(PlinthTheme.darkTheme.shadeFor(0), 9);
      expect(PlinthTheme.darkTheme.shadeFor(1), 8);
    });

    test('a wash stays lighter than its accent in both themes', () {
      // The role each shade plays has to survive mirroring: whatever
      // the numbers, the alert background must stay a wash behind its
      // accent rather than swapping places with it.
      for (final theme in themes.values) {
        final wash = _luminance(theme.shaded('blue', 0));
        final accent = _luminance(theme.shaded('blue', 6));
        final expectWashLighter = theme.brightness == Brightness.light;
        expect(
          wash > accent,
          expectWashLighter,
          reason: 'wash/accent ordering in ${theme.brightness}',
        );
      }
    });
  });
}
