import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// `radius` on the components that were rounding their corners without
/// offering it.
///
/// The theme defines a radius scale and a `defaultRadius`, so a
/// component that ignores both isn't unstyled — it's un-overridable,
/// and before 0.19.0 which was which had no pattern to it.
///
/// Two things matter per component: passing a radius changes the
/// shape, and *not* passing one leaves it exactly as it was. The second
/// is the whole reason this is an additive change rather than a
/// breaking one.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(body: Center(child: child)),
  );
}

/// The corner radius of the first rounded box inside [of].
///
/// Matches `AnimatedContainer` as well as `Container` — they are
/// unrelated types, and several of these components animate their fill,
/// which is exactly where the first attempt at this helper looked past
/// the box it wanted and read a radius from further down the tree.
double _radiusOf(WidgetTester tester, Finder of) {
  BoxDecoration? decorationOf(Widget widget) => switch (widget) {
        Container(:final decoration) => decoration as BoxDecoration?,
        AnimatedContainer(:final decoration) => decoration as BoxDecoration?,
        _ => null,
      };

  final rounded = tester
      .widgetList(find.descendant(
        of: of,
        matching: find.byWidgetPredicate(
          (w) => decorationOf(w)?.borderRadius != null,
        ),
      ))
      .first;

  final radius = decorationOf(rounded)!.borderRadius! as BorderRadius;
  return radius.topLeft.x;
}

void main() {
  final theme = PlinthTheme.defaultTheme;

  group('pill-shaped components keep their pill unless told otherwise', () {
    testWidgets('PlinthBadge', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthBadge('New')));
      expect(_radiusOf(tester, find.byType(PlinthBadge)), 999);

      await tester.pumpWidget(
        _wrap(const PlinthBadge('New', radius: PlinthSize.xs)),
      );
      expect(
        _radiusOf(tester, find.byType(PlinthBadge)),
        theme.radius[PlinthSize.xs],
      );
    });

    testWidgets('PlinthChip', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthChip(label: 'Dart', selected: false, onSelected: (_) {})),
      );
      expect(_radiusOf(tester, find.byType(PlinthChip)), 999);

      await tester.pumpWidget(
        _wrap(PlinthChip(
          label: 'Dart',
          selected: false,
          onSelected: (_) {},
          radius: PlinthSize.sm,
        )),
      );
      expect(
        _radiusOf(tester, find.byType(PlinthChip)),
        theme.radius[PlinthSize.sm],
      );
    });

    testWidgets('PlinthSwitch keeps a capsule by default', (tester) async {
      await tester.pumpWidget(
        _wrap(PlinthSwitch(value: true, onChanged: (_) {})),
      );
      final capsule = _radiusOf(tester, find.byType(PlinthSwitch));

      await tester.pumpWidget(
        _wrap(PlinthSwitch(
          value: true,
          onChanged: (_) {},
          radius: PlinthSize.xs,
        )),
      );

      // Half the track height, whatever that is at this size — the
      // point is only that it isn't the theme's radius scale.
      expect(capsule, isNot(theme.radius[PlinthSize.xs]));
      expect(
        _radiusOf(tester, find.byType(PlinthSwitch)),
        theme.radius[PlinthSize.xs],
      );
    });
  });

  group('components that followed the theme default now take an override', () {
    testWidgets('PlinthCascader', (tester) async {
      const options = [PlinthCascaderOption(value: 'eu', label: 'Europe')];

      await tester.pumpWidget(
        _wrap(
            const PlinthCascader(options: options, value: [], onChanged: null)),
      );
      expect(
        _radiusOf(tester, find.byType(PlinthCascader)),
        theme.radius[theme.defaultRadius],
      );

      await tester.pumpWidget(
        _wrap(const PlinthCascader(
          options: options,
          value: [],
          onChanged: null,
          radius: PlinthSize.xl,
        )),
      );
      expect(
        _radiusOf(tester, find.byType(PlinthCascader)),
        theme.radius[PlinthSize.xl],
      );
    });

    testWidgets('PlinthPinInput', (tester) async {
      // Its boxes are `OutlineInputBorder`s rather than decorated
      // containers, so the radius has to be read off the field's own
      // decoration.
      double borderRadius(WidgetTester tester) {
        final field =
            tester.widgetList<TextField>(find.byType(TextField)).first;
        final border = field.decoration!.enabledBorder! as OutlineInputBorder;
        return border.borderRadius.topLeft.x;
      }

      await tester.pumpWidget(_wrap(const PlinthPinInput(length: 3)));
      expect(borderRadius(tester), theme.radius[theme.defaultRadius]);

      await tester.pumpWidget(
        _wrap(const PlinthPinInput(length: 3, radius: PlinthSize.xl)),
      );
      expect(borderRadius(tester), theme.radius[PlinthSize.xl]);
    });

    testWidgets('PlinthColorSwatch keeps its squarer 6px default',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthColorSwatch(color: 'blue')),
      );
      // Not the theme default: a swatch is a sample of colour, and
      // squarer corners show more of it.
      expect(_radiusOf(tester, find.byType(PlinthColorSwatch)), 6);

      await tester.pumpWidget(
        _wrap(const PlinthColorSwatch(color: 'blue', radius: PlinthSize.xl)),
      );
      expect(
        _radiusOf(tester, find.byType(PlinthColorSwatch)),
        theme.radius[PlinthSize.xl],
      );
    });
  });
}
