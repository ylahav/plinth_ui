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
  group('PlinthButtonGroup', () {
    testWidgets('renders every child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthButtonGroup(
            children: [
              PlinthButton(onPressed: () {}, child: const Text('Day')),
              PlinthButton(onPressed: () {}, child: const Text('Week')),
              PlinthButton(onPressed: () {}, child: const Text('Month')),
            ],
          ),
        ),
      );

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
    });

    testWidgets('each child remains independently tappable', (tester) async {
      var tapped = '';
      await tester.pumpWidget(
        _wrap(
          PlinthButtonGroup(
            children: [
              PlinthButton(
                  onPressed: () => tapped = 'day', child: const Text('Day')),
              PlinthButton(
                  onPressed: () => tapped = 'week', child: const Text('Week')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Week'));
      await tester.pump();

      expect(tapped, equals('week'));
    });
  });

  group('PlinthOverlay', () {
    testWidgets('renders its child within a Stack ancestor', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Stack(
            children: [
              Container(width: 100, height: 100, color: Colors.blue),
              const PlinthOverlay(child: Text('Dimmed content')),
            ],
          ),
        ),
      );

      expect(find.text('Dimmed content'), findsOneWidget);
    });

    testWidgets('blockPointerEvents wraps content in AbsorbPointer',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          Stack(
            children: [
              Container(width: 100, height: 100),
              const PlinthOverlay(blockPointerEvents: true, child: SizedBox()),
            ],
          ),
        ),
      );

      // Scoped to PlinthOverlay's own subtree — MaterialApp/Scaffold's
      // chrome apparently already contains an AbsorbPointer of its
      // own elsewhere in the tree, making a bare find.byType(...)
      // ambiguous regardless of PlinthOverlay's own behavior.
      expect(
        find.descendant(
            of: find.byType(PlinthOverlay),
            matching: find.byType(AbsorbPointer)),
        findsOneWidget,
      );
    });

    testWidgets('does not wrap in AbsorbPointer by default', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Stack(
            children: [
              Container(width: 100, height: 100),
              const PlinthOverlay(child: SizedBox()),
            ],
          ),
        ),
      );

      expect(
        find.descendant(
            of: find.byType(PlinthOverlay),
            matching: find.byType(AbsorbPointer)),
        findsNothing,
      );
    });
  });

  group('PlinthVisuallyHidden', () {
    testWidgets('keeps child in the tree (findable) while visually collapsed',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthVisuallyHidden(child: Text('Close dialog')),
        ),
      );

      expect(find.text('Close dialog'), findsOneWidget);
    });
  });
}
