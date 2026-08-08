import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('PlinthBreadcrumbs', () {
    testWidgets('renders every label and a separator between each',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthBreadcrumbs(
            items: [
              PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
              PlinthBreadcrumbItem(label: 'Settings', onTap: () {}),
              const PlinthBreadcrumbItem(label: 'Profile'),
            ],
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      // 3 items -> 2 separators.
      expect(find.text('/'), findsNWidgets(2));
    });

    testWidgets('tapping a non-last crumb calls its onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          PlinthBreadcrumbs(
            items: [
              PlinthBreadcrumbItem(label: 'Home', onTap: () => tapped = true),
              const PlinthBreadcrumbItem(label: 'Profile'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('the last crumb is not tappable even if given onTap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          PlinthBreadcrumbs(
            items: [
              const PlinthBreadcrumbItem(label: 'Home'),
              PlinthBreadcrumbItem(
                  label: 'Profile', onTap: () => tapped = true),
            ],
          ),
        ),
      );

      // Tapping the last crumb should have no effect — it's rendered
      // as plain Text, not wrapped in an InkWell, regardless of
      // whether onTap was provided.
      await tester.tap(find.text('Profile'), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('respects a custom separator', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthBreadcrumbs(
            separator: '>',
            items: [
              const PlinthBreadcrumbItem(label: 'Home'),
              const PlinthBreadcrumbItem(label: 'Profile'),
            ],
          ),
        ),
      );

      expect(find.text('>'), findsOneWidget);
      expect(find.text('/'), findsNothing);
    });
  });
}
