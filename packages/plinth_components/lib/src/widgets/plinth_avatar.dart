import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A circular avatar matching Mantine's `Avatar`: shows [imageUrl] if
/// provided, falls back to [initials] on a theme-colored background,
/// and falls back further to a generic person icon if neither is set.
///
/// ```dart
/// PlinthAvatar(initials: 'YR', color: 'blue');
/// PlinthAvatar(imageUrl: 'https://example.com/photo.jpg', size: PlinthSize.lg);
/// ```
class PlinthAvatar extends StatelessWidget {
  const PlinthAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.color,
    this.size = PlinthSize.md,
    this.radius,
  });

  final String? imageUrl;
  final String? initials;

  /// Background color key for the initials/icon fallback. Ignored
  /// when [imageUrl] loads successfully.
  final String? color;

  final PlinthSize size;

  /// Corner radius — defaults to fully circular. Pass a smaller
  /// [PlinthSize] for a rounded-square avatar instead.
  final PlinthSize? radius;

  static const Map<PlinthSize, double> _diameters = {
    PlinthSize.xs: 24,
    PlinthSize.sm: 32,
    PlinthSize.md: 40,
    PlinthSize.lg: 56,
    PlinthSize.xl: 72,
  };

  static const Map<PlinthSize, double> _fontSizes = {
    PlinthSize.xs: 10,
    PlinthSize.sm: 13,
    PlinthSize.md: 16,
    PlinthSize.lg: 22,
    PlinthSize.xl: 28,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final diameter = _diameters[size]!;
    final colorKey = color ?? theme.primaryColor;
    final backgroundColor = theme.shaded(colorKey, 1);
    final foregroundColor = theme.shaded(colorKey, 7);
    final borderRadius = radius != null
        ? BorderRadius.circular(theme.radius[radius]!)
        : BorderRadius.circular(diameter / 2);

    Widget fallback() {
      if (initials != null && initials!.isNotEmpty) {
        return Center(
          child: Text(
            initials!.toUpperCase(),
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: _fontSizes[size],
            ),
          ),
        );
      }
      return Center(
        child:
            Icon(Icons.person, color: foregroundColor, size: diameter * 0.55),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: diameter,
        height: diameter,
        color: backgroundColor,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback(),
              )
            : fallback(),
      ),
    );
  }
}
