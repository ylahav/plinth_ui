import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A themeable data table matching Mantine's `Table`.
///
/// Built on Flutter's low-level [Table] widget rather than
/// [DataTable] — [DataTable] brings its own fairly opinionated
/// Material styling (fixed row heights, built-in sorting/selection
/// chrome) that would fight against a themeable design system more
/// than it would help. [Table] just handles column alignment, which
/// is the part actually worth not reimplementing.
///
/// Cells are plain strings; there's no per-cell custom-widget escape
/// hatch yet (e.g. an icon button in a cell) — flag if you need that.
///
/// ```dart
/// PlinthTable(
///   columns: const ['Name', 'Role', 'Status'],
///   rows: const [
///     ['Alice', 'Engineer', 'Active'],
///     ['Bob', 'Designer', 'Invited'],
///   ],
/// )
/// ```
class PlinthTable extends StatelessWidget {
  const PlinthTable({
    super.key,
    required this.columns,
    required this.rows,
    this.striped = false,
    this.size = PlinthSize.md,
  });

  final List<String> columns;

  /// Each inner list must have the same length as [columns].
  final List<List<String>> rows;

  /// Alternates row background color when true.
  final bool striped;

  final PlinthSize size;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final cellPadding = EdgeInsets.symmetric(
      horizontal: theme.spacing[PlinthSize.sm]!,
      vertical: theme.spacing[PlinthSize.xs]!,
    );

    Widget cell(String text, {bool header = false}) {
      return Padding(
        padding: cellPadding,
        child: PlinthText(
          text,
          size: size,
          weight: header ? FontWeight.w700 : FontWeight.w400,
        ),
      );
    }

    return Table(
      border: const TableBorder(
        horizontalInside: BorderSide(color: Color(0xFFE9ECEF)),
        bottom: BorderSide(color: Color(0xFFE9ECEF)),
      ),
      columnWidths: {
        for (var i = 0; i < columns.length; i++) i: const FlexColumnWidth(),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Color(0xFFDEE2E6), width: 2)),
          ),
          children: [for (final column in columns) cell(column, header: true)],
        ),
        for (var r = 0; r < rows.length; r++)
          TableRow(
            decoration: striped && r.isOdd
                ? const BoxDecoration(color: Color(0xFFF8F9FA))
                : null,
            children: [for (final value in rows[r]) cell(value)],
          ),
      ],
    );
  }
}
