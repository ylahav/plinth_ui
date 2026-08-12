import 'package:flutter/material.dart';

/// An animated height reveal, matching Mantine's `Collapse`.
///
/// [PlinthAccordion] and [PlinthSpoiler] both animate a height change
/// internally; this is that mechanism on its own, for the cases those
/// don't cover — a filter panel above a table, an "advanced options"
/// section in a form, a validation summary that appears on submit.
///
/// [child] stays mounted while collapsed rather than being swapped for
/// an empty box, so anything stateful inside it — a half-filled form,
/// a scroll position — survives being hidden and shown.
///
/// That mounting is the trade-off to weigh before reaching for this.
/// A clipped child is still *in the tree*: without care it stays
/// focusable and readable by a screen reader while invisible, which is
/// worse than not animating at all. This excludes it from semantics and
/// hit-testing once fully closed, but the child is still built and laid
/// out — so for a long list of panels, or content that should genuinely
/// go away, swapping it out is the better shape. [PlinthAccordion]
/// deliberately does that instead.
///
/// ```dart
/// PlinthCollapse(
///   opened: _showFilters,
///   child: const FilterPanel(),
/// )
/// ```
class PlinthCollapse extends StatelessWidget {
  const PlinthCollapse({
    super.key,
    required this.opened,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
  });

  /// Controlled by the caller, like every other disclosure in this
  /// library — pair it with your own bool or a
  /// `PlinthDisclosureController`.
  final bool opened;

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: opened ? 1 : 0, end: opened ? 1 : 0),
      duration: duration,
      curve: curve,
      // The child is built once and passed through, so collapsing
      // doesn't rebuild it on every frame of the animation.
      child: child,
      builder: (context, factor, child) {
        final closed = factor == 0;

        return ExcludeSemantics(
          // Clipping hides a child from sight, not from assistive
          // technology — a collapsed panel would otherwise still be
          // announced, and its buttons still reachable.
          excluding: closed,
          child: IgnorePointer(
            ignoring: closed,
            child: ClipRect(
              // Align with a heightFactor rather than a
              // height-constrained box: it lays the child out at its
              // natural height and clips what doesn't fit, where
              // constraining would make any Column inside report an
              // overflow while it animates. Same trap PlinthSpoiler hit.
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: factor,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
