import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('PlinthCopyButton', () {
    testWidgets('shows the copy icon by default', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthCopyButton(value: 'hello')));

      expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('writes value to the clipboard and shows a checkmark', (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      await tester.pumpWidget(_wrap(const PlinthCopyButton(value: 'hello')));

      await tester.tap(find.byType(PlinthCopyButton));
      await tester.pump();

      expect(
        calls.any((c) => c.method == 'Clipboard.setData' && c.arguments['text'] == 'hello'),
        isTrue,
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.copy_outlined), findsNothing);
    });

    testWidgets('reverts to the copy icon after confirmDuration', (tester) async {
      // Mock the clipboard platform channel explicitly, same as the
      // previous test — without this, Clipboard.setData()'s await
      // depends on the default unmocked handler's timing, which
      // isn't guaranteed to resolve within a single pump() and was
      // producing inconsistent failures (sometimes the immediate
      // checkmark assertion below, sometimes the later revert
      // assertion, depending on run).
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      await tester.pumpWidget(
        _wrap(
          const PlinthCopyButton(
            value: 'hello',
            confirmDuration: Duration(milliseconds: 200),
          ),
        ),
      );

      await tester.tap(find.byType(PlinthCopyButton));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Elapse time in several smaller increments rather than one
      // large pump(duration) call. A single big elapse depends on
      // exactly how that call sequences "advance the clock" vs
      // "render a frame" internally, which isn't guaranteed
      // identical across Flutter SDK versions. Pumping in smaller
      // steps guarantees the Timer fires *between* two separate
      // frame builds — the next pump() after it fires is what
      // renders the reverted state, regardless of internal pump()
      // sequencing.
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}
