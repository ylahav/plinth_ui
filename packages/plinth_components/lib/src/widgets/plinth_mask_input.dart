import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text_input.dart';

/// A text field that formats as you type, matching Mantine's
/// `MaskInput`.
///
/// The mask is a literal template: `#` stands for a digit, `A` for a
/// letter, `*` for either, and every other character is punctuation
/// the field inserts for you.
///
/// ```dart
/// PlinthMaskInput(
///   mask: '(###) ###-####',
///   label: 'Phone',
///   onChanged: (v) => setState(() => _phone = v),
/// )
/// ```
///
/// [onChanged] reports the masked text as shown. [unmask] the value
/// yourself when you need the raw characters — a phone number is
/// usually stored without its brackets, and the widget shouldn't
/// decide that for you.
class PlinthMaskInput extends StatefulWidget {
  const PlinthMaskInput({
    super.key,
    required this.mask,
    this.value,
    this.onChanged,
    this.label,
    this.description,
    this.placeholder,
    this.error,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.enabled = true,
    this.leadingIcon,
  });

  /// `#` = digit, `A` = letter, `*` = either. Anything else is a
  /// literal the field fills in.
  final String mask;

  final String? value;
  final ValueChanged<String>? onChanged;

  final String? label;
  final String? description;
  final String? placeholder;
  final String? error;

  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool enabled;
  final Widget? leadingIcon;

  /// Strips a masked string back to the characters the user actually
  /// typed, dropping the literals the mask inserted.
  static String unmask(String masked, String mask) {
    final out = StringBuffer();
    for (var i = 0; i < masked.length && i < mask.length; i++) {
      if (_isPlaceholder(mask[i])) out.write(masked[i]);
    }
    return out.toString();
  }

  static bool _isPlaceholder(String c) => c == '#' || c == 'A' || c == '*';

  @override
  State<PlinthMaskInput> createState() => _PlinthMaskInputState();
}

class _PlinthMaskInputState extends State<PlinthMaskInput> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value ?? '');

  @override
  void didUpdateWidget(covariant PlinthMaskInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only when the caller genuinely changed it — rewriting on every
    // rebuild would fight the caret mid-entry.
    if (widget.value != null && widget.value != _controller.text) {
      _controller.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlinthTextInput(
      label: widget.label,
      description: widget.description,
      placeholder: widget.placeholder ?? widget.mask,
      error: widget.error,
      controller: _controller,
      onChanged: widget.onChanged,
      size: widget.size,
      color: widget.color,
      radius: widget.radius,
      enabled: widget.enabled,
      leadingIcon: widget.leadingIcon,
      // Everything else here is PlinthTextInput's. A mask is a
      // formatter, not a different field.
      inputFormatters: [_MaskFormatter(widget.mask)],
    );
  }
}

/// Rebuilds the whole value on every edit rather than patching it.
///
/// Patching is where masked inputs usually go wrong: deleting a
/// character in the middle, or pasting, leaves the literals in the
/// wrong places. Stripping back to the typed characters and re-laying
/// the mask over them is always consistent, at the cost of doing a
/// little more work per keystroke than is strictly needed.
class _MaskFormatter extends TextInputFormatter {
  _MaskFormatter(this.mask);

  final String mask;

  static bool _matches(String maskChar, String input) {
    switch (maskChar) {
      case '#':
        return RegExp(r'\d').hasMatch(input);
      case 'A':
        return RegExp('[A-Za-z]').hasMatch(input);
      case '*':
        return RegExp('[A-Za-z0-9]').hasMatch(input);
      default:
        return false;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // The characters the user has actually supplied, with every
    // literal the mask owns removed.
    final typed = <String>[];
    for (var i = 0; i < newValue.text.length; i++) {
      final c = newValue.text[i];
      if (i < mask.length && !PlinthMaskInput._isPlaceholder(mask[i])) {
        // A literal in its own position is the mask's, not the user's,
        // unless the user typed something else there.
        if (c == mask[i]) continue;
      }
      typed.add(c);
    }

    final out = StringBuffer();
    var next = 0;

    for (var i = 0; i < mask.length && next < typed.length; i++) {
      final maskChar = mask[i];
      if (PlinthMaskInput._isPlaceholder(maskChar)) {
        // Skip anything that can't go here rather than rejecting the
        // whole edit — a stray space in a pasted phone number
        // shouldn't discard the paste.
        while (next < typed.length && !_matches(maskChar, typed[next])) {
          next++;
        }
        if (next >= typed.length) break;
        out.write(typed[next]);
        next++;
      } else {
        out.write(maskChar);
      }
    }

    final text = out.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
