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
///
/// // Half-stars are selectable too
/// PlinthRating(value: _rating, fractions: 2, onChanged: _set);
/// ```
class PlinthRating extends StatelessWidget {
  const PlinthRating({
    super.key,
    required this.value,
    this.onChanged,
    this.count = 5,
    this.color,
    this.size = PlinthSize.md,
    this.fractions = 1,
  }) : assert(fractions >= 1, 'PlinthRating.fractions must be at least 1.');

  /// Current rating. Fractional values render as partly filled stars
  /// whatever [fractions] is — a 4.5 read back from a server displays
  /// correctly on a whole-star selector.
  final double value;

  /// Null makes this a read-only display.
  final ValueChanged<double>? onChanged;

  final int count;
  final String? color;
  final PlinthSize size;

  /// How many parts each star can be *selected* in: 1 for whole stars
  /// (the default), 2 for halves, 4 for quarters.
  ///
  /// This splits each star into that many hit regions, so the value a
  /// tap reports is `1 / fractions` granular. Rendering has always
  /// handled fractions; only choosing one was missing.
  final int fractions;

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
        ? theme.shaded(colorKey, 6)
        : const Color(0xFFFFC107);
    final starSize = _starSizes[size]!;
    final enabled = onChanged != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= count; i++)
          _Star(
            fill: (value - (i - 1)).clamp(0.0, 1.0),
            size: starSize,
            color: starColor,
            fractions: fractions,
            // Region k of star i is the value the whole run up to and
            // including that region represents, so the leftmost region
            // of the first star is the smallest selectable rating and
            // the rightmost of the last is `count`.
            onSelect:
                enabled ? (part) => onChanged!(i - 1 + part / fractions) : null,
          ),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({
    required this.fill,
    required this.size,
    required this.color,
    required this.fractions,
    required this.onSelect,
  });

  /// How much of this star is filled, 0 to 1.
  final double fill;
  final double size;
  final Color color;
  final int fractions;

  /// Called with the 1-based region index that was tapped.
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    // Material ships drawn glyphs for empty, half and full, and a
    // designed half-star beats a mechanically clipped one — so the
    // clip is only for the fills those three don't cover.
    final Widget star;
    if (fill >= 1) {
      star = Icon(Icons.star, size: size, color: color);
    } else if (fill <= 0) {
      star = Icon(Icons.star_border, size: size, color: color);
    } else if (fill == 0.5) {
      star = Icon(Icons.star_half, size: size, color: color);
    } else {
      star = Stack(
        children: [
          Icon(Icons.star_border, size: size, color: color),
          // Aligned left so the fill grows from the star's leading
          // edge; a bare ClipRect would centre what it keeps.
          ClipRect(
            clipper: _FillClipper(fill),
            child: Icon(Icons.star, size: size, color: color),
          ),
        ],
      );
    }

    final content = Padding(padding: const EdgeInsets.all(2), child: star);

    // One region is just the star, and wrapping it keeps the icon
    // inside its own hit path — which is what `find.byIcon(...)` then
    // `tap()` relies on. Only splitting reaches for an overlay.
    if (fractions == 1) {
      return InkWell(
        onTap: onSelect == null ? null : () => onSelect!(1),
        borderRadius: BorderRadius.circular(4),
        child: content,
      );
    }

    return Stack(
      children: [
        content,
        if (onSelect != null)
          Positioned.fill(
            child: Row(
              // Without this the childless InkWells collapse to no
              // height and the star stops being tappable at all.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var k = 1; k <= fractions; k++)
                  Expanded(
                    child: InkWell(
                      onTap: () => onSelect!(k),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Keeps the leftmost [factor] of the child.
class _FillClipper extends CustomClipper<Rect> {
  const _FillClipper(this.factor);

  final double factor;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * factor, size.height);

  @override
  bool shouldReclip(_FillClipper oldClipper) => oldClipper.factor != factor;
}
