import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A titled column of links in a [PlinthFooter].
class PlinthFooterColumn {
  const PlinthFooterColumn({required this.title, required this.links});

  final String title;
  final List<Widget> links;
}

/// The bottom of a page.
///
/// Four arrangements, which differ in how much of the page they are
/// entitled to: a marketing footer with columns of links, a simpler one
/// with a row of them, one with a newsletter form, and a one-line
/// status bar for an app.
///
/// ```dart
/// PlinthFooter(
///   brand: 'Acme',
///   copyright: '© 2026',
///   links: [
///     PlinthAnchor('Privacy', size: PlinthSize.sm, onTap: privacy),
///     PlinthAnchor('Terms', size: PlinthSize.sm, onTap: terms),
///   ],
/// )
/// ```
///
/// **[dense] is the app footer, and it is a different intent.** The
/// footer of a tool should take a row, not a screen — so it drops the
/// card, keeps a top rule, and puts everything on one line. Status
/// belongs where it can be glanced at rather than hunted for.
class PlinthFooter extends StatelessWidget {
  const PlinthFooter({
    super.key,
    this.brand,
    this.copyright,
    this.links = const [],
    this.columns = const [],
    this.leading,
    this.trailing,
    this.dense = false,
    this.width,
  });

  /// The product name. Rendered bold beside [copyright].
  final String? brand;

  /// The rights line. Kept as text you pass, because the year is a
  /// fact about your build rather than about this widget.
  final String? copyright;

  /// A row of links, opposite the brand.
  final List<Widget> links;

  /// Columns of links under the brand, for a marketing footer. When
  /// set, [links] renders as the bottom row beneath them.
  final List<PlinthFooterColumn> columns;

  /// Before the brand — a logo, or a status dot in [dense] mode.
  final Widget? leading;

  /// After the links — a newsletter form, a language picker.
  final Widget? trailing;

  /// One line, no card: the footer of an app rather than of a page.
  final bool dense;

  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    // Also a wrapping group. A `Row` here takes its intrinsic width, so
    // a copyright line long enough to be a sentence pushes the footer
    // wider than the page it sits at the bottom of.
    final identity = <Widget>[
      if (leading case final leading?) leading,
      if (brand case final brand?) PlinthText(brand, weight: FontWeight.w700),
      if (copyright case final copyright?)
        PlinthText(copyright, size: PlinthSize.xs, color: 'gray'),
    ];

    // A wrapping group rather than a Row with a Spacer: a brand, a
    // copyright line, three links and a newsletter field do not fit a
    // phone, and a footer that clips drops the last link — which is
    // usually the one somebody was looking for. It wraps to a second
    // line instead.
    final bottomRow = PlinthGroup(
      gap: PlinthSize.md,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (identity.isNotEmpty)
          PlinthGroup(gap: PlinthSize.sm, children: identity),
        if (links.isNotEmpty) PlinthGroup(gap: PlinthSize.md, children: links),
        if (trailing case final trailing?) trailing,
      ],
    );

    if (dense) {
      final bar = Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing[PlinthSize.md]!,
          vertical: theme.spacing[PlinthSize.xs]!,
        ),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.surfaceSunken)),
        ),
        child: bottomRow,
      );
      return width == null ? bar : SizedBox(width: width, child: bar);
    }

    final card = PlinthPaper(
      withBorder: true,
      p: PlinthSize.md,
      child: columns.isEmpty
          ? bottomRow
          : PlinthStack(
              gap: PlinthSize.lg,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlinthSimpleGrid(
                  columns: columns.length,
                  minColWidth: 120,
                  children: [
                    for (final column in columns)
                      PlinthStack(
                        gap: PlinthSize.xs,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PlinthText(
                            column.title,
                            size: PlinthSize.xs,
                            color: 'gray',
                            weight: FontWeight.w700,
                          ),
                          ...column.links,
                        ],
                      ),
                  ],
                ),
                const PlinthDivider(),
                bottomRow,
              ],
            ),
    );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}
