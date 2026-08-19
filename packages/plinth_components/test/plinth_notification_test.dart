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

    testWidgets('showOn() displays it from a captured messenger',
        (tester) async {
      late ScaffoldMessengerState messenger;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              messenger = ScaffoldMessenger.of(context);
              return const Text('Body');
            },
          ),
        ),
      );

      PlinthNotification.showOn(
        messenger,
        title: 'Imported',
        color: 'green',
        child: const Text('3 accounts added.'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Imported'), findsOneWidget);
      expect(find.text('3 accounts added.'), findsOneWidget);
    });

    testWidgets('showOn() still delivers after the widget is gone',
        (tester) async {
      // The whole reason this exists. Flutter's idiom captures the
      // messenger before an await so the message survives the widget;
      // show(context) cannot express that, and the `context.mounted`
      // guard it forces silently drops the message instead.
      late ScaffoldMessengerState messenger;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              messenger = ScaffoldMessenger.of(context);
              return const Text('Working');
            },
          ),
        ),
      );

      // The originating widget goes away, as it would if the user
      // navigated off the page while the import ran.
      await tester.pumpWidget(_wrap(const Text('Somewhere else')));
      expect(find.text('Working'), findsNothing);

      PlinthNotification.showOn(
        messenger,
        child: const Text('Import finished'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Import finished'), findsOneWidget);
    });

    testWidgets('show() and showOn() produce the same notification',
        (tester) async {
      // show() is showOn() plus a lookup, and this is what says so.
      Future<Finder> render(void Function(BuildContext) trigger) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => trigger(context),
                child: const Text('Trigger'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Trigger'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        return find.byType(PlinthNotification);
      }

      final viaContext = await render((context) => PlinthNotification.show(
            context,
            title: 'Saved',
            color: 'grape',
            child: const Text('Body'),
          ));
      final fromShow = tester.widget<PlinthNotification>(viaContext);

      final viaMessenger = await render(
        (context) => PlinthNotification.showOn(
          ScaffoldMessenger.of(context),
          title: 'Saved',
          color: 'grape',
          child: const Text('Body'),
        ),
      );
      final fromShowOn = tester.widget<PlinthNotification>(viaMessenger);

      expect(fromShowOn.title, fromShow.title);
      expect(fromShowOn.color, fromShow.color);
      expect(fromShowOn.radius, fromShow.radius);
      expect(fromShowOn.onClose, isNotNull);
    });

    testWidgets('showOn() wires up the close button', (tester) async {
      late ScaffoldMessengerState messenger;
      await tester.pumpWidget(
        _wrap(Builder(builder: (context) {
          messenger = ScaffoldMessenger.of(context);
          return const Text('Body');
        })),
      );

      PlinthNotification.showOn(messenger, child: const Text('Dismiss me'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Dismiss me'), findsOneWidget);

      await tester.tap(find.byType(PlinthCloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Dismiss me'), findsNothing);
    });
  });
}
