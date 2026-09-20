// The error-page blocks, and the two-pane auth layout.
//
// Same standard as the auth cards: what a gallery never checked is what
// is pinned here — that a disabled state is disabled for the right
// reason, that a layout degrades rather than clips, and that the words
// the named constructors ship are the ones intended.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {Size? surface}) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: surface == null
              ? SingleChildScrollView(child: child)
              : SizedBox.fromSize(size: surface, child: child),
        ),
      ),
    );

/// Types [code] into a [PlinthPinInput], one box per digit.
///
/// The component renders a `TextField` per digit rather than one field,
/// so `enterText` against the widget itself finds nothing to type into.
Future<void> _enterCode(WidgetTester tester, String code) async {
  for (final (index, digit) in code.split('').indexed) {
    await tester.enterText(find.byType(TextField).at(index), digit);
    await tester.pump();
  }
}

void main() {
  group('PlinthTwoFactorBlock', () {
    testWidgets('verify is disabled until the code is complete',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthTwoFactorBlock(onSubmit: (_) {}),
      ));

      PlinthButton verify() =>
          tester.widget<PlinthButton>(find.byType(PlinthButton));

      expect(verify().onPressed, isNull);

      await _enterCode(tester, '12345');
      expect(verify().onPressed, isNull, reason: 'five digits is not six');

      await _enterCode(tester, '123456');
      expect(verify().onPressed, isNotNull);
    });

    testWidgets('it reports the code', (tester) async {
      String? code;

      await tester.pumpWidget(_wrap(
        PlinthTwoFactorBlock(onSubmit: (value) => code = value),
      ));

      await _enterCode(tester, '424242');
      await tester.tap(find.text('Verify'));
      await tester.pump();

      expect(code, equals('424242'));
    });

    testWidgets('autoSubmit is off by default', (tester) async {
      // Off because an auto-submit that fires on a mistyped digit
      // spends an attempt before the person has finished reading it.
      var submissions = 0;

      await tester.pumpWidget(_wrap(
        PlinthTwoFactorBlock(onSubmit: (_) => submissions++),
      ));

      await _enterCode(tester, '123456');

      expect(submissions, isZero);
    });

    testWidgets('autoSubmit fires once on the last digit', (tester) async {
      var submissions = 0;

      await tester.pumpWidget(_wrap(
        PlinthTwoFactorBlock(autoSubmit: true, onSubmit: (_) => submissions++),
      ));

      await _enterCode(tester, '12345');
      expect(submissions, isZero);

      await _enterCode(tester, '123456');
      expect(submissions, equals(1));
    });

    testWidgets('a custom length moves the gate with it', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthTwoFactorBlock(length: 4, onSubmit: (_) {}),
      ));

      await _enterCode(tester, '1234');

      expect(
        tester.widget<PlinthButton>(find.byType(PlinthButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('the resend link is absent without a callback', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTwoFactorBlock()));
      expect(find.text('Send a new code'), findsNothing);
    });
  });

  group('PlinthErrorPageBlock', () {
    testWidgets('notFound ships the status and the words', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthErrorPageBlock.notFound(),
      ));

      expect(find.text('404'), findsOneWidget);
      expect(find.text('Nothing to see here'), findsOneWidget);
    });

    testWidgets('serverError does not blame the visitor', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthErrorPageBlock.serverError(),
      ));

      final text = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');

      expect(find.text('500'), findsOneWidget);
      expect(text, contains('not your fault'));
    });

    testWidgets('permissionDenied points at who can fix it', (tester) async {
      // "Access denied" alone leaves someone with nothing to do.
      await tester.pumpWidget(_wrap(
        const PlinthErrorPageBlock.permissionDenied(),
      ));

      final text = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');

      expect(text, contains('admin'));
    });

    testWidgets('maintenance has no status code', (tester) async {
      // There is no HTTP number worth showing for planned downtime.
      await tester.pumpWidget(_wrap(
        const PlinthErrorPageBlock.maintenance(),
      ));

      expect(find.text('Back shortly'), findsOneWidget);
      expect(find.text('503'), findsNothing);
    });

    testWidgets('every default is overridable', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthErrorPageBlock.notFound(
          title: 'Ingen sida hittades',
          description: 'Sidan kan ha flyttats.',
          status: 'Fel 404',
        ),
      ));

      expect(find.text('Ingen sida hittades'), findsOneWidget);
      expect(find.text('Fel 404'), findsOneWidget);
      expect(find.text('Nothing to see here'), findsNothing);
    });

    testWidgets('actions render', (tester) async {
      var home = 0;

      await tester.pumpWidget(_wrap(
        PlinthErrorPageBlock.notFound(
          actions: [
            PlinthButton(
              onPressed: () => home++,
              child: const Text('Take me home'),
            ),
          ],
        ),
      ));

      await tester.tap(find.text('Take me home'));
      await tester.pump();

      expect(home, equals(1));
    });
  });

  group('PlinthOfflineNotice', () {
    testWidgets('it is a notice, not a replacement for the page',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthOfflineNotice(
          onRetry: () {},
          details: const [
            PlinthDataListItem.text('Queued changes', '3'),
          ],
        ),
      ));

      // The queue state is the part that answers the actual question.
      expect(find.text('Queued changes'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byType(PlinthAlert), findsOneWidget);
    });

    testWidgets('retry is absent when there is nothing to retry',
        (tester) async {
      await tester.pumpWidget(_wrap(const PlinthOfflineNotice()));
      expect(find.text('Retry now'), findsNothing);
    });

    testWidgets('it is yellow, because nothing has failed', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthOfflineNotice()));

      expect(
        tester.widget<PlinthAlert>(find.byType(PlinthAlert)).color,
        equals('yellow'),
      );
    });
  });

  group('PlinthSplitAuthBlock', () {
    testWidgets('both panes show when there is room', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSplitAuthBlock(
          decoration: Text('brand'),
          child: Text('form'),
        ),
        surface: const Size(800, 400),
      ));

      expect(find.text('brand'), findsOneWidget);
      expect(find.text('form'), findsOneWidget);
    });

    testWidgets('the decoration drops below the breakpoint', (tester) async {
      // The pane that survives is the one with the form in it.
      await tester.pumpWidget(_wrap(
        const PlinthSplitAuthBlock(
          decoration: Text('brand'),
          child: Text('form'),
        ),
        surface: const Size(360, 400),
      ));

      expect(find.text('brand'), findsNothing);
      expect(find.text('form'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('decorationOnRight swaps the order', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSplitAuthBlock(
          decorationOnRight: true,
          decoration: Text('brand'),
          child: Text('form'),
        ),
        surface: const Size(800, 400),
      ));

      final brand = tester.getCenter(find.text('brand'));
      final form = tester.getCenter(find.text('form'));

      expect(brand.dx, greaterThan(form.dx));
    });

    testWidgets('a form taller than the pane scrolls instead of clipping',
        (tester) async {
      // Found by putting a real PlinthSignInBlock in one: the form was
      // 79px taller than the 300px pane, and what a clipped auth pane
      // hides is the submit button.
      await tester.pumpWidget(_wrap(
        PlinthSplitAuthBlock(
          height: 200,
          decoration: const Text('brand'),
          child: Column(
            children: [
              for (var i = 0; i < 12; i++) const SizedBox(height: 40),
            ],
          ),
        ),
        surface: const Size(800, 400),
      ));

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('no decoration renders the form alone', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSplitAuthBlock(child: Text('form')),
        surface: const Size(800, 400),
      ));

      expect(find.text('form'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
