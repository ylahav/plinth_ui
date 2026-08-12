import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Icon extent per [PlinthSize].
const Map<PlinthSize, double> _iconSizes = {
  PlinthSize.xs: 12,
  PlinthSize.sm: 14,
  PlinthSize.md: 16,
  PlinthSize.lg: 18,
  PlinthSize.xl: 22,
};

/// The dismiss affordance shared by anything closeable, matching
/// Mantine's `CloseButton`.
///
/// [PlinthAlert], [PlinthNotification], [PlinthModal], and
/// [PlinthDrawer] each built one inline before this existed, and they
/// had drifted: two used a bare `Icon` inside an `InkWell` with no
/// semantics at all, so a screen reader announced nothing where a
/// sighted user saw a close button.
///
/// Distinct from [PlinthActionIcon], which is the general icon-button
/// primitive. This is narrower on purpose — it always carries the same
/// glyph and the same "Close" semantics, so the components that use it
/// can't accidentally diverge on either.
///
/// ```dart
/// PlinthCloseButton(onPressed: () => setState(() => _visible = false))
/// ```
class PlinthCloseButton extends StatelessWidget {
  const PlinthCloseButton({
    super.key,
    required this.onPressed,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.semanticLabel = 'Close',
  });

  /// A null callback disables the button, matching every other
  /// interactive component here.
  final VoidCallback? onPressed;

  final PlinthSize size;

  /// Color key into the theme palette. Falls back to the muted text
  /// color, which is what a dismiss control should read as — present
  /// but not competing with the content it sits beside.
  final String? color;

  final PlinthSize? radius;

  /// What assistive technology announces. Worth overriding when the
  /// surrounding context makes "Close" ambiguous — "Dismiss
  /// notification", say.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final enabled = onPressed != null;
    final iconSize = _iconSizes[size]!;
    final resolvedRadius = theme.radius[radius ?? PlinthSize.xs]!;

    final foreground = !enabled
        ? theme.textDisabled
        : color != null
            ? theme.readableOn(color!, theme.surface)
            : theme.textMuted;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: Padding(
          // A bare icon is a small tap target; the padding brings it
          // closer to a comfortable one without changing the glyph.
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.close, size: iconSize, color: foreground),
        ),
      ),
    );
  }
}
