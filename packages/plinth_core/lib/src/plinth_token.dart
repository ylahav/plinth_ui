/// Every token in a theme, addressable by path and sorted into tiers.
///
/// The "token hierarchy" `docs/ROADMAP.md` calls the gate on everything
/// in interop. Before this, a `PlinthTheme` was thirty-odd fields that
/// only Dart could read: you could ask it for `surface`, but you could
/// not ask it *what it has*. Every interop item needs the second
/// question — DTCG export has to enumerate, a token explorer has to
/// list, and theme validation has to walk the semantic colours without
/// knowing their names in advance.
///
/// **Purely additive.** No field changed, nothing is deprecated, and a
/// theme that never calls [PlinthTheme.tokens] is unaffected.
library;

import 'package:flutter/material.dart';

import 'plinth_theme.dart';
import 'tokens.dart';

/// Which tier a token sits in.
///
/// Two, not three. **Component tokens are deliberately absent**:
/// `button.primary.background` does not exist yet, and inventing an
/// empty tier for it would describe an intention rather than the
/// theme. It is its own ROADMAP item, and this enum gains a value when
/// that lands.
enum PlinthTier {
  /// A raw value with no meaning attached — a ramp, a step on a scale.
  /// `color.blue.6`, `spacing.md`, `duration.sm`.
  primitive,

  /// A role that resolves to a primitive. `surface`, `text`,
  /// `semantic.error`. What a component actually asks for.
  semantic,
}

/// A token's type, named as the Design Tokens Community Group names it.
///
/// Matching DTCG's vocabulary here rather than inventing one is the
/// point: it is what makes the export a mapping rather than a
/// translation, and it is why `fontWeight` is its own type instead of a
/// number.
enum PlinthTokenType {
  color,
  dimension,
  duration,
  cubicBezier,
  fontWeight,
  shadow,
  number;

  /// The `$type` string DTCG uses.
  String get dtcg => switch (this) {
        PlinthTokenType.color => 'color',
        PlinthTokenType.dimension => 'dimension',
        PlinthTokenType.duration => 'duration',
        PlinthTokenType.cubicBezier => 'cubicBezier',
        PlinthTokenType.fontWeight => 'fontWeight',
        PlinthTokenType.shadow => 'shadow',
        PlinthTokenType.number => 'number',
      };
}

/// One token: where it lives, what tier it is, and what it holds.
@immutable
class PlinthToken {
  const PlinthToken({
    required this.path,
    required this.tier,
    required this.type,
    required this.value,
  });

  /// Dot-separated, and stable — `color.blue.6`, `spacing.md`,
  /// `surface`. Stable because an explorer links to it and an export
  /// writes it into a file somebody else's build reads.
  final String path;

  final PlinthTier tier;
  final PlinthTokenType type;

  /// The resolved Dart value: a `Color`, a `double`, a `Duration`, a
  /// `Curve`, a `FontWeight`, a [PlinthElevation].
  ///
  /// Resolved rather than a reference, because that is what a
  /// `PlinthTheme` actually holds. A semantic colour here is the colour
  /// it came out as, not the `{color.gray.0}` it conceptually is —
  /// see the note on [PlinthTheme.tokens].
  final Object value;

  @override
  bool operator ==(Object other) =>
      other is PlinthToken &&
      other.path == path &&
      other.tier == tier &&
      other.type == type &&
      other.value == value;

  @override
  int get hashCode => Object.hash(path, tier, type, value);

  @override
  String toString() => 'PlinthToken($path, ${tier.name}, ${type.name})';
}

