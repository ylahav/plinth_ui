import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'field_chrome.dart';

/// A password field matching Mantine's `PasswordInput`: shares
/// [PlinthTextInput]'s label/description/error chrome, with a
/// show/hide visibility toggle instead of a plain `obscureText` flag.
///
/// ```dart
/// PlinthPasswordInput(
///   label: 'Password',
///   onChanged: (value) => setState(() => _password = value),
/// )
/// ```
class PlinthPasswordInput extends StatefulWidget {
  const PlinthPasswordInput({
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
    this.loading = false,
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

  /// Shows a spinner at the far end while something this field depends
  /// on is in flight.
  ///
  /// The field stays enabled and focusable: it is busy, not
  /// unavailable. A field that went dead mid-request would eat the
  /// keystroke that arrived during it.
  final bool loading;

  @override
  State<PlinthPasswordInput> createState() => _PlinthPasswordInputState();
}

class _PlinthPasswordInputState extends State<PlinthPasswordInput> {
  final _focusNode = FocusNode();
  bool _isFocused = false;
  bool _visible = false;

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
              width: plinthFieldBorderWidth(theme,
                  hasError: hasError, focused: _isFocused),
            ),
            color: widget.enabled ? theme.surface : theme.surfaceMuted,
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  label: widget.label,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    obscureText: !_visible,
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
              ),
              if (widget.loading) ...[
                PlinthFieldLoader(size: widget.size),
                SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
              ],
              Semantics(
                button: true,
                // Icon-only, so without this a screen reader reaches the
                // control and cannot say what it does. The label states
                // the action rather than the state, which is what a
                // button should announce.
                label: _visible ? 'Hide password' : 'Show password',
                child: InkWell(
                  onTap: widget.enabled
                      ? () => setState(() => _visible = !_visible)
                      : null,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _visible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: theme.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
