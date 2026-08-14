import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// Wraps [child] in a minimal MaterialApp with PlinthTheme registered,
/// mirroring how a real app would set things up. Every widget test in
/// this package should use this rather than a bare `pumpWidget` — a
/// PlinthButton (or any Plinth widget) rendered without a registered
/// PlinthTheme silently falls back to PlinthTheme.defaultTheme via
/// `context.plinth`, which would hide a real "I forgot to register
/// the theme" bug in an app.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: Center(child: child)),
  );
}

/// The ambient text style a component's label ends up with.
TextStyle _labelStyle(WidgetTester tester, String text) =>
    DefaultTextStyle.of(tester.element(find.text(text))).style;

void main() {
  group('ambient text style', () {
    /// `DefaultTextStyle(style: ...)` replaces the ambient style
    /// outright, dropping anything it doesn't restate — `fontFamily`
    /// above all. In an app with brand typography that means the label
    /// silently falls back to the platform font while everything
    /// around it doesn't. `.merge` is the fix, and three components
    /// had the wrong one.
    // The family goes on the theme rather than a DefaultTextStyle
    // wrapper: Material re-applies the theme's own text style beneath
    // any wrapper, so a wrapper alone can't tell a replace from a
    // merge.
    Widget branded(Widget child) => MaterialApp(
          theme: ThemeData(
            fontFamily: 'Brand',
            extensions: [PlinthTheme.defaultTheme],
          ),
          home: Scaffold(body: child),
        );

    testWidgets('PlinthButton keeps it', (tester) async {
      await tester.pumpWidget(
        branded(PlinthButton(onPressed: () {}, child: const Text('Save'))),
      );

      expect(_labelStyle(tester, 'Save').fontFamily, 'Brand');
      // The button's own choices still win over the ambient ones.
      expect(_labelStyle(tester, 'Save').fontWeight, FontWeight.w600);
    });

    testWidgets('PlinthAlert keeps it', (tester) async {
      await tester.pumpWidget(
        branded(const PlinthAlert(child: Text('Heads up'))),
      );

      expect(_labelStyle(tester, 'Heads up').fontFamily, 'Brand');
    });

    testWidgets('PlinthNotification keeps it', (tester) async {
      await tester.pumpWidget(
        branded(const PlinthNotification(child: Text('Saved'))),
      );

      expect(_labelStyle(tester, 'Saved').fontFamily, 'Brand');
    });
  });

  group('PlinthButton', () {
    testWidgets('renders its child label', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthButton(onPressed: () {}, child: const Text('Save'))),
      );

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          PlinthButton(
            onPressed: () => tapped = true,
            child: const Text('Save'),
          ),
        ),
      );

      await tester.tap(find.byType(PlinthButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          PlinthButton(
            onPressed: null,
            child: const Text('Save'),
          ),
        ),
      );

      await tester.tap(find.byType(PlinthButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('renders every variant without throwing', (tester) async {
      // Not a visual assertion (see docs/TESTING.md for golden tests,
      // which do check appearance) — this just guards against a
      // variant hitting an unhandled switch case and crashing.
      for (final variant in PlinthVariant.values) {
        await tester.pumpWidget(
          _wrap(
            PlinthButton(
              variant: variant,
              onPressed: () {},
              child: Text(variant.name),
            ),
          ),
        );
        expect(find.text(variant.name), findsOneWidget);
      }
    });

    testWidgets('is marked as a button for accessibility', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthButton(onPressed: () {}, child: const Text('Save'))),
      );

      // tester.getSemantics(finder) resolves `finder`'s element to its
      // RenderObject, then walks UP the tree until it finds one that
      // owns a SemanticsNode. PlinthButton is a StatelessWidget, so
      // find.byType(PlinthButton) resolves to its outer SizedBox's
      // RenderObject — which doesn't own semantics itself — so that
      // walk lands on some ancestor outside PlinthButton entirely,
      // not the Semantics(button: true, ...) node PlinthButton sets
      // internally. (First attempt at this test used
      // find.byType(PlinthButton) directly and got a false negative
      // for exactly this reason — the button's own semantics were
      // fine, the query was looking in the wrong place.)
      //
      // Finding the actual Semantics widget descendant first gives
      // tester.getSemantics a render object that owns semantics
      // directly, no upward walk needed.
      final semanticsFinder = find.descendant(
        of: find.byType(PlinthButton),
        matching: find.byWidgetPredicate((widget) => widget is Semantics),
      );
      final semantics = tester.getSemantics(semanticsFinder.first);
      expect(semantics.flagsCollection.isButton, isTrue);
    });
  });
}
