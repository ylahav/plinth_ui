import 'package:flutter/widgets.dart';

import 'package:plinth_hooks/plinth_hooks.dart';

/// Shared plumbing behind [PlinthModalHost] and [PlinthDrawerHost] (and
/// any future overlay — Popover, BottomSheet, etc.): listens to a
/// [PlinthDisclosureController] and invokes [onOpen] whenever it opens,
/// so a controller-driven overlay never needs its own bespoke
/// listener/dispose boilerplate.
///
/// Not exported from `plinth_components.dart` — overlay-specific hosts
/// like [PlinthModalHost] wrap this rather than users reaching for it
/// directly, since `onOpen`'s signature (just `BuildContext`) doesn't
/// carry enough type info to be a good public API on its own.
class PlinthOverlayHost extends StatefulWidget {
  const PlinthOverlayHost({
    super.key,
    required this.controller,
    required this.onOpen,
    required this.child,
  });

  final PlinthDisclosureController controller;

  /// Called with the host's [BuildContext] whenever [controller] opens.
  /// Typically `(context) => myOverlay.show(context)`.
  final Future<void> Function(BuildContext context) onOpen;

  final Widget child;

  @override
  State<PlinthOverlayHost> createState() => _PlinthOverlayHostState();
}

class _PlinthOverlayHostState extends State<PlinthOverlayHost> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PlinthOverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (widget.controller.isOpen) {
      widget.onOpen(context);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
