import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_popover.dart' show PlinthPopoverPosition;

/// A hover-triggered anchored panel matching Mantine's `HoverCard`.
///
/// Structurally similar to [PlinthPopover] (same
/// [CompositedTransformTarget]/[CompositedTransformFollower] +
/// [OverlayEntry] approach), but not built by composing it directly —
/// `Popover`'s trigger is hardcoded to tap, which doesn't fit hover
/// semantics, and a hover card additionally needs to stay open while
/// the pointer travels from [target] onto [content] itself, which
/// `Popover` has no mechanism for. [closeDelay] is the grace period
/// after the pointer leaves both regions before the card actually
/// closes, so that travel doesn't cause a flicker.
///
/// Desktop/web-oriented — touch devices have no hover concept, so
/// this control is effectively inert there (see [PlinthPopover] for
/// a tap-triggered equivalent that works everywhere).
///
/// ```dart
/// PlinthHoverCard(
///   target: PlinthAnchor('Hover for details', onTap: () {}),
///   content: const Text('Extra context shown on hover.'),
/// )
/// ```
class PlinthHoverCard extends StatefulWidget {
  const PlinthHoverCard({
    super.key,
    required this.target,
    required this.content,
    this.position = PlinthPopoverPosition.bottom,
    this.width,
    this.closeDelay = const Duration(milliseconds: 100),
  });

  final Widget target;
  final Widget content;
  final PlinthPopoverPosition position;

  /// Fixed content width. Omit to size to content.
  final double? width;

  final Duration closeDelay;

  @override
  State<PlinthHoverCard> createState() => _PlinthHoverCardState();
}

class _PlinthHoverCardState extends State<PlinthHoverCard> {
  final _layerLink = LayerLink();
  OverlayEntry? _entry;
  Timer? _closeTimer;

  static const double _gap = 8;

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
        return const Offset(0, -_gap);
      case PlinthPopoverPosition.bottom:
        return const Offset(0, _gap);
      case PlinthPopoverPosition.left:
        return const Offset(-_gap, 0);
      case PlinthPopoverPosition.right:
        return const Offset(_gap, 0);
    }
  }

  void _open() {
    _closeTimer?.cancel();
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    final theme = context.plinth;
    final resolvedRadius = theme.radius[theme.defaultRadius]!;

    _entry = OverlayEntry(
      builder: (overlayContext) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        targetAnchor: _targetAnchor,
        followerAnchor: _followerAnchor,
        offset: _offset,
        child: MouseRegion(
          onEnter: (_) => _closeTimer?.cancel(),
          onExit: (_) => _scheduleClose(),
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
      ),
    );
    overlay.insert(_entry!);
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(widget.closeDelay, _close);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _open(),
        onExit: (_) => _scheduleClose(),
        child: widget.target,
      ),
    );
  }
}
