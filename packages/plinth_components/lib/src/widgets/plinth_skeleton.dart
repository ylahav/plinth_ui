import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A loading placeholder matching Mantine's `Skeleton`: a gray block
/// that pulses gently to signal "content is loading here."
///
/// Deliberately a simple opacity pulse (self-triggering
/// [TweenAnimationBuilder], see below) rather than a moving shimmer
/// gradient — a shimmer needs a repeating `AnimationController` with
/// explicit lifecycle management (start/stop/dispose), which is more
/// machinery than a loading placeholder needs to earn; the pulse
/// communicates the same "this is a placeholder" signal with far less
/// code to get wrong.
///
/// ```dart
/// PlinthSkeleton(height: 16, width: 200)   // a line of text
/// PlinthSkeleton(height: 40, width: 40, circle: true)  // an avatar
/// ```
class PlinthSkeleton extends StatefulWidget {
  const PlinthSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius,
    this.circle = false,
  });

  /// Omit for a skeleton that fills its parent's width.
  final double? width;
  final double height;

  /// Ignored when [circle] is true.
  final PlinthSize? radius;

  /// Renders as a circle instead of a rounded rectangle — for avatar
  /// placeholders. When true, [width] and [height] should match.
  final bool circle;

  @override
  State<PlinthSkeleton> createState() => _PlinthSkeletonState();
}

class _PlinthSkeletonState extends State<PlinthSkeleton> {
  bool _dim = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius = widget.circle
        ? 999.0
        : theme.radius[widget.radius ?? PlinthSize.sm]!;

    // A self-triggering TweenAnimationBuilder: each time the target
    // opacity is reached, onEnd flips `_dim` and the widget rebuilds
    // with the opposite target, producing a continuous pulse without
    // needing an AnimationController's start/stop/dispose lifecycle.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _dim ? 1.0 : 0.4, end: _dim ? 0.4 : 1.0),
      duration: const Duration(milliseconds: 800),
      onEnd: () => setState(() => _dim = !_dim),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECEF),
              borderRadius: widget.circle ? null : BorderRadius.circular(resolvedRadius),
              shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            ),
          ),
        );
      },
    );
  }
}
