import 'package:flutter/material.dart';

/// A generic dimming backdrop matching Mantine's `Overlay`: a
/// semi-opaque layer over whatever it wraps, with optional centered
/// content of your own.
///
/// Distinct from [PlinthLoadingOverlay], which is specifically a
/// loading state (always shows a spinner, always blocks pointer
/// events via `IgnorePointer`). This is the more general primitive —
/// dim a background image behind text, gray out a section without
/// necessarily blocking interaction, or build a custom loading/empty
/// state with your own content instead of the built-in spinner.
///
/// Renders via `Positioned.fill`, so — like [PlinthAffix] — it needs
/// a `Stack` ancestor; place it as a sibling of whatever it should
/// dim, not as that widget's direct child.
///
/// ```dart
/// Stack(
///   children: [
///     Image.network(url),
///     const PlinthOverlay(
///       opacity: 0.6,
///       child: Center(
///         child: Text('Featured', style: TextStyle(color: Colors.white)),
///       ),
///     ),
///   ],
/// )
/// ```
class PlinthOverlay extends StatelessWidget {
  const PlinthOverlay({
    super.key,
    this.child,
    this.color = Colors.black,
    this.opacity = 0.6,
    this.blockPointerEvents = false,
  });

  final Widget? child;
  final Color color;
  final double opacity;

  /// When true, wraps in [AbsorbPointer] so taps don't reach whatever
  /// is beneath — off by default, since dimming and blocking
  /// interaction are genuinely separate concerns (e.g. a dimmed
  /// background image behind still-interactive text).
  final bool blockPointerEvents;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      color: color.withValues(alpha: opacity),
      child: child,
    );

    return Positioned.fill(
      child: blockPointerEvents ? AbsorbPointer(child: content) : content,
    );
  }
}
