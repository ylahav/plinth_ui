import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A colored icon container matching Mantine's `ThemeIcon`: wraps an
/// icon in a themed background circle/square, for use as a leading
/// visual in list items, feature cards, etc.
///
/// ```dart
/// PlinthThemeIcon(
///   icon: const Icon(Icons.check),
///   color: 'green',
///   variant: PlinthVariant.filled,
/// )
/// ```
class PlinthThemeIcon extends StatelessWidget {
  const PlinthThemeIcon({
    super.key,
    required this.icon,
    this.variant = PlinthVariant.filled,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.circle = false,
  });

  final Widget icon;
  final PlinthVariant variant;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;

  /// Fully circular instead of rounded-square when true.
  final bool circle;

  static const Map<PlinthSize, double> _dimensions = {
    PlinthSize.xs: 22,
    PlinthSize.sm: 28,
    PlinthSize.md: 36,
    PlinthSize.lg: 44,
    PlinthSize.xl: 52,
  };

  static const Map<PlinthSize, double> _iconSizes = {
    PlinthSize.xs: 12,
    PlinthSize.sm: 16,
    PlinthSize.md: 20,
    PlinthSize.lg: 24,
    PlinthSize.xl: 28,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final baseColor = theme.shaded(colorKey, 6);
    final lightColor = theme.shaded(colorKey, 1);
    final dimension = _dimensions[size]!;
    final resolvedRadius =
        circle ? dimension / 2 : theme.radius[radius ?? theme.defaultRadius]!;

    final (background, foreground) = switch (variant) {
      PlinthVariant.filled => (baseColor, theme.contrastingOn(baseColor)),
      PlinthVariant.light => (
          lightColor,
          theme.readableOn(colorKey, lightColor,
              // A same-hue label on a same-hue tint cannot reach 4.5 and
              // stay recognisably that colour: in a dark theme the tint
              // is shade 8, and walking to body contrast lands on
              // near-white (cyan #90DFEA -> #F0F8F9), losing the hue the
              // variant exists to show. Pinned to `large` so raising the
              // default did not silently repaint this variant.
              level: PlinthContrast.large)
        ),
      PlinthVariant.outline => (
          Colors.transparent,
          theme.readableOn(colorKey, theme.surface)
        ),
      PlinthVariant.subtle => (
          Colors.transparent,
          theme.readableOn(colorKey, theme.surface)
        ),
      PlinthVariant.transparent => (
          Colors.transparent,
          theme.readableOn(colorKey, theme.surface)
        ),
      PlinthVariant.defaultVariant => (theme.surfaceMuted, theme.text),
    };

    return Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: variant == PlinthVariant.outline
            ? Border.all(color: baseColor)
            : null,
      ),
      child: IconTheme(
        data: IconThemeData(size: _iconSizes[size], color: foreground),
        child: icon,
      ),
    );
  }
}
