// What makes these blocks rather than demos.
//
// The showcase versions these were extracted from had `onPressed: () {}`
// everywhere — they proved an arrangement renders, which is all a
// gallery needs. A block an app installs has to do more than render:
// report what was typed, refuse to submit when it should, and disable
// rather than fail. That is what is pinned here.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Center(child: SingleChildScrollView(child: child))),
    );

void main() {
  group('PlinthSignInBlock', () {
    testWidgets('reports what was typed', (tester) async {
      PlinthSignInValues? submitted;

      await tester.pumpWidget(_wrap(
        PlinthSignInBlock(onSubmit: (values) => submitted = values),
      ));

      await tester.enterText(find.byType(PlinthTextInput), 'name@example.com');
      await tester.enterText(find.byType(PlinthPasswordInput), 'hunter2');
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(submitted?.email, equals('name@example.com'));
      expect(submitted?.password, equals('hunter2'));
      expect(submitted?.rememberMe, isFalse);
    });

    testWidgets('remember-me travels with the submission', (tester) async {
      PlinthSignInValues? submitted;

      await tester.pumpWidget(_wrap(
        PlinthSignInBlock(onSubmit: (values) => submitted = values),
      ));

      await tester.tap(find.text('Remember me'));
      await tester.pump();
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(submitted?.rememberMe, isTrue);
    });

    testWidgets('a null onSubmit disables the button', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthSignInBlock()));

      final button = tester.widget<PlinthButton>(find.byType(PlinthButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('the forgot-password link is absent without a callback',
        (tester) async {
      await tester.pumpWidget(_wrap(const PlinthSignInBlock()));
      expect(find.text('Forgot password?'), findsNothing);

      await tester.pumpWidget(_wrap(
        PlinthSignInBlock(onForgotPassword: () {}),
      ));
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('an error renders as an alert, not as a field error',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSignInBlock(error: 'Those details did not match.'),
      ));

      // The distinction matters to a screen reader: attaching this to
      // the password field would announce the field as malformed when
      // it is the attempt that failed.
      expect(find.byType(PlinthAlert), findsOneWidget);
      expect(find.text('Those details did not match.'), findsOneWidget);
    });

    testWidgets('alternatives appear under a divider', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthSignInBlock(
          onSubmit: (_) {},
          alternatives: [
            PlinthButton(onPressed: () {}, child: const Text('SSO')),
          ],
        ),
      ));

      expect(find.byType(PlinthDivider), findsOneWidget);
      expect(find.text('SSO'), findsOneWidget);
    });

    testWidgets('no alternatives means no divider', (tester) async {
      await tester.pumpWidget(_wrap(PlinthSignInBlock(onSubmit: (_) {})));
      expect(find.byType(PlinthDivider), findsNothing);
    });
  });

  group('PlinthSignUpBlock', () {
    testWidgets('the terms checkbox gates submission', (tester) async {
      var submissions = 0;

      await tester.pumpWidget(_wrap(
        PlinthSignUpBlock(onSubmit: (_) => submissions++),
      ));

      // Disabled rather than submitting and failing: a dead button says
      // something is missing, a failing one says the app is broken.
      expect(
        tester.widget<PlinthButton>(find.byType(PlinthButton)).onPressed,
        isNull,
      );

      await tester.tap(find.text('I agree to the terms of service'));
      await tester.pump();

      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(submissions, equals(1));
    });

    testWidgets('requireTerms false lets it submit unticked', (tester) async {
      PlinthSignUpValues? submitted;

      await tester.pumpWidget(_wrap(
        PlinthSignUpBlock(
          requireTerms: false,
          onSubmit: (values) => submitted = values,
        ),
      ));

      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(submitted, isNotNull);
      expect(submitted?.acceptedTerms, isFalse);
    });

    testWidgets('hiding the terms does not leave the form unsubmittable',
        (tester) async {
      // The trap in gating on a checkbox: hide it and the gate stays
      // shut forever.
      PlinthSignUpValues? submitted;

      await tester.pumpWidget(_wrap(
        PlinthSignUpBlock(
          showTerms: false,
          onSubmit: (values) => submitted = values,
        ),
      ));

      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(submitted, isNotNull);
    });

    testWidgets('reports every field', (tester) async {
      PlinthSignUpValues? submitted;

      await tester.pumpWidget(_wrap(
        PlinthSignUpBlock(
          requireTerms: false,
          onSubmit: (values) => submitted = values,
        ),
      ));

      final fields = find.byType(PlinthTextInput);
      await tester.enterText(fields.at(0), 'Ada');
      await tester.enterText(fields.at(1), 'ada@example.com');
      await tester.enterText(find.byType(PlinthPasswordInput), 'correct-horse');
      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(submitted?.name, equals('Ada'));
      expect(submitted?.email, equals('ada@example.com'));
      expect(submitted?.password, equals('correct-horse'));
    });
  });

  group('PlinthPasswordResetBlock', () {
    testWidgets('reports the address', (tester) async {
      String? requested;

      await tester.pumpWidget(_wrap(
        PlinthPasswordResetBlock(onSubmit: (email) => requested = email),
      ));

      await tester.enterText(find.byType(PlinthTextInput), 'ada@example.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pump();

      expect(requested, equals('ada@example.com'));
    });

    testWidgets('sent swaps the form for a confirmation', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthPasswordResetBlock(sent: true, onSubmit: (_) {}),
      ));

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.byType(PlinthTextInput), findsNothing);
      expect(find.text('Send reset link'), findsNothing);
    });

    testWidgets('the confirmation does not say whether the account exists',
        (tester) async {
      // Not a style preference: confirming it turns a public reset form
      // into a way to enumerate who has registered.
      await tester.pumpWidget(_wrap(
        const PlinthPasswordResetBlock(sent: true),
      ));

      final text = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');

      expect(text, contains('If that address has an account'));
    });

    testWidgets('the way back survives into the sent state', (tester) async {
      var backs = 0;

      await tester.pumpWidget(_wrap(
        PlinthPasswordResetBlock(sent: true, onBack: () => backs++),
      ));

      await tester.tap(find.text('Back to sign in'));
      await tester.pump();

      expect(backs, equals(1));
    });
  });

  group('PlinthAuthCard', () {
    testWidgets('a null width lets it fill what it is given', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 500,
          child: PlinthAuthCard(title: 'Wide', width: null),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Wide'), findsOneWidget);
    });

    testWidgets('titleOrder is settable so the outline stays right',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthAuthCard(title: 'Nested', titleOrder: 5),
      ));

      expect(
        tester.widget<PlinthTitle>(find.byType(PlinthTitle)).order,
        equals(5),
      );
    });
  });
}
