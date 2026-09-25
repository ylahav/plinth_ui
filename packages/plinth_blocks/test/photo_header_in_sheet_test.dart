/// A photo header inside a full-screen sheet — the screen that started
/// both features.
///
/// `PlinthDrawer.extent` and `PlinthPhotoHeader` shipped together in
/// 1.6.0 and did not compose: the drawer's `SafeArea` and `lg` padding
/// pushed the photograph off the edges it exists to reach. This pins
/// the combination rather than either piece.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

const _notch = EdgeInsets.only(top: 47, bottom: 34);
const _photo = Key('photo');

Future<Size> _openScene(WidgetTester tester) async {
  final drawer = PlinthDrawer(
    controller: PlinthDisclosureController(),
    position: PlinthDrawerPosition.bottom,
    extent: double.infinity,
    contentPadding: EdgeInsets.zero,
    useSafeArea: false,
    child: PlinthPhotoHeader(
      image: const ColoredBox(key: _photo, color: Colors.teal),
      title: 'Scene',
      onClose: () {},
    ),
  );

  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(padding: _notch),
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
  return tester.getSize(find.byType(MaterialApp));
}

void main() {
  testWidgets('the photograph runs to the top and both edges', (tester) async {
    final screen = await _openScene(tester);
    final photo = tester.getRect(find.byKey(_photo));

    expect(photo.top, 0, reason: 'under the status bar, not below it');
    expect(photo.left, 0);
    expect(photo.width, screen.width);
  });

  testWidgets('while the close button stays inside the safe area',
      (tester) async {
    await _openScene(tester);
    final close = tester.getRect(find.byType(PlinthActionIcon).first);

    expect(close.top, greaterThanOrEqualTo(_notch.top),
        reason: 'the photo bleeds; its controls must not');
  });
}
