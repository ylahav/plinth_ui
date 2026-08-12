import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

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
class PlinthLoadingOverlay extends StatelessWidget {
  const PlinthLoadingOverlay({
    super.key,
    required this.child,
    required this.visible,
    this.color,
  });

  final Widget child;
  final bool visible;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final spinnerColor = theme.shaded(colorKey, 6);

    return Stack(
      children: [
        // IgnorePointer rather than removing `child` from
        // interaction some other way — keeps its size/layout stable
        // so wrapping content doesn't jump when loading toggles.
        IgnorePointer(ignoring: visible, child: child),
        if (visible)
          Positioned.fill(
            child: Container(
              color: theme.surface.withValues(alpha: 0.75),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(spinnerColor),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
