/// The translation seam, and the three things it must not get wrong.
///
/// Twenty-one strings were hardcoded before this, and every one was a
/// screen-reader label. A visible English string in a Spanish app is
/// obvious to whoever sees it; an audible one is not, because the
/// person it fails is the person who cannot see that it is wrong.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _app({
  LocalizationsDelegate<PlinthLocalizations>? delegate,
  required Widget child,
}) =>
    MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      localizationsDelegates: delegate == null ? null : [delegate],
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('with nothing registered', () {
    testWidgets('labels are still there', (tester) async {
      // The failure that would make this change worse than no change:
      // accessibility labels that disappear unless you opt in. Most
      // apps will never add a delegate.
      await tester.pumpWidget(_app(
        child: PlinthSelect<String>(
          label: 'Country',
          options: const [PlinthSelectOption('pt', 'Portugal')],
          value: 'pt',
          clearable: true,
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Clear selection'), findsOneWidget);
    });

    testWidgets('of() returns the defaults rather than throwing',
        (tester) async {
      // `MaterialLocalizations.of` asserts when absent. These are a
      // seam over labels that already worked, so absence is normal.
      late PlinthStrings strings;
      await tester.pumpWidget(_app(
        child: Builder(builder: (context) {
          strings = PlinthLocalizations.of(context);
          return const SizedBox();
        }),
      ));

      expect(strings.closeDialog, 'Close dialog');
    });
  });

  group('with an override registered', () {
    testWidgets('the override is what a reader hears', (tester) async {
      await tester.pumpWidget(_app(
        delegate: PlinthLocalizations.override(
          const PlinthStrings(clearSelection: 'Limpiar selección'),
        ),
        child: PlinthSelect<String>(
          label: 'País',
          options: const [PlinthSelectOption('pt', 'Portugal')],
          value: 'pt',
          clearable: true,
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Limpiar selección'), findsOneWidget);
      expect(find.bySemanticsLabel('Clear selection'), findsNothing);
    });

    testWidgets('overriding one string leaves the other twenty alone',
        (tester) async {
      // Every field has a default, so a caller who cares about two
      // strings writes two lines rather than a file.
      late PlinthStrings strings;
      await tester.pumpWidget(_app(
        delegate: PlinthLocalizations.override(
          const PlinthStrings(closeDialog: 'Cerrar'),
        ),
        child: Builder(builder: (context) {
          strings = context.plinthStrings;
          return const SizedBox();
        }),
      ));

      // Delegates resolve asynchronously, so the first frame renders
      // nothing at all and the builder has not run yet.
      await tester.pumpAndSettle();

      expect(strings.closeDialog, 'Cerrar');
      expect(strings.nextSlide, 'Next slide');
    });
  });

  group('an explicit parameter still wins', () {
    testWidgets('over both the override and the default', (tester) async {
      // The seam sits *beneath* the existing API. Nothing about the
      // per-widget label parameters changed, and a caller who passed
      // one before must still get it.
      await tester.pumpWidget(_app(
        delegate: PlinthLocalizations.override(
          const PlinthStrings(clearSelection: 'from the delegate'),
        ),
        child: PlinthCloseButton(
          onPressed: () {},
          semanticLabel: 'from the call site',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('from the call site'), findsOneWidget);
    });
  });

  group('PlinthStrings', () {
    test('compares by value, so the delegate does not reload for nothing', () {
      expect(const PlinthStrings(), const PlinthStrings());
      expect(const PlinthStrings().hashCode, const PlinthStrings().hashCode);
      expect(
        const PlinthStrings(hue: 'Tono'),
        isNot(const PlinthStrings()),
      );
    });

    test('copyWith changes one field and keeps the rest', () {
      final changed = const PlinthStrings().copyWith(rating: 'Valoración');
      expect(changed.rating, 'Valoración');
      expect(changed.angle, 'Angle');
    });

    test('every field is carried by copyWith', () {
      // The failure this catches is a field added to the constructor
      // and forgotten in `copyWith`, which silently resets it on the
      // next copy anybody makes.
      const marker = '<<marker>>';
      final all = PlinthStrings(
        dismissAlert: marker,
        dismissNotification: marker,
        closeDialog: marker,
        previousSlide: marker,
        nextSlide: marker,
        clearSearch: marker,
        clearSelection: marker,
        clearAllSelections: marker,
        clearAllTags: marker,
        clearSelectedFiles: marker,
        clearColor: marker,
        chooseColor: marker,
        saturationAndBrightness: marker,
        opacity: marker,
        hue: marker,
        angle: marker,
        rating: marker,
        resizeWindow: marker,
        decrease: marker,
        increase: marker,
        passwordStrength: marker,
      );

      // A no-op copy must be equal to what it copied.
      expect(all.copyWith(), all);
    });
  });
}
