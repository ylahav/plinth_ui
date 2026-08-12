import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_example/main.dart';
import 'package:plinth_example/src/showcase/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('renders every top-level category title', (tester) async {
      await tester.pumpWidget(const PlinthExampleApp());

      expect(find.text('Application UI'), findsOneWidget);
      expect(find.text('Page Sections'), findsOneWidget);
      expect(find.text('Blog UI'), findsOneWidget);
    });

    testWidgets('renders a subcategory box for each subcategory',
        (tester) async {
      await tester.pumpWidget(const PlinthExampleApp());

      expect(find.text('Navbars'), findsOneWidget);
      expect(find.text('Headers'), findsOneWidget);
      expect(find.text('Hero Sections'), findsOneWidget);
    });

    testWidgets('tapping a subcategory box navigates to its detail page',
        (tester) async {
      await tester.pumpWidget(const PlinthExampleApp());

      await tester.tap(find.text('Navbars'));
      await tester.pumpAndSettle();

      // The detail page shows its own example titles, which don't
      // appear on the home page itself.
      expect(find.text('Simple navbar'), findsOneWidget);
      expect(find.text('Navbar with avatar'), findsOneWidget);
    });

    testWidgets('the component gallery button navigates to ShowcasePage',
        (tester) async {
      await tester.pumpWidget(const PlinthExampleApp());

      await tester.tap(find.text('Component gallery'));
      await tester.pumpAndSettle();

      expect(find.text('Plinth UI — Component Showcase'), findsOneWidget);
    });
  });

  group('CategoryDetailPage', () {
    testWidgets('the Home breadcrumb navigates back to HomePage',
        (tester) async {
      await tester.pumpWidget(const PlinthExampleApp());

      await tester.tap(find.text('Navbars'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Show code reveals the example source, Hide code collapses it',
        (tester) async {
      await tester.pumpWidget(const PlinthExampleApp());

      await tester.tap(find.text('Navbars'));
      await tester.pumpAndSettle();

      // Not visible before toggling.
      expect(find.textContaining('PlinthPaper('), findsNothing);

      await tester.tap(find.text('Show code').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('PlinthPaper('), findsWidgets);
      expect(find.text('Hide code'), findsOneWidget);

      await tester.tap(find.text('Hide code'));
      await tester.pumpAndSettle();

      expect(find.textContaining('PlinthPaper('), findsNothing);
    });
  });
}
