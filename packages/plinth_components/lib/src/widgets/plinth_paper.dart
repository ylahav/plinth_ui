import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Shadow depth for [PlinthPaper]/[PlinthCard], mirroring Mantine's
/// shadow scale (a subset of it — Mantine also has `xl`, added here
/// only as far as this library currently needs).
enum PlinthShadow { none, sm, md, lg }

/// A themed surface container matching Mantine's `Paper`: a white
/// (or custom) background with optional shadow, border, radius, and
/// padding. The foundation [PlinthCard] builds on — reach for `Paper`
/// directly when you just need a surface, and `Card` when you want
/// its header/footer section conventions too.
///
/// ```dart
/// PlinthPaper(
///   p: PlinthSize.md,
///   shadow: PlinthShadow.sm,
///   child: const Text('Content on a raised surface'),
/// )
/// ```
class PlinthPaper extends StatelessWidget {
  const PlinthPaper({
    super.key,
    required this.child,
    this.p = PlinthSize.md,
    this.radius,
    this.shadow = PlinthShadow.none,
    this.withBorder = false,
    this.bg,
  });

  final Widget child;

  /// Padding on all sides, keyed by [PlinthSize] (matches [PlinthBox]'s
  /// shorthand convention). Pass `null` for no padding.
  final PlinthSize? p;

  final PlinthSize? radius;
  final PlinthShadow shadow;

  /// Adds a 1px border in a neutral gray when true.
  final bool withBorder;

  /// Background color. Defaults to white.
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius = theme.radius[radius ?? theme.defaultRadius]!;
    final padding = p != null ? EdgeInsets.all(theme.spacing[p]!) : EdgeInsets.zero;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: withBorder ? Border.all(color: const Color(0xFFE9ECEF)) : null,
        boxShadow: _shadowFor(shadow),
      ),
      child: child,
    );
  }

  static List<BoxShadow> _shadowFor(PlinthShadow shadow) {
    switch (shadow) {
      case PlinthShadow.none:
        return const [];
      case PlinthShadow.sm:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ];
      case PlinthShadow.md:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
      case PlinthShadow.lg:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];
    }
  }
}
