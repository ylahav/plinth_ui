import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_scroll_area.dart';
import 'plinth_text.dart';

/// One option in a [PlinthCascader].
class PlinthCascaderOption {
  const PlinthCascaderOption({
    required this.value,
    required this.label,
    this.children = const [],
  });

  /// Unique among its siblings — a path is a list of these, so they
  /// only have to be distinct within one level.
  final String value;

  final String label;
  final List<PlinthCascaderOption> children;

  bool get hasChildren => children.isNotEmpty;
}

/// Column-by-column selection through a hierarchy, matching Mantine's
/// `Cascader`.
///
/// The same data [PlinthTreeSelect] shows, arranged for a different
/// question. A tree is for *finding* one item in a structure you have
/// to explore; this is for *walking a known path* — country → region →
/// city, category → subcategory → type — where every level is a real
/// decision and seeing the alternatives at each one is the point.
///
/// The value is the path, not a leaf: `['eu', 'fr', 'paris']`. That
/// keeps a partial selection representable, which matters because
/// choosing a category without yet choosing its subcategory is a
/// normal intermediate state rather than an error.
///
/// Renders inline. Wrap it in a [PlinthPopover] for the dropdown form
/// — the columns are the part worth having, and keeping the trigger
/// out means it composes into a filter bar or a settings panel just as
/// easily.
///
/// ```dart
/// PlinthCascader(
///   options: _places,
///   value: _path,
///   onChanged: (p) => setState(() => _path = p),
/// )
/// ```
class PlinthCascader extends StatelessWidget {
  const PlinthCascader({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.columnWidth = 160,
    this.height = 200,
    this.size = PlinthSize.md,
    this.color,
  });

  final List<PlinthCascaderOption> options;

  /// The chosen path, outermost level first. Empty means nothing
  /// chosen yet.
  final List<String> value;

  /// Null makes the whole thing read-only.
  final ValueChanged<List<String>>? onChanged;

  final double columnWidth;
  final double height;
  final PlinthSize size;
  final String? color;

  static PlinthCascaderOption? _findIn(
    List<PlinthCascaderOption> level,
    String value,
  ) {
    for (final option in level) {
      if (option.value == value) return option;
    }
    return null;
  }

  /// The columns the current path opens: the roots, then the children
  /// of each chosen option, stopping at the first leaf or dead end.
  List<List<PlinthCascaderOption>> _columns() {
    final columns = <List<PlinthCascaderOption>>[options];
    var level = options;

    for (final step in value) {
      final match = _findIn(level, step);
      if (match == null || !match.hasChildren) break;
      columns.add(match.children);
      level = match.children;
    }

    return columns;
  }

  void _select(int column, PlinthCascaderOption option) {
    // Everything to the right of the level just changed is no longer
    // reachable, so the path is truncated rather than patched.
    onChanged?.call([...value.take(column), option.value]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final columns = _columns();

    final panels = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var c = 0; c < columns.length; c++) ...[
          if (c > 0) VerticalDivider(width: 1, color: theme.surfaceSunken),
          SizedBox(
            width: columnWidth,
            child: PlinthScrollArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final option in columns[c])
                    _Option(
                      option: option,
                      selected: c < value.length && value[c] == option.value,
                      size: size,
                      colorKey: colorKey,
                      onTap:
                          onChanged == null ? null : () => _select(c, option),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );

    // Each panel is a fixed width and each divider a single pixel, so
    // what the row needs is arithmetic rather than a measurement.
    final contentWidth = columnWidth * columns.length +
        (columns.isEmpty ? 0 : columns.length - 1);

    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radius[theme.defaultRadius]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Drilling in adds a panel, so a cascader outgrows a phone
          // after two levels. Panning to the level you are choosing at
          // is how every column browser handles that; shrinking the
          // panels would cost the labels instead.
          //
          // Only when it doesn't fit: a scroll viewport fills the width
          // it is offered, which would stretch the border past the
          // panels on a wide screen where the row shrink-wraps today.
          if (!constraints.hasBoundedWidth ||
              contentWidth <= constraints.maxWidth) {
            return panels;
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: panels,
          );
        },
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.option,
    required this.selected,
    required this.size,
    required this.colorKey,
    required this.onTap,
  });

  final PlinthCascaderOption option;
  final bool selected;
  final PlinthSize size;
  final String colorKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final fontSize = theme.fontSizes[size]!;

    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing[PlinthSize.sm]!,
            vertical: theme.spacing[PlinthSize.xs]! * 0.7,
          ),
          color: selected ? theme.shaded(colorKey, 0) : null,
          child: Row(
            children: [
              Expanded(
                child: PlinthText(
                  option.label,
                  size: size,
                  color: selected ? colorKey : null,
                  weight: selected ? FontWeight.w600 : null,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (option.hasChildren)
                Icon(
                  Icons.keyboard_arrow_right,
                  size: fontSize,
                  // The caret is the only thing distinguishing "opens
                  // another column" from "this is the end of the path".
                  color: selected ? theme.shaded(colorKey, 6) : theme.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
