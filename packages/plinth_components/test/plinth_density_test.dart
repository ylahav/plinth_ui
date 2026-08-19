// A1c — the density axis.
//
// Plinth sizes like the web library it is modelled on. Measured across
// eleven controls at default size: all clear WCAG 2.2 AA's 24x24, none
// clear iOS's 44 or Android's 48. That is the right answer for a dense
// desktop table and the wrong one for a phone, and until this existed
// an app had no way to say which it was.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _at(PlinthDensity density, Widget child) => MaterialApp(
      theme: ThemeData(
        extensions: [PlinthTheme.defaultTheme.copyWith(density: density)],
      ),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  Map<String, Widget> cases() => {
        'PlinthButton':
            PlinthButton(onPressed: () {}, child: const Text('Save')),
        'PlinthActionIcon': PlinthActionIcon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            semanticLabel: 'Edit'),
        'PlinthCloseButton':
            PlinthCloseButton(onPressed: () {}, semanticLabel: 'Close'),
        'PlinthChip':
            PlinthChip(label: 'Filter', selected: true, onSelected: (_) {}),
      };

  group('A1c — density floors the tap target', () {
    for (final density in PlinthDensity.values) {
      testWidgets('${density.name} gives every control its floor',
          (tester) async {
        for (final entry in cases().entries) {
          await tester.pumpWidget(_at(density, entry.value));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final size = tester.getSize(find.byWidget(entry.value));
          expect(size.height, greaterThanOrEqualTo(density.minTapTarget),
              reason: '${entry.key} at ${density.name}');
          expect(size.width, greaterThanOrEqualTo(density.minTapTarget),
              reason: '${entry.key} at ${density.name}');
        }
      });
    }

    testWidgets('standard leaves the controls exactly as they were',
        (tester) async {
      // The floor is 24 and every control already cleared it, so the
      // default density has to be a no-op — otherwise this ships as a
      // silent restyle of every screen.
      const expected = {
        'PlinthButton': 39.0,
        'PlinthActionIcon': 36.0,
        'PlinthCloseButton': 24.0,
        'PlinthChip': 36.0,
      };
      for (final entry in cases().entries) {
        await tester.pumpWidget(_at(PlinthDensity.standard, entry.value));
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byWidget(entry.value)).height,
            expected[entry.key],
            reason: '${entry.key} moved at the default density');
      }
    });

    testWidgets('a full-width button is still full width', (tester) async {
      // The floor has to be transparent to layout. An earlier version
      // centred the child so the *painted* box could stay small while
      // the target grew — the way Flutter's MaterialTapTargetSize
      // works. Centring shrink-wraps, which collapsed every
      // `fullWidth: true` button to the width of its label. No test
      // here caught that; a golden did.
      final button = PlinthButton(
          onPressed: () {}, fullWidth: true, child: const Text('Save'));
      for (final density in PlinthDensity.values) {
        await tester
            .pumpWidget(_at(density, SizedBox(width: 300, child: button)));
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byWidget(button)).width, 300,
            reason: 'fullWidth collapsed at ${density.name}');
      }
    });

    test('the floors are the standards they claim to be', () {
      expect(PlinthDensity.standard.minTapTarget, 24); // WCAG 2.2 SC 2.5.8
      expect(PlinthDensity.comfortable.minTapTarget, 44); // iOS HIG
      expect(PlinthDensity.touch.minTapTarget, 48); // Android Material
    });
  });
}
