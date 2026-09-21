/// The token axes have to reach the pixels, or they are decoration.
///
/// This file exists because of a bug it would have caught:
/// `PlinthTheme` carried a `shadow` colour, documented and public,
/// while `PlinthPaper` built its shadows from a hardcoded
/// `Colors.black`. The token existed, resolved, and painted nothing.
/// Every axis added alongside it is at risk of the same thing, so each
/// one is asserted here by overriding it and looking at what rendered
/// — not by reading it back off the theme, which proves only that a map
/// holds what was put in it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Widget _wrap(Widget child, PlinthTheme theme) => MaterialApp(
      theme: ThemeData(extensions: [theme]),
      home: Scaffold(body: Center(child: child)),
    );

final _base = PlinthTheme.defaultTheme;

void main() {
  group('fontWeights', () {
    testWidgets('a heading takes its weight from the theme', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTitle('Heading', order: 1), _base),
      );
      expect(
        tester.widget<Text>(find.text('Heading')).style!.fontWeight,
        FontWeight.w700,
      );

      await tester.pumpWidget(
        _wrap(
          const PlinthTitle('Heading', order: 1),
          _base.copyWith(
            fontWeights: {
              ..._base.fontWeights,
              PlinthWeight.bold: FontWeight.w900
            },
          ),
        ),
      );

      // `MaterialApp` installs an `AnimatedTheme`, and a weight is
      // discrete — it changes over at the midpoint rather than
      // interpolating. So this has to settle before it is the new one.
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.text('Heading')).style!.fontWeight,
        FontWeight.w900,
        reason: 'the heading ignored the theme and used its own literal',
      );
    });
  });

  group('borderWidths', () {
    Future<double> borderOf(WidgetTester tester, PlinthTheme theme) async {
      await tester.pumpWidget(
        _wrap(const PlinthTextInput(label: 'Email'), theme),
      );
      await tester.pumpAndSettle();
      final box =
          tester.widgetList<Container>(find.byType(Container)).firstWhere(
                (c) => (c.decoration as BoxDecoration?)?.border != null,
              );
      final border = (box.decoration! as BoxDecoration).border!;
      return border.top.width;
    }

    testWidgets('an input takes its border width from the theme',
        (tester) async {
      expect(await borderOf(tester, _base), 1);
      expect(
        await borderOf(
          tester,
          _base.copyWith(
              borderWidths: {..._base.borderWidths, PlinthSize.xs: 5}),
        ),
        5,
        reason: 'the input ignored the theme and used its own literal',
      );
    });
  });

  group('elevations', () {
    BoxShadow shadowOf(WidgetTester tester) {
      final container = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (c) =>
                ((c.decoration as BoxDecoration?)?.boxShadow ?? []).isNotEmpty,
          );
      return (container.decoration! as BoxDecoration).boxShadow!.single;
    }

    testWidgets('a paper takes its shadow geometry from the theme',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthPaper(shadow: PlinthShadow.md, child: Text('x')),
          _base.copyWith(
            elevations: {
              ..._base.elevations,
              PlinthShadow.md: const PlinthElevation(
                blur: 33,
                offsetY: 7,
                opacity: 0.5,
              ),
            },
          ),
        ),
      );

      final shadow = shadowOf(tester);
      expect(shadow.blurRadius, 33);
      expect(shadow.offset, const Offset(0, 7));
    });

    testWidgets('and its shadow colour, which used to be hardcoded black',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthPaper(shadow: PlinthShadow.md, child: Text('x')),
          _base.copyWith(shadow: const Color(0xFF00FF00)),
        ),
      );

      final shadow = shadowOf(tester);
      expect(shadow.color.g, 1, reason: 'shadow colour is still ignored');
      expect(shadow.color.r, 0);
      expect(shadow.color.b, 0);
    });

    testWidgets('PlinthShadow.none paints no shadow at all', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthPaper(child: Text('x')), _base),
      );
      final papers = tester.widgetList<Container>(find.byType(Container));
      for (final c in papers) {
        final shadows = (c.decoration as BoxDecoration?)?.boxShadow;
        expect(shadows ?? const <BoxShadow>[], isEmpty);
      }
    });
  });

  group('durations and curves', () {
    testWidgets('a collapse takes its motion from the theme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthCollapse(opened: true, child: SizedBox(height: 40)),
          _base.copyWith(
            durations: {
              ..._base.durations,
              PlinthSize.md: const Duration(milliseconds: 777),
            },
            curves: {..._base.curves, PlinthCurve.standard: Curves.bounceIn},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final animated = tester.widget<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>),
      );
      expect(animated.duration, const Duration(milliseconds: 777));
      expect(animated.curve, Curves.bounceIn);
    });

    testWidgets('an explicit duration still wins over the theme',
        (tester) async {
      // The parameter is nullable so the theme can drive it. That must
      // not cost a caller the ability to override it.
      await tester.pumpWidget(
        _wrap(
          const PlinthCollapse(
            opened: true,
            duration: Duration(milliseconds: 12),
            child: SizedBox(height: 40),
          ),
          _base.copyWith(
            durations: {
              ..._base.durations,
              PlinthSize.md: const Duration(milliseconds: 777),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TweenAnimationBuilder<double>>(
              find.byType(TweenAnimationBuilder<double>),
            )
            .duration,
        const Duration(milliseconds: 12),
      );
    });
  });
}
