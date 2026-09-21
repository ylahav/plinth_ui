import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// One slice.
class PlinthDonutSegment {
  const PlinthDonutSegment({
    required this.label,
    required this.value,
    this.color,
    this.seriesKey,
  });

  final String label;

  /// A share of the whole. Negative values are treated as zero — a
  /// slice cannot be less than nothing, and drawing one backwards
  /// silently corrupts every slice after it.
  final double value;

  final String? color;

  /// A stable slot in the series palette, so a slice keeps its colour
  /// when the list is reordered or filtered.
  final String? seriesKey;
}

/// A ring of slices, with the total in the middle.
///
/// ```dart
/// PlinthDonutChart(
///   label: 'Sessions',
///   centreLabel: '9,100',
///   centreCaption: 'sessions',
///   segments: const [
///     PlinthDonutSegment(label: 'Direct', value: 5200),
///     PlinthDonutSegment(label: 'Search', value: 3100),
///   ],
/// )
/// ```
///
/// **Reach for a bar first.** Angles are harder to compare than
/// lengths, and `PlinthProgress.sections` shows the same part-to-whole
/// split as a bar that is easier to read and takes a fraction of the
/// space. This earns its place when the *total* is the headline — which
/// is what the middle of a ring is for — and when there are few enough
/// slices that nobody has to compare two of them by eye.
///
/// **The legend carries the figures.** A slice is an angle, and an
/// angle is not a number; the percentages and values live in the
/// legend so the chart does not ask anyone to estimate.
///
/// **Every slice is its own node**, like a bar chart and unlike a line:
/// a donut is a list of parts, and a list should be walkable.
class PlinthDonutChart extends StatelessWidget {
  const PlinthDonutChart({
    super.key,
    required this.segments,
    this.label,
    this.centreLabel,
    this.centreCaption,
    this.diameter = 140,
    this.thickness = 22,
    this.gapDegrees = 2,
    this.showLegend = true,
    this.showPercentages = true,
    this.describeValue,
    this.emptyLabel = 'No data',
    this.width,
  });

  final List<PlinthDonutSegment> segments;

  /// What the ring is of, rendered above it.
  final String? label;

  /// The headline in the middle — usually the total.
  final String? centreLabel;

  /// A smaller line under [centreLabel].
  final String? centreCaption;

  final double diameter;
  final double thickness;

  /// Space between slices, in degrees. A hairline gap is what stops
  /// two adjacent slices of similar colour reading as one.
  final double gapDegrees;

  final bool showLegend;
  final bool showPercentages;
  final String Function(double)? describeValue;
  final String emptyLabel;
  final double? width;

  double get total => segments.fold(0, (sum, s) => sum + math.max(s.value, 0));

  String describe(double v) =>
      describeValue?.call(v) ??
      (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString());

  /// The share of the whole each slice takes, 0 to 1.
  List<double> get shares {
    final whole = total;
    return [
      for (final s in segments) whole <= 0 ? 0.0 : math.max(s.value, 0) / whole,
    ];
  }

  /// The colour each slice is drawn in.
  ///
  /// Taken from the palette unlifted, like a bar and unlike a line: a
  /// slice is a filled area, and the lightness variation is what lets a
  /// dichromat tell two of them apart.
  List<Color> colorsFor(PlinthTheme theme) {
    return [
      for (final (index, s) in segments.indexed)
        if (s.color case final key?)
          theme.shaded(key, 6)
        else if (s.seriesKey case final seriesKey?)
          theme.seriesFor(seriesKey)
        else
          theme.series(index),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colors = colorsFor(theme);
    final fractions = shares;

    if (segments.isEmpty || total <= 0) {
      final empty = Text(
        emptyLabel,
        style: TextStyle(
          fontSize: theme.fontSizes[PlinthSize.sm],
          color: theme.textMuted,
        ),
      );
      return width == null ? empty : SizedBox(width: width, child: empty);
    }

    final ring = SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
            child: CustomPaint(
              size: Size.square(diameter),
              painter: _DonutPainter(
                shares: fractions,
                colors: colors,
                thickness: thickness,
                gapRadians: gapDegrees * math.pi / 180,
              ),
            ),
          ),
          if (centreLabel != null || centreCaption != null)
            // Merged, because "9,100 sessions" is one fact rather than
            // a number and a caption that happen to be stacked.
            MergeSemantics(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (centreLabel case final centre?)
                    Text(
                      centre,
                      style: TextStyle(
                        fontSize: theme.fontSizes[PlinthSize.lg],
                        fontWeight: FontWeight.w700,
                        color: theme.text,
                      ),
                    ),
                  if (centreCaption case final caption?)
                    Text(
                      caption,
                      style: TextStyle(
                        fontSize: theme.fontSizes[PlinthSize.xs],
                        color: theme.textMuted,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label case final title?) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: theme.fontSizes[PlinthSize.md],
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          SizedBox(height: theme.space(2)),
        ],
        Center(child: ring),
        if (showLegend) ...[
          SizedBox(height: theme.space(3)),
          for (final (index, segment) in segments.indexed) ...[
            if (index > 0) SizedBox(height: theme.space(1)),
            _LegendRow(
              segment: segment,
              color: colors[index],
              share: fractions[index],
              text: describe(segment.value),
              showPercentage: showPercentages,
            ),
          ],
        ],
      ],
    );

    return width == null ? body : SizedBox(width: width, child: body);
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.segment,
    required this.color,
    required this.share,
    required this.text,
    required this.showPercentage,
  });

  final PlinthDonutSegment segment;
  final Color color;
  final double share;
  final String text;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final percent = '${(share * 100).round()}%';

    // One node per slice: a donut is a list of parts, and a list should
    // be walkable. The percentage is in the label because an angle is
    // not a number.
    return Semantics(
      label: showPercentage
          ? '${segment.label}, $text, $percent'
          : '${segment.label}, $text',
      container: true,
      child: ExcludeSemantics(
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: theme.space(2)),
            Expanded(
              child: Text(
                segment.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.fontSizes[PlinthSize.xs],
                  color: theme.text,
                ),
              ),
            ),
            Text(
              showPercentage ? '$text · $percent' : text,
              style: TextStyle(
                fontSize: theme.fontSizes[PlinthSize.xs],
                color: theme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.shares,
    required this.colors,
    required this.thickness,
    required this.gapRadians,
  });

  final List<double> shares;
  final List<Color> colors;
  final double thickness;
  final double gapRadians;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (math.min(size.width, size.height) - thickness) / 2;
    if (radius <= 0) return;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    // Start at the top, which is where a reader looks first.
    var start = -math.pi / 2;
    final drawn = shares.where((s) => s > 0).length;

    for (final (index, share) in shares.indexed) {
      if (share <= 0) continue;

      final sweep = share * 2 * math.pi;
      // No gap when one slice is the whole ring: a gap there is a
      // notch in a circle that has nothing to be separated from.
      final gap = drawn > 1 ? gapRadians : 0.0;
      final drawSweep = math.max(sweep - gap, 0.0001);

      canvas.drawArc(
        rect,
        start + gap / 2,
        drawSweep,
        false,
        Paint()
          ..color = colors[index % colors.length]
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.butt
          ..style = PaintingStyle.stroke,
      );

      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => true;
}
