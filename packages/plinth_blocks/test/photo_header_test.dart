/// The detail-page header, from a gap somebody else reported.
///
/// They wanted a photograph edge to edge with a close button over it,
/// found the parts but not the arrangement, and built it from their own
/// photo widget and a `PlinthActionIcon`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

final _photo = Container(key: const ValueKey('photo'), color: Colors.teal);

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('takes any image widget, not a URL', (tester) async {
    // `PlinthBackgroundImage` takes a String and calls Image.network,
    // which is why the reporter had their own photo widget at all.
    await tester.pumpWidget(_wrap(PlinthPhotoHeader(image: _photo)));
    expect(find.byKey(const ValueKey('photo')), findsOneWidget);
  });

  testWidgets('renders a title and subtitle over the photograph',
      (tester) async {
    await tester.pumpWidget(_wrap(PlinthPhotoHeader(
      image: _photo,
      title: 'Kitchen at dusk',
      subtitle: '12 devices',
    )));
    expect(find.text('Kitchen at dusk'), findsOneWidget);
    expect(find.text('12 devices'), findsOneWidget);
  });

  testWidgets('the title keeps its heading semantics', (tester) async {
    // A plain Text styled to look like a heading is not a heading. The
    // colour is passed through DefaultTextStyle precisely so PlinthTitle
    // can still be used here.
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(PlinthPhotoHeader(
      image: _photo,
      title: 'Kitchen at dusk',
      titleOrder: 2,
    )));

    final node = tester.getSemantics(find.text('Kitchen at dusk'));
    expect(node.headingLevel, 2);
    handle.dispose();
  });

  testWidgets('the photograph is decorative unless labelled', (tester) async {
    // Most detail-page photos repeat what the title says, and "image"
    // announced over and over is noise.
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(PlinthPhotoHeader(image: _photo)));
    expect(find.bySemanticsLabel('A dim kitchen'), findsNothing);

    await tester.pumpWidget(_wrap(PlinthPhotoHeader(
      image: _photo,
      imageLabel: 'A dim kitchen',
    )));
    expect(find.bySemanticsLabel('A dim kitchen'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('no close button unless it can do something', (tester) async {
    await tester.pumpWidget(_wrap(PlinthPhotoHeader(image: _photo)));
    expect(find.byType(PlinthActionIcon), findsNothing);

    var closed = 0;
    await tester.pumpWidget(_wrap(PlinthPhotoHeader(
      image: _photo,
      onClose: () => closed++,
    )));
    await tester.tap(find.byType(PlinthActionIcon));
    await tester.pumpAndSettle();
    expect(closed, 1);
  });

  testWidgets('the close button is named through the i18n seam',
      (tester) async {
    // Not a hardcoded 'Close'. Twenty-one of those were fixed in
    // components 1.5.0 and this is not the twenty-second.
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      localizationsDelegates: [
        PlinthLocalizations.override(
          const PlinthStrings(closeDialog: 'Cerrar'),
        ),
      ],
      home: Scaffold(
        body: PlinthPhotoHeader(image: _photo, onClose: () {}),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Cerrar'), findsOneWidget);
  });

  testWidgets('and overridden where "close" is ambiguous', (tester) async {
    await tester.pumpWidget(_wrap(PlinthPhotoHeader(
      image: _photo,
      onClose: () {},
      closeLabel: 'Back to scenes',
    )));
    expect(find.bySemanticsLabel('Back to scenes'), findsOneWidget);
  });

  testWidgets('controls take the safe area and the photograph does not',
      (tester) async {
    // Edge to edge is the point of the photograph; a close button under
    // a notch is the point of nothing.
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(top: 60),
        ),
        child: Scaffold(
          body: PlinthPhotoHeader(image: _photo, onClose: () {}),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final photoTop = tester.getTopLeft(find.byKey(const ValueKey('photo'))).dy;
    final buttonTop = tester.getTopLeft(find.byType(PlinthActionIcon)).dy;

    expect(photoTop, 0, reason: 'the photograph was inset');
    expect(buttonTop, greaterThanOrEqualTo(60),
        reason: 'the close button is under the notch');
  });
}
