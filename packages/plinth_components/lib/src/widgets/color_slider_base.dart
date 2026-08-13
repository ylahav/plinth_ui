import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

/// Shared behaviour behind [PlinthHueSlider] and [PlinthAlphaSlider].
/// Internal — not exported.
///
/// [PlinthSlider] wraps Flutter's [Slider] precisely so drag handling,
/// keyboard steps, and screen-reader announcements don't have to be
/// re-derived. A colour slider can't: its track is a gradient, and
/// [SliderTheme] only paints flat colours. So the parts [Slider] would
/// have given for free are rebuilt here, once, rather than twice in
/// two components and inevitably only half-done in one of them:
/// dragging, tapping to jump, arrow-key steps with a Home/End jump,
/// and a slider semantics node with a readable value.
class PlinthColorSliderBase extends StatefulWidget {
  const PlinthColorSliderBase({
    super.key,
    required this.value,
    required this.onChanged,
    required this.gradient,
    required this.thumbColor,
    this.checkerboard = false,
    this.step = 0.01,
    this.height = 14,
    this.radius,
    this.semanticLabel,
    this.semanticFormatter,
  });

  /// Normalised position, 0..1. Every colour slider maps its own range
  /// onto this so the geometry lives in one place.
  final double value;

  final ValueChanged<double>? onChanged;

  final List<Color> gradient;

  /// Painted inside the thumb, so the handle previews what it selects.
  final Color thumbColor;

  /// Draws a light/dark chequer under the track, the conventional way
  /// to show that a colour is partly transparent rather than pale.
  final bool checkerboard;

  final double step;
  final double height;
  final PlinthSize? radius;

  final String? semanticLabel;

  /// Renders the announced value from the raw 0..1 fraction, so a
  /// screen reader says "210 degrees" rather than "0.58".
  ///
  /// A formatter rather than a string because the framework wants the
  /// values a step either side as well: an increase action with no
  /// `increasedValue` to announce trips an assertion.
  final String Function(double normalised)? semanticFormatter;

  @override
  State<PlinthColorSliderBase> createState() => _PlinthColorSliderBaseState();
}

class _PlinthColorSliderBaseState extends State<PlinthColorSliderBase> {
  double _width = 0;

  bool get _enabled => widget.onChanged != null;

  void _emit(double normalised) {
    widget.onChanged?.call(normalised.clamp(0.0, 1.0));
  }

  void _emitFromPosition(double dx) {
    if (_width <= 0) return;
    _emit(dx / _width);
  }

  void _nudge(double delta) => _emit(widget.value + delta);

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_enabled || event is KeyUpEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowDown:
        _nudge(-widget.step);
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.arrowUp:
        _nudge(widget.step);
      case LogicalKeyboardKey.home:
        _emit(0);
      case LogicalKeyboardKey.end:
        _emit(1);
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final radius = theme.radius[widget.radius ?? PlinthSize.xl]!;
    final thumbSize = widget.height + 6;
    final value = widget.value.clamp(0.0, 1.0);

    String announce(double v) {
      final clamped = v.clamp(0.0, 1.0);
      return widget.semanticFormatter?.call(clamped) ??
          '${(clamped * 100).round()}%';
    }

    return Semantics(
      slider: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      value: announce(value),
      // Both are required alongside an increase/decrease action —
      // the framework asserts on a value with no stepped counterpart.
      increasedValue: announce(value + widget.step),
      decreasedValue: announce(value - widget.step),
      onIncrease: _enabled ? () => _nudge(widget.step) : null,
      onDecrease: _enabled ? () => _nudge(-widget.step) : null,
      child: Focus(
        canRequestFocus: _enabled,
        onKeyEvent: _onKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _width = constraints.maxWidth;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _enabled
                  ? (d) => _emitFromPosition(d.localPosition.dx)
                  : null,
              onHorizontalDragUpdate: _enabled
                  ? (d) => _emitFromPosition(d.localPosition.dx)
                  : null,
              child: SizedBox(
                height: thumbSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: SizedBox(
                        height: widget.height,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (widget.checkerboard)
                              CustomPaint(
                                painter: _CheckerboardPainter(
                                  light: theme.surface,
                                  dark: theme.surfaceSunken,
                                ),
                              ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: widget.gradient,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      // Inset by half the thumb at each end, so the
                      // handle stays inside the track it points at.
                      left: value * (_width - thumbSize).clamp(0, _width),
                      child: _Thumb(
                        size: thumbSize,
                        color: widget.thumbColor,
                        border: theme.surface,
                        shadow: theme.shadow,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.size,
    required this.color,
    required this.border,
    required this.shadow,
  });

  final double size;
  final Color color;
  final Color border;
  final Color shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
        boxShadow: [
          BoxShadow(
            color: shadow.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

/// The chequer that says "transparent" rather than "pale".
class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter({required this.light, required this.dark});

  final Color light;
  final Color dark;

  static const double _cell = 6;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = light);

    final paint = Paint()..color = dark;
    for (var y = 0.0; y < size.height; y += _cell) {
      for (var x = 0.0; x < size.width; x += _cell) {
        final odd = ((x / _cell).floor() + (y / _cell).floor()).isOdd;
        if (odd) {
          canvas.drawRect(Rect.fromLTWH(x, y, _cell, _cell), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter old) =>
      old.light != light || old.dark != dark;
}
