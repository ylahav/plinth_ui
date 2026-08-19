// PR-19 — text is checked against the background it actually sits on.
//
// The failure this closes is the silent kind: `readableOn` was called, a
// floor was cleared, and the floor was measured against a surface the
// text never touches.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

double _lum(Color c) {
  double f(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
}

double _cr(Color a, Color b) {
  final x = _lum(a), y = _lum(b);
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

Widget _wrap(Widget child, PlinthTheme theme) => MaterialApp(
      theme: ThemeData(extensions: [theme]),
      home: Scaffold(body: child),
    );

void main() {
  final light = PlinthTheme.defaultTheme;
  final dark = PlinthTheme.darkTheme;
  final themes = {'light': light, 'dark': dark};

  group('PR-19 — PlinthText resolves against its real background', () {
    testWidgets('the default is still the surface', (tester) async {
      // Nothing changes for text on a page, which is most text.
      await tester.pumpWidget(
        _wrap(const PlinthText('a', color: 'teal'), light),
      );
      expect(tester.widget<Text>(find.text('a')).style!.color,
          light.readableOn('teal', light.surface));
    });

    testWidgets('an explicit background changes the resolution',
        (tester) async {
      const tint = Color(0xFFE9FAC8);
      await tester.pumpWidget(_wrap(
        const Column(children: [
          PlinthText('a', color: 'teal'),
          PlinthText('b', color: 'teal', on: tint),
        ]),
        light,
      ));
      final a = tester.widget<Text>(find.text('a')).style!.color!;
      final b = tester.widget<Text>(find.text('b')).style!.color!;
      expect(a, light.readableOn('teal', light.surface));
      expect(b, light.readableOn('teal', tint));
      expect(_cr(b, tint), greaterThanOrEqualTo(PlinthContrast.body.ratio));
    });

    testWidgets('every alert title clears the floor on its own background',
        (tester) async {
      // Was 3 of 13 failing in light and 1 in dark -- marginally, at
      // 4.35 to 4.48, which is exactly why nobody noticed.
      for (final entry in themes.entries) {
        final theme = entry.value;
        for (final key in theme.colors.keys) {
          await tester.pumpWidget(_wrap(
            PlinthAlert(color: key, title: 'Title', child: const Text('Body')),
            theme,
          ));
          await tester.pumpAndSettle();
          final color = tester.widget<Text>(find.text('Title')).style!.color!;
          expect(
            _cr(color, theme.shaded(key, 0)),
            greaterThanOrEqualTo(PlinthContrast.body.ratio - 0.01),
            reason: '$key alert title in ${entry.key}',
          );
        }
      }
    });
  });

  group('PR-19 — a highlighted run gets its own foreground', () {
    testWidgets('marked text is legible on the mark, in both themes',
        (tester) async {
      // Was 9 of 13 failing in light and 13 of 13 in dark. The marked
      // run is the entire point of the widget, and it was the part that
      // failed.
      //
      for (final entry in themes.entries) {
        final theme = entry.value;
        for (final key in theme.colors.keys) {
          await tester.pumpWidget(_wrap(
            PlinthHighlight('find the match',
                highlight: const ['match'], color: key, textColor: key),
            theme,
          ));
          await tester.pumpAndSettle();
          final span =
              tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
          final marked = span.children!
              .cast<TextSpan>()
              .firstWhere((s) => s.style?.backgroundColor != null);
          expect(
            _cr(marked.style!.color!, marked.style!.backgroundColor!),
            greaterThanOrEqualTo(PlinthContrast.body.ratio - 0.01),
            reason: '$key marked run in ${entry.key}',
          );
        }
      }
    });

    testWidgets('unmarked text still resolves against the surface',
        (tester) async {
      // The two runs have different backgrounds, so they get different
      // foregrounds. One colour clearing both is not available: for 8 of
      // the 26 ramp/theme pairings no shade clears 4.5:1 against the
      // surface and that ramp's own tint at once, because the tint sits
      // too close to the ramp's middle.
      for (final entry in themes.entries) {
        final theme = entry.value;
        for (final key in theme.colors.keys) {
          await tester.pumpWidget(_wrap(
            PlinthHighlight('find the match',
                highlight: const ['match'], color: key, textColor: key),
            theme,
          ));
          await tester.pumpAndSettle();
          final span =
              tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
          final plain = span.children!
              .cast<TextSpan>()
              .firstWhere((s) => s.style?.backgroundColor == null);
          expect(plain.style!.color, theme.readableOn(key, theme.surface),
              reason: '$key unmarked run in ${entry.key}');
          expect(
            _cr(plain.style!.color!, theme.surface),
            greaterThanOrEqualTo(PlinthContrast.body.ratio - 0.01),
          );
        }
      }
    });

    testWidgets('the two runs genuinely differ where the tint demands it',
        (tester) async {
      // If they were ever the same colour everywhere, the per-span split
      // would be pointless and this test would be the one to say so.
      var differing = 0;
      for (final key in light.colors.keys) {
        await tester.pumpWidget(_wrap(
          PlinthHighlight('find the match',
              highlight: const ['match'], color: key, textColor: key),
          light,
        ));
        await tester.pumpAndSettle();
        final span =
            tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
        final children = span.children!.cast<TextSpan>();
        final marked =
            children.firstWhere((s) => s.style?.backgroundColor != null);
        final plain =
            children.firstWhere((s) => s.style?.backgroundColor == null);
        if (marked.style!.color != plain.style!.color) differing++;
      }
      expect(differing, greaterThan(0));
    });

    testWidgets('an uncoloured highlight is still legible on its mark',
        (tester) async {
      // textColor omitted: the run inherits, but the mark is painted
      // regardless, so the foreground still has to clear it.
      await tester.pumpWidget(_wrap(
        const PlinthHighlight('find the match', highlight: ['match']),
        light,
      ));
      final span = tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
      final marked = span.children!
          .cast<TextSpan>()
          .firstWhere((s) => s.style?.backgroundColor != null);
      expect(
        _cr(marked.style!.color!, marked.style!.backgroundColor!),
        greaterThanOrEqualTo(PlinthContrast.body.ratio - 0.01),
      );
    });
  });
}
