import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_stack.dart';
import 'plinth_text.dart';

/// A themeable checkbox matching Mantine's `Checkbox`: a square box
/// that fills with the active theme color when checked, plus an
/// optional inline label.
///
/// ```dart
/// PlinthCheckbox(
///   label: 'I agree to the terms',
///   value: _agreed,
///   onChanged: (v) => setState(() => _agreed = v),
/// )
/// ```
class PlinthCheckbox extends StatelessWidget {
  const PlinthCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.error,
    this.indeterminate = false,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
  });

  final bool value;

  /// Null disables the checkbox (matches Flutter's `Checkbox` convention).
  final ValueChanged<bool>? onChanged;
  final String? label;

  /// Secondary line under the label, for the sentence that explains
  /// what ticking this actually does. Same chrome as the text inputs,
  /// which had it from the start while the boolean controls did not.
  final String? description;

  /// Error message shown below, which also turns the box red.
  final String? error;

  /// Neither checked nor unchecked: the "some of the children are
  /// selected" state a parent checkbox needs.
  ///
  /// Takes precedence over [value] for what is *drawn* — a dash rather
  /// than a tick — while [value] still decides what a tap reports, so
  /// the caller stays in charge of what indeterminate means for their
  /// tree.
  final bool indeterminate;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;

  static const Map<PlinthSize, double> _boxSizes = {
    PlinthSize.xs: 16,
    PlinthSize.sm: 20,
    PlinthSize.md: 24,
    PlinthSize.lg: 28,
    PlinthSize.xl: 32,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final baseColor = theme.shaded(colorKey, 6);
    final boxSize = _boxSizes[size]!;
    final resolvedRadius = theme.radius[radius ?? PlinthSize.xs]!;
    final enabled = onChanged != null;
    final hasError = error != null && error!.isNotEmpty;
    // Indeterminate reads as filled: an empty box would say "none of
    // them", which is the one thing this state exists to deny.
    final filled = value || indeterminate;

    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: filled
            ? (enabled ? baseColor : baseColor.withValues(alpha: 0.5))
            : theme.surface,
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(
          color: filled
              ? Colors.transparent
              : hasError
                  ? theme.roleShaded(PlinthRole.error, 6)
                  : theme.border,
          width: 1.5,
        ),
      ),
      child: filled
          ? Icon(
              indeterminate ? Icons.remove : Icons.check,
              size: boxSize * 0.7,
              color: theme.contrastingOn(baseColor),
            )
          : null,
    );

    return Semantics(
      // Mixed rather than checked when indeterminate: a screen reader
      // has a word for this state, and saying "checked" would be a
      // different claim than the dash makes.
      checked: indeterminate ? null : value,
      mixed: indeterminate ? true : null,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              box,
              if (label != null) ...[
                SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.8),
                // Flexible so a long label wraps instead of
                // overflowing when the row is width-constrained by its
                // parent — a consent checkbox in a narrow form is the
                // usual case.
                Flexible(
                  child: PlinthStack(
                    gap: PlinthSize.xs,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlinthText(label!, size: size),
                      if (description != null)
                        PlinthText(description!,
                            size: PlinthSize.xs,
                            color: theme.rampFor(PlinthRole.neutral)),
                      if (hasError)
                        PlinthText(error!,
                            size: PlinthSize.xs,
                            color: theme.rampFor(PlinthRole.error)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
