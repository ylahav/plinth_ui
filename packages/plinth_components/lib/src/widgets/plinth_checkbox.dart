import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

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
    this.size = PlinthSize.md,
    this.color,
    this.radius,
  });

  final bool value;

  /// Null disables the checkbox (matches Flutter's `Checkbox` convention).
  final ValueChanged<bool>? onChanged;
  final String? label;
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
    final baseColor = theme.color(colorKey, 6);
    final boxSize = _boxSizes[size]!;
    final resolvedRadius = theme.radius[radius ?? PlinthSize.xs]!;
    final enabled = onChanged != null;

    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: value
            ? (enabled ? baseColor : baseColor.withValues(alpha: 0.5))
            : theme.surface,
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(
          color: value ? Colors.transparent : theme.border,
          width: 1.5,
        ),
      ),
      child: value
          ? Icon(Icons.check, size: boxSize * 0.7, color: theme.onFilled)
          : null,
    );

    return Semantics(
      checked: value,
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
                Flexible(child: PlinthText(label!, size: size)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
