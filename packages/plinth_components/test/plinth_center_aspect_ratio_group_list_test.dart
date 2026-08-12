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
  group('PlinthCenter', () {
    testWidgets('renders its child', (tester) async {
      await tester
          .pumpWidget(_wrap(const PlinthCenter(child: Text('Centered'))));

      expect(find.text('Centered'), findsOneWidget);
    });
  });

  group('PlinthAspectRatio', () {
    testWidgets('constrains child to the given ratio', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 300,
            child: PlinthAspectRatio(
              ratio: 16 / 9,
              child: Container(key: const Key('box')),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byKey(const Key('box')));
      expect(size.width, closeTo(300, 0.01));
      expect(size.height, closeTo(300 / (16 / 9), 0.01));
    });
  });

  group('PlinthGroup', () {
    testWidgets('renders every child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthGroup(
            children: [Text('One'), Text('Two'), Text('Three')],
          ),
        ),
      );

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);
    });

    testWidgets('uses Wrap by default', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthGroup(children: [Text('One')])),
      );

      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('uses Row when wrap is false', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthGroup(wrap: false, children: [Text('One')])),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Wrap), findsNothing);
    });
  });

  group('PlinthList', () {
    testWidgets('renders every item', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthList(
            items: const [
              PlinthListItem(Text('First')),
              PlinthListItem(Text('Second')),
            ],
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('ordered type numbers items sequentially', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthList(
            type: PlinthListType.ordered,
            items: const [
              PlinthListItem(Text('A')),
              PlinthListItem(Text('B')),
            ],
          ),
        ),
      );

      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
    });

    testWidgets('a per-item icon overrides the default marker', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlinthList(
            type: PlinthListType.ordered,
            items: const [
              PlinthListItem(Text('A')),
              PlinthListItem(Text('B'),
                  icon: Icon(Icons.check, key: Key('custom-icon'))),
            ],
          ),
        ),
      );

      expect(find.byKey(const Key('custom-icon')), findsOneWidget);
      // Second item used its own icon, so only the first item's
      // default ordered marker ("1.") should appear.
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsNothing);
    });
  });
}
