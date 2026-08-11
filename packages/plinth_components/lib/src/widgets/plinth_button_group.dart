import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Joins a row of buttons (or action icons) into one visually
/// connected group, matching Mantine's `Button.Group`: outer corners
/// stay rounded, inner corners square off, and adjacent borders
/// collapse into a single shared line instead of doubling up.
///
/// This is a layout wrapper only — it doesn't alter the children's
/// own behavior, just their visual framing. Works with any child
/// that renders its own border (e.g. [PlinthButton] with
/// `variant: PlinthVariant.outline`).
///
/// ```dart
/// PlinthButtonGroup(
///   children: [
///     PlinthButton(variant: PlinthVariant.outline, onPressed: () {}, child: const Text('Day')),
///     PlinthButton(variant: PlinthVariant.outline, onPressed: () {}, child: const Text('Week')),
///     PlinthButton(variant: PlinthVariant.outline, onPressed: () {}, child: const Text('Month')),
///   ],
/// )
/// ```
class PlinthButtonGroup extends StatelessWidget {
  const PlinthButtonGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius = theme.radius[theme.defaultRadius]!;

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++)
            // A hairline divider between each pair of children stands
            // in for the "shared border" look — cheaper and more
            // robust than trying to make each child's own border
            // collapse with its neighbor's, which would require every
            // child type to cooperate with an external radius/border
            // override.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i > 0) Container(width: 1, color: const Color(0xFFCED4DA)),
                ClipRRect(
                  borderRadius: BorderRadius.horizontal(
                    left:
                        i == 0 ? Radius.circular(resolvedRadius) : Radius.zero,
                    right: i == children.length - 1
                        ? Radius.circular(resolvedRadius)
                        : Radius.zero,
                  ),
                  child: children[i],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
