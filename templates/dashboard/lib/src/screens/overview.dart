/// The landing screen: three figures, then the two charts that explain
/// them.
///
/// The figures come first because they answer "is anything wrong" in one
/// glance, and the charts come second because they answer "why", which
/// is a question you only ask once the first answer is bad.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';
import 'package:plinth_charts/plinth_charts.dart';

import '../data.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final wide = MediaQuery.sizeOf(context).width >= 760;

    final revenue = PlinthLineChart(
      label: 'Revenue by channel, last eight weeks (thousands)',
      series: [
        for (final entry in revenueByChannel.entries)
          PlinthChartSeries(
            name: entry.key,
            values: entry.value,
            seriesKey: entry.key,
          ),
      ],
      showArea: true,
      describeValue: (v) => '\$${v.toStringAsFixed(0)}k',
    );

    final sources = PlinthDonutChart(
      label: 'Orders by source, this month',
      centreLabel: '1,284',
      centreCaption: 'orders',
      segments: [
        for (final entry in ordersBySource.entries)
          PlinthDonutSegment(label: entry.key, value: entry.value),
      ],
      describeValue: (v) => v.toStringAsFixed(0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlinthPageHeader(
          title: 'Overview',
          subtitle: 'Trading month to date',
        ),
        SizedBox(height: theme.space(6)),
        PlinthStatGrid(
          tiles: [
            for (final metric in overviewMetrics)
              PlinthStatTile(
                label: metric.label,
                value: metric.value,
                delta: metric.delta,
                trend: metric.rising ? PlinthTrend.up : PlinthTrend.down,
                higherIsBetter: metric.higherIsBetter,
                caption: metric.caption,
              ),
          ],
        ),
        SizedBox(height: theme.space(6)),

        // Side by side only when both stay legible. A line chart squeezed
        // into half of a narrow window is a chart nobody can read, and
        // stacking costs a scroll.
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: PlinthCard(child: revenue)),
              SizedBox(width: theme.space(6)),
              Expanded(flex: 2, child: PlinthCard(child: sources)),
            ],
          )
        else ...[
          PlinthCard(child: revenue),
          SizedBox(height: theme.space(6)),
          PlinthCard(child: sources),
        ],
      ],
    );
  }
}
