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
///
/// ## Sorting and filtering
///
/// Both need something comparable to work with, and **a widget cell
/// has no value to compare** — a `PlinthBadge` isn't greater or less
/// than another one. So a text table sorts and filters out of the box,
/// while a widget table needs [sortValues]: the plain strings standing
/// behind the widgets, in the same shape as the rows.
///
/// ```dart
/// PlinthTable(
///   columns: const ['Name', 'Status'],
///   sortable: true,
///   filter: _query,
///   rows: rows,
///   sortValues: const [
///     ['Alice', 'Active'],
///     ['Bob', 'Invited'],
///   ],
/// )
/// ```
///
/// Sorting is uncontrolled by default: tapping a header sorts in
/// place, tapping again reverses it. Pass [onSortChanged] to take that
/// over — the table then reports the sort it *would* apply and leaves
/// the row order alone, which is what a server-side or paginated table
/// needs. That's the same split as [PlinthTabs]/[PlinthTabView].
///
/// ## A header that stays put
///
/// Mantine spells this `stickyHeader`, a flag on top of the page's own
/// scrolling. Flutter has no page scroll to stick to, so the table has
/// to own one — and a scroll view needs a height. [maxHeight] is
/// therefore the whole feature in one prop: give the table a ceiling
/// and its rows scroll under a header that stays.
///
/// ```dart
/// PlinthTable.text(
///   columns: const ['Name', 'Role'],
///   rows: manyRows,
///   maxHeight: 320,
///   highlightOnHover: true,
/// )
/// ```
///
/// A separate `stickyHeader: true` would only be a flag that throws
/// when the height it needs is missing, which is a prop that can be
/// set wrong. Below the ceiling the table is its natural height, so
/// short tables don't grow to fill it.
class PlinthTable extends StatefulWidget {
  /// A table whose cells are arbitrary widgets.
  const PlinthTable({
    super.key,
    required this.columns,
    required List<List<Widget>> rows,
    List<List<String>>? sortValues,
    this.striped = false,
    this.size = PlinthSize.md,
    this.sortable = false,
    this.sortColumn,
    this.sortAscending = true,
    this.onSortChanged,
    this.filter,
    this.emptyState,
    this.highlightOnHover = false,
    this.maxHeight,
  })  : _widgetRows = rows,
        _textRows = null,
        _sortValues = sortValues;

  /// A table of plain text, styled for you.
  ///
  /// Kept as a separate constructor rather than an `Object` cell type:
  /// a table of strings is the common case and should not have to wrap
  /// every value, while a union type would make the widget case
  /// unclear at the call site.
  ///
  /// Its own strings are what sorting and filtering compare, so
  /// neither needs anything extra here.
  const PlinthTable.text({
    super.key,
    required this.columns,
    required List<List<String>> rows,
    this.striped = false,
    this.size = PlinthSize.md,
    this.sortable = false,
    this.sortColumn,
    this.sortAscending = true,
    this.onSortChanged,
    this.filter,
    this.emptyState,
    this.highlightOnHover = false,
    this.maxHeight,
  })  : _textRows = rows,
        _widgetRows = null,
        _sortValues = null;

  final List<String> columns;

  final List<List<Widget>>? _widgetRows;
  final List<List<String>>? _textRows;

  /// Plain values behind widget cells, for sorting and filtering.
  /// Unused by [PlinthTable.text], which already has them.
  final List<List<String>>? _sortValues;

  /// Alternates row background color when true.
  final bool striped;

  final PlinthSize size;

  /// Makes every header tappable, with a direction caret on the active
  /// column.
  final bool sortable;

  /// The column to show as sorted. Only meaningful alongside
  /// [onSortChanged] — without it the table tracks its own.
  final int? sortColumn;
  final bool sortAscending;

  /// Takes ownership of sorting. When set, the table reports the sort
  /// it would apply and does **not** reorder anything itself.
  final void Function(int column, bool ascending)? onSortChanged;

  /// Keeps only rows with a value containing this text, case
  /// insensitively, across every column. Null or empty shows all rows.
  final String? filter;

  /// Shown in place of the rows when nothing matches [filter]. A
  /// [PlinthEmptyState] is the natural fit.
  final Widget? emptyState;

