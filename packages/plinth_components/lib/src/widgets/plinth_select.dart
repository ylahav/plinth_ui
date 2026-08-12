import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A single option for [PlinthSelect].
class PlinthSelectOption<T> {
  const PlinthSelectOption(this.value, this.label);

  final T value;
  final String label;
}

/// A themeable dropdown select matching Mantine's `Select`: shares
/// [PlinthTextInput]'s label/description/error chrome, but renders a
/// tappable field that opens a menu instead of a text field.
///
/// ```dart
/// PlinthSelect<String>(
///   label: 'Country',
///   placeholder: 'Choose a country',
///   value: _country,
///   options: const [
///     PlinthSelectOption('us', 'United States'),
///     PlinthSelectOption('il', 'Israel'),
///   ],
///   onChanged: (v) => setState(() => _country = v),
/// )
/// ```
class PlinthSelect<T> extends StatelessWidget {
  const PlinthSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.placeholder,
    this.error,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.enabled = true,
  });

  final List<PlinthSelectOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? description;
  final String? placeholder;
  final String? error;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final hasError = error != null && error!.isNotEmpty;
    final colorKey = color ?? theme.primaryColor;

    final resolvedRadius = theme.radius[radius ?? theme.defaultRadius]!;
    final fontSize = theme.fontSizes[size]!;
    final verticalPadding = theme.spacing[size]! * 0.5;
    final horizontalPadding = theme.spacing[size]!;

    final borderColor = hasError ? theme.shaded('red', 6) : theme.border;

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
        Theme(
          // Strip Material's default dropdown underline/theming so
          // PlinthSelect can own its own border like PlinthTextInput.
          data: Theme.of(context).copyWith(
            highlightColor: theme.shaded(colorKey, 1),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: Border.all(color: borderColor, width: hasError ? 2 : 1),
              color: enabled ? theme.surface : theme.surfaceMuted,
            ),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: value,
                hint: placeholder != null
                    ? Text(
                        placeholder!,
                        style:
                            TextStyle(fontSize: fontSize, color: Colors.grey),
                      )
                    : null,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                onChanged: enabled ? onChanged : null,
                items: [
                  for (final option in options)
                    DropdownMenuItem<T>(
                      value: option.value,
                      child: Text(option.label,
                          style: TextStyle(fontSize: fontSize)),
                    ),
                ],
                selectedItemBuilder: (context) => [
                  for (final option in options)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: verticalPadding),
                      child: Text(
                        option.label,
                        style: TextStyle(fontSize: fontSize),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
          PlinthText(error!, size: PlinthSize.xs, color: 'red'),
        ],
      ],
    );
  }
}
