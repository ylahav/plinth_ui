import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

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
/// ```dart
/// PlinthSimpleGrid(
///   columns: 3,
///   spacing: PlinthSize.md,
///   children: [for (final item in items) ItemCard(item)],
/// )
/// ```
class PlinthSimpleGrid extends StatelessWidget {
  const PlinthSimpleGrid({
    super.key,
    required this.children,
    required this.columns,
    this.spacing = PlinthSize.md,
  });

  final List<Widget> children;
  final int columns;
  final PlinthSize spacing;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final gap = theme.spacing[spacing]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGap = gap * (columns - 1);
        final cellWidth = (constraints.maxWidth - totalGap) / columns;

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
