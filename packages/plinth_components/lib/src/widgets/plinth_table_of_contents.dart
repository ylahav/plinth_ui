import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// One heading in a [PlinthTableOfContents].
class PlinthTocItem {
  const PlinthTocItem({
    required this.label,
    this.order = 1,
    this.targetKey,
  });

  final String label;

  /// Heading level, 1–6, matching [PlinthTitle]'s `order`. Drives the
  /// indent, so a level-3 heading sits under the level-2 above it.
  final int order;

  /// Attach the same key to the heading widget and this entry will
  /// scroll to it when tapped, without the caller wiring up offsets.
  ///
  /// Only works if the heading is actually built: scrolling to it goes
  /// through `Scrollable.ensureVisible`, which needs a live context. In
  /// a lazy `ListView` anything far below the fold hasn't been built
  /// yet, so use a `SingleChildScrollView` — or handle
  /// [PlinthTableOfContents.onSelected] and jump by index yourself.
  final GlobalKey? targetKey;
}

/// A jump list built from a page's headings, matching Mantine's
/// `TableOfContents`.
///
/// **Headings are passed in, not discovered.** Mantine's version reads
/// them out of the DOM; Flutter has no document to walk, and crawling
/// the widget tree for [PlinthTitle]s would be both fragile and unable
/// to see anything not yet built inside a lazy list. So the list is
/// explicit — which also means it can name sections that aren't
/// headings at all.
///
/// Give an item a [PlinthTocItem.targetKey] matching a key on the
/// heading itself and tapping it scrolls there; otherwise handle
/// [onSelected] yourself.
///
/// ```dart
/// PlinthTableOfContents(
///   items: const [
///     PlinthTocItem(label: 'Introduction'),
///     PlinthTocItem(label: 'Installing', order: 2),
///   ],
///   activeIndex: _visibleSection,
/// )
/// ```
class PlinthTableOfContents extends StatelessWidget {
  const PlinthTableOfContents({
    super.key,
    required this.items,
    this.activeIndex,
    this.onSelected,
    this.size = PlinthSize.sm,
    this.color,
    this.indent = 14,
    this.withRail = true,
    this.scrollDuration = const Duration(milliseconds: 300),
  });

  final List<PlinthTocItem> items;

  /// Which entry is currently on screen. The caller decides — it's the
  /// only part that knows where the page is scrolled to.
  final int? activeIndex;

  final ValueChanged<int>? onSelected;

  final PlinthSize size;
  final String? color;

  /// Pixels of indent per heading level below the shallowest.
  final double indent;

  /// Draws the vertical rule that marks the active entry.
  final bool withRail;

  final Duration scrollDuration;

  /// Indent is relative: a document whose headings start at level 2
  /// shouldn't sit permanently indented.
  int get _baseOrder => items.isEmpty
      ? 1
      : items.map((i) => i.order).reduce((a, b) => a < b ? a : b);

  void _handleTap(int index) {
    onSelected?.call(index);

    final target = items[index].targetKey?.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: scrollDuration,
        curve: Curves.easeOutCubic,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final base = _baseOrder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          Builder(
            builder: (context) {
              final item = items[i];
              final active = activeIndex == i;
              final depth = (item.order - base).clamp(0, 5);

              return Semantics(
                button: true,
                selected: active,
                label: item.label,
                excludeSemantics: true,
                child: InkWell(
                  onTap: () => _handleTap(i),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: theme.spacing[PlinthSize.sm]! + depth * indent,
                      top: theme.spacing[PlinthSize.xs]! * 0.7,
                      bottom: theme.spacing[PlinthSize.xs]! * 0.7,
                    ),
                    decoration: withRail
                        ? BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: active
                                    ? theme.shaded(colorKey, 6)
                                    : theme.surfaceSunken,
                                width: 2,
                              ),
                            ),
                          )
                        : null,
                    child: PlinthText(
                      item.label,
                      size: size,
                      // The active entry carries both weight and colour:
                      // a rail alone is easy to miss at a glance, and
                      // colour alone doesn't survive a mono display.
                      weight: active ? FontWeight.w600 : null,
                      color: active ? colorKey : 'gray',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
