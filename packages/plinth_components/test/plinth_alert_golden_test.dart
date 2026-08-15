@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

import 'helpers/golden.dart';

/// Golden coverage for `PlinthAlert`'s colour tinting.
///
/// The second component `docs/TESTING.md` names, and for a reason a
/// behaviour test can't reach: an alert paints its background at shade
/// 0 and its accent — icon, title, border — at shade 6 of the same
/// ramp. Those two values come out of the theme's shade generator, so
/// a change to the curve, or to `shaded()`'s dark-mode mirroring,
/// moves every alert in the library at once without changing a line of
/// alert code.
///
/// Several colours are covered rather than one because the ramp is not
/// uniform: yellow and lime sit much lighter at the same index than
/// violet or blue, which is the whole reason `readableOn` exists. A
/// single-colour golden would miss a regression that only shows at one
/// end of the palette.
void main() {
  group('PlinthAlert golden', () {
    testWidgets('default blue', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 320,
            child: PlinthAlert(
              title: 'Heads up',
              child: Text('Your trial ends in three days.'),
            ),
          ),
          width: 360,
          height: 120,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_alert_blue.png'),
      );
    });

    testWidgets('with icon and close button', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          SizedBox(
            width: 320,
            child: PlinthAlert(
              title: 'Saved',
              color: 'green',
              icon: const Icon(Icons.check_circle_outline),
              onClose: () {},
              child: const Text('Your changes are live.'),
            ),
          ),
          width: 360,
          height: 120,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_alert_green_icon.png'),
      );
    });

    testWidgets('no title', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 320,
            child: PlinthAlert(child: Text('A bare alert, body only.')),
          ),
          width: 360,
          height: 100,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_alert_untitled.png'),
      );
    });

    testWidgets('across the palette', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Deliberately spread across the ramp: yellow sits
                // much lighter than violet at the same shade index.
                PlinthAlert(
                    color: 'red', title: 'red', child: Text('shade 0 / 6')),
                SizedBox(height: 6),
                PlinthAlert(
                    color: 'yellow',
                    title: 'yellow',
                    child: Text('shade 0 / 6')),
                SizedBox(height: 6),
                PlinthAlert(
                    color: 'violet',
                    title: 'violet',
                    child: Text('shade 0 / 6')),
              ],
            ),
          ),
          width: 360,
          height: 300,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_alert_palette.png'),
      );
    });

    testWidgets('dark theme', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 320,
            child: PlinthAlert(
              title: 'Heads up',
              color: 'blue',
              child: Text('Shades mirror in dark mode.'),
            ),
          ),
          width: 360,
          height: 120,
          dark: true,
        ),
      );

      // `shaded()` mirrors the index in dark themes so a shade-0 wash
      // stays a wash instead of becoming near-white. This is where
      // that would visibly break.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_alert_dark.png'),
      );
    });
  });
}
