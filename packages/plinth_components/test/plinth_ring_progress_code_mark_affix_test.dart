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
  group('PlinthRingProgress', () {
    testWidgets('renders without throwing at various values', (tester) async {
      for (final v in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        await tester.pumpWidget(_wrap(PlinthRingProgress(value: v)));
        expect(find.byType(PlinthRingProgress), findsOneWidget);
      }
    });

    testWidgets('renders the label content when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthRingProgress(value: 0.5, label: Text('50%'))),
      );

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('respects the size parameter', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthRingProgress(value: 0.5, size: 120)));

      final size = tester.getSize(find.byType(PlinthRingProgress));
      expect(size.width, equals(120));
      expect(size.height, equals(120));
    });
  });

  group('PlinthCode', () {
    testWidgets('renders its text', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthCode('flutter pub get')));

      expect(find.text('flutter pub get'), findsOneWidget);
    });
  });

  group('PlinthMark', () {
    testWidgets('renders its text', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthMark('highlighted')));

      expect(find.text('highlighted'), findsOneWidget);
    });
  });

  group('PlinthAffix', () {
    testWidgets('renders its child inside a Stack', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Stack(
            children: [
              const Positioned.fill(child: SizedBox()),
              PlinthAffix(bottom: 20, right: 20, child: const Icon(Icons.arrow_upward)),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });
  });
}
