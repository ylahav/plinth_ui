import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

void main() {
  testWidgets('autocomplete: keyboard can now choose', (tester) async {
    var value = '';
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 400,
              child: PlinthAutocomplete(
                label: 'Company',
                value: value,
                options: const ['Alpha', 'Amber', 'Gamma'],
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    // ignore: avoid_print
    print('DBG chosen="$value"');
  });
}
