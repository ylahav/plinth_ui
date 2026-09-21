// The article card and the comment thread.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 460}) => MaterialApp(
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
  group('PlinthArticleCard', () {
    testWidgets('the headline is a heading', (tester) async {
      // A feed is a list of documents, and a reader skims it by
      // heading. Bold text is one long undifferentiated run.
      await tester.pumpWidget(_wrap(
        const PlinthArticleCard(title: 'Building a design system'),
      ));

      expect(
        tester.widget<PlinthTitle>(find.byType(PlinthTitle)).order,
        equals(4),
      );
    });

    testWidgets('category, excerpt, author and meta all render',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthArticleCard(
          title: 'Building a design system',
          excerpt: 'What we learned shipping tokens to three apps.',
          category: PlinthBadge('Design', color: 'orange'),
          author: PlinthUserTile(initials: 'YL', name: 'Yair Lahav'),
          meta: '12 Aug · 6 min read',
        ),
      ));

      expect(find.text('DESIGN'), findsOneWidget);
      expect(find.text('Yair Lahav'), findsOneWidget);
      expect(find.text('12 Aug · 6 min read'), findsOneWidget);
    });

    testWidgets('the image is decorative', (tester) async {
      // The headline beside it already says what the article is.
      await tester.pumpWidget(_wrap(
        const PlinthArticleCard(
          title: 'Building a design system',
          image: ColoredBox(color: Color(0xFFEEEEEE)),
        ),
      ));

      expect(find.byType(ExcludeSemantics), findsWidgets);
    });

    testWidgets('every layout builds with and without an image',
        (tester) async {
      for (final layout in PlinthArticleLayout.values) {
        for (final withImage in [true, false]) {
          await tester.pumpWidget(_wrap(
            PlinthArticleCard(
              layout: layout,
              title: 'Building a design system',
              excerpt: 'A sentence.',
              image:
                  withImage ? const ColoredBox(color: Color(0xFFEEEEEE)) : null,
            ),
          ));
          expect(
            tester.takeException(),
            isNull,
            reason: '${layout.name}, image: $withImage',
          );
        }
      }
    });

    testWidgets('horizontal puts the image beside the words', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthArticleCard(
          layout: PlinthArticleLayout.horizontal,
          title: 'Building a design system',
          image: ColoredBox(color: Color(0xFFEEEEEE)),
        ),
      ));

      expect(
        tester.getCenter(find.byType(ColoredBox).first).dx,
        lessThan(tester.getCenter(find.text('Building a design system')).dx),
      );
    });

    testWidgets('onTap makes the whole card pressable', (tester) async {
      var opened = 0;

      await tester.pumpWidget(_wrap(
        PlinthArticleCard(
          title: 'Building a design system',
          onTap: () => opened++,
        ),
      ));

      await tester.tap(find.byType(PlinthUnstyledButton));
      await tester.pump();

      expect(opened, equals(1));
    });
  });

  group('PlinthCommentThread', () {
    const thread = [
      PlinthCommentData(
        initials: 'AB',
        author: 'Ada Byron',
        when: '2 hours ago',
        body: 'Does the shade mirroring apply to custom palettes?',
        replies: [
          PlinthCommentData(
            initials: 'YL',
            author: 'Yair Lahav',
            when: '1 hour ago',
            body: 'Any ramp registered on the theme.',
          ),
        ],
      ),
    ];

    testWidgets('comments and replies render', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthCommentThread(comments: thread),
      ));

      expect(find.text('Ada Byron'), findsOneWidget);
      expect(find.text('Yair Lahav'), findsOneWidget);
      expect(find.text('Any ramp registered on the theme.'), findsOneWidget);
    });

    testWidgets('a reply is indented', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthCommentThread(comments: thread),
      ));

      expect(
        tester.getTopLeft(find.text('Yair Lahav')).dx,
        greaterThan(tester.getTopLeft(find.text('Ada Byron')).dx),
      );
    });

    testWidgets('nesting stops rather than running off the page',
        (tester) async {
      // A reply four levels in is a reply to something nobody can
      // still see.
      const deep = PlinthCommentData(
        author: 'L0',
        body: 'a',
        replies: [
          PlinthCommentData(
            author: 'L1',
            body: 'b',
            replies: [
              PlinthCommentData(
                author: 'L2',
                body: 'c',
                replies: [
                  PlinthCommentData(
                    author: 'L3',
                    body: 'd',
                    replies: [PlinthCommentData(author: 'L4', body: 'e')],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(_wrap(
        const PlinthCommentThread(comments: [deep], maxDepth: 2),
      ));

      expect(tester.takeException(), isNull);
      final l2 = tester.getTopLeft(find.text('L2')).dx;
      final l4 = tester.getTopLeft(find.text('L4')).dx;
      expect(l4, equals(l2), reason: 'indenting did not stop at maxDepth');
    });

    testWidgets('an empty thread says so', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthCommentThread(comments: []),
      ));

      expect(find.text('No comments yet.'), findsOneWidget);
    });
  });
}
