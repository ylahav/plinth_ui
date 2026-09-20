import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// How a [PlinthHeroBlock] arranges itself.
enum PlinthHeroLayout {
  /// Everything centred in a column. The default, and the right one
  /// when there is nothing to show beside the words.
  centered,

  /// Words on one side, [PlinthHeroBlock.aside] on the other. Falls
  /// back to a stacked column when there is not room for two.
  split,
}

/// The top of a landing page: a claim, a sentence, and something to do.
///
/// One widget for the hero arrangements, which vary in what surrounds
/// the words rather than in what the words are for.
///
/// ```dart
/// PlinthHeroBlock(
///   eyebrow: const PlinthBadge('New', color: 'grape'),
///   headline: 'Build interfaces faster',
///   subhead: 'A themeable Flutter component library for teams that ship.',
///   actions: [
///     PlinthButton(onPressed: start, child: const Text('Get started')),
///   ],
/// )
/// ```
///
/// **[headline] is a [PlinthTitle], not big text.** A landing page's
/// claim is the page's heading, and rendering it as a large `Text`
/// leaves a document whose outline starts somewhere further down —
/// which is what a screen reader navigates by. [headlineOrder] moves it
/// when a hero is not the top of its page.
///
/// **[backgroundImage] carries a scrim by default.** A headline over a
/// photograph is legible or not depending on which photograph, and
/// "works on the one we tested" is the failure mode this library exists
/// to avoid.
class PlinthHeroBlock extends StatelessWidget {
  const PlinthHeroBlock({
    super.key,
    required this.headline,
    this.subhead,
    this.eyebrow,
    this.actions = const [],
    this.aside,
    this.footer,
    this.layout = PlinthHeroLayout.centered,
    this.asideOnLeft = false,
    this.backgroundImage,
    this.scrimOpacity = 0.5,
    this.backgroundHeight = 240,
    this.headlineOrder = 2,
    this.minSplitWidth = 520,
    this.width,
    this.padding = const EdgeInsets.all(32),
  });

  /// The claim. Rendered as a heading, not as large text.
  final String headline;

  /// The sentence under it.
  final String? subhead;

  /// Above the headline — usually a [PlinthBadge].
  final Widget? eyebrow;

  /// What to do about it. A hero with no action is a poster.
  final List<Widget> actions;

  /// The thing beside the words in [PlinthHeroLayout.split] — a
  /// screenshot, an illustration.
  ///
  /// It goes *under* the words rather than beside them whenever there
  /// is no room for two columns, and in the centred layout. Never
  /// dropped: a widget that vanishes because a layout flag disagrees
  /// with it is an hour somebody spends looking for it.
  final Widget? aside;

  /// Under everything: a proof strip, a signup row, a note about the
  /// free tier.
  final Widget? footer;

  final PlinthHeroLayout layout;

  /// Puts [aside] before the words instead of after.
  final bool asideOnLeft;

  /// A photograph behind the whole hero. The words sit on it, centred,
  /// over a scrim.
  final String? backgroundImage;

  /// How strongly to darken [backgroundImage]. Lower this only after
  /// checking the headline against the lightest part of the image.
  final double scrimOpacity;

  final double backgroundHeight;

  /// Heading level for [headline], passed to [PlinthTitle.order].
  final int headlineOrder;

  /// Width below which [PlinthHeroLayout.split] stacks instead.
  ///
  /// A split hero squeezed onto a phone gives both halves a column too
  /// narrow to read; stacking gives the words the full width and puts
  /// the picture under them.
  final double minSplitWidth;

  final double? width;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (backgroundImage case final src?) {
      final hero = PlinthBackgroundImage(
        src: src,
        height: backgroundHeight,
        scrimOpacity: scrimOpacity,
        child: Padding(
          padding: padding,
          child: _words(context, CrossAxisAlignment.center, TextAlign.center),
        ),
      );
      return width == null ? hero : SizedBox(width: width, child: hero);
    }

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (width ?? double.infinity);
        final canSplit = layout == PlinthHeroLayout.split &&
            aside != null &&
            available >= minSplitWidth;

        if (!canSplit) {
          final stacked = _words(
            context,
            layout == PlinthHeroLayout.split
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            layout == PlinthHeroLayout.split
                ? TextAlign.start
                : TextAlign.center,
          );

          // The picture still belongs on the page when the two halves
          // stop fitting side by side — it moves under the words
          // rather than being dropped.
          if (aside == null) return stacked;
          return PlinthStack(
            gap: PlinthSize.md,
            children: [stacked, aside!],
          );
        }

        final panes = <Widget>[
          Expanded(
            child: _words(context, CrossAxisAlignment.start, TextAlign.start),
          ),
          const SizedBox(width: 24),
          Expanded(child: aside!),
        ];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: asideOnLeft ? panes.reversed.toList() : panes,
        );
      },
    );

    return width == null ? body : SizedBox(width: width, child: body);
  }

  Widget _words(
    BuildContext context,
    CrossAxisAlignment cross,
    TextAlign align,
  ) {
    final theme = context.plinth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: cross,
      children: [
        if (eyebrow case final eyebrow?) ...[
          eyebrow,
          SizedBox(height: theme.space(3)),
        ],
        PlinthTitle(headline, order: headlineOrder, textAlign: align),
        if (subhead case final subhead?) ...[
          SizedBox(height: theme.space(2)),
          PlinthText(
            subhead,
            size: PlinthSize.sm,
            color: 'gray',
            textAlign: align,
          ),
        ],
        if (actions.isNotEmpty) ...[
          SizedBox(height: theme.space(4)),
          PlinthGroup(
            gap: PlinthSize.sm,
            mainAxisAlignment: align == TextAlign.center
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: actions,
          ),
        ],
        if (footer case final footer?) ...[
          SizedBox(height: theme.space(5)),
          footer,
        ],
      ],
    );
  }
}
