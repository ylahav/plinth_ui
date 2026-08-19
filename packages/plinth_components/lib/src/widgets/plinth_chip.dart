import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_tap_target.dart';

/// A selectable pill toggle matching Mantine's `Chip`: shows a
/// checkmark and fills with the theme color when selected.
///
/// Standalone — for a group of mutually-exclusive or multi-select
/// chips, manage a `Set`/single value in your own state and pass
/// `selected: mySet.contains(value)` per chip, the same controlled-
/// component pattern as [PlinthCheckbox]/[PlinthRadio].
///
/// ```dart
/// Wrap(
///   spacing: 8,
///   children: [
///     for (final tag in _allTags)
///       PlinthChip(
///         label: tag,
///         selected: _selectedTags.contains(tag),
///         onSelected: (selected) => setState(() {
///           selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
///         }),
///       ),
///   ],
/// )
/// ```
class PlinthChip extends StatelessWidget {
  const PlinthChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
    this.size = PlinthSize.md,
    this.radius,
  });

  final String label;
  final bool selected;

  /// Null disables the chip.
  final ValueChanged<bool>? onSelected;

  final String? color;
  final PlinthSize size;

  /// Squares off the pill. Omit for the fully rounded default, which
  /// is what this shape normally wants; pass one when it has to match
  /// squarer chrome around it.
  final PlinthSize? radius;

  static const Map<PlinthSize, double> _fontSizes = {
    PlinthSize.xs: 11,
    PlinthSize.sm: 12,
    PlinthSize.md: 14,
    PlinthSize.lg: 15,
    PlinthSize.xl: 16,
  };

  static const Map<PlinthSize, double> _verticalPadding = {
    PlinthSize.xs: 3,
    PlinthSize.sm: 5,
    PlinthSize.md: 7,
    PlinthSize.lg: 9,
    PlinthSize.xl: 11,
  };

  static const Map<PlinthSize, double> _horizontalPadding = {
    PlinthSize.xs: 10,
    PlinthSize.sm: 12,
    PlinthSize.md: 14,
    PlinthSize.lg: 16,
    PlinthSize.xl: 18,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final baseColor = theme.shaded(colorKey, 6);
    final enabled = onSelected != null;
    final resolvedRadius = radius == null ? 999.0 : theme.radius[radius!]!;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      // Inside the Semantics: the button role covers the whole hit
      // area, and `getSemantics` resolves from the widget's root.
      child: PlinthTapTarget(
        child: InkWell(
          onTap: enabled ? () => onSelected!(!selected) : null,
          borderRadius: BorderRadius.circular(resolvedRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: _horizontalPadding[size]!,
              vertical: _verticalPadding[size]!,
            ),
            decoration: BoxDecoration(
              color: selected ? baseColor : theme.surface,
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: Border.all(
                color: selected ? baseColor : theme.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(Icons.check,
                      size: _fontSizes[size]! + 2,
                      color: theme.contrastingOn(baseColor)),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: _fontSizes[size],
                    color:
                        selected ? theme.contrastingOn(baseColor) : theme.text,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
