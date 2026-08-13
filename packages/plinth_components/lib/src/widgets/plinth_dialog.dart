import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

import 'plinth_close_button.dart';
import 'plinth_text.dart';

/// Where a [PlinthDialog] sits on screen.
enum PlinthDialogPosition { topLeft, topRight, bottomLeft, bottomRight }

/// A small floating panel anchored to a screen corner, matching
/// Mantine's `Dialog`.
///
/// Deliberately *not* a modal. [PlinthModal] takes the screen, dims
/// what's behind it, and demands an answer before anything else can
/// happen. This sits in a corner and lets the user carry on — a cookie
/// notice, a "we've updated" prompt, a quick feedback box. Nothing
/// behind it is blocked.
///
/// Mounted in the overlay, so it escapes any clipping ancestor. Like
/// the other disclosure components it takes a
/// [PlinthDisclosureController], which the caller owns and disposes.
///
/// ```dart
/// PlinthDialog(
///   controller: _dialog,
///   title: 'Subscribe',
///   child: const SubscribeForm(),
/// )
/// ```
class PlinthDialog extends StatefulWidget {
  const PlinthDialog({
    super.key,
    required this.controller,
    required this.child,
    this.title,
    this.position = PlinthDialogPosition.bottomRight,
    this.width = 320,
    this.withCloseButton = true,
    this.radius,
    this.margin = PlinthSize.lg,
  });

  final PlinthDisclosureController controller;
  final Widget child;
  final String? title;
  final PlinthDialogPosition position;
  final double width;

  /// A dialog with no close button and no action inside it is a trap,
  /// so this defaults on.
  final bool withCloseButton;

  final PlinthSize? radius;

  /// Distance from the screen edges.
  final PlinthSize margin;

  @override
  State<PlinthDialog> createState() => _PlinthDialogState();
}

class _PlinthDialogState extends State<PlinthDialog> {
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    if (widget.controller.isOpen) {
      // Inserting during build would setState the ancestor Overlay
      // mid-build, so defer to after this frame — the same reason
      // PlinthPortal does.
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  @override
  void didUpdateWidget(covariant PlinthDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    // Rebuild the panel so prop changes reach an already-open dialog.
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
    if (!mounted) return;
    widget.controller.isOpen ? _show() : _hide();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _hide();
    super.dispose();
  }

  void _show() {
    if (_entry != null) return;
    _entry = OverlayEntry(builder: _buildPanel);
    Overlay.of(context).insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  Alignment get _alignment => switch (widget.position) {
        PlinthDialogPosition.topLeft => Alignment.topLeft,
        PlinthDialogPosition.topRight => Alignment.topRight,
        PlinthDialogPosition.bottomLeft => Alignment.bottomLeft,
        PlinthDialogPosition.bottomRight => Alignment.bottomRight,
      };

  Widget _buildPanel(BuildContext overlayContext) {
    final theme = context.plinth;
    final resolvedRadius = theme.radius[widget.radius ?? PlinthSize.md]!;
    final inset = theme.spacing[widget.margin]!;

    // No barrier and no IgnorePointer: the point of a dialog over a
    // modal is that the rest of the app stays usable. Align, Padding,
    // and SafeArea only hit-test their child, so a tap that misses the
    // panel falls straight through to whatever is underneath.
    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(inset),
          child: Align(
            alignment: _alignment,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: widget.width,
                padding: EdgeInsets.all(theme.spacing[PlinthSize.md]!),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(resolvedRadius),
                  border: Border.all(color: theme.border),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadow.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.title != null || widget.withCloseButton) ...[
                      Row(
                        children: [
                          Expanded(
                            child: widget.title == null
                                ? const SizedBox.shrink()
                                : PlinthText(
                                    widget.title!,
                                    weight: FontWeight.w700,
                                  ),
                          ),
                          if (widget.withCloseButton)
                            PlinthCloseButton(
                              onPressed: widget.controller.close,
                              semanticLabel: 'Close dialog',
                            ),
                        ],
                      ),
                      SizedBox(height: theme.spacing[PlinthSize.xs]),
                    ],
                    widget.child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Renders nothing inline — the panel lives in the overlay. Mount
    // this anywhere below an Overlay and drive it with the controller.
    return const SizedBox.shrink();
  }
}
