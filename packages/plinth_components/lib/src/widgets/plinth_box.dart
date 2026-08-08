import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A `Container`-like primitive with Mantine-style spacing shorthand:
/// instead of raw `EdgeInsets`, margin/padding accept [PlinthSize]
/// keys that resolve through the active [PlinthTheme], so spacing
/// stays consistent with the rest of the design system.
///
/// ```dart
/// PlinthBox(
///   p: PlinthSize.md,   // padding: theme.spacing[md] on all sides
///   m: PlinthSize.sm,   // margin: theme.spacing[sm] on all sides
///   child: const Text('Hello'),
/// )
/// ```
class PlinthBox extends StatelessWidget {
  const PlinthBox({
    super.key,
    this.child,
    this.p,
    this.px,
    this.py,
    this.m,
    this.mx,
    this.my,
    this.w,
    this.h,
    this.bg,
    this.radius,
    this.border,
    this.alignment,
  });

  final Widget? child;

  /// Padding on all sides, keyed by [PlinthSize].
  final PlinthSize? p;

  /// Padding on the horizontal axis only (overrides [p] on that axis).
  final PlinthSize? px;

  /// Padding on the vertical axis only (overrides [p] on that axis).
  final PlinthSize? py;

  final PlinthSize? m;
  final PlinthSize? mx;
  final PlinthSize? my;

  /// Explicit width/height in logical pixels — not theme-scaled, since
  /// layout dimensions are context-specific rather than tokenized.
  final double? w;
  final double? h;

  /// Background color key into the active theme's palette (e.g. 'blue').
  /// Pass a specific shade via [PlinthBoxColor] if you need finer control;
  /// this shorthand uses shade 6 (the "base" shade) for simplicity.
  final String? bg;

  final PlinthSize? radius;
  final Color? border;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    EdgeInsets resolveInsets(PlinthSize? all, PlinthSize? x, PlinthSize? y) {
      final base = all != null ? theme.spacing[all]! : 0.0;
      final horizontal = x != null ? theme.spacing[x]! : base;
      final vertical = y != null ? theme.spacing[y]! : base;
      return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
    }

    final padding = resolveInsets(p, px, py);
    final margin = resolveInsets(m, mx, my);
    final resolvedRadius = radius != null ? theme.radius[radius]! : 0.0;
    final resolvedBg = bg != null ? theme.color(bg!, 6) : null;

    return Container(
      width: w,
      height: h,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: child,
    );
  }
}
