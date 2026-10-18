/// What a chip does when its label does not fit.
///
/// Found in CaptureGuide: tip titles used as link chips in a `Wrap`
/// overflowed on a phone — `A RenderFlex overflowed by 19 pixels on the
/// right` for a Hebrew title — and the app replaced `PlinthChip` with its
/// own chip to get around it.
///
/// As with the segmented control, the case a naive fix gets wrong is the
/// last group: a chip that fits must be left exactly as it was.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

const _long = 'Slowest safe shutter speed for handheld shots';
const _hebrew = 'מהירות התריס האיטית הבטוחה לצילום ביד';

Future<void> _pump(
  WidgetTester tester, {
  String label = _long,
  bool selected = false,
  double? width,
  double? maxWidth,
  bool horizontalScroll = false,
  TextDirection direction = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  Widget chip = PlinthChip(
    label: label,
    selected: selected,
    onSelected: (_) {},
  );

  if (horizontalScroll) {
    chip = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: chip,
    );
  } else if (width != null) {
    // Tight: exactly this much room, which is the overflow case.
    chip = SizedBox(width: width, child: chip);
  } else if (maxWidth != null) {
    // Loose: up to this much. Only a loose bound shows whether the chip
    // still shrink-wraps its label.
    chip = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: chip,
    );
  }

  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Directionality(textDirection: direction, child: child!),
    ),
    home: Scaffold(body: Center(child: chip)),
  ));
}

Size _chipSize(WidgetTester tester) =>
    tester.getSize(find.byType(PlinthChip));

void main() {
  group('a narrow parent no longer overflows', () {
    testWidgets('120px, a long label', (tester) async {
      await _pump(tester, width: 120);
      expect(tester.takeException(), isNull,
          reason: 'the label kept its natural width and overflowed before');
    });

    testWidgets('and the chip stays inside the width it was given',
        (tester) async {
      await _pump(tester, width: 120);
      expect(_chipSize(tester).width, lessThanOrEqualTo(120));
    });

    testWidgets('selected, with the checkmark taking room too',
        (tester) async {
      await _pump(tester, width: 120, selected: true);
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('right to left, which is how it was found', (tester) async {
      await _pump(
        tester,
        label: _hebrew,
        width: 160,
        direction: TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('down to an absurd width', (tester) async {
      await _pump(tester, width: 40);
      expect(tester.takeException(), isNull);
    });

    testWidgets('and at 200% text scale', (tester) async {
      await _pump(tester, width: 200, textScaler: const TextScaler.linear(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('the label truncates rather than wraps', () {
    testWidgets('one line, ellipsised', (tester) async {
      await _pump(tester, width: 120);
      final text = tester.widget<Text>(find.text(_long));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.softWrap, isFalse);
    });

    testWidgets('the chip keeps one line of height', (tester) async {
      // Wrapping instead would change the chip's height — in a Wrap of
      // chips, the same bug moved somewhere else.
      await _pump(tester, maxWidth: 600);
      final tall = _chipSize(tester).height;
      await _pump(tester, width: 100);
      expect(_chipSize(tester).height, tall,
          reason: 'a squeezed chip must not grow taller');
    });

    testWidgets('and the full label still reaches a screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, width: 100);
      expect(find.bySemanticsLabel(_long), findsOneWidget);
      handle.dispose();
    });
  });

  group('a chip that fits is left alone', () {
    testWidgets('with room to spare, the width is the natural width',
        (tester) async {
      await _pump(tester, label: 'Blue', maxWidth: 600);
      final roomy = _chipSize(tester).width;

      // Unbounded: pure natural width, nothing divided.
      await _pump(tester, label: 'Blue', horizontalScroll: true);
      final natural = _chipSize(tester).width;

      expect(roomy, natural,
          reason: 'a chip that fits must lay out exactly as before the fix');
    });
  });

  group('the unbounded case still works', () {
    testWidgets('inside a horizontal scroll view, nothing throws',
        (tester) async {
      // A flex child in an unbounded row is a layout error, which is why
      // the Flexible is behind a hasBoundedWidth check.
      await _pump(tester, horizontalScroll: true);
      expect(tester.takeException(), isNull);
    });

    testWidgets('and keeps its full natural width there', (tester) async {
      // With no width to divide, the label is not truncated: the chip is
      // as wide as the label wants, far wider than the squeezed case.
      await _pump(tester, horizontalScroll: true);
      final natural = _chipSize(tester).width;
      await _pump(tester, width: 120);
      expect(natural, greaterThan(_chipSize(tester).width));
    });
  });
}
