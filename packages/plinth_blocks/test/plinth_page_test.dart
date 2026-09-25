/// A whole screen, and the leading slot its header was missing.
///
/// Found while converting an existing app onto Plinth, where
/// `PlinthPageHeader` gave the header and the app still owned the
/// Scaffold, the SafeArea, the back button and the Expanded that lets a
/// ListView work.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

const _notch = EdgeInsets.only(top: 47, bottom: 34);
const _back = Key('back');

Future<void> _pump(
  WidgetTester tester,
  Widget page, {
  TextDirection direction = TextDirection.ltr,
  EdgeInsets viewPadding = EdgeInsets.zero,
}) =>
    tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(padding: viewPadding),
        child: Directionality(textDirection: direction, child: child!),
      ),
      home: page,
    ));

PlinthPage _page({
  Widget? leading,
  Widget? body,
  List<Widget> actions = const [],
  bool scrollableBody = false,
}) =>
    PlinthPage(
      title: 'Program',
      subtitle: 'Good morning',
      leading: leading,
      actions: actions,
      scrollableBody: scrollableBody,
      body: body ?? const SizedBox.expand(),
    );

void main() {
  group('the shell', () {
    testWidgets(
        'renders title, subtitle and body without a Scaffold from '
        'the caller', (tester) async {
      await _pump(tester, _page(body: const Text('rows')));

      expect(find.text('Program'), findsOneWidget);
      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('rows'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget,
          reason: 'the page owns it, so the caller does not');
    });

    testWidgets('no Material AppBar', (tester) async {
      await _pump(tester, _page());
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('the background is surfaceMuted', (tester) async {
      await _pump(tester, _page());
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, PlinthTheme.defaultTheme.surfaceMuted);
    });

    testWidgets('content clears the notch', (tester) async {
      await _pump(tester, _page(), viewPadding: _notch);
      expect(tester.getRect(find.text('Program')).top,
          greaterThanOrEqualTo(_notch.top));
    });
  });

  group('the body gets the remaining height', () {
    testWidgets('a plain ListView works, unbounded', (tester) async {
      await _pump(
        tester,
        _page(
          body: ListView(
            children: List.generate(60, (i) => Text('row $i')),
          ),
        ),
      );

      expect(tester.takeException(), isNull,
          reason: 'an unbounded-height ListView is the whole point');
      expect(find.text('row 0'), findsOneWidget);
    });

    testWidgets('and it scrolls', (tester) async {
      await _pump(
        tester,
        _page(
          body: ListView(children: List.generate(60, (i) => Text('row $i'))),
        ),
      );
      await tester.drag(find.text('row 0'), const Offset(0, -400));
      await tester.pump();
      expect(find.text('row 0'), findsNothing);
    });

    testWidgets('scrollableBody wraps a non-scrolling body instead',
        (tester) async {
      await _pump(
        tester,
        _page(
          scrollableBody: true,
          body: Column(children: List.generate(40, (i) => Text('line $i'))),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('leading', () {
    testWidgets('sits before the title', (tester) async {
      await _pump(
          tester, _page(leading: const Icon(Icons.arrow_back, key: _back)));

      expect(tester.getRect(find.byKey(_back)).left,
          lessThan(tester.getRect(find.text('Program')).left));
    });

    testWidgets('and after it in RTL, with no work from the caller',
        (tester) async {
      await _pump(
        tester,
        _page(leading: const Icon(Icons.arrow_back, key: _back)),
        direction: TextDirection.rtl,
      );

      expect(tester.getRect(find.byKey(_back)).left,
          greaterThan(tester.getRect(find.text('Program')).left),
          reason: 'start side means right in RTL');
    });

    testWidgets('a leading button keeps its own semantics node',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _page(
          leading: PlinthActionIcon(
            icon: const Icon(Icons.arrow_back),
            semanticLabel: 'Back',
            onPressed: () {},
          ),
        ),
      );

      // Merged into the heading it would stop being its own control.
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('it coexists with actions on the other side', (tester) async {
      await _pump(
        tester,
        _page(
          leading: const Icon(Icons.arrow_back, key: _back),
          actions: const [Icon(Icons.language, key: Key('lang'))],
        ),
      );

      final back = tester.getRect(find.byKey(_back));
      final lang = tester.getRect(find.byKey(const Key('lang')));
      expect(back.left, lessThan(lang.left));
      expect(find.text('Program'), findsOneWidget);
    });
  });

  testWidgets('the title is still a real heading at order 2', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, _page());

    final node = tester.getSemantics(find.text('Program'));
    expect(node.flagsCollection.isHeader, isTrue,
        reason: 'a page whose title is not a heading has no outline');
    handle.dispose();
  });

  testWidgets('below sits under the header and outside the scroll',
      (tester) async {
    await _pump(
      tester,
      PlinthPage(
        title: 'Program',
        below: const Text('filters', key: Key('filters')),
        body: ListView(children: List.generate(60, (i) => Text('row $i'))),
      ),
    );

    final filters = tester.getRect(find.byKey(const Key('filters')));
    await tester.drag(find.text('row 0'), const Offset(0, -400));
    await tester.pump();

    expect(tester.getRect(find.byKey(const Key('filters'))), filters,
        reason: 'it does not scroll away with the body');
  });
}
