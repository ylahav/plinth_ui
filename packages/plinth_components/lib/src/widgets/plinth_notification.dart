import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_close_button.dart';
import 'plinth_text.dart';

/// A toast-style notification matching Mantine's `Notification`.
///
/// Distinct from [PlinthAlert]: `PlinthAlert` is an inline callout
/// meant to sit in a page's normal layout flow (a permanent-ish
/// banner until dismissed). `PlinthNotification` is meant to float —
/// typically shown via [show], which pushes it as a `SnackBar` using
/// Flutter's own `ScaffoldMessenger`, so it inherits Flutter's
/// existing stacking, auto-dismiss timing, and swipe-to-dismiss
/// behavior rather than reimplementing a toast/overlay stack from
/// scratch.
///
/// ```dart
/// PlinthNotification.show(
///   context,
///   title: 'Saved',
///   color: 'green',
///   icon: const Icon(Icons.check_circle_outline),
///   child: const Text('Your changes have been saved.'),
/// );
/// ```
class PlinthNotification extends StatelessWidget {
  const PlinthNotification({
    super.key,
    this.title,
    required this.child,
    this.color = 'blue',
    this.icon,
    this.onClose,
    this.radius,
  });

  final String? title;
  final Widget child;
  final String color;
  final Widget? icon;

  /// If non-null, renders a close button that calls this when tapped.
  /// When shown via [show], this is wired up automatically to dismiss
  /// the snack bar — you don't need to pass it yourself in that case.
  final VoidCallback? onClose;

  final PlinthSize? radius;

  /// Shows this notification as a floating `SnackBar` via
  /// [ScaffoldMessenger]. Requires a `Scaffold` (or `MaterialApp`'s
  /// built-in one) above [context] in the widget tree — the same
  /// requirement Flutter's `SnackBar` already has.
  ///
  /// Use [showOn] instead when showing a message *after* an `await`.
  static void show(
    BuildContext context, {
    String? title,
    required Widget child,
    String color = 'blue',
    Widget? icon,
    PlinthSize? radius,
    Duration duration = const Duration(seconds: 4),
  }) {
    showOn(
      ScaffoldMessenger.of(context),
      title: title,
      color: color,
      icon: icon,
      radius: radius,
      duration: duration,
      child: child,
    );
  }

  /// The same, against a messenger you already hold.
  ///
  /// Flutter's idiom for feedback after an `await` is to capture the
  /// messenger *before* it, precisely so no `BuildContext` is needed
  /// once the work finishes:
  ///
  /// ```dart
  /// final messenger = ScaffoldMessenger.of(context);
  /// await store.applyImport(file);
  /// PlinthNotification.showOn(messenger, child: const Text('Imported'));
  /// ```
  ///
  /// [show] cannot express that. Taking only a context forces the
  /// `if (!context.mounted) return;` form instead — which is **a
  /// different behaviour, not a different spelling**: the captured
  /// messenger still delivers its message when the widget has gone
  /// away, and the guard silently drops it. For "import finished" the
  /// guard is often the wrong choice, and either way it should be the
  /// caller's decision rather than a consequence of the signature.
  ///
  /// One real app hit this 13 times.
  ///
  /// This is the more primitive of the two — [show] is this plus a
  /// lookup.
  static void showOn(
    ScaffoldMessengerState messenger, {
    String? title,
    required Widget child,
    String color = 'blue',
    Widget? icon,
    PlinthSize? radius,
    Duration duration = const Duration(seconds: 4),
  }) {
    late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
        controller;
    controller = messenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        content: PlinthNotification(
          title: title,
          color: color,
          icon: icon,
          radius: radius,
          onClose: () => controller.close(),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final accentColor = theme.shaded(color, 6);
    final resolvedRadius = theme.radius[radius ?? PlinthSize.sm]!;

    return Material(
      color: theme.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(resolvedRadius),
      child: Container(
        padding: EdgeInsets.all(theme.spacing[PlinthSize.sm]!),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(resolvedRadius),
          border: Border(left: BorderSide(color: accentColor, width: 4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(color: accentColor, size: 20),
                child: icon!,
              ),
              SizedBox(width: theme.spacing[PlinthSize.sm]),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    PlinthText(title!, weight: FontWeight.w700),
                  if (title != null)
                    SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.5),
                  DefaultTextStyle.merge(
                    style: TextStyle(color: theme.text, fontSize: 14),
                    child: child,
                  ),
                ],
              ),
            ),
            if (onClose != null) ...[
              SizedBox(width: theme.spacing[PlinthSize.xs]),
              PlinthCloseButton(
                onPressed: onClose,
                semanticLabel: 'Dismiss notification',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
