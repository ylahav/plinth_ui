import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'field_chrome.dart';

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
    this.loading = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.inputFormatters,
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

  /// The field starts at this many visible lines tall.
  final int minLines;

  /// The field grows up to this many lines before scrolling
  /// internally rather than growing further.
  final int maxLines;

  /// Formatters applied as the value is committed — a length limit, a
  /// character whitelist.
  ///
  /// `PlinthTextInput` has had this since it was written; this field
  /// not having it was an oversight rather than a decision, and it had
  /// a cost. `PlinthCharacterLimitField` in `plinth_blocks` enforced
  /// its limit by truncating in a controller listener, which runs
  /// *after* the value is committed and corrects it, where a formatter
  /// runs before and prevents it.
  final List<TextInputFormatter>? inputFormatters;

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
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Stack(
            children: [
              Semantics(
                label: widget.label,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  enabled: widget.enabled,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  inputFormatters: widget.inputFormatters,
                  style: TextStyle(fontSize: fontSize),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // The trailing corner rather than a row beside the text:
              // this box is several lines tall, and a spinner sharing a
              // row with the field would either sit beside the first
              // line or stretch the box to centre itself against all of
              // them. The Stack keeps it out of the text's way without
              // the box changing size when loading starts.
              if (widget.loading)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: PlinthFieldLoader(size: widget.size),
                ),
            ],
          ),
        ));
  }
}
