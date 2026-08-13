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
  group('PlinthStack', () {
    testWidgets('lays children out vertically with a gap between them', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthStack(
            gap: PlinthSize.md,
            children: [
              SizedBox(height: 20, child: Text('one')),
              SizedBox(height: 20, child: Text('two')),
            ],
          ),
        ),
      );

      final first = tester.getRect(find.text('one'));
      final second = tester.getRect(find.text('two'));
      expect(second.top, greaterThan(first.bottom));

      final expected = PlinthTheme.defaultTheme.spacing[PlinthSize.md]!;
      expect(second.top - first.bottom, closeTo(expected, 0.01));
    });

    testWidgets('puts no gap before the first child or after the last', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthStack(
            mainAxisSize: MainAxisSize.min,
            children: [SizedBox(height: 20), SizedBox(height: 20)],
          ),
        ),
      );

      final gap = PlinthTheme.defaultTheme.spacing[PlinthSize.md]!;
      expect(
          tester.getSize(find.byType(Column)).height, closeTo(40 + gap, 0.01));
    });

    testWidgets('stretches children across the cross axis by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 300,
            child: PlinthStack(children: [SizedBox(height: 10)]),
          ),
        ),
      );

      // The reason this defaults to stretch rather than start: a column
      // of form fields or buttons almost always wants full width.
      expect(tester.getSize(find.byType(SizedBox).last).width, 300);
    });
  });

  group('PlinthFieldset', () {
    testWidgets('renders its legend and child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthFieldset(
            legend: 'Shipping address',
            child: Text('Street'),
          ),
        ),
      );

      expect(find.text('Shipping address'), findsOneWidget);
      expect(find.text('Street'), findsOneWidget);
    });

    testWidgets('the legend labels the group rather than reading as a sibling',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthFieldset(legend: 'Billing', child: Text('Card number')),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PlinthFieldset));
      expect(semantics.label, contains('Billing'));
    });

    testWidgets('renders without a legend', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthFieldset(child: Text('Bare'))));

      expect(find.text('Bare'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled blocks interaction with everything inside', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthFieldset(
            legend: 'Payment',
            disabled: true,
            child: PlinthButton(
              onPressed: () => taps++,
              child: const Text('Pay'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pay'), warnIfMissed: false);
      await tester.pump();

      // A whole section switches off at once — no per-field wiring.
      expect(taps, 0);
    });

    testWidgets('enabled passes taps through', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthFieldset(
            legend: 'Payment',
            child: PlinthButton(
              onPressed: () => taps++,
              child: const Text('Pay'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pay'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('filled variant drops the border', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthFieldset(
            variant: PlinthVariant.filled,
            legend: 'Filled',
            child: Text('body'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PlinthFieldset),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border, isNull);
      expect(decoration.color, PlinthTheme.defaultTheme.surfaceMuted);
    });
  });

  group('PlinthEmptyState', () {
    testWidgets('renders title, description, icon, and action', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthEmptyState(
            icon: const Icon(Icons.inbox_outlined),
            title: 'No messages',
            description: 'Anything sent to your team lands here.',
            action: PlinthButton(
              onPressed: () {},
              child: const Text('Compose'),
            ),
          ),
        ),
      );

      expect(find.text('No messages'), findsOneWidget);
      expect(
          find.text('Anything sent to your team lands here.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('Compose'), findsOneWidget);
    });

    testWidgets('title alone is enough', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthEmptyState(title: 'Nothing here')),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the icon is hidden from assistive technology', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthEmptyState(
            icon: Icon(Icons.inbox_outlined, semanticLabel: 'inbox'),
            title: 'No messages',
          ),
        ),
      );

      // Decorative: the title already says what the icon illustrates,
      // so announcing both is noise.
      expect(find.bySemanticsLabel('inbox'), findsNothing);
    });

    testWidgets('the action stays tappable', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthEmptyState(
            title: 'No members',
            action: PlinthButton(
              onPressed: () => pressed++,
              child: const Text('Invite'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Invite'));
      await tester.pump();

      expect(pressed, 1);
    });
  });
}
