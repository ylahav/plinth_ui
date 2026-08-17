import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A half-ring gauge, matching Mantine's `SemiCircleProgress`.
///
/// The same idea as [PlinthRingProgress] drawn as a 180° arc, which
/// suits a dashboard tile better than a full circle: the flat bottom
/// sits on a baseline, and the empty half of a full ring reads as
/// wasted space when the value is the only thing on the card.
///
/// ```dart
/// PlinthSemiCircleProgress(
///   value: 0.72,
///   label: const PlinthText('72%', weight: FontWeight.w700),
/// )
/// ```
class PlinthSemiCircleProgress extends StatelessWidget {
  const PlinthSemiCircleProgress({
    super.key,
    required this.value,
    this.color,
    this.diameter = 160,
    this.thickness = 12,
    this.trackColor,
    this.label,
  }) : assert(value >= 0 && value <= 1, 'value must be between 0 and 1');

  /// Fraction filled, from 0.0 to 1.0.
  final double value;

  final String? color;

  /// Diameter of the full circle the arc is taken from. The rendered
  /// height is about half this, since only the top half is drawn.
  ///
  /// Named `size` before 0.20.0, which everywhere else in this library
  /// means a step on the [PlinthSize] scale.
  final double diameter;

  final double thickness;
  final Color? trackColor;

  /// Centred content, typically the percentage.
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final fill = theme.shaded(color ?? theme.primaryColor, 6);
    // Clamped so a thickness past the radius can't paint the arc back
    // over itself, the same guard PlinthRingProgress needs.
    final stroke = math.min(thickness, diameter / 2);

    return SizedBox(
      width: diameter,
      // Half the diameter plus the stroke, so the arc isn't clipped at
      // its thickest point.
      height: diameter / 2 + stroke / 2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(diameter, diameter / 2 + stroke / 2),
            painter: _SemiCirclePainter(
              value: value,
              fill: fill,
              track: trackColor ?? theme.surfaceSunken,
              stroke: stroke,
            ),
          ),
          if (label != null)
            Padding(
              padding: EdgeInsets.only(bottom: stroke / 2),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: theme.text),
                child: label!,
              ),
            ),
        ],
      ),
    );
  }
}

class _SemiCirclePainter extends CustomPainter {
  const _SemiCirclePainter({
    required this.value,
    required this.fill,
    required this.track,
    required this.stroke,
  });

  final double value;
  final Color fill;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.width - stroke) / 2;
    final centre = Offset(size.width / 2, size.height - stroke / 2);
    final rect = Rect.fromCircle(center: centre, radius: radius);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Left to right across the top half: start at 180°, sweep 180°.
    canvas.drawArc(rect, math.pi, math.pi, false, base..color = track);
    if (value > 0) {
      canvas.drawArc(
        rect,
        math.pi,
        math.pi * value,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = fill,
      );
    }
  }

  @override
  bool shouldRepaint(_SemiCirclePainter old) =>
      old.value != value ||
      old.fill != fill ||
      old.track != track ||
      old.stroke != stroke;
}
