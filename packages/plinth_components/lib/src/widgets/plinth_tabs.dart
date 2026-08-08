import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A single tab for [PlinthTabs].
class PlinthTabItem<T> {
  const PlinthTabItem(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final Widget? icon;
}

/// A themeable tab bar matching Mantine's `Tabs`: an underline
/// indicator on the active tab, theme-driven color and sizing.
///
/// Deliberately implemented as a plain row of bordered tabs rather
/// than a measured sliding-indicator animation (the kind that needs
/// `GlobalKey`/`RenderBox` size lookups to animate an indicator's
/// position between arbitrary-width tabs) — that approach is easy to
/// get subtly wrong without a live SDK to iterate against, and a
/// static per-tab underline is both simpler and just as readable.
///
/// Pair with [PlinthTabView] to switch content based on the same
/// `value`:
///
/// ```dart
/// PlinthTabs<String>(
///   value: _tab,
///   onChanged: (v) => setState(() => _tab = v),
///   tabs: const [
///     PlinthTabItem('account', 'Account'),
///     PlinthTabItem('security', 'Security'),
///   ],
/// ),
/// PlinthTabView<String>(
///   value: _tab,
///   children: const {
///     'account': Text('Account settings'),
///     'security': Text('Security settings'),
///   },
/// ),
/// ```
class PlinthTabs<T> extends StatelessWidget {
  const PlinthTabs({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.size = PlinthSize.md,
    this.color,
  });

  final List<PlinthTabItem<T>> tabs;
  final T value;
  final ValueChanged<T> onChanged;
  final PlinthSize size;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.color(colorKey, 6);
    final verticalPadding = theme.spacing[size]! * 0.5;
    final horizontalPadding = theme.spacing[size]!;

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE9ECEF))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tab in tabs)
            InkWell(
              onTap: () => onChanged(tab.value),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          tab.value == value ? activeColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          size: 16,
                          color: tab.value == value ? activeColor : Colors.grey,
                        ),
                        child: tab.icon!,
                      ),
                      SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
                    ],
                    PlinthText(
                      tab.label,
                      size: size,
                      weight: tab.value == value
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: tab.value == value ? colorKey : null,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Switches between [children] based on [value], with a fade
/// transition. Pairs with [PlinthTabs] — pass the same `value`/type
/// parameter to both.
///
/// If [value] has no matching key in [children], renders nothing
/// (rather than throwing), since that's a recoverable state a caller
/// might hit transiently — e.g. a tab list built from async data that
/// hasn't loaded a matching panel yet.
class PlinthTabView<T> extends StatelessWidget {
  const PlinthTabView({
    super.key,
    required this.value,
    required this.children,
  });

  final T value;
  final Map<T, Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: KeyedSubtree(
        key: ValueKey(value),
        child: children[value] ?? const SizedBox.shrink(),
      ),
    );
  }
}
