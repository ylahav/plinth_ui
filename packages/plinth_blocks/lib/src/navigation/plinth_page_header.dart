import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// The top of a page: what this is, and what you can do to it.
///
/// ```dart
/// PlinthPageHeader(
///   breadcrumbs: PlinthBreadcrumbs(items: [...]),
///   title: 'Plinth UI',
///   actions: [
///     PlinthButton(onPressed: release, child: const Text('New release')),
///   ],
///   below: PlinthTabs(value: _tab, onChanged: select, items: [...]),
/// )
/// ```
///
/// **[title] is a [PlinthTitle], not big text.** Every header this was
/// extracted from rendered its title as `PlinthText` at `size: xl,
/// weight: w700` — which looks the same and is not the same thing. A
/// page's title is the page's heading, and a document whose outline has
/// no top is one a screen reader cannot navigate by. [titleOrder] moves
/// it for a header nested inside something else.
class PlinthPageHeader extends StatelessWidget {
  const PlinthPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.breadcrumbs,
    this.titleTrailing,
    this.actions = const [],
    this.below,
    this.centered = false,
    this.titleOrder = 2,
    this.width,
  });

  final String title;

  /// One line under the title.
  final String? subtitle;

  /// A control before the title — a back button, most often.
  ///
  /// Sits on the **start** side, so it moves to the right in an RTL
  /// locale without the caller doing anything: this is a [Row], and a
  /// Row's first child is its start child.
  ///
  /// Deliberately outside the heading's [MergeSemantics]. A back button
  /// merged into the title would stop being its own focusable control
  /// and would be announced as part of the heading text.
  final Widget? leading;

  /// Where this page sits, above the title. Usually [PlinthBreadcrumbs].
  final Widget? breadcrumbs;

  /// Beside the title — a count, a status pill.
  ///
  /// Next to the title rather than in [actions], because "Issues, 128"
  /// is one fact about the page and belongs with its name. Merged with
  /// the title for assistive technology so it is read as that one fact.
  final Widget? titleTrailing;

  /// What you can do to this page, at the right-hand end.
  final List<Widget> actions;

  /// A row under the header — tabs, filters, a segmented control.
  final Widget? below;

  /// Centres the title and subtitle, for a header with no actions.
  final bool centered;

  final int titleOrder;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final heading = MergeSemantics(
      child: Row(
        mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Flexible(
            child: PlinthTitle(
              title,
              order: titleOrder,
              textAlign: centered ? TextAlign.center : TextAlign.start,
            ),
          ),
          if (titleTrailing case final trailing?) ...[
            SizedBox(width: theme.space(2)),
            trailing,
          ],
        ],
      ),
    );

    // Outside the MergeSemantics above, and outside `heading`, so the
    // control keeps its own semantics node.
    final titleRow = leading == null
        ? heading
        : Row(
            children: [
              leading!,
              SizedBox(width: theme.space(2)),
              Expanded(child: heading),
            ],
          );

    final body = Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (breadcrumbs case final breadcrumbs?) ...[
          breadcrumbs,
          SizedBox(height: theme.space(2)),
        ],
        if (actions.isEmpty)
          titleRow
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: titleRow),
              SizedBox(width: theme.space(4)),
              PlinthGroup(gap: PlinthSize.sm, children: actions),
            ],
          ),
        if (subtitle case final subtitle?) ...[
          SizedBox(height: theme.space(1)),
          PlinthText(
            subtitle,
            size: PlinthSize.sm,
            color: 'gray',
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
        ],
        if (below case final below?) ...[
          SizedBox(height: theme.space(3)),
          below,
        ],
      ],
    );

    final aligned = centered ? PlinthCenter(child: body) : body;
    return width == null ? aligned : SizedBox(width: width, child: aligned);
  }
}

/// A header that stays put while what is under it scrolls.
///
/// A fixed row plus a scrolling [child], rather than a `SliverAppBar`:
/// the header never moves, so there is no collapse behaviour to tune
/// and nothing here needs a `CustomScrollView` to work inside.
///
/// ```dart
/// PlinthStickyHeader(
///   height: 220,
///   header: const PlinthPageHeader(title: 'Members', titleOrder: 4),
///   child: ListView(children: rows),
/// )
/// ```
class PlinthStickyHeader extends StatelessWidget {
  const PlinthStickyHeader({
    super.key,
    required this.header,
    required this.child,
    this.height,
    this.withBorder = true,
    this.headerPadding = const EdgeInsets.all(12),
    this.width,
  });

  /// The part that stays.
  final Widget header;

  /// The part that scrolls. Given a bounded height, so a plain
  /// `ListView` or `SingleChildScrollView` works here.
  final Widget child;

  final double? height;
  final bool withBorder;
  final EdgeInsetsGeometry headerPadding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final panel = SizedBox(
      height: height,
      child: PlinthPaper(
        // xs rather than the md default: the header and the body supply
        // their own padding, and doubling it wastes the panel.
        p: PlinthSize.xs,
        withBorder: withBorder,
        child: Column(
          children: [
            Container(
              padding: headerPadding,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.surfaceSunken),
                ),
              ),
              child: header,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );

    return width == null ? panel : SizedBox(width: width, child: panel);
  }
}
