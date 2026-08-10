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
  group('PlinthPaper', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthPaper(child: Text('Surface content'))),
      );

      expect(find.text('Surface content'), findsOneWidget);
    });

    testWidgets('every shadow level renders without throwing', (tester) async {
      for (final shadow in PlinthShadow.values) {
        await tester.pumpWidget(
          _wrap(PlinthPaper(shadow: shadow, child: const Text('X'))),
        );
        expect(find.text('X'), findsOneWidget);
      }
    });
  });

  group('PlinthCard', () {
    testWidgets('renders child only when header/footer are omitted', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCard(child: Text('Body only'))),
      );

      expect(find.text('Body only'), findsOneWidget);
      // No divider should render without header/footer.
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('renders header, body, and footer with dividers between them', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthCard(
            header: Text('Title'),
            footer: Text('Footer'),
            child: Text('Body'),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
      // One divider between header/body, one between body/footer.
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('renders only a header divider when footer is omitted', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthCard(
            header: Text('Title'),
            child: Text('Body'),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
