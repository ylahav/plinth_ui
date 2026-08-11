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
  group('PlinthPinInput', () {
    testWidgets('renders one text field per length', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPinInput(length: 4, onChanged: (_) {})),
      );

      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('pre-fills from an initial value', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPinInput(length: 4, value: '12', onChanged: (_) {})),
      );

      final fields =
          tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields[0].controller!.text, equals('1'));
      expect(fields[1].controller!.text, equals('2'));
      expect(fields[2].controller!.text, equals(''));
    });

    testWidgets('typing a digit advances focus to the next box',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPinInput(length: 3, onChanged: (_) {})),
      );

      await tester.enterText(find.byType(TextField).at(0), '5');
      await tester.pump();

      final fields =
          tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields[1].focusNode!.hasFocus, isTrue);
    });

    testWidgets('calls onChanged with the combined value as digits are typed',
        (tester) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(PlinthPinInput(length: 3, onChanged: (v) => changed = v)),
      );

      await tester.enterText(find.byType(TextField).at(0), '1');
      await tester.pump();

      expect(changed, equals('1'));
    });

    testWidgets('calls onCompleted once all boxes are filled', (tester) async {
      String? completed;
      await tester.pumpWidget(
        _wrap(
          PlinthPinInput(
            length: 2,
            onChanged: (_) {},
            onCompleted: (v) => completed = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '1');
      await tester.pump();
      expect(completed, isNull);

      await tester.enterText(find.byType(TextField).at(1), '2');
      await tester.pump();
      expect(completed, equals('12'));
    });

    testWidgets('restricts input to digits when numbersOnly is true',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthPinInput(length: 2, numbersOnly: true, onChanged: (_) {})),
      );

      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.keyboardType, equals(TextInputType.number));
    });
  });
}
