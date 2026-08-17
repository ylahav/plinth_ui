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
///
/// ## [position] is a preference, not an instruction
///
/// A panel that would run off the screen on its requested side is put
/// on the opposite one instead — a `bottom` popover near the bottom of
/// the viewport opens upward. Only the requested axis flips: `bottom`
/// becomes `top`, never `left`. If neither side fits, the requested one
/// wins, on the grounds that a caller who asked for `bottom` and cannot
/// have it is better served by the side they named than by a surprise.
///
/// This costs one frame. The panel's height isn't knowable until it has
/// been laid out, and which side fits depends on that height, so the
/// first frame after opening lays it out invisibly to measure it and
/// the second shows it in the resolved place. The alternative — placing
/// it visibly and then moving it — is the jump this avoids.
///
/// [PlinthTooltip] gets the same behaviour from Flutter's own tooltip,
/// which is why the pre-1.0 audit could record it as already handled
/// there while it was missing here.
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
  final _panelKey = GlobalKey();
  OverlayEntry? _entry;

  static const double _gap = 8;

  /// The side actually used. Starts as the requested one and is
  /// replaced once the panel has a measured size to judge by.
  late PlinthPopoverPosition _resolved = widget.position;

  /// Whether [_resolved] has been decided against a real panel size.
  /// The panel stays invisible and untappable until it has, so it is
  /// never seen in a place it is about to leave.
  bool _measured = false;

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
      // New content can be a new size, which can change which side it
      // fits on. Re-resolving is a no-op when the answer is unchanged.
      _scheduleResolve();
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
    switch (_resolved) {
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
    switch (_resolved) {
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
    switch (_resolved) {
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
            // Laid out on the first frame so it can be measured, but
            // neither drawn nor tappable until the side is settled.
            child: IgnorePointer(
              ignoring: !_measured,
              child: Opacity(
                opacity: _measured ? 1 : 0,
                child: Material(
                  key: _panelKey,
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
            ),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
    _scheduleResolve();
  }

  /// The opposite side on the same axis. A popover that won't fit
  /// below belongs above, never beside — flipping across axes would
  /// move it somewhere the caller never pointed at.
  static PlinthPopoverPosition _opposite(PlinthPopoverPosition p) {
    switch (p) {
      case PlinthPopoverPosition.top:
        return PlinthPopoverPosition.bottom;
      case PlinthPopoverPosition.bottom:
        return PlinthPopoverPosition.top;
      case PlinthPopoverPosition.left:
        return PlinthPopoverPosition.right;
      case PlinthPopoverPosition.right:
        return PlinthPopoverPosition.left;
    }
  }

  /// The target's rectangle in global coordinates. This State's own
  /// render object *is* the target's, since [build] wraps nothing else
  /// around it.
  Rect? _targetRect() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  bool _fits(PlinthPopoverPosition side, Rect target, Size screen, Size panel) {
    switch (side) {
      case PlinthPopoverPosition.top:
        return target.top - _gap - panel.height >= 0;
      case PlinthPopoverPosition.bottom:
        return target.bottom + _gap + panel.height <= screen.height;
      case PlinthPopoverPosition.left:
        return target.left - _gap - panel.width >= 0;
      case PlinthPopoverPosition.right:
        return target.right + _gap + panel.width <= screen.width;
    }
  }

  /// Measures the panel once it has been laid out, picks the side, and
  /// rebuilds the entry if that changed anything — including the first
  /// pass, which is what reveals the panel.
  void _scheduleResolve() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _entry == null) return;

      final panel = _panelKey.currentContext?.findRenderObject() as RenderBox?;
      final target = _targetRect();
      if (panel == null || !panel.hasSize || target == null) return;

      final screen = MediaQuery.sizeOf(context);
      var side = widget.position;
      if (!_fits(side, target, screen, panel.size)) {
        final other = _opposite(side);
        // Neither side fits: keep the one that was asked for.
        if (_fits(other, target, screen, panel.size)) side = other;
      }

      if (_measured && side == _resolved) return;
      _resolved = side;
      _measured = true;
      _entry?.markNeedsBuild();
    });
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
    // The next open re-measures from scratch: the content may have
    // changed size, and the target may have moved.
    _measured = false;
    _resolved = widget.position;
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
