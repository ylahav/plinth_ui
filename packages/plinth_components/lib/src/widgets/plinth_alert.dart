import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_close_button.dart';
import 'plinth_text.dart';

/// A colored callout box matching Mantine's `Alert`: an icon, optional
/// title, body content, and an optional dismiss button — all tinted
/// by [color] via the active [PlinthTheme].
///
/// ```dart
/// PlinthAlert(
///   title: 'Something went wrong',
///   color: 'red',
///   icon: const Icon(Icons.error_outline),
///   child: const Text('Please try again in a few minutes.'),
/// )
/// ```
class PlinthAlert extends StatelessWidget {
  const PlinthAlert({
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

  /// Color key into the theme palette — drives background tint,
  /// border, icon, and title color.
  final String color;

  final Widget? icon;

  /// If non-null, renders a close button that calls this when tapped.
  final VoidCallback? onClose;

  final PlinthSize? radius;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final accentColor = theme.shaded(color, 6);
    final backgroundColor = theme.shaded(color, 0);
    final resolvedRadius = theme.radius[radius ?? PlinthSize.sm]!;

    return Container(
      padding: EdgeInsets.all(theme.spacing[PlinthSize.md]!),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
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
                  PlinthText(title!, weight: FontWeight.w700, color: color),
                if (title != null)
                  SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.5),
                DefaultTextStyle(
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
              size: PlinthSize.md,
              color: color,
              semanticLabel: 'Dismiss alert',
            ),
          ],
        ],
      ),
    );
  }
}
