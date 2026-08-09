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
  group('PlinthSpoiler', () {
    testWidgets('shows the show-label by default', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSpoiler(child: Text('Long content'))),
      );

      expect(find.text('Show more'), findsOneWidget);
      expect(find.text('Show less'), findsNothing);
    });

    testWidgets('tapping the toggle switches to the hide-label', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSpoiler(child: Text('Long content'))),
      );

      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();

      expect(find.text('Show less'), findsOneWidget);
      expect(find.text('Show more'), findsNothing);
    });

    testWidgets('respects custom labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthSpoiler(
            showLabel: 'Read more',
            hideLabel: 'Collapse',
            child: Text('Long content'),
          ),
        ),
      );

      expect(find.text('Read more'), findsOneWidget);
    });
  });

  group('PlinthIndicator', () {
    testWidgets('renders the child and a label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthIndicator(
            label: '3',
            child: Icon(Icons.notifications_outlined),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides the indicator label when disabled, keeps the child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthIndicator(
            label: '3',
            disabled: true,
            child: Icon(Icons.notifications_outlined),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.text('3'), findsNothing);
    });

    testWidgets('every position renders without throwing', (tester) async {
      for (final position in PlinthIndicatorPosition.values) {
        await tester.pumpWidget(
          _wrap(
            PlinthIndicator(
              position: position,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        );
        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      }
    });
  });

  group('PlinthLoadingOverlay', () {
    testWidgets('shows a spinner when visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthLoadingOverlay(visible: true, child: Text('Form content')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides the spinner when not visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthLoadingOverlay(visible: false, child: Text('Form content')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Form content'), findsOneWidget);
    });

    testWidgets('child stays in the tree (not removed) while visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthLoadingOverlay(visible: true, child: Text('Form content')),
        ),
      );

      // Content underneath is dimmed/non-interactive, not gone —
      // confirms the IgnorePointer approach keeps layout stable.
      expect(find.text('Form content'), findsOneWidget);
    });
  });
}
