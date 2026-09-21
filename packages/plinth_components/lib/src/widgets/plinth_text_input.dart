import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'field_chrome.dart';

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
    this.trailing,
    this.inputFormatters,
    this.keyboardType,
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

  /// The far end of the field, inside the border — a clear button, a
  /// unit, a visibility toggle.
  ///
  /// Outside the `TextField` rather than in its `decoration.suffixIcon`
  /// so that a button here has its own hit area: a suffix icon sits
  /// inside the field's, and a tap meant for the button places the
  /// caret instead.
  final Widget? trailing;

  /// Passed straight through to the underlying [TextField]. Added for
  /// [PlinthMaskInput], which is nothing but a formatter over this
  /// field — reproducing the chrome to attach one would have been the
  /// worse trade.
  final List<TextInputFormatter>? inputFormatters;

  final TextInputType? keyboardType;

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
    final hasError = plinthHasError(widget.error);
    final colorKey = widget.color ?? theme.primaryColor;

    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;
    final fontSize = theme.fontSizes[widget.size]!;
    final verticalPadding = theme.spacing[widget.size]! * 0.5;
    final horizontalPadding = theme.spacing[widget.size]!;

    final borderColor = plinthFieldBorderColor(
      theme,
      hasError: hasError,
      focused: _isFocused,
      colorKey: colorKey,
    );

    return PlinthFieldChrome(
      label: widget.label,
      description: widget.description,
      error: widget.error,
      size: widget.size,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(resolvedRadius),
          border: Border.all(
            color: borderColor,
            width: plinthFieldBorderWidth(
              theme,
              hasError: hasError,
              focused: _isFocused,
            ),
          ),
          color: widget.enabled ? theme.surface : theme.surfaceMuted,
        ),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            if (widget.leadingIcon != null) ...[
              widget.leadingIcon!,
              SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
            ],
            Expanded(
              child: Semantics(
                label: widget.label,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  obscureText: widget.obscureText,
                  enabled: widget.enabled,
                  inputFormatters: widget.inputFormatters,
                  keyboardType: widget.keyboardType,
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
            ),
            if (widget.trailing != null) ...[
              SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
