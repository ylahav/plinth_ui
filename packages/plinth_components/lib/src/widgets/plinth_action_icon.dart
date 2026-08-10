import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// An icon-only button matching Mantine's `ActionIcon`: same
/// variant/size/color resolution as [PlinthButton], but square
/// (or circular) with no label.
///
/// ```dart
/// PlinthActionIcon(
///   icon: const Icon(Icons.delete_outline),
///   color: 'red',
///   variant: PlinthVariant.light,
///   onPressed: () {},
/// )
/// ```
class PlinthActionIcon extends StatelessWidget {
  const PlinthActionIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = PlinthVariant.light,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.circle = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final PlinthVariant variant;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;

  /// Fully circular instead of rounded-square when true.
  final bool circle;

  static const Map<PlinthSize, double> _dimensions = {
    PlinthSize.xs: 24,
    PlinthSize.sm: 30,
    PlinthSize.md: 36,
    PlinthSize.lg: 44,
    PlinthSize.xl: 52,
  };

  static const Map<PlinthSize, double> _iconSizes = {
    PlinthSize.xs: 14,
    PlinthSize.sm: 16,
    PlinthSize.md: 18,
    PlinthSize.lg: 22,
    PlinthSize.xl: 26,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final baseColor = theme.color(colorKey, 6);
    final lightColor = theme.color(colorKey, 1);
    final dimension = _dimensions[size]!;
    final resolvedRadius = circle ? dimension / 2 : theme.radius[radius ?? theme.defaultRadius]!;

    final (background, foreground, border) = switch (variant) {
      PlinthVariant.filled => (baseColor, Colors.white, null),
      PlinthVariant.light => (lightColor, baseColor, null),
      PlinthVariant.outline => (Colors.transparent, baseColor, baseColor),
      PlinthVariant.subtle => (Colors.transparent, baseColor, null),
      PlinthVariant.transparent => (Colors.transparent, baseColor, null),
      PlinthVariant.defaultVariant => (
          Colors.white,
          Colors.black87,
          const Color(0xFFCED4DA),
        ),
    };

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(resolvedRadius),
          child: Container(
            width: dimension,
            height: dimension,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: border != null ? Border.all(color: border) : null,
            ),
            child: IconTheme(
              data: IconThemeData(size: _iconSizes[size], color: foreground),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
