import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

/// A circular dial for choosing an angle, matching Mantine's
/// `AngleSlider`.
///
/// The one control in the colour set that isn't about colour: it picks
/// a direction. A gradient's angle, a shadow's offset, a rotation. It
/// lives here because Mantine ships it alongside the colour inputs,
/// built from the same drag-on-a-track machinery.
///
/// Zero points up and the value increases clockwise — the compass
/// convention people expect from a dial, not the mathematical one
/// where zero points right and grows anticlockwise.
///
/// ```dart
/// PlinthAngleSlider(
///   value: _angle,
///   onChanged: (a) => setState(() => _angle = a),
/// )
/// ```
class PlinthAngleSlider extends StatefulWidget {
  const PlinthAngleSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.diameter = 60,
    this.thickness = 4,
    this.color,
    this.step = 1,
    this.divisions,
  });

  /// Degrees clockwise from straight up, 0..360.
  final double value;

  /// Null disables the dial.
  final ValueChanged<double>? onChanged;

  /// Diameter of the dial in logical pixels.
  ///
  /// Named `size` before 0.20.0, which everywhere else in this library
  /// means a step on the [PlinthSize] scale.
  final double diameter;
  final double thickness;
  final String? color;

  /// Degrees per arrow-key press.
  final double step;

  /// Snaps to this many equal steps around the circle — 8 gives the
  /// compass points, 12 the clock positions. Omit for continuous.
  final int? divisions;

  @override
  State<PlinthAngleSlider> createState() => _PlinthAngleSliderState();
}

class _PlinthAngleSliderState extends State<PlinthAngleSlider> {
  bool get _enabled => widget.onChanged != null;

  double _snap(double degrees) {
    final wrapped = degrees % 360;
    final divisions = widget.divisions;
    if (divisions == null || divisions <= 0) return wrapped;
    final increment = 360 / divisions;
    return (wrapped / increment).round() * increment % 360;
  }

  void _emit(double degrees) => widget.onChanged?.call(_snap(degrees));

  void _emitFromPosition(Offset local) {
    final centre = widget.diameter / 2;
    final dx = local.dx - centre;
    final dy = local.dy - centre;
    if (dx == 0 && dy == 0) return;

    // atan2(dx, -dy) rather than atan2(dy, dx): rotates the zero from
    // east to north and flips the sweep to clockwise in one step.
    final degrees = math.atan2(dx, -dy) * 180 / math.pi;
    _emit(degrees);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_enabled || event is KeyUpEvent) return KeyEventResult.ignored;

    final increment =
        widget.divisions != null ? 360 / widget.divisions! : widget.step;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowDown:
        _emit(widget.value - increment);
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.arrowUp:
        _emit(widget.value + increment);
      case LogicalKeyboardKey.home:
        _emit(0);
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final fill = theme.shaded(widget.color ?? theme.primaryColor, 6);
    final degrees = widget.value % 360;

    return Semantics(
      slider: true,
      enabled: _enabled,
      label: 'Angle',
      value: '${degrees.round()} degrees',
      // Required alongside the actions below: the framework asserts on
      // a value with no stepped counterpart to announce.
      increasedValue: '${((degrees + widget.step) % 360).round()} degrees',
      decreasedValue: '${((degrees - widget.step) % 360).round()} degrees',
      onIncrease: _enabled ? () => _emit(widget.value + widget.step) : null,
      onDecrease: _enabled ? () => _emit(widget.value - widget.step) : null,
      child: Focus(
        canRequestFocus: _enabled,
        onKeyEvent: _onKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown:
              _enabled ? (d) => _emitFromPosition(d.localPosition) : null,
          onPanUpdate:
              _enabled ? (d) => _emitFromPosition(d.localPosition) : null,
          child: CustomPaint(
            size: Size.square(widget.diameter),
            painter: _AngleDialPainter(
              degrees: degrees,
              fill: fill,
              track: theme.surfaceSunken,
              knob: theme.surface,
              thickness: widget.thickness,
            ),
          ),
        ),
      ),
    );
  }
}

class _AngleDialPainter extends CustomPainter {
  const _AngleDialPainter({
    required this.degrees,
    required this.fill,
    required this.track,
    required this.knob,
    required this.thickness,
  });

  final double degrees;
  final Color fill;
  final Color track;
  final Color knob;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - thickness) / 2;

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = track,
    );

    // Sweep from 12 o'clock. Canvas angles start at 3 o'clock and run
    // clockwise, so the start is rotated back a quarter turn.
    final radians = degrees * math.pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      -math.pi / 2,
      radians,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = fill,
    );

    final handle = Offset(
      centre.dx + radius * math.sin(radians),
      centre.dy - radius * math.cos(radians),
    );
    canvas
      ..drawCircle(handle, thickness * 1.6, Paint()..color = fill)
      ..drawCircle(
        handle,
        thickness * 1.6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = knob,
      );
  }

  @override
  bool shouldRepaint(_AngleDialPainter old) =>
      old.degrees != degrees ||
      old.fill != fill ||
      old.track != track ||
      old.knob != knob ||
      old.thickness != thickness;
}
