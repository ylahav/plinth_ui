import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A single event in a [PlinthTimeline].
class PlinthTimelineItem {
  const PlinthTimelineItem({
    required this.title,
    this.description,
    this.icon,
    this.active = false,
  });

  final String title;
  final String? description;

  /// Icon shown inside the dot marker. Omit for a plain filled dot.
  final Widget? icon;

  /// Highlights this item's dot in the theme color instead of gray —
  /// use for the current/most-recent event in the sequence.
  final bool active;
}

/// A vertical event timeline matching Mantine's `Timeline`: dot
/// markers connected by a line, with a title/description per event.
///
/// ```dart
/// PlinthTimeline(
///   items: [
///     PlinthTimelineItem(
///       title: 'Order placed',
///       description: 'Jan 3, 10:24 AM',
///       icon: const Icon(Icons.shopping_bag_outlined),
///       active: true,
///     ),
///     const PlinthTimelineItem(
///       title: 'Shipped',
///       description: 'Pending',
///     ),
///   ],
/// )
/// ```
class PlinthTimeline extends StatelessWidget {
  const PlinthTimeline({
    super.key,
    required this.items,
    this.color,
    this.align = PlinthTimelineAlign.start,
  });

  final List<PlinthTimelineItem> items;
  final String? color;

  /// Which side the rail of dots runs down. [PlinthTimelineAlign.end]
  /// puts it on the trailing edge with the text to its left, which is
  /// what a timeline in a right-hand column wants so the rail sits
  /// against the content rather than against the page edge.
  ///
  /// Directional rather than left/right: in an RTL locale `start` is
  /// already the right-hand side, and a timeline that ignored that
  /// would be the only component here that does.
  final PlinthTimelineAlign align;

  static const double _dotSize = 24;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.shaded(colorKey, 6);

    return Column(
      crossAxisAlignment: align == PlinthTimelineAlign.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          _TimelineRow(
            item: items[i],
            isLast: i == items.length - 1,
            activeColor: activeColor,
            align: align,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.item,
    required this.isLast,
    required this.activeColor,
    required this.align,
  });

  final PlinthTimelineItem item;
  final bool isLast;
  final Color activeColor;
  final PlinthTimelineAlign align;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final dotColor = item.active ? activeColor : theme.border;

    final rail = Column(
      children: [
        Container(
          width: PlinthTimeline._dotSize,
          height: PlinthTimeline._dotSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.active ? activeColor : theme.surface,
            border: Border.all(color: dotColor, width: 2),
          ),
          child: item.icon != null
              ? IconTheme(
                  data: IconThemeData(
                    size: 12,
                    color: item.active
                        ? theme.contrastingOn(activeColor)
                        : theme.textMuted,
                  ),
                  child: item.icon!,
                )
              : null,
        ),
        if (!isLast)
          Expanded(child: Container(width: 2, color: theme.surfaceSunken)),
      ],
    );

    final body = Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: theme.spacing[PlinthSize.md]!),
        child: Column(
          crossAxisAlignment: align == PlinthTimelineAlign.end
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            PlinthText(item.title, weight: FontWeight.w600),
            if (item.description != null) ...[
              SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.3),
              PlinthText(item.description!,
                  size: PlinthSize.sm,
                  color: theme.rampFor(PlinthRole.neutral)),
            ],
          ],
        ),
      ),
    );

    final gap = SizedBox(width: theme.spacing[PlinthSize.sm]);
    final isEnd = align == PlinthTimelineAlign.end;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: isEnd ? [body, gap, rail] : [rail, gap, body],
      ),
    );
  }
}

/// Which side of a [PlinthTimeline] its rail of dots runs down.
enum PlinthTimelineAlign { start, end }
