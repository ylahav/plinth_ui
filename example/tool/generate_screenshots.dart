// Renders the pub.dev screenshots for `plinth_components`.
//
// Run explicitly — it writes files, so it deliberately lives outside
// `test/` and is not picked up by `melos run test`:
//
//     cd example
//     flutter test tool/generate_screenshots.dart
//
// Output lands in `packages/plinth_components/screenshots/`, which is
// what the package's `screenshots:` entries point at.
//
// **Why this isn't a golden test.** `flutter test` renders with a
// placeholder font by default — text comes out as solid blocks, which
// is exactly what makes goldens reproducible and exactly what makes
// them useless as marketing images. So this loads the real Roboto that
// ships in the Flutter SDK cache before rendering.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// Where the Flutter SDK keeps the fonts it bundles.
///
/// Found by walking up from the running Dart executable rather than
/// counting directory levels — the depth of `dart` inside the SDK is
/// an implementation detail that has already moved once — and rather
/// than reading FLUTTER_ROOT, which isn't reliably set inside a test
/// process.
String _materialFontsDir() {
  var dir = File(Platform.resolvedExecutable).parent;

  for (var i = 0; i < 8; i++) {
    final candidate =
        Directory('${dir.path}/bin/cache/artifacts/material_fonts');
    if (candidate.existsSync()) return candidate.path;
    if (dir.path == dir.parent.path) break; // hit the filesystem root
    dir = dir.parent;
  }

  throw StateError(
    'Could not locate the Flutter SDK fonts above '
    '${Platform.resolvedExecutable}',
  );
}

Future<void> _loadFonts() async {
  final root = _materialFontsDir();

  // Roboto under one family for the text, and MaterialIcons under its
  // own — without the second, every icon renders as an empty box,
  // which is not obviously a *font* problem when you first see it.
  const families = {
    'Roboto': [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
    ],
    'MaterialIcons': ['materialicons-regular.otf'],
  };

  for (final family in families.entries) {
    final loader = FontLoader(family.key);
    for (final name in family.value) {
      final file = File('$root/$name');
      if (!file.existsSync()) {
        throw StateError('Font not found: ${file.path}');
      }
      loader.addFont(
        Future.value(file.readAsBytesSync().buffer.asByteData()),
      );
    }
    await loader.load();
  }
}

