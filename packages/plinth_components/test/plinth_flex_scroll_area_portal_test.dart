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
      // The insert is deferred to a post-frame callback (inserting
      // synchronously during this widget's own first build would hit
      // Flutter's "setState during build" assertion, since the
      // ancestor Overlay would also still be mid-build) — one more
      // pump lets that callback fire.
      await tester.pump();

      expect(find.text('Portaled content'), findsOneWidget);
    });

    testWidgets('removing the portal from the tree removes its overlay entry',
        (tester) async {
      // Unmount by pumping a tree without the portal rather than by
      // tapping an in-tree button: the portal's overlay entry covers
      // the whole screen, so it sits on top of any such button and
      // swallows the tap before it lands.
      await tester.pumpWidget(
        _wrap(const Column(children: [PlinthPortal(child: Text('Portaled'))])),
      );
      await tester.pump();

      expect(find.text('Portaled'), findsOneWidget);

      await tester.pumpWidget(_wrap(const Column(children: [])));
      await tester.pump();

      expect(find.text('Portaled'), findsNothing);
    });
  });
}
