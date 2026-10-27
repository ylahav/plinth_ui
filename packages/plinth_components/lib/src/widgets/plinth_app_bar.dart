import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_action_icon.dart';
import 'plinth_localizations.dart';
import 'plinth_text.dart';

/// The bar across the top of a page, for `Scaffold.appBar`.
///
/// A title, an optional [leading] widget, and [actions] at the far end.
/// When there is no [leading] and the page can be popped, a back button
/// takes its place; [automaticallyImplyLeading] turns that off.
///
/// ```dart
/// Scaffold(
///   appBar: PlinthAppBar(
///     title: 'Statistics',
///     actions: [
///       PlinthActionIcon(
///         icon: const Icon(Icons.refresh),
///         semanticLabel: 'Refresh',
///         variant: PlinthVariant.subtle,
///         onPressed: _reload,
///       ),
///     ],
///   ),
///   body: ...,
/// )
/// ```
///
/// Colours come from the theme (the surface, the text colour, a hairline
/// border under it), so it follows a dark or light theme without being
/// told. The status-bar inset is added to the height, so the bar sits
/// below it on a phone and is [height] tall everywhere else.
///
/// [title] is a string for the common case; pass [titleWidget] when the
/// title is more than text. Give one or neither, not both.
class PlinthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlinthAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions = const [],
    this.automaticallyImplyLeading = true,
    this.height = 56,
  }) : assert(
          title == null || titleWidget == null,
          'Give a title or a titleWidget, not both.',
        );

  final String? title;
  final Widget? titleWidget;

  /// Replaces the back button. Give a menu button here to open a drawer.
  final Widget? leading;

  /// Widgets at the trailing end, in order.
  final List<Widget> actions;

  /// Whether a back button stands in when [leading] is null and the page
  /// can be popped.
  final bool automaticallyImplyLeading;

  /// Height of the bar itself, without the status-bar inset.
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final gap = theme.spacing[PlinthSize.sm]!;

    Widget? start = leading;
    if (start == null &&
        automaticallyImplyLeading &&
        (ModalRoute.of(context)?.canPop ?? false)) {
      start = PlinthActionIcon(
        icon: const Icon(Icons.arrow_back),
        semanticLabel: context.plinthStrings.back,
        variant: PlinthVariant.subtle,
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    final heading = titleWidget ??
        (title == null
            ? null
            : PlinthText(
                title!,
                size: PlinthSize.lg,
                weight: theme.weight(PlinthWeight.semibold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ));

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Material(
        color: theme.surface,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.border)),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: gap),
                child: Row(
                  children: [
                    if (start != null) ...[start, SizedBox(width: gap)],
                    Expanded(child: heading ?? const SizedBox.shrink()),
                    for (final action in actions) ...[
                      SizedBox(width: gap),
                      action,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