  /// Tints the row under the pointer. Pairs with [maxHeight]: the
  /// longer the table, the more a row needs help staying one row as
  /// the eye crosses it.
  ///
  /// Pointer-only by nature, so it is decoration rather than
  /// information — nothing here is reachable only by hovering.
  final bool highlightOnHover;

  /// Caps the table's height and scrolls the rows under a header that
  /// stays. Null lets the table be as tall as its rows.
  final double? maxHeight;

  /// How many rows the table was given, before any filtering.
  int get rowCount => _widgetRows?.length ?? _textRows!.length;

  /// The comparable values for a row, or null when there are none.
  List<String>? valuesFor(int row) {
    final text = _textRows;
    if (text != null) return text[row];
    final values = _sortValues;
    if (values == null || row >= values.length) return null;
    return values[row];
  }

  bool get _hasValues => _textRows != null || _sortValues != null;

  @override
  State<PlinthTable> createState() => _PlinthTableState();
}

class _PlinthTableState extends State<PlinthTable> {
  int? _sortColumn;
  bool _ascending = true;

  /// Index into the *displayed* order, not into the caller's rows —
  /// it follows the pointer, and the pointer is over a position.
  int? _hoveredRow;

  void _hover(int? row) {
    if (_hoveredRow == row) return;
    setState(() => _hoveredRow = row);
  }

  /// The caller owns the order the moment it asks to be told about it.
  bool get _controlled => widget.onSortChanged != null;

  int? get _activeColumn => _controlled ? widget.sortColumn : _sortColumn;
  bool get _activeAscending => _controlled ? widget.sortAscending : _ascending;

  void _onHeaderTap(int column) {
    // First tap on a new column sorts ascending; tapping the active
    // one reverses it, which is what every table people have used does.
    final ascending = _activeColumn == column ? !_activeAscending : true;

    if (_controlled) {
      widget.onSortChanged!(column, ascending);
    } else {
      setState(() {
        _sortColumn = column;
        _ascending = ascending;
      });
    }
  }

