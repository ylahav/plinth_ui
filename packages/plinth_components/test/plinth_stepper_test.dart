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
  group('PlinthStepper', () {
    testWidgets('renders every step label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthStepper(
            currentStep: 0,
            steps: [
              PlinthStep(label: 'Account'),
              PlinthStep(label: 'Shipping'),
              PlinthStep(label: 'Confirm'),
            ],
          ),
        ),
      );

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Shipping'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('shows a checkmark for completed steps', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthStepper(
            currentStep: 2,
            steps: [
              PlinthStep(label: 'Account'),
              PlinthStep(label: 'Shipping'),
              PlinthStep(label: 'Confirm'),
            ],
          ),
        ),
      );

      // Steps 0 and 1 are before currentStep (2), so both show a
      // check icon instead of their number.
      expect(find.byIcon(Icons.check), findsNWidgets(2));
      // The active step (index 2) still shows its number, not a check.
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tapping a step calls onStepTapped with its index',
        (tester) async {
      int? tapped;
      await tester.pumpWidget(
        _wrap(
          PlinthStepper(
            currentStep: 0,
            onStepTapped: (i) => tapped = i,
            steps: const [
              PlinthStep(label: 'Account'),
              PlinthStep(label: 'Shipping'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Shipping'));
      await tester.pump();

      expect(tapped, equals(1));
    });

    testWidgets('does not throw when onStepTapped is omitted', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthStepper(
            currentStep: 0,
            steps: [PlinthStep(label: 'Account')],
          ),
        ),
      );

      await tester.tap(find.text('Account'), warnIfMissed: false);
      await tester.pump();

      // No assertion needed beyond "didn't throw" — a null onTap
      // should just make the step non-interactive.
    });
  });

  group('PlinthStepper size', () {
    const steps = [
      PlinthStep(label: 'Account', description: 'Who you are'),
      PlinthStep(label: 'Shipping'),
      PlinthStep(label: 'Confirm'),
    ];

    /// The marker disc for the active step, found by the number in it.
    Size circleSize(WidgetTester tester, String number) => tester.getSize(
          find
              .ancestor(
                of: find.text(number),
                matching: find.byType(Container),
              )
              .first,
        );

    testWidgets('md is the 32 it drew before the prop existed', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthStepper(currentStep: 0, steps: steps)),
      );

      expect(circleSize(tester, '1'), equals(const Size(32, 32)));
    });

    testWidgets('every step scales the marker together', (tester) async {
      for (final (size, expected) in const [
        (PlinthSize.xs, 20.0),
        (PlinthSize.sm, 26.0),
        (PlinthSize.md, 32.0),
        (PlinthSize.lg, 40.0),
        (PlinthSize.xl, 48.0),
      ]) {
        await tester.pumpWidget(
          _wrap(PlinthStepper(currentStep: 0, size: size, steps: steps)),
        );
        expect(
          circleSize(tester, '1'),
          equals(Size(expected, expected)),
          reason: 'circle for $size',
        );
      }
    });

    testWidgets('the label grows with the marker', (tester) async {
      double labelHeight(WidgetTester tester) =>
          tester.getSize(find.text('Shipping')).height;

      await tester.pumpWidget(
        _wrap(const PlinthStepper(
          currentStep: 0,
          size: PlinthSize.xs,
          steps: steps,
        )),
      );
      final small = labelHeight(tester);

      await tester.pumpWidget(
        _wrap(const PlinthStepper(
          currentStep: 0,
          size: PlinthSize.xl,
          steps: steps,
        )),
      );

      // A giant disc over xs text would be the failure mode of scaling
      // only the marker.
      expect(labelHeight(tester), greaterThan(small));
    });

    testWidgets('markers share a line when only some steps have descriptions',
        (tester) async {
      // The Row centred each step column against the tallest, so the
      // one carrying a description sat higher than its neighbours —
      // markers 8.5px apart at md, and further at every larger size.
      // Every other stepper assertion passed through it.
      for (final size in PlinthSize.values) {
        await tester.pumpWidget(
          _wrap(PlinthStepper(currentStep: 2, size: size, steps: steps)),
        );

        final checks = find.byIcon(Icons.check);
        expect(checks, findsNWidgets(2));
        expect(
          tester.getRect(checks.at(0)).top,
          closeTo(tester.getRect(checks.at(1)).top, 0.01),
          reason: 'markers should share a top edge at $size',
        );
      }
    });

    testWidgets('the connector sits on the markers\' centre line',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthStepper(
          currentStep: 2,
          size: PlinthSize.xl,
          steps: steps,
        )),
      );

      final marker = tester.getRect(find.byIcon(Icons.check).first);
      final connectors = find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxHeight == 2,
      );
      expect(connectors, findsNWidgets(2));

      // A connector joins marker centres, and at xl that centre is
      // 24px down — the old fixed bottom-margin offset was tuned for
      // one size and one label shape.
      for (var i = 0; i < 2; i++) {
        expect(
          tester.getRect(connectors.at(i)).center.dy,
          closeTo(marker.center.dy, 1),
          reason: 'connector $i should meet the marker centre line',
        );
      }
    });
  });

  group('PlinthStepper direction', () {
    const steps = [
      PlinthStep(label: 'Account', description: 'Who you are'),
      PlinthStep(label: 'Shipping'),
      PlinthStep(label: 'Confirm'),
    ];

    testWidgets('horizontal runs the steps across, label under circle',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthStepper(currentStep: 1, steps: steps)),
      );

      final account = tester.getRect(find.text('Account'));
      final shipping = tester.getRect(find.text('Shipping'));
      expect(shipping.left, greaterThan(account.left));

      // The label sits below its own circle, which is what makes the
      // horizontal variant need the whole width for three words.
      // Step 0 is complete at currentStep 1, so '2' is the first
      // marker still showing a number.
      final circle = tester.getRect(find.text('2'));
      expect(shipping.top, greaterThan(circle.top));
    });

    testWidgets('vertical runs them down, label beside circle', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthStepper(
          currentStep: 1,
          direction: Axis.vertical,
          steps: steps,
        )),
      );

      final account = tester.getRect(find.text('Account'));
      final shipping = tester.getRect(find.text('Shipping'));
      expect(shipping.top, greaterThan(account.top));
      expect(shipping.left, equals(account.left));

      // Beside, not under: the label starts to the right of the
      // marker and shares its line.
      final circle = tester.getRect(find.text('2'));
      expect(shipping.left, greaterThan(circle.right));
    });

    testWidgets('vertical connectors stay hairlines under the circles',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthStepper(
          currentStep: 1,
          direction: Axis.vertical,
          steps: steps,
        )),
      );

      final connectors = find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxWidth == 2,
      );
      expect(connectors, findsNWidgets(2));

      // The rendered width, not the requested one. The column
      // stretches its children so the steps share a left edge, and
      // that stretch overruled the connector's own width — it painted
      // as a full-width bar across the step below, which every
      // behaviour assertion above still passed through.
      final circle = tester.getRect(find.text('2'));
      for (var i = 0; i < 2; i++) {
        // The painted box rather than the Container, whose own rect
        // includes the margin that positions it.
        final rect = tester.getRect(find.descendant(
          of: connectors.at(i),
          matching: find.byType(ColoredBox),
        ));
        expect(rect.width, equals(2));
        expect(rect.center.dx, closeTo(circle.center.dx, 1));
      }
    });

    testWidgets('vertical keeps the descriptions and reports taps',
        (tester) async {
      int? tapped;
      await tester.pumpWidget(
        _wrap(PlinthStepper(
          currentStep: 1,
          direction: Axis.vertical,
          steps: steps,
          onStepTapped: (i) => tapped = i,
        )),
      );

      expect(find.text('Who you are'), findsOneWidget);
      // Completed steps show a check rather than their number, the
      // same as horizontally.
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pump();
      expect(tapped, equals(2));
    });
  });
}
