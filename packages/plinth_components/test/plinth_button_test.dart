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

  group('disabled', () {
    /// The fill the button actually paints, read off the `Material`
    /// that paints it.
    Color background(WidgetTester tester) => tester
        .widget<Material>(
          find.descendant(
            of: find.byType(PlinthButton),
            matching: find.byType(Material),
          ),
        )
        .color!;

    testWidgets('a null onPressed changes how the button looks',
        (tester) async {
      // Until 0.19.0 it changed only the semantics, so a disabled
      // button was indistinguishable from an enabled one to everyone
      // not using a screen reader — including the person wondering why
      // their tap does nothing.
      await tester.pumpWidget(
        _wrap(PlinthButton(onPressed: () {}, child: const Text('Save'))),
      );
      final enabled = background(tester);

      await tester.pumpWidget(
        _wrap(const PlinthButton(onPressed: null, child: Text('Save'))),
      );

      expect(background(tester), isNot(enabled));
      expect(background(tester), PlinthTheme.defaultTheme.surfaceMuted);
      expect(
        _labelStyle(tester, 'Save').color,
        PlinthTheme.defaultTheme.textDisabled,
      );
    });

    testWidgets('the variants that draw nothing keep drawing nothing',
        (tester) async {
      // A disabled `subtle` button with a grey plate behind it would be
      // more prominent than its enabled self.
      await tester.pumpWidget(
        _wrap(const PlinthButton(
          onPressed: null,
          variant: PlinthVariant.subtle,
          child: Text('Save'),
        )),
      );

      expect(background(tester), Colors.transparent);
      expect(
        _labelStyle(tester, 'Save').color,
        PlinthTheme.defaultTheme.textDisabled,
      );
    });
  });

  group('loading', () {
    testWidgets('shows a spinner and ignores taps', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _wrap(PlinthButton(
          loading: true,
          onPressed: () => presses++,
          child: const Text('Save'),
        )),
      );

      expect(find.byType(PlinthLoader), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pump();

      // A slow request must not be submittable twice.
      expect(presses, 0);
    });

    testWidgets('keeps its own colors rather than the disabled ones',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthButton(
          loading: true,
          onPressed: () {},
          child: const Text('Save'),
        )),
      );

      // Busy is not unavailable: greying the button out would say the
      // press didn't land.
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(PlinthButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, isNot(PlinthTheme.defaultTheme.surfaceMuted));
    });

    testWidgets('takes the place of the leading icon, not the label',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthButton(
          loading: true,
          leadingIcon: const Icon(Icons.save),
          onPressed: () {},
          child: const Text('Save'),
        )),
      );

      expect(find.byIcon(Icons.save), findsNothing);
      expect(find.text('Save'), findsOneWidget);
    });
  });

  group('PlinthActionIcon', () {
    testWidgets('a null onPressed changes how it looks', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthActionIcon(icon: Icon(Icons.add), onPressed: null)),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(PlinthActionIcon),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, PlinthTheme.defaultTheme.surfaceMuted);
    });

    testWidgets('loading replaces the icon and ignores taps', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _wrap(PlinthActionIcon(
          icon: const Icon(Icons.refresh),
          loading: true,
          onPressed: () => presses++,
        )),
      );

      expect(find.byIcon(Icons.refresh), findsNothing);
      expect(find.byType(PlinthLoader), findsOneWidget);

      await tester.tap(find.byType(PlinthActionIcon));
      await tester.pump();
      expect(presses, 0);
    });
  });
}
