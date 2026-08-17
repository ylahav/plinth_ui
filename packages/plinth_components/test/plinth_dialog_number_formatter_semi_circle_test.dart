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
  group('PlinthDialog', () {
    late PlinthDisclosureController controller;

    setUp(() => controller = PlinthDisclosureController());
    tearDown(() => controller.dispose());

    testWidgets('renders nothing until opened', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthDialog(
            controller: controller,
            title: 'Subscribe',
            child: const Text('Get the newsletter'),
          ),
        ),
      );

      expect(find.text('Get the newsletter'), findsNothing);

      controller.open();
      await tester.pumpAndSettle();

      expect(find.text('Get the newsletter'), findsOneWidget);
      expect(find.text('Subscribe'), findsOneWidget);
    });

    testWidgets('opens already-open when mounted that way', (tester) async {
      controller.open();
      await tester.pumpWidget(
        _wrap(
          PlinthDialog(controller: controller, child: const Text('Already up')),
        ),
      );
      // Insertion is deferred to after the frame, so this needs a pump.
      await tester.pumpAndSettle();

      expect(find.text('Already up'), findsOneWidget);
    });

    testWidgets('the close button dismisses it', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthDialog(controller: controller, child: const Text('Body')),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PlinthCloseButton));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
      expect(controller.isOpen, isFalse);
    });

    testWidgets('withCloseButton: false leaves the dismissal to the caller', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PlinthDialog(
            controller: controller,
            withCloseButton: false,
            child: const Text('Body'),
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      expect(find.byType(PlinthCloseButton), findsNothing);
    });

    testWidgets('does not block what is behind it', (tester) async {
      var behindTaps = 0;
      await tester.pumpWidget(
        _wrap(
          // A Column rather than a Stack: PlinthDialog renders a
          // zero-size placeholder inline, and an unpositioned zero-size
          // child collapses a Stack to 0x0, leaving nothing to tap.
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => behindTaps++,
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
              ),
              PlinthDialog(
                controller: controller,
                position: PlinthDialogPosition.bottomRight,
                child: const Text('Corner'),
              ),
            ],
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      // The whole point of a dialog over a modal: no barrier, so the
      // app behind it stays usable.
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();

      expect(behindTaps, 1);
      expect(find.text('Corner'), findsOneWidget);
    });

    testWidgets('position moves the panel', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthDialog(
            controller: controller,
            position: PlinthDialogPosition.topLeft,
            child: const Text('Panel'),
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      final topLeft = tester.getRect(find.text('Panel'));
      final screen = tester.getSize(find.byType(MaterialApp));
      expect(topLeft.top, lessThan(screen.height / 2));
      expect(topLeft.left, lessThan(screen.width / 2));
    });

    testWidgets('removes its overlay entry when unmounted while open', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PlinthDialog(controller: controller, child: const Text('Body')),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      await tester.pumpWidget(_wrap(const SizedBox.shrink()));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthNumberFormatter', () {
    testWidgets('groups thousands', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthNumberFormatter(value: 1234567)),
      );

      expect(find.text('1,234,567'), findsOneWidget);
    });

    test('formats prefix, suffix, decimals, and sign', () {
      expect(
        const PlinthNumberFormatter(
          value: 1234567.5,
          prefix: r'$',
          decimalScale: 2,
        ).formatted,
        r'$1,234,567.50',
      );
      expect(
        const PlinthNumberFormatter(value: 42, suffix: ' km').formatted,
        '42 km',
      );
      // The sign leads the prefix, not the other way round.
      expect(
        const PlinthNumberFormatter(value: -1500, prefix: r'$').formatted,
        r'-$1,500',
      );
    });

    test('leading group can be 1-3 digits', () {
      expect(const PlinthNumberFormatter(value: 100).formatted, '100');
      expect(const PlinthNumberFormatter(value: 1000).formatted, '1,000');
      expect(const PlinthNumberFormatter(value: 10000).formatted, '10,000');
      expect(const PlinthNumberFormatter(value: 100000).formatted, '100,000');
    });

    test('separators are configurable', () {
      expect(
        const PlinthNumberFormatter(
          value: 1234.56,
          thousandSeparator: '.',
          decimalSeparator: ',',
          decimalScale: 2,
        ).formatted,
        '1.234,56',
      );
      expect(
        const PlinthNumberFormatter(value: 1234, thousandSeparator: '')
            .formatted,
        '1234',
      );
    });

    test('trimTrailingZeros drops padding from a fixed scale', () {
      expect(
        const PlinthNumberFormatter(
          value: 1.5,
          decimalScale: 3,
          trimTrailingZeros: true,
        ).formatted,
        '1.5',
      );
      expect(
        const PlinthNumberFormatter(
          value: 2,
          decimalScale: 2,
          trimTrailingZeros: true,
        ).formatted,
        '2',
      );
    });
  });

  group('PlinthSemiCircleProgress', () {
    testWidgets('renders a label over the arc', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthSemiCircleProgress(value: 0.72, label: Text('72%')),
        ),
      );

      expect(find.text('72%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is about half as tall as it is wide', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthSemiCircleProgress(value: 0.5, diameter: 160)),
      );

      final size = tester.getSize(find.byType(PlinthSemiCircleProgress));
      expect(size.width, 160);
      // Half the diameter plus half a stroke, so the arc isn't clipped.
      expect(size.height, lessThan(size.width * 0.7));
      expect(size.height, greaterThan(size.width * 0.4));
    });

    testWidgets('accepts the ends of the range', (tester) async {
      for (final value in [0.0, 1.0]) {
        await tester.pumpWidget(
          _wrap(PlinthSemiCircleProgress(value: value)),
        );
        expect(tester.takeException(), isNull);
      }
    });

    test('rejects a value outside 0..1', () {
      expect(
        () => PlinthSemiCircleProgress(value: 1.5),
        throwsAssertionError,
      );
    });

    testWidgets('a thickness past the radius is clamped', (tester) async {
      // Unclamped this paints the arc back over itself, the same guard
      // PlinthRingProgress needs.
      await tester.pumpWidget(
        _wrap(
          const PlinthSemiCircleProgress(
              value: 0.5, diameter: 40, thickness: 200),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
