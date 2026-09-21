// The password meter and the secret field.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 460}) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );

void main() {
  group('PlinthPasswordStrength', () {
    testWidgets('strength is the share of rules met', (tester) async {
      const nothing = PlinthPasswordStrength(value: '');
      expect(nothing.strength, equals(0));

      const everything = PlinthPasswordStrength(value: r'Abcdefg1!');
      expect(everything.strength, equals(1));

      // 8 chars and a number, no capital, no symbol.
      const half = PlinthPasswordStrength(value: 'abcdefg1');
      expect(half.strength, equals(0.5));
    });

    testWidgets('the bar changes band rather than creeping', (tester) async {
      // The useful question is whether this will be accepted.
      Future<String> bandFor(String value) async {
        await tester.pumpWidget(_wrap(PlinthPasswordStrength(value: value)));
        return tester
            .widget<PlinthProgress>(find.byType(PlinthProgress))
            .color!;
      }

      expect(await bandFor('abc'), equals('red'));
      expect(await bandFor('abcdefg1'), equals('yellow'));
      expect(await bandFor(r'Abcdefg1!'), equals('green'));
    });

    testWidgets('every rule stays on screen, met or not', (tester) async {
      // A checklist that hides what you satisfied leaves you re-reading
      // the remainder to work out what changed.
      await tester.pumpWidget(_wrap(
        const PlinthPasswordStrength(value: 'abcdefgh'),
      ));

      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(find.text('Includes a number'), findsOneWidget);
      expect(find.text('Includes a symbol'), findsOneWidget);
    });

    testWidgets('each rule says whether it is met, in words', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthPasswordStrength(value: 'abcdefgh'),
      ));

      expect(
        find.bySemanticsLabel('At least 8 characters, met'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Includes a number, not met'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('custom rules replace the defaults entirely', (tester) async {
      // Your server's rules are the ones that decide.
      await tester.pumpWidget(_wrap(
        PlinthPasswordStrength(
          value: 'anything',
          rules: [PlinthPasswordRule('Not empty', (v) => v.isNotEmpty)],
        ),
      ));

      expect(find.text('Not empty'), findsOneWidget);
      expect(find.text('At least 8 characters'), findsNothing);
    });

    testWidgets('no rules does not divide by zero', (tester) async {
      const empty = PlinthPasswordStrength(value: 'abc', rules: []);
      expect(empty.strength, equals(0));

      await tester.pumpWidget(_wrap(empty));
      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthSecretField', () {
    testWidgets('it shows the value, copy, and regenerate', (tester) async {
      var rotated = 0;

      await tester.pumpWidget(_wrap(
        PlinthSecretField(
          label: 'Publishable key',
          value: 'pk_live_abc',
          onRegenerate: () => rotated++,
        ),
      ));

      expect(find.byType(PlinthCopyButton), findsOneWidget);

      await tester.tap(find.text('Regenerate'));
      await tester.pump();
      expect(rotated, equals(1));
    });

    testWidgets('no onRegenerate means no button', (tester) async {
      // A regenerate that does nothing is worse than no regenerate.
      await tester.pumpWidget(_wrap(
        const PlinthSecretField(value: 'pk_live_abc'),
      ));

      expect(find.text('Regenerate'), findsNothing);
      expect(find.byType(PlinthCopyButton), findsOneWidget);
    });

    testWidgets('a new value from the server replaces what is shown',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSecretField(value: 'pk_live_first'),
      ));

      await tester.pumpWidget(_wrap(
        const PlinthSecretField(value: 'pk_live_second'),
      ));
      await tester.pump();

      final field = tester.widget<PlinthPasswordInput>(
        find.byType(PlinthPasswordInput),
      );
      expect(field.controller!.text, equals('pk_live_second'));
    });

    testWidgets('a warning is an alert, not muted text', (tester) async {
      // Rotating a live key breaks whatever is using it. That is not a
      // footnote.
      await tester.pumpWidget(_wrap(
        const PlinthSecretField(
          value: 'pk_live_abc',
          warning: 'Regenerating takes effect immediately.',
        ),
      ));

      expect(find.byType(PlinthAlert), findsOneWidget);
    });
  });
}
