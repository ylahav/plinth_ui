import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One destination in a [PlinthSidebar].
class PlinthNavItem {
  const PlinthNavItem({
    required this.label,
    this.icon,
    this.trailing,
    String? value,
    this.onTap,
    this.children = const [],
  }) : _value = value;

  final String label;
  final Widget? icon;

  /// The far end of the row — an unread count, a status dot.
  final Widget? trailing;
  final String? _value;

  /// What [PlinthSidebar.activeValue] compares against. Defaults to the
  /// label, which is unique in every sidebar worth navigating.
  String get value => _value ?? label;

  final VoidCallback? onTap;

  /// Sub-destinations, rendered as a disclosure under this one.
  final List<PlinthNavItem> children;
}

/// A titled group of destinations.
class PlinthNavSection {
  const PlinthNavSection({required this.items, this.title});

  /// The heading above the group. Null renders the items with no
  /// heading, which is right for the first group in most sidebars.
  final String? title;

  final List<PlinthNavItem> items;
}

/// A vertical navigation rail.
///
/// Covers the sidebar shapes: flat, sectioned, with sub-levels, with a
/// search box, with a user card at the bottom, and collapsible to an
/// icon rail.
///
/// ```dart
/// PlinthSidebar(
///   activeValue: _active,
///   onSelect: (value) => setState(() => _active = value),
///   sections: const [
///     PlinthNavSection(title: 'Workspace', items: [
///       PlinthNavItem(label: 'Home', icon: Icon(Icons.home_outlined)),
///       PlinthNavItem(label: 'Projects', icon: Icon(Icons.folder_outlined)),
///     ]),
///   ],
///   footer: const PlinthNavItem(label: 'Yair Lahav'),
/// )
/// ```
///
/// **Collapsed, the labels are still there.** The rail narrows and the
/// text goes, but each link keeps its accessible name — the version
/// this was extracted from passed an empty string as the label when
/// collapsed, which left a column of icons that a screen reader
/// announced as nothing at all. Visible only to a pair of eyes is not
/// the same as reachable.
class PlinthSidebar extends StatelessWidget {
  const PlinthSidebar({
    super.key,
    required this.sections,
    this.activeValue,
    this.onSelect,
    this.header,
    this.search,
    this.footer,
    this.collapsed = false,
    this.onToggleCollapsed,
    this.openValues = const {},
    this.onOpenedChanged,
    this.width = 220,
    this.collapsedWidth = 64,
    this.height,
  });

  final List<PlinthNavSection> sections;

  /// Which destination is current. Compared against
  /// [PlinthNavItem.value].
  final String? activeValue;

  /// Called with the chosen value. An item's own `onTap` fires too, so
  /// a sidebar can be driven either way.
  final ValueChanged<String>? onSelect;

  /// Above the destinations — a brand, usually.
  final Widget? header;

  /// A filter box. Hidden when [collapsed], since a 64px rail has
  /// nowhere to type.
  final Widget? search;

  /// The bottom of the rail, usually the signed-in user.
  final Widget? footer;

  /// Whether the rail is narrowed to icons.
  final bool collapsed;

  /// Shows a [PlinthBurger] that toggles [collapsed]. Null renders no
  /// toggle, for a rail whose width is not the user's decision.
  final VoidCallback? onToggleCollapsed;

  /// Values of the items whose children are expanded.
  final Set<String> openValues;

  final void Function(String value, bool opened)? onOpenedChanged;

  final double width;

  /// Width when [collapsed]. Wide enough for an icon and its tap
  /// target — the rail narrows rather than disappearing, so the
  /// destinations stay reachable.
  final double collapsedWidth;

  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final children = <Widget>[
      if (onToggleCollapsed case final toggle?)
        PlinthBurger(opened: !collapsed, onPressed: toggle),
      if (header case final header? when !collapsed) header,
      if (search case final search? when !collapsed) search,
      for (final section in sections) ...[
        if (section.title case final title? when !collapsed)
          Padding(
            padding: EdgeInsets.only(
              top: theme.space(3),
              bottom: theme.space(1),
              left: theme.space(2),
            ),
            child: PlinthText(
              title,
              size: PlinthSize.xs,
              color: 'gray',
              weight: FontWeight.w700,
            ),
          ),
        for (final item in section.items) _link(item),
      ],
      if (footer case final footer? when !collapsed) ...[
        const Spacer(),
        const PlinthDivider(),
        footer,
      ],
    ];

    return SizedBox(
      height: height,
      child: PlinthPaper(
        p: PlinthSize.sm,
        withBorder: true,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: collapsed ? collapsedWidth : width,
            child: PlinthStack(gap: PlinthSize.xs, children: children),
          ),
        ),
      ),
    );
  }

  Widget _link(PlinthNavItem item) {
    final link = PlinthNavLink(
      // Empty when collapsed so the text does not force the rail wide.
      // The name is restored below rather than lost with it.
      label: collapsed ? '' : item.label,
      leadingIcon: item.icon,
      // Dropped when collapsed: a badge on a 64px rail has nowhere to
      // sit, and the count is still on the destination it belongs to.
      trailing: collapsed ? null : item.trailing,
      active: activeValue == item.value,
      opened: openValues.contains(item.value),
      onOpenedChanged: onOpenedChanged == null
          ? null
          : (opened) => onOpenedChanged!(item.value, opened),
      onTap: () {
        item.onTap?.call();
        onSelect?.call(item.value);
      },
      children: [
        for (final child in item.children)
          PlinthNavLink(
            label: child.label,
            leadingIcon: child.icon,
            trailing: child.trailing,
            active: activeValue == child.value,
            onTap: () {
              child.onTap?.call();
              onSelect?.call(child.value);
            },
          ),
      ],
    );

    if (!collapsed) return link;

    // Collapsed: the label is gone from the screen, not from the tree.
    // A tooltip gives it back to a pointer, and the semantics label
    // gives it back to everyone else.
    return PlinthTooltip(
      message: item.label,
      child: Semantics(label: item.label, child: link),
    );
  }
}
