import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_grid.dart' show kDefaultBreakpoints;

/// Arranges [children] into a grid with a fixed number of [columns]
/// per row and consistent spacing, matching Mantine's `SimpleGrid`.
///
/// Unlike Flutter's `GridView`, this isn't scrollable or virtualized
/// — it sizes to its content and expects to sit inside something
/// that already scrolls (or a bounded area), the same trade-off
/// Mantine's version makes. For a large or unbounded list of items,
/// use `GridView.builder` directly instead. Needs a bounded width
/// from its parent (via `LayoutBuilder` internally) to compute each
/// cell's width — an unbounded-width ancestor (e.g. a horizontal
/// `ListView`) will throw, same as most width-dependent layouts.
///
/// [columns] is the count at any width; the per-breakpoint counts
/// override it from that breakpoint *upward*, so `columns: 1,
/// columnsMd: 3` is a single stack on phones and three across on
/// desktops. Same mobile-first direction as [PlinthGridCol]'s spans
/// and Mantine's `cols={{ base: 1, md: 3 }}` — the unqualified
/// [columns] is the smallest case, not the default case.
///
/// ```dart
/// PlinthSimpleGrid(
///   columns: 1,
///   columnsSm: 2,
///   columnsMd: 3,
///   spacing: PlinthSize.md,
///   children: [for (final item in items) ItemCard(item)],
/// )
/// ```
class PlinthSimpleGrid extends StatelessWidget {
  const PlinthSimpleGrid({
    super.key,
    required this.children,
    required this.columns,
    this.columnsXs,
    this.columnsSm,
    this.columnsMd,
    this.columnsLg,
    this.columnsXl,
    this.spacing = PlinthSize.md,
  }) : assert(columns > 0, 'columns must be at least 1');

  final List<Widget> children;
  final int columns;
  final int? columnsXs;
  final int? columnsSm;
  final int? columnsMd;
  final int? columnsLg;
  final int? columnsXl;
  final PlinthSize spacing;

  /// The column count that applies at [width], taking the largest
  /// breakpoint at or below it that defines one.
  int columnsFor(double width) {
    final candidates = <PlinthSize, int?>{
      PlinthSize.xl: columnsXl,
      PlinthSize.lg: columnsLg,
      PlinthSize.md: columnsMd,
      PlinthSize.sm: columnsSm,
      PlinthSize.xs: columnsXs,
    };

    for (final entry in candidates.entries) {
      final breakpoint = kDefaultBreakpoints[entry.key]!;
      if (entry.value != null && width >= breakpoint) return entry.value!;
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final gap = theme.spacing[spacing]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // A count below 1 would compute a negative cell width, and the
        // per-breakpoint values are caller-supplied rather than
        // asserted at construction.
        final count = columnsFor(constraints.maxWidth).clamp(1, 1 << 20);
        final totalGap = gap * (count - 1);
        final cellWidth = (constraints.maxWidth - totalGap) / count;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              SizedBox(width: cellWidth, child: child),
          ],
        );
      },
    );
  }
}
