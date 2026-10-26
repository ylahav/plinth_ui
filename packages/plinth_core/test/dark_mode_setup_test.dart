/// The dark-mode setup the documentation shows has to produce readable text.
///
/// It did not. Every README, the dartdoc on `PlinthTheme.darkTheme`, and the
/// four published examples registered the dark extension on a `ThemeData`
/// whose brightness was left at its default, light. Plinth text with no
/// colour of its own inherits Material's, which follows that brightness, so
/// the text painted on the dark surface was `#1D1B20` on `#1A1B1E`: 1.01:1.
/// The four starters, the goldens and the showcase all set the brightness
/// and never hit it; the documentation was the only place that did not.
///
/// Nothing tested the snippets' *behaviour* — only the numbers the README
/// quotes — so the documented setup went out broken.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

/// Walks up from wherever the runner started until the repo root.
Directory _repoRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    if (File('${dir.path}/melos.yaml').existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError('could not find the repo root from ${Directory.current}');
}

/// The colour that text with no colour of its own is painted in, inside a
/// `Scaffold` — what `PlinthText` falls back to — under [darkTheme].
Future<Color> _paintedTextColour(
    WidgetTester tester, ThemeData darkTheme) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const Scaffold(body: Text('Hello')),
    ),
  );
  final style = DefaultTextStyle.of(tester.element(find.text('Hello'))).style;
  return style.color!;
}

void main() {
  final dark = PlinthTheme.darkTheme;

  group('the documented dark setup', () {
    testWidgets('paints body text a reader can read', (tester) async {
      // The snippet exactly as the READMEs show it.
      final color = await _paintedTextColour(
        tester,
        ThemeData(
          brightness: Brightness.dark,
          extensions: [PlinthTheme.darkTheme],
        ),
      );

      expect(
        PlinthTheme.contrastRatio(color, dark.surface),
        greaterThanOrEqualTo(PlinthContrast.body.ratio),
      );
    });

    testWidgets('and the setup it replaced did not', (tester) async {
      // The control. Without it the test above could pass for a reason
      // that has nothing to do with `brightness`.
      final color = await _paintedTextColour(
        tester,
        ThemeData(extensions: [PlinthTheme.darkTheme]),
      );

      expect(
        PlinthTheme.contrastRatio(color, dark.surface),
        lessThan(PlinthContrast.body.ratio),
        reason: 'if this now passes, Flutter changed what an unset brightness '
            'means and the documentation can be simplified',
      );
    });
  });

  group('every place that shows the setup', () {
    // A `darkTheme: ThemeData(...)` block that registers the Plinth dark
    // extension. `[^)]*` is enough: the documented block has no nested
    // parentheses, and a block that grew some would fail loudly rather than
    // be skipped.
    final block =
        RegExp(r'darkTheme: ThemeData\(([^)]*PlinthTheme\.darkTheme[^)]*)\)');

    const files = [
      'README.md',
      'docs/COMPONENTS.md',
      'packages/plinth_core/README.md',
      'packages/plinth_core/lib/src/plinth_theme.dart',
      'packages/plinth_blocks/README.md',
      'packages/plinth_core/example/lib/main.dart',
      'packages/plinth_components/example/lib/main.dart',
      'packages/plinth_blocks/example/lib/main.dart',
      'packages/plinth_charts/example/lib/main.dart',
    ];

    for (final path in files) {
      test('$path sets brightness', () {
        final text = File('${_repoRoot().path}/$path').readAsStringSync();
        final matches = block.allMatches(text).toList();

        expect(matches, isNotEmpty,
            reason: '$path no longer shows the dark setup; drop it from this '
                'list if that was deliberate');
        for (final m in matches) {
          expect(m.group(1), contains('brightness: Brightness.dark'),
              reason: 'the dark ThemeData in $path leaves brightness light, '
                  'which makes Plinth text near-invisible on the dark surface');
        }
      });
    }
  });
}
