import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// One entry in a [PlinthList].
class PlinthListItem {
  const PlinthListItem(this.content, {this.icon});

  /// The item's text or arbitrary widget content.
  final Widget content;

  /// Overrides this item's marker — an icon, a custom number, etc.
  /// Falls back to the parent list's bullet/numbering when omitted.
  final Widget? icon;
}

/// A bulleted, numbered, or custom-icon list matching Mantine's
/// `List`. Each item can override its own marker via
/// [PlinthListItem.icon] — e.g. a checklist mixing checkmarks and
/// crosses.
///
/// ```dart
/// PlinthList(
///   items: [
///     PlinthListItem(PlinthText('First step')),
///     PlinthListItem(PlinthText('Second step')),
///     PlinthListItem(
///       PlinthText('Optional step'),
///       icon: Icon(Icons.check_circle, color: Colors.green, size: 16),
///     ),
///   ],
/// )
/// ```
class PlinthList extends StatelessWidget {
  const PlinthList({
    super.key,
    required this.items,
    this.type = PlinthListType.bullet,
    this.spacing = PlinthSize.xs,
    this.size = PlinthSize.md,
  });

  final List<PlinthListItem> items;
  final PlinthListType type;
  final PlinthSize spacing;
  final PlinthSize size;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final gap = theme.spacing[spacing]!;
    final fontSize = theme.fontSizes[size]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: fontSize,
                child: items[i].icon ?? _defaultMarker(theme, fontSize, i),
              ),
              SizedBox(width: theme.spacing[PlinthSize.xs]!),
              Expanded(child: items[i].content),
            ],
          ),
        ],
      ],
    );
  }

  Widget _defaultMarker(PlinthTheme theme, double fontSize, int index) {
    switch (type) {
      case PlinthListType.bullet:
        return Container(
          margin: EdgeInsets.only(top: fontSize * 0.4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.shaded(theme.primaryColor, 6),
            shape: BoxShape.circle,
          ),
        );
      case PlinthListType.ordered:
        return Text(
          '${index + 1}.',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        );
    }
  }
}

enum PlinthListType { bullet, ordered }
