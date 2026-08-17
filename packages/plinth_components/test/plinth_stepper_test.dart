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
