import 'dart:ui' show Tristate;

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
  group('PlinthCloseButton', () {
    testWidgets('renders a close glyph and fires on tap', (tester) async {
      var closed = 0;
      await tester.pumpWidget(
        _wrap(PlinthCloseButton(onPressed: () => closed++)),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byType(PlinthCloseButton));

      expect(closed, 1);
    });

    testWidgets('announces itself as a button with a label', (tester) async {
      await tester.pumpWidget(_wrap(PlinthCloseButton(onPressed: () {})));

      // The reason this component exists: PlinthAlert and
      // PlinthNotification previously used a bare Icon in an InkWell,
      // which a screen reader announced as nothing at all.
      final semantics = tester.getSemantics(find.byType(PlinthCloseButton));
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(semantics.label, 'Close');
    });

    testWidgets('takes a custom semantic label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthCloseButton(onPressed: () {}, semanticLabel: 'Dismiss banner'),
        ),
      );

      expect(
        tester.getSemantics(find.byType(PlinthCloseButton)).label,
        'Dismiss banner',
      );
    });

    testWidgets('a null callback disables it', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCloseButton(onPressed: null)),
      );

      await tester.tap(find.byType(PlinthCloseButton));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        tester
            .getSemantics(find.byType(PlinthCloseButton))
            .flagsCollection
            .isEnabled,
        Tristate.isFalse,
      );
    });

    testWidgets('size drives the glyph extent', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthCloseButton(onPressed: () {}, size: PlinthSize.xs)),
      );
      final small = tester.widget<Icon>(find.byIcon(Icons.close)).size!;

      await tester.pumpWidget(
        _wrap(PlinthCloseButton(onPressed: () {}, size: PlinthSize.xl)),
      );
      final large = tester.widget<Icon>(find.byIcon(Icons.close)).size!;

      expect(large, greaterThan(small));
    });

    testWidgets('the dismissible components use it', (tester) async {
      // Guards the extraction: these four each hand-rolled a close
      // affordance before, and had drifted apart in the process.
      await tester.pumpWidget(
        _wrap(PlinthAlert(onClose: () {}, child: const Text('Body'))),
      );
      expect(find.byType(PlinthCloseButton), findsOneWidget);

      await tester.pumpWidget(
        _wrap(PlinthNotification(onClose: () {}, child: const Text('Body'))),
      );
      expect(find.byType(PlinthCloseButton), findsOneWidget);
    });
  });

  group('PlinthCollapse', () {
    testWidgets('shows its child when opened', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCollapse(opened: true, child: Text('Panel'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Panel'), findsOneWidget);
      expect(tester.getSize(find.text('Panel')).height, greaterThan(0));
    });

    testWidgets('collapses to zero height while keeping the child mounted',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCollapse(opened: false, child: Text('Panel'))),
      );
      await tester.pumpAndSettle();

      // Still in the tree — that's the point of this over a swap — but
      // taking no vertical space.
      expect(find.text('Panel'), findsOneWidget);
      expect(
        tester.getSize(find.byType(PlinthCollapse)).height,
        0,
      );
    });

    testWidgets('hides collapsed content from assistive technology',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCollapse(opened: false, child: Text('Panel'))),
      );
      await tester.pumpAndSettle();

      // A clipped child is still in the tree, so without excluding it a
      // screen reader would read a panel the user cannot see.
      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel('Panel'),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('exposes content again once opened', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCollapse(opened: true, child: Text('Panel'))),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Panel'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('animates between the two states', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthCollapse(opened: false, child: SizedBox(height: 80))),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _wrap(const PlinthCollapse(opened: true, child: SizedBox(height: 80))),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final midway = tester.getSize(find.byType(PlinthCollapse)).height;

      await tester.pumpAndSettle();
      final settled = tester.getSize(find.byType(PlinthCollapse)).height;

      expect(midway, greaterThan(0));
      expect(midway, lessThan(settled));
      expect(settled, 80);
    });

    testWidgets('a Column child does not overflow while collapsed',
        (tester) async {
      // The trap PlinthSpoiler hit: a height-constrained box makes a
      // Flex child report an overflow rather than being clipped.
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 200,
            child: PlinthCollapse(
              opened: false,
              child: Column(
                children: [SizedBox(height: 60), SizedBox(height: 60)],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthHighlight', () {
    /// The runs a Text.rich ends up with, flattened for assertion.
    List<String> spanTexts(WidgetTester tester) {
      final text = tester.widget<Text>(find.byType(Text));
      final span = text.textSpan! as TextSpan;
      return [
        for (final child in span.children!) (child as TextSpan).text!,
      ];
    }

    testWidgets('renders the full text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthHighlight('The quick brown fox', highlight: ['quick']),
        ),
      );

      expect(spanTexts(tester).join(), 'The quick brown fox');
    });

    testWidgets('splits around the match', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthHighlight('The quick brown fox', highlight: ['quick']),
        ),
      );

      expect(spanTexts(tester), ['The ', 'quick', ' brown fox']);
    });

    testWidgets('matches case-insensitively but keeps the original casing',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthHighlight('The Quick fox', highlight: ['quick'])),
      );

      // The rendered text must read as written — highlighting is not
      // licence to rewrite what the user sees.
      expect(spanTexts(tester), ['The ', 'Quick', ' fox']);
    });

    testWidgets('marks every occurrence', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthHighlight('one two one', highlight: ['one'])),
      );

      expect(spanTexts(tester), ['one', ' two ', 'one']);
    });

    testWidgets('handles multiple terms', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthHighlight('red and blue', highlight: ['red', 'blue']),
        ),
      );

      expect(spanTexts(tester), ['red', ' and ', 'blue']);
    });

    testWidgets('prefers the longest of two overlapping terms', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthHighlight('foobar', highlight: ['foo', 'foobar']),
        ),
      );

      // Matching the shorter term first would leave 'bar' unhighlighted
      // even though a longer supplied term covers it.
      expect(spanTexts(tester), ['foobar']);
    });

    testWidgets('treats terms literally rather than as patterns',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthHighlight('a.b acb', highlight: ['a.b'])),
      );

      // Unescaped, '.' would match any character and highlight 'acb'
      // too — a query typed into a search box must not act as a regex.
      expect(spanTexts(tester), ['a.b', ' acb']);
    });

    testWidgets('ignores blank terms', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthHighlight('hello world', highlight: ['', '  '])),
      );

      // A raw query.split(' ') can produce these; highlighting on them
      // would mark the entire string.
      expect(spanTexts(tester), ['hello world']);
    });

    testWidgets('renders unmatched text when nothing matches', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthHighlight('hello', highlight: ['zzz'])),
      );

      expect(spanTexts(tester), ['hello']);
    });

    testWidgets('paints a background only on the matches', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthHighlight('a b', highlight: ['b'])),
      );

      final span = tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
      final children = span.children!.cast<TextSpan>();
      expect(children[0].style!.backgroundColor, isNull);
      expect(children[1].style!.backgroundColor, isNotNull);
    });
  });
}
