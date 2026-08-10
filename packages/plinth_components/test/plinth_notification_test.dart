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
  group('PlinthNotification', () {
    testWidgets('renders title and content inline', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthNotification(
            title: 'Saved',
            color: 'green',
            child: Text('Your changes have been saved.'),
          ),
        ),
      );

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Your changes have been saved.'), findsOneWidget);
    });

    testWidgets('onClose fires when the close icon is tapped', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        _wrap(
          PlinthNotification(
            title: 'Saved',
            onClose: () => closed = true,
            child: const Text('Done'),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('show() displays the notification as a SnackBar',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => PlinthNotification.show(
                context,
                title: 'Saved',
                color: 'green',
                child: const Text('Your changes have been saved.'),
              ),
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      // SnackBars animate in — pump partway rather than pumpAndSettle,
      // since the default 4-second duration means pumpAndSettle would
      // wait for it to also animate back out before returning.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Your changes have been saved.'), findsOneWidget);
    });
  });
}
