import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'slider_marks.dart';

/// A dual-thumb range slider matching Mantine's `RangeSlider`.
///
/// Like [PlinthSlider], this wraps Flutter's built-in [RangeSlider]
/// (via [SliderTheme]) rather than reimplementing dual-thumb drag
/// handling — the same reasoning as `PlinthSlider`: pointer tracking
/// and accessibility are worth not re-deriving from scratch.
///
/// ```dart
/// PlinthRangeSlider(
///   values: _priceRange,
///   min: 0,
///   max: 500,
///   onChanged: (v) => setState(() => _priceRange = v),
/// )
/// ```
class PlinthRangeSlider extends StatelessWidget {
  const PlinthRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.color,
    this.size = PlinthSize.md,
    this.labels,
    this.marks = const [],
  });

  final RangeValues values;

  /// Null disables the slider.
  final ValueChanged<RangeValues>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? color;
  final PlinthSize size;

  /// Optional value labels shown above each thumb while dragging.
  final RangeLabels? labels;

  /// Named positions along the track, as on [PlinthSlider]. Both thumbs
  /// emphasise the mark they sit on.
  final List<PlinthSliderMark> marks;

  static const Map<PlinthSize, double> _trackHeights = {
    PlinthSize.xs: 2,
    PlinthSize.sm: 3,
    PlinthSize.md: 4,
    PlinthSize.lg: 6,
    PlinthSize.xl: 8,
  };

  static const Map<PlinthSize, double> _thumbRadii = {
    PlinthSize.xs: 6,
    PlinthSize.sm: 7,
    PlinthSize.md: 8,
    PlinthSize.lg: 10,
    PlinthSize.xl: 12,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.shaded(colorKey, 6);

    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor,
        inactiveTrackColor: theme.shaded(colorKey, 1),
        thumbColor: activeColor,
        overlayColor: activeColor.withValues(alpha: 0.15),
        trackHeight: _trackHeights[size],
        rangeThumbShape:
            RoundRangeSliderThumbShape(enabledThumbRadius: _thumbRadii[size]!),
        valueIndicatorColor: activeColor,
      ),
      child: RangeSlider(
        values: RangeValues(
            values.start.clamp(min, max), values.end.clamp(min, max)),
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        labels: labels,
      ),
    );

    if (marks.isEmpty) return slider;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        slider,
        SliderMarkLabels(
          marks: marks,
          min: min,
          max: max,
          inset: _thumbRadii[size]!,
          activeValues: [values.start, values.end],
        ),
      ],
    );
  }
}