  /// Numeric where both sides are numbers, textual otherwise — so a
  /// quantity column orders 9 before 10 rather than after it.
  static int _compare(String a, String b) {
    final left = num.tryParse(a.trim());
    final right = num.tryParse(b.trim());
    if (left != null && right != null) return left.compareTo(right);
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  List<int> _resolveRows() {
    var indices = [for (var i = 0; i < widget.rowCount; i++) i];

    final query = widget.filter?.trim().toLowerCase();
    if (query != null && query.isNotEmpty) {
      indices = indices.where((i) {
        final values = widget.valuesFor(i);
        if (values == null) return true;
        return values.any((v) => v.toLowerCase().contains(query));
      }).toList();
    }

    final column = _activeColumn;
    if (!_controlled && column != null) {
      indices.sort((a, b) {
        final left = widget.valuesFor(a);
        final right = widget.valuesFor(b);
        if (left == null || right == null) return a.compareTo(b);
        if (column >= left.length || column >= right.length) {
          return a.compareTo(b);
        }

        final result = _compare(left[column], right[column]);
        // Dart's sort isn't stable, so equal keys fall back to the
        // original order rather than shuffling on every rebuild.
        if (result != 0) return _activeAscending ? result : -result;
        return a.compareTo(b);
      });
    }

    return indices;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !widget.sortable || widget._hasValues,
      'PlinthTable.sortable needs values to compare. Pass sortValues '
      'alongside widget rows, or use PlinthTable.text.',
    );
    assert(
      widget.filter == null || widget._hasValues,
      'PlinthTable.filter needs values to match against. Pass sortValues '
      'alongside widget rows, or use PlinthTable.text.',
    );

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
          size: widget.size,
          weight: header ? FontWeight.w700 : FontWeight.w400,
        ),
      );
    }

    // Widget cells still get the table's padding and a default text
    // style, so a bare Text in one lines up with a PlinthTable.text
    // cell beside it rather than sitting flush against the border.
    List<Widget> cellsFor(int row) {
      final textRows = widget._textRows;
      if (textRows != null) {
        return [for (final value in textRows[row]) textCell(value)];
      }
      return [
        for (final child in widget._widgetRows![row])
          pad(
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: theme.fontSizes[widget.size],
                color: theme.text,
              ),
              child: child,
            ),
          ),
      ];
    }

    Widget headerCell(int index) {
      final label = widget.columns[index];
      if (!widget.sortable) return textCell(label, header: true);

      final active = _activeColumn == index;
      final ascending = _activeAscending;

      return Semantics(
        button: true,
        // Without this a screen reader gets a bare column name and no
        // hint that the header does anything, let alone which way it
        // is currently ordered.
        label: active
            ? '$label, sorted ${ascending ? 'ascending' : 'descending'}'
            : '$label, not sorted',
        excludeSemantics: true,
        child: InkWell(
          onTap: () => _onHeaderTap(index),
          child: pad(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: PlinthText(
                    label,
                    size: widget.size,
                    weight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.4),
                Icon(
                  active
                      ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                      : Icons.unfold_more,
                  size: theme.fontSizes[widget.size]! * 0.9,
                  // The inactive caret stays visible but recedes: it's
                  // the affordance that says the header is tappable.
                  color: active ? theme.text : theme.textDisabled,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final rows = _resolveRows();

    // Every column is an equal-flex share of the available width, which
    // is what lets the header and the body be two separate tables when
    // the header has to stay put: flex widths come from the space, not
    // from the content, so both land on the same column edges.
    final columnWidths = {
      for (var i = 0; i < widget.columns.length; i++)
        i: const FlexColumnWidth(),
    };

    final headerRow = TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.borderMuted, width: 2)),
      ),
      children: [
        for (var i = 0; i < widget.columns.length; i++) headerCell(i),
      ],
    );

    // Cells rather than rows carry the hover region: a TableRow is
    // configuration, not a widget, so there is nothing spanning a row
    // to wrap. Entering any cell claims the row; only leaving the
    // whole table gives it up, so the few pixels a short cell doesn't
    // cover in a tall row don't make the highlight flicker.
    Widget hoverable(int display, Widget cell) {
      if (!widget.highlightOnHover) return cell;
      return MouseRegion(
        onEnter: (_) => _hover(display),
        child: cell,
      );
    }

    BoxDecoration? rowDecoration(int display) {
      if (widget.highlightOnHover && _hoveredRow == display) {
        return BoxDecoration(color: theme.surfaceSunken);
      }
      if (widget.striped && display.isOdd) {
        return BoxDecoration(color: theme.surfaceMuted);
      }
      return null;
    }

    final bodyRows = [
      for (var r = 0; r < rows.length; r++)
        TableRow(
          decoration: rowDecoration(r),
          children: [
            for (final cell in cellsFor(rows[r])) hoverable(r, cell),
          ],
        ),
    ];

    Table table(List<TableRow> children, TableBorder border) => Table(
          border: border,
          // Middle rather than top: a row mixing a badge or an avatar
          // with plain text looks misaligned otherwise, and mixed-height
          // cells are the reason widget cells exist.
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: children,
        );

    final bodyBorder = TableBorder(
      horizontalInside: BorderSide(color: theme.surfaceSunken),
      bottom: BorderSide(color: theme.surfaceSunken),
    );

    Widget result;
    if (widget.maxHeight == null) {
      result = table([headerRow, ...bodyRows], bodyBorder);

      if (rows.isEmpty && widget.emptyState != null) {
        // A Table can't hold a widget spanning every column, so the
        // empty state sits below the header rather than inside the grid.
        result = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [result, widget.emptyState!],
        );
      }
    } else {
      result = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The header table stops one hairline short of the first row
          // so the seam between the two tables looks like the line
          // `horizontalInside` draws everywhere else.
          table(
            [headerRow],
            TableBorder(bottom: BorderSide(color: theme.surfaceSunken)),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // A Table with no rows has no columns either, which
                  // its own width assertions don't survive.
                  if (bodyRows.isNotEmpty) table(bodyRows, bodyBorder),
                  if (rows.isEmpty && widget.emptyState != null)
                    widget.emptyState!,
                ],
              ),
            ),
          ),
        ],
      );

      result = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: result,
      );
    }

    if (!widget.highlightOnHover) return result;
    return MouseRegion(
      onExit: (_) => _hover(null),
      child: result,
    );
  }
}
