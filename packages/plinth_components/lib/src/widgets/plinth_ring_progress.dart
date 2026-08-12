import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A circular progress indicator matching Mantine's `RingProgress`.
/// Companion to [PlinthProgress] (linear) — reach for this when the
/// available space is better suited to a ring, e.g. a compact
/// dashboard stat card.
///
/// ```dart
/// PlinthRingProgress(value: 0.72, color: 'green', label: Text('72%'))
/// ```
class PlinthRingProgress extends StatelessWidget {
  const PlinthRingProgress({
    super.key,
    required this.value,
    this.color,
    this.size = 80,
    this.thickness = 8,
    this.trackColor,
    this.label,
  }) : assert(value >= 0 && value <= 1, 'value must be between 0 and 1');

  /// Fraction filled, from 0.0 to 1.0.
  final double value;
  final String? color;

  /// Outer diameter in logical pixels.
  final double size;
  final double thickness;

  /// Background ring color. Defaults to a light gray.
  final Color? trackColor;

  /// Optional content centered inside the ring, e.g. a percentage label.
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final fillColor = theme.color(colorKey, 6);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              value: value,
              thickness: thickness,
              fillColor: fillColor,
              trackColor: trackColor ?? theme.surfaceSunken,
            ),
          ),
          if (label != null) label!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.thickness,
    required this.fillColor,
    required this.trackColor,
  });

  final double value;
  final double thickness;
  final Color fillColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - thickness) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawCircle(center, radius, trackPaint);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Start at 12 o'clock (-90deg) and sweep clockwise proportional
    // to `value`, matching the conventional progress-ring reading
    // direction.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.thickness != thickness ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.trackColor != trackColor;
  }
}
