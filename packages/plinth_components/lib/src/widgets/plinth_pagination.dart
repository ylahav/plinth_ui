import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Page-number navigation matching Mantine's `Pagination`.
///
/// For large page counts, collapses the middle range into an
/// ellipsis (always showing the first, last, current, and immediate
/// neighbors of current) rather than rendering every page number —
/// mirrors the common pagination UX pattern seen in most web apps.
///
/// ```dart
/// PlinthPagination(
///   page: _page,
///   total: 20,
///   onChanged: (p) => setState(() => _page = p),
/// )
/// ```
///
/// [withEdges] adds first/last controls outside the previous/next
/// pair. They earn their space once the range collapses — jumping from
/// page 14 of 200 back to the start otherwise means tapping `1`, which
/// the ellipsis has already hidden more often than not.
class PlinthPagination extends StatelessWidget {
  const PlinthPagination({
    super.key,
    required this.page,
    required this.total,
    required this.onChanged,
    this.color,
    this.size = PlinthSize.md,
    this.siblingCount = 1,
    this.radius,
    this.withEdges = false,
  });

  /// Current page, 1-based.
  final int page;

  /// Total number of pages.
  final int total;

  /// Null disables every control, the way a null callback does
  /// everywhere else in this library — a pager waiting on the request
  /// that fills the page it is already on has nowhere to send a tap.
  final ValueChanged<int>? onChanged;

  final String? color;
  final PlinthSize size;

  /// Overrides the theme's default radius for this one instance.
  final PlinthSize? radius;

  /// How many page numbers to show on either side of [page] before
  /// collapsing into an ellipsis.
  final int siblingCount;

  /// Adds first/last controls outside the previous/next pair.
  final bool withEdges;

  List<Object> _buildRange() {
    // Object because entries are either an int page number or the
    // String '…' ellipsis marker.
    if (total <= 5 + siblingCount * 2) {
      return List.generate(total, (i) => i + 1);
    }

    final start = (page - siblingCount).clamp(2, total - 1);
    final end = (page + siblingCount).clamp(2, total - 1);

    return [
      1,
      if (start > 2) '…',
      for (var i = start; i <= end; i++) i,
      if (end < total - 1) '…',
      total,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.shaded(colorKey, 6);
    final dimension = switch (size) {
      PlinthSize.xs => 24.0,
      PlinthSize.sm => 28.0,
      PlinthSize.md => 32.0,
      PlinthSize.lg => 38.0,
      PlinthSize.xl => 44.0,
    };
    final resolvedRadius = theme.radius[radius ?? theme.defaultRadius]!;
    final interactive = onChanged != null;

    Widget navButton(IconData icon, String label, bool enabled, int target) {
      final usable = enabled && interactive;
      return _PageCell(
        dimension: dimension,
        radius: resolvedRadius,
        // Icon-only controls have nothing for a screen reader to read
        // out; the numbered cells below carry their own number.
        semanticLabel: label,
        onTap: usable ? () => onChanged!(target) : null,
        child: Icon(icon,
            size: dimension * 0.5,
            color: usable ? theme.text : theme.textDisabled),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (withEdges) navButton(Icons.first_page, 'First page', page > 1, 1),
        navButton(Icons.chevron_left, 'Previous page', page > 1, page - 1),
        for (final entry in _buildRange())
          if (entry == '…')
            ConstrainedBox(
              // Same floor as a cell: the ellipsis is text too, and a
              // fixed box would clip it for the same reason.
              constraints: BoxConstraints(
                minWidth: dimension,
                minHeight: dimension,
              ),
              // Shrink-wrapping, for the same reason as the cell: a
              // bare Center expands to fill, which would make the gap
              // between page runs as tall as the viewport.
              child: const Center(
                  widthFactor: 1, heightFactor: 1, child: Text('…')),
            )
          else
            _PageCell(
              dimension: dimension,
              radius: resolvedRadius,
              selected: entry == page,
              activeColor: activeColor,
              onTap: entry == page || !interactive
                  ? null
                  : () => onChanged!(entry as int),
              child: Text(
                '$entry',
                style: TextStyle(
                  color: entry == page
                      ? theme.contrastingOn(activeColor)
                      : interactive
                          ? theme.text
                          : theme.textDisabled,
                  fontWeight: entry == page ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
        navButton(Icons.chevron_right, 'Next page', page < total, page + 1),
        if (withEdges)
          navButton(Icons.last_page, 'Last page', page < total, total),
      ],
    );
  }
}

class _PageCell extends StatelessWidget {
  const _PageCell({
    required this.dimension,
    required this.radius,
    required this.child,
    this.onTap,
    this.selected = false,
    this.activeColor,
    this.semanticLabel,
  });

  final double dimension;
  final double radius;
  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final Color? activeColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final cell = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          // A minimum rather than a fixed size. At `textScaler` 2.0 a
          // single digit already measured 28x32 inside a 32x32 cell --
          // flush to the edge, with a two-digit page or any larger
          // scale clipping outright. Constraining the floor lets the
          // cell grow with its own content and changes nothing at
          // ordinary scales, where the digit has room to spare.
          constraints: BoxConstraints(
            minWidth: dimension,
            minHeight: dimension,
          ),
          padding: EdgeInsets.symmetric(horizontal: dimension * 0.15),
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
          ),
          // `alignment:` centres the child *and* expands the box to
          // fill whatever it is given. The fixed width/height hid that;
          // the moment the height became a minimum, the cell stretched
          // to the full 600px of the viewport. A `Center` with both
          // factors at 1 shrink-wraps instead, so the box grows only to
          // its content or to the floor, whichever is larger.
          child: Center(widthFactor: 1, heightFactor: 1, child: child),
        ),
      ),
    );

    if (semanticLabel == null) return cell;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: cell,
    );
  }
}
