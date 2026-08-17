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
///
/// `direction: Axis.vertical` stacks the tabs instead, with the
/// indicator down the trailing edge — the shape a settings sidebar
/// wants, and the one where a dozen tabs stay readable.
class PlinthTabs<T> extends StatelessWidget {
  const PlinthTabs({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.size = PlinthSize.md,
    this.color,
    this.direction = Axis.horizontal,
  });

  final List<PlinthTabItem<T>> tabs;
  final T value;
  final ValueChanged<T> onChanged;
  final PlinthSize size;
  final String? color;

  /// Which way the strip runs. Vertical puts the tabs in a column and
  /// moves both the divider and the active indicator to their trailing
  /// edge, so the content sits to the right of the list.
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.shaded(colorKey, 6);
    final verticalPadding = theme.spacing[size]! * 0.5;
    final horizontalPadding = theme.spacing[size]!;
    final isVertical = direction == Axis.vertical;

    Widget tabButton(PlinthTabItem<T> tab) {
      final selected = tab.value == value;
      final indicator = BorderSide(
        color: selected ? activeColor : Colors.transparent,
        width: 2,
      );
      final label = PlinthText(
        tab.label,
        size: size,
        weight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? colorKey : null,
      );

      return InkWell(
        onTap: () => onChanged(tab.value),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            border: isVertical
                ? Border(right: indicator)
                : Border(bottom: indicator),
          ),
          child: Row(
            // Vertical tabs are stretched to the strip's width, so
            // their content would centre in whatever the widest label
            // demands; a column of labels reads as a list only when
            // they share a left edge.
            mainAxisSize: isVertical ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (tab.icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: 16,
                    color: selected ? activeColor : Colors.grey,
                  ),
                  child: tab.icon!,
                ),
                SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
              ],
              // Flexible only where the width is bounded: a horizontal
              // strip lays out inside a scroll view with no width to
              // divide up, and a flex child there is a layout error.
              if (isVertical) Flexible(child: label) else label,
            ],
          ),
        ),
      );
    }

    final strip = isVertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final tab in tabs) tabButton(tab)],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final tab in tabs) tabButton(tab)],
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: isVertical
            ? Border(right: BorderSide(color: theme.surfaceSunken))
            : Border(bottom: BorderSide(color: theme.surfaceSunken)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Nothing can overflow without room to overflow — and a
          // scroll view needs a bounded main axis, so a tab bar sitting
          // in a `Row`/`Column` without an `Expanded` keeps the plain
          // strip.
          if (isVertical) {
            // `stretch` needs a width to stretch to. Unbounded, the
            // column takes its widest tab's width instead, which still
            // gives every indicator the same edge to sit on.
            final sized = constraints.hasBoundedWidth
                ? strip
                : IntrinsicWidth(child: strip);
            if (!constraints.hasBoundedHeight) return sized;
            return SingleChildScrollView(child: sized);
          }

          if (!constraints.hasBoundedWidth) return strip;

          // More tabs than fit is the ordinary case on a phone, and
          // the platform answer to it is a strip that pans rather than
          // one that clips or wraps. The viewport fills the width it is
          // given, so the underline runs the width of the container the
          // way Mantine's list does, rather than stopping at the last
          // tab.
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: strip,
          );
        },
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
