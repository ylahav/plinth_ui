/// What a segmented control does when its labels do not fit.
///
/// Found converting bClock, whose German labels overflowed the control
/// on a phone — `A RenderFlex overflowed by 511 pixels on the right` for
/// the case below. The app worked around it in two places, Settings and
/// the Clock tab's toggle.
///
/// Three things are asserted here, and the third is the one a naive fix
/// gets wrong: it must not truncate a row that actually fits.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

const _long = [
  PlinthSegmentedControlItem('a', 'Analoguhr anzeigen'),
  PlinthSegmentedControlItem('b', 'Digitaluhr anzeigen'),
];

const _short = [
  PlinthSegmentedControlItem('list', 'List'),
  PlinthSegmentedControlItem('grid', 'Grid'),
];

Future<void> _pump(
  WidgetTester tester, {
  double? width,
  double? maxWidth,
  List<PlinthSegmentedControlItem<String>> items = _long,
  bool fullWidth = false,
  bool horizontalScroll = false,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  Widget control = PlinthSegmentedControl<String>(
    value: items.first.value,
    onChanged: (_) {},
    items: items,
    fullWidth: fullWidth,
  );

  if (horizontalScroll) {
    control = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: control,
    );
  } else if (width != null) {
    // Tight: the control is in a slot of exactly this width, which is
    // the overflow case.
    control = SizedBox(width: width, child: control);
  } else if (maxWidth != null) {
    // Loose: room up to this much. Only a loose bound can show whether
    // the control shrink-wraps, because a tight one forces its width
    // whatever the labels want.
    control = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: control,
    );
  }

  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: Scaffold(body: Center(child: control)),
  ));
}

List<Text> _labels(WidgetTester tester) =>
    tester.widgetList<Text>(find.byType(Text)).toList();

void main() {
  group('a narrow parent no longer overflows', () {
    testWidgets('160px, two long German labels', (tester) async {
      await _pump(tester, width: 160);
      expect(tester.takeException(), isNull,
          reason: 'this overflowed by 511px before the fix');
    });

    testWidgets('and the control stays inside the width it was given',
        (tester) async {
      await _pump(tester, width: 160);
      expect(tester.getSize(find.byType(PlinthSegmentedControl<String>)).width,
          lessThanOrEqualTo(160));
    });

    testWidgets('down to an absurd width', (tester) async {
      await _pump(tester, width: 40);
      expect(tester.takeException(), isNull);
    });

    testWidgets('and at 200% text scale, which is the real-world case',
        (tester) async {
      // A German label at double the text size is how this was found —
      // a long translation and an accessibility setting compound.
      await _pump(tester, width: 200, textScaler: const TextScaler.linear(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('labels truncate rather than wrap', () {
    testWidgets('one line, ellipsised', (tester) async {
      await _pump(tester, width: 160);
      for (final label in _labels(tester)) {
        expect(label.maxLines, 1);
        expect(label.overflow, TextOverflow.ellipsis);
        expect(label.softWrap, isFalse);
      }
    });

    testWidgets('the control keeps one line of height', (tester) async {
      // Wrapping instead of truncating is the same bug wearing a
      // different hat: it changes the control's height.
      await _pump(tester, width: 400);
      final tall =
          tester.getSize(find.byType(PlinthSegmentedControl<String>)).height;
      await _pump(tester, width: 120);
      expect(tester.getSize(find.byType(PlinthSegmentedControl<String>)).height,
          tall,
          reason: 'a squeezed control must not grow taller');
    });

    testWidgets('and the full label still reaches a screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, width: 120);
      // Truncation is visual; the semantics carry the whole string.
      expect(find.bySemanticsLabel('Analoguhr anzeigen'), findsOneWidget);
      handle.dispose();
    });
  });

  group('a row that fits is left alone', () {
    testWidgets('short labels keep their natural width', (tester) async {
      await _pump(tester, items: _short, maxWidth: 600);
      final wide =
          tester.getSize(find.byType(PlinthSegmentedControl<String>)).width;

      // Unbounded: pure natural width, nothing divided.
      await _pump(tester, items: _short, horizontalScroll: true);
      final natural =
          tester.getSize(find.byType(PlinthSegmentedControl<String>)).width;

      expect(wide, natural,
          reason: 'with room to spare the layout must be identical to '
              'before the fix');
    });

    testWidgets('an uneven pair that fits is not truncated', (tester) async {
      // The case equal-share Flexible gets wrong: one short label and one
      // long one whose total fits. Shared equally, the long one is capped
      // at half the width and ellipsised for no reason. Weighted by
      // natural width, both get what they asked for.
      const uneven = [
        PlinthSegmentedControlItem('s', 'On'),
        PlinthSegmentedControlItem('l', 'Show seconds hand'),
      ];

      await _pump(tester, items: uneven, horizontalScroll: true);
      final natural =
          tester.getSize(find.byType(PlinthSegmentedControl<String>)).width;

      // Comfortably more room than it needs.
      await _pump(tester, items: uneven, maxWidth: natural + 60);
      expect(tester.getSize(find.byType(PlinthSegmentedControl<String>)).width,
          natural,
          reason: 'equal shares would have squeezed the long label here');
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

    testWidgets('and labels are not clipped there', (tester) async {
      await _pump(tester, horizontalScroll: true);
      // Natural width means the full label is drawn, ellipsis settings
      // notwithstanding — there is no constraint to trip them.
      expect(find.text('Analoguhr anzeigen'), findsOneWidget);
    });
  });

  testWidgets('fullWidth still stretches to fill', (tester) async {
    await _pump(tester, items: _short, width: 400, fullWidth: true);
    expect(tester.takeException(), isNull);
    expect(
        tester.getSize(find.byType(PlinthSegmentedControl<String>)).width, 400);
  });

  testWidgets('selecting a different segment does not resize anything',
      (tester) async {
    // Widths are measured at semibold regardless of selection, so the
    // control must not twitch when the selection moves.
    const items = [
      PlinthSegmentedControlItem('a', 'Analogue'),
      PlinthSegmentedControlItem('b', 'Digital'),
    ];
    var value = 'a';

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            child: StatefulBuilder(
              builder: (context, setState) => PlinthSegmentedControl<String>(
                value: value,
                onChanged: (v) => setState(() => value = v),
                items: items,
              ),
            ),
          ),
        ),
      ),
    ));

    final before = tester.getRect(find.text('Analogue'));
    await tester.tap(find.text('Digital'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Analogue')), before,
        reason: 'measuring the selected label heavier would make the '
            'control twitch on every tap');
  });
}
