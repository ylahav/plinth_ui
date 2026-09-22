/// A text field with a hard limit, and a counter that says so before
/// the limit is reached rather than after.
library;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A field that counts down to a limit it will not let you cross.
///
/// The counter is the whole point, and the interesting decisions are
/// about when it speaks.
///
/// **It does not announce on every keystroke.** A live region on a
/// character counter reads a number after every letter, which makes the
/// field unusable with a screen reader — the same trap the loading
/// spinner avoids. It announces **once**, when the remaining count
/// first crosses [warnAt], which is the moment the information starts
/// mattering.
///
/// **The limit is enforced, not merely reported.** A counter that goes
/// red while the field keeps accepting text is a counter that lied:
/// the form will reject the value later, somewhere else, in different
/// words.
///
/// That enforcement happens here rather than through a
/// `LengthLimitingTextInputFormatter`, because `PlinthTextarea` does
/// not take `inputFormatters` — `PlinthTextInput` does, and the two
/// disagreeing is a real gap in `plinth_components` rather than a
/// decision. When it gains them, this should become a formatter and
/// the truncation below should go: a formatter runs before the value
/// is committed, where this runs after and corrects it.
class PlinthCharacterLimitField extends StatefulWidget {
  const PlinthCharacterLimitField({
    super.key,
    required this.maxLength,
    this.controller,
    this.onChanged,
    this.label,
    this.description,
    this.placeholder,
    this.minLines = 3,
    this.maxLines = 6,
    this.warnAt = 20,
    this.warnColor = 'yellow',
    this.overColor = 'red',
    this.size = PlinthSize.md,
    this.width,
  });

  final int maxLength;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? description;
  final String? placeholder;
  final int minLines;
  final int maxLines;

  /// How many characters remain when the counter starts warning — and
  /// when the one announcement happens.
  final int warnAt;

  final String warnColor;
  final String overColor;
  final PlinthSize size;
  final double? width;

  @override
  State<PlinthCharacterLimitField> createState() =>
      _PlinthCharacterLimitFieldState();
}

class _PlinthCharacterLimitFieldState extends State<PlinthCharacterLimitField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  /// Whether the crossing has already been announced, so it happens
  /// once per crossing rather than once per keystroke after it.
  var _warned = false;

  /// Guards the listener against the edit it makes itself.
  var _truncating = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  int get _remaining => widget.maxLength - _controller.text.characters.length;

  void _onChanged() {
    if (_truncating) return;

    // Paste is the case that matters: typing cannot exceed the limit by
    // more than one character, but pasting an article into a 280-limit
    // field can exceed it by thousands.
    final text = _controller.text;
    if (text.characters.length > widget.maxLength) {
      final kept = text.characters.take(widget.maxLength).toString();
      _truncating = true;
      _controller.value = TextEditingValue(
        text: kept,
        // Caret at the end of what survived, not wherever it was in
        // text that no longer exists.
        selection: TextSelection.collapsed(offset: kept.length),
      );
      _truncating = false;
    }

    final remaining = _remaining;

    if (remaining <= widget.warnAt && !_warned) {
      _warned = true;
      PlinthAnnounce.say(context, '$remaining characters remaining');
    } else if (remaining > widget.warnAt && _warned) {
      // Re-arm, so deleting back under the threshold and typing up to
      // it again says so a second time. The user crossed it twice.
      _warned = false;
    }

    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final remaining = _remaining;
    final warning = remaining <= widget.warnAt;

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          PlinthTextarea(
            label: widget.label,
            description: widget.description,
            placeholder: widget.placeholder,
            controller: _controller,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            size: widget.size,
          ),
          SizedBox(height: theme.space(1)),
          Align(
            alignment: AlignmentDirectional.centerEnd,

            // Not a live region: this changes on every keystroke, and
            // reading a number after each letter would make the field
            // unusable. The crossing is announced once instead.
            child: ExcludeSemantics(
              child: PlinthText(
                '$remaining',
                size: PlinthSize.xs,
                color: warning
                    ? widget.warnColor
                    : theme.rampFor(PlinthRole.neutral),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
