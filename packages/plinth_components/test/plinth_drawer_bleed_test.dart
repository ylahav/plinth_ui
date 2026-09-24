/// A full-screen sheet whose content reaches the edges of it.
///
/// `extent: double.infinity` made the panel fill the screen, and that
/// turned out to be half of what a covering sheet needs: the drawer
/// still wrapped its child in `SafeArea` and `lg` padding, so content
/// meant to bleed started 20px in and, on a notched phone, 67px down.
///
/// Found by putting a photo header inside the sheet shipped for it in
/// 1.6.0 — the two features did not compose, which neither of their own
/// tests could see.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// An iPhone-shaped inset: status bar above, home indicator below.
const _notch = EdgeInsets.only(top: 47, bottom: 34);

const _marker = Key('sheet-content');

Future<void> _show(
  WidgetTester tester, {
  EdgeInsetsGeometry? contentPadding,
  bool useSafeArea = true,
  EdgeInsets viewPadding = EdgeInsets.zero,
  String? title,
}) async {
  final drawer = PlinthDrawer(
    controller: PlinthDisclosureController(),
    position: PlinthDrawerPosition.bottom,
    extent: double.infinity,
    contentPadding: contentPadding,
    useSafeArea: useSafeArea,
    title: title,
    child: const SizedBox.expand(key: _marker),
  );

  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(padding: viewPadding),
      child: child!,
    ),
    home: Scaffold(
      body: Builder(
        builder: (context) => PlinthButton(
          onPressed: () => drawer.show(context),
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Rect _content(WidgetTester tester) => tester.getRect(find.byKey(_marker));

void main() {
  group('the default is unchanged', () {
    testWidgets('content is still inset by lg on a plain screen',
        (tester) async {
      await _show(tester);
      final screen = tester.getSize(find.byType(MaterialApp));
      final rect = _content(tester);
      expect(rect.left, 20, reason: 'lg padding, as before');
      expect(rect.width, screen.width - 40);
    });

    testWidgets('and a notch still pushes it clear', (tester) async {
      await _show(tester, viewPadding: _notch);
      expect(_content(tester).top, 47 + 20,
          reason: 'SafeArea then lg padding, as before');
    });
  });

  group('a bleeding sheet', () {
    testWidgets('reaches the left and right edges', (tester) async {
      await _show(tester, contentPadding: EdgeInsets.zero, useSafeArea: false);
      final screen = tester.getSize(find.byType(MaterialApp));
      final rect = _content(tester);
      expect(rect.left, 0);
      expect(rect.width, screen.width);
    });

    testWidgets('runs under the status bar and the home indicator',
        (tester) async {
      await _show(tester,
          contentPadding: EdgeInsets.zero,
          useSafeArea: false,
          viewPadding: _notch);
      final screen = tester.getSize(find.byType(MaterialApp));
      final rect = _content(tester);
      expect(rect.top, 0,
          reason: 'the whole point: no band of surface above the photo');
      expect(rect.bottom, screen.height);
    });
  });

  group('the two knobs are independent', () {
    testWidgets('padding alone keeps the safe area', (tester) async {
      await _show(tester, contentPadding: EdgeInsets.zero, viewPadding: _notch);
      expect(_content(tester).top, 47);
      expect(_content(tester).left, 0);
    });

    testWidgets('dropping the safe area alone keeps the padding',
        (tester) async {
      await _show(tester, useSafeArea: false, viewPadding: _notch);
      expect(_content(tester).top, 20);
    });
  });

  testWidgets('a title still renders when content bleeds', (tester) async {
    await _show(tester,
        contentPadding: EdgeInsets.zero, useSafeArea: false, title: 'Scene');
    expect(find.text('Scene'), findsOneWidget);
  });
}
