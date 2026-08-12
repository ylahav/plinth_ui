import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_close_button.dart';
import 'plinth_text.dart';

/// Free-text entry that turns what you type into removable chips,
/// matching Mantine's `TagsInput`.
///
/// [PlinthMultiSelect] is the fixed-options equivalent — the user picks
/// from a list you supply. This is the case where they invent the
/// values: keywords on a post, recipients on a message, skills on a
/// profile.
///
/// Enter or a comma commits the current text as a tag. Backspace in an
/// empty field removes the last one, which is the behaviour people
/// expect from every tag field they have used and is unreasonably
/// annoying to be without.
///
/// ```dart
/// PlinthTagsInput(
///   label: 'Skills',
///   value: _skills,
///   onChanged: (tags) => setState(() => _skills = tags),
/// )
/// ```
class PlinthTagsInput extends StatefulWidget {
  const PlinthTagsInput({
    super.key,
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
    this.maxTags,
    this.allowDuplicates = false,
  });

  final List<String> value;
  final ValueChanged<List<String>> onChanged;

  final String? label;
  final String? description;
  final String? placeholder;
  final String? error;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool enabled;

  /// Stops accepting new tags once reached. Null for no limit.
  final int? maxTags;

  /// Duplicates are rejected by default — a tag list is a set in
  /// everything but type, and two identical chips give the user no way
  /// to tell which is which.
  final bool allowDuplicates;

  @override
  State<PlinthTagsInput> createState() => _PlinthTagsInputState();
}

class _PlinthTagsInputState extends State<PlinthTagsInput> {
  final _controller = TextEditingController();
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
    _controller.dispose();
    super.dispose();
  }

  bool get _atLimit =>
      widget.maxTags != null && widget.value.length >= widget.maxTags!;

  void _commit(String raw) {
    final tag = raw.trim();
    _controller.clear();
    if (tag.isEmpty || _atLimit) return;
    if (!widget.allowDuplicates && widget.value.contains(tag)) return;
    widget.onChanged([...widget.value, tag]);
  }

  void _remove(String tag) => widget.onChanged([...widget.value]..remove(tag));

  void _onChanged(String text) {
    // A comma commits rather than being typed, so pasting
    // "dart, flutter" produces two tags instead of one odd-looking one.
    if (text.contains(',')) {
      for (final part in text.split(',')) {
        _commit(part);
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty &&
        widget.value.isNotEmpty) {
      _remove(widget.value.last);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final colorKey = widget.color ?? theme.primaryColor;
    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;
    final fontSize = theme.fontSizes[widget.size]!;

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
        GestureDetector(
          // Tapping anywhere in the field focuses the input, matching
          // how a native text field behaves across its whole box.
          onTap: widget.enabled ? _focusNode.requestFocus : null,
          child: Container(
            constraints:
                BoxConstraints(minHeight: theme.spacing[widget.size]! * 2.2),
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing[PlinthSize.xs]!,
              vertical: theme.spacing[PlinthSize.xs]! * 0.6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: Border.all(
                color: borderColor,
                width: _isFocused || hasError ? 2 : 1,
              ),
              color: widget.enabled ? theme.surface : theme.surfaceMuted,
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final tag in widget.value)
                  _TagChip(
                    label: tag,
                    fontSize: fontSize - 2,
                    background: theme.shaded(colorKey, 1),
                    foreground: theme.readableOn(
                      colorKey,
                      theme.shaded(colorKey, 1),
                    ),
                    onRemove: widget.enabled ? () => _remove(tag) : null,
                  ),
                // A bounded width so the field wraps with its chips
                // rather than the input demanding a whole row.
                SizedBox(
                  width: 120,
                  child: Focus(
                    onKeyEvent: _onKey,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled && !_atLimit,
                      style: TextStyle(fontSize: fontSize),
                      onChanged: _onChanged,
                      onSubmitted: _commit,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: widget.value.isEmpty
                            ? widget.placeholder
                            : _atLimit
                                ? null
                                : '',
                        hintStyle: TextStyle(
                          color: theme.textMuted,
                          fontSize: fontSize,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                ),
              ],
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

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.fontSize,
    required this.background,
    required this.foreground,
    required this.onRemove,
  });

  final String label;
  final double fontSize;
  final Color background;
  final Color foreground;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 2, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, color: foreground)),
          if (onRemove != null)
            PlinthCloseButton(
              size: PlinthSize.xs,
              onPressed: onRemove,
              semanticLabel: 'Remove $label',
            ),
        ],
      ),
    );
  }
}
