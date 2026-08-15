@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

import 'helpers/golden.dart';

/// Golden coverage for the states `plinth_text_input_test.dart` can
/// only assert numerically.
///
/// That file already pins the *rules* — error beats focus, an empty
/// error string is no error, a null `onChanged` still leaves the field
/// enabled — by reading border colours and widths back out of the
/// decoration. What it can't see is the result: padding, label
/// spacing, the description and error lines stacking correctly, and
/// the two-pixel border not shifting the field's height as it thickens.
///
/// `docs/TESTING.md` names this component as the first thing to extend
/// golden coverage to, for exactly that reason: it has the most
/// conditional border logic in the library.
void main() {
  group('PlinthTextInput golden', () {
    testWidgets('idle', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 260,
            child: PlinthTextInput(label: 'Email', placeholder: 'you@here.com'),
          ),
          height: 120,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_text_input_idle.png'),
      );
    });

    testWidgets('focused', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 260,
            child: PlinthTextInput(label: 'Email', placeholder: 'you@here.com'),
          ),
          height: 120,
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_text_input_focused.png'),
      );
    });

    testWidgets('error', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 260,
            child: PlinthTextInput(
              label: 'Email',
              placeholder: 'you@here.com',
              error: 'Enter a valid address',
            ),
          ),
          height: 140,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_text_input_error.png'),
      );
    });

    testWidgets('error while focused', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 260,
            child: PlinthTextInput(
              label: 'Email',
              error: 'Enter a valid address',
            ),
          ),
          height: 140,
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // The precedence rule, as a picture: the border stays red rather
      // than switching to the focus colour.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_text_input_error_focused.png'),
      );
    });

    testWidgets('with description and leading icon', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 260,
            child: PlinthTextInput(
              label: 'Search',
              description: 'Matches titles and body text',
              leadingIcon: Icon(Icons.search, size: 18),
            ),
          ),
          height: 140,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_text_input_described.png'),
      );
    });

    testWidgets('disabled', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 260,
            child: PlinthTextInput(label: 'Email', enabled: false),
          ),
          height: 120,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_text_input_disabled.png'),
      );
    });

    testWidgets('every size', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlinthTextInput(size: PlinthSize.xs, placeholder: 'xs'),
                SizedBox(height: 6),
                PlinthTextInput(size: PlinthSize.md, placeholder: 'md'),
                SizedBox(height: 6),
                PlinthTextInput(size: PlinthSize.xl, placeholder: 'xl'),
              ],
            ),
          ),
          height: 200,
        ),
      );
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_text_input_sizes.png'),
      );
    });

    testWidgets('dark theme', (tester) async {
      await tester.pumpWidget(
        goldenWrap(
          const SizedBox(
            width: 260,
            child: PlinthTextInput(
              label: 'Email',
              error: 'Enter a valid address',
            ),
          ),
          height: 140,
          dark: true,
        ),
      );

      // Dark mode is a chrome swap rather than a rewrite, so this is
      // where a token wired to the wrong value would show up.
      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('goldens/plinth_text_input_dark.png'),
      );
    });
  });
}
