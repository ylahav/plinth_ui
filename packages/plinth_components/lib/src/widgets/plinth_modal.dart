import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

import 'plinth_box.dart';
import 'plinth_text.dart';
import 'overlay_host.dart';

/// An overlay dialog matching Mantine's `Modal`: centered content on a
/// dismissible backdrop, with an optional title bar and close button.
///
/// Visibility is driven by a [PlinthDisclosureController] rather than
/// Flutter's `showDialog` imperative API, so a single controller can
/// be shared between the trigger button and the modal itself (and
/// later, other overlays like Drawer can reuse the same controller
/// shape).
///
/// ```dart
/// final _modal = PlinthDisclosureController();
///
/// PlinthButton(onPressed: _modal.open, child: const Text('Open'));
///
/// PlinthModal(
///   controller: _modal,
///   title: 'Confirm',
///   child: const Text('Are you sure?'),
/// );
/// ```
///
/// [PlinthModal] renders nothing itself — call [show] to push it as a
/// route, typically from a listener on [controller]. See
/// [PlinthModalHost] for a zero-boilerplate way to wire that up.
class PlinthModal extends StatelessWidget {
  const PlinthModal({
    super.key,
    required this.controller,
    this.title,
    required this.child,
    this.size = PlinthSize.md,
    this.closeOnBackdropTap = true,
    this.radius,
  });

  final PlinthDisclosureController controller;
  final String? title;
  final Widget child;

  /// Controls the modal's max width via the theme's spacing scale
  /// (larger [PlinthSize] -> wider modal).
  final PlinthSize size;

  final bool closeOnBackdropTap;
  final PlinthSize? radius;

  static const Map<PlinthSize, double> _widths = {
    PlinthSize.xs: 320,
    PlinthSize.sm: 380,
    PlinthSize.md: 440,
    PlinthSize.lg: 560,
    PlinthSize.xl: 720,
  };

  /// Pushes this modal as a dialog route. Automatically calls
  /// [PlinthDisclosureController.close] when dismissed via backdrop
  /// tap or the close button, keeping [controller] in sync with
  /// whatever else is listening to it.
  Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: closeOnBackdropTap,
      barrierLabel: title ?? 'Modal',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, _, __) => _buildContent(context),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    ).whenComplete(controller.close);
  }

  Widget _buildContent(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius = theme.radius[radius ?? theme.defaultRadius]!;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _widths[size]!),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(resolvedRadius),
          clipBehavior: Clip.antiAlias,
          child: PlinthBox(
            p: PlinthSize.lg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PlinthModal is driven imperatively via show(), not built inline
    // in the tree — see PlinthModalHost for the declarative wrapper.
    return const SizedBox.shrink();
  }
}

/// Wraps [child] and automatically calls [modal.show] whenever
/// [modal]'s controller opens, so you can declare the modal once and
/// forget about wiring listeners manually.
///
/// ```dart
/// PlinthModalHost(
///   modal: PlinthModal(controller: _modal, title: 'Hi', child: ...),
///   child: Scaffold(
///     body: PlinthButton(onPressed: _modal.open, child: const Text('Open')),
///   ),
/// )
/// ```
class PlinthModalHost extends StatelessWidget {
  const PlinthModalHost({super.key, required this.modal, required this.child});

  final PlinthModal modal;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlinthOverlayHost(
      controller: modal.controller,
      onOpen: modal.show,
      child: child,
    );
  }
}
