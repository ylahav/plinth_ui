import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

import 'plinth_color_picker.dart';
import 'plinth_popover.dart';
import 'plinth_text_input.dart';

/// A text field holding a hex colour, with a preview swatch that opens
/// a [PlinthColorPicker]. Matches Mantine's `ColorInput`.
///
/// The two halves matter equally: typing `#2f9e44` is the fastest way
/// in when you already know the value, and the picker is the only way
/// in when you don't. A picker alone makes a designer paste a hex into
/// a colour wheel by eye.
///
/// Where [PlinthColorSwatch] chooses from a fixed palette, this
/// accepts any colour — so reach for the palette when the choice
/// should stay on-system, and this when it genuinely shouldn't.
///
/// Typing is parsed leniently (`#abc`, `abc`, `#aabbcc`, `aabbcc`, and
/// with [withAlpha], `#aabbccdd`), and an unparseable value is simply
/// not reported: the field keeps whatever was typed so a half-finished
/// `#2f9` isn't destroyed mid-keystroke, and [onChanged] fires only
/// once it means something.
///
/// ```dart
/// PlinthColorInput(
///   label: 'Brand colour',
///   value: _brand,
///   onChanged: (c) => setState(() => _brand = c),
/// )
/// ```
class PlinthColorInput extends StatefulWidget {
  const PlinthColorInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.placeholder,
    this.error,
    this.withAlpha = false,
    this.swatches,
    this.size = PlinthSize.md,
    this.radius,
    this.enabled = true,
  });

  final Color value;

  /// Null disables the field, matching the other form components.
  final ValueChanged<Color>? onChanged;

  final String? label;
  final String? description;
  final String? placeholder;
  final String? error;

  /// Shows an opacity slider in the picker and an eight-digit hex in
  /// the field.
  final bool withAlpha;

  /// Quick picks shown under the picker's sliders.
  final List<Color>? swatches;

  final PlinthSize size;
  final PlinthSize? radius;
  final bool enabled;

  /// Formats a colour as CSS-style hex: `#RRGGBB`, or `#RRGGBBAA` when
  /// [withAlpha]. Exposed because the same string usually has to
  /// appear somewhere else — a copy button, an exported theme file.
  static String formatHex(Color color, {bool withAlpha = false}) {
    final argb = color.toARGB32();
    final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    if (!withAlpha) return '#$rgb';
    final alpha = ((argb >> 24) & 0xFF).toRadixString(16).padLeft(2, '0');
    return '#$rgb$alpha';
  }

  /// Parses the forms a person actually types. Returns null when the
  /// text isn't a colour yet, which is not the same as an error —
  /// every prefix of a hex value passes through this state.
  static Color? parseHex(String input) {
    var text = input.trim();
    if (text.startsWith('#')) text = text.substring(1);
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(text)) return null;

    // #abc is shorthand for #aabbcc.
    if (text.length == 3) {
      text = text.split('').map((c) => '$c$c').join();
    }

    switch (text.length) {
      case 6:
        text = 'ff$text';
      case 8:
        // Typed as CSS RRGGBBAA; Flutter's Color wants AARRGGBB.
        text = text.substring(6) + text.substring(0, 6);
      default:
        return null;
    }

    final value = int.tryParse(text, radix: 16);
    return value == null ? null : Color(value);
  }

  @override
  State<PlinthColorInput> createState() => _PlinthColorInputState();
}

class _PlinthColorInputState extends State<PlinthColorInput> {
  late final TextEditingController _controller =
      TextEditingController(text: _formatted);

  /// Owned here rather than taken from the caller, unlike the overlay
  /// components: the dropdown is this field's own mechanism, not a
  /// disclosure the surrounding page has any reason to drive — the
  /// same call [PlinthSelect] and [PlinthAutocomplete] make.
  final PlinthDisclosureController _picker = PlinthDisclosureController();

  String get _formatted =>
      PlinthColorInput.formatHex(widget.value, withAlpha: widget.withAlpha);

  @override
  void didUpdateWidget(covariant PlinthColorInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only overwrite the field when the incoming colour isn't what the
    // text already says. Rewriting it on every rebuild would fight the
    // cursor while somebody is mid-hex.
    final typed = PlinthColorInput.parseHex(_controller.text);
    if (typed == null || typed.toARGB32() != widget.value.toARGB32()) {
      _controller.text = _formatted;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _picker.dispose();
    super.dispose();
  }

  void _onTyped(String text) {
    final parsed = PlinthColorInput.parseHex(text);
    if (parsed != null) widget.onChanged?.call(parsed);
  }

  void _onPicked(Color color) {
    _controller.text =
        PlinthColorInput.formatHex(color, withAlpha: widget.withAlpha);
    widget.onChanged?.call(color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final enabled = widget.enabled && widget.onChanged != null;
    final swatchSize = theme.fontSizes[widget.size]! * 1.2;

    return PlinthTextInput(
      label: widget.label,
      description: widget.description,
      placeholder: widget.placeholder ?? '#000000',
      error: widget.error,
      controller: _controller,
      onChanged: enabled ? _onTyped : null,
      size: widget.size,
      radius: widget.radius,
      enabled: enabled,
      // The swatch is the picker's trigger rather than the whole
      // field: a field that opened a dropdown on every tap would fight
      // the caret for the same gesture.
      leadingIcon: PlinthPopover(
        controller: _picker,
        width: 240,
        target: Semantics(
          button: true,
          label: 'Choose colour',
          child: Container(
            width: swatchSize,
            height: swatchSize,
            decoration: BoxDecoration(
              color: widget.value,
              borderRadius: BorderRadius.circular(theme.radius[PlinthSize.xs]!),
              border: Border.all(color: theme.border),
            ),
          ),
        ),
        content: PlinthColorPicker(
          value: widget.value,
          onChanged: enabled ? _onPicked : null,
          withAlpha: widget.withAlpha,
          swatches: widget.swatches,
        ),
      ),
    );
  }
}
