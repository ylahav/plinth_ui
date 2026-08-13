import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_textarea.dart';

/// A textarea that validates JSON, matching Mantine's `JsonInput`.
///
/// Validation runs when the field loses focus, not on every keystroke.
/// Half-typed JSON is invalid by definition — an object is broken from
/// the opening brace until the closing one — so validating as you type
/// means showing an error for the entire time somebody is writing.
///
/// [formatOnBlur] pretty-prints valid JSON when focus leaves, which is
/// the moment it's welcome and no other: reformatting mid-edit moves
/// the caret out from under whoever is typing.
///
/// ```dart
/// PlinthJsonInput(
///   label: 'Payload',
///   value: _payload,
///   onChanged: (v) => setState(() => _payload = v),
/// )
/// ```
class PlinthJsonInput extends StatefulWidget {
  const PlinthJsonInput({
    super.key,
    this.value,
    this.onChanged,
    this.onValidChanged,
    this.label,
    this.description,
    this.placeholder,
    this.error,
    this.formatOnBlur = true,
    this.validationMessage = 'Invalid JSON',
    this.minLines = 4,
    this.maxLines = 10,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.enabled = true,
  });

  final String? value;
  final ValueChanged<String>? onChanged;

  /// Reports whether the current text parses, so a form can disable
  /// its submit button without parsing the string a second time.
  final ValueChanged<bool>? onValidChanged;

  final String? label;
  final String? description;
  final String? placeholder;

  /// Your own error, shown instead of the parse error. Use it for
  /// schema problems the parser can't see.
  final String? error;

  final bool formatOnBlur;
  final String validationMessage;

  final int minLines;
  final int maxLines;

  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool enabled;

  /// Whether [text] parses as JSON. Exposed because a form usually has
  /// to ask the same question before submitting.
  static bool isValid(String text) {
    if (text.trim().isEmpty) return true;
    try {
      jsonDecode(text);
      return true;
    } on FormatException {
      return false;
    }
  }

  /// Pretty-prints [text] with a two-space indent, or returns it
  /// unchanged when it doesn't parse.
  static String format(String text) {
    if (text.trim().isEmpty) return text;
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(text));
    } on FormatException {
      return text;
    }
  }

  @override
  State<PlinthJsonInput> createState() => _PlinthJsonInputState();
}

class _PlinthJsonInputState extends State<PlinthJsonInput> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value ?? '');

  String? _parseError;

  @override
  void didUpdateWidget(covariant PlinthJsonInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != _controller.text) {
      _controller.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged(bool hasFocus) {
    if (hasFocus) {
      // Editing again: drop the error rather than leaving a red field
      // while it's being fixed.
      if (_parseError != null) setState(() => _parseError = null);
      return;
    }
    _validate();
  }

  void _validate() {
    final text = _controller.text;
    final valid = PlinthJsonInput.isValid(text);

    if (valid && widget.formatOnBlur) {
      final formatted = PlinthJsonInput.format(text);
      if (formatted != text) {
        _controller.text = formatted;
        widget.onChanged?.call(formatted);
      }
    }

    widget.onValidChanged?.call(valid);
    setState(() => _parseError = valid ? null : widget.validationMessage);
  }

  @override
  Widget build(BuildContext context) {
    // A Focus ancestor reports its descendants' focus, so blur is
    // detectable without PlinthTextarea having to expose a node.
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _onFocusChanged,
      child: PlinthTextarea(
        label: widget.label,
        description: widget.description,
        placeholder: widget.placeholder ?? '{ }',
        // The caller's error wins: a schema problem is more specific
        // than "this isn't JSON", and showing both is noise.
        error: widget.error ?? _parseError,
        controller: _controller,
        onChanged: widget.onChanged,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        size: widget.size,
        color: widget.color,
        radius: widget.radius,
        enabled: widget.enabled,
      ),
    );
  }
}
