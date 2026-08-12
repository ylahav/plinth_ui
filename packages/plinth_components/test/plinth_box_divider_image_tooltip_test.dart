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
        _wrap(const PlinthDivider(vertical: true, height: 40)),
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
  });
}
