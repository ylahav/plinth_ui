// Charts on the colour-blind-safe categorical palette.
//
// The point of the package in one screen. Two things are worth
// noticing that a screenshot cannot show you:
//
// Every chart carries a sentence built from its own data, so a screen
// reader hears "Revenue by channel, web rising from 32 to 47" rather
// than nothing at all. A chart is pixels, and pixels say nothing.
//
// The series palette is validated against protanopia, deuteranopia and
// tritanopia, so the lines are told apart by more than hue. The line
// chart also dashes them, because a tenth of readers cannot use colour
// alone.

import 'package:flutter/material.dart';
import 'package:plinth_charts/plinth_charts.dart';

void main() => runApp(const ChartsExampleApp());

class ChartsExampleApp extends StatelessWidget {
  const ChartsExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'plinth_charts',
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
        home: const _Demo(),
      );
}

class _Demo extends StatelessWidget {
  const _Demo();

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(theme.space(6)),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PlinthLineChart(
                    label: 'Revenue by channel, last eight weeks',
                    showArea: true,
                    describeValue: (v) => '\$${v.toStringAsFixed(0)}k',
                    series: const [
                      PlinthChartSeries(
                        name: 'web',
                        values: [32, 35, 34, 38, 41, 39, 44, 47],
                      ),
                      PlinthChartSeries(
                        name: 'retail',
                        values: [18, 19, 17, 21, 20, 23, 22, 24],
                      ),
                    ],
                  ),
                  SizedBox(height: theme.space(8)),

                  // A bar chart is a list, so it is walkable: each bar
                  // is a stop, and each says its label and value.
                  PlinthBarChart(
                    label: 'Top pages this week',
                    describeValue: (v) => '${v.toStringAsFixed(0)} views',
                    bars: const [
                      PlinthBar(label: '/pricing', value: 4820),
                      PlinthBar(label: '/docs', value: 3150),
                      PlinthBar(label: '/blog', value: 1290),
                    ],
                  ),
                  SizedBox(height: theme.space(8)),

                  // A ring rather than a bar, because the total is the
                  // headline and a segmented bar has nowhere to put it.
                  PlinthDonutChart(
                    label: 'Sessions by source',
                    centreLabel: '10.5k',
                    centreCaption: 'sessions',
                    segments: const [
                      PlinthDonutSegment(label: 'Direct', value: 5200),
                      PlinthDonutSegment(label: 'Search', value: 3100),
                      PlinthDonutSegment(label: 'Social', value: 1400),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
