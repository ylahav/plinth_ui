// A1c — control sizing as a minimum, not a constant.
//
// Most of Plinth already scales with text, because heights come from
// padding rather than being fixed: Button 39->62, Checkbox 32->54,
// Chip 36->56 between textScaler 1.0 and 2.0. `PlinthPagination` was
// the exception, and the one that clipped.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';

/// The painted cell carrying [digit].
///
/// Measured through the `Center` that shrink-wraps it rather than an
/// ancestor `InkWell`: `find.ancestor` does not promise innermost-first,
/// and equal widgets can resolve to the wrong element entirely.
Rect _cellAround(WidgetTester tester, String digit) => tester.getRect(
      find.ancestor(of: find.text(digit), matching: find.byType(Center)).first,
    );

Widget _at(double scale, Widget child) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  group('A1c — controls grow with text rather than clipping it', () {
    for (final scale in [1.0, 1.3, 2.0, 3.0]) {
      testWidgets('pagination fits its digits at $scale', (tester) async {
        await tester.pumpWidget(
          _at(scale, PlinthPagination(total: 5, page: 1, onChanged: (_) {})),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // The digit has to sit inside the cell that carries it. Before
        // this, a single digit measured 28x32 in a fixed 32x32 cell --
        // flush at 2.0 and clipped beyond it.
        final text = tester.getRect(find.text('2'));
        final cell = _cellAround(tester, '2');
        expect(cell.width, greaterThanOrEqualTo(text.width),
            reason: 'digit wider than its cell at $scale');
        expect(cell.height, greaterThanOrEqualTo(text.height),
            reason: 'digit taller than its cell at $scale');
      });
    }

    testWidgets('the cell keeps its ordinary size at ordinary scales',
        (tester) async {
      // A minimum that quietly inflated every control would be a
      // regression dressed as a fix.
      await tester.pumpWidget(
        _at(1.0, PlinthPagination(total: 5, page: 1, onChanged: (_) {})),
      );
      await tester.pumpAndSettle();
      // The control as a whole, which is what a caller sees.
      expect(tester.getSize(find.byType(PlinthPagination)).height, 32);
      final cell = _cellAround(tester, '2');
      expect(cell.height, lessThanOrEqualTo(32));
    });

    testWidgets('the ellipsis gap does not stretch either', (tester) async {
      // Only reachable with enough pages to collapse a run, which is
      // why the first version of this fix left it broken and no test
      // noticed.
      await tester.pumpWidget(
        _at(1.0, PlinthPagination(total: 40, page: 20, onChanged: (_) {})),
      );
      await tester.pumpAndSettle();
      expect(find.text('…'), findsWidgets, reason: 'no run was collapsed');
      expect(tester.getSize(find.byType(PlinthPagination)).height, 32);
    });

    testWidgets('the padding-derived controls were already fine',
        (tester) async {
      // Recorded so nobody "fixes" them: the roadmap assumed a fixed
      // controlHeight was the danger, and for these it never applied.
      Future<double> heightOf(Widget w, double scale) async {
        await tester.pumpWidget(_at(scale, w));
        await tester.pumpAndSettle();
        return tester.getSize(find.byWidget(w)).height;
      }

      final small = await heightOf(
          PlinthButton(onPressed: () {}, child: const Text('S')), 1.0);
      final large = await heightOf(
          PlinthButton(onPressed: () {}, child: const Text('S')), 2.0);
      expect(large, greaterThan(small));
    });
  });
}
