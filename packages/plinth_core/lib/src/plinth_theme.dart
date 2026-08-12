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

/// Surface, text, and border colors for the light theme.
///
/// These are *not* drawn from the color ramps. A ramp answers "what
/// does blue look like at shade 6"; these answer "what colour is a
/// panel, a body paragraph, a hairline" — the neutral chrome every
/// component paints regardless of which palette colour it was given.
/// Keeping them here rather than as literals inside widgets is what
/// makes a dark theme a matter of swapping values instead of editing
/// forty files.
const Color kLightSurface = Color(0xFFFFFFFF);
const Color kLightSurfaceMuted = Color(0xFFF1F3F5);
const Color kLightSurfaceSunken = Color(0xFFE9ECEF);
const Color kLightBorder = Color(0xFFCED4DA);
const Color kLightBorderMuted = Color(0xFFDEE2E6);
const Color kLightText = Color(0xDD000000);
const Color kLightTextMuted = Color(0x8A000000);
const Color kLightTextDisabled = Color(0x42000000);

/// The same set for the dark theme, using Mantine's `dark` ramp.
const Color kDarkSurface = Color(0xFF1A1B1E);
const Color kDarkSurfaceMuted = Color(0xFF25262B);
const Color kDarkSurfaceSunken = Color(0xFF2C2E33);
const Color kDarkBorder = Color(0xFF373A40);
const Color kDarkBorderMuted = Color(0xFF2C2E33);
const Color kDarkText = Color(0xFFC1C2C5);
const Color kDarkTextMuted = Color(0xFF909296);
const Color kDarkTextDisabled = Color(0xFF5C5F66);

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
    this.brightness = Brightness.light,
    this.surface = kLightSurface,
    this.surfaceMuted = kLightSurfaceMuted,
    this.surfaceSunken = kLightSurfaceSunken,
    this.border = kLightBorder,
    this.borderMuted = kLightBorderMuted,
    this.text = kLightText,
    this.textMuted = kLightTextMuted,
    this.textDisabled = kLightTextDisabled,
    this.onFilled = const Color(0xFFFFFFFF),
    this.shadow = const Color(0xFF000000),
    this.scrim = const Color(0xFF000000),
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

  /// Whether this theme reads as light or dark. Components rarely need
  /// to branch on it — the tokens below already carry the difference —
  /// but it's here for the cases that genuinely do, and for callers
  /// deciding which theme to register.
  final Brightness brightness;

  /// Panel and field backgrounds: cards, modals, drawers, inputs.
  final Color surface;

  /// A step back from [surface], for fills that should read as
  /// recessed rather than raised: disabled inputs, keyboard keys, the
  /// track behind a segmented control.
  final Color surfaceMuted;

  /// A further step back, for dividers, progress tracks, and skeleton
  /// placeholders — things that are structure rather than content.
  final Color surfaceSunken;

  /// The default hairline around inputs and bordered containers.
  final Color border;

  /// A softer border, for decoration rather than delineation.
  final Color borderMuted;

  /// Body text.
  final Color text;

  /// Secondary text: descriptions, captions, inactive labels.
  final Color textMuted;

  /// Text and icons in a disabled control.
  final Color textDisabled;

  /// Foreground for content sitting *on* a saturated fill — the label
  /// of a filled button, the tick in a checked checkbox.
  ///
  /// Deliberately not tied to [brightness]: a filled button is
  /// saturated in either theme, so its label stays white in both.
  /// Flipping this with the theme is the classic way to end up with
  /// dark text on a dark-blue button.
  final Color onFilled;

  /// Base color for elevation shadows, applied at low opacity.
  final Color shadow;

  /// Base color for the barrier behind a modal or drawer.
  final Color scrim;

  /// Resolves a color name + shade index to a concrete [Color].
  /// Falls back to [primaryColor] if the name isn't found.
  Color color(String name, int shade) {
    final ramp = colors[name] ?? colors[primaryColor]!;
    return ramp[shade.clamp(0, ramp.length - 1)];
  }

  /// Whether [colors] defines a ramp under [name].
  ///
  /// [color] deliberately falls back rather than throwing, which means
  /// a typo or an unavailable palette key renders as the primary color
  /// with no complaint. Use this when you need to know the difference —
  /// picking a swatch to offer in a UI, say, rather than rendering one.
  bool hasColor(String name) => colors.containsKey(name);

  /// The default palette: Mantine's standard color set, each generated
  /// from its base (shade 6) value.
  ///
  /// Keep this broad. An unrecognized key falls back to the primary
  /// color silently, so a palette missing a color that callers
  /// reasonably expect doesn't fail — it just quietly renders the wrong
  /// thing, which is harder to notice than an error would be.
  static final PlinthTheme defaultTheme = PlinthTheme(
    primaryColor: 'blue',
    colors: {
      'gray': _generateShades(const Color(0xFF868E96)),
      'red': _generateShades(const Color(0xFFFA5252)),
      'pink': _generateShades(const Color(0xFFE64980)),
      'grape': _generateShades(const Color(0xFFBE4BDB)),
      'violet': _generateShades(const Color(0xFF7950F2)),
      'indigo': _generateShades(const Color(0xFF4C6EF5)),
      'blue': _generateShades(const Color(0xFF228BE6)),
      'cyan': _generateShades(const Color(0xFF15AABF)),
      'teal': _generateShades(const Color(0xFF12B886)),
      'green': _generateShades(const Color(0xFF40C057)),
      'lime': _generateShades(const Color(0xFF82C91E)),
      'yellow': _generateShades(const Color(0xFFFAB005)),
      'orange': _generateShades(const Color(0xFFFD7E14)),
    },
  );

  /// The same palette as [defaultTheme], with the neutral chrome
  /// inverted.
  ///
  /// The color ramps are shared rather than darkened: a blue button
  /// should be the same blue in either theme, and Mantine takes the
  /// same approach. What changes is everything the ramps don't cover —
  /// surfaces, text, and borders.
  ///
  /// ```dart
  /// MaterialApp(
  ///   theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
  ///   darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
  /// )
  /// ```
  static final PlinthTheme darkTheme = PlinthTheme(
    primaryColor: defaultTheme.primaryColor,
    colors: defaultTheme.colors,
    brightness: Brightness.dark,
    surface: kDarkSurface,
    surfaceMuted: kDarkSurfaceMuted,
    surfaceSunken: kDarkSurfaceSunken,
    border: kDarkBorder,
    borderMuted: kDarkBorderMuted,
    text: kDarkText,
    textMuted: kDarkTextMuted,
    textDisabled: kDarkTextDisabled,
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
      0.96,
      0.91,
      0.83,
      0.74,
      0.64,
      0.55,
      0.47,
      0.39,
      0.32,
      0.25,
    ];

    // Light shades are pulled toward white (desaturated) so they
    // read as soft tints rather than pale versions of the same hue;
    // dark shades are boosted slightly for richness.
    const saturationMultipliers = [
      0.55,
      0.65,
      0.75,
      0.85,
      0.92,
      1.0,
      1.0,
      0.95,
      0.90,
      0.85,
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
    Brightness? brightness,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceSunken,
    Color? border,
    Color? borderMuted,
    Color? text,
    Color? textMuted,
    Color? textDisabled,
    Color? onFilled,
    Color? shadow,
    Color? scrim,
  }) {
    return PlinthTheme(
      colors: colors ?? this.colors,
      primaryColor: primaryColor ?? this.primaryColor,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      fontSizes: fontSizes ?? this.fontSizes,
      defaultRadius: defaultRadius ?? this.defaultRadius,
      brightness: brightness ?? this.brightness,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      border: border ?? this.border,
      borderMuted: borderMuted ?? this.borderMuted,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      onFilled: onFilled ?? this.onFilled,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
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
