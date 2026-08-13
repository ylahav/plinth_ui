import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_alpha_slider.dart';
import 'plinth_hue_slider.dart';
import 'plinth_stack.dart';

/// A full colour picker — saturation/brightness area, hue, and
/// optionally opacity — matching Mantine's `ColorPicker`.
///
/// Controlled like every other input here: it holds no colour of its
/// own, and [onChanged] reports the colour it would become.
///
/// Distinct from [PlinthColorSwatch], which chooses from a fixed
/// palette. This is for an arbitrary colour, so it's the right control
/// only when any colour is genuinely valid — a brand setting, a
/// highlight, a user's own label. A palette is usually the better
/// answer when the choice should stay on-system.
///
/// ```dart
/// PlinthColorPicker(
///   value: _brand,
///   onChanged: (c) => setState(() => _brand = c),
/// )
/// ```
class PlinthColorPicker extends StatefulWidget {
  const PlinthColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.withAlpha = false,
    this.swatches,
    this.areaHeight = 140,
    this.radius,
  });

  final Color value;

  /// Null disables every part of the picker.
  final ValueChanged<Color>? onChanged;

  /// Adds an opacity slider, and makes the picker preserve the alpha
  /// channel it is given.
  final bool withAlpha;

  /// Quick picks shown under the sliders. Omit for none.
  final List<Color>? swatches;

  final double areaHeight;
  final PlinthSize? radius;

  @override
  State<PlinthColorPicker> createState() => _PlinthColorPickerState();
}

class _PlinthColorPickerState extends State<PlinthColorPicker> {
  /// Remembered across changes because hue is *undefined* for greys and
  /// blacks, where [HSVColor] reports 0. Reading it back would snap the
  /// picker to red the moment saturation or brightness hit zero, and
  /// then dragging the hue slider on a black would appear to do
  /// nothing. Keeping the last meaningful hue is what makes the two
  /// controls behave independently.
  ///
  /// Captured eagerly rather than with a `late` initialiser: a lazy one
  /// runs at first *read*, which is only ever the moment the hue has
  /// already gone undefined — so it would reliably record the 0 it
  /// exists to avoid.
  late double _hue;

  @override
  void initState() {
    super.initState();
    _hue = HSVColor.fromColor(widget.value).hue;
  }

  @override
  void didUpdateWidget(covariant PlinthColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final raw = HSVColor.fromColor(widget.value);
    if (raw.saturation > 0 && raw.value > 0) _hue = raw.hue;
  }

  HSVColor get _hsv {
    final raw = HSVColor.fromColor(widget.value);
    final defined = raw.saturation > 0 && raw.value > 0;
    return HSVColor.fromAHSV(
      raw.alpha,
      defined ? raw.hue : _hue,
      raw.saturation,
      raw.value,
    );
  }

  bool get _enabled => widget.onChanged != null;

  void _emit(HSVColor hsv) {
    setState(() => _hue = hsv.hue);
    final next = widget.withAlpha ? hsv : hsv.withAlpha(1);
    widget.onChanged?.call(next.toColor());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final hsv = _hsv;
    final radius = theme.radius[widget.radius ?? theme.defaultRadius]!;

    return PlinthStack(
      gap: PlinthSize.sm,
      children: [
        _SaturationBrightnessArea(
          hsv: hsv,
          height: widget.areaHeight,
          radius: radius,
          onChanged: _enabled
              ? (s, v) => _emit(HSVColor.fromAHSV(hsv.alpha, hsv.hue, s, v))
              : null,
        ),
        PlinthHueSlider(
          value: hsv.hue,
          saturation: hsv.saturation,
          brightness: hsv.value,
          onChanged: _enabled
              ? (h) => _emit(
                    HSVColor.fromAHSV(hsv.alpha, h, hsv.saturation, hsv.value),
                  )
              : null,
        ),
        if (widget.withAlpha)
          PlinthAlphaSlider(
            color: hsv.withAlpha(1).toColor(),
            value: hsv.alpha,
            onChanged: _enabled ? (a) => _emit(hsv.withAlpha(a)) : null,
          ),
        if (widget.swatches != null && widget.swatches!.isNotEmpty)
          _Swatches(
            swatches: widget.swatches!,
            selected: widget.value,
            radius: theme.radius[PlinthSize.xs]!,
            border: theme.border,
            check: theme.contrastingOn,
            onSelected: _enabled ? (c) => _emit(HSVColor.fromColor(c)) : null,
          ),
      ],
    );
  }
}

