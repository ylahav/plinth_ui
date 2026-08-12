import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Minimum viewport width (logical pixels) at which each breakpoint
/// applies, matching Mantine's defaults converted from `em` at a 16px
/// root (36/48/62/75/88em).
///
/// Lives here rather than in `plinth_core`'s token set because it is
/// the only layout-responsive scale in the library, and adding it to
/// the published core package would mean releasing and re-pinning
/// `plinth_core` for a value nothing else reads.
const Map<PlinthSize, double> kDefaultBreakpoints = {
  PlinthSize.xs: 576,
  PlinthSize.sm: 768,
  PlinthSize.md: 992,
  PlinthSize.lg: 1200,
  PlinthSize.xl: 1408,
};

/// One column in a [PlinthGrid], matching Mantine's `Grid.Col`.
///
/// [span] is the number of grid columns to occupy at any width; the
/// per-breakpoint spans override it from that breakpoint *upward*, so
/// `span: 12, spanMd: 6` is full width on phones and half on desktops.
/// That mobile-first direction matches Mantine and CSS media queries —
/// the unqualified [span] is the smallest case, not the default case.
class PlinthGridCol extends StatelessWidget {
  const PlinthGridCol({
    super.key,
    required this.child,
    this.span = 12,
    this.spanXs,
    this.spanSm,
    this.spanMd,
    this.spanLg,
    this.spanXl,
  });

  final Widget child;
  final int span;
  final int? spanXs;
  final int? spanSm;
  final int? spanMd;
  final int? spanLg;
  final int? spanXl;

  /// The span that applies at [width], taking the largest breakpoint
  /// at or below it that defines one.
  int spanFor(double width) {
    final candidates = <PlinthSize, int?>{
      PlinthSize.xl: spanXl,
      PlinthSize.lg: spanLg,
      PlinthSize.md: spanMd,
      PlinthSize.sm: spanSm,
      PlinthSize.xs: spanXs,
    };

    for (final entry in candidates.entries) {
      final breakpoint = kDefaultBreakpoints[entry.key]!;
      if (entry.value != null && width >= breakpoint) return entry.value!;
    }
    return span;
  }

  /// Renders [child] directly. A column carries layout *data* that
  /// [PlinthGrid] reads off it; used outside a grid it is transparent
  /// rather than an error.
  @override
  Widget build(BuildContext context) => child;
}

/// A responsive column grid matching Mantine's `Grid`.
///
/// Distinct from [PlinthSimpleGrid], which puts a fixed number of
/// equal-width items per row: here each child declares how many of the
/// [columns] it occupies, and can declare different spans at different
/// viewport widths. Reach for SimpleGrid for a uniform gallery of
/// cards, and this for a page layout where a sidebar and a main column
/// have genuinely different widths.
///
/// Like SimpleGrid it is neither scrollable nor virtualized, and needs
/// a bounded width from its parent.
///
/// ```dart
/// PlinthGrid(
///   children: [
///     PlinthGridCol(span: 12, spanMd: 8, child: MainContent()),
///     PlinthGridCol(span: 12, spanMd: 4, child: Sidebar()),
///   ],
/// )
/// ```
class PlinthGrid extends StatelessWidget {
  const PlinthGrid({
    super.key,
    required this.children,
    this.gutter = PlinthSize.md,
    this.columns = 12,
  }) : assert(columns > 0, 'columns must be at least 1');

  final List<PlinthGridCol> children;
  final PlinthSize gutter;

  /// Total columns in the grid. 12 by default, the convention every
  /// CSS grid system uses because it divides evenly by 2, 3, 4, and 6.
  final int columns;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final gap = theme.spacing[gutter]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Width of a single column once the gutters between all of
        // them are taken out.
        final unit = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final col in children)
              SizedBox(
                // A span wider than the grid would push its row into
                // overflow, and a span below 1 would compute a
                // negative width.
                width: _widthFor(
                  col.spanFor(width).clamp(1, columns),
                  unit,
                  gap,
                ),
                child: col,
              ),
          ],
        );
      },
    );
  }

  /// A span of n covers n columns *and* the n-1 gutters between them.
  double _widthFor(int span, double unit, double gap) =>
      unit * span + gap * (span - 1);
}
