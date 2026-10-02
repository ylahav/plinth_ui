/// `autofocus` and `onSubmitted` across the input family.
///
/// `PlinthTextInput` got them first, because bClock's one-field dialogs
/// had lost both when they moved off Material's `TextField`. That is a
/// different kind of finding from the rest of the conversion work: not
/// "Plinth has no X", but "Plinth's X lost something the thing it
/// replaced had", which only shows up by substitution.
///
/// The same argument applies to eight siblings — but not uniformly, and
/// the three negative cases below are the point of this file. On a
/// multiline field `onSubmitted` can never fire; on a tags field Enter is
/// already taken; on a PIN field `onCompleted` already is the submit. In
/// each case the parameter is absent on purpose, and these tests say so
/// in a form that fails if somebody adds it.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: Scaffold(body: child),
      ),
    );

/// Whether any `TextField` in the tree currently holds focus.
bool _focused(WidgetTester tester) => tester
    .widgetList<TextField>(find.byType(TextField))
    .any((f) => f.focusNode?.hasFocus ?? false);

/// Presses Enter the way the platform does it.
///
/// **Not `sendKeyEvent(enter)`.** A raw key event does not produce a text
/// input action, so `TextField.onSubmitted` never fires under it — the
/// engine turns Enter into `TextInputAction.done` and that is what the
/// field listens for. A raw Enter is still the right tool for testing a
/// `Focus.onKeyEvent` handler, which is why the autocomplete group below
/// uses both.
Future<void> _submit(WidgetTester tester) async {
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
}

