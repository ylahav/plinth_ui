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
  group('PlinthFileInput', () {
    testWidgets('shows the placeholder with nothing selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthFileInput<String>(
            placeholder: 'Choose a report',
            value: const [],
            labelBuilder: (f) => f,
            onPick: () async => const [],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Choose a report'), findsOneWidget);
    });

    testWidgets('renders a chip per selected file', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthFileInput<String>(
            value: const ['a.pdf', 'b.png'],
            labelBuilder: (f) => f,
            onPick: () async => const [],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('a.pdf'), findsOneWidget);
      expect(find.text('b.png'), findsOneWidget);
    });

    testWidgets('tapping calls the caller-supplied picker', (tester) async {
      var picks = 0;
      List<String>? received;
      await tester.pumpWidget(
        _wrap(
          PlinthFileInput<String>(
            value: const [],
            labelBuilder: (f) => f,
            onPick: () async {
              picks++;
              return const ['picked.txt'];
            },
            onChanged: (files) => received = files,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('plinth_file_input_field')));
      await tester.pumpAndSettle();

      // The whole design: this component never opens a picker itself,
      // so plinth_components takes no file-picking dependency.
      expect(picks, 1);
      expect(received, ['picked.txt']);
    });

    testWidgets('a cancelled picker leaves the selection alone',
        (tester) async {
      var changes = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthFileInput<String>(
            value: const ['keep.pdf'],
            labelBuilder: (f) => f,
            onPick: () async => null,
            onChanged: (_) => changes++,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('plinth_file_input_field')));
      await tester.pumpAndSettle();

      // Cancelling a dialog must not discard what was already chosen.
      expect(changes, 0);
    });

    testWidgets('single mode replaces, multiple appends', (tester) async {
      List<String>? received;

      Widget build({required bool multiple}) => _wrap(
            PlinthFileInput<String>(
              multiple: multiple,
              value: const ['first.pdf'],
              labelBuilder: (f) => f,
              onPick: () async => const ['second.pdf'],
              onChanged: (files) => received = files,
            ),
          );

      await tester.pumpWidget(build(multiple: false));
      await tester.tap(find.byKey(const Key('plinth_file_input_field')));
      await tester.pumpAndSettle();
      expect(received, ['second.pdf']);

      await tester.pumpWidget(build(multiple: true));
      await tester.tap(find.byKey(const Key('plinth_file_input_field')));
      await tester.pumpAndSettle();
      expect(received, ['first.pdf', 'second.pdf']);
    });

    testWidgets('removing a chip drops just that file', (tester) async {
      List<String>? received;
      await tester.pumpWidget(
        _wrap(
          PlinthFileInput<String>(
            value: const ['a.pdf', 'b.png'],
            labelBuilder: (f) => f,
            onPick: () async => const [],
            onChanged: (files) => received = files,
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Remove a.pdf'));
      await tester.pumpAndSettle();

      expect(received, ['b.png']);
    });

    testWidgets('disabled does not open the picker', (tester) async {
      var picks = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthFileInput<String>(
            enabled: false,
            value: const [],
            labelBuilder: (f) => f,
            onPick: () async {
              picks++;
              return const [];
            },
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('plinth_file_input_field')));
      await tester.pumpAndSettle();

      expect(picks, 0);
    });

    testWidgets('works with an arbitrary file type', (tester) async {
      // The generic is the point: callers keep whatever their picker
      // returns rather than converting to a Plinth-specific type.
      await tester.pumpWidget(
        _wrap(
          PlinthFileInput<({String name, int bytes})>(
            value: const [(name: 'report.csv', bytes: 2048)],
            labelBuilder: (f) => '${f.name} (${f.bytes}B)',
            onPick: () async => const [],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('report.csv (2048B)'), findsOneWidget);
    });
  });

  group('PlinthTagsInput', () {
    testWidgets('renders a chip per tag', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(value: const ['dart', 'flutter'], onChanged: (_) {}),
        ),
      );

      expect(find.text('dart'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
    });

    testWidgets('submitting commits a tag', (tester) async {
      List<String>? received;
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(value: const [], onChanged: (t) => received = t),
        ),
      );

      await tester.enterText(find.byType(TextField), 'dart');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(received, ['dart']);
    });

    testWidgets('a comma commits, so a pasted list becomes several tags',
        (tester) async {
      List<String>? received;
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(value: const [], onChanged: (t) => received = t),
        ),
      );

      await tester.enterText(find.byType(TextField), 'dart,');
      await tester.pumpAndSettle();

      expect(received, ['dart']);
    });

    testWidgets('trims whitespace and ignores an empty commit', (tester) async {
      var changes = 0;
      List<String>? received;
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(
            value: const [],
            onChanged: (t) {
              changes++;
              received = t;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(changes, 0);

      await tester.enterText(find.byType(TextField), '  dart  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(received, ['dart']);
    });

    testWidgets('rejects a duplicate by default', (tester) async {
      var changes = 0;
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(value: const ['dart'], onChanged: (_) => changes++),
        ),
      );

      await tester.enterText(find.byType(TextField), 'dart');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Two identical chips give the user no way to tell them apart.
      expect(changes, 0);
    });

    testWidgets('allows a duplicate when asked to', (tester) async {
      List<String>? received;
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(
            value: const ['dart'],
            allowDuplicates: true,
            onChanged: (t) => received = t,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'dart');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(received, ['dart', 'dart']);
    });

    testWidgets('backspace on an empty field removes the last tag',
        (tester) async {
      List<String>? received;
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(
            value: const ['dart', 'flutter'],
            onChanged: (t) => received = t,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      expect(received, ['dart']);
    });

    testWidgets('removing a chip drops just that tag', (tester) async {
      List<String>? received;
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(
            value: const ['dart', 'flutter'],
            onChanged: (t) => received = t,
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Remove dart'));
      await tester.pumpAndSettle();

      expect(received, ['flutter']);
    });

    testWidgets('maxTags stops further entry', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(
            value: const ['a', 'b'],
            maxTags: 2,
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).enabled,
        isFalse,
      );
    });
  });

  group('PlinthAutocomplete', () {
    const options = ['Acme', 'Globex', 'Initech', 'Gmail'];

    testWidgets('renders its label and current value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAutocomplete(
            label: 'Company',
            value: 'Acme',
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Company'), findsOneWidget);
      expect(find.text('Acme'), findsWidgets);
    });

    testWidgets('shows suggestions on focus', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAutocomplete(
            value: '',
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('Globex'), findsOneWidget);
    });

    testWidgets('filters as you type, matching anywhere in the option',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAutocomplete(
            value: '',
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'mail');
      await tester.pumpAndSettle();

      // "mail" offering "Gmail" is the point of contains-matching over
      // startsWith — a fragment is usually what someone half-remembers.
      expect(find.text('Gmail'), findsWidgets);
      expect(find.text('Globex'), findsNothing);
    });

    testWidgets('picking a suggestion sets the value and closes the list',
        (tester) async {
      String? received;
      String? selected;
      await tester.pumpWidget(
        _wrap(
          PlinthAutocomplete(
            value: '',
            options: options,
            onChanged: (v) => received = v,
            onOptionSelected: (v) => selected = v,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const ValueKey('plinth_autocomplete_option_Globex')));
      await tester.pumpAndSettle();

      expect(received, 'Globex');
      expect(selected, 'Globex');
      expect(find.byKey(const ValueKey('plinth_autocomplete_option_Acme')),
          findsNothing);
    });

    testWidgets('accepts free text that matches nothing', (tester) async {
      String? received;
      await tester.pumpWidget(
        _wrap(
          PlinthAutocomplete(
            value: '',
            options: options,
            onChanged: (v) => received = v,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Something else');
      await tester.pumpAndSettle();

      // Unlike PlinthSelect, being absent from the list is not an error.
      expect(received, 'Something else');
    });

    testWidgets('limit caps how many suggestions show', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAutocomplete(
            value: '',
            limit: 2,
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('Acme'), findsWidgets);
      expect(find.text('Initech'), findsNothing);
    });

    testWidgets('disabled shows no suggestions', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAutocomplete(
            value: '',
            enabled: false,
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(TextField), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Globex'), findsNothing);
    });

    testWidgets('anchors its list to the field, not the whole widget',
        (tester) async {
      // The outer Column stretches to fill a tall parent, so linking the
      // overlay to it put the list a screen-height below the field —
      // rendered, but off the bottom of the viewport and untappable.
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              PlinthAutocomplete(
                value: '',
                options: options,
                onChanged: (_) {},
              ),
              const Spacer(),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final option =
          find.byKey(const ValueKey('plinth_autocomplete_option_Globex'));
      expect(
        tester.getCenter(option).dy,
        lessThan(600),
        reason: 'the list should sit within the viewport, below the field',
      );
    });

    testWidgets('removes its overlay when disposed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthAutocomplete(
            value: '',
            options: options,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_wrap(const Text('Replaced')));
      await tester.pumpAndSettle();

      expect(find.text('Globex'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
