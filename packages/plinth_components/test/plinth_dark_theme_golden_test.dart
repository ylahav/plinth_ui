@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

import 'helpers/golden.dart';

/// The dark theme, across the chrome rather than one component at a
/// time.
///
/// Two dark images existed before this: `plinth_text_input_dark` and
/// `plinth_alert_dark`, each pinning its own component. Everything else
/// was only ever rendered light — and dark is where a hardcoded colour
/// hides: a `Colors.white` surface, a `Colors.grey` border, a
/// foreground resolved against the wrong background. None of that fails
/// a behaviour test, and the contrast suite only checks the palette
/// ramps, not whether a component reads the tokens at all.
///
/// One image per group rather than one per component: the point is
/// whether the chrome follows the theme, and twelve components in one
/// picture make an unfollowed token obvious by contrast with its
/// neighbours.
void main() {
  group('dark theme golden', () {
    testWidgets('surfaces, text and borders follow the dark tokens',
        (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          dark: true,
          width: 320,
          // Tall enough for the stack: the first run of this came back
          // 65px short, and an overflow stripe is not a golden anyone
          // wants to inherit.
          height: 340,
          SizedBox(
            width: 280,
            child: PlinthStack(
              gap: PlinthSize.sm,
              mainAxisSize: MainAxisSize.min,
              children: [
                const PlinthPaper(
                  withBorder: true,
                  child: PlinthText('Paper with a border'),
                ),
                const PlinthTextInput(
                  label: 'Email',
                  placeholder: 'you@example.com',
                ),
                const PlinthAlert(
                  title: 'Heads up',
                  child: PlinthText('An alert on a dark surface'),
                ),
                PlinthGroup(
                  gap: PlinthSize.sm,
                  children: [
                    const PlinthBadge('Beta'),
                    const PlinthKbd('Ctrl'),
                    PlinthButton(
                      size: PlinthSize.sm,
                      onPressed: () {},
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_dark_surfaces.png'),
      );
    });

    testWidgets('a disabled control is legible against a dark surface',
        (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          dark: true,
          width: 300,
          height: 160,
          PlinthStack(
            gap: PlinthSize.sm,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlinthButton(
                    size: PlinthSize.sm,
                    onPressed: () {},
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 12),
                  const PlinthButton(
                    size: PlinthSize.sm,
                    onPressed: null,
                    child: Text('Save'),
                  ),
                ],
              ),
              const PlinthTextInput(label: 'Locked', enabled: false),
            ],
          ),
        ),
      );

      // `surfaceMuted` and `textDisabled` are separate tokens per
      // theme, and the disabled treatment added in 0.19.0 was only
      // ever looked at in light mode. Dark is where a muted fill can
      // land *lighter* than the surface it sits on and read as
      // emphasis rather than absence.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_dark_disabled.png'),
      );
    });
  });
}
