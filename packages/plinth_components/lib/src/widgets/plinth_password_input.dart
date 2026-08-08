import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

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
            color: widget.enabled ? Colors.white : const Color(0xFFF1F3F5),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Expanded(
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
              InkWell(
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
                    color: Colors.black54,
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
