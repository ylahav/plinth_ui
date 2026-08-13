import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

// flutter_test's HttpClient answers every request with a 400, so every
// PlinthBackgroundImage here exercises the failure path. That is the
// path worth pinning: content over a background must survive the
// background not arriving.
void main() {
  group('PlinthBackgroundImage', () {
    testWidgets('takes the size it is given', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBackgroundImage(
            src: 'https://example.com/hero.jpg',
            width: 300,
            height: 200,
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSize(find.byType(PlinthBackgroundImage)),
        const Size(300, 200),
      );
    });

    testWidgets('keeps rendering its child when the image fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBackgroundImage(
            src: 'https://example.com/missing.jpg',
            height: 200,
            child: Text('Ships tomorrow'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ships tomorrow'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays a scrim between image and content by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBackgroundImage(
            src: 'https://example.com/hero.jpg',
            height: 200,
            child: Text('Over the top'),
          ),
        ),
      );
      await tester.pump();

      final theme = PlinthTheme.defaultTheme;
      final scrims = tester
          .widgetList<ColoredBox>(
            find.descendant(
              of: find.byType(PlinthBackgroundImage),
              matching: find.byType(ColoredBox),
            ),
          )
          .where((box) => box.color.a > 0 && box.color.a < 1);

      expect(scrims, hasLength(1));
      expect(scrims.first.color, theme.scrim.withValues(alpha: 0.35));
    });

    testWidgets('scrimOpacity: 0 draws no scrim', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBackgroundImage(
            src: 'https://example.com/hero.jpg',
            height: 200,
            scrimOpacity: 0,
            child: Text('Bare'),
          ),
        ),
      );
      await tester.pump();

      final translucent = tester
          .widgetList<ColoredBox>(
            find.descendant(
              of: find.byType(PlinthBackgroundImage),
              matching: find.byType(ColoredBox),
            ),
          )
          .where((box) => box.color.a > 0 && box.color.a < 1);

      expect(translucent, isEmpty);
    });

    testWidgets('content takes the on-fill foreground, not body text colour', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBackgroundImage(
            src: 'https://example.com/hero.jpg',
            height: 200,
            child: Text('Legible'),
          ),
        ),
      );
      await tester.pump();

      final style = DefaultTextStyle.of(
        tester.element(find.text('Legible')),
      ).style;
      expect(style.color, PlinthTheme.defaultTheme.onFilled);
    });

    testWidgets('alignment places the child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBackgroundImage(
            src: 'https://example.com/hero.jpg',
            width: 300,
            height: 200,
            alignment: Alignment.bottomLeft,
            child: Text('Corner'),
          ),
        ),
      );
      await tester.pump();

      final outer = tester.getRect(find.byType(PlinthBackgroundImage));
      final child = tester.getRect(find.text('Corner'));
      expect(child.left, closeTo(outer.left, 0.01));
      expect(child.bottom, closeTo(outer.bottom, 0.01));
    });
  });
}
