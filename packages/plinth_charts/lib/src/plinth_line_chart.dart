import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// One line on a [PlinthLineChart].
class PlinthChartSeries {
  const PlinthChartSeries({
    required this.name,
    required this.values,
    this.color,
    this.seriesKey,
  });

  /// What this line is of. Shown in the legend and said in the summary.
  final String name;

  final List<double> values;

  /// Palette key, overriding the theme's series sequence.
  final String? color;

  /// A stable slot in the series palette, via `PlinthTheme.seriesFor`.
  ///
  /// Without one a series takes the colour of its position, so adding a
  /// line at the front recolours every line behind it, and a dashboard
  /// means something different after a deploy.
  final String? seriesKey;
}

/// A multi-series line chart.
///
/// **Colour is not load-bearing.** Each line also gets its own dash
/// pattern, so series are told apart by shape as well as hue. A legend
/// mapping colour to name is no help to a reader who cannot see the
/// difference, and a chart is exactly where that bites.
///
/// **Faint lines are lifted to the non-text floor.** The series palette
/// in `plinth_core` varies *lightness* on purpose, so dichromats keep a
/// second channel. But four of its six defaults sit between 1.48:1 and
/// 2.09:1 against a light surface, and a 2px line at 1.5:1 is faint for
/// everybody. Each colour resolves with `PlinthContrast.nonText`, which
/// moves only the ones below 3:1 and leaves their hue alone.
///
/// **The summary names every line**, built from the data, so it cannot
/// describe a chart other than the one drawn.
class PlinthLineChart extends StatelessWidget {
  const PlinthLineChart({
    super.key,
    required this.series,
    this.label,
    this.height = 180,
    this.width,
    this.showLegend = true,
    this.showArea = false,
    this.areaOpacity = 0.12,
    this.strokeWidth = 2,
    this.dashed = true,
    this.describeValue,
    this.riseLabel = 'rising',
    this.fallLabel = 'falling',
    this.flatLabel = 'flat',
    this.emptyLabel = 'No data',
  });

  final List<PlinthChartSeries> series;

  /// What the chart is of, said before the lines.
  final String? label;

  final double height;
  final double? width;
  final bool showLegend;
  final bool showArea;
  final double areaOpacity;
  final double strokeWidth;

  /// Whether to vary the dash pattern per series.
  ///
  /// On by default. Turn it off only for a single-series chart, where
  /// there is nothing to tell apart and a dashed line is just noise.
  final bool dashed;

  final String Function(double)? describeValue;
  final String riseLabel;
  final String fallLabel;
  final String flatLabel;
  final String emptyLabel;

  /// Dash patterns, in the order series take them. The first is solid.
  static const List<List<double>> dashPatterns = [
    [],
    [6, 4],
    [2, 3],
    [10, 4, 2, 4],
    [1, 3],
    [8, 3, 3, 3],
  ];

  String _describe(double v) =>
      describeValue?.call(v) ??
      (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString());

  String _direction(List<double> v) => v.last > v.first
      ? riseLabel
      : v.last < v.first
          ? fallLabel
          : flatLabel;

  /// The sentence a screen reader hears.
  String get summary {
    final drawn = series.where((s) => s.values.isNotEmpty).toList();
    if (drawn.isEmpty) {
      return [if (label != null) label!, emptyLabel].join('. ');
    }

    return [
      if (label case final label?) label,
      for (final s in drawn)
        '${s.name}, ${_describe(s.values.first)} to '
            '${_describe(s.values.last)}, ${_direction(s.values)}',
    ].join('. ');
  }

  /// The colour each series is drawn in, lifted to the non-text floor.
  List<Color> colorsFor(PlinthTheme theme) {
    return [
      for (final (index, s) in series.indexed)
        if (s.color case final key?)
          theme.readableOn(key, theme.surface, level: PlinthContrast.nonText)
        else
          _resolvedSlot(
            theme,
            s.seriesKey == null ? index : theme.seriesIndexFor(s.seriesKey!),
          ),
    ];
  }

