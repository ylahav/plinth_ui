import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A duration as a display number — a rest timer, a countdown, a lap
/// time.
///
/// Not [PlinthText] with a large `fontSize`. Three things separate a
/// number that changes every second from text that does not:
///
/// 1. **Tabular figures.** Proportional digits are different widths, so
///    `1` is narrower than `8` and the whole number shifts sideways as
///    it counts down. At 72px that is a visible twitch every second.
/// 2. **Line height 1 and tight tracking.** Display type set at body
///    leading floats in a box far taller than the glyphs.
/// 3. **A different contrast floor.** WCAG large text is 3:1, not
///    4.5:1, and a clock is always large text. Holding it to 4.5:1
///    darkens a brand colour that was already legible — see [color].
///
/// **It does not tick.** The caller owns the timer and passes a
/// formatted string, because who owns the clock decides whether it
/// pauses, and a widget that counted on its own would be wrong for
/// every app that needs to.
///
/// ```dart
/// PlinthClock('01:30', size: 72, color: 'yellow')
/// ```
class PlinthClock extends StatelessWidget {
  const PlinthClock(
    this.value, {
    super.key,
    this.size = 72,
    this.color,
    this.on,
    this.weight = FontWeight.w700,
    this.letterSpacing,
    this.semanticLabel,
    this.textAlign,
  });

  /// The already-formatted duration, e.g. `'01:30'`.
  final String value;

  /// Font size in logical pixels, not a [PlinthSize].
  ///
  /// The type scale stops at `xl`, well short of display sizes, and a
  /// clock is sized to the space it gets rather than to a step on a
  /// scale. [PlinthTheme.fontSizes] still answers everything else.
  final double size;

  /// A palette key, resolved against [on] at the **large-text** floor.
  ///
  /// 3:1 rather than 4.5:1, because at [size] this is large text by
  /// WCAG's definition and the stricter floor would cost brand
  /// fidelity for nothing: `'yellow'` shade 6 clears 3:1 on a light
  /// surface and would be pushed several shades darker to reach 4.5:1.
  ///
  /// The floor follows [size] and [weight] rather than assuming — under
  /// 24px regular, or 18.66px bold, this falls back to 4.5:1, because
  /// then it really is body text.
  ///
  /// Null takes [PlinthTheme.text].
  final String? color;

  /// What [color] is resolved against. Defaults to
  /// [PlinthTheme.surface].
  final Color? on;

  final FontWeight weight;

  /// Tracking. Defaults to a hair negative, scaled to [size] — display
  /// digits set at body tracking look loose.
  final double? letterSpacing;

  /// What a screen reader says instead of [value].
  ///
  /// **Worth setting.** `'01:30'` is announced as a clock time by most
  /// screen readers — "one thirty" — which is wrong for a duration.
  /// There is no automatic spoken form here on purpose: "1 minutes"
  /// needs plural rules, and [PlinthStrings] is a seam of plain strings
  /// with no `intl` dependency, so a built-in version would be wrong
  /// in English and worse everywhere else. The caller has the number
  /// before it was formatted and can say it properly.
  ///
  /// Deliberately **not** a live region: a countdown that announced
  /// itself every second would talk over everything else on the screen.
  final String? semanticLabel;

  final TextAlign? textAlign;

  /// Whether WCAG counts this as large text: 18.66px at bold or above,
  /// 24px otherwise.
  PlinthContrast get _level =>
      (weight.value >= FontWeight.w700.value ? size >= 18.66 : size >= 24)
          ? PlinthContrast.large
          : PlinthContrast.body;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolved = color != null
        ? theme.readableOn(color!, on ?? theme.surface, level: _level)
        : theme.text;

    final text = Text(
      value,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: size,
        height: 1,
        color: resolved,
        fontWeight: weight,
        letterSpacing: letterSpacing ?? -size * 0.02,
        // The whole reason this is not PlinthText: without this the
        // number changes width as the digits change.
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    if (semanticLabel == null) return text;
    return Semantics(
      label: semanticLabel,
      // Or the raw digits are announced after the label.
      excludeSemantics: true,
      child: text,
    );
  }
}
