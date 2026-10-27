import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(PlinthAppBar bar, {List<LocalizationsDelegate>? delegates}) =>
    MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      localizationsDelegates: [...?delegates],
      home: Scaffold(appBar: bar, body: const SizedBox()),
    );

/// A page pushed over another, so there is something to go back to.
Future<void> _pushed(WidgetTester tester, PlinthAppBar bar) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => Scaffold(appBar: bar, body: const Text('page two')),
        )),
        child: const Text('open'),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('PlinthAppBar', () {
    testWidgets('shows the title and is the height it says', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAppBar(title: 'Statistics')));

      expect(find.text('Statistics'), findsOneWidget);
      expect(tester.getSize(find.byType(PlinthAppBar)).height, 56);
    });

    testWidgets('a custom height is used', (tester) async {
      await tester
          .pumpWidget(_wrap(const PlinthAppBar(title: 'x', height: 50)));

      expect(tester.getSize(find.byType(PlinthAppBar)).height, 50);
    });

    testWidgets('no back button on the first page', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAppBar(title: 'Home')));

      expect(find.byType(PlinthActionIcon), findsNothing);
    });

    testWidgets('a pushed page gets a back button that goes back',
        (tester) async {
      await _pushed(tester, const PlinthAppBar(title: 'Two'));

      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.text('page two'), findsNothing);
    });

    testWidgets('automaticallyImplyLeading: false leaves it out',
        (tester) async {
      await _pushed(
        tester,
        const PlinthAppBar(title: 'Two', automaticallyImplyLeading: false),
      );

      expect(find.byType(PlinthActionIcon), findsNothing);
    });

    testWidgets('leading replaces the back button', (tester) async {
      await _pushed(
        tester,
        const PlinthAppBar(title: 'Two', leading: Icon(Icons.menu)),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('the back label can be translated', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        localizationsDelegates: [
          PlinthLocalizations.override(const PlinthStrings(back: 'Atrás')),
        ],
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const Scaffold(
                appBar: PlinthAppBar(title: 'Two'),
              ),
            )),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Atrás'), findsOneWidget);
    });

    testWidgets('actions sit at the end, in order', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAppBar(
        title: 'x',
        actions: [Text('one'), Text('two')],
      )));

      final one = tester.getTopLeft(find.text('one')).dx;
      final two = tester.getTopLeft(find.text('two')).dx;
      expect(one, lessThan(two));
      expect(
          tester.getTopRight(find.text('two')).dx,
          lessThanOrEqualTo(
              tester.view.physicalSize.width / tester.view.devicePixelRatio));
    });

    testWidgets('a long title is cut rather than overflowing', (tester) async {
      await tester.pumpWidget(_wrap(PlinthAppBar(
        title: 'A very long title ' * 20,
        actions: const [Text('act')],
      )));

      expect(tester.takeException(), isNull);
    });

    testWidgets('titleWidget is drawn in place of the title', (tester) async {
      await tester
          .pumpWidget(_wrap(const PlinthAppBar(titleWidget: Text('custom'))));

      expect(find.text('custom'), findsOneWidget);
    });

    test('title and titleWidget together are rejected', () {
      expect(
        () => PlinthAppBar(title: 'a', titleWidget: const SizedBox()),
        throwsAssertionError,
      );
    });
  });
}
