// The top bar and the sidebar.
//
// The one that matters is the collapsed rail: the version these were
// extracted from passed an empty string as the label when collapsed,
// leaving a column of icons a screen reader announced as nothing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 800, double height = 600}) =>
    MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    );

const _sections = [
  PlinthNavSection(
    title: 'Workspace',
    items: [
      PlinthNavItem(label: 'Home', icon: Icon(Icons.home_outlined)),
      PlinthNavItem(label: 'Projects', icon: Icon(Icons.folder_outlined)),
    ],
  ),
  PlinthNavSection(
    items: [PlinthNavItem(label: 'Settings', icon: Icon(Icons.settings))],
  ),
];

void main() {
  group('PlinthTopBar', () {
    testWidgets('brand, links, centre and actions all render', (tester) async {
      await tester.pumpWidget(_wrap(
        PlinthTopBar(
          brand: const PlinthTopBarBrand(
            title: 'Dashboard',
            icon: Icon(Icons.hexagon),
          ),
          links: [PlinthAnchor('Product', onTap: () {})],
          center: PlinthTextInput(placeholder: 'Search', onChanged: (_) {}),
          actions: const [PlinthAvatar(initials: 'YL', size: PlinthSize.sm)],
        ),
      ));

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Product'), findsOneWidget);
      expect(find.byType(PlinthTextInput), findsOneWidget);
      expect(find.text('YL'), findsOneWidget);
    });

    testWidgets('the brand icon does not repeat the name', (tester) async {
      // The title beside it already says what the product is.
      await tester.pumpWidget(_wrap(
        const PlinthTopBar(
          brand: PlinthTopBarBrand(
            title: 'Dashboard',
            icon: Icon(Icons.hexagon),
          ),
        ),
      ));

      expect(find.byType(ExcludeSemantics), findsWidgets);
    });

    testWidgets('a brand with no onTap is not a button', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthTopBar(brand: PlinthTopBarBrand(title: 'Dashboard')),
      ));
      expect(find.byType(PlinthUnstyledButton), findsNothing);

      await tester.pumpWidget(_wrap(
        PlinthTopBar(
          brand: PlinthTopBarBrand(title: 'Dashboard', onTap: () {}),
        ),
      ));
      expect(find.byType(PlinthUnstyledButton), findsOneWidget);
    });

    testWidgets('links wrap rather than clipping on a phone', (tester) async {
      // Caught by the showcase's own phone-width test after this block
      // first shipped with a non-wrapping row: 18 pixels over, and what
      // a clipped top bar loses is the last link.
      await tester.pumpWidget(_wrap(
        PlinthTopBar(
          brand: const PlinthTopBarBrand(title: 'Acme'),
          links: [
            PlinthAnchor('Product', onTap: () {}),
            PlinthAnchor('Pricing', onTap: () {}),
            PlinthAnchor('About', onTap: () {}),
          ],
          actions: [
            PlinthButton(onPressed: () {}, child: const Text('Sign in')),
          ],
        ),
        width: 390,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('it survives having nothing in it', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthTopBar()));
      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthSidebar', () {
    testWidgets('sections, headings and links render', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSidebar(sections: _sections),
      ));

      expect(find.text('Workspace'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('selecting reports the value', (tester) async {
      String? selected;

      await tester.pumpWidget(_wrap(
        PlinthSidebar(
          sections: _sections,
          onSelect: (value) => selected = value,
        ),
      ));

      await tester.tap(find.text('Projects'));
      await tester.pump();

      expect(selected, equals('Projects'));
    });

    testWidgets('an item value defaults to its label', (tester) async {
      const item = PlinthNavItem(label: 'Home');
      expect(item.value, equals('Home'));

      const explicit = PlinthNavItem(label: 'Home', value: 'home');
      expect(explicit.value, equals('home'));
    });

    testWidgets('collapsed, the rail narrows rather than disappearing',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSidebar(sections: _sections, collapsed: true),
      ));
      await tester.pumpAndSettle();

      // The text is gone from the screen.
      expect(find.text('Home'), findsNothing);
      // The icons are not.
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('collapsed, every destination keeps its name', (tester) async {
      // The defect this block was extracted to fix. Visible only to a
      // pair of eyes is not the same as reachable.
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(
        const PlinthSidebar(sections: _sections, collapsed: true),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('Projects'), findsOneWidget);
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('the search box is hidden when collapsed', (tester) async {
      // A 64px rail has nowhere to type.
      await tester.pumpWidget(_wrap(
        PlinthSidebar(
          sections: _sections,
          collapsed: true,
          search: PlinthTextInput(placeholder: 'Filter', onChanged: (_) {}),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(PlinthTextInput), findsNothing);
    });

    testWidgets('a toggle appears only when it can do something',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSidebar(sections: _sections),
      ));
      expect(find.byType(PlinthBurger), findsNothing);

      await tester.pumpWidget(_wrap(
        PlinthSidebar(sections: _sections, onToggleCollapsed: () {}),
      ));
      expect(find.byType(PlinthBurger), findsOneWidget);
    });

    testWidgets('sub-levels render under their parent', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSidebar(
          openValues: {'Projects'},
          sections: [
            PlinthNavSection(items: [
              PlinthNavItem(
                label: 'Projects',
                children: [PlinthNavItem(label: 'Archived')],
              ),
            ]),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Archived'), findsOneWidget);
    });

    testWidgets('a footer sits at the bottom', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthSidebar(
          sections: _sections,
          footer: Text('Yair Lahav'),
        ),
      ));

      expect(
        tester.getCenter(find.text('Yair Lahav')).dy,
        greaterThan(tester.getCenter(find.text('Settings')).dy),
      );
    });

    testWidgets('no sections is not a crash', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthSidebar(sections: [])));
      expect(tester.takeException(), isNull);
    });
  });
}
