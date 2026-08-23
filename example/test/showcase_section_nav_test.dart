// The component tour shows one section at a time, and selecting one
// puts focus at the top of it.
//
// Reported from a screen-reader session: reaching a control meant
// Tab-ing past 115 sidebar entries and then every control above it on
// the page. The tour mounted all 115 sections at once, so the number of
// stops between "I want to check PlinthSelect" and PlinthSelect ran to
// the hundreds — on the app that exists to invite exactly that check.
//
// Not a screen-reader problem. A keyboard user has the same walk, and
// the fix is the same: show the section that was asked for, and leave
// focus where the next Tab enters it.
//
// These assert on the widgets a section contains rather than on its
// title. The sidebar is a ListView and so is virtualized — a section
// name near the middle of the alphabet is not built at all until it
// scrolls into view, which makes text a poor proxy for "is this section
// on screen".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:plinth_example/main.dart';

/// Pumps the showcase on a surface wide enough for the persistent
/// sidebar — the narrow layout puts it behind a hamburger instead.
///
/// Through the real app rather than pumping `ShowcasePage` directly:
/// the toolbar's theme toggle reads an `InheritedWidget` that only
/// `PlinthExampleApp` installs.
///
/// Bounded pumps rather than pumpAndSettle, because the page carries
/// indeterminate animations — the skeleton's pulse, a network image
/// that fails immediately under test — so it never converges. The
/// established pattern in this suite.
Future<void> _pumpShowcase(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const PlinthExampleApp());
  await tester.tap(find.text('Component gallery'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _select(WidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('opens on one section rather than all of them', (tester) async {
    await _pumpShowcase(tester);

    expect(find.byType(PlinthAccordion), findsWidgets,
        reason: 'the tour opens on the first section by name, which is '
            'also the first entry under "All components" in the menu');
    expect(find.byType(PlinthRingProgress), findsNothing,
        reason: 'every other section used to be mounted at the same '
            'time, which is what put hundreds of Tab stops between the '
            'sidebar and any one control');
  });

  testWidgets('the sidebar switches sections', (tester) async {
    await _pumpShowcase(tester);

    // Near the top of the alphabet, so it is inside the sidebar's
    // viewport without having to scroll it.
    await _select(tester, 'Avatars');

    expect(find.byType(PlinthAvatar), findsWidgets);
    expect(find.byType(PlinthAccordion), findsNothing,
        reason: 'the section that was on screen should have left');
  });

  testWidgets('selecting a section moves focus to the content', (tester) async {
    await _pumpShowcase(tester);
    await _select(tester, 'Avatars');

    expect(FocusManager.instance.primaryFocus?.debugLabel, 'showcase content',
        reason: 'the point of the change: the next Tab steps into the '
            'section, instead of starting again at the top of a '
            '115-entry sidebar');
  });

  testWidgets('"All components" brings the whole tour back', (tester) async {
    await _pumpShowcase(tester);
    await _select(tester, 'Avatars');
    await _select(tester, 'All components');

    expect(find.byType(PlinthAccordion), findsWidgets);
    expect(find.byType(PlinthAvatar), findsWidgets,
        reason: 'two sections mounted at once is enough to show the '
            'mode is back; the long page is not what this tests');
  });

  testWidgets('and reads down in the order the menu lists', (tester) async {
    await _pumpShowcase(tester);
    await _select(tester, 'All components');

    // Accordion sorts before Avatars, and the page is authored the
    // other way round. Before the sections were regrouped, the menu and
    // the page disagreed about where anything was.
    final accordion = tester.getTopLeft(find.byType(PlinthAccordion).first).dy;
    final avatar = tester.getTopLeft(find.byType(PlinthAvatar).first).dy;

    expect(accordion, lessThan(avatar),
        reason: 'the menu is sorted by name, so the page has to be too '
            '— otherwise scrolling past one entry to find the next '
            'lands somewhere unrelated');
  });
}
