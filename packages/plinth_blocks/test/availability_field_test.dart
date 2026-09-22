/// The three ways a hand-rolled availability check goes wrong.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: SizedBox(width: 400, child: child))),
    );

void main() {
  testWidgets('asks once for a burst of typing, not once per keystroke',
      (tester) async {
    final asked = <String>[];
    await tester.pumpWidget(_wrap(PlinthAvailabilityField(
      label: 'Username',
      check: (v) async {
        asked.add(v);
        return true;
      },
    )));

    for (final value in ['ad', 'ada', 'adao']) {
      await tester.enterText(find.byType(TextField), value);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 500));

    expect(asked, ['adao'], reason: 'asked about prefixes nobody chose');
    await tester.pumpAndSettle();
  });

  testWidgets('says nothing below minLength', (tester) async {
    var asked = 0;
    await tester.pumpWidget(_wrap(PlinthAvailabilityField(
      label: 'Username',
      check: (v) async {
        asked++;
        return true;
      },
    )));

    await tester.enterText(find.byType(TextField), 'ad');
    await tester.pump(const Duration(milliseconds: 600));

    expect(asked, 0, reason: 'a two-letter prefix matches everything');
    expect(find.text('Available'), findsNothing);
  });

  testWidgets('a slow answer about an old value never lands', (tester) async {
    // The bug that survives review: it needs two requests in flight and
    // a particular ordering before it shows itself, so it is invisible
    // to anyone typing at a normal speed on a fast connection.
    final gates = <String, Completer<bool>>{};
    await tester.pumpWidget(_wrap(PlinthAvailabilityField(
      label: 'Username',
      debounce: const Duration(milliseconds: 10),
      check: (v) => (gates[v] = Completer<bool>()).future,
    )));

    await tester.enterText(find.byType(TextField), 'ada');
    await tester.pump(const Duration(milliseconds: 20));

    await tester.enterText(find.byType(TextField), 'adaokafor');
    await tester.pump(const Duration(milliseconds: 20));

    // The *second* request answers first, and the first answers after.
    gates['adaokafor']!.complete(true);
    await tester.pump();
    expect(find.text('Available'), findsOneWidget);

    gates['ada']!.complete(false);
    await tester.pump();

    expect(
      find.text('Already taken'),
      findsNothing,
      reason: 'a stale answer overwrote a fresh one',
    );
    expect(find.text('Available'), findsOneWidget);
  });

  testWidgets('a failed check is not a taken name', (tester) async {
    // Conflating the two tells somebody their preferred name is gone
    // when the network merely hiccuped.
    await tester.pumpWidget(_wrap(PlinthAvailabilityField(
      label: 'Username',
      debounce: const Duration(milliseconds: 10),
      check: (v) async => throw StateError('offline'),
    )));

    await tester.enterText(find.byType(TextField), 'adaokafor');
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();

    expect(find.text('Could not check just now'), findsOneWidget);
    expect(find.text('Already taken'), findsNothing);
  });

  testWidgets('the result is announced, the spinner is not', (tester) async {
    await tester.pumpWidget(_wrap(PlinthAvailabilityField(
      label: 'Username',
      debounce: const Duration(milliseconds: 10),
      check: (v) async => false,
    )));

    await tester.enterText(find.byType(TextField), 'adaokafor');
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();

    // The answer arrives after the user stopped typing, so nothing else
    // would tell a reader it came.
    expect(
      find.descendant(
        of: find.byType(PlinthLiveRegion),
        matching: find.text('Already taken'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('clearing the field withdraws the question', (tester) async {
    await tester.pumpWidget(_wrap(PlinthAvailabilityField(
      label: 'Username',
      debounce: const Duration(milliseconds: 10),
      check: (v) async => false,
    )));

    await tester.enterText(find.byType(TextField), 'adaokafor');
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();
    expect(find.text('Already taken'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(
      find.text('Already taken'),
      findsNothing,
      reason: 'an answer about a value that is no longer there',
    );
  });

  testWidgets('disposing mid-flight does not throw', (tester) async {
    final gate = Completer<bool>();
    await tester.pumpWidget(_wrap(PlinthAvailabilityField(
      label: 'Username',
      debounce: const Duration(milliseconds: 10),
      check: (v) => gate.future,
    )));

    await tester.enterText(find.byType(TextField), 'adaokafor');
    await tester.pump(const Duration(milliseconds: 20));

    await tester.pumpWidget(_wrap(const SizedBox()));
    gate.complete(true);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
