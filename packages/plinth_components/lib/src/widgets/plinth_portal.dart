import 'package:flutter/material.dart';

/// Renders [child] into the ambient `Overlay` rather than in its
/// normal place in the tree, matching Mantine's `Portal`.
///
/// The building block underneath every overlay component in this
/// library (`PlinthModal`, `PlinthDrawer`, `PlinthPopover`, ...) —
/// exposed directly for cases outside those: a custom floating panel
/// that needs to escape a parent's `ClipRect`, an `Overflow: hidden`
/// container, or a scrolling ancestor that would otherwise clip it.
///
/// Unlike those components, this has no show/hide state of its own
/// — mount it conditionally (e.g. inside an `if` in a `children:`
/// list, or via a boolean controlling whether it's built at all) to
/// control when its content appears.
///
/// ```dart
/// if (_showBanner) PlinthPortal(child: MyFloatingBanner()),
/// ```
class PlinthPortal extends StatefulWidget {
  const PlinthPortal({super.key, required this.child});

  final Widget child;

  @override
  State<PlinthPortal> createState() => _PlinthPortalState();
}

class _PlinthPortalState extends State<PlinthPortal> {
  OverlayEntry? _entry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Insert once, on the first call after mounting (this is the
    // earliest point Overlay.of(context) is safely available — not
    // yet in initState). Every subsequent didChangeDependencies call
    // (e.g. from a theme or MediaQuery change) just needs a rebuild
    // of the SAME entry, not a fresh remove-and-reinsert — that
    // would needlessly tear down and recreate the overlay slot on
    // every ambient rebuild, not just when widget.child itself
    // changes.
    if (_entry == null) {
      _entry = OverlayEntry(builder: (context) => widget.child);
      Overlay.of(context).insert(_entry!);
    } else {
      _entry!.markNeedsBuild();
    }
  }

  @override
  void didUpdateWidget(covariant PlinthPortal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
