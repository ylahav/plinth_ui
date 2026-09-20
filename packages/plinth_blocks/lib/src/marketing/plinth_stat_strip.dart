import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One number and what it counts.
class PlinthStat {
  const PlinthStat({required this.value, required this.label});

  /// The number, as text — `'111'`, `'99.9%'`, `'<2ms'`.
  ///
  /// A string rather than a num because the interesting ones are not
  /// plain numbers, and because formatting a number for display is a
  /// locale question this package does not answer. Format it, then
  /// pass the result.
  final String value;

  final String label;
}

/// A row of numbers under a claim.
///
/// Evidence rather than a second paragraph asserting the same thing:
/// the numbers are the part a reader can go and check.
///
/// ```dart
/// PlinthStatStrip(
///   stats: const [
///     PlinthStat(value: '117', label: 'components'),
///     PlinthStat(value: '160', label: 'pub points'),
///   ],
/// )
/// ```
///
/// The value is read first and larger, and the label under it is muted
/// — which is also the reading order somebody scanning gets. Each pair
/// is merged into one node for assistive technology, so it is
/// announced as "117 components" rather than as two unrelated strings
/// that happen to be near each other.
class PlinthStatStrip extends StatelessWidget {
  const PlinthStatStrip({
    super.key,
    required this.stats,
    this.gap = PlinthSize.xl,
    this.alignment = MainAxisAlignment.center,
    this.valueSize = PlinthSize.lg,
    this.divider = false,
  });

  final List<PlinthStat> stats;
  final PlinthSize gap;
  final MainAxisAlignment alignment;
  final PlinthSize valueSize;

  /// Whether to draw a rule above the strip, separating the evidence
  /// from the claim it supports.
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final strip = PlinthGroup(
      gap: gap,
      mainAxisAlignment: alignment,
      children: [
        for (final stat in stats)
          MergeSemantics(
            child: PlinthStack(
              gap: PlinthSize.xs,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                PlinthText(
                  stat.value,
                  size: valueSize,
                  weight: FontWeight.w700,
                ),
                PlinthText(stat.label, size: PlinthSize.xs, color: 'gray'),
              ],
            ),
          ),
      ],
    );

    if (!divider) return strip;

    return PlinthStack(
      gap: PlinthSize.md,
      children: [const PlinthDivider(), strip],
    );
  }
}
