import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:plinth_example/main.dart';
import 'package:plinth_example/src/showcase/category_detail_page.dart';
import 'package:plinth_example/src/showcase/showcase_data.dart';

/// Every page of the example app at phone width.
///
/// The showcase smoke test pumps blocks into a 1400x2000 viewport,
/// which is the right call for asserting a block builds — but it meant
/// nothing in the app was ever laid out at a size someone might open
/// it on. All 24 detail pages and the component tour overflowed on a
/// phone, and the deployed site is a URL people open on one.
///
/// [HomePage] has its own file: its failure was a wrapped title rather
/// than an exception, so it needs different assertions.
void main() {
  /// An iPhone 14 in logical pixels — the narrow end of what the
  /// deployed web build gets opened on.
  void usePhoneView(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  group('CategoryDetailPage', () {
    for (final category in showcaseCategories) {
      for (final subcategory in category.subcategories) {
        testWidgets('${category.title} / ${subcategory.title} fits a phone',
            (tester) async {
          usePhoneView(tester);

          // The page directly rather than through a tap: reaching a
          // subcategory means scrolling a one-column list of 24 tiles,
          // and ThemeSwitcher is the only thing the page needs from
          // the app above it.
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
            home: ThemeSwitcher(
              mode: ThemeMode.light,
              onChanged: (_) {},
              child: CategoryDetailPage(
                category: category,
                subcategory: subcategory,
              ),
            ),
          ));
          await tester.pump();

          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  testWidgets('the component tour fits a phone', (tester) async {
    usePhoneView(tester);

    await tester.pumpWidget(const PlinthExampleApp());
    // The action collapses to an icon at this width, so it is found by
    // tooltip rather than by label.
    await tester.tap(find.byTooltip('Component gallery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The tour builds every section up front rather than virtualizing,
    // so one pump lays out all 111 of them.
    expect(tester.takeException(), isNull);
  });
}
