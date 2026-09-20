import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A two-pane authentication layout: brand on one side, form on the
/// other.
///
/// The pane arrangement is all this does. The form is whatever you put
/// in [child] — usually a [PlinthSignInBlock] with `width: null` so it
/// fills its half.
///
/// ```dart
/// PlinthSplitAuthBlock(
///   decoration: const PlinthBackgroundImage(
///     src: 'https://example.com/hero.jpg',
///     height: double.infinity,
///     child: PlinthTitle('Build faster', order: 3),
///   ),
///   child: PlinthSignInBlock(width: null, onSubmit: signIn),
/// )
/// ```
///
/// **The decoration pane drops below [breakpoint]** rather than
/// squeezing both halves into a phone. The original of this block was a
/// fixed 620x300, which is a layout that only exists on a desktop; the
/// pane that survives is the one with the form in it.
///
/// **The decoration is decoration.** It is first in the tree so it
/// paints on the leading side, and it should carry no focusable
/// content — a screen reader user should reach the form without wading
/// through a marketing pane. Nothing here can enforce that about a
/// widget you pass in, so it is worth saying: put links in the form
/// half.
class PlinthSplitAuthBlock extends StatelessWidget {
  const PlinthSplitAuthBlock({
    super.key,
    required this.child,
    this.decoration,
    this.decorationFlex = 1,
    this.contentFlex = 1,
    this.decorationOnRight = false,
    this.breakpoint = 560,
    this.width,
    this.height = 300,
    this.padding = const EdgeInsets.all(20),
  });

  /// The form half.
  final Widget child;

  /// The brand half. Null renders [child] alone, which is also what
  /// happens below [breakpoint].
  final Widget? decoration;

  /// Flex of the decoration pane against [contentFlex].
  final int decorationFlex;

  /// Flex of the form pane.
  final int contentFlex;

  /// Puts the decoration after the form instead of before it.
  final bool decorationOnRight;

  /// Width below which the decoration pane is dropped entirely.
  final double breakpoint;

  final double? width;

  /// Height of the pair. Null lets it size to the form, which is what a
  /// full-page route wants.
  final double? height;

  /// Padding around [child] inside its pane.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // Scrollable because [height] fixes the pane and the form in it is
    // whatever the caller passed. A sign-in card with a subtitle and an
    // SSO button is taller than a plain one, and the pane that clips it
    // hides the submit button — so the overflow is absorbed here rather
    // than left for each caller to discover at some viewport size.
    final content = SingleChildScrollView(
      child: Padding(padding: padding, child: child),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // `maxWidth` can be unbounded in a scrolling row; treat that as
        // "plenty of room" rather than as narrower than any breakpoint.
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (width ?? double.infinity);
        final narrow = available < breakpoint;

        if (decoration == null || narrow) {
          return SizedBox(width: width, child: content);
        }

        final panes = <Widget>[
          Expanded(flex: decorationFlex, child: decoration!),
          Expanded(flex: contentFlex, child: content),
        ];

        return SizedBox(
          width: width,
          height: height,
          child: PlinthPaper(
            p: PlinthSize.xs,
            withBorder: true,
            child: Row(
              children: decorationOnRight ? panes.reversed.toList() : panes,
            ),
          ),
        );
      },
    );
  }
}
