import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_loader.dart';

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
    this.loading = false,
  });

  final Widget icon;

  /// Null disables the control, and from 0.19.0 that is visible rather
  /// than only semantic.
  final VoidCallback? onPressed;
  final PlinthVariant variant;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;

  /// Fully circular instead of rounded-square when true.
  final bool circle;

  /// Shows a spinner in place of [icon] and stops responding to taps.
  /// Keeps its own colors, the same reasoning as [PlinthButton.loading]:
  /// busy is not the same as unavailable.
  final bool loading;

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
    final baseColor = theme.shaded(colorKey, 6);
    final lightColor = theme.shaded(colorKey, 1);
    final dimension = _dimensions[size]!;
    final resolvedRadius =
        circle ? dimension / 2 : theme.radius[radius ?? theme.defaultRadius]!;

    final disabled = onPressed == null;

    // Same treatment as PlinthButton's disabled state, and for the same
    // reason: the variants that draw nothing keep drawing nothing.
    final (background, foreground, border) = disabled
        ? switch (variant) {
            PlinthVariant.subtle || PlinthVariant.transparent => (
                Colors.transparent,
                theme.textDisabled,
                null,
              ),
            PlinthVariant.outline || PlinthVariant.defaultVariant => (
                theme.surfaceMuted,
                theme.textDisabled,
                theme.borderMuted,
              ),
            PlinthVariant.filled || PlinthVariant.light => (
                theme.surfaceMuted,
                theme.textDisabled,
                null,
              ),
          }
        : switch (variant) {
            PlinthVariant.filled => (
                baseColor,
                theme.contrastingOn(baseColor),
                null
              ),
            PlinthVariant.light => (
                lightColor,
                theme.readableOn(colorKey, lightColor,
                    // A same-hue label on a same-hue tint cannot reach 4.5 and
                    // stay recognisably that colour: in a dark theme the tint
                    // is shade 8, and walking to body contrast lands on
                    // near-white (cyan #90DFEA -> #F0F8F9), losing the hue the
                    // variant exists to show. Pinned to `large` so raising the
                    // default did not silently repaint this variant.
                    level: PlinthContrast.large),
                null
              ),
            PlinthVariant.outline => (
                Colors.transparent,
                theme.readableOn(colorKey, theme.surface),
                theme.readableOn(colorKey, theme.surface)
              ),
            PlinthVariant.subtle => (
                Colors.transparent,
                theme.readableOn(colorKey, theme.surface),
                null
              ),
            PlinthVariant.transparent => (
                Colors.transparent,
                theme.readableOn(colorKey, theme.surface),
                null
              ),
            PlinthVariant.defaultVariant => (
                theme.surface,
                theme.text,
                theme.border,
              ),
          };

    return Semantics(
      button: true,
      enabled: !disabled && !loading,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(resolvedRadius),
          child: Container(
            width: dimension,
            height: dimension,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: border != null ? Border.all(color: border) : null,
            ),
            child: loading
                ? PlinthLoader(
                    dimension: _iconSizes[size],
                    colorValue: foreground,
                  )
                : IconTheme(
                    data: IconThemeData(
                        size: _iconSizes[size], color: foreground),
                    child: icon,
                  ),
          ),
        ),
      ),
    );
  }
}
