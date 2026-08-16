import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_loader.dart';

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
    this.loading = false,
  });

  /// Null disables the button, Flutter's own convention — and unlike
  /// before 0.19.0, a disabled button now *looks* disabled.
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

  /// Shows a spinner in place of [leadingIcon] and stops responding to
  /// taps, for the span between a submit and its answer.
  ///
  /// Keeps the button's own colors rather than the disabled ones: it
  /// is *busy*, not unavailable, and greying it out would say the
  /// press didn't land. Taps are ignored regardless, so a slow request
  /// can't be submitted twice.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final baseColor = theme.shaded(colorKey, 6);

    final resolvedRadius = theme.radius[radius ?? theme.defaultRadius]!;
    final verticalPadding = theme.spacing[size]! * 0.5;
    final horizontalPadding = theme.spacing[size]!;
    final fontSize = theme.fontSizes[size]!;

    final disabled = onPressed == null;

    final (background, foreground, border) = disabled
        ? _disabledColors(variant, theme)
        : _resolveColors(
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
        enabled: !disabled && !loading,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(resolvedRadius),
          child: InkWell(
            // A button mid-request must not take a second press, so
            // loading removes the callback rather than only dressing
            // the button up as busy.
            onTap: loading ? null : onPressed,
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
                  if (loading) ...[
                    // Sized to the label rather than the size scale, so
                    // starting to load doesn't change the button's
                    // height — and tinted to the foreground, which on a
                    // filled button is a colour the palette can't name.
                    PlinthLoader(
                      dimension: fontSize,
                      colorValue: foreground,
                    ),
                    SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
                  ] else if (leadingIcon != null) ...[
                    leadingIcon!,
                    SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
                  ],
                  // Flexible so a label too long for the available
                  // width shrinks instead of overflowing the button.
                  // Reachable whenever the width is constrained rather
                  // than derived from the content: fullWidth, a narrow
                  // parent, or a large text scale.
                  Flexible(
                    child: DefaultTextStyle.merge(
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

  /// What every variant collapses to once the button can't be pressed.
  ///
  /// A muted fill rather than an opacity wrapper: opacity lets whatever
  /// sits behind the button show through it, so the same disabled
  /// button reads differently on a card and on a photograph. The
  /// variants that draw nothing keep drawing nothing — a disabled
  /// `subtle` button with a grey plate would be *more* prominent than
  /// its enabled self.
  (Color background, Color foreground, Color? border) _disabledColors(
    PlinthVariant variant,
    PlinthTheme theme,
  ) {
    return switch (variant) {
      PlinthVariant.subtle || PlinthVariant.transparent => (
          Colors.transparent,
          theme.textDisabled,
          null
        ),
      PlinthVariant.outline || PlinthVariant.defaultVariant => (
          theme.surfaceMuted,
          theme.textDisabled,
          theme.borderMuted
        ),
      PlinthVariant.filled || PlinthVariant.light => (
          theme.surfaceMuted,
          theme.textDisabled,
          null
        ),
    };
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
