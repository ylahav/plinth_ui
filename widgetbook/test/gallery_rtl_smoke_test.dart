/// B0d — every gallery use case, built right-to-left.
///
/// The cheap half of the RTL question: does anything *break*. It reuses
/// the same 232 use cases the gallery smoke test builds, so coverage is
/// the whole component surface rather than a hand-picked sample, and
/// costs one extra pump each.
///
/// It cannot answer whether Hebrew or Arabic *reads* right — that needs
/// a reader, and the stronger evidence there is already recorded:
/// migrating a real Hebrew/English app found 12 of 12 page x language
/// combinations clean.
///
/// Result when added: 0 of 232 threw.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_widgetbook/main.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  final useCases = _collect(plinthDirectories).toList();
  for (final entry in useCases) {
    testWidgets('${entry.path} builds in RTL', (tester) async {
      await tester.pumpWidget(_host(entry.useCase));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  test('the walk found use cases', () => expect(useCases, isNotEmpty));
}

Widget _host(WidgetbookUseCase useCase) {
  return WidgetbookScope(
    state: WidgetbookState(root: WidgetbookRoot(children: plinthDirectories)),
    child: MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Builder(builder: useCase.builder),
      ),
    ),
  );
}

Iterable<({String path, WidgetbookUseCase useCase})> _collect(
  List<WidgetbookNode> nodes, [
  String prefix = '',
]) sync* {
  for (final node in nodes) {
    final path = prefix.isEmpty ? node.name : '$prefix / ${node.name}';
    if (node is WidgetbookUseCase) {
      yield (path: path, useCase: node);
    } else {
      yield* _collect(node.children ?? const [], path);
    }
  }
}
