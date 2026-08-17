@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

import 'helpers/golden.dart';

/// Golden coverage for the four components that render somewhere other
/// than where they are written.
///
/// The [pre-1.0 audit](../../../docs/PRE_1_0_AUDIT.md) named these as
/// the gap the other six golden files leave: *"the overlay components
/// (menu, popover, drawer, modal), which no image covers because each
/// needs an interaction pumped first."* That was the whole obstacle —
/// an open panel needs a controller opened and the frame settled — and
/// it is one `pumpAndSettle` per image.
///
/// What they are actually for: a popover is placed by
/// `CompositedTransformFollower` against a `LayerLink`, which is
/// arithmetic on two anchors and an offset. A behaviour test can only
/// ask whether the content is in the tree — `find.text('Edit')` passes
/// just as happily when the panel is behind its own trigger, off the
/// side of the screen, or on the wrong edge entirely. Where it landed
/// is a question only an image answers.
///
/// This library has been taught that three times: the rolling number's
/// wheels, the vertical stepper's connectors, and the indicator dot
/// drawn at its child's full size.
///
/// **The hard black band along the drawer's edge is not a bug.**
/// `flutter_test` sets `debugDisableShadows = true`, which paints an
/// elevation as a solid rectangle instead of a blurred one; the drawer
/// is the only overlay here with an elevation (`8`). Rendering with
/// shadows enabled turns that band into the expected soft gradient.
/// Left at the default deliberately — a blurred shadow is exactly the
/// kind of antialiasing these images should not be pinned to — so
/// these goldens pin the shadow's *extent* and not its softness.
void main() {
  /// Every overlay here is driven by a disclosure controller rather
  /// than a tap, so the image is of a settled open state rather than
  /// of whatever frame a tap happened to land on.
  Future<PlinthDisclosureController> opened(WidgetTester tester) async {
    final controller = PlinthDisclosureController();
    addTearDown(controller.dispose);
    return controller;
  }

  group('overlay golden', () {
    testWidgets('menu, open under its target', (tester) async {
      useGoldenSurface(tester, width: 260, height: 260);
      final controller = await opened(tester);

      await tester.pumpWidget(
        overlayGoldenWrap(
          // Near the top rather than centred: the panel opens downward
          // and a centred trigger puts half of it past the bottom
          // edge, which is a fixture problem rather than a finding —
          // this popover does not flip (see the note below).
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: PlinthMenu(
                controller: controller,
                target: const Icon(Icons.more_vert),
                items: [
                  PlinthMenuItem(label: 'Edit', onTap: () {}),
                  PlinthMenuItem(label: 'Duplicate', onTap: () {}),
                  const PlinthMenuItem.divider(),
                  PlinthMenuItem(label: 'Delete', onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      // The divider between the safe items and the destructive one is
      // the detail worth a picture: it is a one-pixel rule inside a
      // panel, and a menu with it missing looks entirely normal.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_menu_open.png'),
      );
    });

    testWidgets('popover, on each of its four sides', (tester) async {
      useGoldenSurface(tester, width: 360, height: 300);

      for (final (position, name) in const [
        (PlinthPopoverPosition.top, 'top'),
        (PlinthPopoverPosition.bottom, 'bottom'),
        (PlinthPopoverPosition.left, 'left'),
        (PlinthPopoverPosition.right, 'right'),
      ]) {
        final controller = await opened(tester);

        await tester.pumpWidget(
          overlayGoldenWrap(
            Center(
              child: PlinthPopover(
                controller: controller,
                position: position,
                width: 100,
                target: const PlinthBadge('Anchor'),
                content: const Text('Panel'),
              ),
            ),
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

        // Four images rather than one composite: the anchors are four
        // independent pairs of `Alignment`s, and a composite would let
        // one wrong pair hide inside a picture that still looks busy
        // and plausible.
        await expectLater(
          find.byKey(goldenBoundary),
          matchesGoldenFile('goldens/plinth_popover_$name.png'),
        );
      }
    });

    testWidgets('drawer, open from the right over its scrim', (tester) async {
      useGoldenSurface(tester, width: 400, height: 260);
      final controller = await opened(tester);

      await tester.pumpWidget(
        overlayGoldenWrap(
          PlinthDrawerHost(
            drawer: PlinthDrawer(
              controller: controller,
              title: 'Filters',
              size: PlinthSize.xs,
              child: const Text('Body'),
            ),
            // Left-aligned so the page sits under the scrim rather
            // than behind the panel — a scrim over blank white says
            // nothing about how much it dims.
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text('Page'),
              ),
            ),
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      // The panel's edge, the scrim's density and the page still
      // visible beside it are three things that only read together.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_drawer_right.png'),
      );
    });

    testWidgets('modal, centred over its scrim', (tester) async {
      useGoldenSurface(tester, width: 400, height: 300);
      final controller = await opened(tester);

      await tester.pumpWidget(
        overlayGoldenWrap(
          PlinthModalHost(
            modal: PlinthModal(
              controller: controller,
              title: 'Delete project',
              size: PlinthSize.xs,
              child: const Text('This cannot be undone.'),
            ),
            child: const Center(child: Text('Page')),
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_modal_open.png'),
      );
    });

    testWidgets('modal on a dark page', (tester) async {
      useGoldenSurface(tester, width: 400, height: 300);
      final controller = await opened(tester);

      await tester.pumpWidget(
        overlayGoldenWrap(
          dark: true,
          PlinthModalHost(
            modal: PlinthModal(
              controller: controller,
              title: 'Delete project',
              size: PlinthSize.xs,
              child: const Text('This cannot be undone.'),
            ),
            child: const Center(child: Text('Page')),
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      // A scrim is a black wash at low opacity, which is the one
      // treatment that can vanish entirely on a dark page — the panel
      // would then float with nothing separating it from the page
      // behind.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_modal_dark.png'),
      );
    });
  });
}
