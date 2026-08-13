import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

const _nodes = [
  PlinthTreeNode(
    value: 'src',
    label: 'src',
    children: [
      PlinthTreeNode(
        value: 'widgets',
        label: 'widgets',
        children: [PlinthTreeNode(value: 'button', label: 'button.dart')],
      ),
      PlinthTreeNode(value: 'main', label: 'main.dart'),
    ],
  ),
  PlinthTreeNode(value: 'test', label: 'test'),
];

void main() {
  group('PlinthTree', () {
    testWidgets('shows only what the expansion opens', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTree(nodes: _nodes, expanded: {})),
      );

      expect(find.text('src'), findsOneWidget);
      expect(find.text('test'), findsOneWidget);
      expect(find.text('widgets'), findsNothing);

      await tester.pumpWidget(
        _wrap(const PlinthTree(nodes: _nodes, expanded: {'src'})),
      );

      expect(find.text('widgets'), findsOneWidget);
      expect(find.text('main.dart'), findsOneWidget);
      // Still shut one level further down.
      expect(find.text('button.dart'), findsNothing);
    });

    testWidgets('tapping a branch reports the expansion it would become', (
      tester,
    ) async {
      Set<String>? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthTree(
            nodes: _nodes,
            expanded: const {},
            onExpandedChanged: (e) => reported = e,
          ),
        ),
      );

      await tester.tap(find.text('src'));
      await tester.pump();

      // Controlled: it reports, it doesn't open itself.
      expect(reported, {'src'});
      expect(find.text('widgets'), findsNothing);
    });

    testWidgets('tapping an open branch reports closing it', (tester) async {
      Set<String>? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthTree(
            nodes: _nodes,
            expanded: const {'src'},
            onExpandedChanged: (e) => reported = e,
          ),
        ),
      );

      await tester.tap(find.text('src'));
      await tester.pump();

      expect(reported, isEmpty);
    });

    testWidgets('selection is reported for leaves and branches alike', (
      tester,
    ) async {
      final selected = <String>[];
      await tester.pumpWidget(
        _wrap(
          PlinthTree(
            nodes: _nodes,
            expanded: const {'src'},
            onSelected: selected.add,
          ),
        ),
      );

      await tester.tap(find.text('main.dart'));
      await tester.tap(find.text('src'));
      await tester.pump();

      expect(selected, ['main', 'src']);
    });

    testWidgets('branches announce their expanded state, leaves do not', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PlinthTree(nodes: _nodes, expanded: {'src'})),
      );

      final branch = tester.getSemantics(find.text('src')).flagsCollection;
      expect(branch.isExpanded, Tristate.isTrue);

      // `none` is the whole point: not "collapsed", but "expanding
      // doesn't apply here". A leaf announcing "collapsed" would be
      // claiming it opens.
      final leaf = tester.getSemantics(find.text('main.dart')).flagsCollection;
      expect(leaf.isExpanded, Tristate.none);
    });

    testWidgets('a null onExpandedChanged leaves branches fixed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PlinthTree(nodes: _nodes, expanded: {})),
      );

      await tester.tap(find.text('src'));
      await tester.pump();

      expect(find.text('widgets'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthTreeSelect', () {
    testWidgets('shows the placeholder, then the selected label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PlinthTreeSelect(nodes: _nodes, value: null, onChanged: (_) {}),
        ),
      );
      expect(find.text('Select…'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          PlinthTreeSelect(nodes: _nodes, value: 'button', onChanged: (_) {}),
        ),
      );
      expect(find.text('button.dart'), findsOneWidget);
    });

    testWidgets('opening expands the branches down to the current value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PlinthTreeSelect(nodes: _nodes, value: 'button', onChanged: (_) {}),
        ),
      );

      await tester.tap(find.text('button.dart'));
      await tester.pumpAndSettle();

      // A selection three levels down has to be visible when you open
      // the thing that claims to be showing it.
      expect(find.text('widgets'), findsOneWidget);
      expect(find.text('button.dart'), findsNWidgets(2));
    });

    testWidgets('choosing a leaf reports it and closes', (tester) async {
      String? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthTreeSelect(
            nodes: _nodes,
            value: null,
            onChanged: (v) => reported = v,
          ),
        ),
      );

      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();

      expect(reported, 'test');
      expect(find.byType(PlinthTree), findsNothing);
    });

    testWidgets('selectableBranches: false only opens branches', (
      tester,
    ) async {
      String? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthTreeSelect(
            nodes: _nodes,
            value: null,
            selectableBranches: false,
            onChanged: (v) => reported = v,
          ),
        ),
      );

      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('src'));
      await tester.pumpAndSettle();

      expect(reported, isNull);
      // Opened rather than chosen, and still open.
      expect(find.text('main.dart'), findsOneWidget);
    });
  });

  group('PlinthCascader', () {
    const options = [
      PlinthCascaderOption(
        value: 'eu',
        label: 'Europe',
        children: [
          PlinthCascaderOption(
            value: 'fr',
            label: 'France',
            children: [PlinthCascaderOption(value: 'paris', label: 'Paris')],
          ),
        ],
      ),
      PlinthCascaderOption(value: 'as', label: 'Asia'),
    ];

    testWidgets('opens one column per chosen level', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthCascader(
            options: options,
            value: [],
            onChanged: null,
          ),
        ),
      );
      expect(find.text('France'), findsNothing);

      await tester.pumpWidget(
        _wrap(
          const PlinthCascader(
            options: options,
            value: ['eu'],
            onChanged: null,
          ),
        ),
      );
      expect(find.text('France'), findsOneWidget);
      expect(find.text('Paris'), findsNothing);

      await tester.pumpWidget(
        _wrap(
          const PlinthCascader(
            options: options,
            value: ['eu', 'fr'],
            onChanged: null,
          ),
        ),
      );
      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('choosing a shallower level truncates the path', (
      tester,
    ) async {
      List<String>? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthCascader(
            options: options,
            value: const ['eu', 'fr', 'paris'],
            onChanged: (p) => reported = p,
          ),
        ),
      );

      await tester.tap(find.text('Asia'));
      await tester.pump();

      // Everything right of the level that changed is unreachable now.
      expect(reported, ['as']);
    });

    testWidgets('reports the path, not just the leaf', (tester) async {
      List<String>? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthCascader(
            options: options,
            value: const ['eu', 'fr'],
            onChanged: (p) => reported = p,
          ),
        ),
      );

      await tester.tap(find.text('Paris'));
      await tester.pump();

      expect(reported, ['eu', 'fr', 'paris']);
    });

    testWidgets('a null onChanged makes it read-only', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthCascader(options: options, value: [], onChanged: null),
        ),
      );

      await tester.tap(find.text('Asia'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('PlinthTableOfContents', () {
    const items = [
      PlinthTocItem(label: 'Introduction'),
      PlinthTocItem(label: 'Installing', order: 2),
      PlinthTocItem(label: 'From pub.dev', order: 3),
    ];

    testWidgets('renders every heading', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTableOfContents(items: items)),
      );

      expect(find.text('Introduction'), findsOneWidget);
      expect(find.text('From pub.dev'), findsOneWidget);
    });

    testWidgets('indents by heading level, relative to the shallowest', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PlinthTableOfContents(items: items)),
      );

      final first = tester.getRect(find.text('Introduction')).left;
      final second = tester.getRect(find.text('Installing')).left;
      final third = tester.getRect(find.text('From pub.dev')).left;

      expect(second, greaterThan(first));
      expect(third, greaterThan(second));
    });

    testWidgets('a document starting at level 2 is not left indented', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTableOfContents(
            items: [
              PlinthTocItem(label: 'Alpha', order: 2),
              PlinthTocItem(label: 'Beta', order: 2),
            ],
          ),
        ),
      );

      expect(
        tester.getRect(find.text('Alpha')).left,
        closeTo(tester.getRect(find.text('Beta')).left, 0.01),
      );
    });

    testWidgets('tapping reports the index', (tester) async {
      int? reported;
      await tester.pumpWidget(
        _wrap(
          PlinthTableOfContents(items: items, onSelected: (i) => reported = i),
        ),
      );

      await tester.tap(find.text('Installing'));
      await tester.pump();

      expect(reported, 1);
    });

    testWidgets('the active entry is marked as selected', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTableOfContents(items: items, activeIndex: 2)),
      );

      expect(
        tester
            .getSemantics(find.text('From pub.dev'))
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
    });

    testWidgets('scrolls to a targetKey when given one', (tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        _wrap(
          // Deliberately not a ListView: ensureVisible needs the target
          // to already be built, and a lazy list hasn't built anything
          // 2000px below the fold.
          SingleChildScrollView(
            child: Column(
              children: [
                PlinthTableOfContents(
                  items: [PlinthTocItem(label: 'Far below', targetKey: key)],
                ),
                const SizedBox(height: 2000),
                SizedBox(key: key, height: 40, child: const Text('Target')),
              ],
            ),
          ),
        ),
      );

      // Built, but well below the fold — so position is what tells us
      // whether it scrolled, not whether the widget exists.
      final position = tester
          .state<ScrollableState>(
            find.byType(Scrollable),
          )
          .position;
      expect(position.pixels, 0);
      expect(
          tester.getRect(find.text('Target')).top,
          greaterThan(
              tester.getRect(find.byType(SingleChildScrollView)).bottom));

      await tester.tap(find.text('Far below'));
      await tester.pumpAndSettle();

      expect(position.pixels, greaterThan(0));
      expect(tester.getRect(find.text('Target')).top,
          lessThan(tester.getRect(find.byType(SingleChildScrollView)).bottom));
    });
  });
}
