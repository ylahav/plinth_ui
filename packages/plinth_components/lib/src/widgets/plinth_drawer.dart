import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

import 'plinth_box.dart';
import 'plinth_text.dart';
import 'overlay_host.dart';

/// Which screen edge a [PlinthDrawer] slides in from.
enum PlinthDrawerPosition { left, right, top, bottom }

/// A slide-in side panel matching Mantine's `Drawer`: full-height (or
/// full-width, for top/bottom) content anchored to a screen edge,
/// dismissible via backdrop tap.
///
/// Shares [PlinthModal]'s controller-driven design — visibility comes
/// from a [PlinthDisclosureController] rather than an imperative
/// `showDialog`-only call, so the same controller can drive a trigger
/// button and the drawer itself. Use [PlinthDrawerHost] the same way
/// you'd use [PlinthModalHost].
///
/// ```dart
/// final _nav = PlinthDisclosureController();
///
/// PlinthDrawerHost(
///   drawer: PlinthDrawer(
///     controller: _nav,
///     title: 'Menu',
///     child: const Text('Drawer content'),
///   ),
///   child: Scaffold(
///     body: PlinthButton(onPressed: _nav.open, child: const Text('Open')),
///   ),
/// )
/// ```
class PlinthDrawer extends StatelessWidget {
  const PlinthDrawer({
    super.key,
    required this.controller,
    this.title,
    required this.child,
    this.position = PlinthDrawerPosition.right,
    this.size = PlinthSize.md,
    this.closeOnBackdropTap = true,
  });

  final PlinthDisclosureController controller;
  final String? title;
  final Widget child;
  final PlinthDrawerPosition position;

  /// Controls the drawer's extent (width for left/right, height for
  /// top/bottom) via a fixed size map, mirroring [PlinthModal]'s
  /// [PlinthSize]-keyed sizing.
  final PlinthSize size;

  final bool closeOnBackdropTap;

  static const Map<PlinthSize, double> _extents = {
    PlinthSize.xs: 240,
    PlinthSize.sm: 300,
    PlinthSize.md: 360,
    PlinthSize.lg: 460,
    PlinthSize.xl: 600,
  };

  bool get _isHorizontal =>
      position == PlinthDrawerPosition.left ||
      position == PlinthDrawerPosition.right;

  Offset get _beginOffset {
    switch (position) {
      case PlinthDrawerPosition.left:
        return const Offset(-1, 0);
      case PlinthDrawerPosition.right:
        return const Offset(1, 0);
      case PlinthDrawerPosition.top:
        return const Offset(0, -1);
      case PlinthDrawerPosition.bottom:
        return const Offset(0, 1);
    }
  }

  Alignment get _alignment {
    switch (position) {
      case PlinthDrawerPosition.left:
        return Alignment.centerLeft;
      case PlinthDrawerPosition.right:
        return Alignment.centerRight;
      case PlinthDrawerPosition.top:
        return Alignment.topCenter;
      case PlinthDrawerPosition.bottom:
        return Alignment.bottomCenter;
    }
  }

  /// Pushes this drawer as a dialog route sliding in from [position].
  /// Like [PlinthModal.show], calls [PlinthDisclosureController.close]
  /// automatically when dismissed so [controller] stays in sync.
  Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: closeOnBackdropTap,
      barrierLabel: title ?? 'Drawer',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) => _buildContent(context),
      transitionBuilder: (context, animation, _, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position:
              Tween(begin: _beginOffset, end: Offset.zero).animate(curved),
          child: child,
        );
      },
    ).whenComplete(controller.close);
  }

  Widget _buildContent(BuildContext context) {
    final theme = context.plinth;
    final extent = _extents[size]!;

    final panel = Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        child: PlinthBox(
          p: PlinthSize.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: PlinthText(
                        title!,
                        size: PlinthSize.lg,
                        weight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      splashRadius: 18,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: theme.spacing[PlinthSize.sm]),
              ],
              if (_isHorizontal)
                Expanded(child: child)
              else
                Flexible(child: child),
            ],
          ),
        ),
      ),
    );

    return Align(
      alignment: _alignment,
      child: SizedBox(
        width: _isHorizontal ? extent : double.infinity,
        height: _isHorizontal ? double.infinity : extent,
        child: panel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Like PlinthModal, PlinthDrawer is driven imperatively via
    // show() rather than built inline — see PlinthDrawerHost.
    return const SizedBox.shrink();
  }
}

/// Wraps [child] and automatically calls [drawer.show] whenever
/// [drawer]'s controller opens — the [PlinthDrawer] equivalent of
/// [PlinthModalHost].
class PlinthDrawerHost extends StatelessWidget {
  const PlinthDrawerHost(
      {super.key, required this.drawer, required this.child});

  final PlinthDrawer drawer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlinthOverlayHost(
      controller: drawer.controller,
      onOpen: drawer.show,
      child: child,
    );
  }
}
