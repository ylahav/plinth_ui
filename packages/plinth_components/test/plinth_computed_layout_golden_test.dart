@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

import 'helpers/golden.dart';

/// Golden coverage for the components that place things by arithmetic
/// rather than by layout.
///
/// Every other component here hands its children to a `Row`, a
/// `Stack`, or a `Table` and lets Flutter position them — get the
/// props right and the pixels follow. These don't: they compute an
/// offset, an angle, or a fit, and paint at it. A behaviour test can
/// confirm the number that went in; only an image confirms where the
/// glyph or the arc came out.
///
/// That distinction is not theoretical. `PlinthRollingNumber` shipped
/// in 0.16.1 placing every wheel above the units at
/// `value / 10^place`, so 58,210 rendered closer to 68,210 — while 494
/// tests passed, because the semantics label was correct throughout.
/// A human reading the showcase found it. These images are the cheaper
/// version of that human.
void main() {
  group('computed layout golden', () {
    testWidgets('rolling number at rest', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const PlinthRollingNumber(
            value: 58210,
            prefix: r'$',
            size: PlinthSize.xl,
            weight: FontWeight.w700,
          ),
          width: 260,
          height: 80,
        ),
      );
      await tester.pumpAndSettle();

      // The exact value that exposed the carry bug: every wheel should
      // sit flush, and the digits should read 58,210 rather than the
      // glyph above each one.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_rolling_number_rest.png'),
      );
    });

    testWidgets('semi circle and ring progress', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlinthSemiCircleProgress(
                value: 0.72,
                diameter: 140,
                label: PlinthText('72%', weight: FontWeight.w700),
              ),
              SizedBox(width: 24),
              PlinthRingProgress(
                value: 0.72,
                label: PlinthText('72%', weight: FontWeight.w700),
              ),
            ],
          ),
          width: 320,
          height: 140,
        ),
      );

      // Both sweep the same fraction from the same origin; side by side
      // is where a wrong start angle or direction is obvious.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_progress_arcs.png'),
      );
    });

    testWidgets('angle slider sweeps clockwise from twelve', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final angle in [0.0, 45.0, 135.0, 270.0]) ...[
                PlinthAngleSlider(
                    value: angle, onChanged: (_) {}, diameter: 64),
                const SizedBox(width: 12),
              ],
            ],
          ),
          width: 360,
          height: 100,
        ),
      );

      // Zero points up and the value grows clockwise. Four positions
      // pin both the origin and the direction — one would pin neither.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_angle_slider_sweep.png'),
      );
    });

    testWidgets('slider marks sit over their positions', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          SizedBox(
            width: 320,
            child: PlinthSlider(
              value: 50,
              divisions: 4,
              onChanged: (_) {},
              marks: const [
                PlinthSliderMark(value: 0, label: 'Off'),
                PlinthSliderMark(value: 25, label: 'Low'),
                PlinthSliderMark(value: 50, label: 'Mid'),
                PlinthSliderMark(value: 100, label: 'Max'),
              ],
            ),
          ),
          width: 360,
          height: 90,
        ),
      );

      // Marks are placed by arithmetic against a track this widget
      // doesn't draw: Flutter's slider insets it by a thumb radius at
      // each end. A test can assert the centre label's x; only the
      // image shows whether "Off" and "Max" line up with the ends, and
      // whether an unevenly spaced mark (100 after 50) lands right.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_slider_marks.png'),
      );
    });

    testWidgets('overflow list, everything fits', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 320,
            child: PlinthOverflowList(
              children: [
                PlinthBadge('Design'),
                PlinthBadge('Research'),
                PlinthBadge('Copy'),
              ],
            ),
          ),
          width: 360,
          height: 60,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_overflow_list_fits.png'),
      );
    });

    testWidgets('overflow list, collapsed', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 200,
            child: PlinthOverflowList(
              children: [
                PlinthBadge('Design'),
                PlinthBadge('Research'),
                PlinthBadge('Copy'),
                PlinthBadge('QA'),
                PlinthBadge('Operations'),
              ],
            ),
          ),
          width: 240,
          height: 60,
        ),
      );

      // The marker is painted by the render object rather than being a
      // child widget, so this is the only place its position, baseline
      // and count can be checked at all.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_overflow_list_collapsed.png'),
      );
    });

    testWidgets('colour slider tracks and thumbs', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          SizedBox(
            width: 280,
            child: PlinthStack(
              gap: PlinthSize.md,
              children: [
                PlinthHueSlider(value: 210, onChanged: (_) {}),
                PlinthAlphaSlider(
                  color: const Color(0xFF1971C2),
                  value: 0.6,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          width: 320,
          height: 120,
        ),
      );

      // Thumb offsets are computed from the value against the track
      // width, and the alpha track's chequer is painted rather than
      // laid out — neither is reachable from a widget test.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_colour_sliders.png'),
      );
    });
  });
}
