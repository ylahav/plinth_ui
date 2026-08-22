import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

void main() {
  testWidgets('accordion tree', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PlinthAccordion(
          items: const [
            PlinthAccordionItem(
              value: 'a',
              title: 'How do refunds work?',
              content: Text('Within 30 days of purchase.'),
            ),
          ],
        ),
      ),
    ));
    final owner = tester.binding.pipelineOwner.semanticsOwner!;
    debugPrint('=== CLOSED ===');
    debugPrint(owner.rootSemanticsNode!.toStringDeep());
    await tester.tap(find.text('How do refunds work?'));
    await tester.pumpAndSettle();
    debugPrint('=== OPEN ===');
    debugPrint(owner.rootSemanticsNode!.toStringDeep());
    handle.dispose();
  });
}
