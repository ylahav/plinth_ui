import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A multi-line text field matching Mantine's `Textarea`. Shares
/// [PlinthTextInput]'s label/description/error chrome and
/// focus/error border styling.
///
/// ```dart
/// PlinthTextarea(
///   label: 'Bio',
///   placeholder: 'Tell us about yourself',
///   minLines: 3,
///   maxLines: 6,
///   onChanged: (value) => setState(() => _bio = value),
/// )
/// ```
class PlinthTextarea extends StatefulWidget {
  const PlinthTextarea({
    super.key,
    this.label,
    this.description,
    this.placeholder,
    this.error,
    this.controller,
    this.onChanged,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.enabled = true,
    this.minLines = 3,
    this.maxLines = 6,
  });

  final String? label;
  final String? description;
  final String? placeholder;
  final String? error;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool enabled;

  /// The field starts at this many visible lines tall.
  final int minLines;

  /// The field grows up to this many lines before scrolling
  /// internally rather than growing further.
  final int maxLines;

  @override
  State<PlinthTextarea> createState() => _PlinthTextareaState();
}

class _PlinthTextareaState extends State<PlinthTextarea> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() => _isFocused = _focusNode.hasFocus);

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final colorKey = widget.color ?? theme.primaryColor;

    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;
    final fontSize = theme.fontSizes[widget.size]!;
    final verticalPadding = theme.spacing[widget.size]! * 0.5;
    final horizontalPadding = theme.spacing[widget.size]!;

    final Color borderColor;
    if (hasError) {
      borderColor = theme.shaded('red', 6);
    } else if (_isFocused) {
      borderColor = theme.shaded(colorKey, 6);
    } else {
      borderColor = theme.border;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          PlinthText(widget.label!, size: widget.size, weight: FontWeight.w600),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        if (widget.description != null) ...[
          PlinthText(widget.description!, size: PlinthSize.xs, color: 'gray'),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(resolvedRadius),
            border: Border.all(
              color: borderColor,
              width: _isFocused || hasError ? 2 : 1,
            ),
            color: widget.enabled ? theme.surface : theme.surfaceMuted,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            style: TextStyle(fontSize: fontSize),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
          PlinthText(widget.error!, size: PlinthSize.xs, color: 'red'),
        ],
      ],
    );
  }
}
