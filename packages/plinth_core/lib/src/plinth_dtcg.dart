/// Reading and writing the Design Tokens Community Group format.
///
/// The one planned item `docs/ROADMAP.md` says neither competitor has.
/// It is a mapping rather than a translation, because
/// `plinth_token.dart` already names types the way DTCG names them —
/// which is most of why the hierarchy had to land first.
///
/// **What this is for.** A design team publishes tokens from Figma as
/// DTCG JSON; a web codebase consumes them through Style Dictionary.
/// Until now a Flutter app in that organisation had to re-type the
/// palette by hand and drift from it quietly. This reads the same file.
///
/// **What it deliberately does not do.** It does not invent tokens the
/// format cannot express, and it does not silently drop ones it does
/// not understand — [PlinthDtcg.parse] reports them, because a token
/// that vanishes on import is worse than one that fails loudly.
library;

import 'package:flutter/material.dart';

import 'plinth_theme.dart';
import 'plinth_token.dart';
import 'tokens.dart';

/// What came back from reading a DTCG document.
@immutable
class PlinthDtcgResult {
  const PlinthDtcgResult({
    required this.theme,
    required this.applied,
    required this.ignored,
  });

  /// The theme, with everything understood applied over the base.
  final PlinthTheme theme;

  /// Token paths that were read and used.
  final List<String> applied;

  /// Token paths that were present and *not* used, with why.
  ///
  /// The whole reason this type exists rather than returning a bare
  /// theme. An importer that silently ignores half a file produces a
  /// theme that looks right and is not, and the person who finds out is
  /// whoever trusted the colours.
  final Map<String, String> ignored;
}

/// DTCG read and write.
abstract final class PlinthDtcg {
  /// Emits [theme] as a DTCG document.
  ///
  /// Groups mirror the token paths, so `color.blue.6` becomes
  /// `color > blue > 6`. Every leaf carries `$type` and `$value`.
  static Map<String, Object?> export(PlinthTheme theme) {
    final root = <String, Object?>{};

    for (final token in theme.tokens) {
      final parts = token.path.split('.');
      var node = root;
      for (final part in parts.take(parts.length - 1)) {
        node = node.putIfAbsent(part, () => <String, Object?>{})
            as Map<String, Object?>;
      }
      node[parts.last] = {
        r'$type': token.type.dtcg,
        r'$value': _encode(token.type, token.value),
      };
    }
    return root;
  }

  static Object? _encode(PlinthTokenType type, Object value) => switch (type) {
        PlinthTokenType.color => _hex(value as Color),
        // DTCG dimensions carry a unit. Logical pixels are what Flutter
        // means, and `px` is the nearest honest spelling of that.
        PlinthTokenType.dimension => '${_trim(value as double)}px',
        PlinthTokenType.duration => '${(value as Duration).inMilliseconds}ms',
        PlinthTokenType.fontWeight => (value as FontWeight).value,
        PlinthTokenType.cubicBezier => _curveName(value as Curve),
        PlinthTokenType.shadow => _shadow(value as PlinthElevation),
        PlinthTokenType.number => value,
      };

