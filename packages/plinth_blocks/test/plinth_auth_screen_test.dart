/// The sign-in shell and its accent bar.
///
/// Found while converting an existing app onto Plinth, where login and
/// boot were each a raw `Scaffold` with the same 8px strip at the top.
///
/// The interesting requirement is the one the report did not state:
/// where the strip sits relative to the status bar. An 8px bar painted
/// at the physical top edge is hidden under the notch; painted below
/// the inset it floats under a band of background. It extends through
/// the inset instead, which is the only version that cannot look
/// broken.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

const _notch = EdgeInsets.only(top: 47, bottom: 34);
const _content = Key('content');

Future<void> _pump(
  WidgetTester tester, {
  String? accentColor = 'green',
  double accentHeight = 8,
  double? maxWidth = 420,
  EdgeInsets viewPadding = EdgeInsets.zero,
  Widget child = const SizedBox(key: _content, height: 100, width: 100),
}) =>
    tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      builder: (context, inner) => MediaQuery(
        data: MediaQuery.of(context).copyWith(padding: viewPadding),
        child: inner!,
      ),
      home: PlinthAuthScreen(
        accentColor: accentColor,
        accentHeight: accentHeight,
        maxWidth: maxWidth,
        child: child,
      ),
    ));

Rect _bar(WidgetTester tester) => tester.getRect(find.byType(PlinthAccentBar));

void main() {
  group('PlinthAccentBar on its own', () {
    testWidgets('takes a theme colour at shade 6, full width', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: const Scaffold(
          body: Column(children: [PlinthAccentBar(color: 'green')]),
        ),
      ));

      final box = tester.widget<ColoredBox>(find.descendant(
          of: find.byType(PlinthAccentBar), matching: find.byType(ColoredBox)));
      expect(box.color, PlinthTheme.defaultTheme.shaded('green', 6));

      final rect = tester.getRect(find.byType(PlinthAccentBar));
      expect(rect.height, 8);
      expect(rect.width, tester.getSize(find.byType(MaterialApp)).width);
    });

    testWidgets('knows nothing about safe areas', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: _notch),
          child: child!,
        ),
        home: const Scaffold(
          body: Column(children: [PlinthAccentBar(color: 'green')]),
        ),
      ));

      expect(tester.getRect(find.byType(PlinthAccentBar)).height, 8,
          reason: 'the screen decides insets, not the bar');
    });

    testWidgets('no colour takes the primary', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: const Scaffold(body: Column(children: [PlinthAccentBar()])),
      ));

      final theme = PlinthTheme.defaultTheme;
      final box = tester.widget<ColoredBox>(find.descendant(
          of: find.byType(PlinthAccentBar), matching: find.byType(ColoredBox)));
      expect(box.color, theme.shaded(theme.primaryColor, 6));
    });
  });

  group('the screen', () {
    testWidgets('the bar starts at the physical top edge', (tester) async {
      await _pump(tester, viewPadding: _notch);
      expect(_bar(tester).top, 0,
          reason: 'no band of background above the accent');
    });

    testWidgets('and extends through the status bar inset', (tester) async {
      await _pump(tester, viewPadding: _notch);
      expect(_bar(tester).height, 47 + 8,
          reason: 'so the strip reads as 8px below the status bar');
    });

    testWidgets('with no inset it is exactly the height asked for',
        (tester) async {
      await _pump(tester);
      expect(_bar(tester).height, 8);
    });

    testWidgets('a custom height is respected', (tester) async {
      await _pump(tester, accentHeight: 20, viewPadding: _notch);
      expect(_bar(tester).height, 47 + 20);
    });

    testWidgets('content sits below the bar, not under it', (tester) async {
      await _pump(tester, viewPadding: _notch);
      expect(tester.getRect(find.byKey(_content)).top,
          greaterThanOrEqualTo(_bar(tester).bottom));
    });

    testWidgets('the top inset is not taken twice', (tester) async {
      await _pump(tester, viewPadding: _notch);
      final content = tester.getRect(find.byKey(_content));
      final screen = tester.getSize(find.byType(MaterialApp));

      // Centred in what is left below the bar. Taking SafeArea's top a
      // second time would push it down by another 47.
      final available = screen.height - _bar(tester).height - _notch.bottom;
      final expected = _bar(tester).height + (available - content.height) / 2;
      expect(content.top, closeTo(expected, 1));
    });

    testWidgets('content is centred and width-capped', (tester) async {
      await _pump(
        tester,
        child: const SizedBox(key: _content, height: 100, width: 2000),
      );
      expect(tester.getRect(find.byKey(_content)).width, lessThanOrEqualTo(420),
          reason: 'a sign-in form should not stretch across a desktop window');
    });

    testWidgets('maxWidth null removes the cap', (tester) async {
      await _pump(
        tester,
        maxWidth: null,
        child: const SizedBox(key: _content, height: 100, width: 2000),
      );
      expect(tester.getRect(find.byKey(_content)).width, greaterThan(420));
    });

    testWidgets('a loader is a valid child — that is the boot screen',
        (tester) async {
      await _pump(tester, child: const PlinthLoader());
      expect(find.byType(PlinthLoader), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tall content scrolls rather than overflowing', (tester) async {
      await _pump(
        tester,
        child: const SizedBox(key: _content, height: 4000, width: 100),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('it knows nothing about authentication', (tester) async {
      await _pump(tester);
      expect(find.byType(PlinthAuthCard), findsNothing,
          reason: 'the card is the form; this is only the page');
    });
  });
}
