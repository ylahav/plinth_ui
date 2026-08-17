import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_collapse.dart';
import 'plinth_text.dart';

/// A sidebar-style navigation item matching Mantine's `NavLink`:
/// icon, label, active-state highlighting, and optional trailing
/// content (e.g. a badge showing an unread count).
///
/// ```dart
/// PlinthNavLink(
///   label: 'Dashboard',
///   leadingIcon: const Icon(Icons.dashboard_outlined),
///   active: _route == 'dashboard',
///   onTap: () => setState(() => _route = 'dashboard'),
/// )
/// ```
///
/// ## Nesting
///
/// [children] makes the link a disclosure: they sit indented beneath
/// it and animate in and out. Whether they are showing is [opened],
/// controlled by the caller like every other disclosure here, and a
/// tap reports the flip through [onOpenedChanged]:
///
/// ```dart
/// PlinthNavLink(
///   label: 'Analytics',
///   leadingIcon: const Icon(Icons.insights_outlined),
///   opened: _open == 'analytics',
///   onOpenedChanged: (o) => setState(() => _open = o ? 'analytics' : ''),
///   children: [
///     for (final page in _pages)
///       PlinthNavLink(
///         label: page,
///         active: _active == page,
///         onTap: () => setState(() => _active = page),
///       ),
///   ],
/// )
/// ```
///
/// A parent can be a destination as well as a disclosure — pass
/// [onTap] too and a tap calls both. Keeping them separate is what
/// lets a parent that is *only* a grouping heading stay unreachable
/// as a route, which is the shape a sidebar usually wants.
///
/// The chevron is supplied for you when there are children, unless
/// [trailing] fills that slot with something of its own.
///
/// [PlinthCollapse] keeps the children mounted while closed, so a
/// deep tree pays to build every branch. For a sidebar that is the
/// point — the state in a branch survives closing it — but a tree of
/// hundreds of nodes wants [PlinthTree], which builds what it shows.
class PlinthNavLink extends StatelessWidget {
  const PlinthNavLink({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailing,
    this.active = false,
    this.onTap,
    this.color,
    this.children = const [],
    this.opened = false,
    this.onOpenedChanged,
    this.childrenOffset,
  });

  final String label;
  final Widget? leadingIcon;

  /// Content shown at the trailing edge, e.g. a `PlinthBadge` for an
  /// unread count. Replaces the disclosure chevron when there are
  /// [children].
  final Widget? trailing;

  final bool active;
  final VoidCallback? onTap;
  final String? color;

  /// Nested links, shown indented beneath this one while [opened].
  final List<Widget> children;

  /// Whether [children] are showing. Ignored when there are none.
  final bool opened;

  /// Reports the flipped value when a link with [children] is tapped.
  final ValueChanged<bool>? onOpenedChanged;

  /// How far [children] are indented, in logical pixels. Defaults to
  /// the theme's `lg` spacing, which lines a child's label up under
  /// its parent's rather than its parent's icon.
  final double? childrenOffset;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.shaded(colorKey, 6);
    final activeBackground = theme.shaded(colorKey, 0);
    final resolvedRadius = theme.radius[theme.defaultRadius]!;
    final hasChildren = children.isNotEmpty;

    // A link with children is tappable even without an onTap: opening
    // them is the thing the tap does.
    final VoidCallback? handleTap = hasChildren
        ? () {
            onOpenedChanged?.call(!opened);
            onTap?.call();
          }
        : onTap;

    final row = Material(
      color: active ? activeBackground : Colors.transparent,
      borderRadius: BorderRadius.circular(resolvedRadius),
      child: InkWell(
        onTap: handleTap,
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing[PlinthSize.sm]!,
            vertical: theme.spacing[PlinthSize.xs]!,
          ),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: 18,
                    color: active ? activeColor : theme.textMuted,
                  ),
                  child: leadingIcon!,
                ),
                SizedBox(width: theme.spacing[PlinthSize.xs]),
              ],
              Expanded(
                child: PlinthText(
                  label,
                  size: PlinthSize.sm,
                  weight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? colorKey : null,
                ),
              ),
              if (trailing != null)
                trailing!
              else if (hasChildren)
                // Rotated rather than swapped for a second glyph, so
                // it turns with the reveal instead of snapping.
                AnimatedRotation(
                  turns: opened ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: 16,
                    color: active ? activeColor : theme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!hasChildren) return row;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Expanded state belongs on the row that flips it, not on the
        // column: it's the link that is expandable, and a screen
        // reader reads the state alongside the label it applies to.
        Semantics(container: true, expanded: opened, child: row),
        PlinthCollapse(
          opened: opened,
          child: Padding(
            padding: EdgeInsets.only(
              left: childrenOffset ?? theme.spacing[PlinthSize.lg]!,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
