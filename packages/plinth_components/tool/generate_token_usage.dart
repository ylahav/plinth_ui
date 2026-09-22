// Generates docs/TOKENS.md: every token, its value in both themes, and
// which components read it.
//
// The third part is the one that needed writing. "Which components read
// this token" is the question you ask before changing a token, and
// until now the only way to answer it was to grep and hope you guessed
// the right spelling — `theme.surface`, `theme.spacing[PlinthSize.md]`
// and `theme.space(4)` are all token reads and none of them look alike.
//
// Run explicitly — it writes a file, so like `generate_screenshots.dart`
// it lives outside `test/` and is not picked up by `melos run test`:
//
//     cd packages/plinth_components
//     flutter test tool/generate_token_usage.dart
//
// `flutter test` rather than `dart run` because the values half needs
// `PlinthTheme`, which imports Flutter.
//
// `token_usage_fresh_test.dart` fails if the committed file has fallen
// behind, the same trade `examples_code.dart` makes.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

/// How a token read looks in source, and which token path it means.
///
/// Regex rather than the analyzer: these are all simple receiver-plus-
/// member patterns, and the analyzer would resolve *every* `theme.`
/// expression including ones that are not tokens at all. The cost is
/// that a dynamic read cannot be pinned to one path — see `_dynamic`.
final _patterns = <RegExp, String Function(Match)>{
  // theme.surface, theme.text, theme.border, ...
  RegExp(r'\btheme\.(surface|surfaceMuted|surfaceSunken|border|borderMuted'
      r'|text|textMuted|textDisabled|onFilled|onFilledInverse|shadow|scrim)'
      r'\b'): (m) => m[1]!,

  // theme.spacing[PlinthSize.md]
  RegExp(r'\btheme\.(spacing|radius|fontSizes)\[PlinthSize\.(\w+)\]'): (m) =>
      '${m[1] == 'fontSizes' ? 'fontSize' : m[1]}.${m[2]}',

  // theme.borderWidth(PlinthSize.md), theme.duration(PlinthSize.sm)
  RegExp(r'\btheme\.borderWidth\(PlinthSize\.(\w+)\)'): (m) =>
      'borderWidth.${m[1]}',
  RegExp(r'\btheme\.duration\(PlinthSize\.(\w+)\)'): (m) => 'duration.${m[1]}',
  RegExp(r'\btheme\.weight\(PlinthWeight\.(\w+)\)'): (m) =>
      'fontWeight.${m[1]}',
  RegExp(r'\btheme\.curve\(PlinthCurve\.(\w+)\)'): (m) => 'curve.${m[1]}',
  RegExp(r'\btheme\.elevation\(PlinthShadow\.(\w+)\)'): (m) =>
      'elevation.${m[1]}',

  // theme.color('blue', 6) — only when the ramp is a literal.
  RegExp(r"""\btheme\.(?:color|shaded)\(\s*'(\w+)'\s*,\s*(\d)"""): (m) =>
      'color.${m[1]}.${m[2]}',
};

/// Reads that cannot be pinned to one path, and what they are.
///
/// `theme.shaded(colorKey, 6)` is a real token read whose ramp is only
/// known at runtime — the caller passed it. Recording the component as
/// "reads a ramp dynamically" is honest; guessing `color.blue.6`
/// because blue is the default would be a lie that survives until
/// somebody rebrands.
final _dynamic = <RegExp, String>{
  RegExp(r'\btheme\.(?:color|shaded)\(\s*(?!\x27)\w'):
      'a ramp chosen at runtime',
  RegExp(r'\btheme\.space\('): 'the spacing unit, by multiple',
  RegExp(r'\btheme\.readableOn\('):
      'a ramp, resolved against the contrast floor',
  RegExp(r'\btheme\.semanticText\('): 'a semantic role',
};

void main() {
  test('generate docs/TOKENS.md', _generate);
}

void _generate() {
  final dir = Directory('lib/src/widgets');
  if (!dir.existsSync()) {
    fail('Run this from packages/plinth_components.');
  }

  // token path -> widget names, and widget name -> dynamic notes.
  final readers = <String, Set<String>>{};
  final dynamics = <String, Set<String>>{};

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final name = file.uri.pathSegments.last.replaceAll('.dart', '');
    final widget = _widgetName(name);

    final source = file
        .readAsLinesSync()
        // Doc comments carry examples, and an example is not a read.
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');

    _patterns.forEach((pattern, path) {
      for (final match in pattern.allMatches(source)) {
        (readers[path(match)] ??= <String>{}).add(widget);
      }
    });

    _dynamic.forEach((pattern, note) {
      if (pattern.hasMatch(source)) {
        (dynamics[note] ??= <String>{}).add(widget);
      }
    });
  }

  File('../../docs/TOKENS.md').writeAsStringSync(_render(readers, dynamics));
  // ignore: avoid_print
  print('Wrote docs/TOKENS.md — ${readers.length} tokens with a named '
      'reader, ${dynamics.length} kinds of dynamic read.');
}

