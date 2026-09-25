/// A whole screen: safe area, header, and a body that gets the rest.
///
/// [PlinthPageHeader] was only ever the header, so every app that used
/// it still hand-wrote the same shell around it — `Scaffold`,
/// `SafeArea`, a `Column`, and an `Expanded` so a `ListView` would
/// work. Found while converting an existing app onto Plinth, where that
/// shell existed once per app under a name like `AppPage`.
///
/// **No `AppBar`.** A Material app bar brings a fixed height, its own
/// title typography and a `leading` slot with Material's back-button
/// behaviour baked in. The header here is [PlinthPageHeader], so the
/// title stays a real heading at [titleOrder] and scales with the type
/// scale rather than with `AppBar`'s.
library;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import 'plinth_page_header.dart';

class PlinthPage extends StatelessWidget {
  const PlinthPage({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.below,
    this.titleOrder = 2,
    this.padding,
    this.background,
    this.scrollableBody = false,
  });

  final String title;
  final String? subtitle;

  /// Before the title, on the start side — a back button, usually.
  /// RTL-aware, because [PlinthPageHeader.leading] is.
  final Widget? leading;

  /// After the title, on the end side.
  final List<Widget> actions;

  /// Under the header and above [body], inside the page padding — a
  /// filter row, a segmented control, a search field.
  ///
  /// Distinct from putting it at the top of [body]: this does not
  /// scroll away, because it sits outside the part that scrolls.
  final Widget? below;

  /// The heading level. 2 by default: a page title is the document's
  /// heading under an `h1` the app supplies, and dropping straight to
  /// the first heading a screen reader finds is how a page ends up with
  /// no outline at all.
  final int titleOrder;

  /// Fills the remaining height, unbounded, so a plain `ListView` works
  /// here without a `shrinkWrap` or an intrinsic-height trick.
  final Widget body;

  /// Around header and body. Defaults to `md` horizontally and `md` on
  /// top, and **nothing at the bottom** — a list that stops short of
  /// the bottom edge looks like it has ended when it has not.
  final EdgeInsetsGeometry? padding;

  /// Page background. Defaults to [PlinthTheme.surfaceMuted], so cards
  /// and papers in [body] read as raised off it rather than blending
  /// into a flat [PlinthTheme.surface].
  final Color? background;

  /// Wraps [body] in a scroll view.
  ///
  /// Leave it false when [body] scrolls already — a `ListView` inside a
  /// `SingleChildScrollView` is unbounded in both and throws.
  final bool scrollableBody;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final gutter = theme.space(4);
    final resolvedPadding =
        padding ?? EdgeInsets.only(left: gutter, right: gutter, top: gutter);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlinthPageHeader(
          title: title,
          subtitle: subtitle,
          leading: leading,
          actions: actions,
          below: below,
          titleOrder: titleOrder,
        ),
        SizedBox(height: theme.space(3)),
        Expanded(
          child: scrollableBody ? SingleChildScrollView(child: body) : body,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: background ?? theme.surfaceMuted,
      body: SafeArea(
        child: Padding(padding: resolvedPadding, child: content),
      ),
    );
  }
}
