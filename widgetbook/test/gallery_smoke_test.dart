import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_widgetbook/main.dart';
import 'package:widgetbook/widgetbook.dart';

/// Builds every use case in the gallery and asserts it doesn't throw.
///
/// The gallery is the one place in this repo where components are
/// exercised in isolation across their whole prop surface, but nothing
/// verified that its use cases actually *build* — `dart analyze` only
/// type-checks them, and the app has no platform folders checked in,
/// so running it by hand isn't a quick loop either. A knob whose value
/// trips an assertion inside the component (a slider value outside
/// min/max, minLines above maxLines) is a runtime failure that would
/// otherwise only show up when someone opened that page.
///
/// This is a smoke test, not a golden or behavior test: it asserts the
/// absence of exceptions, nothing about appearance. Use cases are
/// pumped at their knobs' *initial* values, since that's the state a
/// visitor lands on — a knob combination reachable only by dragging
/// two sliders into conflict isn't covered here, which is why the
/// playgrounds clamp those cases at the call site instead.
void main() {
  final useCases = _collectUseCases(plinthDirectories).toList();

  test('the gallery exposes use cases to smoke test', () {
    // Guards against the walk silently finding nothing (a refactor of
    // the node tree, say) and the suite passing with zero assertions.
    expect(useCases, isNotEmpty);
  });

  for (final entry in useCases) {
    testWidgets('${entry.path} builds', (tester) async {
      await tester.pumpWidget(_host(entry.useCase));

      // A second pump lets post-frame callbacks run — PlinthPortal
      // defers its overlay insert to one, so without this its use case
      // would report success before doing the thing that could fail.
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }
}

/// Hosts a single use case with the ambient state its builder expects.
///
/// `context.knobs` reads from a [WidgetbookState] via [WidgetbookScope]
/// and asserts if there isn't one, so the playground use cases can't be
/// pumped bare. Supplying the scope directly — rather than standing up
/// the full `Widgetbook.material` UI and navigating to each page — keeps
/// the test measuring the use case rather than Widgetbook's own
/// navigation. With no `knobs` query group set, every knob resolves to
/// its initial value.
Widget _host(WidgetbookUseCase useCase) {
  return WidgetbookScope(
    state: WidgetbookState(root: WidgetbookRoot(children: plinthDirectories)),
    // MaterialApp supplies the Navigator/Overlay that the overlay
    // components mount into; _themed inside the gallery supplies the
    // PlinthTheme and a Material ancestor.
    child: MaterialApp(home: Builder(builder: useCase.builder)),
  );
}

/// Walks the node tree, pairing each use case with a readable path.
///
/// Builds the path from the names it passes through rather than using
/// `WidgetbookNode.path`, which depends on parent links being wired up
/// by the widget that renders the tree.
Iterable<({String path, WidgetbookUseCase useCase})> _collectUseCases(
  List<WidgetbookNode> nodes, [
  String prefix = '',
]) sync* {
  for (final node in nodes) {
    final path = prefix.isEmpty ? node.name : '$prefix / ${node.name}';

    if (node is WidgetbookUseCase) {
      yield (path: path, useCase: node);
    } else {
      yield* _collectUseCases(node.children ?? const [], path);
    }
  }
}
