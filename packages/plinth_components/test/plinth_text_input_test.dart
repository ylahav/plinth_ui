import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

/// The border painted around the field itself.
///
/// The first Container inside the widget is the bordered box — the
/// label and description sit outside it, above.
Border _border(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(PlinthTextInput),
          matching: find.byType(Container),
        )
        .first,
  );
  return (container.decoration! as BoxDecoration).border! as Border;
}

Future<void> _focusField(WidgetTester tester) async {
  await tester.tap(find.byType(TextField));
  await tester.pump();
}

void main() {
  final theme = PlinthTheme.defaultTheme;
  const unfocusedGray = Color(0xFFCED4DA);

  group('PlinthTextInput', () {
    testWidgets('renders label, description, and placeholder', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTextInput(
            label: 'Email',
            description: "We'll never share it.",
            placeholder: 'you@example.com',
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text("We'll never share it."), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('omits label and description when not given', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTextInput()));

      // Only the field itself, no stray empty text slots above it.
      expect(find.byType(PlinthText), findsNothing);
    });

    testWidgets('renders the error message below the field', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTextInput(error: 'Enter a valid email')),
      );

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('an empty error string is treated as no error', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTextInput(error: '')));

      // Otherwise clearing an error by setting '' rather than null
      // would leave the field looking permanently invalid.
      expect(_border(tester).top.color, unfocusedGray);
      expect(_border(tester).top.width, 1);
    });

    testWidgets('is gray-bordered and hairline-thin when idle', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTextInput()));

      expect(_border(tester).top.color, unfocusedGray);
      expect(_border(tester).top.width, 1);
    });

    testWidgets('focus switches the border to the theme color', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTextInput()));
      await _focusField(tester);

      expect(_border(tester).top.color, theme.color(theme.primaryColor, 6));
      expect(_border(tester).top.width, 2);
    });

    testWidgets('focus uses an explicit color override', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTextInput(color: 'green')));
      await _focusField(tester);

      expect(_border(tester).top.color, theme.color('green', 6));
    });

    testWidgets('an error switches the border to red without focus',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTextInput(error: 'Required')),
      );

      expect(_border(tester).top.color, theme.color('red', 6));
      expect(_border(tester).top.width, 2);
    });

    testWidgets('the error border follows PlinthRole.error, not the red ramp',
        (tester) async {
      // PR-09. Before this the widget reached into `colors` for 'red'
      // directly, so an app repurposing that key as its own expense
      // colour silently restyled every form field in the library.
      final remapped = PlinthTheme.defaultTheme
          .copyWith(roleRamps: const {PlinthRole.error: 'grape'});

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [remapped]),
          home: const Scaffold(body: PlinthTextInput(error: 'Required')),
        ),
      );

      expect(_border(tester).top.color, remapped.color('grape', 6));
      expect(_border(tester).top.color, isNot(remapped.color('red', 6)));
    });

    testWidgets('error takes precedence over focus', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTextInput(color: 'green', error: 'Required')),
      );
      await _focusField(tester);

      // The documented precedence: a focused *and* invalid field reads
      // as invalid, not as focused. Without this the error colour would
      // vanish the moment the user clicked in to fix the problem.
      expect(_border(tester).top.color, theme.color('red', 6));
      expect(_border(tester).top.color, isNot(theme.color('green', 6)));
    });

    testWidgets('calls onChanged as the user types', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _wrap(PlinthTextInput(onChanged: changes.add)),
      );

      await tester.enterText(find.byType(TextField), 'hello');

      expect(changes, ['hello']);
    });

    testWidgets('reflects an external controller', (tester) async {
      final controller = TextEditingController(text: 'preset');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(PlinthTextInput(controller: controller)),
      );

      expect(find.text('preset'), findsOneWidget);
    });

    testWidgets('enabled: false disables the underlying field', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTextInput(enabled: false)),
      );

      // Distinct from a null onChanged, which leaves the field
      // read-only-but-selectable — the split this library documents.
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('a null onChanged leaves the field enabled', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTextInput()));

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    });

    testWidgets('obscureText reaches the field', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTextInput(obscureText: true)),
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isTrue,
      );
    });

    testWidgets('renders a leading icon', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTextInput(leadingIcon: Icon(Icons.search))),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('every size renders', (tester) async {
      for (final size in PlinthSize.values) {
        await tester.pumpWidget(
          _wrap(PlinthTextInput(label: size.name, size: size)),
        );

        expect(find.text(size.name), findsOneWidget);
      }
    });
  });
}
