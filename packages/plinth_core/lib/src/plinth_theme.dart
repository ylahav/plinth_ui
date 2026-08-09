import 'package:flutter/material.dart';

import 'tokens.dart';

/// Default spacing scale (in logical pixels), matching Mantine's defaults.
const Map<PlinthSize, double> kDefaultSpacing = {
  PlinthSize.xs: 10,
  PlinthSize.sm: 12,
  PlinthSize.md: 16,
  PlinthSize.lg: 20,
  PlinthSize.xl: 32,
};

/// Default corner radius scale (in logical pixels).
const Map<PlinthSize, double> kDefaultRadius = {
  PlinthSize.xs: 2,
  PlinthSize.sm: 4,
  PlinthSize.md: 8,
  PlinthSize.lg: 16,
  PlinthSize.xl: 32,
};

/// Default font size scale (in logical pixels).
const Map<PlinthSize, double> kDefaultFontSizes = {
  PlinthSize.xs: 12,
  PlinthSize.sm: 14,
  PlinthSize.md: 16,
  PlinthSize.lg: 18,
  PlinthSize.xl: 20,
};

/// The design-token layer for Plinth. Every Plinth widget reads its
/// colors, spacing, radius, and font sizes from an instance of this
/// class rather than hardcoding values, so a single theme swap
/// restyles the whole app.
///
/// Register it on your [ThemeData]:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [PlinthTheme.defaultTheme],
///   ),
/// )
/// ```
@immutable
class PlinthTheme extends ThemeExtension<PlinthTheme> {
  const PlinthTheme({
    required this.colors,
    required this.primaryColor,
    this.spacing = kDefaultSpacing,
    this.radius = kDefaultRadius,
    this.fontSizes = kDefaultFontSizes,
    this.defaultRadius = PlinthSize.sm,
  });

  /// Named color palettes (e.g. 'blue', 'red', 'gray'), each with a
  /// 10-shade ramp from lightest (0) to darkest (9), mirroring Mantine.
  final Map<String, PlinthColorShades> colors;

  /// The key into [colors] used by components when no explicit
  /// `color` prop is given.
  final String primaryColor;

  final Map<PlinthSize, double> spacing;
  final Map<PlinthSize, double> radius;
  final Map<PlinthSize, double> fontSizes;

  /// The radius used when a component doesn't specify a [PlinthSize]
  /// for its `radius` prop.
  final PlinthSize defaultRadius;

  /// Resolves a color name + shade index to a concrete [Color].
  /// Falls back to [primaryColor] if the name isn't found.
  Color color(String name, int shade) {
    final ramp = colors[name] ?? colors[primaryColor]!;
    return ramp[shade.clamp(0, ramp.length - 1)];
  }

  static final PlinthTheme defaultTheme = PlinthTheme(
    primaryColor: 'blue',
    colors: {
      'blue': _generateShades(const Color(0xFF228BE6)),
      'red': _generateShades(const Color(0xFFFA5252)),
      'green': _generateShades(const Color(0xFF40C057)),
      'gray': _generateShades(const Color(0xFF868E96)),
    },
  );

  /// Generates a 10-shade ramp from a single base color, following
  /// the same idea as Mantine's/most design systems' generated
  /// palettes: light shades are desaturated tints suitable for
  /// backgrounds, dark shades are more saturated for contrast and
  /// text-on-color use, and shade 6 — the shade [PlinthButton] and
  /// friends default to for filled/base color — lands closest to
  /// how a typical brand color actually reads.
  ///
  /// Hue is held fixed across the ramp. Real Mantine palettes also
  /// drift hue slightly at the extremes (a common trick for richer
  /// darks/lights); that's a reasonable future improvement but isn't
  /// implemented here.
  static PlinthColorShades _generateShades(Color base) {
    final baseHsl = HSLColor.fromColor(base);
    final hue = baseHsl.hue;

    // Non-linear lightness stops (index 0 = lightest, 9 = darkest).
    // Front-loaded spacing keeps shades 0-2 usable as subtle
    // backgrounds without washing out, while 5-6 stay close to the
    // base color's natural saturation/lightness for filled buttons,
    // badges, etc.
    const lightnessStops = [
      0.96, 0.91, 0.83, 0.74, 0.64, 0.55, 0.47, 0.39, 0.32, 0.25,
    ];

    // Light shades are pulled toward white (desaturated) so they
    // read as soft tints rather than pale versions of the same hue;
    // dark shades are boosted slightly for richness.
    const saturationMultipliers = [
      0.55, 0.65, 0.75, 0.85, 0.92, 1.0, 1.0, 0.95, 0.90, 0.85,
    ];

    return List.generate(10, (i) {
      final lightness = lightnessStops[i].clamp(0.0, 1.0);
      final saturation =
          (baseHsl.saturation * saturationMultipliers[i]).clamp(0.0, 1.0);
      return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
    });
  }

  @override
  PlinthTheme copyWith({
    Map<String, PlinthColorShades>? colors,
    String? primaryColor,
    Map<PlinthSize, double>? spacing,
    Map<PlinthSize, double>? radius,
    Map<PlinthSize, double>? fontSizes,
    PlinthSize? defaultRadius,
  }) {
    return PlinthTheme(
      colors: colors ?? this.colors,
      primaryColor: primaryColor ?? this.primaryColor,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      fontSizes: fontSizes ?? this.fontSizes,
      defaultRadius: defaultRadius ?? this.defaultRadius,
    );
  }

  @override
  PlinthTheme lerp(ThemeExtension<PlinthTheme>? other, double t) {
    if (other is! PlinthTheme) return this;
    // Colors/spacing maps aren't meaningfully lerped key-by-key here;
    // snap at the midpoint. Replace with per-key Color.lerp if you
    // need smooth theme-transition animations.
    return t < 0.5 ? this : other;
  }
}

/// Convenience accessor: `context.plinth`.
extension PlinthThemeContext on BuildContext {
  PlinthTheme get plinth =>
      Theme.of(this).extension<PlinthTheme>() ?? PlinthTheme.defaultTheme;
}
