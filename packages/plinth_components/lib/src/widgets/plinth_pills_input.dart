import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A field that holds [PlinthPill]s, matching Mantine's `PillsInput`.
///
/// The chrome, not the behaviour: the label, the bordered box that
/// wraps its contents onto new lines, the focus and error borders, the
/// message underneath. What goes inside is yours — pills, a text
/// field, a placeholder, a count.
///
/// [PlinthMultiSelect] and [PlinthTagsInput] are the two finished
/// components built on this shape, and either is the better answer
/// when it fits. Reach for this when neither does: pills whose values
/// come from somewhere else entirely — a file picker, a contact list,
/// a query builder — where the field is the only part worth reusing.
///
/// It is deliberately presentational. Focus is passed in rather than
/// tracked, because the thing that owns the input inside also owns its
/// focus node, and two widgets disagreeing about focus is worse than
/// one prop.
///
/// ```dart
/// PlinthPillsInput(
///   label: 'Recipients',
///   focused: _focusNode.hasFocus,
///   children: [
///     for (final to in _recipients)
///       PlinthPill(to, onRemove: () => _remove(to)),
///     SizedBox(width: 120, child: TextField(focusNode: _focusNode)),
///   ],
/// )
/// ```
class PlinthPillsInput extends StatelessWidget {
  const PlinthPillsInput({
    super.key,
    required this.children,
    this.label,
    this.description,
    this.error,
    this.placeholder,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.enabled = true,
    this.focused = false,
    this.onTap,
  });

  /// Whatever the field holds. Usually [PlinthPill]s and an input.
  final List<Widget> children;

  final String? label;
  final String? description;

  /// Non-null switches the border to red, taking precedence over
  /// [focused] — the same order [PlinthTextInput] uses.
  final String? error;

  /// Shown when [children] is empty, so an empty field isn't a bare
  /// box with no hint of what belongs in it.
  final String? placeholder;

  final PlinthSize size;

  /// Focus-state border colour key. Ignored while [error] is set.
  final String? color;

  final PlinthSize? radius;
  final bool enabled;

  /// Whether the thing inside currently has focus. Passed in rather
  /// than tracked here — see the class doc.
  final bool focused;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final hasError = error != null && error!.isNotEmpty;
    final colorKey = color ?? theme.primaryColor;

    final Color borderColor;
    if (hasError) {
      borderColor = theme.shaded('red', 6);
    } else if (focused) {
      borderColor = theme.shaded(colorKey, 6);
    } else {
      borderColor = theme.border;
    }

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
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing[PlinthSize.xs]!,
              vertical: theme.spacing[PlinthSize.xs]! * 0.6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  theme.radius[radius ?? theme.defaultRadius]!),
              border: Border.all(
                color: borderColor,
                width: focused || hasError ? 2 : 1,
              ),
              color: enabled ? theme.surface : theme.surfaceMuted,
            ),
            child: children.isEmpty && placeholder != null
                ? PlinthText(placeholder!, size: size, color: 'gray')
                : Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: children,
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
