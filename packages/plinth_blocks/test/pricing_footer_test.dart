// The pricing card and the footer.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 600}) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );

void main() {
  group('PlinthPricingCard', () {
    testWidgets('plan, price, period, features and action', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthPricingCard(
          plan: 'Pro',
          price: r'$24',
          period: '/ month',
          badge: const PlinthBadge('Popular', color: 'violet'),
          features: const ['Unlimited projects', 'Priority support'],
          action: PlinthButton(
            fullWidth: true,
            onPressed: () {},
            child: const Text('Start trial'),
          ),
        ),
      ));

      expect(find.text('Pro'), findsOneWidget);
      expect(find.text(r'$24'), findsOneWidget);
      expect(find.text('/ month'), findsOneWidget);
      expect(find.text('Unlimited projects'), findsOneWidget);
      expect(find.text('Start trial'), findsOneWidget);
    });

    testWidgets('the price is the heading, not the plan name', (tester) async {
      // The price is what gets compared across a row of these, and it
      // is how a reader tells three identical "Start trial" buttons
      // apart.
      await tester.pumpWidget(_wrap(
        const PlinthPricingCard(plan: 'Pro', price: r'$24'),
      ));

      expect(
        tester.widget<PlinthTitle>(find.byType(PlinthTitle)).data,
        equals(r'$24'),
      );
    });

    testWidgets('a non-numeric price is fine', (tester) async {
      // "Free" and "Let's talk" are prices too.
      await tester.pumpWidget(_wrap(
        const PlinthPricingCard(plan: 'Enterprise', price: "Let's talk"),
      ));

      expect(find.text("Let's talk"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the feature tick is hidden from assistive technology',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthPricingCard(
          plan: 'Pro',
          price: r'$24',
          features: ['Unlimited projects'],
        ),
      ));

      expect(find.byType(ExcludeSemantics), findsWidgets);
    });

    testWidgets('highlighted adds a border, not a size change', (tester) async {
      // A card that grows breaks the alignment of the row it sits in,
      // and the one being recommended is the one somebody needs to
      // read most easily.
      Size sizeOf(bool highlighted) => tester.getSize(
            find.byType(PlinthPricingCard),
          );

      await tester.pumpWidget(_wrap(
        const PlinthPricingCard(plan: 'Pro', price: r'$24'),
      ));
      final plain = sizeOf(false);

      await tester.pumpWidget(_wrap(
        const PlinthPricingCard(
          plan: 'Pro',
          price: r'$24',
          highlighted: true,
        ),
      ));
      final marked = sizeOf(true);

      expect(marked, equals(plain));
      expect(find.byType(DecoratedBox), findsWidgets);
    });
  });

  group('PlinthFooter', () {
    testWidgets('brand, copyright and links', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthFooter(
          brand: 'Acme',
          copyright: '© 2026',
          links: [
            PlinthAnchor('Privacy', size: PlinthSize.sm, onTap: () {}),
            PlinthAnchor('Terms', size: PlinthSize.sm, onTap: () {}),
          ],
        ),
      ));

      expect(find.text('Acme'), findsOneWidget);
      expect(find.text('© 2026'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });

    testWidgets('columns render above the bottom row', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthFooter(
          brand: 'Acme',
          columns: [
            PlinthFooterColumn(
              title: 'Product',
              links: [PlinthAnchor('Features', onTap: () {})],
            ),
            PlinthFooterColumn(
              title: 'Company',
              links: [PlinthAnchor('About', onTap: () {})],
            ),
          ],
        ),
      ));

      expect(find.text('PRODUCT'), findsNothing, reason: 'not upper-cased');
      expect(find.text('Product'), findsOneWidget);
      expect(
        tester.getCenter(find.text('Features')).dy,
        lessThan(tester.getCenter(find.text('Acme')).dy),
      );
    });

    testWidgets('dense is one line with no card', (tester) async {
      // The footer of a tool takes a row, not a screen.
      await tester.pumpWidget(_wrap(
        const PlinthFooter(dense: true, brand: 'Acme'),
      ));

      expect(find.byType(PlinthPaper), findsNothing);
      expect(find.text('Acme'), findsOneWidget);
    });

    testWidgets('a trailing slot takes a newsletter form', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthFooter(
          brand: 'Acme',
          trailing: SizedBox(
            width: 220,
            child: PlinthTextInput(
              placeholder: 'you@example.com',
              onChanged: (_) {},
            ),
          ),
        ),
      ));

      expect(find.byType(PlinthTextInput), findsOneWidget);
    });

    testWidgets('a long line and a form wrap rather than clipping',
        (tester) async {
      // Both halves of this were caught by the showcase's own tests:
      // the bottom row could not shrink, and then the identity row took
      // its intrinsic width and a sentence-length copyright pushed the
      // footer wider than the page under it.
      await tester.pumpWidget(_wrap(
        PlinthFooter(
          brand: 'Plinth UI',
          copyright: 'A themeable component library for Flutter.',
          links: [
            PlinthAnchor('Status', size: PlinthSize.xs, onTap: () {}),
            PlinthAnchor('Docs', size: PlinthSize.xs, onTap: () {}),
          ],
          trailing: SizedBox(
            width: 260,
            child: PlinthTextInput(
              placeholder: 'you@example.com',
              onChanged: (_) {},
            ),
          ),
        ),
        width: 360,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Docs'), findsOneWidget);
    });

    testWidgets('an empty footer does not crash', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthFooter()));
      expect(tester.takeException(), isNull);
    });
  });
}
