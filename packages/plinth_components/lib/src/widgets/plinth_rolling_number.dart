import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_number_formatter.dart';

/// Digits that roll to their new value on change, matching Mantine's
/// `RollingNumber`.
///
/// Formatting is [PlinthNumberFormatter]'s — same props, same
/// `formatted` string, same deliberate lack of localisation. This adds
/// the movement, for the one place a plain number is worth animating: a
/// live counter, a total that updates as a form is filled in, a stat
/// tile on a dashboard.
///
/// The roll is a real odometer rather than a per-digit crossfade: the
/// *value* is what animates, and each digit's position is derived from
/// it. That's what makes 999 → 1000 turn every digit forward together,
/// where tweening each digit separately would send the 9 backwards
/// through 8, 7, 6 while its neighbours went the other way.
///
/// Honours the platform's reduce-motion setting, which for a number
/// that may change often is the difference between a stat tile and a
/// distraction.
///
/// ```dart
/// PlinthRollingNumber(value: _total, prefix: r'$', decimalScale: 2)
/// ```
class PlinthRollingNumber extends StatelessWidget {
  const PlinthRollingNumber({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.thousandSeparator = ',',
    this.decimalSeparator = '.',
    this.decimalScale,
    this.trimTrailingZeros = false,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.size = PlinthSize.md,
    this.color,
    this.weight,
  });

  final num value;

  final String? prefix;
  final String? suffix;
  final String thousandSeparator;
  final String decimalSeparator;
  final int? decimalScale;
  final bool trimTrailingZeros;

  final Duration duration;
  final Curve curve;

  final PlinthSize size;
  final String? color;
  final FontWeight? weight;

  /// The formatting this widget animates, delegated rather than
  /// reimplemented — the getter [PlinthNumberFormatter] exposes for
  /// exactly this kind of reuse.
  PlinthNumberFormatter get _formatter => PlinthNumberFormatter(
        value: value,
        prefix: prefix,
        suffix: suffix,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
        decimalScale: decimalScale,
        trimTrailingZeros: trimTrailingZeros,
        size: size,
        color: color,
        weight: weight,
      );

  /// The text this widget settles on. Useful for a semantics label or
  /// a test, and the same string [PlinthNumberFormatter] would render.
  String get formatted => _formatter.formatted;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final style = TextStyle(
      fontSize: theme.fontSizes[size],
      fontWeight: weight,
      color:
          color != null ? theme.readableOn(color!, theme.surface) : theme.text,
    );

    final text = formatted;
    final places = _digitPlaces(text);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // A rolling number would otherwise announce as a stream of changing
    // digits. One label, read once, is what a screen reader wants.
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: value.toDouble()),
        duration: reduceMotion ? Duration.zero : duration,
        curve: curve,
        builder: (context, animated, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < text.length; i++)
                if (places[i] case final place?)
                  _DigitSlot(
                    place: place,
                    value: animated.abs(),
                    style: style,
                    textScaler: MediaQuery.textScalerOf(context),
                  )
                else
                  Text(text[i], style: style),
            ],
          );
        },
      ),
    );
  }

  /// Maps each character index to the power of ten it represents, or
  /// null for anything that isn't a rolling digit. Units are 0, tens
  /// 1, the first decimal place -1.
  ///
  /// Only the numeric body is considered. A digit inside a `prefix` or
  /// `suffix` — `'2x '`, `' m2'` — is a label, not a place value, and
  /// must not roll, so the body is bounded by their lengths rather
  /// than by scanning for digit characters.
  List<int?> _digitPlaces(String text) {
    final places = List<int?>.filled(text.length, null);

    final start = (value < 0 ? 1 : 0) + (prefix?.length ?? 0);
    final end = text.length - (suffix?.length ?? 0);
    if (start >= end) return places;

    final digits = <int>[];
    for (var i = start; i < end; i++) {
      if (_isDigit(text[i])) digits.add(i);
    }
    if (digits.isEmpty) return places;

    // Digits after the decimal separator take negative places. The
    // separator is looked for within the body only, so a suffix that
    // happens to contain one can't be mistaken for it. Configuring the
    // same character for both separators is the one case this can't
    // resolve — there is nothing in the string left to tell them apart.
    var fraction = 0;
    if (decimalSeparator.isNotEmpty) {
      final sep = text.lastIndexOf(decimalSeparator, end - 1);
      if (sep >= start) {
        for (var i = sep + 1; i < end; i++) {
          if (_isDigit(text[i])) fraction++;
        }
      }
    }

    for (var d = 0; d < digits.length; d++) {
      places[digits[d]] = digits.length - 1 - d - fraction;
    }
    return places;
  }

  static bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }
}

/// One digit column, showing whichever glyphs the continuous position
/// currently straddles.
class _DigitSlot extends StatelessWidget {
  const _DigitSlot({
    required this.place,
    required this.value,
    required this.style,
    required this.textScaler,
  });

  final int place;
  final double value;
  final TextStyle style;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    // The digit's own continuous position: as the value climbs this
    // climbs with it, wrapping through 9 back to 0 going forwards.
    final position = value / math.pow(10, place);
    final metrics = _measure('0', style, textScaler);
    final lowest = position.floor() - 1;

    return ClipRect(
      child: SizedBox(
        width: metrics.width,
        height: metrics.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Three glyphs is all that can be even partly visible, so
            // the strip is built around the current position rather
            // than rendering all ten of them every frame.
            for (var d = lowest; d <= lowest + 2; d++)
              Positioned(
                top: (d - position) * metrics.height,
                child: Text(_glyph(d), style: style),
              ),
          ],
        ),
      ),
    );
  }

  static String _glyph(int d) => '${((d % 10) + 10) % 10}';

  static Size _measure(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final size = painter.size;
    painter.dispose();
    return size;
  }
}
