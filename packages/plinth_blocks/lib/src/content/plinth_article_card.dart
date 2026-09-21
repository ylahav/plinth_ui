import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// How a [PlinthArticleCard] arranges itself.
enum PlinthArticleLayout {
  /// Image above the words. The default, and what a grid of cards
  /// wants.
  stacked,

  /// Image beside them. A feed of these fits far more articles on
  /// screen, and the image can shrink without the headline reflowing.
  horizontal,

  /// Words over the image, on a scrim.
  overlay,
}

/// One article in a feed.
///
/// ```dart
/// PlinthArticleCard(
///   title: 'Building a design system from scratch',
///   excerpt: 'What we learned shipping tokens to three apps.',
///   category: const PlinthBadge('Design', color: 'orange'),
///   image: const PlinthImage(src: '…'),
///   meta: '12 Aug · 6 min read',
///   onTap: openArticle,
/// )
/// ```
///
/// **The headline is a heading.** A feed is a list of documents, and a
/// screen reader skims it by heading — a page of cards whose titles are
/// bold text is one long undifferentiated run. [titleOrder] moves it
/// for a feed nested under a section heading of its own.
///
/// **The image is decorative here.** The headline beside it says what
/// the article is; an alt text repeating that is heard twice. Pass an
/// image with its own semantics if it carries information the words
/// do not.
class PlinthArticleCard extends StatelessWidget {
  const PlinthArticleCard({
    super.key,
    required this.title,
    this.excerpt,
    this.image,
    this.category,
    this.author,
    this.meta,
    this.onTap,
    this.layout = PlinthArticleLayout.stacked,
    this.imageWidth = 96,
    this.imageRatio = 16 / 9,
    this.overlayHeight = 180,
    this.scrimOpacity = 0.5,
    this.titleOrder = 4,
    this.width,
  });

  final String title;

  /// A line or two under the headline.
  final String? excerpt;

  /// The picture. Null renders the card without one, which the
  /// horizontal and stacked layouts both handle.
  final Widget? image;

  /// A topic badge above the headline.
  final Widget? category;

  /// Who wrote it, usually a `PlinthUserTile`.
  final Widget? author;

  /// Date, reading time, anything else small and factual.
  final String? meta;

  final VoidCallback? onTap;
  final PlinthArticleLayout layout;

  /// Image width in [PlinthArticleLayout.horizontal].
  final double imageWidth;

  /// Image aspect ratio in [PlinthArticleLayout.stacked].
  final double imageRatio;

  final double overlayHeight;
  final double scrimOpacity;
  final int titleOrder;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final card = switch (layout) {
      PlinthArticleLayout.stacked => _stacked(context),
      PlinthArticleLayout.horizontal => _horizontal(context),
      PlinthArticleLayout.overlay => _overlay(context),
    };

    final tappable = onTap == null
        ? card
        : PlinthUnstyledButton(onPressed: onTap, child: card);

    return width == null ? tappable : SizedBox(width: width, child: tappable);
  }

  Widget _words(BuildContext context, {bool onScrim = false}) {
    final theme = context.plinth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (category case final category?) ...[
          category,
          SizedBox(height: theme.space(2)),
        ],
        PlinthTitle(title, order: titleOrder),
        if (excerpt case final excerpt?) ...[
          SizedBox(height: theme.space(2)),
          PlinthText(
            excerpt,
            size: PlinthSize.sm,
            color: onScrim ? null : 'gray',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (author != null || meta != null) ...[
          SizedBox(height: theme.space(3)),
          Row(
            children: [
              if (author case final author?) Expanded(child: author),
              if (meta case final meta?)
                PlinthText(meta, size: PlinthSize.xs, color: 'gray'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _stacked(BuildContext context) {
    final theme = context.plinth;

    return PlinthCard(
      withBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image case final image?) ...[
            ExcludeSemantics(
              child: PlinthAspectRatio(ratio: imageRatio, child: image),
            ),
            SizedBox(height: theme.space(3)),
          ],
          _words(context),
        ],
      ),
    );
  }

  Widget _horizontal(BuildContext context) {
    final theme = context.plinth;

    return PlinthPaper(
      p: PlinthSize.sm,
      withBorder: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image case final image?) ...[
            ExcludeSemantics(
              child: SizedBox(
                width: imageWidth,
                height: imageWidth,
                child: image,
              ),
            ),
            SizedBox(width: theme.space(3)),
          ],
          Expanded(child: _words(context)),
        ],
      ),
    );
  }

  Widget _overlay(BuildContext context) {
    final theme = context.plinth;

    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radius[theme.defaultRadius]!),
      // The height lives here rather than on the image: a Stack whose
      // children are all positioned has no size of its own, so an
      // overlay card with no picture would fail to lay out at all.
      child: SizedBox(
        height: overlayHeight,
        width: double.infinity,
        child: Stack(
          children: [
            if (image case final image?)
              Positioned.fill(child: ExcludeSemantics(child: image)),
            // The scrim is not decoration: a headline over a photograph is
            // legible or not depending on which photograph, and "works on
            // the one we tested" is the failure this library exists to
            // avoid.
            Positioned.fill(
              child: ColoredBox(
                color: theme.scrim.withValues(alpha: scrimOpacity),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(theme.spacing[PlinthSize.md]!),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: theme.onFilled),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: _words(context, onScrim: true),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
