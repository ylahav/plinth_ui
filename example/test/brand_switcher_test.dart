// The rebrand claim, asserted rather than demonstrated.
//
// `src/brand_switcher.dart` invites anyone to re-skin the demo to a
// colour of their choosing and watch the contrast readout hold. That is
// a claim, and a demo can only show it for the colours somebody clicked.
// These check it for the hostile ones on purpose — including `yellow`,
// which `plinth_readme_claims_test.dart` pins at 1.86:1 against white,
// the worst ramp in the palette.
//
// The failure this guards against is not subtle and is what every
// library that hardcodes a foreground ships: rebrand to yellow, and the
// label on a filled button becomes white-on-yellow.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:plinth_example/src/brand_switcher.dart';

/// Brand colours chosen to be difficult, not flattering.
const _hostileBrands = <String, Color>{
  'yellow (1.86:1 at shade 6)': Color(0xFFFFD43B),
  'cyan (2.79:1 at shade 6)': Color(0xFF15AABF),
  'near-white': Color(0xFFFAFAFA),
  'near-black': Color(0xFF0A0A0A),
  'saturated lime': Color(0xFFCCFF00),
};

void main() {
  group('brandedTheme', () {
    test('a null brand returns the base theme untouched', () {
      final base = PlinthTheme.defaultTheme;
      expect(identical(brandedTheme(base, null), base), isTrue);
    });

    test('the primary ramp comes back anchored to the brand colour', () {
      // The anchoring is what makes this a rebrand rather than an
      // approximation: ask for #FF3B30 and shade 6 *is* #FF3B30.
      for (final entry in _hostileBrands.entries) {
        final theme = brandedTheme(PlinthTheme.defaultTheme, entry.value);
        expect(
          theme.shaded(theme.primaryColor, 6),
          equals(entry.value),
          reason: entry.key,
        );
      }
    });

    test('it leaves every other ramp alone', () {
      final base = PlinthTheme.defaultTheme;
      final branded = brandedTheme(base, const Color(0xFFFFD43B));

      for (final ramp in base.colors.keys) {
        if (ramp == base.primaryColor) continue;
        expect(branded.colors[ramp], equals(base.colors[ramp]), reason: ramp);
      }
    });

    test('it leaves the neutral chrome alone', () {
      final base = PlinthTheme.defaultTheme;
      final branded = brandedTheme(base, const Color(0xFFFFD43B));

      expect(branded.surface, equals(base.surface));
      expect(branded.text, equals(base.text));
      expect(branded.border, equals(base.border));
    });
  });

  group('a rebrand holds the AA floor', () {
    for (final entry in _hostileBrands.entries) {
      for (final base in [PlinthTheme.defaultTheme, PlinthTheme.darkTheme]) {
        final mode = base.brightness == Brightness.dark ? 'dark' : 'light';

        test('${entry.key}, $mode', () {
          final theme = brandedTheme(base, entry.value);
          final ramp = theme.primaryColor;

          // Accent text on the page, which is the row that moves: the
          // resolution walks the ramp until something clears the floor.
          final accent = theme.readableOn(ramp, theme.surface);
          expect(
            PlinthTheme.contrastRatio(accent, theme.surface),
            greaterThanOrEqualTo(PlinthContrast.body.ratio),
            reason: 'accent text on the surface',
          );

          // The label a filled button picks for itself. `contrastingOn`
          // chooses between two foregrounds rather than walking a ramp,
          // so this is the 3:1 large-text floor, not 4.5 — a button
          // label is large text by WCAG's definition at these sizes.
          final fill = theme.shaded(ramp, 6);
          expect(
            PlinthTheme.contrastRatio(theme.contrastingOn(fill), fill),
            greaterThanOrEqualTo(PlinthContrast.large.ratio),
            reason: 'label on a filled button',
          );
        });
      }
    }

    test('the naive colour would have failed, which is the point', () {
      // Guards the test above from becoming vacuous. If shade 6 on the
      // surface already cleared the floor for yellow, the resolution
      // would not be doing anything and this suite would pass for the
      // wrong reason.
      final theme = brandedTheme(
        PlinthTheme.defaultTheme,
        const Color(0xFFFFD43B),
      );
      final naive = theme.shaded(theme.primaryColor, 6);

      expect(
        PlinthTheme.contrastRatio(naive, theme.surface),
        lessThan(PlinthContrast.body.ratio),
      );
    });
  });

  group('the control', () {
    testWidgets('picking a brand re-skins the app', (tester) async {
      Color? picked;

      await tester.pumpWidget(
        _host(
          brand: null,
          onChanged: (c) => picked = c,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Change the brand colour'));
      await tester.pumpAndSettle();

      // Tooltips carry the preset names.
      await tester.tap(find.byTooltip('Yellow').first);
      await tester.pump();

      expect(picked, equals(const Color(0xFFFFD43B)));
    });

    testWidgets('the readout reports a passing ratio for a hostile brand',
        (tester) async {
      await tester.pumpWidget(
        _host(brand: const Color(0xFFFFD43B), onChanged: (_) {}),
      );

      await tester.tap(find.bySemanticsLabel('Change the brand colour'));
      await tester.pumpAndSettle();

      // Every ratio badge on the panel is a "N.NN:1" string; none of
      // them may be under the floor the panel claims to hold.
      final badges = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .where((s) => RegExp(r'^\d+\.\d\d:1$').hasMatch(s))
          .toList();

      expect(badges, isNotEmpty, reason: 'the readout rendered no ratios');
      for (final badge in badges) {
        final ratio = double.parse(badge.split(':').first);
        expect(
          ratio,
          greaterThanOrEqualTo(PlinthContrast.large.ratio),
          reason: '$badge is below even the large-text floor',
        );
      }
    });
  });
}

Widget _host({required Color? brand, required ValueChanged<Color?> onChanged}) {
  final theme = brandedTheme(PlinthTheme.defaultTheme, brand);

  return BrandSwitcher(
    brand: brand,
    onChanged: onChanged,
    child: MaterialApp(
      theme: ThemeData(extensions: [theme]),
      home: const Scaffold(
        appBar: null,
        body: Center(child: BrandPickerButton()),
      ),
    ),
  );
}
