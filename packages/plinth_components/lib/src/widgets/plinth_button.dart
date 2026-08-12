import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A themeable button matching Mantine's Button API shape: a
/// `variant` controlling visual weight, a `size` from the shared
/// [PlinthSize] scale, and a `color` that keys into the active
/// [PlinthTheme]'s palette.
///
/// This widget is the reference implementation for every other
/// Plinth component — new widgets should follow the same
/// variant/size/color resolution pattern established here.
class PlinthButton extends StatelessWidget {
  const PlinthButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = PlinthVariant.filled,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.fullWidth = false,
    this.leadingIcon,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final PlinthVariant variant;
  final PlinthSize size;

  /// Key into the theme's color palette (e.g. 'blue', 'red').
  /// Falls back to the theme's `primaryColor` when omitted.
  final String? color;

  /// Overrides the theme's default radius for this button only.
  final PlinthSize? radius;

  final bool fullWidth;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final baseColor = theme.shaded(colorKey, 6);

    final resolvedRadius = theme.radius[radius ?? theme.defaultRadius]!;
    final verticalPadding = theme.spacing[size]! * 0.5;
    final horizontalPadding = theme.spacing[size]!;
    final fontSize = theme.fontSizes[size]!;

    final (background, foreground, border) = _resolveColors(
      variant: variant,
      colorKey: colorKey,
      baseColor: baseColor,
      lightColor: theme.shaded(colorKey, 1),
      theme: theme,
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(resolvedRadius),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(resolvedRadius),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(resolvedRadius),
                border: border != null ? Border.all(color: border) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
                  ],
                  // Flexible so a label too long for the available
                  // width shrinks instead of overflowing the button.
                  // Reachable whenever the width is constrained rather
                  // than derived from the content: fullWidth, a narrow
                  // parent, or a large text scale.
                  Flexible(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: foreground,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color background, Color foreground, Color? border) _resolveColors({
    required PlinthVariant variant,
    required String colorKey,
    required Color baseColor,
    required Color lightColor,
    required PlinthTheme theme,
  }) {
    // Foregrounds resolve against whatever they actually sit on: a
    // filled button against its own fill, a light one against its tint,
    // and the transparent variants against the surface behind them.
    // Using baseColor throughout put a cyan `subtle` button at 2.2:1.
    switch (variant) {
      case PlinthVariant.filled:
        return (baseColor, theme.contrastingOn(baseColor), null);
      case PlinthVariant.light:
        return (lightColor, theme.readableOn(colorKey, lightColor), null);
      case PlinthVariant.outline:
        final onSurface = theme.readableOn(colorKey, theme.surface);
        return (Colors.transparent, onSurface, onSurface);
      case PlinthVariant.subtle:
      case PlinthVariant.transparent:
        return (
          Colors.transparent,
          theme.readableOn(colorKey, theme.surface),
          null,
        );
      case PlinthVariant.defaultVariant:
        return (theme.surface, theme.text, theme.border);
    }
  }
}
