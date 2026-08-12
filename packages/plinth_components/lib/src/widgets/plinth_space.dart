import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A fixed-size spacer keyed by [PlinthSize] and resolved through
/// `theme.spacing`, matching Mantine's `Space` — for the common case
/// of "I need a themed gap here" without reaching for a raw
/// `SizedBox` with a magic-number pixel value.
///
/// Provide exactly one of [w] or [h] (or both, for a spacer with
/// both dimensions) — omitting both collapses to zero size.
///
/// ```dart
/// Column(
///   children: [
///     PlinthText('Above'),
///     const PlinthSpace(h: PlinthSize.lg),
///     PlinthText('Below'),
///   ],
/// )
/// ```
class PlinthSpace extends StatelessWidget {
  const PlinthSpace({super.key, this.w, this.h});

  final PlinthSize? w;
  final PlinthSize? h;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    return SizedBox(
      width: w != null ? theme.spacing[w]! : null,
      height: h != null ? theme.spacing[h]! : null,
    );
  }
}
