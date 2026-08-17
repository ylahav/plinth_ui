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
/// PlinthDivider(direction: Axis.vertical, height: 40) // vertical rule
/// const PlinthDivider(size: PlinthSize.md)  // a thicker rule
/// ```
///
/// **[size] and [height] are different questions**, which is why both
/// exist: [size] is how *thick* the rule is, a step on the theme's
/// scale; [height] is how *long* a vertical one runs, a measured
/// extent its parent can't always supply. A horizontal rule never
/// needs the second — it fills the width it is given.
class PlinthDivider extends StatelessWidget {
  const PlinthDivider({
    super.key,
    this.label,
    this.direction = Axis.horizontal,
    this.height,
    this.color,
    this.size = PlinthSize.xs,
  });

  final String? label;

  /// Which way the rule runs. An `Axis` rather than a `vertical` flag
  /// as of 0.20.0, matching [PlinthFlex], [PlinthScrollArea] and
  /// [PlinthSplitter] — one spelling for one idea.
  final Axis direction;

  /// How thick the rule is. Defaults to [PlinthSize.xs], the hairline
  /// this component drew before the prop existed, so nothing moves
  /// unless it is asked to.
  final PlinthSize size;

  /// Only meaningful when [direction] is [Axis.vertical] — [Divider] fills
  /// available height on its own, but [VerticalDivider] needs an
  /// explicit extent from its parent to render visibly in an
  /// unconstrained context (e.g. inside a `Row` without a bounded
  /// height). Pass this when you see a zero-height vertical divider.
  ///
  /// This is the rule's *length*, not its thickness — see [size].
  final double? height;

  final Color? color;

  /// A rule is structure, not text, so its thickness is its own small
  /// ramp rather than the font or spacing scale: one device pixel per
  /// step, which is what Mantine's divider sizes come out at too.
  double get _thickness => switch (size) {
        PlinthSize.xs => 1,
        PlinthSize.sm => 2,
        PlinthSize.md => 3,
        PlinthSize.lg => 4,
        PlinthSize.xl => 5,
      };

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.plinth.surfaceSunken;
    final thickness = _thickness;

    if (direction == Axis.vertical) {
      return SizedBox(
        height: height,
        // `width` is the space the divider occupies and `thickness` the
        // line inside it; keeping them equal means a thicker rule takes
        // exactly the room it draws in, rather than growing padding.
        child: VerticalDivider(
          width: thickness,
          thickness: thickness,
          color: resolvedColor,
        ),
      );
    }

    Widget rule() => Divider(
          height: thickness,
          thickness: thickness,
          color: resolvedColor,
        );

    if (label == null) return rule();

    return Row(
      children: [
        Expanded(child: rule()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: PlinthText(label!, size: PlinthSize.xs, color: 'gray'),
        ),
        Expanded(child: rule()),
      ],
    );
  }
}
