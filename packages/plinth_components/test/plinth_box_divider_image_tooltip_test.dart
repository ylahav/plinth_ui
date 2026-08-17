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

  group('PlinthBox', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBox(child: Text('Boxed'))),
      );

      expect(find.text('Boxed'), findsOneWidget);
    });

    testWidgets('renders without a child', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthBox(w: 40, h: 40)));

      expect(tester.takeException(), isNull);
    });

    testWidgets('resolves padding through the spacing scale', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBox(p: PlinthSize.lg, child: Text('Boxed'))),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PlinthBox),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        container.padding,
        EdgeInsets.all(theme.spacing[PlinthSize.lg]!),
      );
    });

    testWidgets('axis-specific padding overrides the shorthand',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthBox(
            px: PlinthSize.lg,
            py: PlinthSize.xs,
            child: Text('Boxed'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PlinthBox),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        container.padding,
        EdgeInsets.symmetric(
          horizontal: theme.spacing[PlinthSize.lg]!,
          vertical: theme.spacing[PlinthSize.xs]!,
        ),
      );
    });

    testWidgets('sizes to w and h', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBox(w: 120, h: 40, child: SizedBox())),
      );

      final size = tester.getSize(
        find
            .descendant(
              of: find.byType(PlinthBox),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(size.width, 120);
      expect(size.height, 40);
    });

    testWidgets('resolves bg through the theme palette', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthBox(bg: 'blue', child: Text('Boxed'))),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PlinthBox),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, isNotNull);
    });
  });

  group('PlinthDivider', () {
    testWidgets('renders a plain rule with no label', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthDivider()));

      expect(find.byType(Divider), findsOneWidget);
      expect(find.byType(PlinthText), findsNothing);
    });

    testWidgets('a label sits between two rules', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthDivider(label: 'OR')));

      expect(find.text('OR'), findsOneWidget);
      // One rule either side, which is what makes it read as a
      // separator rather than a heading.
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('vertical uses a VerticalDivider', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthDivider(direction: Axis.vertical, height: 40)),
      );

      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('uses the color it was given', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthDivider(color: Color(0xFF123456))),
      );

      expect(
        tester.widget<Divider>(find.byType(Divider)).color,
        const Color(0xFF123456),
      );
    });

    testWidgets('defaults to the hairline it always drew', (tester) async {
      await tester.pumpWidget(_wrap(const PlinthDivider()));

      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.thickness, equals(1));
      // The space it occupies matches the line it draws, so a rule
      // never reserves padding it doesn't paint.
      expect(divider.height, equals(1));
    });

    testWidgets('size steps the thickness', (tester) async {
      for (final (size, expected) in const [
        (PlinthSize.xs, 1.0),
        (PlinthSize.sm, 2.0),
        (PlinthSize.md, 3.0),
        (PlinthSize.lg, 4.0),
        (PlinthSize.xl, 5.0),
      ]) {
        await tester.pumpWidget(_wrap(PlinthDivider(size: size)));
        expect(
          tester.widget<Divider>(find.byType(Divider)).thickness,
          equals(expected),
          reason: 'thickness for $size',
        );
      }
    });

    testWidgets('size thickens a vertical rule too, and height is its length',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthDivider(
          direction: Axis.vertical,
          height: 40,
          size: PlinthSize.lg,
        )),
      );

      // The two props answer different questions, which is the whole
      // reason both exist: 4 across, 40 along.
      expect(
        tester.widget<VerticalDivider>(find.byType(VerticalDivider)).thickness,
        equals(4),
      );
      expect(tester.getSize(find.byType(VerticalDivider)).height, equals(40));
    });

    testWidgets('a labelled rule thickens on both sides', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthDivider(label: 'OR', size: PlinthSize.md)),
      );

      final rules = tester.widgetList<Divider>(find.byType(Divider));
      expect(rules.length, equals(2));
      for (final rule in rules) {
        expect(rule.thickness, equals(3));
      }
    });
  });

  group('PlinthImage', () {
    testWidgets('renders an Image.network for its src', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthImage(src: 'https://example.invalid/a.png')),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows a broken-image fallback when the load fails',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthImage(src: 'https://example.invalid/a.png')),
      );
      // The test HTTP client fails every request, which is exactly the
      // path worth covering: Image.network alone would surface this as
      // a raw render error.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('passes width, height, and fit through', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthImage(
            src: 'https://example.invalid/a.png',
            width: 120,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 120);
      expect(image.height, 80);
      expect(image.fit, BoxFit.contain);
    });
  });

  group('theme tokens reach the widgets', () {
    Widget wrapDark(Widget child) {
      return MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.darkTheme]),
        home: Scaffold(body: child),
      );
    }

    Color paperColor(WidgetTester tester) {
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PlinthPaper),
              matching: find.byType(Container),
            )
            .first,
      );
      return (container.decoration! as BoxDecoration).color!;
    }

    testWidgets('a surface follows the registered theme', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthPaper(child: Text('Body'))),
      );
      expect(paperColor(tester), PlinthTheme.defaultTheme.surface);

      await tester.pumpWidget(
        wrapDark(const PlinthPaper(child: Text('Body'))),
      );
      // MaterialApp animates a theme change, and PlinthTheme.lerp
      // snaps at the midpoint rather than interpolating each token —
      // so the swap only lands once the transition is past halfway.
      await tester.pumpAndSettle();

      // The whole point of the token extraction: swapping the theme
      // repaints the surface, where a hardcoded Colors.white would not
      // have moved.
      expect(paperColor(tester), PlinthTheme.darkTheme.surface);
    });

    testWidgets('an input border follows the registered theme', (tester) async {
      Color borderOf(WidgetTester tester) {
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(PlinthTextInput),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = container.decoration! as BoxDecoration;
        return (decoration.border! as Border).top.color;
      }

      await tester.pumpWidget(_wrap(const PlinthTextInput()));
      expect(borderOf(tester), PlinthTheme.defaultTheme.border);

      await tester.pumpWidget(wrapDark(const PlinthTextInput()));
      await tester.pumpAndSettle();
      expect(borderOf(tester), PlinthTheme.darkTheme.border);
    });

    testWidgets('a filled button labels itself against its own fill',
        (tester) async {
      Color labelColor(WidgetTester tester) {
        return tester
            .widget<DefaultTextStyle>(
              find
                  .descendant(
                    of: find.byType(PlinthButton),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .last,
            )
            .style
            .color!;
      }

      // The foreground follows the *fill's* lightness, not the theme's.
      // A dark theme mirrors the accent to a lighter shade, so the same
      // button that carries a white label in light mode needs a dark
      // one here — tying the label to brightness instead would get this
      // backwards in exactly the case it is meant to handle.
      await tester.pumpWidget(
        _wrap(PlinthButton(onPressed: () {}, child: const Text('Save'))),
      );
      expect(
        labelColor(tester),
        PlinthTheme.defaultTheme
            .contrastingOn(PlinthTheme.defaultTheme.shaded('blue', 6)),
      );

      await tester.pumpWidget(
        wrapDark(PlinthButton(onPressed: () {}, child: const Text('Save'))),
      );
      await tester.pumpAndSettle();
      expect(
        labelColor(tester),
        PlinthTheme.darkTheme
            .contrastingOn(PlinthTheme.darkTheme.shaded('blue', 6)),
      );
    });
  });

  group('PlinthTooltip', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTooltip(message: 'Copied', child: Text('Trigger')),
        ),
      );

      expect(find.text('Trigger'), findsOneWidget);
      expect(find.text('Copied'), findsNothing);
    });

    testWidgets('a long press reveals the message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTooltip(message: 'Copied', child: Text('Trigger')),
        ),
      );

      await tester.longPress(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Copied'), findsOneWidget);
    });

    testWidgets('wraps Flutter\'s own Tooltip', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlinthTooltip(message: 'Copied', child: Text('Trigger')),
        ),
      );

      // Deliberately a wrapper: hover/long-press timing and dismissal
      // are not worth re-deriving.
      expect(
        tester.widget<Tooltip>(find.byType(Tooltip)).message,
        'Copied',
      );
    });

    testWidgets('position picks the side, and defaults to above',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTooltip(message: 'Copied', child: Text('Trigger'))),
      );
      expect(tester.widget<Tooltip>(find.byType(Tooltip)).preferBelow, isFalse);

      await tester.pumpWidget(
        _wrap(const PlinthTooltip(
          message: 'Copied',
          position: PlinthTooltipPosition.bottom,
          child: Text('Trigger'),
        )),
      );
      expect(tester.widget<Tooltip>(find.byType(Tooltip)).preferBelow, isTrue);
    });

    testWidgets('the open delay is the caller\'s to set', (tester) async {
      // Fixed at 400ms until 0.19.0: a toolbar of icons wants it
      // shorter, a tooltip repeating a visible label wants it longer.
      await tester.pumpWidget(
        _wrap(const PlinthTooltip(
          message: 'Copied',
          openDelay: Duration(milliseconds: 50),
          child: Text('Trigger'),
        )),
      );

      expect(
        tester.widget<Tooltip>(find.byType(Tooltip)).waitDuration,
        const Duration(milliseconds: 50),
      );
    });

    testWidgets('a colored tooltip reads against its own fill', (tester) async {
      await tester.pumpWidget(
        _wrap(const PlinthTooltip(
          message: 'Deletes everything',
          color: 'red',
          child: Text('Trigger'),
        )),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      final theme = PlinthTheme.defaultTheme;
      final fill = theme.shaded('red', 6);

      expect((tooltip.decoration as BoxDecoration).color, fill);
      // Not the theme's text color: the tooltip is a filled surface
      // like any other, so its label resolves against the fill.
      expect(tooltip.textStyle?.color, theme.contrastingOn(fill));
    });
  });
}
