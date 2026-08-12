import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// The page scaffold matching Mantine's `AppShell`: an optional
/// [header] and [footer] spanning the full width, an optional [navbar]
/// and [aside] down either side, and [child] filling what's left.
///
/// ```
/// ┌─────────────────────────────┐
/// │           header            │
/// ├────────┬───────────┬────────┤
/// │ navbar │   child   │ aside  │
/// ├────────┴───────────┴────────┤
/// │           footer            │
/// └─────────────────────────────┘
/// ```
///
/// Every region is optional, and one left `null` takes no space at all
/// rather than rendering empty — the same convention [PlinthCard] uses
/// for its header and footer.
///
/// **Collapsing is controlled by the caller**, matching
/// [PlinthTabs]/[PlinthStepper] rather than managing a breakpoint
/// internally. A shell that collapsed its own navbar would own a
/// piece of state the surrounding page also needs (to point a
/// [PlinthBurger] at it, or to decide whether to offer the same links
/// in a [PlinthDrawer] instead), and splitting that ownership causes
/// more trouble than the convenience saves. The responsive pattern:
///
/// ```dart
/// final narrow = MediaQuery.sizeOf(context).width < 768;
///
/// PlinthAppShell(
///   navbarCollapsed: narrow,
///   header: PlinthGroup(
///     children: [
///       if (narrow) PlinthBurger(opened: _open, onPressed: _toggle),
///       const PlinthTitle('Dashboard', order: 4),
///     ],
///   ),
///   navbar: const NavLinks(),
///   child: const PageContent(),
/// )
/// ```
///
/// The shell fills whatever space it is given, so it expects a bounded
/// height — put it directly inside a `Scaffold` body rather than
/// inside a scrolling column. [child] is the part that should scroll,
/// if anything does.
class PlinthAppShell extends StatelessWidget {
  const PlinthAppShell({
    super.key,
    required this.child,
    this.header,
    this.headerHeight = 60,
    this.navbar,
    this.navbarWidth = 260,
    this.navbarCollapsed = false,
    this.aside,
    this.asideWidth = 260,
    this.asideCollapsed = false,
    this.footer,
    this.footerHeight = 60,
    this.padding = PlinthSize.md,
    this.withBorder = true,
    this.bg,
  });

  /// The main content region.
  final Widget child;

  final Widget? header;
  final double headerHeight;

  /// The side region, on the start side (left in LTR).
  final Widget? navbar;
  final double navbarWidth;

  /// Hides [navbar] without unmounting the rest of the layout. Pair
  /// with a [PlinthDrawer] to reach the same links on narrow screens.
  final bool navbarCollapsed;

  /// The side region, on the end side (right in LTR).
  final Widget? aside;
  final double asideWidth;
  final bool asideCollapsed;

  final Widget? footer;
  final double footerHeight;

  /// Padding applied to [child] only. The header, navbar, aside, and
  /// footer are given the full extent of their region so they can
  /// paint edge to edge; pad their own content if they need it.
  final PlinthSize padding;

  /// Draws hairline dividers between the regions.
  final bool withBorder;

  /// Color key into the theme palette for the [child] region's
  /// background, resolved at shade 0. Null leaves it transparent.
  final String? bg;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final borderColor = theme.color('gray', 2);
    final border =
        withBorder ? BorderSide(color: borderColor, width: 1) : BorderSide.none;

    final showNavbar = navbar != null && !navbarCollapsed;
    final showAside = aside != null && !asideCollapsed;

    return Column(
      children: [
        if (header != null)
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              border: Border(bottom: border),
            ),
            child: header,
          ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showNavbar)
                Container(
                  width: navbarWidth,
                  decoration: BoxDecoration(
                    border: Border(right: border),
                  ),
                  child: navbar,
                ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(theme.spacing[padding]!),
                  color: bg != null ? theme.color(bg!, 0) : null,
                  child: child,
                ),
              ),
              if (showAside)
                Container(
                  width: asideWidth,
                  decoration: BoxDecoration(
                    border: Border(left: border),
                  ),
                  child: aside,
                ),
            ],
          ),
        ),
        if (footer != null)
          Container(
            height: footerHeight,
            decoration: BoxDecoration(
              border: Border(top: border),
            ),
            child: footer,
          ),
      ],
    );
  }
}
