import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_announce.dart';

/// A full-container loading overlay matching Mantine's
/// `LoadingOverlay`: dims [child] and shows a centered spinner on
/// top when [visible] is true, blocking interaction with the content
/// beneath.
///
/// Distinct from [PlinthSkeleton] (a per-element loading placeholder
/// shown *before* content exists) — this overlays *existing* content
/// during an async operation (e.g. a form mid-submit), so the layout
/// doesn't shift when loading starts or ends.
///
/// ```dart
/// PlinthLoadingOverlay(
///   visible: _isSaving,
///   child: MyForm(),
/// )
/// ```
class PlinthLoadingOverlay extends StatefulWidget {
  const PlinthLoadingOverlay({
    super.key,
    required this.child,
    required this.visible,
    this.color,
    this.loadingLabel = 'Loading',
    this.completeLabel = 'Loading complete',
  });

  final Widget child;
  final bool visible;
  final String? color;

  /// What a screen reader hears when the overlay appears. Spoken from
  /// the tree, so it works on every platform.
  ///
  /// Pass an empty string for an overlay whose arrival is already
  /// announced by whatever triggered it.
  final String loadingLabel;

  /// What a screen reader hears when the overlay goes away.
  ///
  /// This one cannot come from the tree: when loading finishes the
  /// overlay is removed, and a live region that no longer exists
  /// announces nothing. So it is spoken with [PlinthAnnounce.say],
  /// which is the whole reason that half of the primitive exists —
  /// and, being an announcement, it is silent on Android by that
  /// platform's own policy. See `docs/F3_ANNOUNCEMENTS.md`.
  ///
  /// Pass an empty string to say nothing.
  final String completeLabel;

  @override
  State<PlinthLoadingOverlay> createState() => _PlinthLoadingOverlayState();
}

class _PlinthLoadingOverlayState extends State<PlinthLoadingOverlay> {
  @override
  void didUpdateWidget(PlinthLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The falling edge only. The rising one is carried by the live
    // region below, which is the better mechanism wherever a node
    // survives to hold the message.
    if (oldWidget.visible && !widget.visible) {
      PlinthAnnounce.say(context, widget.completeLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = widget.color ?? theme.primaryColor;
    final spinnerColor = theme.shaded(colorKey, 6);

    return Stack(
      children: [
        // IgnorePointer rather than removing `child` from
        // interaction some other way — keeps its size/layout stable
        // so wrapping content doesn't jump when loading toggles.
        IgnorePointer(ignoring: widget.visible, child: widget.child),
        if (widget.visible)
          Positioned.fill(
            child: Container(
              color: theme.surface.withValues(alpha: 0.75),
              child: Center(
                child: PlinthLiveRegion(
                  message: widget.loadingLabel,
                  // A spinner is a picture of waiting and says nothing
                  // on its own; the label is what there is to speak.
                  child: Semantics(
                    label: widget.loadingLabel,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(spinnerColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
