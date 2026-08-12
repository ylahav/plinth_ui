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
/// Cells are widgets, so a status column can hold a [PlinthBadge], a
/// person column a [PlinthAvatar], an actions column a
/// [PlinthActionIcon]:
///
/// ```dart
/// PlinthTable(
///   columns: const ['Name', 'Status'],
///   rows: [
///     [const PlinthText('Alice'), const PlinthBadge('Active', color: 'green')],
///     [const PlinthText('Bob'), const PlinthBadge('Invited', color: 'gray')],
///   ],
/// )
/// ```
///
/// Columns share the available width, so a cell is width-bounded: a
/// `Row` inside one needs a `Flexible` or `Expanded` around anything
/// that can grow, or it will overflow rather than ellipsize.
///
/// For a table that is only text — most of them — [PlinthTable.text]
/// takes plain strings and styles them for you, which stays `const`
/// and avoids wrapping every value:
///
/// ```dart
/// PlinthTable.text(
///   columns: const ['Name', 'Role'],
///   rows: const [
///     ['Alice', 'Engineer'],
///     ['Bob', 'Designer'],
///   ],
/// )
/// ```
class PlinthTable extends StatelessWidget {
  /// A table whose cells are arbitrary widgets.
  const PlinthTable({
    super.key,
    required this.columns,
    required List<List<Widget>> rows,
    this.striped = false,
    this.size = PlinthSize.md,
  })  : _widgetRows = rows,
        _textRows = null;

  /// A table of plain text, styled for you.
  ///
  /// Kept as a separate constructor rather than an `Object` cell type:
  /// a table of strings is the common case and should not have to wrap
  /// every value, while a union type would make the widget case
  /// unclear at the call site.
  const PlinthTable.text({
    super.key,
    required this.columns,
    required List<List<String>> rows,
    this.striped = false,
    this.size = PlinthSize.md,
  })  : _textRows = rows,
        _widgetRows = null;

  final List<String> columns;

  final List<List<Widget>>? _widgetRows;
  final List<List<String>>? _textRows;

  /// Alternates row background color when true.
  final bool striped;

  final PlinthSize size;

  /// How many rows the table holds, whichever constructor was used.
  int get rowCount => _widgetRows?.length ?? _textRows!.length;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final cellPadding = EdgeInsets.symmetric(
      horizontal: theme.spacing[PlinthSize.sm]!,
      vertical: theme.spacing[PlinthSize.xs]!,
    );

    Widget pad(Widget child) => Padding(padding: cellPadding, child: child);

    Widget textCell(String text, {bool header = false}) {
      return pad(
        PlinthText(
          text,
          size: size,
          weight: header ? FontWeight.w700 : FontWeight.w400,
        ),
      );
    }

    // Widget cells still get the table's padding and a default text
    // style, so a bare Text in one lines up with a PlinthTable.text
    // cell beside it rather than sitting flush against the border.
    List<Widget> cellsFor(int row) {
      final textRows = _textRows;
      if (textRows != null) {
        return [for (final value in textRows[row]) textCell(value)];
      }
      return [
        for (final child in _widgetRows![row])
          pad(
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: theme.fontSizes[size],
                color: theme.text,
              ),
              child: child,
            ),
          ),
      ];
    }

    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(color: theme.surfaceSunken),
        bottom: BorderSide(color: theme.surfaceSunken),
      ),
      // Middle rather than top: a row mixing a badge or an avatar with
      // plain text looks misaligned otherwise, and mixed-height cells
      // are the reason widget cells exist.
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        for (var i = 0; i < columns.length; i++) i: const FlexColumnWidth(),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: theme.borderMuted, width: 2)),
          ),
          children: [
            for (final column in columns) textCell(column, header: true),
          ],
        ),
        for (var r = 0; r < rowCount; r++)
          TableRow(
            decoration: striped && r.isOdd
                ? BoxDecoration(color: theme.surfaceMuted)
                : null,
            children: cellsFor(r),
          ),
      ],
    );
  }
}
