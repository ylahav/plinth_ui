import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A line with no axes: the shape of a series, beside the number it
/// belongs to.
///
/// ```dart
/// PlinthSparkline(values: const [12, 15, 14, 19, 24, 31, 38])
/// ```
///
/// **A sparkline is pixels, so it carries a sentence.** A chart with no
/// text alternative is a blank to anyone not looking at it, and the
/// useful summary is not the numbers — it is where the series started,
/// where it ended, and which way it went. That sentence is built from
/// the data rather than passed in, so it cannot describe a different
/// series to the one drawn.
///
/// Pass [semanticsLabel] to say something else entirely, or
/// [describeValue] to format the endpoints — `38` is rarely what a
/// reader wants to hear when the axis is money.
class PlinthSparkline extends StatelessWidget {
  const PlinthSparkline({
    super.key,
    required this.values,
    this.color,
    this.strokeWidth = 2,
    this.fill = true,
    this.fillOpacity = 0.15,
    this.showLast = true,
    this.height = 40,
    this.width,
    this.label,
    this.semanticsLabel,
    this.describeValue,
    this.riseLabel = 'rising',
    this.fallLabel = 'falling',
    this.flatLabel = 'flat',
  });

  /// The series, in order. Fewer than two points draws nothing — one
  /// point is a dot, not a trend, and drawing it as a flat line would
  /// claim a shape the data does not have.
  final List<double> values;

  /// Palette key. Null falls back to the theme's primary.
  final String? color;

  final double strokeWidth;

  /// Whether to wash the area under the line.
  final bool fill;

  final double fillOpacity;

  /// Whether to mark the final point, which is the one a reader is
  /// usually looking for.
  final bool showLast;

  final double height;
  final double? width;

  /// What the series is of — "Monthly revenue". Used in the spoken
  /// summary, and not drawn.
  final String? label;

  /// Replaces the generated summary entirely.
  final String? semanticsLabel;

  /// Formats the endpoints for the summary.
  final String Function(double)? describeValue;

  final String riseLabel;
  final String fallLabel;
  final String flatLabel;

  /// The sentence a screen reader hears.
  String get summary {
    if (semanticsLabel != null) return semanticsLabel!;
    if (values.isEmpty) return label ?? '';

    final format = describeValue ?? (v) => _trim(v);
    final first = values.first;
    final last = values.last;
    final direction = last > first
        ? riseLabel
        : last < first
            ? fallLabel
            : flatLabel;

    final parts = [
      if (label case final label?) label,
      '${format(first)} to ${format(last)}',
      direction,
    ];
    return parts.join(', ');
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    // Resolved against the surface rather than taken at shade 6: a 2px
    // line is the thinnest mark in the library, and the raw shade is
    // under the floor for several ramps.
    final stroke = theme.readableOn(color ?? theme.primaryColor, theme.surface);

    final chart = SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          stroke: stroke,
          strokeWidth: strokeWidth,
          fill: fill ? stroke.withValues(alpha: fillOpacity) : null,
          showLast: showLast,
        ),
        size: Size.infinite,
      ),
    );

    return Semantics(
      label: summary,
      image: true,
      child: ExcludeSemantics(child: chart),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.stroke,
    required this.strokeWidth,
    required this.fill,
    required this.showLast,
  });

  final List<double> values;
  final Color stroke;
  final double strokeWidth;
  final Color? fill;
  final bool showLast;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) return;

    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    // A flat series would divide by zero; drawn down the middle it is
    // honest about having no shape.
    final span = max - min;
    final inset = strokeWidth / 2;
    final usable = math.max(size.height - strokeWidth, 0.0);

    Offset pointAt(int i) {
      final x = values.length == 1 ? 0.0 : size.width * i / (values.length - 1);
      final t = span == 0 ? 0.5 : (values[i] - min) / span;
      return Offset(x, inset + usable * (1 - t));
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      final p = pointAt(i);
      path.lineTo(p.dx, p.dy);
    }

    if (fill case final fill?) {
      final area = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(area, Paint()..color = fill);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    if (showLast) {
      canvas.drawCircle(
        pointAt(values.length - 1),
        strokeWidth * 1.5,
        Paint()..color = stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      !listEquals(old.values, values) ||
      old.stroke != stroke ||
      old.strokeWidth != strokeWidth ||
      old.fill != fill ||
      old.showLast != showLast;
}
