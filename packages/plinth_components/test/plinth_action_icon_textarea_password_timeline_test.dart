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
  group('PlinthActionIcon', () {
    testWidgets('renders its icon', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthActionIcon(icon: const Icon(Icons.delete), onPressed: () {}),
        ),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          PlinthActionIcon(icon: const Icon(Icons.delete), onPressed: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(PlinthActionIcon));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('every variant renders without throwing', (tester) async {
      for (final variant in PlinthVariant.values) {
        await tester.pumpWidget(
          _wrap(
            PlinthActionIcon(icon: const Icon(Icons.star), variant: variant, onPressed: () {}),
          ),
        );
        expect(find.byIcon(Icons.star), findsOneWidget);
      }
    });
  });

  group('PlinthTextarea', () {
    testWidgets('renders placeholder and accepts input', (tester) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(
          PlinthTextarea(
            label: 'Bio',
            placeholder: 'Tell us about yourself',
            onChanged: (v) => changed = v,
          ),
        ),
      );

      expect(find.text('Bio'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Hello world');
      expect(changed, equals('Hello world'));
    });
  });

  group('PlinthPasswordInput', () {
    testWidgets('obscures text by default and toggles visibility', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPasswordInput(label: 'Password', onChanged: (_) {})),
      );

      var field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('PlinthTimeline', () {
    testWidgets('renders every item title and description', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTimeline(
            items: [
              PlinthTimelineItem(
                title: 'Order placed',
                description: 'Jan 3, 10:24 AM',
                active: true,
              ),
              PlinthTimelineItem(title: 'Shipped', description: 'Pending'),
            ],
          ),
        ),
      );

      expect(find.text('Order placed'), findsOneWidget);
      expect(find.text('Jan 3, 10:24 AM'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders a single item without throwing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTimeline(items: [PlinthTimelineItem(title: 'Only item')]),
        ),
      );

      expect(find.text('Only item'), findsOneWidget);
    });
  });
}
