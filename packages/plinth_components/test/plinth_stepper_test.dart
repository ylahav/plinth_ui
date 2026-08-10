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
}
