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

    testWidgets('writes value to the clipboard and shows a checkmark',
        (tester) async {
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
        calls.any((c) =>
            c.method == 'Clipboard.setData' && c.arguments['text'] == 'hello'),
        isTrue,
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.copy_outlined), findsNothing);
    });

    testWidgets('reverts to the copy icon after confirmDuration',
        (tester) async {
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

      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}
