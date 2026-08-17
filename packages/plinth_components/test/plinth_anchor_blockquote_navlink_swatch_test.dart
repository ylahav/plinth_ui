import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('PlinthAnchor', () {
    testWidgets('renders its label', (tester) async {
      await tester
          .pumpWidget(_wrap(PlinthAnchor('Forgot password?', onTap: () {})));

      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PlinthAnchor('Forgot password?', onTap: () => tapped = true)),
      );

      await tester.tap(find.text('Forgot password?'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('PlinthBlockquote', () {
    testWidgets('renders the quote', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBlockquote(quote: 'Stay hungry, stay foolish.')),
      );

      expect(find.text('Stay hungry, stay foolish.'), findsOneWidget);
    });

    testWidgets('renders the citation when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBlockquote(quote: 'Quote text', citation: 'Steve Jobs'),
        ),
      );

      expect(find.text('— Steve Jobs'), findsOneWidget);
    });

    testWidgets('omits the citation line when not provided', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBlockquote(quote: 'Quote text')),
      );

      expect(find.textContaining('—'), findsNothing);
    });
  });

  group('PlinthNavLink', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthNavLink(label: 'Dashboard')),
      );

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PlinthNavLink(label: 'Dashboard', onTap: () => tapped = true)),
      );

      await tester.tap(find.text('Dashboard'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('a link without children has no chevron', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthNavLink(label: 'Dashboard')));

      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets('children are hidden from semantics while closed',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthNavLink(
          label: 'Analytics',
          children: [PlinthNavLink(label: 'Traffic')],
        )),
      );
      await tester.pumpAndSettle();

      // PlinthCollapse keeps the child mounted, so it is still in the
      // tree — the thing that must not happen is a screen reader
      // reading out a link nobody can see.
      expect(find.text('Traffic'), findsOneWidget);
      final semantics = tester.getSemantics(find.byType(PlinthNavLink).first);
      expect(semantics.label.contains('Traffic'), isFalse);
    });

    testWidgets('opened reveals the children and turns the chevron',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthNavLink(
          label: 'Analytics',
          opened: true,
          children: [PlinthNavLink(label: 'Traffic')],
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('Traffic'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        equals(0.5),
      );
    });

    testWidgets('tapping a parent reports the flipped opened state',
        (tester) async {
      bool? opened;
      await tester.pumpWidget(
        _wrap(PlinthNavLink(
          label: 'Analytics',
          onOpenedChanged: (o) => opened = o,
          children: const [PlinthNavLink(label: 'Traffic')],
        )),
      );

      await tester.tap(find.text('Analytics'));
      await tester.pump();

      expect(opened, isTrue);
    });

    testWidgets('a parent that is also a destination calls both callbacks',
        (tester) async {
      var tapped = false;
      bool? opened;
      await tester.pumpWidget(
        _wrap(PlinthNavLink(
          label: 'Analytics',
          opened: true,
          onTap: () => tapped = true,
          onOpenedChanged: (o) => opened = o,
          children: const [PlinthNavLink(label: 'Traffic')],
        )),
      );

      await tester.tap(find.text('Analytics'));
      await tester.pump();

      expect(tapped, isTrue);
      expect(opened, isFalse);
    });

    testWidgets('trailing keeps its slot ahead of the chevron', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthNavLink(
          label: 'Analytics',
          trailing: Icon(Icons.circle),
          children: [PlinthNavLink(label: 'Traffic')],
        )),
      );

      expect(find.byIcon(Icons.circle), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });
  });

  group('PlinthColorSwatch', () {
    testWidgets('shows a checkmark when selected', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthColorSwatch(color: 'blue', selected: true)),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not show a checkmark when unselected', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthColorSwatch(color: 'blue', selected: false)),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PlinthColorSwatch(color: 'blue', onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(PlinthColorSwatch));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
