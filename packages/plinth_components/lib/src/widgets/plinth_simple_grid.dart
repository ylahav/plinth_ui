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
    this.minColWidth,
  })  : assert(columns > 0, 'columns must be at least 1'),
        assert(
          minColWidth == null || minColWidth > 0,
          'minColWidth must be positive',
        );

  final List<Widget> children;
  final int columns;
  final int? columnsXs;
  final int? columnsSm;
  final int? columnsMd;
  final int? columnsLg;
  final int? columnsXl;
  final PlinthSize spacing;

  /// Fits as many columns as will hold a cell this wide, instead of
  /// counting them.
  ///
  /// This is Mantine's container-query mode, and the difference from
  /// the breakpoint props is which width is being asked about: those
  /// measure the *screen*, this measures the space the grid was
  /// actually given. A grid inside a sidebar gets narrow cells from
  /// this and desktop-sized ones from the breakpoints, because the
  /// screen is still wide.
  ///
  /// Overrides [columns] and every breakpoint when set.
  final double? minColWidth;

  /// The column count that applies at [width], taking the largest
  /// breakpoint at or below it that defines one.
  ///
  /// [minColWidth] short-circuits all of it — see its own note on why
  /// the two are different questions.
  int columnsFor(double width) {
    final min = minColWidth;
    if (min != null) {
      // Solving `n * min + (n - 1) * gap <= width` needs the gap,
      // which `columnsFor` does not have; the caller-facing answer is
      // close enough without it, and `build` does the exact sum.
      return (width / min).floor().clamp(1, 1 << 20);
    }

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
        var count = columnsFor(constraints.maxWidth).clamp(1, 1 << 20);
        final min = minColWidth;
        if (min != null) {
          // Gaps eat into the width the cells have to share, so the
          // count from `columnsFor` can be one too many. Step down
          // until the cells actually clear `min`, never below one.
          while (count > 1 &&
              (constraints.maxWidth - gap * (count - 1)) / count < min) {
            count--;
          }
        }
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
