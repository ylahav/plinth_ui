import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_progress.dart' show PlinthProgressSection;

/// A circular progress indicator matching Mantine's `RingProgress`.
/// Companion to [PlinthProgress] (linear) — reach for this when the
/// available space is better suited to a ring, e.g. a compact
/// dashboard stat card.
///
/// ```dart
/// PlinthRingProgress(value: 0.72, color: 'green', label: Text('72%'))
/// ```
///
/// [PlinthRingProgress.sections] draws several parts of one whole, the
/// same shape as [PlinthProgress.sections] — a donut rather than a
/// gauge.
class PlinthRingProgress extends StatelessWidget {
  const PlinthRingProgress({
    super.key,
    required this.value,
    this.color,
    this.diameter = 80,
    this.thickness = 8,
    this.trackColor,
    this.label,
  })  : sections = null,
        assert(value >= 0 && value <= 1, 'value must be between 0 and 1');

  /// A ring divided into coloured parts of one whole. Not `const` for
  /// the same reason as [PlinthProgress.sections]: the check that the
  /// parts fit inside the whole has to add them up.
  PlinthRingProgress.sections({
    super.key,
    required List<PlinthProgressSection> sections,
    this.diameter = 80,
    this.thickness = 8,
    this.trackColor,
    this.label,
  })  : sections = sections,
        value = 0,
        color = null,
        assert(sections.length > 0, 'a sectioned ring needs a section'),
        assert(
          sections.fold<double>(0, (sum, s) => sum + s.value) <= 1.0001,
          'sections are fractions of the whole ring, so they cannot sum '
          'above 1 — scale them yourself if you have raw counts',
        );

  /// Fraction filled, from 0.0 to 1.0. Ignored when [sections] is set.
  final double value;
  final String? color;

  /// Outer diameter in logical pixels.
  ///
  /// Named `size` before 0.20.0, which everywhere else in this library
  /// means a step on the [PlinthSize] scale.
  final double diameter;
  final double thickness;

  /// Background ring color. Defaults to a light gray.
  final Color? trackColor;

  /// The parts of a part-to-whole ring, or null for a single arc.
  final List<PlinthProgressSection>? sections;

  /// Optional content centered inside the ring, e.g. a percentage label.
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final fillColor = theme.shaded(colorKey, 6);

    final described = sections?.where((s) => s.label != null) ?? const [];

    Widget ring = SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(diameter, diameter),
            painter: _RingPainter(
              value: value,
              thickness: thickness,
              fillColor: fillColor,
              trackColor: trackColor ?? theme.surfaceSunken,
              arcs: [
                for (final section
                    in sections ?? const <PlinthProgressSection>[])
                  (value: section.value, color: theme.shaded(section.color, 6)),
              ],
            ),
          ),
          if (label != null) label!,
        ],
      ),
    );

    if (described.isNotEmpty) {
      ring = Semantics(
        label: described
            .map((s) => '${s.label}: ${(s.value * 100).round()}%')
            .join(', '),
        textDirection: TextDirection.ltr,
        child: ring,
      );
    }

    return ring;
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.thickness,
    required this.fillColor,
    required this.trackColor,
    this.arcs = const [],
  });

  final double value;
  final double thickness;
  final Color fillColor;
  final Color trackColor;

  /// Consecutive coloured arcs, empty for a single-value ring.
  final List<({double value, Color color})> arcs;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - thickness) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawCircle(center, radius, trackPaint);

    final bounds = Rect.fromCircle(center: center, radius: radius);

    // Start at 12 o'clock (-90deg) and sweep clockwise, matching the
    // conventional progress-ring reading direction.
    const start = -math.pi / 2;

    if (arcs.isNotEmpty) {
      var angle = start;
      for (final arc in arcs) {
        final sweep = 2 * math.pi * arc.value;
        canvas.drawArc(
          bounds,
          angle,
          sweep,
          false,
          Paint()
            ..color = arc.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = thickness
            // Butt caps, not round: rounded ends on consecutive arcs
            // overlap their neighbours, so each section would eat a
            // little of the one before it.
            ..strokeCap = StrokeCap.butt,
        );
        angle += sweep;
      }
      return;
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(bounds, start, 2 * math.pi * value, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.thickness != thickness ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.trackColor != trackColor ||
        !listEquals(oldDelegate.arcs, arcs);
  }
}
