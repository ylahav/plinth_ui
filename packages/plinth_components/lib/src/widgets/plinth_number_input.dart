import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A numeric input matching Mantine's `NumberInput`: a text field
/// restricted to numbers, with increment/decrement buttons, sharing
/// [PlinthTextInput]'s label/description/error chrome and focus/error
/// border styling.
///
/// ```dart
/// PlinthNumberInput(
///   label: 'Quantity',
///   value: _qty,
///   min: 1,
///   max: 99,
///   onChanged: (v) => setState(() => _qty = v),
/// )
/// ```
class PlinthNumberInput extends StatefulWidget {
  const PlinthNumberInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.label,
    this.description,
    this.error,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.enabled = true,
  });

  final num value;
  final ValueChanged<num>? onChanged;
  final num? min;
  final num? max;
  final num step;

  final String? label;
  final String? description;
  final String? error;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool enabled;

  @override
  State<PlinthNumberInput> createState() => _PlinthNumberInputState();
}

class _PlinthNumberInputState extends State<PlinthNumberInput> {
  // `late` is required, not just stylistic: a plain field initializer
  // runs during State's constructor, before the framework assigns
  // `widget` — accessing widget.value there would fail. `late` defers
  // evaluation to first access (build()), by which point `widget` is
  // safely available. Same reasoning as PlinthAccordion's _openValues.
  late final TextEditingController _controller =
      TextEditingController(text: _format(widget.value));
  final _focusNode = FocusNode();
  bool _isFocused = false;

  String _format(num value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  void initState() {
    super.initState();
    _focusNode
        .addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void didUpdateWidget(covariant PlinthNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the text field in sync if `value` changes from outside
    // (e.g. the +/- buttons here, or an external reset) without
    // fighting the user's in-progress typing while focused.
    if (!_isFocused && oldWidget.value != widget.value) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  num _clamp(num value) {
    var result = value;
    if (widget.min != null && result < widget.min!) result = widget.min!;
    if (widget.max != null && result > widget.max!) result = widget.max!;
    return result;
  }

  void _step(num delta) {
    final next = _clamp(widget.value + delta);
    _controller.text = _format(next);
    widget.onChanged?.call(next);
  }

  void _onTextChanged(String text) {
    final parsed = num.tryParse(text);
    if (parsed != null) {
      widget.onChanged?.call(_clamp(parsed));
    }
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
      borderColor = theme.roleShaded(PlinthRole.error, 6);
    } else if (_isFocused) {
      borderColor = theme.shaded(colorKey, 6);
    } else {
      borderColor = theme.border;
    }

    final atMin = widget.min != null && widget.value <= widget.min!;
    final atMax = widget.max != null && widget.value >= widget.max!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          PlinthText(widget.label!, size: widget.size, weight: FontWeight.w600),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        if (widget.description != null) ...[
          PlinthText(widget.description!,
              size: PlinthSize.xs, color: theme.rampFor(PlinthRole.neutral)),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(resolvedRadius),
            border: Border.all(
                color: borderColor, width: _isFocused || hasError ? 2 : 1),
            color: widget.enabled ? theme.surface : theme.surfaceMuted,
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  label: widget.label,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*')),
                    ],
                    onChanged: _onTextChanged,
                    style: TextStyle(fontSize: fontSize),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: verticalPadding),
                    ),
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.remove,
                enabled: widget.enabled && !atMin,
                onTap: () => _step(-widget.step),
              ),
              _StepButton(
                icon: Icons.add,
                enabled: widget.enabled && !atMax,
                onTap: () => _step(widget.step),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
          PlinthText(widget.error!,
              size: PlinthSize.xs, color: theme.rampFor(PlinthRole.error)),
        ],
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton(
      {required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? theme.textMuted : theme.textDisabled,
        ),
      ),
    );
  }
}
