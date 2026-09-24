/// A photograph across the top of a page, with a way back out of it.
///
/// The detail-page header: an image edge to edge, a dismiss control
/// floating over it, and optionally a title reading over a scrim. Every
/// app with a detail screen builds one, and this library had the parts
/// without the arrangement — `PlinthBackgroundImage` does photo and
/// scrim, `PlinthHeroBlock` does a marketing hero over a photograph,
/// and neither is a page header with a close button.
///
/// Reported by somebody building a real screen, who assembled it from
/// their own photo widget and a `PlinthActionIcon`.
library;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// Where the title sits over the photograph.
enum PlinthPhotoHeaderAlign { bottomStart, bottomCentre, none }

class PlinthPhotoHeader extends StatelessWidget {
  const PlinthPhotoHeader({
    super.key,
    required this.image,
    this.imageLabel,
    this.height = 260,
    this.title,
    this.subtitle,
    this.onClose,
    this.closeLabel,
    this.actions = const [],
    this.align = PlinthPhotoHeaderAlign.bottomStart,
    this.scrimOpacity = 0.45,
    this.titleOrder = 2,
  });

  /// The photograph, as a widget rather than a URL.
  ///
  /// `PlinthBackgroundImage` takes a `String` and calls `Image.network`,
  /// which is right for it and wrong here: a detail page's photo is as
  /// often an asset, a file, a cached network image or an app's own
  /// widget. Taking a widget costs the caller `Image.asset(...)` and
  /// buys them every image source Flutter has.
  final Widget image;

  /// What a screen reader is told the photograph *is*.
  ///
  /// Null marks it decorative and hides it, which is the honest
  /// default: most detail-page photos repeat what the title already
  /// says, and "image" announced over and over is noise. Pass this only
  /// when the photograph carries information the page does not.
  final String? imageLabel;

  final double height;
  final String? title;
  final String? subtitle;

  /// Null renders no close button — for a header inside a page that is
  /// not dismissible.
  final VoidCallback? onClose;

  /// What the close button is called.
  ///
  /// Falls back to the theme's `closeDialog` string, so it translates
  /// through `PlinthLocalizations` without the caller doing anything.
  /// Worth overriding where the surrounding context makes "close"
  /// ambiguous — "Back to scenes" says more than "Close".
  final String? closeLabel;

  /// Extra controls beside the close button — share, edit, overflow.
  final List<Widget> actions;

  final PlinthPhotoHeaderAlign align;

  /// How much the photograph is darkened.
  ///
  /// **This is not decoration.** Contrast arithmetic cannot evaluate a
  /// photograph — `readableOn` needs a colour, and a photo is millions
  /// of them, including some that are nearly white. The scrim is what
  /// makes a fixed light foreground safe over an unknown image, which
  /// is why it defaults to a value that darkens rather than tints.
  final double scrimOpacity;

  final int titleOrder;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    // Over a scrimmed photograph, not over a theme surface — so the
    // foreground is the one colour that stays readable regardless of
    // what the photograph does, rather than a token resolved against a
    // background this widget cannot see.
    final foreground = theme.onFilled;

    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Decorative unless the caller says otherwise.
              imageLabel == null
                  ? ExcludeSemantics(child: image)
                  : Semantics(label: imageLabel, image: true, child: image),
              if (scrimOpacity > 0)
                ColoredBox(
                  color: theme.scrim.withValues(alpha: scrimOpacity),
                ),
            ],
          ),
        ),
        if (title != null && align != PlinthPhotoHeaderAlign.none)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.all(theme.space(5)),
              // `PlinthTitle` with a null `color` inherits the ambient
              // `DefaultTextStyle`, which is documented behaviour and
              // the right hook here: its `color` is a *palette key*
              // resolved against `theme.surface`, and this text is not
              // on a surface. Passing the colour down this way keeps
              // the heading semantics a plain `Text` would lose.
              child: DefaultTextStyle.merge(
                style: TextStyle(color: foreground),
                child: Column(
                  crossAxisAlignment:
                      align == PlinthPhotoHeaderAlign.bottomCentre
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlinthTitle(title!, order: titleOrder),
                    if (subtitle != null) ...[
                      SizedBox(height: theme.space(1)),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: theme.fontSizes[PlinthSize.sm],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

        // The controls take the safe area; the photograph does not.
        // Edge to edge is the point of the photograph, and a close
        // button under a notch is the point of nothing.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.all(theme.space(2)),
              child: Row(
                children: [
                  if (onClose != null)
                    _OverPhoto(
                      child: PlinthActionIcon(
                        icon: const Icon(Icons.close),
                        semanticLabel:
                            closeLabel ?? context.plinthStrings.closeDialog,
                        onPressed: onClose,
                      ),
                    ),
                  const Spacer(),
                  for (final action in actions) ...[
                    _OverPhoto(child: action),
                    SizedBox(width: theme.space(2)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Backs a control so it stays visible over any photograph.
///
/// A bare icon over a photo is legible until the photo has a bright
/// patch exactly where the icon is, and then it is gone. The scrim
/// helps the title, which sits over a large area; a small control needs
/// its own backing. WCAG 1.4.11 asks 3:1 of a control's boundary, and
/// against an unknown image the only way to guarantee that is to supply
/// the background yourself.
class _OverPhoto extends StatelessWidget {
  const _OverPhoto({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scrim.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
