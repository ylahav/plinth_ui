/// A bottom sheet that covers the page, which the size scale could not
/// express.
///
/// Reported by somebody building a real screen: `PlinthDrawer` from the
/// bottom tops out at 600px at `xl`, every phone is taller than that,
/// so they dropped to a plain full-screen route — which works, and
/// loses the drawer's scrim, dismissal and animation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

/// Builds a drawer with a controller, since `PlinthDrawer` requires
/// one and this file is about extent rather than disclosure.
PlinthDrawer _drawer({
  required PlinthDrawerPosition position,
  PlinthSize size = PlinthSize.md,
  double? extent,
  required Widget child,
}) =>
    PlinthDrawer(
      controller: PlinthDisclosureController(),
      position: position,
      size: size,
      extent: extent,
      child: child,
    );

Future<void> _show(WidgetTester tester, PlinthDrawer drawer) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(
      body: Builder(
        builder: (context) => PlinthButton(
          onPressed: () => drawer.show(context),
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

double _panelHeight(WidgetTester tester) =>
    tester.getSize(find.byKey(const ValueKey('sheet-body'))).height;

void main() {
  const body = SizedBox(key: ValueKey('sheet-body'), height: 2000);

  testWidgets('the scale still tops out where it always did', (tester) async {
    // Not a regression test for the ceiling — a test that the ceiling
    // is still the default, so nothing moved for anyone not asking.
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _show(
      tester,
      _drawer(
        position: PlinthDrawerPosition.bottom,
        size: PlinthSize.xl,
        child: body,
      ),
    );
    expect(_panelHeight(tester), lessThanOrEqualTo(600));
  });

  testWidgets('an explicit extent overrides the scale', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _show(
      tester,
      _drawer(
        position: PlinthDrawerPosition.bottom,
        extent: 750,
        child: body,
      ),
    );
    expect(_panelHeight(tester), greaterThan(600));
  });

  testWidgets('double.infinity fills the screen', (tester) async {
    // The case that sent somebody to a plain route.
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _show(
      tester,
      _drawer(
        position: PlinthDrawerPosition.bottom,
        extent: double.infinity,
        child: body,
      ),
    );

    // Not exactly 900: the panel pads its own content by `lg` on each
    // side, so the *child* is the screen minus that. Asserting the
    // padding arithmetic would pin a number that has nothing to do
    // with this feature; asserting it clears the old ceiling by a
    // wide margin is the actual claim.
    expect(_panelHeight(tester), greaterThan(800));
  });

  testWidgets('and works on a side drawer too', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _show(
      tester,
      _drawer(
        position: PlinthDrawerPosition.left,
        extent: double.infinity,
        child: const SizedBox(key: ValueKey('sheet-body'), width: 2000),
      ),
    );
    // Screen width minus the panel's own padding, as above.
    expect(
      tester.getSize(find.byKey(const ValueKey('sheet-body'))).width,
      greaterThan(300),
      reason: 'a full-width side drawer was still bounded by the scale',
    );
  });
}
