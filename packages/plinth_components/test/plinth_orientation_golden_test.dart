@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

import 'helpers/golden.dart';

/// Golden coverage for 0.22.0's structural changes — the ones where a
/// prop doesn't tweak a component but re-composes it.
///
/// `direction: Axis.vertical` on [PlinthTabs] and [PlinthStepper]
/// swaps a `Row` for a `Column` and moves the indicator to a different
/// edge; [PlinthTable]'s `maxHeight` splits one table into two and
/// relies on their columns landing on the same edges. Each is the kind
/// of change a behaviour test passes and an eye catches: the tap still
/// reports the right value while the line runs down the wrong side, or
/// the header's second column sits a few pixels off its body's.
///
/// The precedent is in `plinth_computed_layout_golden_test.dart` —
/// `PlinthRollingNumber` shipped placing every digit wheel wrong while
/// 494 tests passed.
void main() {
  const tabs = [
    PlinthTabItem('account', 'Account'),
    PlinthTabItem('security', 'Security'),
    PlinthTabItem('billing', 'Billing'),
  ];

  const steps = [
    PlinthStep(label: 'Account', description: 'Who you are'),
    PlinthStep(label: 'Shipping', description: 'Where it goes'),
    PlinthStep(label: 'Confirm'),
  ];

  group('vertical orientation golden', () {
    testWidgets('tabs run down with the indicator on the trailing edge',
        (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 200,
            child: PlinthTabs<String>(
              tabs: tabs,
              value: 'security',
              direction: Axis.vertical,
              onChanged: _ignore,
            ),
          ),
          width: 240,
          height: 160,
        ),
      );

      // The active tab is the middle one, so a mirrored or misplaced
      // indicator shows as a line on the wrong edge rather than as a
      // missing one.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_tabs_vertical.png'),
      );
    });

    testWidgets('stepper runs down with labels beside the circles',
        (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 220,
            child: PlinthStepper(
              steps: steps,
              currentStep: 1,
              direction: Axis.vertical,
            ),
          ),
          width: 260,
          height: 200,
        ),
      );

      // Connectors have to land centred under the circle above them —
      // the one measurement in here that is arithmetic rather than
      // layout, and the one an image is the only check on.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_stepper_vertical.png'),
      );
    });

    testWidgets('a capped table keeps its header over the same columns',
        (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          PlinthTable.text(
            columns: const ['ID', 'Description'],
            // A two-character header over a longer cell, which is
            // where two independently sized tables would drift apart.
            rows: [
              for (var i = 0; i < 12; i++) ['$i', 'Line item $i'],
            ],
            maxHeight: 150,
            striped: true,
          ),
          width: 320,
          height: 170,
        ),
      );

      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_table_capped.png'),
      );
    });
  });
}

void _ignore(String _) {}