  static String _hex(Color c) {
    String two(double channel) =>
        (channel * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final rgb = '#${two(c.r)}${two(c.g)}${two(c.b)}';
    // Alpha only when it is not opaque, which is how every DTCG file in
    // the wild writes it.
    return c.a >= 1.0 ? rgb : '$rgb${two(c.a)}';
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// Named curves rather than control points.
  ///
  /// DTCG's `cubicBezier` wants four numbers, and Flutter's curves are
  /// not all cubic béziers — `Curves.bounceIn` is piecewise and has no
  /// four-number form. Emitting a name that round-trips is more use to
  /// a consumer than four numbers that are wrong for half the values.
  static String _curveName(Curve c) => switch (c) {
        Curves.linear => 'linear',
        Curves.easeOut => 'easeOut',
        Curves.easeOutCubic => 'easeOutCubic',
        _ => c.toString(),
      };

  /// Reads a DTCG document over [base].
  ///
  /// Everything it understands is applied; everything else is reported
  /// in [PlinthDtcgResult.ignored] rather than dropped. A theme that
  /// looks right and silently lost half its input is the failure this
  /// return type exists to prevent.
  ///
  /// ```dart
  /// final result = PlinthDtcg.parse(json, base: PlinthTheme.defaultTheme);
  /// if (result.ignored.isNotEmpty) debugPrint('${result.ignored}');
  /// MaterialApp(theme: ThemeData(extensions: [result.theme]));
  /// ```
  ///
  /// **References are resolved.** DTCG writes `{color.blue.6}` to mean
  /// "the same as that one", and a file that used them and came back
  /// with literals would not round-trip.
  static PlinthDtcgResult parse(
    Map<String, Object?> document, {
    PlinthTheme? base,
  }) {
    final theme = base ?? PlinthTheme.defaultTheme;
    final applied = <String>[];
    final ignored = <String, String>{};

    final flat = <String, Map<String, Object?>>{};
    _flatten(document, const [], flat);

    Object? resolve(String path, Object? value, {int depth = 0}) {
      if (value is! String || !value.startsWith('{') || !value.endsWith('}')) {
        return value;
      }
      // A reference cycle is a file bug, not a stack overflow.
      if (depth > 8) {
        ignored[path] = 'reference chain too deep, probably a cycle';
        return null;
      }
      final target = value.substring(1, value.length - 1);
      final node = flat[target];
      if (node == null) {
        ignored[path] = 'references {$target}, which is not in this document';
        return null;
      }
      return resolve(path, node[r'$value'], depth: depth + 1);
    }

    final ramps = <String, List<Color>>{};
    final spacing = <PlinthSize, double>{};
    final radius = <PlinthSize, double>{};
    final fontSizes = <PlinthSize, double>{};

    for (final entry in flat.entries) {
      final path = entry.key;
      final raw = resolve(path, entry.value[r'$value']);
      if (raw == null) continue;

      final parts = path.split('.');

      if (parts.length == 3 && parts.first == 'color') {
        final color = _color(raw);
        if (color == null) {
          ignored[path] = 'not a colour this reader understands: $raw';
          continue;
        }
        final shade = int.tryParse(parts[2]);
        if (shade == null || shade < 0 || shade > 9) {
          ignored[path] = 'shade must be 0-9, got "${parts[2]}"';
          continue;
        }
        (ramps[parts[1]] ??=
            List<Color>.filled(10, const Color(0xFF000000)))[shade] = color;
        applied.add(path);
        continue;
      }

      if (parts.length == 2) {
        final size =
            PlinthSize.values.where((s) => s.name == parts[1]).firstOrNull;
        final number = _dimension(raw);
        if (size != null && number != null) {
          switch (parts.first) {
            case 'spacing':
              spacing[size] = number;
              applied.add(path);
              continue;
            case 'radius':
              radius[size] = number;
              applied.add(path);
              continue;
            case 'fontSize':
              fontSizes[size] = number;
              applied.add(path);
              continue;
          }
        }
      }

      ignored[path] = 'no Plinth token matches this path';
    }

    // A partial ramp is a real case: a design file often publishes five
    // shades of a colour, not ten. Filling the gaps from the base keeps
    // the ten-shade contract that `readableOn` walks.
    final merged = <String, PlinthColorShades>{...theme.colors};
    for (final entry in ramps.entries) {
      merged[entry.key] = entry.value;
    }

    return PlinthDtcgResult(
      theme: theme.copyWith(
        colors: merged,
        spacing: spacing.isEmpty ? null : {...theme.spacing, ...spacing},
        radius: radius.isEmpty ? null : {...theme.radius, ...radius},
        fontSizes:
            fontSizes.isEmpty ? null : {...theme.fontSizes, ...fontSizes},
      ),
      applied: applied..sort(),
      ignored: ignored,
    );
  }

  static void _flatten(
    Map<String, Object?> node,
    List<String> prefix,
    Map<String, Map<String, Object?>> out,
  ) {
    for (final entry in node.entries) {
      if (entry.key.startsWith(r'$')) continue;
      final value = entry.value;
      if (value is! Map<String, Object?>) continue;
      final path = [...prefix, entry.key];
      if (value.containsKey(r'$value')) {
        out[path.join('.')] = value;
      } else {
        _flatten(value, path, out);
      }
    }
  }

  static Color? _color(Object? raw) {
    if (raw is! String) return null;
    var hex = raw.trim();
    if (!hex.startsWith('#')) return null;
    hex = hex.substring(1);
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }

    // Exclusive, not sequential. An earlier version padded a 6-digit
    // value to `ff……` and then let the 8-digit branch reorder it as
    // though the `ff` were a trailing alpha — which turned #123456
    // into 56ff1234. Every opaque colour in the library came back
    // wrong, and the round-trip test is what said so.
    if (hex.length == 6) {
      hex = 'ff$hex';
    } else if (hex.length == 8) {
      // DTCG writes #RRGGBBAA; Dart wants 0xAARRGGBB.
      hex = hex.substring(6) + hex.substring(0, 6);
    }
    final value = int.tryParse(hex, radix: 16);
    return value == null ? null : Color(value);
  }

  static double? _dimension(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is! String) return null;
    final text = raw.trim().replaceAll(RegExp(r'(px|rem|dp)$'), '');
    return double.tryParse(text);
  }

  static Map<String, Object?> _shadow(PlinthElevation e) => {
        'offsetX': '0px',
        'offsetY': '${_trim(e.offsetY)}px',
        'blur': '${_trim(e.blur)}px',
        'spread': '${_trim(e.spread)}px',
        'color': '#000000',
        // The opacity lives beside the colour rather than inside it,
        // because the colour is the theme's `shadow` at paint time and
        // this file cannot know what that will be.
        'alpha': e.opacity,
      };
}
