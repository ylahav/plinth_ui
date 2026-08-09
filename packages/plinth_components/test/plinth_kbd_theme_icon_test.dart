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
  group('PlinthKbd', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthKbd('Ctrl')));

      expect(find.text('Ctrl'), findsOneWidget);
    });
  });

  group('PlinthThemeIcon', () {
    testWidgets('renders its icon', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthThemeIcon(icon: const Icon(Icons.check))),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('every variant renders without throwing', (tester) async {
      for (final variant in PlinthVariant.values) {
        await tester.pumpWidget(
          _wrap(
              PlinthThemeIcon(icon: const Icon(Icons.star), variant: variant)),
        );
        expect(find.byIcon(Icons.star), findsOneWidget);
      }
    });
  });
}
