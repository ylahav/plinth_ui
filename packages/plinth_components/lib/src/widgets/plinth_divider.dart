import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A themed divider matching Mantine's `Divider`: a thin rule,
/// optionally with a centered label (e.g. "OR" between two sign-in
/// options).
///
/// ```dart
/// const PlinthDivider()                    // plain horizontal rule
/// const PlinthDivider(label: 'OR')          // rule with a centered label
/// PlinthDivider(vertical: true, height: 40) // vertical rule
/// ```
class PlinthDivider extends StatelessWidget {
  const PlinthDivider({
    super.key,
    this.label,
    this.vertical = false,
    this.height,
    this.color,
  });

  final String? label;
  final bool vertical;

  /// Only meaningful when [vertical] is true — [Divider] fills
  /// available height on its own, but [VerticalDivider] needs an
  /// explicit extent from its parent to render visibly in an
  /// unconstrained context (e.g. inside a `Row` without a bounded
  /// height). Pass this when you see a zero-height vertical divider.
  final double? height;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.plinth.surfaceSunken;

    if (vertical) {
      return SizedBox(
        height: height,
        child: VerticalDivider(width: 1, color: resolvedColor),
      );
    }

    if (label == null) {
      return Divider(height: 1, color: resolvedColor);
    }

    return Row(
      children: [
        Expanded(child: Divider(height: 1, color: resolvedColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: PlinthText(label!, size: PlinthSize.xs, color: 'gray'),
        ),
        Expanded(child: Divider(height: 1, color: resolvedColor)),
      ],
    );
  }
}