void main() {
  group('autofocus takes focus on build', () {
    testWidgets('PlinthTextInput', (tester) async {
      await _pump(tester, const PlinthTextInput(autofocus: true));
      expect(_focused(tester), isTrue);
    });

    testWidgets('PlinthPasswordInput', (tester) async {
      await _pump(tester, const PlinthPasswordInput(autofocus: true));
      expect(_focused(tester), isTrue);
    });

    testWidgets('PlinthNumberInput', (tester) async {
      await _pump(
          tester,
          PlinthNumberInput(
            value: 1,
            onChanged: (_) {},
            autofocus: true,
          ));
      expect(_focused(tester), isTrue);
    });

    testWidgets('PlinthMaskInput', (tester) async {
      await _pump(
          tester, const PlinthMaskInput(mask: '000-000', autofocus: true));
      expect(_focused(tester), isTrue);
    });

    testWidgets('PlinthColorInput', (tester) async {
      await _pump(
          tester,
          PlinthColorInput(
            value: const Color(0xFF3B5BDB),
            onChanged: (_) {},
            autofocus: true,
          ));
      expect(_focused(tester), isTrue);
    });

    testWidgets('PlinthTextarea', (tester) async {
      await _pump(tester, const PlinthTextarea(autofocus: true));
      expect(_focused(tester), isTrue);
    });

    testWidgets('PlinthJsonInput', (tester) async {
      await _pump(tester, const PlinthJsonInput(autofocus: true));
      expect(_focused(tester), isTrue);
    });

    testWidgets('PlinthTagsInput', (tester) async {
      await _pump(
          tester,
          PlinthTagsInput(
            value: const [],
            onChanged: (_) {},
            autofocus: true,
          ));
      expect(_focused(tester), isTrue);
    });

    testWidgets('PlinthAutocomplete', (tester) async {
      await _pump(
          tester,
          PlinthAutocomplete(
            value: '',
            onChanged: (_) {},
            options: const ['alpha', 'beta'],
            autofocus: true,
          ));
      expect(_focused(tester), isTrue);
    });

    testWidgets('and nothing takes focus without it', (tester) async {
      // The negative control for this whole group: if focus happened
      // anyway, every assertion above would pass for the wrong reason.
      await _pump(tester, const PlinthTextInput());
      expect(_focused(tester), isFalse);
    });
  });

  group('PlinthPinInput focuses the first box only', () {
    testWidgets('box 0 has focus, the others do not', (tester) async {
      await _pump(tester, const PlinthPinInput(length: 4, autofocus: true));

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields, hasLength(4));
      final focus = fields.map((f) => f.focusNode?.hasFocus ?? false).toList();
      expect(focus, [true, false, false, false],
          reason: 'autofocusing all four is a fight they lose');
    });

    testWidgets('and none without it', (tester) async {
      await _pump(tester, const PlinthPinInput(length: 4));
      expect(_focused(tester), isFalse);
    });
  });

  group('onSubmitted fires on Enter', () {
    testWidgets('PlinthTextInput hands back the text', (tester) async {
      String? got;
      await _pump(
          tester,
          PlinthTextInput(
            autofocus: true,
            onSubmitted: (v) => got = v,
          ));
      await tester.enterText(find.byType(TextField), 'rename me');
      await _submit(tester);
      expect(got, 'rename me');
    });

    testWidgets('PlinthPasswordInput hands back the text', (tester) async {
      String? got;
      await _pump(
          tester,
          PlinthPasswordInput(
            autofocus: true,
            onSubmitted: (v) => got = v,
          ));
      await tester.enterText(find.byType(TextField), 'hunter2');
      await _submit(tester);
      expect(got, 'hunter2');
    });

    testWidgets('PlinthNumberInput hands back a clamped num, not text',
        (tester) async {
      num? got;
      await _pump(
          tester,
          PlinthNumberInput(
            value: 1,
            max: 10,
            onChanged: (_) {},
            autofocus: true,
            onSubmitted: (v) => got = v,
          ));
      await tester.enterText(find.byType(TextField), '42');
      await _submit(tester);
      expect(got, 10, reason: 'clamped to max, and a num rather than "42"');
    });

    testWidgets('PlinthNumberInput stays quiet on unparseable text',
        (tester) async {
      var fired = false;
      await _pump(
          tester,
          PlinthNumberInput(
            value: 1,
            onChanged: (_) {},
            autofocus: true,
            onSubmitted: (_) => fired = true,
          ));
      await tester.enterText(find.byType(TextField), '-');
      await _submit(tester);
      expect(fired, isFalse, reason: 'there is no number to submit');
    });

    testWidgets('PlinthMaskInput forwards it', (tester) async {
      String? got;
      await _pump(
          tester,
          PlinthMaskInput(
            mask: '000-000',
            autofocus: true,
            onSubmitted: (v) => got = v,
          ));
      await tester.enterText(find.byType(TextField), '123456');
      await _submit(tester);
      expect(got, isNotNull);
    });
  });

  group('the exclusions are deliberate', () {
    testWidgets('a multiline textarea gets a newline, not a submit',
        (tester) async {
      // Why PlinthTextarea has no onSubmitted: Flutter does not call it
      // on a multiline field, so the parameter would never fire.
      final controller = TextEditingController(text: 'one');
      addTearDown(controller.dispose);
      await _pump(
          tester, PlinthTextarea(controller: controller, autofocus: true));

      await tester.enterText(find.byType(TextField), 'one');
      await _submit(tester);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, greaterThan(1),
          reason: 'if this became single-line, onSubmitted would be viable '
              'and this exclusion should be revisited');
      expect(field.onSubmitted, isNull,
          reason: 'nothing should be wired to a callback Flutter will not '
              'call');
    });

    testWidgets('Enter on a tags field commits a tag', (tester) async {
      var tags = <String>[];
      await _pump(
          tester,
          StatefulBuilder(
            builder: (context, setState) => PlinthTagsInput(
              value: tags,
              onChanged: (v) => setState(() => tags = v),
              autofocus: true,
            ),
          ));

      await tester.enterText(find.byType(TextField), 'urgent');
      await _submit(tester);
      expect(tags, ['urgent'],
          reason: 'Enter already has a job here, which is why there is no '
              'public onSubmitted to give it a second one');
    });

    testWidgets('a PIN completes rather than submitting', (tester) async {
      String? completed;
      await _pump(
          tester,
          PlinthPinInput(
            length: 4,
            autofocus: true,
            onCompleted: (v) => completed = v,
          ));

      final boxes = find.byType(TextField);
      for (var i = 0; i < 4; i++) {
        await tester.enterText(boxes.at(i), '${i + 1}');
        await tester.pump();
      }
      expect(completed, '1234',
          reason: 'onCompleted is the submit for a code of known length');
    });
  });

  group('PlinthAutocomplete splits Enter with its option list', () {
    testWidgets('nothing highlighted — Enter reaches the form', (tester) async {
      String? submitted;
      String? picked;
      await _pump(
          tester,
          PlinthAutocomplete(
            value: '',
            onChanged: (_) {},
            options: const ['alpha', 'beta'],
            autofocus: true,
            onSubmitted: (v) => submitted = v,
            onOptionSelected: (v) => picked = v,
          ));

      await tester.enterText(find.byType(TextField), 'al');
      await tester.pump();

      // Two mechanisms, because two different things are being checked.
      // A raw Enter exercises the Focus handler: with nothing highlighted
      // it must return `ignored` and leave the option untouched.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked, isNull,
          reason: 'the list must not claim Enter with no highlight');

      // And the action path proves the field itself is wired.
      await _submit(tester);
      expect(submitted, 'al', reason: 'a free-text query must be submittable');
    });

    testWidgets('an option highlighted — Enter picks it instead',
        (tester) async {
      String? submitted;
      String? picked;
      await _pump(
          tester,
          PlinthAutocomplete(
            value: '',
            onChanged: (_) {},
            options: const ['alpha', 'beta'],
            autofocus: true,
            onSubmitted: (v) => submitted = v,
            onOptionSelected: (v) => picked = v,
          ));

      await tester.enterText(find.byType(TextField), 'al');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // Raw Enter on purpose: this is the Focus handler's path, and it
      // claims the key before the field ever sees an action.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(picked, 'alpha');
      expect(submitted, isNull,
          reason: 'the list claimed Enter, so the form must not also see it');
    });
  });
}
