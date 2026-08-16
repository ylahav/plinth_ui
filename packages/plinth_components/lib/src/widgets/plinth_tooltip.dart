import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Which side of its target a [PlinthTooltip] prefers.
///
/// Two values rather than the four [PlinthPopoverPosition] offers, and
/// deliberately so — see [PlinthTooltip] for why a tooltip can't be
/// placed left or right here.
enum PlinthTooltipPosition { top, bottom }

/// A themed tooltip matching Mantine's `Tooltip`: dark background,
/// theme-driven radius and font size, shown on hover (desktop/web) or
/// long-press (touch).
///
/// This wraps Flutter's built-in [Tooltip] rather than reimplementing
/// hover/long-press detection and positioning from scratch — those
/// are exactly the parts of a tooltip that are easy to get subtly
/// wrong (a11y, edge-of-screen flipping, focus interaction), and
/// Flutter's implementation already handles them well. Plinth only
/// adds theme-consistent styling on top.
///
/// **[position] is above or below, not left or right.** That is the
/// price of the wrapper: Flutter's tooltip decides its own horizontal
/// placement and exposes only a vertical preference. Offering `left`
/// and `right` would mean re-deriving hover, long-press, focus and
/// dismissal on our own overlay — the work this component exists to
/// avoid — and the case it would serve is largely handled already,
/// since Flutter flips the tooltip to the other side when the
/// preferred one doesn't fit on screen.
///
/// ```dart
/// PlinthTooltip(
///   message: 'Delete this item',
///   child: PlinthButton(onPressed: () {}, child: const Icon(Icons.delete)),
/// )
/// ```
class PlinthTooltip extends StatelessWidget {
  const PlinthTooltip({
    super.key,
    required this.message,
    required this.child,
    this.size = PlinthSize.sm,
    this.radius,
    this.position = PlinthTooltipPosition.top,
    this.offset = 24,
    this.openDelay = const Duration(milliseconds: 400),
    this.color,
  });

  final String message;
  final Widget child;
  final PlinthSize size;
  final PlinthSize? radius;

  /// The side to prefer. Flutter still flips it when the preferred
  /// side doesn't fit on screen, which is the behaviour worth keeping.
  final PlinthTooltipPosition position;

  /// Distance from the target, in logical pixels.
  final double offset;

  /// How long a pointer must rest on the target first. Was fixed at
  /// 400ms before 0.19.0 — a toolbar of icons wants it shorter, a
  /// tooltip repeating a visible label wants it longer.
  final Duration openDelay;

  /// Palette key for the tooltip's own fill, for the times a tooltip
  /// carries a warning rather than a description. Omit for the
  /// inverted surface, which is what a tooltip should normally be.
  final String? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius = theme.radius[radius ?? PlinthSize.xs]!;

    // A tooltip is deliberately *inverted* against the surface it
    // floats over — dark on a light theme — so it reads as an overlay
    // rather than as more page. Following the surface token instead
    // would make it disappear into the background in dark mode, which
    // is the one place the brightness has to be consulted directly.
    final inverted = theme.brightness == Brightness.light;

    // A coloured tooltip is a filled surface like any other, so its
    // text resolves against that fill rather than against the theme.
    final fill = color != null
        ? theme.shaded(color!, 6)
        : inverted
            ? kDarkSurface
            : theme.surfaceMuted;
    final text = color != null
        ? theme.contrastingOn(fill)
        : inverted
            ? theme.onFilled
            : theme.text;

    return Tooltip(
      message: message,
      textStyle: TextStyle(color: text, fontSize: theme.fontSizes[size]),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(resolvedRadius),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing[PlinthSize.sm]!,
        vertical: theme.spacing[PlinthSize.xs]! * 0.6,
      ),
      preferBelow: position == PlinthTooltipPosition.bottom,
      verticalOffset: offset,
      waitDuration: openDelay,
      child: child,
    );
  }
}
