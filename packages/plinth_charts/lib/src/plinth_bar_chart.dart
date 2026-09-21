import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// One bar.
class PlinthBar {
  const PlinthBar({
    required this.label,
    required this.value,
    this.color,
    this.seriesKey,
  });

  /// What the bar counts.
  final String label;

  final double value;

  /// Palette key, overriding the theme's series sequence.
  final String? color;

  /// A stable slot in the series palette, so a bar keeps its colour
  /// when the list is reordered or filtered.
  final String? seriesKey;
}

/// A categorical bar chart.
///
/// ```dart
/// PlinthBarChart(
///   label: 'Sessions by source',
///   bars: const [
///     PlinthBar(label: 'Direct', value: 5200),
///     PlinthBar(label: 'Search', value: 3100),
///   ],
/// )
/// ```
///
/// **Horizontal by default**, which is the opposite of most defaults
/// and the right one here: category names are words, and words fit
/// along a horizontal bar without being rotated, truncated, or turned
/// into a legend somebody has to cross-reference.
///
/// **Every bar is its own node to a screen reader** — "Direct, 5,200" —
/// rather than the whole chart being one sentence. A line chart is a
/// shape and reads as a summary; a bar chart is a list of figures, and
/// a list should be walkable.
///
/// **The value is written beside the bar**, so the chart does not
/// depend on anyone estimating a length against an axis.
class PlinthBarChart extends StatelessWidget {
  const PlinthBarChart({
    super.key,
    required this.bars,
    this.label,
    this.showValues = true,
    this.describeValue,
    this.barThickness = 18,
    this.gap = PlinthSize.xs,
    this.emptyLabel = 'No data',
    this.width,
  });

  final List<PlinthBar> bars;

  /// What the chart is of, rendered as a heading above it.
  final String? label;

  /// Whether to print each value at the end of its bar.
  final bool showValues;

  /// Formats values for display and for the spoken label.
  final String Function(double)? describeValue;

  final double barThickness;
  final PlinthSize gap;
  final String emptyLabel;
  final double? width;

  String describe(double v) =>
      describeValue?.call(v) ??
      (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString());

  /// The colour each bar is drawn in.
  ///
  /// Bars are large areas rather than thin marks, so these are taken
  /// from the palette as they are — the lift a line needs would flatten
  /// the lightness variation that the palette exists to provide, and a
  /// filled rectangle at 2:1 is still perfectly visible where a 2px
  /// line at 2:1 is not.
  List<Color> colorsFor(PlinthTheme theme) {
    return [
      for (final (index, bar) in bars.indexed)
        if (bar.color case final key?)
          theme.shaded(key, 6)
        else if (bar.seriesKey case final seriesKey?)
          theme.seriesFor(seriesKey)
        else
          theme.series(index),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colors = colorsFor(theme);

    // Against the largest bar, not against a total: a bar chart asks
    // how the categories compare, and dividing by a sum nobody sees
    // makes a long tail out of every one of them.
    final peak = bars.isEmpty ? 0.0 : bars.map((b) => b.value).reduce(math.max);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label case final label?) ...[
          // Plain `Text` rather than `PlinthText`: this package depends
          // on `plinth_core` alone, so you can chart without installing
          // the widget library. The style still comes from the theme.
          Text(
            label,
            style: TextStyle(
              fontSize: theme.fontSizes[PlinthSize.md],
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          SizedBox(height: theme.space(2)),
        ],
        if (bars.isEmpty)
          Text(
            emptyLabel,
            style: TextStyle(
              fontSize: theme.fontSizes[PlinthSize.sm],
              color: theme.textMuted,
            ),
          )
        else
          for (final (index, bar) in bars.indexed) ...[
            if (index > 0) SizedBox(height: theme.spacing[gap]!),
            _BarRow(
              bar: bar,
              color: colors[index],
              share: peak <= 0 ? 0 : bar.value / peak,
              thickness: barThickness,
              showValue: showValues,
              text: describe(bar.value),
            ),
          ],
      ],
    );

    return width == null ? body : SizedBox(width: width, child: body);
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.bar,
    required this.color,
    required this.share,
    required this.thickness,
    required this.showValue,
    required this.text,
  });

  final PlinthBar bar;
  final Color color;
  final double share;
  final double thickness;
  final bool showValue;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    // One node per bar, so a reader walks the figures rather than
    // hearing one long sentence about all of them.
    return Semantics(
      label: '${bar.label}, $text',
      container: true,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 96,
              child: Text(
                bar.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.fontSizes[PlinthSize.xs],
                  color: theme.text,
                ),
              ),
            ),
            SizedBox(width: theme.space(2)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  theme.radius[PlinthSize.xs]!,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: share.clamp(0.0, 1.0),
                    child: Container(height: thickness, color: color),
                  ),
                ),
              ),
            ),
            if (showValue) ...[
              SizedBox(width: theme.space(2)),
              Text(
                text,
                style: TextStyle(
                  fontSize: theme.fontSizes[PlinthSize.xs],
                  color: theme.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
