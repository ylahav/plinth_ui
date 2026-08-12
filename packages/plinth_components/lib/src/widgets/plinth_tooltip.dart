import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

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
  });

  final String message;
  final Widget child;
  final PlinthSize size;
  final PlinthSize? radius;

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

    return Tooltip(
      message: message,
      textStyle: TextStyle(
        color: inverted ? theme.onFilled : theme.text,
        fontSize: theme.fontSizes[size],
      ),
      decoration: BoxDecoration(
        color: inverted ? kDarkSurface : theme.surfaceMuted,
        borderRadius: BorderRadius.circular(resolvedRadius),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing[PlinthSize.sm]!,
        vertical: theme.spacing[PlinthSize.xs]! * 0.6,
      ),
      waitDuration: const Duration(milliseconds: 400),
      child: child,
    );
  }
}
