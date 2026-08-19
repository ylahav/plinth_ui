import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A single crumb in a [PlinthBreadcrumbs] trail.
class PlinthBreadcrumbItem {
  const PlinthBreadcrumbItem({required this.label, this.onTap});

  final String label;

  /// Tapping this crumb calls this, if provided. The *last* item in
  /// a [PlinthBreadcrumbs] is always rendered non-interactive
  /// regardless of whether it has an [onTap] — matching Mantine's
  /// convention that the current page isn't itself a link.
  final VoidCallback? onTap;
}

/// A navigation trail matching Mantine's `Breadcrumbs`: a row of
/// tappable crumbs separated by a divider character, with the final
/// crumb (the current page) rendered as plain, non-interactive text.
///
/// ```dart
/// PlinthBreadcrumbs(
///   items: [
///     PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
///     PlinthBreadcrumbItem(label: 'Settings', onTap: () {}),
///     const PlinthBreadcrumbItem(label: 'Profile'),
///   ],
/// )
/// ```
class PlinthBreadcrumbs extends StatelessWidget {
  const PlinthBreadcrumbs({
    super.key,
    required this.items,
    this.separator = '/',
    this.color,
  });

  final List<PlinthBreadcrumbItem> items;
  final String separator;

  /// Color key for interactive (non-last) crumbs. Defaults to the
  /// theme's primary color.
  final String? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final linkColor = theme.shaded(colorKey, 6);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: PlinthText(separator,
                  size: PlinthSize.sm,
                  color: theme.rampFor(PlinthRole.neutral)),
            ),
          _Crumb(
            item: items[i],
            isLast: i == items.length - 1,
            linkColor: linkColor,
          ),
        ],
      ],
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb(
      {required this.item, required this.isLast, required this.linkColor});

  final PlinthBreadcrumbItem item;
  final bool isLast;
  final Color linkColor;

  @override
  Widget build(BuildContext context) {
    if (isLast) {
      return Text(
        item.label,
        style: TextStyle(fontSize: 14, color: context.plinth.textMuted),
      );
    }

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(4),
      child: Text(
        item.label,
        style: TextStyle(fontSize: 14, color: linkColor),
      ),
    );
  }
}