  Color _resolvedSlot(PlinthTheme theme, int slot) {
    if (theme.seriesColors.isEmpty) {
      return theme.readableOn(
        theme.primaryColor,
        theme.surface,
        level: PlinthContrast.nonText,
      );
    }
    final entry = theme.seriesColors[slot % theme.seriesColors.length];
    // Starts from the palette's own shade, so a colour already clearing
    // the floor comes back untouched and keeps its place in the
    // lightness ordering the CVD work depends on.
    return theme.readableOn(
      entry.ramp,
      theme.surface,
      from: entry.shade,
      level: PlinthContrast.nonText,
    );
  }

  List<double> _dashFor(int index) =>
      dashed ? dashPatterns[index % dashPatterns.length] : const <double>[];

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colors = colorsFor(theme);

    final chart = SizedBox(
      height: height,
      child: CustomPaint(
        painter: _LineChartPainter(
          series: [for (final s in series) s.values],
          colors: colors,
          strokeWidth: strokeWidth,
          dashes: [for (var i = 0; i < series.length; i++) _dashFor(i)],
          areaOpacity: showArea ? areaOpacity : null,
        ),
        size: Size.infinite,
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: summary,
          image: true,
          child: ExcludeSemantics(child: chart),
        ),
        if (showLegend && series.isNotEmpty) ...[
          SizedBox(height: theme.space(2)),
          Wrap(
            spacing: theme.spacing[PlinthSize.md]!,
            runSpacing: theme.spacing[PlinthSize.xs]!,
            children: [
              for (final (index, s) in series.indexed)
                MergeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomPaint(
                        size: const Size(18, 8),
                        painter: _SwatchPainter(
                          color: colors[index],
                          dash: _dashFor(index),
                        ),
                      ),
                      SizedBox(width: theme.space(2)),
                      Text(
                        s.name,
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
        ],
      ],
    );

    return width == null ? body : SizedBox(width: width, child: body);
  }
}

/// Strokes [path], honouring [dash] as an on/off length sequence.
void _strokeDashed(Canvas canvas, Path path, List<double> dash, Paint paint) {
  if (dash.isEmpty) {
    canvas.drawPath(path, paint);
    return;
  }

  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    var on = true;
    var i = 0;
    while (distance < metric.length) {
      final next = math.min(distance + dash[i % dash.length], metric.length);
      if (on) canvas.drawPath(metric.extractPath(distance, next), paint);
      distance = next;
      on = !on;
      i++;
    }
  }
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter({required this.color, required this.dash});

  final Color color;
  final List<double> dash;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);
    _strokeDashed(
      canvas,
      path,
      dash,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) =>
      old.color != color || !listEquals(old.dash, dash);
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.colors,
    required this.strokeWidth,
    required this.dashes,
    required this.areaOpacity,
  });

  final List<List<double>> series;
  final List<Color> colors;
  final double strokeWidth;
  final List<List<double>> dashes;
  final double? areaOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final drawn = series.where((s) => s.length >= 2).toList();
    if (drawn.isEmpty || size.width <= 0 || size.height <= 0) return;

    // One scale across every series, or the lines say nothing about
    // each other: two series on their own axes can cross without ever
    // having met.
    final all = drawn.expand((s) => s);
    final min = all.reduce(math.min);
    final max = all.reduce(math.max);
    final span = max - min;

    final inset = strokeWidth / 2;
    final usable = math.max(size.height - strokeWidth, 0.0);

    for (final (index, values) in series.indexed) {
      if (values.length < 2) continue;

      Offset pointAt(int i) {
        final x = size.width * i / (values.length - 1);
        final t = span == 0 ? 0.5 : (values[i] - min) / span;
        return Offset(x, inset + usable * (1 - t));
      }

      final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
      for (var i = 1; i < values.length; i++) {
        final p = pointAt(i);
        path.lineTo(p.dx, p.dy);
      }

      final color = colors[index % colors.length];

      if (areaOpacity case final opacity?) {
        final area = Path.from(path)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(
          area,
          Paint()..color = color.withValues(alpha: opacity),
        );
      }

      _strokeDashed(
        canvas,
        path,
        dashes[index % dashes.length],
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => true;
}
