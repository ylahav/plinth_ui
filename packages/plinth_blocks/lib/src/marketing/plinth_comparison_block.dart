import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One row of a comparison: what is being compared, and the answer for
/// each column.
class PlinthComparisonRow {
  const PlinthComparisonRow({required this.label, required this.values});

  /// The feature, down the left.
  final String label;

  /// One entry per plan, in the same order as
  /// [PlinthComparisonBlock.plans].
  ///
  /// A `String` renders as text; a `bool` renders as a tick or a cross
  /// with a label an assistive technology can read, because an
  /// unlabelled tick in a matrix is a cell that reads as nothing.
  final List<Object> values;
}

/// A feature matrix — plans across, features down.
///
/// A matrix rather than a row of cards, because the reader's question
/// is what *differs* between the plans, and columns answer it directly
/// where cards make them hold three lists in their head.
///
/// ```dart
/// PlinthComparisonBlock(
///   title: 'Compare plans',
///   plans: const ['Free', 'Pro'],
///   rows: const [
///     PlinthComparisonRow(label: 'Components', values: ['All', 'All']),
///     PlinthComparisonRow(label: 'Private themes', values: [false, true]),
///   ],
/// )
/// ```
///
/// **Every row is checked against the plan count** in debug, because a
/// matrix with a short row does not look broken — it silently shifts
/// every answer after it one column to the left, which is a pricing
/// page that lies.
class PlinthComparisonBlock extends StatelessWidget {
  PlinthComparisonBlock({
    super.key,
    required this.plans,
    required this.rows,
    this.title,
    this.featureHeading = 'Feature',
    this.yesLabel = 'Included',
    this.noLabel = 'Not included',
    this.width,
    this.titleOrder = 4,
  }) : assert(
          rows.isEmpty ||
              rows.every((row) => row.values.length == plans.length),
          'every row needs one value per plan — a short row shifts every '
          'answer after it into the wrong column',
        );

  /// The column headings, left to right.
  final List<String> plans;

  final List<PlinthComparisonRow> rows;

  final String? title;

  /// Heading for the left-hand column.
  final String featureHeading;

  /// What a `true` cell is called when it is read aloud. The tick is a
  /// picture; this is the text behind it.
  final String yesLabel;

  /// What a `false` cell is called when it is read aloud.
  final String noLabel;

  final double? width;
  final int titleOrder;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final table = PlinthTable(
      columns: [featureHeading, ...plans],
      rows: [
        for (final row in rows)
          [
            PlinthText(row.label),
            for (final value in row.values) _cell(theme, value),
          ],
      ],
    );

    final body = PlinthStack(
      gap: PlinthSize.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title case final title?) PlinthTitle(title, order: titleOrder),
        table,
      ],
    );

    return width == null ? body : SizedBox(width: width, child: body);
  }

  Widget _cell(PlinthTheme theme, Object value) {
    if (value is bool) {
      // Labelled, not bare. A tick with no text is a cell that reads as
      // nothing, and a row of them is a table a screen reader cannot
      // answer the question with.
      return Semantics(
        label: value ? yesLabel : noLabel,
        child: ExcludeSemantics(
          child: Icon(
            value ? Icons.check : Icons.close,
            size: 16,
            color: value
                ? theme.readableOn('green', theme.surface)
                : theme.textMuted,
          ),
        ),
      );
    }

    if (value is Widget) return value;
    return PlinthText('$value');
  }
}
