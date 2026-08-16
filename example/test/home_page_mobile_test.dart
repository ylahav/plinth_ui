import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:plinth_example/main.dart';

/// The home page at phone width.
///
/// It shipped with a fixed three-column grid of subcategory tiles,
/// which on a 390px phone left each title about 40 logical pixels of
/// room — enough to wrap "Navbars" to one letter per line, seven rows
/// tall. Nothing threw, so no existing test noticed; these assert the
/// arrangement rather than the absence of exceptions.
void main() {
  /// Sizes the test view to a phone. 390x844 is an iPhone 14 in
  /// logical pixels, the narrow end of what the deployed web build
  /// actually gets opened on.
  void usePhoneView(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('subcategory titles stay on one line at phone width',
      (tester) async {
    usePhoneView(tester);
    await tester.pumpWidget(const PlinthExampleApp());

    // A single line of body text is around 20px tall; the broken
    // layout rendered these at seven or eight times that.
    for (final title in ['Navbars', 'Headers', 'Hero Sections']) {
      expect(
        tester.getSize(find.text(title)).height,
        lessThan(40),
        reason: '$title wrapped to more than one line',
      );
    }
  });

  testWidgets('the tiles stack to a single column at phone width',
      (tester) async {
    usePhoneView(tester);
    await tester.pumpWidget(const PlinthExampleApp());

    // Two tiles side by side on a phone is the layout this replaced,
    // so assert the width rather than only the text height: a tile
    // taking most of the viewport can only be one per row.
    expect(
      tester
          .getSize(find.ancestor(
            of: find.text('Navbars'),
            matching: find.byType(PlinthPaper),
          ))
          .width,
      greaterThan(300),
    );
  });

  testWidgets('nothing overflows at phone width', (tester) async {
    usePhoneView(tester);
    await tester.pumpWidget(const PlinthExampleApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the gallery button keeps its label on a wide view',
      (tester) async {
    // The action collapses to an icon on a phone, so guard the wide
    // case too — dropping the label everywhere would also pass the
    // tests above.
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PlinthExampleApp());

    expect(find.text('Component gallery'), findsOneWidget);
  });
}
