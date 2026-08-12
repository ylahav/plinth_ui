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
  group('PlinthFlex', () {
    testWidgets('renders every child', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthFlex(children: [Text('One'), Text('Two')])),
      );

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('uses Row for horizontal direction (the default)',
        (tester) async {
      await tester.pumpWidget(_wrap(const PlinthFlex(children: [Text('One')])));

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsNothing);
    });

    testWidgets('uses Column for vertical direction', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthFlex(
            direction: Axis.vertical, children: [Text('One')])),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });
  });

  group('PlinthScrollArea', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 100,
            child: PlinthScrollArea(
                child: Column(children: const [Text('Content')])),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('shows an always-visible scrollbar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 100,
            child: PlinthScrollArea(
              child: Column(
                  children: [for (var i = 0; i < 20; i++) Text('Item $i')]),
            ),
          ),
        ),
      );

      expect(find.byType(Scrollbar), findsOneWidget);
      final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
      expect(scrollbar.thumbVisibility, isTrue);
    });
  });

  group('PlinthPortal', () {
    testWidgets('renders its child into the overlay', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthPortal(child: Text('Portaled content'))),
      );

      expect(find.text('Portaled content'), findsOneWidget);
    });

    testWidgets('removing the portal from the tree removes its overlay entry',
        (tester) async {
      var showPortal = true;
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                if (showPortal)
                  const PlinthPortal(child: Text('Portaled content')),
                TextButton(
                  onPressed: () => setState(() => showPortal = false),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Portaled content'), findsOneWidget);

      await tester.tap(find.text('Remove'));
      await tester.pump();

      expect(find.text('Portaled content'), findsNothing);
    });
  });
}
