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
  group('PlinthPill', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthPill('design')));

      expect(find.text('design'), findsOneWidget);
    });

    testWidgets('a null onRemove renders no remove button', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthPill('fixed')));

      expect(find.byType(PlinthCloseButton), findsNothing);
    });

    testWidgets('removing reports it', (tester) async {
      var removed = 0;
      await tester.pumpWidget(
        _wrap(PlinthPill('design', onRemove: () => removed++)),
      );

      await tester.tap(find.byType(PlinthCloseButton));
      await tester.pump();

      expect(removed, 1);
    });

    testWidgets('the remove button names the value it removes', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPill('design', onRemove: () {})),
      );

      // A row of identical "close" buttons tells a screen-reader user
      // nothing about which value goes.
      expect(find.bySemanticsLabel('Remove design'), findsOneWidget);
    });
  });

  group('PlinthPill extraction', () {
    testWidgets('PlinthTagsInput renders its values as pills', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthTagsInput(
            value: const ['dart', 'flutter'],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(PlinthPill), findsNWidgets(2));
      expect(find.bySemanticsLabel('Remove dart'), findsOneWidget);
    });

    testWidgets('PlinthMultiSelect renders its values as pills', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PlinthMultiSelect<String>(
            value: const ['dart'],
            onChanged: (_) {},
            options: const [
              PlinthMultiSelectOption('dart', 'Dart'),
              PlinthMultiSelectOption('flutter', 'Flutter'),
            ],
          ),
        ),
      );

      expect(find.byType(PlinthPill), findsOneWidget);
      expect(find.bySemanticsLabel('Remove Dart'), findsOneWidget);
    });
  });

  group('PlinthPillsInput', () {
    testWidgets('renders label, children, and error', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthPillsInput(
            label: 'Recipients',
            error: 'Pick at least one',
            children: [PlinthPill('ana@example.com')],
          ),
        ),
      );

      expect(find.text('Recipients'), findsOneWidget);
      expect(find.text('ana@example.com'), findsOneWidget);
      expect(find.text('Pick at least one'), findsOneWidget);
    });

    testWidgets('shows the placeholder only while empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthPillsInput(placeholder: 'Add someone', children: []),
        ),
      );
      expect(find.text('Add someone'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const PlinthPillsInput(
            placeholder: 'Add someone',
            children: [PlinthPill('ana')],
          ),
        ),
      );
      expect(find.text('Add someone'), findsNothing);
    });

    testWidgets('error takes precedence over focus on the border', (
      tester,
    ) async {
      Border borderOf(WidgetTester t) {
        final container = t.widget<Container>(
          find
              .descendant(
                of: find.byType(PlinthPillsInput),
                matching: find.byType(Container),
              )
              .first,
        );
        return (container.decoration! as BoxDecoration).border! as Border;
      }

      await tester.pumpWidget(
        _wrap(const PlinthPillsInput(focused: true, children: [])),
      );
      final focusedColor = borderOf(tester).top.color;

      await tester.pumpWidget(
        _wrap(
          const PlinthPillsInput(focused: true, error: 'bad', children: []),
        ),
      );

      // Same order PlinthTextInput uses: an error outranks focus.
      expect(borderOf(tester).top.color, isNot(focusedColor));
      expect(
        borderOf(tester).top.color,
        PlinthTheme.defaultTheme.shaded('red', 6),
      );
    });
  });

  group('PlinthCombobox', () {
    late PlinthDisclosureController controller;

    setUp(() => controller = PlinthDisclosureController());
    tearDown(() => controller.dispose());

    Widget combobox({
      List<PlinthComboboxOption<String>>? options,
      String? selected,
      void Function(String)? onSelected,
      Widget? empty,
    }) {
      return _wrap(
        SizedBox(
          width: 300,
          child: PlinthCombobox<String>(
            controller: controller,
            selected: selected,
            empty: empty,
            target: PlinthButton(
              onPressed: controller.toggle,
              child: const Text('Open'),
            ),
            options: options ??
                const [
                  PlinthComboboxOption('a', 'Alpha'),
                  PlinthComboboxOption('b', 'Beta', disabled: true),
                  PlinthComboboxOption('c', 'Gamma'),
                ],
            onSelected: onSelected ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('shows nothing until opened', (tester) async {
      await tester.pumpWidget(combobox());
      expect(find.text('Alpha'), findsNothing);

      controller.open();
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('tapping an option reports it and closes', (tester) async {
      String? picked;
      await tester.pumpWidget(combobox(onSelected: (v) => picked = v));

      controller.open();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gamma'));
      await tester.pumpAndSettle();

      expect(picked, 'c');
      expect(controller.isOpen, isFalse);
    });

    testWidgets('a disabled option cannot be chosen', (tester) async {
      String? picked;
      await tester.pumpWidget(combobox(onSelected: (v) => picked = v));

      controller.open();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beta'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(picked, isNull);
      expect(controller.isOpen, isTrue);
    });

    testWidgets('arrow keys skip disabled options and Enter takes one', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(combobox(onSelected: (v) => picked = v));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Highlight starts on Alpha; one press must land on Gamma, not
      // on the disabled Beta between them.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(picked, 'c');
    });

    testWidgets('Escape closes without choosing', (tester) async {
      String? picked;
      await tester.pumpWidget(combobox(onSelected: (v) => picked = v));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(picked, isNull);
      expect(controller.isOpen, isFalse);
    });

    testWidgets('the highlight stops at the ends rather than wrapping', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(combobox(onSelected: (v) => picked = v));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Already on the first option; up must not jump to the last.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(picked, 'a');
    });

    testWidgets('the list tracks options replaced underneath it', (
      tester,
    ) async {
      await tester.pumpWidget(combobox());
      controller.open();
      await tester.pumpAndSettle();
      expect(find.text('Alpha'), findsOneWidget);

      // Filtering as you type replaces the list wholesale — the open
      // panel has to follow, which is what PlinthPopover failed to do.
      await tester.pumpWidget(
        combobox(
          options: const [PlinthComboboxOption('z', 'Zeta')],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsNothing);
      expect(find.text('Zeta'), findsOneWidget);
    });

    testWidgets('an empty list shows the empty widget when given one', (
      tester,
    ) async {
      await tester.pumpWidget(
        combobox(options: const [], empty: const Text('No matches')),
      );

      controller.open();
      await tester.pumpAndSettle();

      expect(find.text('No matches'), findsOneWidget);
    });

    testWidgets('an empty list with no empty widget renders no panel', (
      tester,
    ) async {
      await tester.pumpWidget(combobox(options: const []));

      controller.open();
      await tester.pumpAndSettle();

      // An empty bordered box is worse than no box.
      expect(find.byType(PlinthScrollArea), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the selected option is marked and starts highlighted', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        combobox(selected: 'c', onSelected: (v) => picked = v),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);

      // Opening onto the current value: Enter without moving keeps it.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(picked, 'c');
    });
  });
}