/// Every token, side by side in both themes.
///
/// The pair is the useful shape: a token whose two values are the same
/// is one a dark theme forgot, and a token whose values are wildly
/// different is one worth looking at before you change either.
void _writeValues(StringBuffer b, Map<String, Set<String>> readers) {
  final light = PlinthTheme.defaultTheme;
  final dark = PlinthTheme.darkTheme;
  final darkByPath = {for (final t in dark.tokens) t.path: t};

  b
    ..writeln('## Every token, in both themes')
    ..writeln()
    ..writeln('| Token | Tier | Light | Dark | Read by |')
    ..writeln('|---|---|---|---|---|');

  for (final token in light.tokens) {
    final other = darkByPath[token.path];
    final count = readers[token.path]?.length ?? 0;
    b.writeln('| `${token.path}` '
        '| ${token.tier.name} '
        '| ${_value(token.value)} '
        '| ${other == null ? '—' : _value(other.value)} '
        '| ${count == 0 ? '—' : '$count'} |');
  }
  b.writeln();
}

String _value(Object v) => switch (v) {
      Color() =>
        '`#${((v.a * 255).round() << 24 | (v.r * 255).round() << 16 | (v.g * 255).round() << 8 | (v.b * 255).round()).toRadixString(16).padLeft(8, '0').substring(2)}`',
      Duration() => '${v.inMilliseconds}ms',
      FontWeight() => 'w${v.value}',
      PlinthElevation() => 'blur ${v.blur}, y ${v.offsetY}',
      double() => v == v.roundToDouble() ? '${v.toInt()}' : '$v',
      _ => '$v',
    };

String _widgetName(String fileName) => fileName
    .split('_')
    .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
    .join();

String _render(
  Map<String, Set<String>> readers,
  Map<String, Set<String>> dynamics,
) {
  final b = StringBuffer()
    ..writeln('# Tokens')
    ..writeln()
    ..writeln('**Generated — do not edit.** Run')
    ..writeln('`dart run tool/generate_token_usage.dart` from')
    ..writeln('`packages/plinth_components`. `token_usage_fresh_test.dart`')
    ..writeln('fails if this file falls behind the source.')
    ..writeln()
    ..writeln('Every token, and which components read it. The question')
    ..writeln('this answers is the one you ask before changing a token,')
    ..writeln('and it was previously answerable only by grepping and')
    ..writeln('hoping you guessed the right spelling — `theme.surface`,')
    ..writeln('`theme.spacing[PlinthSize.md]` and `theme.space(4)` are')
    ..writeln('all token reads and none of them look alike.')
    ..writeln()
    ..writeln('Values come from `PlinthTheme.defaultTheme` and')
    ..writeln('`PlinthTheme.darkTheme`. A rebranded theme has different')
    ..writeln('values and the same readers.')
    ..writeln();

  _writeValues(b, readers);

  b
    ..writeln('## What reads what')
    ..writeln()
    ..writeln('| Token | Components |')
    ..writeln('|---|---|');

  for (final path in readers.keys.toList()..sort()) {
    final names = readers[path]!.toList()..sort();
    // Long lists are noise in a table; the count is the useful part
    // once a token is read by half the library.
    final cell = names.length > 6
        ? '**${names.length} components**, including ${names.take(4).join(', ')}'
        : names.join(', ');
    b.writeln('| `$path` | $cell |');
  }

  b
    ..writeln()
    ..writeln('## Reads that cannot be pinned to one token')
    ..writeln()
    ..writeln('These are real token reads whose target is only known at')
    ..writeln('runtime — the caller passed the ramp. Recording them as a')
    ..writeln('kind rather than guessing a path is deliberate: assuming')
    ..writeln('`color.blue.6` because blue is the default would be a lie')
    ..writeln('that survives until somebody rebrands.')
    ..writeln()
    ..writeln('| Kind of read | Components |')
    ..writeln('|---|---|');

  for (final note in dynamics.keys.toList()..sort()) {
    final names = dynamics[note]!.toList()..sort();
    final cell = names.length > 6
        ? '**${names.length} components**, including ${names.take(4).join(', ')}'
        : names.join(', ');
    b.writeln('| $note | $cell |');
  }

  b
    ..writeln()
    ..writeln('## Tokens nothing reads')
    ..writeln()
    ..writeln('Not necessarily dead. A token can exist for an *adopter*')
    ..writeln('to read rather than for this library to paint with, which')
    ..writeln('is most of the point of a token layer. But a token here')
    ..writeln('that nobody outside can name either is worth a question.')
    ..writeln();

  return b.toString();
}
