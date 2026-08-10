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
/// ```
class PlinthIndicator extends StatelessWidget {
  const PlinthIndicator({
    super.key,
    required this.child,
    this.label,
    this.color,
    this.position = PlinthIndicatorPosition.topEnd,
    this.disabled = false,
  });

  final Widget child;

  /// Text shown inside the indicator (e.g. an unread count). Omit
  /// for a plain dot.
  final String? label;

  final String? color;
  final PlinthIndicatorPosition position;

  /// Hides the indicator entirely when true, without removing
  /// [child] from the tree — useful for a "has unread" state that
  /// toggles on/off without restructuring your widget tree.
  final bool disabled;

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

  @override
  Widget build(BuildContext context) {
    if (disabled) return child;

    final theme = context.plinth;
    final colorKey = color ?? 'red';
    final fillColor = theme.color(colorKey, 6);
    final hasLabel = label != null && label!.isNotEmpty;

    final indicator = Container(
      padding: hasLabel ? const EdgeInsets.symmetric(horizontal: 4) : EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(999)),
      child: hasLabel
          ? Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: _alignments[position]!,
            child: FractionalTranslation(
              translation: _offsets[position]!,
              child: indicator,
            ),
          ),
        ),
      ],
    );
  }
}
