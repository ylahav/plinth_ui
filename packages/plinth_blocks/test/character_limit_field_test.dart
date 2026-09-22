/// A counter that is honest, and quiet until it matters.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: SizedBox(width: 420, child: child))),
    );

List<String> _captureAnnouncements(WidgetTester tester) {
  final announced = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility, (message) async {
    final m = message as Map<dynamic, dynamic>;
    if (m['type'] == 'announce') {
      announced.add((m['data'] as Map<dynamic, dynamic>)['message'] as String);
    }
    return null;
  });
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility, null));
  return announced;
}

void main() {
  testWidgets('counts down', (tester) async {
    await tester.pumpWidget(
      _wrap(const PlinthCharacterLimitField(label: 'Bio', maxLength: 50)),
    );
    expect(find.text('50'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    expect(find.text('45'), findsOneWidget);
  });

  testWidgets('a paste over the limit is truncated, not just flagged',
      (tester) async {
    // Typing cannot exceed a limit by more than one character. Pasting
    // an article into a 280-limit field exceeds it by thousands, and a
    // counter that only goes red has let a value through that the form
    // will reject later, elsewhere, in different words.
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(PlinthCharacterLimitField(
      label: 'Bio',
      maxLength: 10,
      controller: controller,
    )));

    await tester.enterText(find.byType(TextField), 'a' * 400);
    await tester.pump();

    expect(controller.text.length, 10);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('the caret survives truncation', (tester) async {
    // Left where it was in text that no longer exists, the next
    // keystroke lands somewhere baffling.
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(PlinthCharacterLimitField(
      label: 'Bio',
      maxLength: 5,
      controller: controller,
    )));

    await tester.enterText(find.byType(TextField), 'abcdefghij');
    await tester.pump();

    expect(controller.selection.baseOffset, 5);
    expect(controller.selection.isCollapsed, isTrue);
  });

  testWidgets('counts graphemes, not code units', (tester) async {
    // A flag emoji is one character to a person and several to Dart.
    // Counting the wrong one means a limit that rejects text a user
    // can see is short enough.
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(PlinthCharacterLimitField(
      label: 'Bio',
      maxLength: 3,
      controller: controller,
    )));

    await tester.enterText(find.byType(TextField), '🇵🇹🇵🇹🇵🇹');
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(controller.text.characters.length, 3);
  });

  testWidgets('announces the crossing once, not once per keystroke',
      (tester) async {
    // A live region on a counter reads a number after every letter,
    // which makes the field unusable with a screen reader.
    await tester.pumpWidget(
      _wrap(const PlinthCharacterLimitField(
        label: 'Bio',
        maxLength: 20,
        warnAt: 10,
      )),
    );
    final announced = _captureAnnouncements(tester);

    for (var i = 1; i <= 15; i++) {
      await tester.enterText(find.byType(TextField), 'a' * i);
      await tester.pump();
    }

    expect(announced, hasLength(1), reason: 'announced $announced');
    expect(announced.single, '10 characters remaining');
  });

  testWidgets('re-arms after going back under the threshold', (tester) async {
    // The user crossed it twice, so they are told twice.
    await tester.pumpWidget(
      _wrap(const PlinthCharacterLimitField(
        label: 'Bio',
        maxLength: 20,
        warnAt: 10,
      )),
    );
    final announced = _captureAnnouncements(tester);

    await tester.enterText(find.byType(TextField), 'a' * 12);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'a' * 12);
    await tester.pump();

    expect(announced, hasLength(2));
  });

  testWidgets('the counter itself is hidden from the reader', (tester) async {
    await tester.pumpWidget(
      _wrap(const PlinthCharacterLimitField(label: 'Bio', maxLength: 50)),
    );

    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel('50'), findsNothing,
        reason: 'the counter is in the tree, so it will be read aloud');
    handle.dispose();
  });
}
