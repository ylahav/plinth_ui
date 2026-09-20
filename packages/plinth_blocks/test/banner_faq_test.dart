// The banner and FAQ blocks.
//
// Both collapsed four showcase arrangements into one widget, so most of
// what is pinned here is that the arrangements are still distinguishable
// — a bar is not a notice, a consent prompt is not dismissible, and a
// two-column FAQ is not an accordion with the chevrons hidden.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 700}) => MaterialApp(
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

const _faqs = [
  PlinthFaqItem(
    question: 'When am I billed?',
    answer: 'On the same day each month.',
  ),
  PlinthFaqItem(
    question: 'Can I cancel?',
    answer: 'Yes, and the plan runs to the end of the period.',
  ),
  PlinthFaqItem(
    question: 'Is there a free tier?',
    answer: 'Everything here is MIT licensed.',
  ),
];

void main() {
  group('PlinthBannerBlock', () {
    testWidgets('the notice layout is an alert', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthBannerBlock(
          title: 'Version 1.3.0 is available',
          message: 'Adds four components.',
        ),
      ));

      expect(find.byType(PlinthAlert), findsOneWidget);
      expect(find.text('Version 1.3.0 is available'), findsOneWidget);
    });

    testWidgets('the bar layout is not', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthBannerBlock(
          layout: PlinthBannerLayout.bar,
          message: 'We use one cookie to remember your theme.',
        ),
      ));

      expect(find.byType(PlinthAlert), findsNothing);
      expect(
        find.text('We use one cookie to remember your theme.'),
        findsOneWidget,
      );
    });

    testWidgets('no onClose means no close button', (tester) async {
      // The consent case. A prompt somebody can wave away has not
      // obtained consent.
      await tester.pumpWidget(_wrap(
        const PlinthBannerBlock(
          layout: PlinthBannerLayout.bar,
          message: 'Choose one.',
        ),
      ));

      expect(find.byType(PlinthCloseButton), findsNothing);
    });

    testWidgets('onClose renders a dismissal that fires', (tester) async {
      // The promo case, which is the opposite: one that cannot be
      // dismissed is a tax on everyone who has already read it.
      var closed = 0;

      await tester.pumpWidget(_wrap(
        PlinthBannerBlock(
          layout: PlinthBannerLayout.bar,
          message: 'Annual plans are 20% off.',
          onClose: () => closed++,
        ),
      ));

      await tester.tap(find.byType(PlinthCloseButton));
      await tester.pump();

      expect(closed, equals(1));
    });

    testWidgets('actions render in both layouts', (tester) async {
      for (final layout in PlinthBannerLayout.values) {
        await tester.pumpWidget(_wrap(
          PlinthBannerBlock(
            layout: layout,
            message: 'Something happened.',
            actions: [
              PlinthButton(onPressed: () {}, child: const Text('Act')),
            ],
          ),
        ));

        expect(find.text('Act'), findsOneWidget, reason: layout.name);
      }
    });

    testWidgets('a leading widget shows in the bar', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthBannerBlock(
          layout: PlinthBannerLayout.bar,
          leading: PlinthBadge('Offer', color: 'grape'),
          message: 'Annual plans are 20% off.',
        ),
      ));

      expect(find.text('OFFER'), findsOneWidget);
    });

    testWidgets('elevated and tinted bars both build', (tester) async {
      for (final elevated in [true, false]) {
        await tester.pumpWidget(_wrap(
          PlinthBannerBlock(
            layout: PlinthBannerLayout.bar,
            elevated: elevated,
            message: 'A message.',
          ),
        ));

        expect(tester.takeException(), isNull, reason: 'elevated: $elevated');
      }
    });
  });

  group('PlinthFaqBlock', () {
    testWidgets('the accordion hides answers until asked', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthFaqBlock(items: _faqs, title: 'FAQ'),
      ));

      expect(find.text('When am I billed?'), findsOneWidget);
      expect(find.text('On the same day each month.'), findsNothing);

      await tester.tap(find.text('When am I billed?'));
      await tester.pumpAndSettle();

      expect(find.text('On the same day each month.'), findsOneWidget);
    });

    testWidgets('two columns show every answer at once', (tester) async {
      // Which is the reason to choose it: a collapsed answer is not
      // text on the page, so find-in-page cannot reach it.
      await tester.pumpWidget(_wrap(
        const PlinthFaqBlock(
          items: _faqs,
          layout: PlinthFaqLayout.twoColumn,
        ),
      ));

      expect(find.text('On the same day each month.'), findsOneWidget);
      expect(find.byType(PlinthAccordion), findsNothing);
    });

    testWidgets('search filters on the answer, not only the question',
        (tester) async {
      // People search for the word they remember, and it is usually in
      // the answer.
      await tester.pumpWidget(_wrap(
        const PlinthFaqBlock(
          items: _faqs,
          searchable: true,
          layout: PlinthFaqLayout.twoColumn,
        ),
      ));

      await tester.enterText(find.byType(PlinthTextInput), 'MIT');
      await tester.pumpAndSettle();

      expect(find.text('Is there a free tier?'), findsOneWidget);
      expect(find.text('When am I billed?'), findsNothing);
    });

    testWidgets('a search matching nothing says so', (tester) async {
      // An empty list with no explanation reads as a broken filter.
      await tester.pumpWidget(_wrap(
        const PlinthFaqBlock(items: _faqs, searchable: true),
      ));

      await tester.enterText(find.byType(PlinthTextInput), 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('No questions match that.'), findsOneWidget);
    });

    testWidgets('no search box unless asked for one', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthFaqBlock(items: _faqs),
      ));

      expect(find.byType(PlinthTextInput), findsNothing);
    });

    testWidgets('the footer renders under the questions', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthFaqBlock(
          items: _faqs,
          footer: PlinthButton(onPressed: () {}, child: const Text('Ask us')),
        ),
      ));

      expect(find.text('Ask us'), findsOneWidget);
    });

    testWidgets('an item value defaults to its question', (tester) async {
      const item = PlinthFaqItem(question: 'Why?', answer: 'Because.');
      expect(item.value, equals('Why?'));

      const explicit =
          PlinthFaqItem(question: 'Why?', answer: 'Because.', value: 'why-2');
      expect(explicit.value, equals('why-2'));
    });

    testWidgets('an empty list does not crash', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthFaqBlock(items: [])));
      expect(tester.takeException(), isNull);
    });
  });
}
