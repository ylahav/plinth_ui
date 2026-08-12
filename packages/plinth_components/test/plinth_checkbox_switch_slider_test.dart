// The semantics flags are tri-state enums from dart:ui rather than
// bools — "unchecked" and "checkedness does not apply here" are
// different things to a screen reader. They are not re-exported by
// flutter/material.dart or flutter/semantics.dart.
import 'dart:ui' show CheckedState, Tristate;

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
  group('PlinthCheckbox', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthCheckbox(
            label: 'I agree to the terms',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('I agree to the terms'), findsOneWidget);
    });

    testWidgets('shows a check only when checked', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCheckbox(value: false, onChanged: (_) {})),
      );
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.pumpWidget(
        _wrap(PlinthCheckbox(value: true, onChanged: (_) {})),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tapping calls onChanged with the toggled value',
        (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        _wrap(PlinthCheckbox(value: false, onChanged: changes.add)),
      );

      await tester.tap(find.byType(PlinthCheckbox));

      // Controlled: it reports the value it *would* become and leaves
      // the caller to actually change it.
      expect(changes, [true]);
    });

    testWidgets('tapping a checked box reports false', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        _wrap(PlinthCheckbox(value: true, onChanged: changes.add)),
      );

      await tester.tap(find.byType(PlinthCheckbox));

      expect(changes, [false]);
    });

    testWidgets('a null onChanged disables it', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCheckbox(value: false, onChanged: null)),
      );

      await tester.tap(find.byType(PlinthCheckbox));
      await tester.pump();

      expect(tester.takeException(), isNull);
      // The flags are tri-state enums rather than bools: "not enabled"
      // and "enabledness doesn't apply here" are different things to a
      // screen reader.
      final semantics = tester.getSemantics(find.byType(PlinthCheckbox));
      expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
    });

    testWidgets('exposes its checked state to assistive technology',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCheckbox(value: true, onChanged: (_) {})),
      );

      final semantics = tester.getSemantics(find.byType(PlinthCheckbox));
      expect(semantics.flagsCollection.isChecked, CheckedState.isTrue);
    });
  });

  group('PlinthSwitch', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthSwitch(
            label: 'Enable notifications',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Enable notifications'), findsOneWidget);
    });

    testWidgets('tapping calls onChanged with the toggled value',
        (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        _wrap(PlinthSwitch(value: false, onChanged: changes.add)),
      );

      await tester.tap(find.byType(PlinthSwitch));

      expect(changes, [true]);
    });

    testWidgets('a null onChanged disables it', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSwitch(value: false, onChanged: null)),
      );

      await tester.tap(find.byType(PlinthSwitch));
      await tester.pump();

      expect(tester.takeException(), isNull);
      final semantics = tester.getSemantics(find.byType(PlinthSwitch));
      expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
    });

    testWidgets('exposes its toggled state to assistive technology',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthSwitch(value: true, onChanged: (_) {})),
      );

      final semantics = tester.getSemantics(find.byType(PlinthSwitch));
      expect(semantics.flagsCollection.isToggled, Tristate.isTrue);
    });
  });

  group('PlinthSlider', () {
    testWidgets('passes its range through to the underlying Slider',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthSlider(
            value: 30,
            min: 10,
            max: 50,
            divisions: 4,
            onChanged: (_) {},
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 30);
      expect(slider.min, 10);
      expect(slider.max, 50);
      expect(slider.divisions, 4);
    });

    testWidgets('clamps a value outside the range instead of asserting',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthSlider(value: 500, max: 100, onChanged: (_) {})),
      );

      // Flutter's own Slider asserts on an out-of-range value, so
      // clamping is what keeps a stale value from crashing the app.
      expect(tester.takeException(), isNull);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 100);
    });

    testWidgets('a null onChanged disables it', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSlider(value: 30, onChanged: null)),
      );

      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
    });

    testWidgets('dragging reports a new value', (tester) async {
      final changes = <double>[];
      await tester.pumpWidget(
        _wrap(PlinthSlider(value: 50, onChanged: changes.add)),
      );

      await tester.drag(find.byType(Slider), const Offset(-200, 0));
      await tester.pump();

      expect(changes, isNotEmpty);
      expect(changes.last, lessThan(50));
    });

    testWidgets('every size renders', (tester) async {
      for (final size in PlinthSize.values) {
        await tester.pumpWidget(
          _wrap(PlinthSlider(value: 50, size: size, onChanged: (_) {})),
        );

        expect(find.byType(Slider), findsOneWidget);
      }
    });
  });
}
