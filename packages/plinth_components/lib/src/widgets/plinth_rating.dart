import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A star rating selector matching Mantine's `Rating`.
///
/// Pass `onChanged: null` (the default) for a read-only display —
/// useful for showing an existing rating (e.g. "4.5 stars") without
/// making it interactive.
///
/// ```dart
/// // Interactive
/// PlinthRating(value: _rating, onChanged: (v) => setState(() => _rating = v));
///
/// // Read-only display
/// const PlinthRating(value: 4.5);
/// ```
class PlinthRating extends StatelessWidget {
  const PlinthRating({
    super.key,
    required this.value,
    this.onChanged,
    this.count = 5,
    this.color,
    this.size = PlinthSize.md,
  });

  /// Current rating. Supports half-stars (e.g. `3.5`) for read-only
  /// display; tapping in interactive mode always sets a whole number
  /// (the tapped star's index).
  final double value;

  /// Null makes this a read-only display.
  final ValueChanged<double>? onChanged;

  final int count;
  final String? color;
  final PlinthSize size;

  static const Map<PlinthSize, double> _starSizes = {
    PlinthSize.xs: 14,
    PlinthSize.sm: 18,
    PlinthSize.md: 22,
    PlinthSize.lg: 28,
    PlinthSize.xl: 34,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? 'yellow';
    // 'yellow' isn't in the default theme palette (only blue/red/
    // green/gray) — fall back to an explicit amber if the active
    // theme hasn't defined it, rather than theme.color()'s usual
    // primaryColor fallback, since a rating in the primary brand
    // color reads oddly compared to the conventional gold-star look.
    final starColor = theme.colors.containsKey(colorKey)
        ? theme.color(colorKey, 6)
        : const Color(0xFFFFC107);
    final starSize = _starSizes[size]!;
    final enabled = onChanged != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= count; i++)
          _Star(
            filled: value >= i,
            halfFilled: value >= i - 0.5 && value < i,
            size: starSize,
            color: starColor,
            onTap: enabled ? () => onChanged!(i.toDouble()) : null,
          ),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({
    required this.filled,
    required this.halfFilled,
    required this.size,
    required this.color,
    required this.onTap,
  });

  final bool filled;
  final bool halfFilled;
  final double size;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = filled
        ? Icons.star
        : halfFilled
            ? Icons.star_half
            : Icons.star_border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}
