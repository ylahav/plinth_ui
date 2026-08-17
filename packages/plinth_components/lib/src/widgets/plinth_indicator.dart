import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Which corner a [PlinthIndicator]'s dot/badge is anchored to.
enum PlinthIndicatorPosition { topStart, topEnd, bottomStart, bottomEnd }

/// A small notification dot/badge anchored to a corner of [child],
/// matching Mantine's `Indicator` — e.g. an unread-count badge on a
/// notification bell icon.
///
/// ```dart
/// PlinthIndicator(
///   label: '3',
///   color: 'red',
///   child: const Icon(Icons.notifications_outlined),
/// )
///
/// // Plain dot, no label — for a simple "has updates" marker.
/// PlinthIndicator(color: 'green', child: const PlinthAvatar(initials: 'AB'))
///
/// // A presence dot on a round avatar: pulled in off the bounding
/// // box's corner, and ringed so it reads against a photo.
/// PlinthIndicator(
///   color: 'green',
///   offset: 4,
///   withBorder: true,
///   child: const PlinthAvatar(src: url),
/// )
/// ```
class PlinthIndicator extends StatelessWidget {
  const PlinthIndicator({
    super.key,
    required this.child,
    this.label,
    this.color,
    this.position = PlinthIndicatorPosition.topEnd,
    this.visible = true,
    this.radius,
    this.size = PlinthSize.md,
    this.offset,
    this.withBorder = false,
  });

  final Widget child;

  /// Text shown inside the indicator (e.g. an unread count). Omit
  /// for a plain dot.
  final String? label;

  final String? color;
  final PlinthIndicatorPosition position;

  /// How big the dot is. Defaults to [PlinthSize.md], which is the
  /// 16px this drew before the prop existed — a dot sized for an icon
  /// reads as a speck on a large avatar and as a blot on a small one.
  ///
  /// A [label] still widens the badge past this to fit its text; the
  /// size is the minimum square and the height.
  final PlinthSize size;

  /// Pulls the dot back in from its corner, in logical pixels.
  ///
  /// The default placement straddles the corner of [child]'s bounding
  /// box, which is right for a square icon and wrong for a round
  /// avatar — a circle's edge is well inside its box's corner, so an
  /// untouched dot floats off it. This is the correction, and it is
  /// measured rather than a scale step because what it has to clear is
  /// a radius, not a size.
  final double? offset;

  /// Rings the dot in the surface colour, so it stays legible on a
  /// photo or a busy child rather than merging into it.
  final bool withBorder;

  /// Whether the dot is drawn at all. False keeps [child] in the tree
  /// untouched — for a "has unread" state that toggles without
  /// restructuring anything.
  ///
  /// Named `disabled` before 0.20.0, which said the wrong thing: an
  /// indicator is not a control, and hiding it disables nothing.
  final bool visible;

  /// Squares off the fully rounded default. Omit unless it has to
  /// match squarer chrome around it.
  final PlinthSize? radius;

  static const Map<PlinthIndicatorPosition, Alignment> _alignments = {
    PlinthIndicatorPosition.topStart: Alignment.topLeft,
    PlinthIndicatorPosition.topEnd: Alignment.topRight,
    PlinthIndicatorPosition.bottomStart: Alignment.bottomLeft,
    PlinthIndicatorPosition.bottomEnd: Alignment.bottomRight,
  };

  /// Fractional translation (relative to the indicator's own size)
  /// nudging it half-outside its corner, so it overlaps [child]'s
  /// edge rather than sitting fully inside it — the conventional
  /// "badge poking out of the corner" look.
  static const Map<PlinthIndicatorPosition, Offset> _offsets = {
    PlinthIndicatorPosition.topStart: Offset(-0.3, -0.3),
    PlinthIndicatorPosition.topEnd: Offset(0.3, -0.3),
    PlinthIndicatorPosition.bottomStart: Offset(-0.3, 0.3),
    PlinthIndicatorPosition.bottomEnd: Offset(0.3, 0.3),
  };

  /// The dot's minimum square. Its own small ramp rather than the font
  /// scale: this is a mark, not text, and the label inside it is
  /// derived from the dot rather than the other way round.
  double get _dimension => switch (size) {
        PlinthSize.xs => 8,
        PlinthSize.sm => 12,
        PlinthSize.md => 16,
        PlinthSize.lg => 20,
        PlinthSize.xl => 24,
      };

  @override
  Widget build(BuildContext context) {
    if (!visible) return child;

    final theme = context.plinth;
    final colorKey = color ?? 'red';
    final fillColor = theme.shaded(colorKey, 6);
    final hasLabel = label != null && label!.isNotEmpty;
    final dimension = _dimension;
    const borderWidth = 2.0;

    final indicator = Container(
      // No `alignment`, and that is the fix rather than a style
      // choice: a Container with one expands to whatever bounded
      // constraints it is handed, and the corner this sits in hands it
      // the child's full size. The dot was drawn the size of the thing
      // it annotates — a disc over the bell rather than a mark on it.
      // The label is centred by `textAlign` instead, which centres
      // text without resizing the box around it.
      width: hasLabel ? null : dimension,
      height: dimension,
      padding:
          hasLabel ? EdgeInsets.symmetric(horizontal: dimension * 0.25) : null,
      constraints: hasLabel ? BoxConstraints(minWidth: dimension) : null,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(
            radius == null ? 999 : theme.radius[radius!]!),
        // The surface rather than a palette colour: the ring exists to
        // separate the dot from whatever is behind it, which is the
        // page, so it reads as a gap rather than as an outline.
        border: withBorder
            ? Border.all(color: theme.surface, width: borderWidth)
            : null,
      ),
      child: hasLabel
          ? Text(
              label!,
              textAlign: TextAlign.center,
              style: TextStyle(
                // Sits on the coloured dot, so it follows onFilled
                // rather than the surface behind the badge.
                color: theme.contrastingOn(fillColor),
                fontSize: dimension * 0.625,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );

    // The fractional nudge scales with the dot, which is what keeps
    // the default look identical at every size; `offset` then pulls it
    // back along both axes in real pixels.
    final fraction = _offsets[position]!;
    final inset = offset ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: _alignments[position]!,
            child: FractionalTranslation(
              translation: fraction,
              child: Transform.translate(
                // Toward the centre on each axis, whichever corner
                // this is: the sign of the corner's own nudge says
                // which way "out" was.
                offset: Offset(
                  -fraction.dx.sign * inset,
                  -fraction.dy.sign * inset,
                ),
                child: indicator,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
