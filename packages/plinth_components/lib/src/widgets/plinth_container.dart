import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Constrains [child] to a maximum width and centers it, matching
/// Mantine's `Container` — the standard "page content shouldn't get
/// absurdly wide on a big monitor" wrapper.
///
/// ```dart
/// PlinthContainer(
///   size: PlinthContainerSize.md,
///   child: Column(children: [...]),
/// )
/// ```
class PlinthContainer extends StatelessWidget {
  const PlinthContainer({
    super.key,
    required this.child,
    this.size = PlinthContainerSize.md,
    this.padding = PlinthSize.md,
    this.fluid = false,
  });

  final Widget child;

  /// Ignored when [fluid] is set.
  final PlinthContainerSize size;

  /// Drops the maximum width and fills whatever it is given, keeping
  /// the horizontal [padding]. For the full-bleed sections a page puts
  /// between its constrained ones — a hero, a banner, a wide table —
  /// where the padding is still wanted and the ceiling is not.
  final bool fluid;

  /// Horizontal padding applied inside the max-width constraint.
  final PlinthSize padding;

  static const Map<PlinthContainerSize, double> _maxWidths = {
    PlinthContainerSize.xs: 540,
    PlinthContainerSize.sm: 720,
    PlinthContainerSize.md: 960,
    PlinthContainerSize.lg: 1140,
    PlinthContainerSize.xl: 1320,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: fluid ? double.infinity : _maxWidths[size]!,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.spacing[padding]!),
          child: child,
        ),
      ),
    );
  }
}

enum PlinthContainerSize { xs, sm, md, lg, xl }
