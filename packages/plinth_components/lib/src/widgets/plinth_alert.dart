import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_announce.dart';
import 'plinth_close_button.dart';
import 'plinth_localizations.dart';
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
    this.live = true,
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

  /// Whether a screen reader should be told when this appears, rather
  /// than only when a reader arrives at it.
  ///
  /// Defaults to true, because the usual alert is raised by something
  /// the user just did — a failed submit — and that is exactly the
  /// change `F-3` found nothing in this library ever spoke. Only the
  /// title and body are covered; the dismiss button is a control, and
  /// including it would re-speak "Dismiss alert" alongside the
  /// message.
  ///
  /// Pass false for a callout that is simply part of the page — a
  /// standing informational banner present on first paint. On the web
  /// that costs little either way, since a live region registered
  /// during the initial render announces nothing until it changes; on
  /// other platforms it is the difference between a quiet page and one
  /// that reads its own furniture aloud.
  ///
  /// **Dismissal is silent, deliberately.** The user pressed the
  /// button; telling them what they just did is noise.
  final bool live;

  Widget _spoken(Widget content) =>
      live ? PlinthLiveRegion.always(child: content) : content;

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
              // Not `accentColor`. An icon carries meaning on its own,
              // so WCAG 1.4.11 asks 3:1 against what is behind it — and
              // shade 6 on shade 0 cleared that for only 6 of the 13
              // ramps: yellow landed at 1.74:1, lime 1.91, green 2.19.
              data: IconThemeData(
                color: theme.readableOn(color, backgroundColor,
                    level: PlinthContrast.nonText),
                size: 20,
              ),
              child: icon!,
            ),
            SizedBox(width: theme.spacing[PlinthSize.sm]),
          ],
          Expanded(
            child: _spoken(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    PlinthText(title!,
                        weight: theme.weight(PlinthWeight.bold),
                        color: color,
                        // The title sits on the tint, not on the surface.
                        on: backgroundColor),
                  if (title != null)
                    SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.5),
                  DefaultTextStyle.merge(
                    style: TextStyle(color: theme.text, fontSize: 14),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
          if (onClose != null) ...[
            SizedBox(width: theme.spacing[PlinthSize.xs]),
            PlinthCloseButton(
              onPressed: onClose,
              size: PlinthSize.md,
              color: color,
              semanticLabel: context.plinthStrings.dismissAlert,
            ),
          ],
        ],
      ),
    );
  }
}
