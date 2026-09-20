import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One thing the product does.
class PlinthFeature {
  const PlinthFeature({
    required this.title,
    this.description,
    this.icon,
    this.eyebrow,
    this.media,
  });

  /// The claim. In [PlinthFeatureLayout.list] this is the whole line.
  final String title;

  final String? description;

  /// Shown above [title] in a grid, beside it in a list.
  final Widget? icon;

  /// A category label, in [PlinthFeatureLayout.alternating] only.
  final String? eyebrow;

  /// A screenshot or illustration, in [PlinthFeatureLayout.alternating].
  /// Items without one render full width rather than leaving a hole.
  final Widget? media;
}

/// How a [PlinthFeatureBlock] arranges its features.
enum PlinthFeatureLayout {
  /// Cards across, icon above the words. Good for three or four short
  /// claims that are peers.
  grid,

  /// A checklist. Good for many short claims, and for the ones that
  /// are really a specification.
  list,

  /// Text and picture down the page, sides alternating. Good for a
  /// small number of claims that each need showing.
  alternating,
}

/// A "what it does" section.
///
/// Three layouts on one item type, because a feature grid, a feature
/// checklist and a row of alternating screenshots are the same content
/// shown at three densities.
///
/// ```dart
/// PlinthFeatureBlock(
///   features: const [
///     PlinthFeature(
///       icon: Icon(Icons.bolt_outlined),
///       title: 'Fast',
///       description: 'Optimised rebuilds with no widget churn.',
///     ),
///   ],
/// )
/// ```
///
/// **The tick in a checklist is decorative.** It is the same mark on
/// every row, so it carries no information a reader does not already
/// have from the row being in the list — and read aloud on every item
/// it is thirty repetitions of the word "check". It is hidden from
/// assistive technology unless you pass an icon that means something.
class PlinthFeatureBlock extends StatelessWidget {
  const PlinthFeatureBlock({
    super.key,
    required this.features,
    this.title,
    this.subtitle,
    this.layout = PlinthFeatureLayout.grid,
    this.columns = 3,
    this.minColWidth = 200,
    this.checkColor = 'green',
    this.mediaFirst = false,
    this.minAlternatingWidth = 520,
    this.width,
    this.titleOrder = 3,
  });

  final List<PlinthFeature> features;

  final String? title;
  final String? subtitle;
  final PlinthFeatureLayout layout;

  /// Columns in [PlinthFeatureLayout.grid], before [minColWidth]
  /// reduces them.
  final int columns;

  /// Width below which the grid drops a column.
  final double minColWidth;

  /// Palette key for the default checklist tick.
  ///
  /// A key rather than a [Color], so a tick resolves against the theme
  /// and stays legible in dark mode. The showcase version of this block
  /// hardcoded `Color(0xFF40C057)`, which is Mantine's green 6 frozen
  /// at one shade.
  final String checkColor;

  /// Starts [PlinthFeatureLayout.alternating] with the picture rather
  /// than the words.
  final bool mediaFirst;

  /// Width below which alternating rows stack instead.
  final double minAlternatingWidth;

  final double? width;
  final int titleOrder;

  @override
  Widget build(BuildContext context) {
    final body = PlinthStack(
      gap: PlinthSize.md,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title case final title?) PlinthTitle(title, order: titleOrder),
        if (subtitle case final subtitle?)
          PlinthText(subtitle, size: PlinthSize.sm, color: 'gray'),
        switch (layout) {
          PlinthFeatureLayout.grid => _grid(context),
          PlinthFeatureLayout.list => _list(context),
          PlinthFeatureLayout.alternating => _alternating(context),
        },
      ],
    );

    return width == null ? body : SizedBox(width: width, child: body);
  }

  Widget _grid(BuildContext context) {
    return PlinthSimpleGrid(
      columns: columns,
      minColWidth: minColWidth,
      children: [
        for (final feature in features)
          PlinthStack(
            gap: PlinthSize.xs,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (feature.icon case final icon?)
                ExcludeSemantics(
                  child: PlinthThemeIcon(
                    icon: icon,
                    variant: PlinthVariant.light,
                  ),
                ),
              PlinthText(feature.title, weight: FontWeight.w600),
              if (feature.description case final description?)
                PlinthText(description, size: PlinthSize.sm, color: 'gray'),
            ],
          ),
      ],
    );
  }

  Widget _list(BuildContext context) {
    final theme = context.plinth;

    return PlinthList(
      items: [
        for (final feature in features)
          PlinthListItem(
            PlinthStack(
              gap: PlinthSize.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlinthText(feature.title),
                if (feature.description case final description?)
                  PlinthText(description, size: PlinthSize.sm, color: 'gray'),
              ],
            ),
            icon: feature.icon ??
                ExcludeSemantics(
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    // Resolved against the surface rather than frozen at
                    // one shade, so it survives the theme flipping.
                    color: theme.readableOn(checkColor, theme.surface),
                  ),
                ),
          ),
      ],
    );
  }

  Widget _alternating(BuildContext context) {
    final theme = context.plinth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (width ?? double.infinity);
        final stacked = available < minAlternatingWidth;

        return PlinthStack(
          gap: PlinthSize.lg,
          children: [
            for (final (index, feature) in features.indexed)
              _AlternatingRow(
                feature: feature,
                // The alternation is the arrangement. Doing it by hand
                // is where a row ends up on the same side as the one
                // above it.
                mediaOnLeft: mediaFirst ? index.isEven : index.isOdd,
                stacked: stacked,
                gap: theme.spacing[PlinthSize.lg]!,
              ),
          ],
        );
      },
    );
  }
}

class _AlternatingRow extends StatelessWidget {
  const _AlternatingRow({
    required this.feature,
    required this.mediaOnLeft,
    required this.stacked,
    required this.gap,
  });

  final PlinthFeature feature;
  final bool mediaOnLeft;
  final bool stacked;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final words = PlinthStack(
      gap: PlinthSize.xs,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (feature.eyebrow case final eyebrow?) PlinthBadge(eyebrow),
        PlinthTitle(feature.title, order: 4),
        if (feature.description case final description?)
          PlinthText(description, size: PlinthSize.sm, color: 'gray'),
      ],
    );

    final media = feature.media;
    if (media == null) return words;

    if (stacked) {
      // Words first regardless of side when stacked: the alternation
      // was a horizontal rhythm, and keeping it vertically just moves
      // the caption above the picture for half the rows.
      return PlinthStack(gap: PlinthSize.sm, children: [words, media]);
    }

    final panes = <Widget>[
      Expanded(child: words),
      SizedBox(width: gap),
      Expanded(child: media),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: mediaOnLeft ? panes.reversed.toList() : panes,
    );
  }
}
