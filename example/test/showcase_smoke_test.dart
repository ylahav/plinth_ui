import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:plinth_example/src/showcase/showcase_data.dart';

/// Builds every showcase block and asserts it doesn't throw.
///
/// The Widgetbook gallery has an equivalent test, but it walks the
/// component tree — these composed blocks live in the example app and
/// were covered by nothing. They're the more likely place for a render
/// failure, since a block is an arrangement of a dozen components under
/// real layout constraints rather than one widget on its own.
///
/// Asserts the absence of exceptions, nothing about appearance.
void main() {
  final entries = [
    for (final category in showcaseCategories)
      for (final subcategory in category.subcategories)
        for (final example in subcategory.examples)
          (
            path: '${category.title} / ${subcategory.title} / ${example.title}',
            example: example,
          ),
  ];

  test('the showcase exposes blocks to smoke test', () {
    // Guards against the walk finding nothing and the suite passing
    // with zero assertions.
    expect(entries, isNotEmpty);
  });

  for (final entry in entries) {
    testWidgets('${entry.path} builds', (tester) async {
      // Blocks are laid out for a page, not a phone — several are 560
      // wide and would overflow the default 800x600 viewport once
      // padding is counted. Widening the view is the right fix rather
      // than wrapping in a horizontal scroller: that would hand them
      // *unbounded* width, which breaks every Row with an Expanded or
      // Spacer in it.
      tester.view.physicalSize = const Size(1400, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
          home: Scaffold(
            body: SingleChildScrollView(
              // A Builder, not tester.element: the entry's builder
              // needs a context from inside this tree, which doesn't
              // exist yet while the tree is being constructed.
              child: Builder(builder: entry.example.builder),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }

  test('every block has a code snippet for its "Show code" panel', () {
    // The snippets are hand-maintained literals keyed by class name, so
    // a new block is easy to register without one — which renders an
    // empty panel rather than failing.
    for (final entry in entries) {
      expect(
        entry.example.code.trim(),
        isNotEmpty,
        reason: 'missing snippet: ${entry.path}',
      );
    }
  });
}
