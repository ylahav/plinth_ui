import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PlinthSkeleton', () {
    testWidgets('renders at the given width and height', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSkeleton(width: 200, height: 16)),
      );

      final size = tester.getSize(find.byType(PlinthSkeleton));
      expect(size.width, equals(200));
      expect(size.height, equals(16));
    });

    testWidgets('circle mode does not throw', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSkeleton(width: 40, height: 40, circle: true)),
      );

      expect(find.byType(PlinthSkeleton), findsOneWidget);
    });

    testWidgets('pulses without throwing across several animation frames', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSkeleton(width: 100, height: 16)),
      );

      // Advance well past one full pulse cycle (800ms each way) to
      // exercise the self-triggering onEnd/setState loop at least
      // once, guarding against it firing forever or throwing after
      // the first flip.
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.byType(PlinthSkeleton), findsOneWidget);
    });
  });
}
