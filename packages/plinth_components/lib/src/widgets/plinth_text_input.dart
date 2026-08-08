import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A themeable text field matching Mantine's `TextInput`: a `label`,
/// optional `description`/`error` text, and border styling that
/// reacts to focus and error state — all resolved through the active
/// [PlinthTheme], following the same size/color pattern as
/// [PlinthButton].
///
/// ```dart
/// PlinthTextInput(
///   label: 'Email',
///   placeholder: 'you@example.com',
///   error: _emailError,
///   onChanged: (value) => setState(() => _email = value),
/// )
/// ```
class PlinthTextInput extends StatefulWidget {
  const PlinthTextInput({
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
    this.obscureText = false,
    this.enabled = true,
    this.leadingIcon,
  });

  final String? label;
  final String? description;
  final String? placeholder;

  /// Error message to show below the field. Non-null also switches
  /// the border to the theme's 'red' color, matching Mantine's
  /// error-state styling.
  final String? error;

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final PlinthSize size;

  /// Focus-state border color key into the theme palette. Ignored
  /// while [error] is set, since error styling takes precedence.
  final String? color;

  final PlinthSize? radius;
  final bool obscureText;
  final bool enabled;
  final Widget? leadingIcon;

  @override
  State<PlinthTextInput> createState() => _PlinthTextInputState();
}

class _PlinthTextInputState extends State<PlinthTextInput> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

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
      borderColor = theme.color('red', 6);
    } else if (_isFocused) {
      borderColor = theme.color(colorKey, 6);
    } else {
      borderColor = const Color(0xFFCED4DA);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          PlinthText(
            widget.label!,
            size: widget.size,
            weight: FontWeight.w600,
          ),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        if (widget.description != null) ...[
          PlinthText(
            widget.description!,
            size: PlinthSize.xs,
            color: 'gray',
          ),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(resolvedRadius),
            border: Border.all(
              color: borderColor,
              width: _isFocused || hasError ? 2 : 1,
            ),
            color: widget.enabled ? Colors.white : const Color(0xFFF1F3F5),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              if (widget.leadingIcon != null) ...[
                widget.leadingIcon!,
                SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  obscureText: widget.obscureText,
                  enabled: widget.enabled,
                  style: TextStyle(fontSize: fontSize),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: verticalPadding),
                  ),
                ),
              ),
            ],
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
