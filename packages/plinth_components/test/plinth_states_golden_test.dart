@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

import 'helpers/golden.dart';

/// Golden coverage for the states a component enters rather than the
/// props it is given.
///
/// 0.19.0 found that a disabled `PlinthButton` rendered pixel-identical
/// to a live one: the null callback changed the semantics and nothing
/// else. Every test passed, because every test asked about behaviour.
/// The bug was only visible in a picture, and the one picture that
/// could have shown it — `plinth_button_disabled` — had been generated
/// from the broken code, so it certified the bug instead of catching
/// it.
///
/// These images are the answer to that: a state per row, side by side
/// with the state it must not look like.
void main() {
  group('state golden', () {
    testWidgets('disabled is visibly different from enabled', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          PlinthStack(
            gap: PlinthSize.sm,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final variant in [
                PlinthVariant.filled,
                PlinthVariant.light,
                PlinthVariant.outline,
                PlinthVariant.subtle,
              ])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlinthButton(
                      variant: variant,
                      size: PlinthSize.sm,
                      onPressed: () {},
                      child: const Text('Save'),
                    ),
                    const SizedBox(width: 12),
                    PlinthButton(
                      variant: variant,
                      size: PlinthSize.sm,
                      onPressed: null,
                      child: const Text('Save'),
                    ),
                  ],
                ),
            ],
          ),
          width: 260,
          height: 220,
        ),
      );

      // Live on the left, disabled on the right, one row per variant.
      // The two transparent variants must stay transparent — a grey
      // plate behind a disabled `subtle` button would make it *more*
      // prominent than its enabled self, which is the failure mode the
      // pairing makes obvious.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_button_disabled_vs_enabled.png'),
      );
    });

    testWidgets('loading keeps the button its own colour', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          PlinthStack(
            gap: PlinthSize.sm,
            mainAxisSize: MainAxisSize.min,
            children: [
              PlinthButton(
                size: PlinthSize.sm,
                onPressed: () {},
                leadingIcon: const Icon(Icons.save, size: 16),
                child: const Text('Save'),
              ),
              PlinthButton(
                size: PlinthSize.sm,
                loading: true,
                onPressed: () {},
                leadingIcon: const Icon(Icons.save, size: 16),
                child: const Text('Save'),
              ),
              PlinthActionIcon(
                icon: const Icon(Icons.refresh),
                loading: true,
                onPressed: () {},
              ),
            ],
          ),
          width: 220,
          height: 160,
        ),
      );

      // Idle above loading: the spinner takes the icon's place rather
      // than pushing the label along, and the fill stays the brand
      // colour, since busy is not unavailable. A single frame is enough
      // — the spinner's angle doesn't matter, its size and colour do.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_button_loading.png'),
      );
    });

    testWidgets('the shapes that default to a pill still do', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          PlinthStack(
            gap: PlinthSize.sm,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlinthGroup(
                gap: PlinthSize.sm,
                children: [
                  const PlinthBadge('Beta'),
                  PlinthChip(
                    label: 'Dart',
                    selected: true,
                    onSelected: (_) {},
                  ),
                  PlinthSwitch(value: true, onChanged: (_) {}),
                  const PlinthIndicator(
                    label: '3',
                    child: SizedBox(width: 28, height: 28),
                  ),
                ],
              ),
              PlinthGroup(
                gap: PlinthSize.sm,
                children: [
                  const PlinthBadge('Beta', radius: PlinthSize.xs),
                  PlinthChip(
                    label: 'Dart',
                    selected: true,
                    onSelected: (_) {},
                    radius: PlinthSize.xs,
                  ),
                  PlinthSwitch(
                    value: true,
                    onChanged: (_) {},
                    radius: PlinthSize.xs,
                  ),
                  const PlinthIndicator(
                    label: '3',
                    radius: PlinthSize.xs,
                    child: SizedBox(width: 28, height: 28),
                  ),
                ],
              ),
            ],
          ),
          width: 300,
          height: 140,
        ),
      );

      // Defaults on top, `radius: xs` below. 0.19.0 added the prop to
      // thirteen components on the promise that no default moved; the
      // unit tests assert that per component, and this is the picture
      // of it — a squared-off top row would be the regression.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_pill_defaults.png'),
      );
    });
  });
}
