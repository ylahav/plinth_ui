import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A horizontal application bar: brand on the left, actions on the
/// right, and whatever belongs between them.
///
/// ```dart
/// PlinthTopBar(
///   brand: const PlinthTopBarBrand(
///     icon: Icon(Icons.hexagon),
///     title: 'Dashboard',
///   ),
///   center: PlinthTextInput(
///     placeholder: 'Search',
///     leadingIcon: const Icon(Icons.search, size: 16),
///     onChanged: search,
///   ),
///   actions: [
///     PlinthActionIcon(
///       semanticLabel: 'Notifications',
///       icon: const Icon(Icons.notifications_none, size: 18),
///       onPressed: openNotifications,
///     ),
///     const PlinthAvatar(initials: 'YL', size: PlinthSize.sm),
///   ],
/// )
/// ```
///
/// [center] takes the space between the links and the actions, which is
/// what a search field wants. With nothing there the gap is empty and
/// the actions sit hard right.
class PlinthTopBar extends StatelessWidget {
  const PlinthTopBar({
    super.key,
    this.brand,
    this.links = const [],
    this.center,
    this.actions = const [],
    this.withBorder = true,
    this.padding = PlinthSize.md,
    this.width,
  });

  /// Logo and product name. [PlinthTopBarBrand] is the usual one.
  final Widget? brand;

  /// Destinations, next to the brand.
  ///
  /// Plain widgets rather than a typed item list, because a top bar's
  /// links are as often `PlinthAnchor`s or menus as they are nav links,
  /// and a type here would only be in the way. The sidebar is the one
  /// where structure pays for itself — see [PlinthSidebar].
  final List<Widget> links;

  /// The flexible middle, usually a search field.
  final Widget? center;

  /// The right-hand end: notifications, an avatar, a sign-in button.
  final List<Widget> actions;

  final bool withBorder;
  final PlinthSize padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final bar = PlinthPaper(
      p: padding,
      withBorder: withBorder,
      child: Row(
        children: [
          if (brand case final brand?) ...[
            brand,
            SizedBox(width: theme.space(8)),
          ],
          if (links.isNotEmpty) ...[
            // Flexible and wrapping, not a fixed row: three links plus a
            // brand and a sign-in button do not fit a phone, and a bar
            // that clips them loses the last one entirely. Wrapping to a
            // second line is the lesser cost.
            Flexible(
              child: PlinthGroup(gap: PlinthSize.lg, children: links),
            ),
            SizedBox(width: theme.space(4)),
          ],
          Expanded(child: center ?? const SizedBox.shrink()),
          if (actions.isNotEmpty) ...[
            SizedBox(width: theme.space(4)),
            PlinthGroup(gap: PlinthSize.sm, wrap: false, children: actions),
          ],
        ],
      ),
    );

    return width == null ? bar : SizedBox(width: width, child: bar);
  }
}

/// A logo and a product name, as a [PlinthTopBar.brand].
///
/// The icon is decorative — the title beside it already says what the
/// product is, and a reader that announces both hears the name twice.
class PlinthTopBarBrand extends StatelessWidget {
  const PlinthTopBarBrand({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.variant = PlinthVariant.filled,
  });

  final String title;
  final Widget? icon;

  /// Usually "go home". Null renders the brand as a label rather than
  /// as something that looks pressable and is not.
  final VoidCallback? onTap;

  final PlinthVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon case final icon?) ...[
          ExcludeSemantics(
              child: PlinthThemeIcon(icon: icon, variant: variant)),
          SizedBox(width: theme.space(3)),
        ],
        PlinthText(title, weight: FontWeight.w600),
      ],
    );

    if (onTap case final onTap?) {
      return PlinthUnstyledButton(
        onPressed: onTap,
        child: MergeSemantics(child: content),
      );
    }
    return MergeSemantics(child: content);
  }
}
