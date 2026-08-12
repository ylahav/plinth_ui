import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A direction-configurable flex layout with a consistent gap
/// between children, matching Mantine's `Flex`.
///
/// [PlinthGroup] is this same idea specialized to the horizontal
/// case with wrap-by-default — reach for `PlinthFlex` when the
/// direction itself needs to vary (e.g. horizontal on wide screens,
/// vertical on narrow ones) rather than always being a row.
///
/// ```dart
/// PlinthFlex(
///   direction: isWide ? Axis.horizontal : Axis.vertical,
///   gap: PlinthSize.md,
///   children: [PlinthButton(...), PlinthButton(...)],
/// )
/// ```
class PlinthFlex extends StatelessWidget {
  const PlinthFlex({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.gap = PlinthSize.md,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
  });

  final List<Widget> children;
  final Axis direction;
  final PlinthSize gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final spacing = theme.spacing[gap]!;
    final horizontal = direction == Axis.horizontal;

    final spaced = <Widget>[
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0)
          SizedBox(
              width: horizontal ? spacing : 0,
              height: horizontal ? 0 : spacing),
        children[i],
      ],
    ];

    return horizontal
        ? Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: spaced,
          )
        : Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: spaced,
          );
  }
}
