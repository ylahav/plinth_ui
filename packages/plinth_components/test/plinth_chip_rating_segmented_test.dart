import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('PlinthChip', () {
    testWidgets('renders label and shows a checkmark when selected',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthChip(label: 'Blue', selected: true, onSelected: (_) {})),
      );

      expect(find.text('Blue'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not show a checkmark when unselected', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthChip(label: 'Blue', selected: false, onSelected: (_) {})),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('tapping toggles selection via onSelected', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _wrap(
          PlinthChip(
              label: 'Blue', selected: false, onSelected: (v) => result = v),
        ),
      );

      await tester.tap(find.text('Blue'));
      await tester.pump();

      expect(result, isTrue);
    });

    testWidgets('does nothing when onSelected is null', (tester) async {
      await tester.pumpWidget(
        _wrap(
            const PlinthChip(label: 'Blue', selected: false, onSelected: null)),
      );

      await tester.tap(find.text('Blue'), warnIfMissed: false);
      await tester.pump();
      // No assertion beyond "didn't throw" — a null onSelected should
      // simply make the chip non-interactive.
    });
  });

  group('PlinthRating', () {
    testWidgets('renders the given number of stars', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthRating(value: 3, count: 5)));

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('tapping a star calls onChanged with its index',
        (tester) async {
      double? changed;
      await tester.pumpWidget(
        _wrap(PlinthRating(value: 0, onChanged: (v) => changed = v)),
      );

      // Tap all star icons and pick the 3rd one specifically.
      final stars = find.byIcon(Icons.star_border);
      await tester.tap(stars.at(2));
      await tester.pump();

      expect(changed, equals(3.0));
    });

    testWidgets('read-only mode (no onChanged) does not throw when tapped',
        (tester) async {
      await tester.pumpWidget(const _RatingReadOnlyHarness());

      await tester.tap(find.byIcon(Icons.star).first, warnIfMissed: false);
      await tester.pump();

      // No onChanged was provided, so there's nothing to assert on —
      // this test only guards against a crash when a read-only
      // rating is tapped.
    });

    testWidgets('renders a half star for a fractional value', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthRating(value: 3.5, count: 5)));

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('fractions: 2 selects halves from the left of a star',
        (tester) async {
      double? changed;
      await tester.pumpWidget(
        _wrap(PlinthRating(
          value: 0,
          fractions: 2,
          onChanged: (v) => changed = v,
        )),
      );

      // The third star spans two hit regions; the left one is 2.5 and
      // the right one is 3.
      final third = tester.getRect(find.byIcon(Icons.star_border).at(2));

      await tester
          .tapAt(Offset(third.left + third.width * 0.25, third.center.dy));
      await tester.pump();
      expect(changed, equals(2.5));

      await tester
          .tapAt(Offset(third.left + third.width * 0.75, third.center.dy));
      await tester.pump();
      expect(changed, equals(3.0));
    });

    testWidgets('fractions: 1 still reports whole stars', (tester) async {
      double? changed;
      await tester.pumpWidget(
        _wrap(PlinthRating(value: 0, onChanged: (v) => changed = v)),
      );

      final second = tester.getRect(find.byIcon(Icons.star_border).at(1));
      // Left edge of the star: a split rating would call this 1.5.
      await tester
          .tapAt(Offset(second.left + second.width * 0.1, second.center.dy));
      await tester.pump();

      expect(changed, equals(2.0));
    });
  });

  group('PlinthSegmentedControl', () {
    testWidgets('renders every option label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthSegmentedControl<String>(
            value: 'list',
            onChanged: (_) {},
            items: const [
              PlinthSegmentedControlItem('list', 'List'),
              PlinthSegmentedControlItem('grid', 'Grid'),
            ],
          ),
        ),
      );

      expect(find.text('List'), findsOneWidget);
      expect(find.text('Grid'), findsOneWidget);
    });

    testWidgets('tapping an option calls onChanged with its value',
        (tester) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(
          PlinthSegmentedControl<String>(
            value: 'list',
            onChanged: (v) => changed = v,
            items: const [
              PlinthSegmentedControlItem('list', 'List'),
              PlinthSegmentedControlItem('grid', 'Grid'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Grid'));
      await tester.pump();

      expect(changed, equals('grid'));
    });

    testWidgets('arrows move between segments and select as they go',
        (tester) async {
      var value = 'list';
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
            home: Scaffold(
              body: PlinthSegmentedControl<String>(
                value: value,
                onChanged: (v) => setState(() => value = v),
                items: const [
                  PlinthSegmentedControlItem('list', 'List'),
                  PlinthSegmentedControlItem('grid', 'Grid'),
                  PlinthSegmentedControlItem('map', 'Map'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, equals('grid'));

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(value, equals('map'));

      // Loops by default, the same as PlinthTabs.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, equals('list'));
    });

    testWidgets('the control is one stop in the tab order', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthSegmentedControl<String>(
            value: 'list',
            onChanged: (_) {},
            items: const [
              PlinthSegmentedControlItem('list', 'List'),
              PlinthSegmentedControlItem('grid', 'Grid'),
              PlinthSegmentedControlItem('map', 'Map'),
            ],
          ),
        ),
      );

      final stops = tester
          .widgetList<Focus>(find.descendant(
            of: find.byType(PlinthSegmentedControl<String>),
            matching: find.byType(Focus),
          ))
          .where((f) => f.focusNode != null && !f.skipTraversal)
          .length;

      expect(stops, equals(1));
    });
  });
}

/// A read-only PlinthRating with no onChanged, wrapped in a
/// MaterialApp/Scaffold — separate widget (rather than inlining in
/// the test) purely so the const constructor works for pumpWidget.
class _RatingReadOnlyHarness extends StatelessWidget {
  const _RatingReadOnlyHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: const Scaffold(body: PlinthRating(value: 3)),
    );
  }
}
