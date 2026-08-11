import 'package:flutter/material.dart';

/// Renders [child] so screen readers announce it while sighted users
/// never see it, matching Mantine's `VisuallyHidden`.
///
/// The common case is supplementary context for an icon-only control
/// — e.g. an icon button whose visual meaning is obvious to sighted
/// users but needs a text label for accessibility:
///
/// ```dart
/// PlinthActionIcon(
///   icon: Row(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       const Icon(Icons.close),
///       PlinthVisuallyHidden(child: Text('Close dialog')),
///     ],
///   ),
///   onPressed: _close,
/// )
/// ```
///
/// Uses the standard "clip to a near-zero size" technique rather than
/// `Opacity` or `Visibility.invisible` — those keep the content fully
/// in the layout and paintable (just transparent or skipped), which
/// some screen readers still treat as hidden from *them* too. `child`
/// stays in the semantics tree (Flutter includes it by default —
/// nothing extra needed for that); only its painted/laid-out size
/// collapses.
class PlinthVisuallyHidden extends StatelessWidget {
  const PlinthVisuallyHidden({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topLeft,
        widthFactor: 0.001,
        heightFactor: 0.001,
        child: child,
      ),
    );
  }
}
