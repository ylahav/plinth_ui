import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// How a [PlinthDataList] arranges each label against its value.
enum PlinthDataListOrientation {
  /// Label and value side by side, labels sharing one aligned column.
  horizontal,

  /// Label stacked above its value. What narrow layouts want.
  vertical,
}

/// One label/value pair in a [PlinthDataList].
class PlinthDataListItem {
  /// A pair whose value is an arbitrary widget — a badge for a status,
  /// an anchor for an email, a copy button beside an ID.
  const PlinthDataListItem({required this.label, required Widget value})
      : _widgetValue = value,
        _textValue = null;

  /// A pair whose value is plain text, styled for you.
  ///
  /// The same split [PlinthTable] settled on, and for the same reason:
  /// most values are text and shouldn't have to be wrapped, while an
  /// `Object`-typed value would leave the widget case unclear at the
  /// call site.
  const PlinthDataListItem.text(this.label, String value)
      : _textValue = value,
        _widgetValue = null;

  final String label;

  final Widget? _widgetValue;
  final String? _textValue;
}

/// Key/value pairs in a definition-list layout, matching Mantine's
/// `DataList`.
///
/// The layout a detail panel wants — an order summary, a resource's
/// metadata, the "about" block on a profile. Distinct from
/// [PlinthTable], which is for many records sharing columns; this is
/// for one record's fields, where the label belongs to the value
/// rather than to a column.
///
/// ```dart
/// PlinthDataList(
///   items: const [
///     PlinthDataListItem.text('Order', '#4021'),
///     PlinthDataListItem.text('Placed', '12 Aug 2026'),
///   ],
/// )
/// ```
class PlinthDataList extends StatelessWidget {
  const PlinthDataList({
    super.key,
    required this.items,
    this.orientation = PlinthDataListOrientation.horizontal,
    this.gap = PlinthSize.sm,
    this.labelGap = PlinthSize.md,
    this.size = PlinthSize.md,
    this.labelColor,
  });

  final List<PlinthDataListItem> items;
  final PlinthDataListOrientation orientation;

  /// Between one pair and the next.
  final PlinthSize gap;

  /// Between a label and its value.
  final PlinthSize labelGap;

  final PlinthSize size;

  /// Palette key for the labels. Defaults to the theme's muted text,
  /// which is the point of the component: the label is chrome and the
  /// value is the content, so they shouldn't carry equal weight.
  final String? labelColor;

  Widget _value(PlinthDataListItem item) {
    return item._widgetValue ?? PlinthText(item._textValue!, size: size);
  }

  Widget _label(BuildContext context, PlinthDataListItem item) {
    final theme = context.plinth;

    return DefaultTextStyle.merge(
      style: TextStyle(
        color: labelColor != null
            ? theme.readableOn(labelColor!, theme.surface)
            : theme.textMuted,
        fontSize: theme.fontSizes[size],
      ),
      child: Text(item.label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final rowGap = theme.spacing[gap]!;
    final pairGap = theme.spacing[labelGap]!;

    if (orientation == PlinthDataListOrientation.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: rowGap),
            // Stacked, the pair is a single run of text, so merging it
            // reads as "Order, #4021" rather than two separate stops.
            MergeSemantics(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(context, items[i]),
                  SizedBox(height: rowGap / 2),
                  _value(items[i]),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // Labels align in one column without the caller measuring anything,
    // which is the same reason PlinthTable is built on Table:
    // IntrinsicColumnWidth is the part not worth reimplementing.
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (var i = 0; i < items.length; i++)
          TableRow(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: pairGap,
                  bottom: i == items.length - 1 ? 0 : rowGap,
                ),
                child: _label(context, items[i]),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == items.length - 1 ? 0 : rowGap,
                ),
                child: _value(items[i]),
              ),
            ],
          ),
      ],
    );
  }
}
