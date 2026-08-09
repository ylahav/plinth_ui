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
  group('PlinthNumberInput', () {
    testWidgets('renders the initial value', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthNumberInput(value: 5, onChanged: (_) {})),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('tapping increment calls onChanged with value + step', (tester) async {
      num? changed;
      await tester.pumpWidget(
        _wrap(PlinthNumberInput(value: 5, onChanged: (v) => changed = v)),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(changed, equals(6));
    });

    testWidgets('tapping decrement calls onChanged with value - step', (tester) async {
      num? changed;
      await tester.pumpWidget(
        _wrap(PlinthNumberInput(value: 5, onChanged: (v) => changed = v)),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(changed, equals(4));
    });

    testWidgets('increment is clamped at max', (tester) async {
      num? changed;
      await tester.pumpWidget(
        _wrap(
          PlinthNumberInput(value: 10, max: 10, onChanged: (v) => changed = v),
        ),
      );

      // The + icon should be disabled (no onTap) at max, so tapping
      // it should not fire onChanged at all.
      await tester.tap(find.byIcon(Icons.add), warnIfMissed: false);
      await tester.pump();

      expect(changed, isNull);
    });

    testWidgets('decrement is clamped at min', (tester) async {
      num? changed;
      await tester.pumpWidget(
        _wrap(
          PlinthNumberInput(value: 0, min: 0, onChanged: (v) => changed = v),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove), warnIfMissed: false);
      await tester.pump();

      expect(changed, isNull);
    });

    testWidgets('typing a valid number calls onChanged', (tester) async {
      num? changed;
      await tester.pumpWidget(
        _wrap(PlinthNumberInput(value: 5, onChanged: (v) => changed = v)),
      );

      await tester.enterText(find.byType(TextField), '42');
      await tester.pump();

      expect(changed, equals(42));
    });

    testWidgets('respects a custom step', (tester) async {
      num? changed;
      await tester.pumpWidget(
        _wrap(
          PlinthNumberInput(value: 10, step: 5, onChanged: (v) => changed = v),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(changed, equals(15));
    });
  });
}
