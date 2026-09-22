/// The contrast machinery, pointed at a theme instead of a colour.
///
/// This library's whole claim is that colour resolves against a WCAG
/// floor at lookup time. That holds for everything routed through
/// `readableOn` — and it is exactly why validation is worth shipping:
/// **the tokens it cannot help with are the ones an adopter sets by
/// hand.** `text`, `surface`, `onFilled` and the series palette are
/// literal colours. Nothing lifts them, because nothing can: they are
/// the input.
///
/// So this checks the input. A team runs it in CI against their own
/// tokens and finds out that their brand fails before they ship it,
/// rather than after somebody cannot read a label.
///
/// ```dart
/// test('our theme is readable', () {
///   expect(ourTheme.validate(), isEmpty);
/// });
/// ```
library;

import 'package:flutter/material.dart';

import 'plinth_theme.dart';

/// One pair of colours that does not clear its floor.
@immutable
class PlinthContrastIssue {
  const PlinthContrastIssue({
    required this.foreground,
    required this.background,
    required this.ratio,
    required this.required,
    required this.level,
  });

  /// Token paths, matching `PlinthToken.path` — so an issue can be
  /// looked up, linked to, or grepped for in a design file.
  final String foreground;
  final String background;

  final double ratio;

  /// What [level] demands.
  final double required;

  final PlinthContrast level;

  /// How far short it falls, as a ratio. Useful for sorting: the worst
  /// pair is usually the one to fix first.
  double get shortfall => required - ratio;

  @override
  String toString() => '$foreground on $background is '
      '${ratio.toStringAsFixed(2)}:1, needs '
      '${required.toStringAsFixed(1)}:1 (${level.name})';
}

/// Checks a theme's literal colours against the floors they claim.
extension PlinthThemeValidation on PlinthTheme {
  /// Every pair that falls short, worst first.
  ///
  /// **Only pairs that can actually meet on screen.** Checking every
  /// colour against every other would produce a hundred findings, most
  /// of them about combinations no component ever paints, and a report
  /// nobody reads is the same as no report.
  ///
  /// [seriesLevel] defaults to [PlinthContrast.nonText] because a chart
  /// series is a filled area, not text — WCAG 1.4.11 asks 3:1 of it.
  /// Pass [PlinthContrast.body] if your charts carry labels in the
  /// series colour.
  List<PlinthContrastIssue> validate({
    bool includeSeries = true,
    PlinthContrast seriesLevel = PlinthContrast.nonText,
  }) {
    final issues = <PlinthContrastIssue>[];

    void check(
      String fg,
      Color foreground,
      String bg,
      Color background,
      PlinthContrast level,
    ) {
      final ratio = PlinthTheme.contrastRatio(foreground, background);
      if (ratio + 0.005 < level.ratio) {
        issues.add(PlinthContrastIssue(
          foreground: fg,
          background: bg,
          ratio: ratio,
          required: level.ratio,
          level: level,
        ));
      }
    }

    // The three surfaces a component can sit on, and the text colours
    // that can sit on them.
    const surfaceNames = ['surface', 'surfaceMuted', 'surfaceSunken'];
    final surfaceValues = [surface, surfaceMuted, surfaceSunken];

    const textNames = ['text', 'textMuted'];
    final textValues = [text, textMuted];

    for (var s = 0; s < surfaceValues.length; s++) {
      for (var t = 0; t < textValues.length; t++) {
        check(textNames[t], textValues[t], surfaceNames[s], surfaceValues[s],
            PlinthContrast.body);
      }

      // Borders are non-text UI that carries meaning — 1.4.11's 3:1.
      // `borderMuted` is deliberately exempt: it is decoration, and the
      // library's own docs say so ("a softer border, for decoration
      // rather than delineation"). Holding decoration to a floor meant
      // for meaning is how a validator earns a reputation for noise.
      check('border', border, surfaceNames[s], surfaceValues[s],
          PlinthContrast.nonText);
    }

    // `textDisabled` is exempt by WCAG itself: 1.4.3 excludes inactive
    // controls. Flagging it would be flagging the guideline.

    // `onFilled` is deliberately not checked against any ramp.
    //
    // It looks like it should be: white text on a filled button. But
    // no component paints that pair. Filled surfaces use
    // `contrastingOn`, which picks black or white per background and
    // therefore passes by construction; `PlinthTooltip` uses it too
    // when coloured, and otherwise paints `onFilled` over a dark
    // surface rather than over a ramp; `PlinthSwitch` paints it as a
    // shape, not text; and `PlinthBackgroundImage` paints it over a
    // photograph, which no contrast arithmetic can evaluate.
    //
    // A first version checked all thirteen ramps and produced thirteen
    // findings about pairs that never meet — the exact noise this
    // method's own doc comment warns about.

    if (includeSeries) {
      for (var i = 0; i < seriesColors.length; i++) {
        final s = seriesColors[i];
        check('series.$i', color(s.ramp, s.shade), 'surface', surface,
            seriesLevel);
      }
    }

    issues.sort((a, b) => b.shortfall.compareTo(a.shortfall));
    return issues;
  }
}
