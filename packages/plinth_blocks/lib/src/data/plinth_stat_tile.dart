import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// Which way a figure moved.
enum PlinthTrend {
  up,
  down,

  /// Moved by nothing worth reporting. Rendered without an arrow,
  /// because an arrow that means "no change" is an arrow read as
  /// change.
  flat,
}

/// One figure on a dashboard.
///
/// ```dart
/// PlinthStatTile(
///   label: 'Churn',
///   value: '1.8%',
///   delta: '0.4%',
///   trend: PlinthTrend.down,
///   higherIsBetter: false,
/// )
/// ```
///
/// **Direction and sentiment are two different things**, and this takes
/// both. The version this replaced had one flag: churn falling 0.4%
/// came out in red with a downward arrow, which reads as bad news about
/// the best number on the board. [higherIsBetter] is what separates
/// "which way did it go" from "is that good".
///
/// **The movement is spoken, not only coloured.** Each tile is one
/// semantics node reading "Churn, 1.8%, down 0.4%" — the arrow and the
/// colour are hidden from assistive technology, because a green arrow
/// is not information anyone can hear.
class PlinthStatTile extends StatelessWidget {
  const PlinthStatTile({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.trend = PlinthTrend.flat,
    this.higherIsBetter = true,
    this.caption,
    this.badge,
    this.visual,
    this.action,
    this.uppercaseLabel = true,
    this.goodColor = 'green',
    this.badColor = 'red',
    this.valueOrder = 3,
    this.withBorder = true,
  });

  /// What the figure counts.
  final String label;

  /// The figure, already formatted. A string rather than a number
  /// because `$13,456` and `1.8%` are not numbers, and formatting one
  /// for display is a locale question this package does not answer.
  final String value;

  /// How much it moved, without a sign — the sign is [trend]'s job, and
  /// a `-0.4%` beside a downward arrow says it twice.
  final String? delta;

  final PlinthTrend trend;

  /// Whether a rise is good news. False for churn, cost, latency, error
  /// rate — the numbers where down is the win.
  final bool higherIsBetter;

  /// A line under the value: `68 GB of 100 GB`.
  final String? caption;

  /// Top-right of the tile — a plan badge, a status pill.
  final Widget? badge;

  /// A bar, ring, sparkline or breakdown under the figure.
  final Widget? visual;

  /// A link or button at the foot of the tile.
  final Widget? action;

  /// Whether to display [label] in capitals.
  ///
  /// Display only: the semantics keep the label as you wrote it,
  /// because a screen reader handed `REVENUE` may spell it out.
  final bool uppercaseLabel;

  final String goodColor;
  final String badColor;

  /// Heading level for [value]. It is the tile's heading — a dashboard
  /// of figures with no headings is a wall a screen reader cannot skim.
  final int valueOrder;

  final bool withBorder;

  /// Whether this movement is good news, given [higherIsBetter].
  bool? get _isGood => switch (trend) {
        PlinthTrend.flat => null,
        PlinthTrend.up => higherIsBetter,
        PlinthTrend.down => !higherIsBetter,
      };

  /// What the movement sounds like.
  String get _spokenTrend => switch (trend) {
        PlinthTrend.up => 'up',
        PlinthTrend.down => 'down',
        PlinthTrend.flat => 'unchanged',
      };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final good = _isGood;
    final ramp = good == null
        ? 'gray'
        : good
            ? goodColor
            : badColor;

    final spoken = [
      label,
      value,
      if (delta case final delta?) '$_spokenTrend $delta',
      if (caption case final caption?) caption,
    ].join(', ');

    return Semantics(
      label: spoken,
      container: true,
      child: ExcludeSemantics(
        child: PlinthPaper(
          withBorder: withBorder,
          p: PlinthSize.md,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PlinthText(
                      uppercaseLabel ? label.toUpperCase() : label,
                      size: PlinthSize.xs,
                      color: 'gray',
                      weight: FontWeight.w700,
                    ),
                  ),
                  if (badge case final badge?) badge,
                ],
              ),
              SizedBox(height: theme.space(2)),
              PlinthTitle(value, order: valueOrder),
              if (caption case final caption?) ...[
                SizedBox(height: theme.space(1)),
                PlinthText(caption, size: PlinthSize.sm, color: 'gray'),
              ],
              if (delta case final delta?) ...[
                SizedBox(height: theme.space(2)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trend != PlinthTrend.flat) ...[
                      Icon(
                        trend == PlinthTrend.up
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        // Resolved against the surface, not `color(ramp, 6)`
                        // — the raw shade is below the floor for a mark
                        // this small on white.
                        color: theme.readableOn(ramp, theme.surface),
                      ),
                      SizedBox(width: theme.space(1)),
                    ],
                    PlinthText(delta, size: PlinthSize.xs, color: ramp),
                  ],
                ),
              ],
              if (visual case final visual?) ...[
                SizedBox(height: theme.space(4)),
                visual,
              ],
              if (action case final action?) ...[
                SizedBox(height: theme.space(3)),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of [PlinthStatTile]s that becomes a column when narrow.
class PlinthStatGrid extends StatelessWidget {
  const PlinthStatGrid({
    super.key,
    required this.tiles,
    this.columns = 3,
    this.minColWidth = 150,
    this.width,
  });

  final List<Widget> tiles;
  final int columns;

  /// Width below which the grid drops a column. A stat tile squeezed
  /// under its own number is not a tile.
  final double minColWidth;

  final double? width;

  @override
  Widget build(BuildContext context) {
    final grid = PlinthSimpleGrid(
      columns: columns,
      minColWidth: minColWidth,
      children: tiles,
    );

    return width == null ? grid : SizedBox(width: width, child: grid);
  }
}
