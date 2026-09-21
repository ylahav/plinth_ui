// The page header and the sticky-header layout.
//
// The one that matters is the same one the heroes had: every header
// these were extracted from rendered its title as big text rather than
// as a heading, so a page's own name was absent from the document
// outline a screen reader navigates by.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 700, double? height}) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    );

void main() {
  group('PlinthPageHeader', () {
    testWidgets('the title is a heading, not big text', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthPageHeader(title: 'Settings'),
      ));

      expect(
        tester.widget<PlinthTitle>(find.byType(PlinthTitle)).order,
        equals(2),
      );
    });

    testWidgets('titleOrder moves it for a nested header', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthPageHeader(title: 'Members', titleOrder: 4),
      ));

      expect(
        tester.widget<PlinthTitle>(find.byType(PlinthTitle)).order,
        equals(4),
      );
    });

    testWidgets('breadcrumbs, subtitle, actions and below all render',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthPageHeader(
          breadcrumbs: PlinthBreadcrumbs(
            items: [
              PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
              const PlinthBreadcrumbItem(label: 'Plinth UI'),
            ],
          ),
          title: 'Plinth UI',
          subtitle: 'A design-token engine for Flutter',
          actions: [
            PlinthButton(onPressed: () {}, child: const Text('New release')),
          ],
          below: const Text('tabs go here'),
        ),
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('A design-token engine for Flutter'), findsOneWidget);
      expect(find.text('New release'), findsOneWidget);
      expect(find.text('tabs go here'), findsOneWidget);
    });

    testWidgets('a count beside the title reads as one fact', (tester) async {
      // "Issues, 128" is one thing about the page, not a heading and an
      // unrelated number that happen to be adjacent.
      await tester.pumpWidget(_wrap(
        const PlinthPageHeader(
          title: 'Issues',
          titleTrailing: PlinthBadge('128', color: 'gray'),
        ),
      ));

      expect(find.byType(MergeSemantics), findsWidgets);
      expect(find.text('Issues'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
    });

    testWidgets('centred puts the title in the middle', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthPageHeader(
          centered: true,
          title: 'Settings',
          subtitle: 'Manage your account preferences',
        ),
      ));

      final title = tester.getCenter(find.text('Settings'));
      expect(title.dx, closeTo(400, 40));
    });

    testWidgets('a long title does not overflow beside its actions',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthPageHeader(
          title: 'A release name long enough to need the whole row and more',
          actions: [
            PlinthButton(onPressed: () {}, child: const Text('Share')),
          ],
        ),
        width: 360,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Share'), findsOneWidget);
    });
  });

  group('PlinthStickyHeader', () {
    testWidgets('the header stays while the body scrolls', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthStickyHeader(
          height: 220,
          header: const PlinthPageHeader(title: 'Members', titleOrder: 4),
          child: ListView(
            children: [
              for (var i = 0; i < 30; i++)
                SizedBox(height: 40, child: Text('row $i')),
            ],
          ),
        ),
        height: 260,
      ));

      final headerBefore = tester.getCenter(find.text('Members'));
      expect(find.text('row 0'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // The list moved; the header did not.
      expect(find.text('row 0'), findsNothing);
      expect(tester.getCenter(find.text('Members')), equals(headerBefore));
    });

    testWidgets('a plain ListView works without a CustomScrollView',
        (tester) async {
      // The body gets a bounded height, which is the reason this is a
      // Column and not a sliver arrangement.
      await tester.pumpWidget(_wrap(
        PlinthStickyHeader(
          height: 200,
          header: const Text('head'),
          child: ListView(children: const [Text('body')]),
        ),
        height: 240,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('body'), findsOneWidget);
    });
  });
}
