import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Arranges [children] in a horizontal row with a consistent gap
/// between them, matching Mantine's `Group`.
///
/// Unlike a plain `Row`, this wraps onto a new line by default when
/// children overflow the available width — the common real-world
/// need for a "row of chips/buttons/tags" layout, where a plain
/// `Row` would just overflow. Set [wrap] to false to opt back into
/// `Row`'s clip-and-overflow behavior.
///
/// ```dart
/// PlinthGroup(
///   gap: PlinthSize.sm,
///   children: [
///     PlinthBadge('New'),
///     PlinthBadge('Updated'),
///     PlinthBadge('Popular'),
///   ],
/// )
/// ```
class PlinthGroup extends StatelessWidget {
  const PlinthGroup({
    super.key,
    required this.children,
    this.gap = PlinthSize.md,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrap = true,
    this.grow = false,
  }) : assert(
          !grow || !wrap,
          'PlinthGroup.grow needs wrap: false. A Wrap lays each run out '
          'at the widths its children ask for and has no leftover space '
          'to divide, so growing inside one cannot happen.',
        );

  final List<Widget> children;
  final PlinthSize gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrap;

  /// Divides the leftover width equally between [children] instead of
  /// letting each take its own — a row of buttons that fills its
  /// container rather than huddling at one end.
  ///
  /// Requires `wrap: false`, which the assert above explains.
  final bool grow;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final spacing = theme.spacing[gap]!;

    if (wrap) {
      // Wrap has no direct mainAxisAlignment equivalent — alignment
      // maps onto WrapAlignment, and crossAxisAlignment onto
      // WrapCrossAlignment, both close enough matches for the common
      // start/center/end/spaceBetween cases this widget targets.
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        alignment: _toWrapAlignment(mainAxisAlignment),
        crossAxisAlignment: _toWrapCrossAlignment(crossAxisAlignment),
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      // Growing means filling the width, so the row has to ask for all
      // of it rather than shrink-wrapping its children.
      mainAxisSize: grow ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          if (grow) Expanded(child: children[i]) else children[i],
        ],
      ],
    );
  }

  static WrapAlignment _toWrapAlignment(MainAxisAlignment a) {
    switch (a) {
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
      case MainAxisAlignment.start:
        return WrapAlignment.start;
    }
  }

  static WrapCrossAlignment _toWrapCrossAlignment(CrossAxisAlignment a) {
    switch (a) {
      case CrossAxisAlignment.center:
        return WrapCrossAlignment.center;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        return WrapCrossAlignment.start;
    }
  }
}
