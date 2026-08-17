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

  group('PlinthSlider marks', () {
    const marks = [
      PlinthSliderMark(value: 0, label: 'Off'),
      PlinthSliderMark(value: 50, label: 'Half'),
      PlinthSliderMark(value: 100, label: 'Max'),
    ];

    testWidgets('renders a label per mark', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthSlider(value: 50, marks: marks, onChanged: (_) {})),
      );

      expect(find.text('Off'), findsOneWidget);
      expect(find.text('Half'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
    });

    testWidgets('a label sits over the position it names', (tester) async {
      await tester.pumpWidget(
        _wrap(SizedBox(
          width: 300,
          child: PlinthSlider(value: 50, marks: marks, onChanged: (_) {}),
        )),
      );

      final slider = tester.getRect(find.byType(Slider));
      final middle = tester.getCenter(find.text('Half')).dx;

      // Halfway along the *track*, which is inset by a thumb radius at
      // each end — measuring against the raw width would put this a
      // few pixels off, and the end labels much further.
      expect(middle, closeTo(slider.center.dx, 1));
    });

    testWidgets('an unmarked slider is wrapped in nothing', (tester) async {
      // Structure rather than height: Flutter's Slider expands to
      // whatever height it is offered, so a bare one in a Scaffold body
      // measures 600 and a marked one 67 — the wrapper *shrinks* it,
      // which makes a height comparison say the opposite of what it
      // looks like it says.
      final wrapper = find.descendant(
        of: find.byType(PlinthSlider),
        matching: find.byType(Column),
      );

      await tester.pumpWidget(
        _wrap(PlinthSlider(value: 50, onChanged: (_) {})),
      );
      expect(wrapper, findsNothing);

      await tester.pumpWidget(
        _wrap(PlinthSlider(value: 50, marks: marks, onChanged: (_) {})),
      );
      expect(wrapper, findsOneWidget);
    });

    testWidgets('restrictToMarks reports the nearest mark', (tester) async {
      final changes = <double>[];
      await tester.pumpWidget(
        _wrap(PlinthSlider(
          value: 50,
          marks: const [
            // Deliberately uneven, which is the case `divisions`
            // cannot express: it splits the range into equal steps.
            PlinthSliderMark(value: 0, label: '0'),
            PlinthSliderMark(value: 10, label: '10'),
            PlinthSliderMark(value: 100, label: '100'),
          ],
          restrictToMarks: true,
          onChanged: changes.add,
        )),
      );

      await tester.drag(find.byType(Slider), const Offset(-120, 0));
      await tester.pump();

      expect(changes, isNotEmpty);
      expect(
          changes.every((v) => const [0.0, 10.0, 100.0].contains(v)), isTrue);
    });

    testWidgets('a range slider marks both thumbs', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthRangeSlider(
          values: const RangeValues(0, 50),
          marks: marks,
          onChanged: (_) {},
        )),
      );

      expect(find.text('Off'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
    });
  });

  group('description, error and indeterminate', () {
    testWidgets('a checkbox shows its description and error', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCheckbox(
          label: 'Email me',
          description: 'About once a month, never about anything else',
          error: 'Pick at least one channel',
          value: false,
          onChanged: (_) {},
        )),
      );

      // The chrome the text inputs have had from the start, which the
      // boolean controls were missing.
      expect(find.text('About once a month, never about anything else'),
          findsOneWidget);
      expect(find.text('Pick at least one channel'), findsOneWidget);
    });

    testWidgets('a switch and a radio take the same two', (tester) async {
      await tester.pumpWidget(
        _wrap(Column(
          children: [
            PlinthSwitch(
              label: 'Dark mode',
              description: 'Follows the system by default',
              value: false,
              onChanged: (_) {},
            ),
            PlinthRadio<String>(
              label: 'Standard',
              description: 'Three to five working days',
              value: 'standard',
              groupValue: 'express',
              onChanged: (_) {},
            ),
          ],
        )),
      );

      expect(find.text('Follows the system by default'), findsOneWidget);
      expect(find.text('Three to five working days'), findsOneWidget);
    });

    testWidgets('indeterminate draws a dash and reads as mixed',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCheckbox(
          label: 'Everything',
          indeterminate: true,
          value: false,
          onChanged: (_) {},
        )),
      );

      // Filled with a dash, not empty: an empty box would say "none of
      // them", which is the one thing this state exists to deny.
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);

      final semantics = tester.getSemantics(find.byType(PlinthCheckbox));
      expect(semantics.flagsCollection.isChecked, CheckedState.mixed);
    });

    testWidgets('indeterminate leaves what a tap reports to value',
        (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(
        _wrap(PlinthCheckbox(
          indeterminate: true,
          value: false,
          onChanged: changes.add,
        )),
      );

      await tester.tap(find.byType(PlinthCheckbox));

      // The caller decides what "some are selected" should become —
      // usually all of them — so the widget reports the flip of `value`
      // and stays out of it.
      expect(changes, [true]);
    });
  });
}
