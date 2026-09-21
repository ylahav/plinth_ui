/// Tests that this app still works, not that Plinth does.
///
/// The interesting ones are the two layouts: a phone has to *push* the
/// detail so the system back button works, and a tablet has to not push
/// it so the list stays on screen. A starter that gets this wrong looks
/// right in a screenshot of either one.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';
import 'package:plinth_template_mobile/src/app.dart';
import 'package:plinth_template_mobile/src/data.dart';
import 'package:plinth_template_mobile/src/theme.dart';

const _phone = Size(400, 900);
const _tablet = Size(1100, 900);

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MobileApp(
      light: mobileThemeData(mobileLight),
      dark: mobileThemeData(mobileDark),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the list shows every shipment', (tester) async {
    await _pump(tester, _phone);

    for (final shipment in shipments) {
      expect(find.text(shipment.reference), findsWidgets, reason: 'missing');
    }
  });

  testWidgets('on a phone the detail is a route, so back works',
      (tester) async {
    await _pump(tester, _phone);
    await tester.tap(find.text(shipments.first.reference).first);
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);

    // The list is gone, which is how you know a route was pushed and
    // not a pane swapped.
    expect(find.text(shipments.last.reference), findsNothing);

    // And the system back button returns, without this app
    // implementing back.
    final popped = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(popped, isTrue);
    expect(find.text(shipments.last.reference), findsWidgets);
  });

  testWidgets('on a tablet both panes are on screen', (tester) async {
    await _pump(tester, _tablet);

    expect(find.text('Nothing selected'), findsOneWidget);

    await tester.tap(find.text(shipments.first.reference).first);
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);

    // The list is still there. Pushing a route here would hide it and
    // waste the half of the screen the tablet has.
    expect(find.text(shipments.last.reference), findsWidgets);
  });

  testWidgets('every shipment opens without throwing', (tester) async {
    await _pump(tester, _tablet);

    for (final shipment in shipments) {
      await tester.tap(find.text(shipment.reference).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: shipment.reference);
    }
  });

  testWidgets('searching narrows the list, out loud', (tester) async {
    await _pump(tester, _phone);
    expect(find.text('5 of 5 shipments'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'porto');
    await tester.pumpAndSettle();

    expect(find.text('1 of 5 shipments'), findsOneWidget);
    expect(find.text('SHP-2291'), findsWidgets);
    expect(find.text('SHP-2274'), findsNothing);
  });

  testWidgets('a search with no matches says so', (tester) async {
    await _pump(tester, _phone);
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No matching shipments'), findsOneWidget);
    expect(find.text('0 of 5 shipments'), findsOneWidget);
  });

  testWidgets('a status is a word, not only a colour', (tester) async {
    await _pump(tester, _phone);

    // Upper case because PlinthBadge upper-cases its label. Four
    // statuses is past where a hue can carry the difference alone.
    for (final status in ['IN TRANSIT', 'DELAYED', 'DELIVERED', 'LOST']) {
      expect(find.text(status), findsWidgets, reason: '$status unreadable');
    }
  });

  test('the brand colour is the one the theme paints', () {
    expect(mobileLight.colors['brand']![6], brandColor);
  });

  test('every status in the data is declared in the theme', () {
    for (final shipment in shipments) {
      expect(shipmentRoles, contains(shipment.status));
    }
  });

  test('statuses clear the contrast floor on both surfaces', () {
    // `delayed` is amber, which is about 1.9:1 at shade 6 on white.
    // This is the assertion that would fail if the role indirection
    // were ever replaced with a hardcoded colour.
    for (final theme in [mobileLight, mobileDark]) {
      for (final status in shipmentRoles.keys) {
        final ratio = PlinthTheme.contrastRatio(
          theme.semanticText(status),
          theme.surface,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$status is ${ratio.toStringAsFixed(2)}:1',
        );
      }
    }
  });
}
