// The async button and the inline confirm.
//
// Both are behaviour rather than arrangement, so most of this is about
// what happens between presses.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('PlinthAsyncButton', () {
    testWidgets('it disables itself while the future is in flight',
        (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(_wrap(
        PlinthAsyncButton(
          onPressed: () => completer.future,
          child: const Text('Save'),
        ),
      ));

      PlinthButton button() =>
          tester.widget<PlinthButton>(find.byType(PlinthButton));

      expect(button().onPressed, isNotNull);

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(button().onPressed, isNull);
      expect(button().loading, isTrue);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a second press while busy cannot start a second run',
        (tester) async {
      // The bug every hand-rolled version has the first time somebody
      // double-clicks Save.
      var runs = 0;
      final completer = Completer<void>();

      await tester.pumpWidget(_wrap(
        PlinthAsyncButton(
          onPressed: () {
            runs++;
            return completer.future;
          },
          child: const Text('Save'),
        ),
      ));

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.tap(find.text('Save'), warnIfMissed: false);
      await tester.pump();

      expect(runs, equals(1));

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('it returns to rest after the done state', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthAsyncButton(
          onPressed: () async {},
          doneChild: const Text('Saved'),
          resetAfter: const Duration(milliseconds: 100),
          child: const Text('Save'),
        ),
      ));

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Saved'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('a failure is delivered, not swallowed', (tester) async {
      // The button never holds the result, so a caller cannot catch
      // around it. Without a handler the error would go to the zone,
      // which is a long way from the button somebody just pressed.
      Object? caught;

      await tester.pumpWidget(_wrap(
        PlinthAsyncButton(
          onPressed: () async => throw StateError('nope'),
          onError: (error, _) => caught = error,
          child: const Text('Save'),
        ),
      ));

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();

      expect(caught, isA<StateError>());
      expect(
        tester.widget<PlinthButton>(find.byType(PlinthButton)).onPressed,
        isNotNull,
        reason: 'the button stayed dead after a failure',
      );
    });

    testWidgets('a null onPressed disables it', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthAsyncButton(child: Text('Save')),
      ));

      expect(
        tester.widget<PlinthButton>(find.byType(PlinthButton)).onPressed,
        isNull,
      );
    });
  });

  group('PlinthConfirmButton', () {
    testWidgets('it asks before it acts', (tester) async {
      var deleted = 0;

      await tester.pumpWidget(_wrap(
        PlinthConfirmButton(
          label: 'Delete project',
          question: 'Delete permanently?',
          confirmLabel: 'Delete',
          onConfirm: () => deleted++,
        ),
      ));

      await tester.tap(find.text('Delete project'));
      await tester.pump();

      expect(find.text('Delete permanently?'), findsOneWidget);
      expect(deleted, isZero);

      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(deleted, equals(1));
      expect(find.text('Delete project'), findsOneWidget);
    });

    testWidgets('cancel returns without acting', (tester) async {
      var deleted = 0;

      await tester.pumpWidget(_wrap(
        PlinthConfirmButton(
          label: 'Delete project',
          onConfirm: () => deleted++,
        ),
      ));

      await tester.tap(find.text('Delete project'));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(deleted, isZero);
      expect(find.text('Delete project'), findsOneWidget);
    });

    testWidgets('a null onConfirm disables it', (tester) async {
      // A delete that deletes nothing should not offer to.
      await tester.pumpWidget(_wrap(
        const PlinthConfirmButton(label: 'Delete project'),
      ));

      expect(
        tester.widget<PlinthButton>(find.byType(PlinthButton)).onPressed,
        isNull,
      );
    });
  });
}
