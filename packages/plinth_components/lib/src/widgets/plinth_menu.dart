import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

import 'plinth_popover.dart';
import 'plinth_text.dart';

/// A single entry in a [PlinthMenu]. Pass `divider: true` for a plain
/// separator line instead of a tappable item (in which case [label]/
/// [onTap] are ignored).
class PlinthMenuItem {
  const PlinthMenuItem({
    this.label = '',
    this.icon,
    this.onTap,
    this.color,
    this.divider = false,
  });

  const PlinthMenuItem.divider() : this(divider: true);

  final String label;
  final Widget? icon;
  final VoidCallback? onTap;

  /// Color key for this item's icon/label — e.g. `'red'` for a
  /// destructive action like "Delete".
  final String? color;

  final bool divider;
}

/// A dropdown menu matching Mantine's `Menu`: a list of tappable
/// items shown in an anchored floating panel.
///
/// Built directly on [PlinthPopover] rather than reimplementing
/// anchored-overlay positioning — a menu is, structurally, a popover
/// whose content happens to be a themed list of items that close the
/// menu when tapped. This mirrors how [PlinthModal]/[PlinthDrawer]
/// share [PlinthOverlayHost] instead of each managing their own
/// listener plumbing.
///
/// ```dart
/// final _menu = PlinthDisclosureController();
///
/// PlinthMenu(
///   controller: _menu,
///   target: PlinthButton(onPressed: _menu.toggle, child: const Icon(Icons.more_vert)),
///   items: [
///     PlinthMenuItem(label: 'Edit', icon: const Icon(Icons.edit), onTap: () {}),
///     const PlinthMenuItem.divider(),
///     PlinthMenuItem(label: 'Delete', color: 'red', icon: const Icon(Icons.delete), onTap: () {}),
///   ],
/// )
/// ```
class PlinthMenu extends StatelessWidget {
  const PlinthMenu({
    super.key,
    required this.controller,
    required this.target,
    required this.items,
    this.position = PlinthPopoverPosition.bottom,
    this.width = 200,
  });

  final PlinthDisclosureController controller;
  final Widget target;
  final List<PlinthMenuItem> items;
  final PlinthPopoverPosition position;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return PlinthPopover(
      controller: controller,
      target: target,
      position: position,
      width: width,
      content: _MenuContent(controller: controller, items: items),
    );
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent({required this.controller, required this.items});

  final PlinthDisclosureController controller;
  final List<PlinthMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          if (item.divider)
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: theme.spacing[PlinthSize.xs]! * 0.5),
              child: const Divider(height: 1),
            )
          else
            InkWell(
              onTap: item.onTap == null
                  ? null
                  : () {
                      controller.close();
                      item.onTap!();
                    },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing[PlinthSize.xs]!,
                  vertical: theme.spacing[PlinthSize.xs]! * 0.8,
                ),
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          size: 16,
                          color: item.color != null
                              ? theme.color(item.color!, 6)
                              : theme.text,
                        ),
                        child: item.icon!,
                      ),
                      SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.8),
                    ],
                    PlinthText(
                      item.label,
                      size: PlinthSize.sm,
                      color: item.color,
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
