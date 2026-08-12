import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A sidebar-style navigation item matching Mantine's `NavLink`:
/// icon, label, active-state highlighting, and optional trailing
/// content (e.g. a badge showing an unread count).
///
/// ```dart
/// PlinthNavLink(
///   label: 'Dashboard',
///   icon: const Icon(Icons.dashboard_outlined),
///   active: _route == 'dashboard',
///   onTap: () => setState(() => _route = 'dashboard'),
/// )
/// ```
class PlinthNavLink extends StatelessWidget {
  const PlinthNavLink({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
    this.active = false,
    this.onTap,
    this.color,
  });

  final String label;
  final Widget? icon;

  /// Content shown at the trailing edge, e.g. a `PlinthBadge` for an
  /// unread count.
  final Widget? trailing;

  final bool active;
  final VoidCallback? onTap;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.color(colorKey, 6);
    final activeBackground = theme.color(colorKey, 0);
    final resolvedRadius = theme.radius[theme.defaultRadius]!;

    return Material(
      color: active ? activeBackground : Colors.transparent,
      borderRadius: BorderRadius.circular(resolvedRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing[PlinthSize.sm]!,
            vertical: theme.spacing[PlinthSize.xs]!,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: 18,
                    color: active ? activeColor : theme.textMuted,
                  ),
                  child: icon!,
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
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
