import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// Same wrapper as plinth_button_test.dart, but sized to a fixed
/// rectangle via [RepaintBoundary] + [SizedBox] rather than filling
/// the whole test surface — golden images should be tightly cropped
/// around the widget under test, not a full-screen screenshot, so a
/// diff actually highlights what changed instead of drowning it in
/// unrelated whitespace.
Widget _goldenWrap(Widget child, {double width = 300, double height = 100}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: const ValueKey('golden-boundary'),
          child: SizedBox(
            width: width,
            height: height,
            child: Center(child: child),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('PlinthButton golden', () {
    // NOTE: flutter test renders with a placeholder test font (not
    // your system fonts) by default, which is what makes these
    // images reproducible across machines/CI without extra setup —
    // text renders as solid blocks rather than real glyphs. That's
    // expected and fine: these still catch color/layout/padding
    // regressions, just not font-rendering ones.
    //
    // First run: `flutter test --update-goldens` from this package
    // to generate the reference images under test/goldens/. Every
    // run after that compares against those committed images.

    testWidgets('filled variant', (tester) async {
      await tester.pumpWidget(
        _goldenWrap(
          PlinthButton(onPressed: () {}, child: const Text('Save')),
        ),
      );
      await expectLater(
        find.byKey(const ValueKey('golden-boundary')),
        matchesGoldenFile('goldens/plinth_button_filled.png'),
      );
    });

    testWidgets('outline variant', (tester) async {
      await tester.pumpWidget(
        _goldenWrap(
          PlinthButton(
            variant: PlinthVariant.outline,
            onPressed: () {},
            child: const Text('Save'),
          ),
        ),
      );
      await expectLater(
        find.byKey(const ValueKey('golden-boundary')),
        matchesGoldenFile('goldens/plinth_button_outline.png'),
      );
    });

    testWidgets('light variant, red color', (tester) async {
      await tester.pumpWidget(
        _goldenWrap(
          PlinthButton(
            variant: PlinthVariant.light,
            color: 'red',
            onPressed: () {},
            child: const Text('Delete'),
          ),
        ),
      );
      await expectLater(
        find.byKey(const ValueKey('golden-boundary')),
        matchesGoldenFile('goldens/plinth_button_light_red.png'),
      );
    });

    testWidgets('disabled', (tester) async {
      await tester.pumpWidget(
        _goldenWrap(
          const PlinthButton(onPressed: null, child: Text('Save')),
        ),
      );
      await expectLater(
        find.byKey(const ValueKey('golden-boundary')),
        matchesGoldenFile('goldens/plinth_button_disabled.png'),
      );
    });

    testWidgets('all sizes side by side', (tester) async {
      await tester.pumpWidget(
        _goldenWrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final size in PlinthSize.values) ...[
                PlinthButton(size: size, onPressed: () {}, child: Text(size.name)),
                const SizedBox(width: 8),
              ],
            ],
          ),
          width: 480,
          height: 80,
        ),
      );
      await expectLater(
        find.byKey(const ValueKey('golden-boundary')),
        matchesGoldenFile('goldens/plinth_button_sizes.png'),
      );
    });
  });
}
