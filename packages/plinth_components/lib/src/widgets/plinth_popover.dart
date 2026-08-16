import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

/// Which side of the target [PlinthPopover]'s content appears on.
enum PlinthPopoverPosition { top, bottom, left, right }

/// An anchored floating panel matching Mantine's `Popover`: [content]
/// appears positioned relative to [target] when [controller] opens,
/// dismissible by tapping outside.
///
/// Unlike [PlinthModal]/[PlinthDrawer], this doesn't use a dialog
/// route — a popover needs to track its target's on-screen position
/// (including if the page scrolls), so it's built on
/// [CompositedTransformTarget]/[CompositedTransformFollower] plus a
/// manually managed [OverlayEntry] instead.
///
/// ```dart
/// final _popover = PlinthDisclosureController();
///
/// PlinthPopover(
///   controller: _popover,
///   target: PlinthButton(onPressed: _popover.toggle, child: const Text('Info')),
///   content: const Text('Extra details shown in a floating panel.'),
/// )
/// ```
class PlinthPopover extends StatefulWidget {
  const PlinthPopover({
    super.key,
    required this.controller,
    required this.target,
    required this.content,
    this.position = PlinthPopoverPosition.bottom,
    this.width,
    this.radius,
    this.closeOnOutsideTap = true,
  });

  final PlinthDisclosureController controller;

  /// The widget the popover is anchored to. Tapping it toggles
  /// [controller] — wrap your own `GestureDetector` around [target]
  /// instead if you need a different trigger interaction (e.g. hover).
  final Widget target;

  final Widget content;
  final PlinthPopoverPosition position;

  /// Fixed content width. Omit to size to content.
  final double? width;

  /// Overrides the theme's default radius for this one instance.
  final PlinthSize? radius;

  final bool closeOnOutsideTap;

  @override
  State<PlinthPopover> createState() => _PlinthPopoverState();
}

class _PlinthPopoverState extends State<PlinthPopover> {
  final _layerLink = LayerLink();
  OverlayEntry? _entry;

  static const double _gap = 8;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PlinthPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    // The panel lives in an OverlayEntry, which doesn't rebuild just
    // because this widget did. Without this an open popover is frozen
    // at whatever it was built with — a tree that expands inside one
    // would never redraw.
    //
    // Deferred because didUpdateWidget runs *during* the build phase,
    // and marking an overlay entry dirty then is illegal: the entry is
    // not a descendant of this widget, so the framework may already
    // have walked past it.
    if (_entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entry?.markNeedsBuild();
      });
    }
  }

  void _onControllerChanged() {
    if (widget.controller.isOpen) {
      _show();
    } else {
      _hide();
    }
  }

  Alignment get _targetAnchor {
    switch (widget.position) {
      case PlinthPopoverPosition.top:
        return Alignment.topCenter;
      case PlinthPopoverPosition.bottom:
        return Alignment.bottomCenter;
      case PlinthPopoverPosition.left:
        return Alignment.centerLeft;
      case PlinthPopoverPosition.right:
        return Alignment.centerRight;
    }
  }

  Alignment get _followerAnchor {
    switch (widget.position) {
      case PlinthPopoverPosition.top:
        return Alignment.bottomCenter;
      case PlinthPopoverPosition.bottom:
        return Alignment.topCenter;
      case PlinthPopoverPosition.left:
        return Alignment.centerRight;
      case PlinthPopoverPosition.right:
        return Alignment.centerLeft;
    }
  }

  Offset get _offset {
    switch (widget.position) {
      case PlinthPopoverPosition.top:
        return Offset(0, -_gap);
      case PlinthPopoverPosition.bottom:
        return Offset(0, _gap);
      case PlinthPopoverPosition.left:
        return Offset(-_gap, 0);
      case PlinthPopoverPosition.right:
        return Offset(_gap, 0);
    }
  }

  void _show() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    // Captured from this State's own context (guaranteed to sit below
    // the app's Theme, unlike the OverlayEntry builder's own context
    // which depends on where the enclosing Overlay/Navigator lives).
    final theme = context.plinth;
    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;

    _entry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          if (widget.closeOnOutsideTap)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.controller.close,
              ),
            ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: _targetAnchor,
            followerAnchor: _followerAnchor,
            offset: _offset,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(resolvedRadius),
              child: Container(
                width: widget.width,
                padding: EdgeInsets.all(theme.spacing[PlinthSize.sm]!),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(resolvedRadius),
                ),
                child: widget.content,
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: widget.controller.toggle,
        child: widget.target,
      ),
    );
  }
}
