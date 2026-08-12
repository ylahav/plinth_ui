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
  void initState() {
    super.initState();
    // Overlay.of(context).insert() calls setState() on the ancestor
    // Overlay internally — calling it synchronously here (or in
    // didChangeDependencies) happens while this widget's own first
    // build is still in progress, which means the ancestor Overlay
    // is *also* still mid-build, and Flutter forbids setState()
    // during a build. Deferring to a post-frame callback runs it
    // once the current frame's build phase has fully finished, which
    // is the standard fix for "insert something into the Overlay as
    // soon as a widget mounts."
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entry = OverlayEntry(builder: (context) => widget.child);
      Overlay.of(context).insert(_entry!);
    });
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
