import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'focus_ring.dart';

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
///
/// ## When it does not fit
///
/// **The label truncates on one line.** A chip takes its label's natural
/// width while there is room; in a narrower slot the label ellipsizes
/// and the chip stays inside the width it was given. Previously the
/// label kept its natural width in a row that could not shrink it, so a
/// long label — a translation, a tip title in a `Wrap` on a phone —
/// overflowed. Found in CaptureGuide, which worked around it with its
/// own link chip.
///
/// The chip never wraps to a second line: that would change its height,
/// which in a `Wrap` of chips is the same bug in a different place. The
/// full label still reaches a screen reader.
///
/// In an unbounded width — a chip in a horizontal scroll view — there is
/// nothing to divide, so the chip keeps its natural width as before.
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
        child: PlinthFocusRing(
          builder: (onFocusChange) => InkWell(
            onFocusChange: onFocusChange,
            onTap: enabled ? () => onSelected!(!selected) : null,
            borderRadius: BorderRadius.circular(resolvedRadius),
            child: AnimatedContainer(
              duration: theme.duration(PlinthSize.sm),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Truncate rather than overflow — see the class doc.
                  //
                  // `Flexible` only where the width is bounded, the same
                  // guard `PlinthTabs` and `PlinthSegmentedControl` use:
                  // a flex child in an unbounded row is a layout error,
                  // and chips often sit in a horizontal scroll view.
                  final text = Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _fontSizes[size],
                      color: selected
                          ? theme.contrastingOn(baseColor)
                          : theme.text,
                      fontWeight: selected
                          ? theme.weight(PlinthWeight.semibold)
                          : theme.weight(PlinthWeight.regular),
                    ),
                  );
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        Icon(Icons.check,
                            size: _fontSizes[size]! + 2,
                            color: theme.contrastingOn(baseColor)),
                        const SizedBox(width: 4),
                      ],
                      if (constraints.hasBoundedWidth)
                        Flexible(child: text)
                      else
                        text,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
