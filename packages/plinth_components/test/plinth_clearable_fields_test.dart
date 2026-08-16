import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// `clearable` across the fields that hold a value someone might want
/// to take back.
///
/// Mantine offers it on seven inputs; Plinth had it on none, so
/// "I picked a value and now want none" meant building the affordance
/// outside the field. These five are the ones where an empty value is
/// meaningful — `PlinthColorInput` is excluded on purpose, since its
/// value is a non-nullable `Color` and there is no such thing as no
/// colour.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('PlinthSelect', () {
    testWidgets('offers a clear button only once something is chosen',
        (tester) async {
      await tester.pumpWidget(_wrap(PlinthSelect<String>(
        clearable: true,
        value: null,
        onChanged: (_) {},
        options: const [PlinthSelectOption('a', 'Alpha')],
      )));
      expect(find.bySemanticsLabel('Clear selection'), findsNothing);

      await tester.pumpWidget(_wrap(PlinthSelect<String>(
        clearable: true,
        value: 'a',
        onChanged: (_) {},
        options: const [PlinthSelectOption('a', 'Alpha')],
      )));
      expect(find.bySemanticsLabel('Clear selection'), findsOneWidget);
    });

    testWidgets('clearing reports null rather than opening the menu',
        (tester) async {
      final reported = <String?>[];
      await tester.pumpWidget(_wrap(PlinthSelect<String>(
        clearable: true,
        value: 'a',
        onChanged: reported.add,
        options: const [PlinthSelectOption('a', 'Alpha')],
      )));

      await tester.tap(find.bySemanticsLabel('Clear selection'));
      await tester.pumpAndSettle();

      // The button sits outside the DropdownButton for exactly this
      // reason: inside its `icon` slot the tap would open the menu it
      // is supposed to be clearing.
      expect(reported, [null]);
    });

    testWidgets('no button while disabled', (tester) async {
      await tester.pumpWidget(_wrap(PlinthSelect<String>(
        clearable: true,
        enabled: false,
        value: 'a',
        onChanged: (_) {},
        options: const [PlinthSelectOption('a', 'Alpha')],
      )));

      expect(find.bySemanticsLabel('Clear selection'), findsNothing);
    });
  });

  group('PlinthMultiSelect', () {
    testWidgets('empties every pill at once', (tester) async {
      List<String>? reported;
      await tester.pumpWidget(_wrap(PlinthMultiSelect<String>(
        clearable: true,
        value: const ['a', 'b'],
        onChanged: (v) => reported = v,
        options: const [
          PlinthMultiSelectOption('a', 'Alpha'),
          PlinthMultiSelectOption('b', 'Beta'),
        ],
      )));

      await tester.tap(find.bySemanticsLabel('Clear all selections'));
      await tester.pump();

      expect(reported, isEmpty);
    });
  });

  group('PlinthTagsInput', () {
    testWidgets('drops every tag', (tester) async {
      List<String>? reported;
      await tester.pumpWidget(_wrap(PlinthTagsInput(
        clearable: true,
        value: const ['dart', 'flutter'],
        onChanged: (v) => reported = v,
      )));

      await tester.tap(find.bySemanticsLabel('Clear all tags'));
      await tester.pump();

      expect(reported, isEmpty);
    });
  });

  group('PlinthFileInput', () {
    testWidgets('drops every file without reopening the picker',
        (tester) async {
      List<String>? reported;
      var pickerOpened = 0;

      await tester.pumpWidget(_wrap(PlinthFileInput<String>(
        clearable: true,
        value: const ['report.pdf'],
        labelBuilder: (f) => f,
        onPick: () async {
          pickerOpened++;
          return const [];
        },
        onChanged: (v) => reported = v,
      )));

      await tester.tap(find.bySemanticsLabel('Clear selected files'));
      await tester.pump();

      expect(reported, isEmpty);
      // The whole field is a tap target that opens the picker, so a
      // clear button that let the tap through would clear and
      // immediately ask for a new file.
      expect(pickerOpened, 0);
    });
  });

  group('PlinthAutocomplete', () {
    testWidgets('empties the text it is showing, not just the value',
        (tester) async {
      final reported = <String>[];
      await tester.pumpWidget(_wrap(PlinthAutocomplete(
        clearable: true,
        value: 'Acme',
        onChanged: reported.add,
        options: const ['Acme', 'Globex'],
      )));

      await tester.tap(find.bySemanticsLabel('Clear search'));
      await tester.pump();

      expect(reported, ['']);
      // This field owns its controller, so reporting an empty value
      // alone would leave the old text sitting in the box.
      expect(find.text('Acme'), findsNothing);
    });
  });

  testWidgets('every field keeps the button hidden by default', (tester) async {
    // Off by default everywhere: a required field that can be emptied
    // invites the state the form then has to reject.
    await tester.pumpWidget(_wrap(Column(
      children: [
        PlinthSelect<String>(
          value: 'a',
          onChanged: (_) {},
          options: const [PlinthSelectOption('a', 'Alpha')],
        ),
        PlinthTagsInput(value: const ['dart'], onChanged: (_) {}),
      ],
    )));

    // By label rather than by type: a tag pill carries its own close
    // button to remove itself, which is not the field-level clear.
    expect(find.bySemanticsLabel('Clear selection'), findsNothing);
    expect(find.bySemanticsLabel('Clear all tags'), findsNothing);
  });
}
