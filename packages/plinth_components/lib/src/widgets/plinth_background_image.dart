import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// An image behind arbitrary content, matching Mantine's
/// `BackgroundImage`.
///
/// A `Container` with a `DecorationImage` is most of this already. What
/// it adds is the part people forget: text over a photograph is
/// unreadable against the light parts of it, so this can lay a scrim
/// between the two.
///
/// ```dart
/// PlinthBackgroundImage(
///   src: 'https://example.com/hero.jpg',
///   height: 200,
///   child: const PlinthTitle('Ships tomorrow'),
/// )
/// ```
class PlinthBackgroundImage extends StatelessWidget {
  const PlinthBackgroundImage({
    super.key,
    required this.src,
    this.child,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
    this.scrimOpacity = 0.35,
    this.alignment = Alignment.center,
  });

  final String src;
  final Widget? child;

  final double? width;
  final double? height;
  final BoxFit fit;
  final PlinthSize? radius;

  /// Darkens the image behind [child]. Set to 0 for no scrim — worth
  /// doing only when the image is known to be dark, or nothing sits on
  /// top of it.
  final double scrimOpacity;

  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius =
        radius != null ? theme.radius[radius]! : theme.radius[PlinthSize.sm]!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(resolvedRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Image.network(
              src,
              width: width,
              height: height,
              fit: fit,
              // A failed background must not take the content with it:
              // fall back to a muted fill and keep rendering [child].
              errorBuilder: (context, _, __) =>
                  ColoredBox(color: theme.surfaceMuted),
            ),
            if (scrimOpacity > 0)
              Positioned.fill(
                child: ColoredBox(
                  color: theme.scrim.withValues(alpha: scrimOpacity),
                ),
              ),
            if (child != null)
              Positioned.fill(
                child: Align(
                  alignment: alignment,
                  child: DefaultTextStyle.merge(
                    // Content sits on a darkened photograph, so it
                    // takes the on-fill foreground rather than the
                    // theme's body text colour.
                    style: TextStyle(color: theme.onFilled),
                    child: IconTheme.merge(
                      data: IconThemeData(color: theme.onFilled),
                      child: child!,
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
