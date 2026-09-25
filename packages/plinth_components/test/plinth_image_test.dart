/// An image that knows where it loads from, and what to draw when it
/// cannot.
///
/// Found while converting an existing app onto Plinth, which needed
/// three things this was missing: bundled assets, an `Authorization`
/// header for photos behind a login, and a placeholder that was not a
/// broken-image icon.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: Scaffold(body: Center(child: child)),
      ),
    );

/// Paints [painter] into a bitmap, so "the same seed draws the same
/// shape" can be asserted on pixels rather than on trust.
///
/// Inside `runAsync` because `toImage` and `toByteData` are real engine
/// calls: awaited in the fake-async zone `testWidgets` runs in, they
/// never complete and the test hangs.
Future<Uint8List> _render(WidgetTester tester, CustomPainter painter) async {
  final bytes = await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), const Size(100, 100));
    final image = await recorder.endRecording().toImage(100, 100);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  return bytes!;
}

CustomPainter _painterOf(WidgetTester tester) =>
    tester.widget<CustomPaint>(find.byType(CustomPaint).last).painter!;

void main() {
  group('src decides the loader', () {
    test('a URL is a network image', () {
      expect(PlinthImage.sourceOf('https://example.com/a.jpg'),
          PlinthImageSource.network);
      expect(PlinthImage.sourceOf('http://example.com/a.jpg'),
          PlinthImageSource.network);
      expect(PlinthImage.sourceOf('HTTPS://EXAMPLE.COM/A.JPG'),
          PlinthImageSource.network,
          reason: 'the scheme is case-insensitive');
    });

    test('a path or a filename is an asset', () {
      expect(PlinthImage.sourceOf('assets/hero.png'), PlinthImageSource.asset);
      expect(PlinthImage.sourceOf('hero.png'), PlinthImageSource.asset);
    });

    test('a bare identifier is neither', () {
      // The case that matters: an id reaching Image.asset throws rather
      // than falling back, so it must not be treated as a path.
      expect(PlinthImage.sourceOf('hero-42'), PlinthImageSource.none);
      expect(PlinthImage.sourceOf(''), PlinthImageSource.none);
      expect(PlinthImage.sourceOf('   '), PlinthImageSource.none);
    });
  });

  group('network', () {
    testWidgets('headers are passed to the request', (tester) async {
      await _pump(
        tester,
        const PlinthImage(
          src: 'https://example.com/a.jpg',
          headers: {'Authorization': 'Bearer token'},
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final provider = image.image as NetworkImage;
      expect(provider.headers, {'Authorization': 'Bearer token'});
    });

    testWidgets('a failed load shows the fallback, not a render error',
        (tester) async {
      await _pump(
        tester,
        const PlinthImage(
          src: 'https://example.com/missing.jpg',
          width: 100,
          height: 100,
          fallback: PlinthImageFallback(seed: 'x'),
        ),
      );
      // flutter_test's HTTP client answers 400, so this is the real
      // error path rather than a simulated one. Pumped rather than
      // settled: the loading spinner animates forever, so pumpAndSettle
      // would never return.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(PlinthImageFallback), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a bare identifier renders the fallback without loading',
      (tester) async {
    await _pump(
      tester,
      const PlinthImage(
        src: 'hero-42',
        width: 100,
        height: 100,
        fallback: PlinthImageFallback(seed: 'hero-42'),
      ),
    );

    expect(find.byType(PlinthImageFallback), findsOneWidget);
    expect(find.byType(Image), findsNothing,
        reason: 'nothing to fetch, so nothing should be attempted');
  });

  testWidgets('with no fallback given, the icon still stands', (tester) async {
    await _pump(
      tester,
      const PlinthImage(src: 'hero-42', width: 100, height: 100),
    );
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  group('PlinthImageFallback is seed-stable', () {
    testWidgets('the same seed draws the same shape', (tester) async {
      await _pump(
          tester,
          const SizedBox(
              width: 100,
              height: 100,
              child: PlinthImageFallback(seed: 'squat')));
      final first = await _render(tester, _painterOf(tester));

      // A separate build, as a scroll or a setState would produce.
      await _pump(tester, const SizedBox.shrink());
      await _pump(
          tester,
          const SizedBox(
              width: 100,
              height: 100,
              child: PlinthImageFallback(seed: 'squat')));
      final second = await _render(tester, _painterOf(tester));

      expect(second, first,
          reason: 'placeholders must not reshuffle on every rebuild');
    });

    testWidgets('a different seed draws a different shape', (tester) async {
      await _pump(
          tester,
          const SizedBox(
              width: 100,
              height: 100,
              child: PlinthImageFallback(seed: 'squat')));
      final squat = await _render(tester, _painterOf(tester));

      await _pump(
          tester,
          const SizedBox(
              width: 100,
              height: 100,
              child: PlinthImageFallback(seed: 'deadlift')));
      final deadlift = await _render(tester, _painterOf(tester));

      expect(deadlift, isNot(squat),
          reason: 'otherwise a list of placeholders is indistinguishable');
    });

    testWidgets('an empty seed still paints rather than throwing',
        (tester) async {
      await _pump(
          tester,
          const SizedBox(
              width: 100, height: 100, child: PlinthImageFallback()));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('the fallback figure clears the non-text contrast floor',
      (tester) async {
    final theme = PlinthTheme.defaultTheme;
    // What the widget computes internally, asserted against WCAG 1.4.11.
    final fill = theme.wash('green', alpha: 0.10);
    final figure =
        theme.readableOn('green', fill, level: PlinthContrast.nonText);

    expect(PlinthTheme.contrastRatio(figure, fill), greaterThanOrEqualTo(3.0),
        reason: 'a placeholder nobody can see is not a placeholder');
  });

  group('semantics', () {
    testWidgets('an image with no label is decorative', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
          tester, const PlinthImage(src: 'hero-42', width: 50, height: 50));

      expect(find.bySemanticsLabel('hero-42'), findsNothing,
          reason: 'the src is not a description');
      handle.dispose();
    });

    testWidgets('a label describes it', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const PlinthImage(
            src: 'hero-42',
            width: 50,
            height: 50,
            semanticLabel: 'Barbell back squat'),
      );

      expect(find.bySemanticsLabel('Barbell back squat'), findsOneWidget);
      handle.dispose();
    });
  });
}
