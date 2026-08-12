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
  final theme = PlinthTheme.defaultTheme;

  group('PlinthAvatar', () {
    testWidgets('shows initials, uppercased', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar(initials: 'yl')));

      expect(find.text('YL'), findsOneWidget);
    });

    testWidgets('falls back to a person icon with no initials', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar()));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('treats empty initials as absent', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar(initials: '')));

      // Otherwise an empty string from a user record would render a
      // blank circle rather than the icon fallback.
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('every size renders', (tester) async {
      for (final size in PlinthSize.values) {
        await tester.pumpWidget(
          _wrap(PlinthAvatar(initials: 'AB', size: size)),
        );

        expect(find.text('AB'), findsOneWidget);
      }
    });

    testWidgets('is circular unless given a radius', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthAvatar(initials: 'AB')));
      final circular = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(PlinthAvatar),
          matching: find.byType(ClipRRect),
        ),
      );

      await tester.pumpWidget(
        _wrap(const PlinthAvatar(initials: 'AB', radius: PlinthSize.xs)),
      );
      final rounded = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(PlinthAvatar),
          matching: find.byType(ClipRRect),
        ),
      );

      expect(circular.borderRadius, isNot(rounded.borderRadius));
    });
  });

  group('PlinthBadge', () {
    testWidgets('renders its label uppercased', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthBadge('New')));

      // Uppercasing is the component's own styling, not something the
      // caller passes in — pass 'New' and get 'NEW'.
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('New'), findsNothing);
    });

    testWidgets('every variant renders without an unhandled case',
        (tester) async {
      for (final variant in PlinthVariant.values) {
        await tester.pumpWidget(
          _wrap(PlinthBadge(variant.name, variant: variant)),
        );

        expect(find.text(variant.name.toUpperCase()), findsOneWidget);
      }
    });

    testWidgets('the filled variant paints the base color', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBadge(
            'New',
            variant: PlinthVariant.filled,
            color: 'green',
          ),
        ),
      );

      final decoration = tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byType(PlinthBadge),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration! as BoxDecoration;
      expect(decoration.color, theme.color('green', 6));
    });

    testWidgets('the outline variant is transparent with a border',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBadge('New', variant: PlinthVariant.outline)),
      );

      final decoration = tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byType(PlinthBadge),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration! as BoxDecoration;
      expect(decoration.color, Colors.transparent);
      expect(decoration.border, isNotNull);
    });

    testWidgets('renders a leading icon', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBadge('New', leadingIcon: Icon(Icons.star))),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('PlinthProgress', () {
    testWidgets('renders at a valid value', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthProgress(value: 0.5)));

      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts both ends of the range', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthProgress(value: 0)));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_wrap(const PlinthProgress(value: 1)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects a value outside 0..1', (tester) async {
      // Asserted rather than clamped: a fraction above 1 means the
      // caller computed it wrong, and silently flooring it would hide
      // that.
      expect(() => PlinthProgress(value: 1.5), throwsAssertionError);
      expect(() => PlinthProgress(value: -0.1), throwsAssertionError);
    });

    testWidgets('fills the fraction it was given', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthProgress(value: 0.25)));
      await tester.pumpAndSettle();

      final box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, closeTo(0.25, 0.001));
    });

    testWidgets('uses the track color it was given', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthProgress(value: 0.5, trackColor: Color(0xFF123456)),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PlinthProgress),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.color, const Color(0xFF123456));
    });
  });

  group('PlinthText', () {
    testWidgets('renders its data', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthText('Hello')));

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('resolves size through the theme font scale', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthText('Hello', size: PlinthSize.xl)),
      );

      // The point of the component: a PlinthSize rather than a raw
      // fontSize double, so a theme swap restyles every label at once.
      final style = tester.widget<Text>(find.text('Hello')).style!;
      expect(style.fontSize, theme.fontSizes[PlinthSize.xl]);
    });

    testWidgets('resolves a color key at shade 6', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthText('Hello', color: 'red')),
      );

      final style = tester.widget<Text>(find.text('Hello')).style!;
      expect(style.color, theme.color('red', 6));
    });

    testWidgets('leaves color null to inherit the ambient style',
        (tester) async {
      await tester.pumpWidget(_wrap(const PlinthText('Hello')));

      final style = tester.widget<Text>(find.text('Hello')).style!;
      expect(style.color, isNull);
    });

    testWidgets('passes italic, weight, maxLines, and align through',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthText(
            'Hello',
            italic: true,
            weight: FontWeight.w700,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Hello'));
      expect(text.style!.fontStyle, FontStyle.italic);
      expect(text.style!.fontWeight, FontWeight.w700);
      expect(text.maxLines, 2);
      expect(text.textAlign, TextAlign.center);
    });
  });
}
