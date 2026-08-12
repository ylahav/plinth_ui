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
    final baseColor = theme.color(colorKey, 6);
    final lightColor = theme.color(colorKey, 1);
    final dimension = _dimensions[size]!;
    final resolvedRadius =
        circle ? dimension / 2 : theme.radius[radius ?? theme.defaultRadius]!;

    final (background, foreground) = switch (variant) {
      PlinthVariant.filled => (baseColor, theme.onFilled),
      PlinthVariant.light => (lightColor, baseColor),
      PlinthVariant.outline => (Colors.transparent, baseColor),
      PlinthVariant.subtle => (Colors.transparent, baseColor),
      PlinthVariant.transparent => (Colors.transparent, baseColor),
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
