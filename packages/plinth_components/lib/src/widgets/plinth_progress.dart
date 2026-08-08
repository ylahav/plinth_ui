import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A themeable linear progress bar matching Mantine's `Progress`: a
/// track filled proportionally to [value], animated on change.
///
/// ```dart
/// PlinthProgress(value: 0.6, color: 'green')
/// ```
class PlinthProgress extends StatelessWidget {
  const PlinthProgress({
    super.key,
    required this.value,
    this.color,
    this.size = PlinthSize.md,
    this.radius,
    this.trackColor,
  }) : assert(value >= 0 && value <= 1, 'value must be between 0 and 1');

  /// Fraction filled, from 0.0 to 1.0.
  final double value;
  final String? color;
  final PlinthSize size;
  final PlinthSize? radius;

  /// Background track color. Defaults to a light gray.
  final Color? trackColor;

  static const Map<PlinthSize, double> _heights = {
    PlinthSize.xs: 4,
    PlinthSize.sm: 6,
    PlinthSize.md: 10,
    PlinthSize.lg: 14,
    PlinthSize.xl: 20,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final fillColor = theme.color(colorKey, 6);
    final height = _heights[size]!;
    final resolvedRadius = theme.radius[radius ?? PlinthSize.xl]!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(resolvedRadius),
      child: Container(
        height: height,
        color: trackColor ?? const Color(0xFFE9ECEF),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            widthFactor: value,
            child: DecoratedBox(
              decoration: BoxDecoration(color: fillColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// [FractionallySizedBox] doesn't animate its factor changes on its
/// own — this wraps it in a [TweenAnimationBuilder] so the fill
/// smoothly grows/shrinks when [widthFactor] changes, rather than
/// snapping instantly.
class AnimatedFractionallySizedBox extends StatelessWidget {
  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required this.duration,
    this.curve = Curves.linear,
  });

  final double widthFactor;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: widthFactor, end: widthFactor),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: child,
    );
  }
}
