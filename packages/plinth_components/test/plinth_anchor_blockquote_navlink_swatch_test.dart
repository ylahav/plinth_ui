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
  group('PlinthAnchor', () {
    testWidgets('renders its label', (tester) async {
      await tester
          .pumpWidget(_wrap(PlinthAnchor('Forgot password?', onTap: () {})));

      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PlinthAnchor('Forgot password?', onTap: () => tapped = true)),
      );

      await tester.tap(find.text('Forgot password?'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('PlinthBlockquote', () {
    testWidgets('renders the quote', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBlockquote(quote: 'Stay hungry, stay foolish.')),
      );

      expect(find.text('Stay hungry, stay foolish.'), findsOneWidget);
    });

    testWidgets('renders the citation when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBlockquote(quote: 'Quote text', citation: 'Steve Jobs'),
        ),
      );

      expect(find.text('— Steve Jobs'), findsOneWidget);
    });

    testWidgets('omits the citation line when not provided', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBlockquote(quote: 'Quote text')),
      );

      expect(find.textContaining('—'), findsNothing);
    });
  });

  group('PlinthNavLink', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthNavLink(label: 'Dashboard')),
      );

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PlinthNavLink(label: 'Dashboard', onTap: () => tapped = true)),
      );

      await tester.tap(find.text('Dashboard'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('PlinthColorSwatch', () {
    testWidgets('shows a checkmark when selected', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthColorSwatch(color: 'blue', selected: true)),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not show a checkmark when unselected', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthColorSwatch(color: 'blue', selected: false)),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PlinthColorSwatch(color: 'blue', onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(PlinthColorSwatch));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
