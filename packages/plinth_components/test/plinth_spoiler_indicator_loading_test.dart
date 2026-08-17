import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('PlinthSpoiler', () {
    testWidgets('shows the show-label by default', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSpoiler(child: Text('Long content'))),
      );

      expect(find.text('Show more'), findsOneWidget);
      expect(find.text('Show less'), findsNothing);
    });

    testWidgets('tapping the toggle switches to the hide-label',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSpoiler(child: Text('Long content'))),
      );

      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();

      expect(find.text('Show less'), findsOneWidget);
      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('respects custom labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthSpoiler(
            showLabel: 'Read more',
            hideLabel: 'Collapse',
            child: Text('Long content'),
          ),
        ),
      );

      expect(find.text('Read more'), findsOneWidget);
    });

    testWidgets('clips a child taller than maxHeight without overflowing',
        (tester) async {
      // Every other usage passes a Text, which soft-wraps and clips
      // quietly. A Column manages its own overflow, so laying it out
      // *within* maxHeight made it report a RenderFlex overflow and
      // paint overflow stripes — while clipping tall content is the
      // whole point of a spoiler.
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 300,
            child: PlinthSpoiler(
              maxHeight: 50,
              child: Column(
                children: [
                  SizedBox(height: 80, child: Text('First')),
                  SizedBox(height: 80, child: Text('Second')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('shrink-wraps a child shorter than maxHeight', (tester) async {
      // The clipping fix must not pad short content out to maxHeight.
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 300,
            child: PlinthSpoiler(
              maxHeight: 400,
              child: SizedBox(height: 40, child: Text('Short')),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.text('Short')).height, lessThan(400));
      expect(
        tester.getSize(find.byType(SingleChildScrollView)).height,
        40,
      );
    });
  });

  group('PlinthIndicator', () {
    testWidgets('renders the child and a label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthIndicator(
            label: '3',
            child: Icon(Icons.notifications_outlined),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides the indicator label when disabled, keeps the child',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthIndicator(
            label: '3',
            visible: false,
            child: Icon(Icons.notifications_outlined),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.text('3'), findsNothing);
    });

    testWidgets('every position renders without throwing', (tester) async {
      for (final position in PlinthIndicatorPosition.values) {
        await tester.pumpWidget(
          _wrap(
            PlinthIndicator(
              position: position,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        );
        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      }
    });

    /// The dot itself — the decorated box inside the indicator, not
    /// the child it is anchored to.
    Finder dot() => find.descendant(
          of: find.byType(PlinthIndicator),
          matching: find.byType(Container),
        );

    testWidgets('the dot is a dot, not the size of what it marks',
        (tester) async {
      // The bug this pins: `Container.alignment` makes a Container
      // expand to fill bounded constraints, and the corner it sits in
      // hands it the child's full size. A 48px icon got a 48px "dot"
      // covering it. Three tests passed throughout — they asked
      // whether it rendered, never how big it was — and the committed
      // golden had certified the blob for several releases.
      for (final childSize in [24.0, 48.0, 96.0]) {
        await tester.pumpWidget(
          _wrap(PlinthIndicator(
            child: Icon(Icons.notifications_outlined, size: childSize),
          )),
        );
        expect(
          tester.getSize(dot()),
          equals(const Size(16, 16)),
          reason: 'dot should not track a $childSize child',
        );
      }
    });

    testWidgets('size steps the dot, and md is the old fixed 16',
        (tester) async {
      for (final (size, expected) in const [
        (PlinthSize.xs, 8.0),
        (PlinthSize.sm, 12.0),
        (PlinthSize.md, 16.0),
        (PlinthSize.lg, 20.0),
        (PlinthSize.xl, 24.0),
      ]) {
        await tester.pumpWidget(
          _wrap(PlinthIndicator(
            size: size,
            child: const Icon(Icons.notifications_outlined),
          )),
        );
        expect(
          tester.getSize(dot()),
          equals(Size(expected, expected)),
          reason: 'dot for $size',
        );
      }
    });

    testWidgets('a label widens the badge past the dot but keeps its height',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthIndicator(
          label: '128',
          child: Icon(Icons.notifications_outlined),
        )),
      );

      final size = tester.getSize(dot());
      expect(size.height, equals(16));
      expect(size.width, greaterThan(16));
    });

    testWidgets('withBorder rings the dot in the surface colour',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthIndicator(
          child: Icon(Icons.notifications_outlined),
        )),
      );
      expect(
        (tester.widget<Container>(dot()).decoration! as BoxDecoration).border,
        isNull,
      );

      await tester.pumpWidget(
        _wrap(const PlinthIndicator(
          withBorder: true,
          child: Icon(Icons.notifications_outlined),
        )),
      );
      final border =
          (tester.widget<Container>(dot()).decoration! as BoxDecoration)
              .border!;
      expect(border.top.color, equals(PlinthTheme.defaultTheme.surface));
      expect(border.top.width, equals(2));
    });

    testWidgets('offset pulls the dot in toward the child on both axes',
        (tester) async {
      Rect dotRect(WidgetTester tester) => tester.getRect(dot());

      await tester.pumpWidget(
        _wrap(const PlinthIndicator(
          child: Icon(Icons.notifications_outlined, size: 48),
        )),
      );
      final before = dotRect(tester);

      await tester.pumpWidget(
        _wrap(const PlinthIndicator(
          offset: 6,
          child: Icon(Icons.notifications_outlined, size: 48),
        )),
      );
      final after = dotRect(tester);

      // Default corner is topEnd, so "in" is left and down — what a
      // round avatar needs to bring the dot back onto its edge.
      expect(after.left, closeTo(before.left - 6, 0.01));
      expect(after.top, closeTo(before.top + 6, 0.01));
    });

    testWidgets('offset moves toward the centre from any corner',
        (tester) async {
      Rect rectFor(WidgetTester tester) => tester.getRect(dot());

      for (final position in PlinthIndicatorPosition.values) {
        await tester.pumpWidget(
          _wrap(PlinthIndicator(
            position: position,
            child: const Icon(Icons.notifications_outlined, size: 48),
          )),
        );
        final before = rectFor(tester);

        await tester.pumpWidget(
          _wrap(PlinthIndicator(
            position: position,
            offset: 6,
            child: const Icon(Icons.notifications_outlined, size: 48),
          )),
        );
        final after = rectFor(tester);

        final child = tester.getRect(find.byIcon(Icons.notifications_outlined));
        // Whichever corner it sits in, the offset should shorten the
        // distance to the child's centre rather than lengthen it.
        expect(
          (after.center - child.center).distance,
          lessThan((before.center - child.center).distance),
          reason: 'offset should pull inward at $position',
        );
      }
    });
  });

  group('PlinthLoadingOverlay', () {
    testWidgets('shows a spinner when visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthLoadingOverlay(
              visible: true, child: Text('Form content')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides the spinner when not visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthLoadingOverlay(
              visible: false, child: Text('Form content')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Form content'), findsOneWidget);
    });

    testWidgets('child stays in the tree (not removed) while visible',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthLoadingOverlay(
              visible: true, child: Text('Form content')),
        ),
      );

      // Content underneath is dimmed/non-interactive, not gone —
      // confirms the IgnorePointer approach keeps layout stable.
      expect(find.text('Form content'), findsOneWidget);
    });
  });
}
