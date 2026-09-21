/// Tests that this app still works, not that Plinth does.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';
import 'package:plinth_template_account/src/app.dart';
import 'package:plinth_template_account/src/session.dart';
import 'package:plinth_template_account/src/theme.dart';

Future<void> _pump(WidgetTester tester,
    {Size size = const Size(1200, 1000)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AccountApp(
      light: accountThemeData(accountLight),
      dark: accountThemeData(accountDark),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester, String password) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), 'ada@example.com');
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.text('Sign in').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the app opens signed out', (tester) async {
    await _pump(tester);

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Sign out'), findsNothing);
  });

  testWidgets('a wrong password is an error about the attempt', (tester) async {
    await _pump(tester);
    await _signIn(tester, 'wrong');

    expect(find.textContaining('do not match'), findsOneWidget);

    // Still signed out, and still on the form with the email intact —
    // a failed sign-in that clears the form is its own small cruelty.
    expect(find.text('Sign out'), findsNothing);
  });

  testWidgets('the right password gets in', (tester) async {
    await _pump(tester);
    await _signIn(tester, 'plinth');

    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('ada@example.com'), findsWidgets);
  });

  testWidgets('every tab builds, and signing out goes back', (tester) async {
    await _pump(tester);
    await _signIn(tester, 'plinth');

    for (final tab in ['Security', 'Permissions', 'Profile']) {
      await tester.tap(find.text(tab).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tab threw');
    }

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('two-factor survives a tab change', (tester) async {
    await _pump(tester);
    await _signIn(tester, 'plinth');
    await tester.tap(find.text('Security').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PlinthSwitch).first);
    await tester.pumpAndSettle();

    // The session owns this, not the screen. If it lived in the screen's
    // State it would reset on every tab change and look like a save bug.
    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Security').first);
    await tester.pumpAndSettle();

    final toggle = tester.widget<PlinthSwitch>(find.byType(PlinthSwitch).first);
    expect(toggle.value, isTrue);

    // And a reader is told, because `PlinthSwitch` carries the state as
    // a semantics flag rather than only as a painted thumb position.
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(PlinthSwitch).first),
      matchesSemantics(
        isToggled: true,
        hasToggledState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
        // The description is merged into the label rather than left
        // beside it, so a reader hears what the setting does and not
        // only what it is called. Built from the widget so the two
        // cannot drift apart.
        label: '${toggle.label}\n${toggle.description}',
      ),
    );
    handle.dispose();
  });

  testWidgets('a role is a word, not only a colour', (tester) async {
    await _pump(tester);
    await _signIn(tester, 'plinth');
    await tester.tap(find.text('Permissions').first);
    await tester.pumpAndSettle();

    // Upper case because PlinthBadge upper-cases its label.
    for (final role in ['OWNER', 'ADMIN', 'MEMBER', 'INVITED']) {
      expect(find.text(role), findsWidgets, reason: '$role unreadable');
    }
  });

  test('the brand colour is the one the theme paints', () {
    expect(accountLight.colors['brand']![6], brandColor);
  });

  test('every role in the data is declared in the theme', () {
    for (final member in team) {
      expect(teamRoles, contains(member.role));
    }
  });

  test('roles clear the contrast floor on both surfaces', () {
    // Four roles, two surfaces. `invited` is grey, which is where a
    // shade picked by eye is most likely to land under the floor.
    for (final theme in [accountLight, accountDark]) {
      for (final role in teamRoles.keys) {
        final ratio = PlinthTheme.contrastRatio(
          theme.semanticText(role),
          theme.surface,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$role is ${ratio.toStringAsFixed(2)}:1',
        );
      }
    }
  });
}