/// The square: saturation left-to-right, brightness top-to-bottom.
class _SaturationBrightnessArea extends StatefulWidget {
  const _SaturationBrightnessArea({
    required this.hsv,
    required this.height,
    required this.radius,
    required this.onChanged,
  });

  final HSVColor hsv;
  final double height;
  final double radius;
  final void Function(double saturation, double brightness)? onChanged;

  @override
  State<_SaturationBrightnessArea> createState() =>
      _SaturationBrightnessAreaState();
}

class _SaturationBrightnessAreaState extends State<_SaturationBrightnessArea> {
  Size _size = Size.zero;

  bool get _enabled => widget.onChanged != null;

  void _emitFromPosition(Offset local) {
    if (_size.width <= 0 || _size.height <= 0) return;
    widget.onChanged?.call(
      (local.dx / _size.width).clamp(0.0, 1.0),
      (1 - local.dy / _size.height).clamp(0.0, 1.0),
    );
  }

  void _nudge({double saturation = 0, double brightness = 0}) {
    widget.onChanged?.call(
      (widget.hsv.saturation + saturation).clamp(0.0, 1.0),
      (widget.hsv.value + brightness).clamp(0.0, 1.0),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_enabled || event is KeyUpEvent) return KeyEventResult.ignored;

    const step = 0.02;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _nudge(saturation: -step);
      case LogicalKeyboardKey.arrowRight:
        _nudge(saturation: step);
      case LogicalKeyboardKey.arrowUp:
        _nudge(brightness: step);
      case LogicalKeyboardKey.arrowDown:
        _nudge(brightness: -step);
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final hsv = widget.hsv;
    final pure = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();

    return Semantics(
      label: 'Saturation and brightness',
      value: '${(hsv.saturation * 100).round()}% saturation, '
          '${(hsv.value * 100).round()}% brightness',
      child: Focus(
        canRequestFocus: _enabled,
        onKeyEvent: _onKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown:
              _enabled ? (d) => _emitFromPosition(d.localPosition) : null,
          onPanUpdate:
              _enabled ? (d) => _emitFromPosition(d.localPosition) : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _size = Size(constraints.maxWidth, widget.height);

              return ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius),
                child: SizedBox(
                  height: widget.height,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // The standard three-layer build-up: the pure
                      // hue, white washing out to the left, black
                      // deepening to the bottom.
                      Positioned.fill(child: ColoredBox(color: pure)),
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: hsv.saturation * _size.width - 7,
                        top: (1 - hsv.value) * widget.height - 7,
                        child: _AreaHandle(color: hsv.withAlpha(1).toColor()),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AreaHandle extends StatelessWidget {
  const _AreaHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 3),
        ],
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({
    required this.swatches,
    required this.selected,
    required this.radius,
    required this.border,
    required this.check,
    required this.onSelected,
  });

  final List<Color> swatches;
  final Color selected;
  final double radius;
  final Color border;
  final Color Function(Color) check;
  final ValueChanged<Color>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final swatch in swatches)
          Semantics(
            button: true,
            selected: swatch.toARGB32() == selected.toARGB32(),
            child: GestureDetector(
              onTap: onSelected == null ? null : () => onSelected!(swatch),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: swatch,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: border),
                ),
                child: swatch.toARGB32() == selected.toARGB32()
                    ? Icon(Icons.check, size: 14, color: check(swatch))
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
