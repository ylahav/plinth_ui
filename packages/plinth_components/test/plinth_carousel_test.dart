import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: Center(child: child)),
  );
}

List<Widget> _slides(int count) => [
      for (var i = 0; i < count; i++)
        ColoredBox(color: Colors.blue, child: Center(child: Text('Slide $i'))),
    ];

void main() {
  group('PlinthCarousel', () {
    testWidgets('shows the first slide, and the next one after an arrow',
        (tester) async {
      await tester.pumpWidget(_wrap(PlinthCarousel(slides: _slides(3))));

      expect(find.text('Slide 0'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Next slide'));
      await tester.pumpAndSettle();

      expect(find.text('Slide 1'), findsOneWidget);
    });

    testWidgets('starts on initialSlide', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCarousel(slides: _slides(4), initialSlide: 2)),
      );

      expect(find.text('Slide 2'), findsOneWidget);
    });

    testWidgets('an out-of-range initialSlide clamps rather than throwing',
        (tester) async {
      // Commonly computed from data that may have shrunk since.
      await tester.pumpWidget(
        _wrap(PlinthCarousel(slides: _slides(3), initialSlide: 99)),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Slide 2'), findsOneWidget);
    });

    testWidgets('reports each new index once', (tester) async {
      final seen = <int>[];
      await tester.pumpWidget(
        _wrap(PlinthCarousel(
          slides: _slides(3),
          onSlideChanged: seen.add,
        )),
      );

      await tester.tap(find.bySemanticsLabel('Next slide'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Next slide'));
      await tester.pumpAndSettle();

      // Not the initial slide, and not a repeat per settling frame.
      expect(seen, [1, 2]);
    });

    testWidgets('without loop the arrows stop at each end', (tester) async {
      await tester.pumpWidget(_wrap(PlinthCarousel(slides: _slides(2))));

      // The label is *on* the button, not on a wrapper around it. It
      // used to be a `Semantics` ancestor, which produced a second node
      // and left the button itself announcing as unlabelled — caught by
      // walking a whole demo page rather than the component alone.
      PlinthActionIcon iconFor(String label) => tester
          .widgetList<PlinthActionIcon>(find.byType(PlinthActionIcon))
          .firstWhere((w) => w.semanticLabel == label);

      // A null onPressed is how this library renders a disabled
      // control, so it is the honest thing to assert.
      expect(iconFor('Previous slide').onPressed, isNull);
      expect(iconFor('Next slide').onPressed, isNotNull);

      await tester.tap(find.bySemanticsLabel('Next slide'));
      await tester.pumpAndSettle();

      expect(iconFor('Previous slide').onPressed, isNotNull);
      expect(iconFor('Next slide').onPressed, isNull);
    });

    testWidgets('with loop, back from the first slide reaches the last',
        (tester) async {
      final seen = <int>[];
      await tester.pumpWidget(
        _wrap(PlinthCarousel(
          slides: _slides(3),
          loop: true,
          onSlideChanged: seen.add,
        )),
      );

      await tester.tap(find.bySemanticsLabel('Previous slide'));
      await tester.pumpAndSettle();

      expect(seen, [2]);
      expect(find.text('Slide 2'), findsOneWidget);
    });

    testWidgets('an indicator jumps to its slide', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCarousel(slides: _slides(4), withIndicators: true)),
      );

      await tester.tap(find.bySemanticsLabel('Go to slide 3'));
      await tester.pumpAndSettle();

      expect(find.text('Slide 2'), findsOneWidget);
    });

    testWidgets('indicators mark the current slide as selected',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCarousel(slides: _slides(3), withIndicators: true)),
      );

      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Go to slide 1'))
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Go to slide 2'))
            .flagsCollection
            .isSelected,
        Tristate.isFalse,
      );
    });

    testWidgets('arrow keys move it once focused', (tester) async {
      await tester.pumpWidget(_wrap(PlinthCarousel(slides: _slides(3))));

      // A carousel someone can reach by keyboard has to be operable by
      // one; the arrows alone leave it a mouse-only control.
      //
      // Focus.of from inside the viewport: the component owns its
      // FocusNode privately, and the nearest Focus above the PageView
      // is that one.
      Focus.of(tester.element(find.byType(PageView))).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(find.text('Slide 1'), findsOneWidget);
    });

    testWidgets('a controller drives it from outside', (tester) async {
      final controller = PlinthCarouselController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(PlinthCarousel(slides: _slides(4), controller: controller)),
      );

      controller.jumpTo(3);
      await tester.pumpAndSettle();
      expect(controller.index, 3);
      expect(find.text('Slide 3'), findsOneWidget);

      controller.previous();
      await tester.pumpAndSettle();
      expect(find.text('Slide 2'), findsOneWidget);

      // Out of range is ignored rather than thrown, since the caller
      // is often working from data that changed.
      controller.jumpTo(99);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Slide 2'), findsOneWidget);
    });

    testWidgets('losing slides under a carousel past the new end clamps it',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCarousel(slides: _slides(4), initialSlide: 3)),
      );
      expect(find.text('Slide 3'), findsOneWidget);

      await tester.pumpWidget(_wrap(PlinthCarousel(slides: _slides(2))));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Slide 1'), findsOneWidget);
    });

    testWidgets('a single slide shows neither arrows nor indicators',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCarousel(slides: _slides(1), withIndicators: true)),
      );

      // Controls that can't go anywhere are noise, and a lone dot
      // tells a reader nothing they can't already see.
      expect(find.bySemanticsLabel('Next slide'), findsNothing);
      expect(find.bySemanticsLabel('Go to slide 1'), findsNothing);
    });
  });
}
