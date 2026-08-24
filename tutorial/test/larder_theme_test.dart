// What the theme promises the screens, asserted rather than assumed.
//
// Every one of these is a claim the UI relies on without checking:
// screens ask for `semanticText('soon')` and trust that what comes back
// is readable. This is where that trust is earned.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_tutorial/src/larder_theme.dart';
import 'package:plinth_tutorial/src/model.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _ratio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('the brand colour', () {
    test('shade 6 is exactly the colour that was fed in', () {
      // The whole point of an anchored ramp. Without it, asking for the
      // shade every component defaults to returns something near your
      // brand colour rather than your brand colour.
      expect(larderLight.shaded('larder', 6), larderGreen);
    });

    test('light and dark agree about it', () {
      expect(larderDark.color('larder', 6), larderGreen);
    });

    test('it is what the theme reaches for by default', () {
      expect(larderLight.primaryColor, 'larder');
    });
  });

  group('the freshness roles', () {
    for (final theme in [larderLight, larderDark]) {
      final name = theme.brightness == Brightness.light ? 'light' : 'dark';

      for (final state in Freshness.values) {
        test('${state.role} is readable as text in $name', () {
          // `semanticText` walks the ramp until it clears the role's
          // floor. This asserts it actually got there — in both themes,
          // where the surface behind it is a different colour.
          expect(
            _ratio(theme.semanticText(state.role), theme.surface),
            greaterThanOrEqualTo(4.5),
            reason: '${state.role} labels sit on the page surface',
          );
        });

        test('${state.role} is readable on its own wash in $name', () {
          // The label does not sit on the page — it sits on the tint.
          // Resolving against the wrong background is the silent kind of
          // miss: `readableOn` was called, a number was cleared, and the
          // number was against a surface the text never touches.
          final wash = theme.semanticWash(state.role);
          expect(
            _ratio(theme.semanticText(state.role, on: wash), wash),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    }

    test('"use soon" is not simply amber at shade 6', () {
      // The role that proves the machinery is doing something. Yellow
      // shade 6 is 1.86:1 on white — visible, unreadable — so the
      // resolved text colour has to differ from the fill.
      expect(
        larderLight.semanticText('soon'),
        isNot(larderLight.semantic('soon')),
      );
      expect(_ratio(larderLight.semantic('soon'), larderLight.surface),
          lessThan(4.5));
    });

    test('every Freshness state names a role the theme declares', () {
      // Freshness lives in model.dart, the roles live in the theme, and
      // nothing but this connects them. Renaming one without the other
      // would silently fall back to treating the role name as a ramp
      // key and render the primary colour with no complaint.
      for (final state in Freshness.values) {
        expect(larderLight.hasSemantic(state.role), isTrue,
            reason: '${state.role} is not declared in larderRoles');
      }
    });
  });

  group('the shelf palette', () {
    test('every category resolves to its own colour', () {
      final colours = {
        for (final category in PantryCategory.values)
          category.name: larderLight.seriesFor(category.name),
      };
      expect(colours.values.toSet(), hasLength(PantryCategory.values.length),
          reason: 'two shelves sharing a colour makes the stripe useless');
    });

    test('every category has a declared position', () {
      // `seriesFor` wraps rather than throwing, so an undeclared
      // category would quietly share a colour with another one.
      for (final category in PantryCategory.values) {
        expect(larderShelves.containsKey(category.name), isTrue,
            reason: '${category.name} is missing from larderShelves');
      }
    });
  });

  group('Material and Plinth agree', () {
    for (final theme in [larderLight, larderDark]) {
      final name = theme.brightness == Brightness.light ? 'light' : 'dark';

      test('about every field Plinth owns, in $name', () {
        // The app keeps an ordinary ThemeData. This is the check that
        // stops the two palettes drifting apart silently — the thing a
        // migration actually wanted, rather than a generated theme.
        final data = larderThemeData(theme);
        expect(theme.colorSchemeDisagreements(data.colorScheme), isEmpty);
      });

      test('and the extension is actually mounted, in $name', () {
        expect(larderThemeData(theme).plinth.primaryColor, 'larder');
      });
    }
  });
}
