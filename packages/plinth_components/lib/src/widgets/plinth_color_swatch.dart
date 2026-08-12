import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A selectable color square matching Mantine's `ColorSwatch`.
///
/// Standalone — for a full color picker, lay out a `Wrap`/`Row` of
/// these with your own selected-color state, the same controlled-
/// component pattern as [PlinthChip]:
///
/// ```dart
/// Wrap(
///   spacing: 8,
///   children: [
///     for (final c in ['blue', 'red', 'green', 'gray'])
///       PlinthColorSwatch(
///         color: c,
///         selected: _selectedColor == c,
///         onTap: () => setState(() => _selectedColor = c),
///       ),
///   ],
/// )
/// ```
class PlinthColorSwatch extends StatelessWidget {
  const PlinthColorSwatch({
    super.key,
    required this.color,
    this.selected = false,
    this.onTap,
    this.size = PlinthSize.md,
  });

  /// Color key into the active theme's palette (e.g. `'blue'`).
  final String color;

  final bool selected;
  final VoidCallback? onTap;
  final PlinthSize size;

  static const Map<PlinthSize, double> _dimensions = {
    PlinthSize.xs: 20,
    PlinthSize.sm: 26,
    PlinthSize.md: 32,
    PlinthSize.lg: 40,
    PlinthSize.xl: 48,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final fillColor = theme.shaded(color, 6);
    final dimension = _dimensions[size]!;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: dimension,
          height: dimension,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(6),
            border: selected ? Border.all(color: theme.text, width: 2) : null,
          ),
          child: selected
              ? Icon(Icons.check,
                  size: dimension * 0.5, color: theme.contrastingOn(fillColor))
              : null,
        ),
      ),
    );
  }
}
