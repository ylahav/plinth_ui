/// Validation pointed at Plinth's own themes first.
///
/// A validator that passes its author's theme and fails everyone
/// else's is a validator nobody trusts. These pin what it says about
/// the defaults, including the one thing it legitimately complains
/// about.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';

void main() {
  group('the default themes', () {
    test('what the defaults actually fail, stated rather than assumed', () {
      // A validator that passes its author's theme and fails everyone
      // else's is a validator nobody trusts. Pointed at Plinth's own
      // defaults it finds two things, and both are left as-is on
      // purpose -- fixing either changes the look of every screen in
      // every app already on Plinth, which is a decision for a release
      // rather than something to slip into a validator's first commit.
      //
      // 1. `border` is 1.26-1.49:1 against the three surfaces, where
      //    WCAG 1.4.11 asks 3:1 of the visual information required to
      //    *identify* a component. `plinthFieldBorderColor` returns it
      //    for every input that is neither focused nor in error, so it
      //    is the resting boundary of every field in the library.
      //
      // 2. In the dark theme only, `textMuted` on `surfaceSunken` is
      //    4.36:1 against a 4.5 floor. A narrow miss, and narrow misses
      //    are exactly what a person checking by eye lets through.
      //
      // This fails if either changes in either direction. A new finding
      // is a regression; a missing one means somebody fixed it and
      // should delete the line rather than loosen it.
      final light = PlinthTheme.defaultTheme.validate(includeSeries: false);
      expect(
        light.map((i) => '${i.foreground} on ${i.background}').toSet(),
        {
          'border on surface',
          'border on surfaceMuted',
          'border on surfaceSunken',
        },
        reason: light.join(', '),
      );

      final dark = PlinthTheme.darkTheme.validate(includeSeries: false);
      expect(
        dark.map((i) => '${i.foreground} on ${i.background}').toSet(),
        {
          'border on surface',
          'border on surfaceMuted',
          'border on surfaceSunken',
          'textMuted on surfaceSunken',
        },
        reason: dark.join(', '),
      );
    });

    test('body text itself is clear on both themes', () {
      for (final theme in [PlinthTheme.defaultTheme, PlinthTheme.darkTheme]) {
        final issues = theme
            .validate(includeSeries: false)
            .where((i) => i.foreground == 'text')
            .toList();
        expect(issues, isEmpty, reason: issues.join(', '));
      }
    });

    test('the series palette is the known exception, and it is reported', () {
      // Recorded rather than hidden. The categorical palette varies
      // lightness so colour-blind readers can tell the series apart,
      // which is in direct tension with contrast against one surface.
      // The chart widgets lift the failing ones at paint time via
      // `readableOn`; the raw tokens do not, and a validator that
      // pretended otherwise would be lying about its own library.
      final series = PlinthTheme.defaultTheme
          .validate()
          .where((i) => i.foreground.startsWith('series.'))
          .toList();

      expect(series, isNotEmpty,
          reason: 'the series palette used to fail 3:1 — if it now '
              'passes, delete this test rather than loosening it');
      for (final issue in series) {
        expect(issue.level, PlinthContrast.nonText);
        expect(issue.background, 'surface');
      }
    });

    test('and series can be excluded, since charts lift them', () {
      final issues = PlinthTheme.defaultTheme.validate(includeSeries: false);
      expect(issues.any((i) => i.foreground.startsWith('series.')), isFalse);
    });
  });

  group('a hostile brand', () {
    test('yellow text on white is caught', () {
      // #FFFF00 on white is about 1.07:1 — the worst case the repo
      // already uses as its rebrand stress test.
      final bad = PlinthTheme.defaultTheme.copyWith(
        text: const Color(0xFFFFFF00),
      );
      final issues = bad.validate(includeSeries: false);

      expect(issues, isNotEmpty);
      // Worst first, and yellow-on-white beats the border finding by a
      // wide margin.
      final worst = issues.first;
      expect(worst.foreground, 'text');
      expect(worst.ratio, lessThan(2));
      expect(worst.required, 4.5);
    });

    test('worst first, so the first fix is the biggest one', () {
      final bad = PlinthTheme.defaultTheme.copyWith(
        text: const Color(0xFFFFFF00),
        textMuted: const Color(0xFF767676),
      );
      final issues = bad.validate(includeSeries: false);

      for (var i = 1; i < issues.length; i++) {
        expect(
            issues[i - 1].shortfall, greaterThanOrEqualTo(issues[i].shortfall));
      }
    });

    test('a pale surface is caught through the text that sits on it', () {
      // Checking the surface directly would be the wrong shape: a
      // surface is not unreadable by itself, only in company.
      final bad = PlinthTheme.defaultTheme.copyWith(
        surface: const Color(0xFF3A3A3A),
      );
      final issues = bad.validate(includeSeries: false);

      expect(
        issues.any((i) => i.foreground == 'text' && i.background == 'surface'),
        isTrue,
      );
    });
  });

  group('what it deliberately does not flag', () {
    test('textDisabled, which WCAG 1.4.3 exempts', () {
      // Flagging it would be flagging the guideline.
      final issues = PlinthTheme.defaultTheme.validate();
      expect(issues.any((i) => i.foreground == 'textDisabled'), isFalse);
    });

    test('borderMuted, which the library calls decoration', () {
      final issues = PlinthTheme.defaultTheme.validate();
      expect(issues.any((i) => i.foreground == 'borderMuted'), isFalse);
    });

    test('onFilled over a ramp, a pair nothing actually paints', () {
      // Filled surfaces use `contrastingOn`, which picks black or white
      // per background. A first version checked all thirteen ramps and
      // produced thirteen findings about colours that never meet.
      final issues = PlinthTheme.defaultTheme.validate();
      expect(issues.any((i) => i.foreground == 'onFilled'), isFalse);
    });
  });

  test('an issue names tokens by their hierarchy path', () {
    // So a finding can be looked up with `theme.token(path)` or grepped
    // for in the design file it came from.
    final bad = PlinthTheme.defaultTheme
        .copyWith(text: const Color(0xFFFFFF00))
        .validate(includeSeries: false);

    expect(PlinthTheme.defaultTheme.token(bad.first.foreground), isNotNull);
    expect(PlinthTheme.defaultTheme.token(bad.first.background), isNotNull);
  });
}
