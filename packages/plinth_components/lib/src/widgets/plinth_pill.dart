import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_close_button.dart';

/// A removable value chip, matching Mantine's `Pill`.
///
/// Three chip-shaped things live in this library and they are not
/// interchangeable:
///
/// * [PlinthBadge] is a **label**. It states something and does
///   nothing — a status, a count, a tag on a card.
/// * [PlinthChip] is a **toggle**. It has selected/unselected state
///   and reports being switched.
/// * This is a **value**. It represents one entry in a collection the
///   user has built, and the only thing it does is leave.
///
/// That last distinction is why it isn't a variant of the other two:
/// a remove button means something quite different from a selected
/// state, and conflating them makes both call sites read wrong.
///
/// Used by [PlinthMultiSelect] and [PlinthTagsInput] for the values in
/// their fields, and available on its own for anywhere else a
/// collection needs to be shown as removable entries.
///
/// ```dart
/// PlinthPill('design', onRemove: () => _remove('design'))
/// ```
class PlinthPill extends StatelessWidget {
  const PlinthPill(
    this.label, {
    super.key,
    this.onRemove,
    this.size = PlinthSize.sm,
    this.color,
    this.radius,
    this.leadingIcon,
  });

  final String label;

  /// Null renders a pill with no remove button — a value that is shown
  /// but can't be taken out.
  final VoidCallback? onRemove;

  final PlinthSize size;

  /// Palette key. Defaults to the theme's muted surface, since a field
  /// full of saturated pills is harder to read than the text in it.
  final String? color;

  /// Defaults to fully rounded, which is what makes a pill a pill.
  final PlinthSize? radius;

  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final fontSize = theme.fontSizes[size]!;

    final Color background;
    final Color foreground;
    if (color != null) {
      background = theme.shaded(color!, 1);
      foreground = theme.readableOn(color!, background);
    } else {
      background = theme.surfaceMuted;
      foreground = theme.text;
    }

    return Container(
      padding: EdgeInsets.only(
        left: fontSize * 0.6,
        right: onRemove == null ? fontSize * 0.6 : 2,
        top: 2,
        bottom: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(
          radius == null ? 999 : theme.radius[radius]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            IconTheme.merge(
              data: IconThemeData(size: fontSize, color: foreground),
              child: leadingIcon!,
            ),
            SizedBox(width: fontSize * 0.3),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: fontSize, color: foreground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRemove != null)
            PlinthCloseButton(
              size: PlinthSize.xs,
              onPressed: onRemove,
              // Named, because a row of identical "close" buttons tells
              // a screen-reader user nothing about which value goes.
              semanticLabel: 'Remove $label',
            ),
        ],
      ),
    );
  }
}
