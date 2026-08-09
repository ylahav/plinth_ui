import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

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
    final activeColor = theme.color(colorKey, 6);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor,
        inactiveTrackColor: theme.color(colorKey, 1),
        thumbColor: activeColor,
        overlayColor: activeColor.withValues(alpha: 0.15),
        trackHeight: _trackHeights[size],
        thumbShape:
            RoundSliderThumbShape(enabledThumbRadius: _thumbRadii[size]!),
        valueIndicatorColor: activeColor,
      ),
      child: Slider(
        value: value.clamp(min, max),
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
      ),
    );
  }
}
