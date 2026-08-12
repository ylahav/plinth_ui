import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

/// Constrains [child] to a known width so the layout assertions below
/// compute against a number they chose.
///
/// Keep [width] at or under 800: that is the test viewport's width, and
/// a SizedBox asking for more is simply clamped to it, which would make
/// an assertion silently measure the wrong grid.
Widget _atWidth(double width, Widget child) {
  return _wrap(
    Center(
      child: SizedBox(width: width, height: 600, child: child),
    ),
  );
}

void main() {
  group('PlinthAppShell', () {
    testWidgets('renders the child region', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthAppShell(child: Text('Main content'))),
      );

      expect(find.text('Main content'), findsOneWidget);
    });

    testWidgets('omits regions left null rather than rendering them empty',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthAppShell(child: Text('Main content'))),
      );

      expect(find.text('Header'), findsNothing);
      expect(find.text('Navbar'), findsNothing);
      expect(find.text('Aside'), findsNothing);
      expect(find.text('Footer'), findsNothing);
    });

    testWidgets('renders every region when all are provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthAppShell(
            header: Text('Header'),
            navbar: Text('Navbar'),
            aside: Text('Aside'),
            footer: Text('Footer'),
            child: Text('Main content'),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Navbar'), findsOneWidget);
      expect(find.text('Aside'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
      expect(find.text('Main content'), findsOneWidget);
    });

    testWidgets('navbarCollapsed hides the navbar but keeps the child',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthAppShell(
            navbar: Text('Navbar'),
            navbarCollapsed: true,
            child: Text('Main content'),
          ),
        ),
      );

      expect(find.text('Navbar'), findsNothing);
      expect(find.text('Main content'), findsOneWidget);
    });

    testWidgets('asideCollapsed hides the aside independently of the navbar',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthAppShell(
            navbar: Text('Navbar'),
            aside: Text('Aside'),
            asideCollapsed: true,
            child: Text('Main content'),
          ),
        ),
      );

      expect(find.text('Navbar'), findsOneWidget);
      expect(find.text('Aside'), findsNothing);
    });

    testWidgets('gives the navbar the width it was asked for', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthAppShell(
            navbarWidth: 200,
            withBorder: false,
            navbar: SizedBox(key: Key('navbar'), height: 20),
            child: Text('Main content'),
          ),
        ),
      );

      expect(tester.getSize(find.byKey(const Key('navbar'))).width, 200);
    });

    testWidgets('the divider is drawn inside the region, not added to it',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthAppShell(
            navbarWidth: 200,
            navbar: SizedBox(key: Key('navbar'), height: 20),
            child: Text('Main content'),
          ),
        ),
      );

      // The region stays exactly navbarWidth wide either way — a
      // BoxDecoration border insets its child rather than growing the
      // box, so turning borders on costs the content a pixel instead
      // of shifting the whole layout across.
      expect(tester.getSize(find.byKey(const Key('navbar'))).width, 199);
    });
  });

  group('PlinthGrid', () {
    testWidgets('renders every column', (tester) async {
      await tester.pumpWidget(
        _atWidth(
          600,
          const PlinthGrid(
            children: [
              PlinthGridCol(child: Text('One')),
              PlinthGridCol(child: Text('Two')),
            ],
          ),
        ),
      );

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('a half span is about half the grid width', (tester) async {
      await tester.pumpWidget(
        _atWidth(
          600,
          const PlinthGrid(
            gutter: PlinthSize.md,
            children: [
              // A fixed height, not SizedBox.expand: Wrap lays its
              // children out with unbounded height, so an expanding
              // child would be asked to be infinitely tall.
              PlinthGridCol(
                  span: 6, child: SizedBox(key: Key('L'), height: 20)),
              PlinthGridCol(
                  span: 6, child: SizedBox(key: Key('R'), height: 20)),
            ],
          ),
        ),
      );

      // 600 wide, 12 columns, 16px gutters: each column unit is
      // (600 - 16*11)/12 = 35.33, and a span of 6 covers 6 units plus
      // the 5 gutters between them.
      final width = tester.getSize(find.byKey(const Key('L'))).width;
      expect(width, closeTo((600 - 16 * 11) / 12 * 6 + 16 * 5, 0.01));
      expect(
        tester.getSize(find.byKey(const Key('R'))).width,
        closeTo(width, 0.01),
      );
    });

    testWidgets('per-breakpoint spans apply from that width upward',
        (tester) async {
      const col = PlinthGridCol(span: 12, spanMd: 6, child: Text('C'));

      // spanMd applies at md (992) and above, so a 700px grid still
      // uses the unqualified span — mobile-first, matching CSS.
      expect(col.spanFor(700), 12);
      expect(col.spanFor(1100), 6);
    });

    testWidgets('the largest matching breakpoint wins', (tester) async {
      const col = PlinthGridCol(
        span: 12,
        spanSm: 8,
        spanMd: 6,
        spanLg: 3,
        child: Text('C'),
      );

      expect(col.spanFor(500), 12);
      expect(col.spanFor(800), 8);
      expect(col.spanFor(1000), 6);
      expect(col.spanFor(1300), 3);
    });

    testWidgets('a span wider than the grid is clamped, not overflowed',
        (tester) async {
      await tester.pumpWidget(
        _atWidth(
          600,
          const PlinthGrid(
            columns: 12,
            children: [
              PlinthGridCol(
                  span: 40, child: SizedBox(key: Key('W'), height: 20)),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('W'))).width,
        closeTo(600, 0.01),
      );
    });
  });

  group('PlinthLoader', () {
    testWidgets('every type renders without throwing', (tester) async {
      for (final type in PlinthLoaderType.values) {
        await tester.pumpWidget(_wrap(PlinthLoader(type: type)));
        // Not pumpAndSettle: the dots and bars types animate forever,
        // so waiting for the tree to go quiet would time out.
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the oval type defers to Flutter\'s own indicator',
        (tester) async {
      await tester.pumpWidget(_wrap(const PlinthLoader()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('size drives the rendered extent', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthLoader(size: PlinthSize.xs)),
      );
      final small = tester.getSize(find.byType(CircularProgressIndicator));

      await tester.pumpWidget(
        _wrap(const PlinthLoader(size: PlinthSize.xl)),
      );
      final large = tester.getSize(find.byType(CircularProgressIndicator));

      expect(large.width, greaterThan(small.width));
    });

    testWidgets('disposes its ticker when removed from the tree',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthLoader(type: PlinthLoaderType.dots)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // A repeating controller that outlives its State fails the test
      // binding's ticker check at teardown, so replacing the tree is
      // what exercises dispose().
      await tester.pumpWidget(_wrap(const SizedBox()));

      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthTitle', () {
    testWidgets('renders its text', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTitle('Getting started')));

      expect(find.text('Getting started'), findsOneWidget);
    });

    testWidgets('exposes heading semantics at the given level', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTitle('Section', order: 3)),
      );

      final semantics = tester.getSemantics(find.text('Section'));
      // The whole reason this exists rather than a large PlinthText:
      // screen readers can navigate by heading, and the level tells
      // them whether they moved to a sibling or a subsection.
      expect(semantics.flagsCollection.isHeader, isTrue);
      expect(semantics.headingLevel, 3);
    });

    testWidgets('a lower order renders larger text', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTitle('T', order: 1)));
      final h1 = tester.widget<Text>(find.text('T')).style!.fontSize;

      await tester.pumpWidget(_wrap(const PlinthTitle('T', order: 6)));
      final h6 = tester.widget<Text>(find.text('T')).style!.fontSize;

      expect(h1, greaterThan(h6!));
    });

    testWidgets('every valid order renders', (tester) async {
      for (var order = 1; order <= 6; order++) {
        await tester.pumpWidget(_wrap(PlinthTitle('H$order', order: order)));

        expect(find.text('H$order'), findsOneWidget);
      }
    });

    test('rejects an order outside 1-6', () {
      expect(() => PlinthTitle('T', order: 0), throwsAssertionError);
      expect(() => PlinthTitle('T', order: 7), throwsAssertionError);
    });
  });
}
