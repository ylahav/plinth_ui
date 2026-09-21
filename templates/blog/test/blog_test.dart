/// Tests that this app still works, not that Plinth does.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';
import 'package:plinth_template_blog/src/app.dart';
import 'package:plinth_template_blog/src/content.dart';
import 'package:plinth_template_blog/src/theme.dart';

Future<void> _pump(
  WidgetTester tester, {
  Size size = const Size(1400, 1200),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    BlogApp(light: blogThemeData(blogLight), dark: blogThemeData(blogDark)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the index lists every post', (tester) async {
    await _pump(tester);

    for (final post in posts) {
      expect(find.text(post.title), findsOneWidget, reason: post.slug);
    }
  });

  testWidgets('opening a post shows it, and back returns', (tester) async {
    await _pump(tester);
    await tester.tap(find.text(posts.first.title));
    await tester.pumpAndSettle();

    expect(find.text(posts.first.sections.first.heading), findsWidgets);
    expect(find.text('All posts'), findsOneWidget);

    await tester.tap(find.text('All posts'));
    await tester.pumpAndSettle();
    expect(find.text(posts.last.title), findsOneWidget);
  });

  testWidgets('every post opens without throwing', (tester) async {
    await _pump(tester);

    // Back to the index between each, because pumping the same app
    // again keeps the State it already had — it would still be showing
    // the previous article.
    for (final post in posts) {
      await tester.tap(find.text(post.title));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '${post.slug} threw');

      await tester.tap(find.text('All posts'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('the contents are derived from the headings', (tester) async {
    await _pump(tester);
    await tester.tap(find.text(posts.first.title));
    await tester.pumpAndSettle();

    // Every heading appears twice — once in the article, once in the
    // contents. If the TOC were a second hand-written list, a renamed
    // heading would leave one of the two behind and this would catch it.
    for (final section in posts.first.sections) {
      expect(
        find.text(section.heading),
        findsNWidgets(2),
        reason: section.heading,
      );
    }
  });

  testWidgets('the contents move above the article on a phone', (tester) async {
    await _pump(tester, size: const Size(420, 1400));
    await tester.tap(find.text(posts.first.title));
    await tester.pumpAndSettle();

    // Still present, and reachable without scrolling past the thing it
    // is the contents of.
    final toc = find.byType(PlinthTableOfContents);
    expect(toc, findsOneWidget);

    final article = find.text(posts.first.sections.first.body);
    expect(
      tester.getTopLeft(toc).dy,
      lessThan(tester.getTopLeft(article).dy),
    );
  });

  testWidgets('replies are announced as replies', (tester) async {
    await _pump(tester);
    await tester.tap(find.text(posts.first.title));
    await tester.pumpAndSettle();

    // Nesting is indentation, and indentation is not audible. The
    // thread says "reply" so a reader knows a comment answers the one
    // above rather than standing on its own.
    final handle = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel(RegExp('reply')),
      findsWidgets,
      reason: 'nested comments are silent about being nested',
    );
    handle.dispose();
  });

  test('every section in the content is declared in the theme', () {
    for (final post in posts) {
      expect(
        sectionRoles,
        contains(post.section),
        reason: '${post.slug} has an undeclared section',
      );
    }
  });

  test('the brand colour is the one the theme paints', () {
    expect(blogLight.colors['brand']![6], brandColor);
  });

  test('section tags clear the contrast floor on both surfaces', () {
    for (final theme in [blogLight, blogDark]) {
      for (final section in sectionRoles.keys) {
        final ratio = PlinthTheme.contrastRatio(
          theme.semanticText(section),
          theme.surface,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$section is ${ratio.toStringAsFixed(2)}:1',
        );
      }
    }
  });
}
