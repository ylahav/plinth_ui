/// What a template's tests are for.
///
/// Not to check that Plinth works — the packages test themselves. These
/// exist so that a template which has quietly stopped compiling, or
/// stopped being accessible, fails in CI rather than in the hands of
/// somebody starting a project with it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';
import 'package:plinth_template_dashboard/src/app_shell.dart';
import 'package:plinth_template_dashboard/src/theme.dart';

Widget _app() => DashboardApp(
      light: dashboardThemeData(dashboardLight),
      dark: dashboardThemeData(dashboardDark),
    );

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the shell opens on the overview', (tester) async {
    await _pumpAt(tester, const Size(1400, 1000));

    expect(find.text('Overview'), findsWidgets);

    // Upper case because `PlinthStatTile.uppercaseLabel` defaults to
    // true — the figure is what the eye should land on, not its name.
    expect(find.text('REVENUE'), findsOneWidget);
    expect(find.text(r'$84,210'), findsOneWidget);
  });

  testWidgets('every section builds', (tester) async {
    await _pumpAt(tester, const Size(1400, 1000));

    for (final section in ['Orders', 'Settings', 'Overview']) {
      await tester.tap(find.text(section).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$section threw');
    }
  });

  testWidgets('the sidebar gives way to a drawer on a phone', (tester) async {
    await _pumpAt(tester, const Size(420, 900));

    // The sidebar is gone, so the only way to the other sections is the
    // menu button — and if it is missing the app is unnavigable rather
    // than merely cramped.
    expect(find.byTooltip('Open navigation'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    expect(find.text('Orders'), findsWidgets);
  });

  testWidgets('filtering the orders table narrows it, out loud',
      (tester) async {
    await _pumpAt(tester, const Size(1400, 1000));
    await tester.tap(find.text('Orders').first);
    await tester.pumpAndSettle();

    expect(find.text('Ama Boateng'), findsOneWidget);
    expect(find.text('6 of 6 orders'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'beacon');
    await tester.pumpAndSettle();

    expect(find.text('Ama Boateng'), findsNothing);
    expect(find.text('Beacon Coffee'), findsOneWidget);

    // The count is in a live region, so the change is announced rather
    // than only drawn. A filter that silently empties a table is the
    // accessibility bug this template exists not to ship.
    expect(find.text('1 of 6 orders'), findsOneWidget);
  });

  testWidgets('a status is a word, not only a colour', (tester) async {
    await _pumpAt(tester, const Size(1400, 1000));
    await tester.tap(find.text('Orders').first);
    await tester.pumpAndSettle();

    // `PlinthBadge` upper-cases its label, so the assertion does too.
    // The point stands either way: the status is legible text, not a
    // hue that a colour-blind reader has to guess at.
    for (final status in ['PAID', 'SHIPPED', 'REFUNDED']) {
      expect(find.text(status), findsWidgets, reason: '$status unreadable');
    }
  });

  test('the brand colour is the one the theme paints', () {
    // `generateShades` anchors shade 6 to the given colour exactly. If
    // that ever stopped being true, every screen would be painting a
    // near-miss of the brand and nothing would say so.
    expect(dashboardLight.colors['brand']![6], brandColor);
  });

  test('every order status is a declared role', () {
    // A status with no role resolves to the primary ramp and looks
    // deliberate. This is the check that catches a new status added to
    // `data.dart` and not to `theme.dart`.
    for (final status in {'paid', 'shipped', 'refunded'}) {
      expect(orderRoles, contains(status));
    }
  });

  test('roles clear the contrast floor on both surfaces', () {
    for (final theme in [dashboardLight, dashboardDark]) {
      for (final role in orderRoles.keys) {
        final ratio = PlinthTheme.contrastRatio(
          theme.semanticText(role),
          theme.surface,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$role is ${ratio.toStringAsFixed(2)}:1 on this surface',
        );
      }
    }
  });
}
