import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A vertical layout with a consistent gap, matching Mantine's `Stack`.
///
/// The vertical counterpart to [PlinthGroup], and the same idea as
/// `PlinthFlex(direction: Axis.vertical)` — kept as its own widget
/// because stacking things vertically is common enough that saying so
/// directly reads better than configuring a flex.
///
/// Named for Mantine's component, not Flutter's `Stack`, which layers
/// children on top of one another. This one does not overlap anything.
///
/// ```dart
/// PlinthStack(
///   gap: PlinthSize.sm,
///   children: [Field(), Field(), SubmitButton()],
/// )
/// ```
class PlinthStack extends StatelessWidget {
  const PlinthStack({
    super.key,
    required this.children,
    this.gap = PlinthSize.md,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  final List<Widget> children;
  final PlinthSize gap;

  /// Stretches by default, unlike [PlinthGroup]: a column of form
  /// fields or buttons almost always wants full width, and a caller
  /// who doesn't can say so.
  final CrossAxisAlignment crossAxisAlignment;

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final spacing = context.plinth.spacing[gap]!;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          children[i],
        ],
      ],
    );
  }
}
