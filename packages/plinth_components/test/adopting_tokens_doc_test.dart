// Compile-check for the code in docs/ADOPTING_TOKENS.md.
//
// That guide's whole value is that an adopter can paste from it, so a
// stale example is worse than no example. This file mirrors every API
// call the guide makes; if one is renamed or removed, this fails rather
// than the guide quietly becoming wrong.
//
// It is deliberately the same class of guard the example app's
// `demo_code.dart` snippets do NOT have -- those are hand-maintained
// string literals that still compile and still render when they drift.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

Color _actionColor(PlinthTheme t, String action) => switch (action) {
      'buy' => t.semantic('income'),
      'sell' => t.semantic('expense'),
      _ => t.textMuted,
    };

Color flowColor(PlinthTheme t, String flow) =>
    t.semantic(flow == 'in' ? 'income' : 'expense');

class BarsPainter extends CustomPainter {
  BarsPainter(
      {required this.bars, required this.barColor, required this.axisColor});
  final List<double> bars;
  final Color barColor;
  final Color axisColor;
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(BarsPainter old) =>
      old.bars != bars ||
      old.barColor != barColor ||
      old.axisColor != axisColor;
}

void main() {
  test('every API the guide uses exists and type-checks', () {
    final theme = PlinthTheme.defaultTheme;

    // 1. const colour maps -> methods
    expect(_actionColor(theme, 'buy'), isA<Color>());
    expect(flowColor(theme, 'in'), isA<Color>());

    // 2. themed widgets
    expect(
        Icon(Icons.delete_outline,
            color: theme.roleShaded(PlinthRole.error, 6)),
        isA<Icon>());
    expect(TextStyle(color: theme.roleShaded(PlinthRole.error, 6)),
        isA<TextStyle>());

    // 3. name across a layer boundary
    expect(theme.seriesFor('groceries'), isA<Color>());

    // 4. painter
    expect(
        BarsPainter(
            bars: const [], barColor: theme.surface, axisColor: theme.border),
        isA<CustomPainter>());

    // The spacing claim: these are compile-time constants.
    const box = SizedBox(height: PlinthSpacing.md);
    const pad = EdgeInsets.all(PlinthSpacing.sm);
    expect(box.height, 16);
    expect(pad.left, 12);
    expect(theme.space(2), 8);
    expect(theme.spacing[PlinthSize.md], 16);

    // The agreement check.
    expect(theme.colorSchemeDisagreements(theme.toColorScheme()), isEmpty);
  });

  testWidgets('the showOn recipe and PlinthLtr compile', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(body: Builder(builder: (context) {
        return PlinthLtr(
          child: TextButton(
            onPressed: () async {
              // The guide's recipe: capture before the await.
              final messenger = ScaffoldMessenger.of(context);
              await Future<void>.delayed(Duration.zero);
              PlinthNotification.showOn(messenger, child: const Text('Saved'));
            },
            child: const Text('Go'),
          ),
        );
      })),
    ));
    await tester.tap(find.text('Go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved'), findsOneWidget);
  });
}
