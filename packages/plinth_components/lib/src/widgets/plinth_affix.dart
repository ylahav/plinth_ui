import 'package:flutter/material.dart';

/// A fixed-position overlay matching Mantine's `Affix`, e.g. a
/// "scroll to top" button that stays anchored to a screen corner
/// regardless of scroll position.
///
/// Wrap your page content in a `Stack` with this as a sibling — unlike
/// [PlinthPopover]/[PlinthModal], this doesn't manage its own overlay
/// insertion, since it's meant to be a simple positioned child within
/// a screen's existing widget tree rather than floating above it.
///
/// ```dart
/// Stack(
///   children: [
///     MyScrollableContent(),
///     PlinthAffix(
///       bottom: 20,
///       right: 20,
///       child: PlinthActionIcon(
///         icon: const Icon(Icons.arrow_upward),
///         variant: PlinthVariant.filled,
///         circle: true,
///         onPressed: _scrollToTop,
///       ),
///     ),
///   ],
/// )
/// ```
class PlinthAffix extends StatelessWidget {
  const PlinthAffix({
    super.key,
    required this.child,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  final Widget child;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: child,
    );
  }
}
