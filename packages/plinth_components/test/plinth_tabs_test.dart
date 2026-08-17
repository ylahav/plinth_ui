import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PlinthTabs', () {
    testWidgets('renders every tab label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthTabs<String>(
            value: 'a',
            onChanged: (_) {},
            tabs: const [
              PlinthTabItem('a', 'First'),
              PlinthTabItem('b', 'Second'),
            ],
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('calls onChanged with the tapped tab value', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          PlinthTabs<String>(
            value: 'a',
            onChanged: (v) => selected = v,
            tabs: const [
              PlinthTabItem('a', 'First'),
              PlinthTabItem('b', 'Second'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Second'));
      await tester.pump();

      expect(selected, equals('b'));
    });

    testWidgets('a strip wider than its box scrolls instead of overflowing',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            child: PlinthTabs<String>(
              value: 'a',
              onChanged: (_) {},
              tabs: const [
                PlinthTabItem('a', 'Overview'),
                PlinthTabItem('b', 'Activity'),
                PlinthTabItem('c', 'Settings'),
                PlinthTabItem('d', 'Integrations'),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      // The last tab is off-screen until it is scrolled to, which is
      // the point — it exists rather than being clipped away.
      await tester.scrollUntilVisible(find.text('Integrations'), 100,
          scrollable: find.byType(Scrollable).last);
      expect(find.text('Integrations'), findsOneWidget);
    });

    testWidgets('a strip inside an unbounded row still lays out',
        (tester) async {
      // A header that puts tabs in a `Row` without an `Expanded` hands
      // them unbounded width, which a scroll viewport cannot take.
      await tester.pumpWidget(
        _wrap(
          Row(
            children: [
              PlinthTabs<String>(
                value: 'a',
                onChanged: (_) {},
                tabs: const [
                  PlinthTabItem('a', 'First'),
                  PlinthTabItem('b', 'Second'),
                ],
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Second'), findsOneWidget);
    });
  });

  group('PlinthTabView', () {
    testWidgets('shows the child matching value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTabView<String>(
            value: 'b',
            children: {
              'a': Text('Panel A'),
              'b': Text('Panel B'),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Panel B'), findsOneWidget);
      expect(find.text('Panel A'), findsNothing);
    });

    testWidgets('renders nothing for a value with no matching child',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTabView<String>(
            value: 'missing',
            children: {'a': Text('Panel A')},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not throw, and should render no panel text.
      expect(find.text('Panel A'), findsNothing);
    });
  });

  group('PlinthTabs keyboard', () {
    const tabs = [
      PlinthTabItem('a', 'Account'),
      PlinthTabItem('b', 'Security'),
      PlinthTabItem('c', 'Billing'),
    ];

    /// A strip driven by its own state, so an arrow key's `onChanged`
    /// actually moves the selection the way a real caller's would.
    Widget strip({
      Axis direction = Axis.horizontal,
      bool loop = true,
      TextDirection textDirection = TextDirection.ltr,
      required ValueChanged<String> onChanged,
      required String value,
    }) {
      return MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: Directionality(
          textDirection: textDirection,
          child: Scaffold(
            body: PlinthTabs<String>(
              tabs: tabs,
              value: value,
              direction: direction,
              loop: loop,
              onChanged: onChanged,
            ),
          ),
        ),
      );
    }

    /// Pumps a self-driving strip and returns a getter for the value.
    Future<String Function()> live(
      WidgetTester tester, {
      String initial = 'a',
      Axis direction = Axis.horizontal,
      bool loop = true,
      TextDirection textDirection = TextDirection.ltr,
    }) async {
      var value = initial;
      late StateSetter setValue;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setValue = setState;
            return strip(
              value: value,
              direction: direction,
              loop: loop,
              textDirection: textDirection,
              onChanged: (v) => setValue(() => value = v),
            );
          },
        ),
      );

      // Focus the strip the way Tab would, then let it settle.
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      return () => value;
    }

    Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets('right and left move along a horizontal strip', (tester) async {
      final value = await live(tester);

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(value(), equals('b'));

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(value(), equals('c'));

      await press(tester, LogicalKeyboardKey.arrowLeft);
      expect(value(), equals('b'));
    });

    testWidgets('up and down move along a vertical strip', (tester) async {
      final value = await live(tester, direction: Axis.vertical);

      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(value(), equals('b'));

      await press(tester, LogicalKeyboardKey.arrowUp);
      expect(value(), equals('a'));
    });

    testWidgets('a vertical strip ignores the cross-axis arrows',
        (tester) async {
      final value = await live(tester, direction: Axis.vertical);

      // Left/right belong to whatever else is on the page — a text
      // field beside the strip should still get its caret keys.
      await press(tester, LogicalKeyboardKey.arrowRight);
      await press(tester, LogicalKeyboardKey.arrowLeft);

      expect(value(), equals('a'));
    });

    testWidgets('Home and End jump to the ends', (tester) async {
      final value = await live(tester, initial: 'b');

      await press(tester, LogicalKeyboardKey.end);
      expect(value(), equals('c'));

      await press(tester, LogicalKeyboardKey.home);
      expect(value(), equals('a'));
    });

    testWidgets('loop wraps at both ends', (tester) async {
      final value = await live(tester);

      await press(tester, LogicalKeyboardKey.arrowLeft);
      expect(value(), equals('c'), reason: 'first tab wraps backward');

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(value(), equals('a'), reason: 'last tab wraps forward');
    });

    testWidgets('loop: false stops at the ends instead', (tester) async {
      final value = await live(tester, loop: false);

      await press(tester, LogicalKeyboardKey.arrowLeft);
      expect(value(), equals('a'));

      for (var i = 0; i < 5; i++) {
        await press(tester, LogicalKeyboardKey.arrowRight);
      }
      expect(value(), equals('c'));
    });

    testWidgets('the arrows follow the reading direction in RTL',
        (tester) async {
      final value = await live(tester, textDirection: TextDirection.rtl);

      // The strip renders right-to-left, so the left arrow moves to
      // the tab that reads next rather than to the previous one.
      await press(tester, LogicalKeyboardKey.arrowLeft);
      expect(value(), equals('b'));

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(value(), equals('a'));
    });

    testWidgets('the strip is one stop in the tab order, not one per tab',
        (tester) async {
      await live(tester);

      // Roving focus is the whole point: a twelve-tab settings page
      // should not cost twelve presses to walk past.
      //
      // Filtered to the strip's own nodes — every InkWell builds a
      // Focus of its own, with a null node because it was not given
      // one, and counting those would measure Material rather than
      // this widget.
      final stops = tester
          .widgetList<Focus>(find.descendant(
            of: find.byType(PlinthTabs<String>),
            matching: find.byType(Focus),
          ))
          .where((f) => f.focusNode != null && !f.skipTraversal)
          .length;

      expect(stops, equals(1));
    });

    testWidgets('focus follows the selection so the strip stays reachable',
        (tester) async {
      final value = await live(tester);

      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(value(), equals('b'));

      // If focus had stayed on the old tab it would now be outside the
      // traversal order, and the next arrow would go nowhere.
      await press(tester, LogicalKeyboardKey.arrowRight);
      expect(value(), equals('c'));
    });

    testWidgets('each tab reports whether it is the selected one',
        (tester) async {
      await tester.pumpWidget(
        strip(value: 'b', onChanged: (_) {}),
      );

      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.text('Security')).hasFlag(
              SemanticsFlag.isSelected,
            ),
        isTrue,
      );
      expect(
        tester.getSemantics(find.text('Account')).hasFlag(
              SemanticsFlag.isSelected,
            ),
        isFalse,
      );
      handle.dispose();
    });
  });

  group('PlinthTabs direction', () {
    const tabs = [
      PlinthTabItem('a', 'Account'),
      PlinthTabItem('b', 'Security'),
      PlinthTabItem('c', 'Billing'),
    ];

    Rect rectOf(WidgetTester tester, String label) =>
        tester.getRect(find.text(label));

    testWidgets('horizontal lays the tabs side by side', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthTabs<String>(tabs: tabs, value: 'a', onChanged: (_) {})),
      );

      final first = rectOf(tester, 'Account');
      final second = rectOf(tester, 'Security');
      expect(second.left, greaterThan(first.left));
      expect(second.top, equals(first.top));
    });

    testWidgets('vertical stacks them instead', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthTabs<String>(
          tabs: tabs,
          value: 'a',
          direction: Axis.vertical,
          onChanged: (_) {},
        )),
      );

      final first = rectOf(tester, 'Account');
      final second = rectOf(tester, 'Security');
      expect(second.top, greaterThan(first.top));
      expect(second.left, equals(first.left));
    });

    testWidgets('vertical moves the indicator to the trailing edge',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthTabs<String>(
          tabs: tabs,
          value: 'b',
          direction: Axis.vertical,
          onChanged: (_) {},
        )),
      );

      // The active tab's coloured side is the one the caller sees as
      // the indicator; horizontally it is `bottom`, and the whole
      // point of the vertical variant is that it is `right`.
      final decorated = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(PlinthTabs<String>),
            matching: find.byType(Container),
          ))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.border)
          .whereType<Border>()
          .toList();

      expect(decorated, isNotEmpty);
      for (final border in decorated) {
        expect(border.bottom, equals(BorderSide.none));
        expect(border.right.width, equals(2));
      }
    });

    testWidgets('vertical still reports taps', (tester) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(PlinthTabs<String>(
          tabs: tabs,
          value: 'a',
          direction: Axis.vertical,
          onChanged: (v) => changed = v,
        )),
      );

      await tester.tap(find.text('Billing'));
      await tester.pump();

      expect(changed, equals('c'));
    });

    testWidgets('vertical survives an unbounded width', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Row(
            children: [
              PlinthTabs<String>(
                tabs: tabs,
                value: 'a',
                direction: Axis.vertical,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      );

      // `crossAxisAlignment: stretch` needs a width to stretch to, and
      // a Row hands its children an unbounded one.
      expect(tester.takeException(), isNull);
      expect(find.text('Billing'), findsOneWidget);
    });
  });
}
