import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A segmented code/PIN input matching Mantine's `PinInput`: one box
/// per character, auto-advancing focus as each digit is typed and
/// auto-retreating on backspace from an empty box.
///
/// ```dart
/// PlinthPinInput(
///   length: 6,
///   value: _code,
///   onChanged: (v) => setState(() => _code = v),
///   onCompleted: (v) => _verify(v),
/// )
/// ```
class PlinthPinInput extends StatefulWidget {
  const PlinthPinInput({
    super.key,
    this.length = 4,
    this.value = '',
    this.onChanged,
    this.onCompleted,
    this.obscureText = false,
    this.numbersOnly = true,
    this.size = PlinthSize.md,
    this.color,
    this.error = false,
    this.statusText,
    this.radius,
  });

  final int length;
  final String value;
  final ValueChanged<String>? onChanged;

  /// Fires once when the input reaches [length] characters.
  final ValueChanged<String>? onCompleted;

  final bool obscureText;

  /// Restricts input to digits when true (the common PIN/OTP case).
  final bool numbersOnly;

  final PlinthSize size;
  final String? color;

  /// Styles the boxes as invalid. Colour only — pair it with
  /// [statusText] so the state has a reading as well as a look.
  final bool error;

  /// The outcome of the code, shown under the boxes and announced when
  /// it appears: 'Incorrect code', 'Code verified'.
  ///
  /// Without this the result of entering the last digit was carried
  /// entirely by [error] recolouring the border, which says nothing to
  /// a screen reader — the boxes are full, focus has not moved, and
  /// nothing is spoken — and nothing to anyone who cannot separate the
  /// two border colours either.
  final String? statusText;

  /// Overrides the theme's default radius for this one instance.
  final PlinthSize? radius;

  @override
  State<PlinthPinInput> createState() => _PlinthPinInputState();
}

class _PlinthPinInputState extends State<PlinthPinInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    _controllers = List.generate(
      widget.length,
      (i) => TextEditingController(
          text: i < widget.value.length ? widget.value[i] : ''),
    );
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(covariant PlinthPinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length) {
      for (final c in _controllers) {
        c.dispose();
      }
      for (final n in _nodes) {
        n.dispose();
      }
      _build();
    } else if (widget.value != _currentValue()) {
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < widget.value.length ? widget.value[i] : '';
      }
    }
  }

  String _currentValue() => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String char) {
    if (char.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    final value = _currentValue();
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      widget.onChanged?.call(_currentValue());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  static const Map<PlinthSize, double> _boxSizes = {
    PlinthSize.xs: 28,
    PlinthSize.sm: 34,
    PlinthSize.md: 40,
    PlinthSize.lg: 48,
    PlinthSize.xl: 56,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = widget.color ?? theme.primaryColor;
    final boxSize = _boxSizes[widget.size]!;
    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;

    // A single non-focusable Focus wrapper around the whole row,
    // rather than a per-box KeyboardListener sharing the TextField's
    // own FocusNode — that sharing caused a real crash ("child !=
    // this" in FocusNode._reparent), since KeyboardListener and
    // TextField each try to own the given node as their own Focus
    // scope, and nesting one inside the other made the node try to
    // become its own parent. canRequestFocus: false means this
    // wrapper never competes for or steals focus from the boxes —
    // it only intercepts key events that bubble up from whichever
    // box currently has focus.
    final status = widget.statusText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _boxes(theme, boxSize, colorKey, resolvedRadius),
        if (status != null && status.isNotEmpty) ...[
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.5),
          // liveRegion is what makes this audible. The message appears
          // without focus moving, so a reader has no reason to look at
          // it unless told; this is the flag that tells it.
          Semantics(
            liveRegion: true,
            child: PlinthText(
              status,
              size: PlinthSize.xs,
              color: widget.error ? theme.rampFor(PlinthRole.error) : null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _boxes(
    PlinthTheme theme,
    double boxSize,
    String colorKey,
    double resolvedRadius,
  ) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          final focusedIndex = _nodes.indexWhere((n) => n.hasFocus);
          if (focusedIndex != -1) {
            _onBackspace(focusedIndex);
          }
        }
        return KeyEventResult.ignored;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.5),
            SizedBox(
              width: boxSize,
              height: boxSize,
              // Each box is its own field, so without a name a screen
              // reader announces four identical unlabelled inputs and
              // gives no way to tell which one has focus.
              child: Semantics(
                label: 'Digit ${i + 1} of ${widget.length}',
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _nodes[i],
                  textAlign: TextAlign.center,
                  obscureText: widget.obscureText,
                  keyboardType: widget.numbersOnly
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    if (widget.numbersOnly)
                      FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: TextStyle(fontSize: theme.fontSizes[widget.size]! + 2),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: theme.surface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(resolvedRadius),
                      borderSide: BorderSide(
                        color: widget.error
                            ? theme.roleShaded(PlinthRole.error, 6)
                            : theme.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(resolvedRadius),
                      borderSide: BorderSide(
                          color: theme.shaded(colorKey, 6), width: 2),
                    ),
                  ),
                  onChanged: (v) => _onChanged(i, v),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
