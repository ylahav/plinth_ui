import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'color_slider_base.dart';

/// Picks a hue from the full colour wheel, matching Mantine's
/// `HueSlider`.
///
/// One of [PlinthColorPicker]'s parts, exported on its own because a
/// hue alone is often the whole interaction — tinting a chart series,
/// theming a workspace — and a full picker would be the wrong amount
/// of UI for it.
///
/// The track is a real hue sweep rather than an approximation: the
/// stops are the six primaries plus a repeat of red, so the gradient
/// wraps where the wheel does.
///
/// ```dart
/// PlinthHueSlider(
///   value: _hue,
///   onChanged: (h) => setState(() => _hue = h),
/// )
/// ```
class PlinthHueSlider extends StatelessWidget {
  const PlinthHueSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 14,
    this.radius,
    this.saturation = 1,
    this.brightness = 1,
  });

  /// Degrees around the wheel, 0..360.
  final double value;

  /// Null disables the slider.
  final ValueChanged<double>? onChanged;

  final double height;
  final PlinthSize? radius;

  /// Applied to the thumb's preview fill only — the track always shows
  /// fully saturated hues, since a washed-out track makes neighbouring
  /// hues hard to tell apart.
  final double saturation;
  final double brightness;

  /// The six primaries plus the wrap back to red.
  static const List<double> _stops = [0, 60, 120, 180, 240, 300, 360];

  @override
  Widget build(BuildContext context) {
    final hue = value.clamp(0.0, 360.0);

    return PlinthColorSliderBase(
      value: hue / 360,
      onChanged: onChanged == null ? null : (v) => onChanged!(v * 360),
      gradient: [
        for (final stop in _stops)
          HSVColor.fromAHSV(1, stop % 360, 1, 1).toColor(),
      ],
      thumbColor: HSVColor.fromAHSV(1, hue, saturation, brightness).toColor(),
      // A degree per arrow press is too slow across 360 of them.
      step: 1 / 72,
      height: height,
      radius: radius,
      semanticLabel: 'Hue',
      semanticFormatter: (v) => '${(v * 360).round()} degrees',
    );
  }
}
