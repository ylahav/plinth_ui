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
class PlinthPagination extends StatelessWidget {
  const PlinthPagination({
    super.key,
    required this.page,
    required this.total,
    required this.onChanged,
    this.color,
    this.size = PlinthSize.md,
    this.siblingCount = 1,
  });

  /// Current page, 1-based.
  final int page;

  /// Total number of pages.
  final int total;

  final ValueChanged<int> onChanged;
  final String? color;
  final PlinthSize size;

  /// How many page numbers to show on either side of [page] before
  /// collapsing into an ellipsis.
  final int siblingCount;

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
    final activeColor = theme.color(colorKey, 6);
    final dimension = switch (size) {
      PlinthSize.xs => 24.0,
      PlinthSize.sm => 28.0,
      PlinthSize.md => 32.0,
      PlinthSize.lg => 38.0,
      PlinthSize.xl => 44.0,
    };

    Widget navButton(IconData icon, bool enabled, VoidCallback onTap) {
      return _PageCell(
        dimension: dimension,
        onTap: enabled ? onTap : null,
        child: Icon(icon,
            size: dimension * 0.5,
            color: enabled ? theme.text : theme.textDisabled),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        navButton(Icons.chevron_left, page > 1, () => onChanged(page - 1)),
        for (final entry in _buildRange())
          if (entry == '…')
            SizedBox(
              width: dimension,
              height: dimension,
              child: const Center(child: Text('…')),
            )
          else
            _PageCell(
              dimension: dimension,
              selected: entry == page,
              activeColor: activeColor,
              onTap: entry == page ? null : () => onChanged(entry as int),
              child: Text(
                '$entry',
                style: TextStyle(
                  color: entry == page ? theme.onFilled : theme.text,
                  fontWeight: entry == page ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
        navButton(Icons.chevron_right, page < total, () => onChanged(page + 1)),
      ],
    );
  }
}

class _PageCell extends StatelessWidget {
  const _PageCell({
    required this.dimension,
    required this.child,
    this.onTap,
    this.selected = false,
    this.activeColor,
  });

  final double dimension;
  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: dimension,
          height: dimension,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: child,
        ),
      ),
    );
  }
}
