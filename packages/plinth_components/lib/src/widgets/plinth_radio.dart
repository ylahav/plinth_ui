import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A single themeable radio button, matching Mantine's `Radio`. Used
/// standalone or, typically, inside a [PlinthRadioGroup] which wires
/// up the shared selected value and change callback for you.
///
/// ```dart
/// PlinthRadioGroup<String>(
///   value: _plan,
///   onChanged: (v) => setState(() => _plan = v),
///   label: 'Plan',
///   options: const [
///     PlinthRadioOption('free', 'Free'),
///     PlinthRadioOption('pro', 'Pro'),
///   ],
/// )
/// ```
class PlinthRadio<T> extends StatelessWidget {
  const PlinthRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.size = PlinthSize.md,
    this.color,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final PlinthSize size;
  final String? color;

  static const Map<PlinthSize, double> _dotSizes = {
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
    final selected = value == groupValue;
    final dotSize = _dotSizes[size]!;
    final enabled = onChanged != null;

    final ring = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.surface,
        border: Border.all(
          color: selected ? baseColor : theme.border,
          width: selected ? dotSize * 0.28 : 1.5,
        ),
      ),
    );

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? () => onChanged!(value) : null,
        borderRadius: BorderRadius.circular(dotSize),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ring,
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

/// A single selectable option for [PlinthRadioGroup].
class PlinthRadioOption<T> {
  const PlinthRadioOption(this.value, this.label);

  final T value;
  final String label;
}

/// Renders a labeled, vertically-stacked set of [PlinthRadio]s sharing
/// one selected value — the equivalent of Mantine's `Radio.Group`.
/// Handles wiring `groupValue`/`onChanged` to each option so you don't
/// repeat that per radio.
class PlinthRadioGroup<T> extends StatelessWidget {
  const PlinthRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.size = PlinthSize.md,
    this.color,
  });

  final List<PlinthRadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? label;
  final String? description;
  final PlinthSize size;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          PlinthText(label!, size: size, weight: FontWeight.w600),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        if (description != null) ...[
          PlinthText(description!, size: PlinthSize.xs, color: 'gray'),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        for (final option in options)
          PlinthRadio<T>(
            value: option.value,
            groupValue: value,
            onChanged: onChanged,
            label: option.label,
            size: size,
            color: color,
          ),
      ],
    );
  }
}
