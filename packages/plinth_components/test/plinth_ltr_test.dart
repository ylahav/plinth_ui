import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// An RTL page, established with `Directionality` rather than a Hebrew
/// locale so the test does not need `flutter_localizations` — what is
/// under test is the direction, not the translation.
Widget _rtl(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(
      body: Directionality(textDirection: TextDirection.rtl, child: child),
    ),
  );
}

void main() {
  group('PlinthLtr', () {
    testWidgets('pins direction to LTR inside an RTL page', (tester) async {
      late TextDirection outside;
      late TextDirection inside;

      await tester.pumpWidget(
        _rtl(
          Builder(
            builder: (context) {
              outside = Directionality.of(context);
              return PlinthLtr(
                child: Builder(builder: (inner) {
                  inside = Directionality.of(inner);
                  return const SizedBox();
                }),
              );
            },
          ),
        ),
      );

      expect(outside, TextDirection.rtl, reason: 'the page is RTL');
      expect(inside, TextDirection.ltr);
    });

    testWidgets('leaves an already-LTR page alone', (tester) async {
      late TextDirection inside;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
          home: Scaffold(
            body: PlinthLtr(
              child: Builder(builder: (context) {
                inside = Directionality.of(context);
                return const SizedBox();
              }),
            ),
          ),
        ),
      );
      expect(inside, TextDirection.ltr);
    });

    testWidgets('the pin does not leak back out', (tester) async {
      // A sibling of the wrapper still follows the page.
      late TextDirection sibling;
      await tester.pumpWidget(
        _rtl(
          Column(
            children: [
              const PlinthLtr(child: SizedBox()),
              Builder(builder: (context) {
                sibling = Directionality.of(context);
                return const SizedBox();
              }),
            ],
          ),
        ),
      );
      expect(sibling, TextDirection.rtl);
    });

    testWidgets('a row of content lays out left-to-right inside it',
        (tester) async {
      // The reason this exists is layout, not just the inherited value:
      // an axis or a bar chart must not plot backwards.
      await tester.pumpWidget(
        _rtl(
          PlinthLtr(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 10, height: 10, key: Key('first')),
                const SizedBox(width: 10, height: 10, key: Key('second')),
              ],
            ),
          ),
        ),
      );

      final first = tester.getTopLeft(find.byKey(const Key('first')));
      final second = tester.getTopLeft(find.byKey(const Key('second')));
      expect(first.dx, lessThan(second.dx));
    });

    testWidgets('the same row reverses without it', (tester) async {
      // The control case. Without this the test above would pass even if
      // PlinthLtr did nothing.
      await tester.pumpWidget(
        _rtl(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 10, height: 10, key: Key('first')),
              const SizedBox(width: 10, height: 10, key: Key('second')),
            ],
          ),
        ),
      );

      final first = tester.getTopLeft(find.byKey(const Key('first')));
      final second = tester.getTopLeft(find.byKey(const Key('second')));
      expect(first.dx, greaterThan(second.dx));
    });

    testWidgets('a formatted figure renders inside it', (tester) async {
      await tester.pumpWidget(
        _rtl(
          const PlinthLtr(
            child: PlinthNumberFormatter(
              value: 1234567.5,
              prefix: r'$',
              decimalScale: 2,
            ),
          ),
        ),
      );
      expect(find.text(r'$1,234,567.50'), findsOneWidget);
    });
  });
}