/// Enumerating a theme.
extension PlinthThemeTokens on PlinthTheme {
  /// Every token this theme holds, primitives first.
  ///
  /// **Semantic colours come out resolved, not as references.** A
  /// `PlinthTheme` stores `surface` as a `Color`, not as
  /// `{color.gray.0}`, so that is what this can honestly report. The
  /// reference layer is a separate change with a breaking edge to it,
  /// and claiming a reference here that the theme does not hold would
  /// make an export that round-trips into one that quietly flattens.
  ///
  /// Ordered and stable: primitives before semantics, and alphabetical
  /// within each group, so a diff of two exports is readable.
  List<PlinthToken> get tokens {
    final out = <PlinthToken>[];

    void add(String path, PlinthTier tier, PlinthTokenType type, Object v) =>
        out.add(PlinthToken(path: path, tier: tier, type: type, value: v));

    // --- primitives -------------------------------------------------

    for (final name in colors.keys.toList()..sort()) {
      final ramp = colors[name]!;
      for (var shade = 0; shade < ramp.length; shade++) {
        add('color.$name.$shade', PlinthTier.primitive, PlinthTokenType.color,
            ramp[shade]);
      }
    }

    for (final size in PlinthSize.values) {
      final s = spacing[size];
      if (s != null) {
        add('spacing.${size.name}', PlinthTier.primitive,
            PlinthTokenType.dimension, s);
      }
      final r = radius[size];
      if (r != null) {
        add('radius.${size.name}', PlinthTier.primitive,
            PlinthTokenType.dimension, r);
      }
      final f = fontSizes[size];
      if (f != null) {
        add('fontSize.${size.name}', PlinthTier.primitive,
            PlinthTokenType.dimension, f);
      }
      final b = borderWidths[size];
      if (b != null) {
        add('borderWidth.${size.name}', PlinthTier.primitive,
            PlinthTokenType.dimension, b);
      }
      final d = durations[size];
      if (d != null) {
        add('duration.${size.name}', PlinthTier.primitive,
            PlinthTokenType.duration, d);
      }
    }

    for (final w in PlinthWeight.values) {
      final v = fontWeights[w];
      if (v != null) {
        add('fontWeight.${w.name}', PlinthTier.primitive,
            PlinthTokenType.fontWeight, v);
      }
    }

    for (final c in PlinthCurve.values) {
      final v = curves[c];
      if (v != null) {
        add('curve.${c.name}', PlinthTier.primitive,
            PlinthTokenType.cubicBezier, v);
      }
    }

    for (final e in PlinthShadow.values) {
      final v = elevations[e];
      if (v != null) {
        add('elevation.${e.name}', PlinthTier.primitive, PlinthTokenType.shadow,
            v);
      }
    }

    for (var i = 0; i < seriesColors.length; i++) {
      // Resolved through the theme's own ramps, so a rebranded theme
      // reports the series it actually paints.
      final s = seriesColors[i];
      add('series.$i', PlinthTier.primitive, PlinthTokenType.color,
          color(s.ramp, s.shade));
    }

    // --- semantics --------------------------------------------------

    const surfaces = <String, String>{
      'surface': 'surface',
      'surfaceMuted': 'surfaceMuted',
      'surfaceSunken': 'surfaceSunken',
      'border': 'border',
      'borderMuted': 'borderMuted',
      'text': 'text',
      'textMuted': 'textMuted',
      'textDisabled': 'textDisabled',
      'onFilled': 'onFilled',
      'onFilledInverse': 'onFilledInverse',
      'shadow': 'shadow',
      'scrim': 'scrim',
    };
    final values = <String, Color>{
      'surface': surface,
      'surfaceMuted': surfaceMuted,
      'surfaceSunken': surfaceSunken,
      'border': border,
      'borderMuted': borderMuted,
      'text': text,
      'textMuted': textMuted,
      'textDisabled': textDisabled,
      'onFilled': onFilled,
      'onFilledInverse': onFilledInverse,
      'shadow': shadow,
      'scrim': scrim,
    };
    for (final key in surfaces.keys) {
      add(key, PlinthTier.semantic, PlinthTokenType.color, values[key]!);
    }

    // Roles resolve through the contrast floor, so what is reported is
    // what a caller would actually be handed — not the shade the role
    // nominally points at.
    for (final role in semanticColors.keys.toList()..sort()) {
      add('semantic.$role', PlinthTier.semantic, PlinthTokenType.color,
          semanticText(role));
    }

    for (final role in PlinthRole.values) {
      final ramp = roleRamps[role];
      if (ramp != null) {
        add('role.${role.name}', PlinthTier.semantic, PlinthTokenType.color,
            color(ramp, 6));
      }
    }

    return out;
  }

  /// The token at [path], or null.
  PlinthToken? token(String path) {
    for (final t in tokens) {
      if (t.path == path) return t;
    }
    return null;
  }
}
