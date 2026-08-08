import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A small pill-shaped label matching Mantine's `Badge`. Follows the
/// same variant/size/color resolution as [PlinthButton] — colors and
/// spacing come from the active [PlinthTheme].
///
/// ```dart
/// PlinthBadge('New', color: 'green');
/// PlinthBadge('Beta', variant: PlinthVariant.outline, color: 'blue');
/// ```
class PlinthBadge extends StatelessWidget {
  const PlinthBadge(
    this.label, {
    super.key,
    this.variant = PlinthVariant.light,
    this.size = PlinthSize.sm,
    this.color,
    this.leadingIcon,
  });

  final String label;
  final PlinthVariant variant;
  final PlinthSize size;
  final String? color;
  final Widget? leadingIcon;

  static const Map<PlinthSize, double> _fontSizes = {
    PlinthSize.xs: 9,
    PlinthSize.sm: 10,
    PlinthSize.md: 12,
    PlinthSize.lg: 13,
    PlinthSize.xl: 14,
  };

  static const Map<PlinthSize, double> _verticalPadding = {
    PlinthSize.xs: 3,
    PlinthSize.sm: 4,
    PlinthSize.md: 6,
    PlinthSize.lg: 7,
    PlinthSize.xl: 9,
  };

  static const Map<PlinthSize, double> _horizontalPadding = {
    PlinthSize.xs: 8,
    PlinthSize.sm: 10,
    PlinthSize.md: 12,
    PlinthSize.lg: 14,
    PlinthSize.xl: 16,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final baseColor = theme.color(colorKey, 6);
    final lightColor = theme.color(colorKey, 1);

    final (background, foreground, border) = switch (variant) {
      PlinthVariant.filled => (baseColor, Colors.white, null),
      PlinthVariant.light => (lightColor, baseColor, null),
      PlinthVariant.outline => (Colors.transparent, baseColor, baseColor),
      PlinthVariant.subtle => (Colors.transparent, baseColor, null),
      PlinthVariant.transparent => (Colors.transparent, baseColor, null),
      PlinthVariant.defaultVariant => (
          const Color(0xFFF1F3F5),
          Colors.black87,
          null,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding[size]!,
        vertical: _verticalPadding[size]!,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: _fontSizes[size],
              fontWeight: FontWeight.w700,
              color: foreground,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
