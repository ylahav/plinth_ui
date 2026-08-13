import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'color_slider_base.dart';

/// Picks an opacity for a given colour, matching Mantine's
/// `AlphaSlider`.
///
/// One of [PlinthColorPicker]'s parts, exported on its own for the
/// cases where the colour is already settled and only its opacity is
/// in question — an overlay's scrim, a chart band, a watermark.
///
/// The track runs from fully transparent to [color] over a chequer,
/// which is the convention that distinguishes *transparent* from
/// *pale*: without it, 50% black and solid grey look identical.
///
/// ```dart
/// PlinthAlphaSlider(
///   color: Colors.blue,
///   value: _opacity,
///   onChanged: (a) => setState(() => _opacity = a),
/// )
/// ```
class PlinthAlphaSlider extends StatelessWidget {
  const PlinthAlphaSlider({
    super.key,
    required this.color,
    required this.value,
    required this.onChanged,
    this.height = 14,
    this.radius,
  });

  /// The colour whose opacity is being chosen. Its own alpha is
  /// ignored — [value] is the alpha.
  final Color color;

  /// Opacity, 0..1.
  final double value;

  /// Null disables the slider.
  final ValueChanged<double>? onChanged;

  final double height;
  final PlinthSize? radius;

  @override
  Widget build(BuildContext context) {
    final alpha = value.clamp(0.0, 1.0);
    final opaque = color.withValues(alpha: 1);

    return PlinthColorSliderBase(
      value: alpha,
      onChanged: onChanged,
      gradient: [opaque.withValues(alpha: 0), opaque],
      thumbColor: opaque.withValues(alpha: alpha),
      checkerboard: true,
      height: height,
      radius: radius,
      semanticLabel: 'Opacity',
      semanticFormatter: (v) => '${(v * 100).round()}%',
    );
  }
}
