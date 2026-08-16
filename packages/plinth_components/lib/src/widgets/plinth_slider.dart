import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'slider_marks.dart';

export 'slider_marks.dart' show PlinthSliderMark;

/// A themeable slider matching Mantine's `Slider`.
///
/// Like [PlinthTooltip], this wraps Flutter's built-in [Slider]
/// (via [SliderTheme]) rather than reimplementing drag handling from
/// scratch — pointer tracking, keyboard step support, and
/// accessibility (screen reader value announcements) are exactly the
/// kind of thing that's easy to get subtly wrong in a hand-rolled
/// version, and Flutter's implementation already handles them well.
/// Plinth only restyles the track/thumb colors and thickness.
///
/// ```dart
/// PlinthSlider(
///   value: _volume,
///   onChanged: (v) => setState(() => _volume = v),
///   color: 'blue',
/// )
/// ```
class PlinthSlider extends StatelessWidget {
  const PlinthSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.color,
    this.size = PlinthSize.md,
    this.label,
    this.marks = const [],
    this.restrictToMarks = false,
  });

  final double value;

  /// Null disables the slider.
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  /// Number of discrete steps. Omit for a continuous slider.
  final int? divisions;

  final String? color;
  final PlinthSize size;

  /// Optional value label shown above the thumb while dragging.
  final String? label;

  /// Named positions along the track, rendered as labels beneath it and
  /// aligned to where the thumb actually lands.
  ///
  /// Labels rather than ticks: the ticks on the track are Flutter's,
  /// drawn from [divisions], and painting a second set over a slider
  /// this widget only themes would mean guessing at the track geometry
  /// of an SDK that is free to change it. Marks name positions;
  /// `divisions` marks them.
  final List<PlinthSliderMark> marks;

  /// Snaps every reported value to the nearest mark.
  ///
  /// For a scale whose steps aren't evenly spaced — 1, 2, 5, 10 — which
  /// [divisions] can't express, since it splits the range evenly.
  final bool restrictToMarks;

  /// The mark nearest [raw], or [raw] itself when there are none.
  double _snap(double raw) {
    if (marks.isEmpty) return raw;
    return marks
        .map((m) => m.value)
        .reduce((a, b) => (a - raw).abs() <= (b - raw).abs() ? a : b);
  }

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
        thumbShape:
            RoundSliderThumbShape(enabledThumbRadius: _thumbRadii[size]!),
        valueIndicatorColor: activeColor,
      ),
      child: Slider(
        value: value.clamp(min, max),
        onChanged: onChanged == null
            ? null
            : (v) => onChanged!(restrictToMarks ? _snap(v) : v),
        min: min,
        max: max,
        divisions: divisions,
        label: label,
      ),
    );

    // Unmarked sliders lay out exactly as they did before marks
    // existed — no wrapper, no extra height.
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
          activeValues: [value],
        ),
      ],
    );
  }
}