/// Renders [child] and writes it to `screenshots/<name>.png`.
Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required Widget child,
  required Size size,
  bool dark = false,
}) async {
  final plinth = dark ? PlinthTheme.darkTheme : PlinthTheme.defaultTheme;

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: plinth.brightness,
        fontFamily: 'Roboto',
        extensions: [plinth],
      ),
      home: Scaffold(
        backgroundColor: plinth.surface,
        body: RepaintBoundary(
          key: const ValueKey('shot'),
          child: Container(
            width: size.width,
            height: size.height,
            // The surface colour has to be painted *inside* the
            // boundary. The Scaffold's own background sits above it in
            // the tree, so it isn't captured — which produced a dark
            // theme screenshot on a white page.
            color: plinth.surface,
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    ),
  );
  // Explicit pumps rather than pumpAndSettle: something in here never
  // reaches a steady state — a cursor, a ripple — and pumpAndSettle
  // waits ten minutes before giving up. Two frames is enough for a
  // still image, and nothing being captured is mid-animation.
  await tester.pump(const Duration(milliseconds: 32));
  await tester.pump(const Duration(milliseconds: 32));

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('shot')),
  );

  // runAsync is required, not optional: PNG encoding runs on the real
  // event loop, and `testWidgets` drives a fake one. Without it the
  // future simply never completes and the run hangs with no error —
  // which is exactly how this failed the first time.
  await tester.runAsync(() async {
    // 3x so the images stay crisp on the high-density displays most
    // people browsing pub.dev are using.
    final image = await boundary.toImage(pixelRatio: 3.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    final out = File('../packages/plinth_components/screenshots/$name.png')
      ..createSync(recursive: true);
    out.writeAsBytesSync(bytes!.buffer.asUint8List());

    // ignore: avoid_print
    print('wrote ${out.path} (${(out.lengthSync() / 1024).round()} KB)');
  });
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('components', (tester) async {
    await _capture(
      tester,
      name: 'components',
      size: const Size(420, 380),
      child: PlinthStack(
        gap: PlinthSize.md,
        children: [
          const PlinthTitle('Create an account', order: 4),
          const PlinthTextInput(
            label: 'Email',
            placeholder: 'you@example.com',
          ),
          const PlinthTextInput(
            label: 'Password',
            error: 'Must be at least 8 characters',
          ),
          PlinthGroup(
            children: [
              const PlinthBadge('New', color: 'green'),
              const PlinthBadge('Beta', color: 'violet'),
              PlinthPill('design', onRemove: () {}),
            ],
          ),
          PlinthButton(
            fullWidth: true,
            onPressed: () {},
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
  });

  testWidgets('dark mode', (tester) async {
    await _capture(
      tester,
      name: 'dark-mode',
      size: const Size(420, 400),
      dark: true,
      child: PlinthStack(
        gap: PlinthSize.md,
        children: [
          const PlinthTitle('Dark mode is a value swap', order: 4),
          const PlinthAlert(
            title: 'Shades mirror',
            child: Text('A shade-0 wash stays a wash instead of going white.'),
          ),
          const PlinthTextInput(label: 'Search', placeholder: 'Type here'),
          PlinthGroup(
            children: [
              PlinthButton(onPressed: () {}, child: const Text('Filled')),
              PlinthButton(
                variant: PlinthVariant.outline,
                onPressed: () {},
                child: const Text('Outline'),
              ),
              PlinthButton(
                variant: PlinthVariant.light,
                color: 'red',
                onPressed: () {},
                child: const Text('Danger'),
              ),
            ],
          ),
        ],
      ),
    );
  });

  testWidgets('data', (tester) async {
    await _capture(
      tester,
      name: 'data-display',
      size: const Size(520, 320),
      child: const PlinthStack(
        gap: PlinthSize.md,
        children: [
          PlinthTitle('Sortable, filterable tables', order: 4),
          PlinthTable(
            columns: ['Name', 'Role', 'Status'],
            sortable: true,
            striped: true,
            sortValues: [
              ['Alice Nguyen', 'Engineer', 'Active'],
              ['Ben Kaur', 'Designer', 'Invited'],
              ['Cara Diaz', 'Support', 'Active'],
            ],
            rows: [
              [
                PlinthText('Alice Nguyen'),
                PlinthText('Engineer'),
                PlinthBadge('Active', color: 'green'),
              ],
              [
                PlinthText('Ben Kaur'),
                PlinthText('Designer'),
                PlinthBadge('Invited', color: 'gray'),
              ],
              [
                PlinthText('Cara Diaz'),
                PlinthText('Support'),
                PlinthBadge('Active', color: 'green'),
              ],
            ],
          ),
        ],
      ),
    );
  });

  testWidgets('palette', (tester) async {
    await _capture(
      tester,
      name: 'theming',
      size: const Size(520, 350),
      child: Builder(
        builder: (context) {
          final theme = context.plinth;
          const ramps = ['blue', 'teal', 'green', 'yellow', 'red', 'violet'];

          return PlinthStack(
            gap: PlinthSize.md,
            children: [
              const PlinthTitle('Thirteen generated ramps', order: 4),
              const PlinthText(
                'Every colour prop is a key into these. Contrast is '
                'asserted against WCAG AA in the theme test suite.',
                size: PlinthSize.sm,
                color: 'gray',
              ),
              for (final ramp in ramps)
                Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: PlinthText(ramp, size: PlinthSize.xs),
                    ),
                    for (var shade = 0; shade < 10; shade++)
                      Expanded(
                        child: Container(
                          height: 18,
                          color: theme.shaded(ramp, shade),
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  });
}
