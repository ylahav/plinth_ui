/// Larder's theme: one brand colour, three semantic roles, and a
/// categorical palette for the shelves.
///
/// This is the whole of the app's colour decision-making. Nothing below
/// this file names a hue — screens ask for `'fresh'` or `'expired'` or
/// `seriesFor(category.name)` and get back whatever this file says that
/// means in the theme currently mounted.
library;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// The app's own colour, and the point of `generateShades`.
///
/// Feed a brand colour in and shade 6 gives it back exactly — so this
/// constant is what a button actually paints, not something near it.
/// `tutorial/test/theme_test.dart` asserts precisely that.
const larderGreen = Color(0xFF2F6F4E);

/// The three states a pantry item can be in, as roles rather than
/// colours.
///
/// `PlinthSemanticColor` is a ramp, a shade on it, and the contrast floor
/// the role is held to. `soon` is the interesting one: amber at shade 6
/// is 1.86:1 on white, nowhere near readable, and declaring it here means
/// `semanticText('soon')` walks the ramp until it clears 4.5:1 instead of
/// handing back an unreadable label. Nothing in the UI has to know that
/// happened.
const larderRoles = <String, PlinthSemanticColor>{
  'fresh': PlinthSemanticColor('green'),
  'soon': PlinthSemanticColor('yellow'),
  'expired': PlinthSemanticColor('red'),
};

/// One colour per shelf, in `PantryCategory`'s declaration order.
///
/// Read through `theme.seriesFor(category.name)`, which takes a *name*.
/// That matters more than it looks: `model.dart` has no Flutter import
/// and no theme, so it could never hand a `Color` to anything. A string
/// crosses that boundary.
const larderShelves = <String, int>{
  'produce': 0,
  'dairy': 1,
  'protein': 2,
  'grain': 3,
  'pantry': 4,
  'spice': 5,
};

PlinthTheme _brand(PlinthTheme base) => base.copyWith(
      primaryColor: 'larder',
      colors: {
        ...base.colors,
        'larder': PlinthTheme.generateShades(larderGreen),
      },
      semanticColors: larderRoles,
      seriesKeys: larderShelves,
    );

final larderLight = _brand(PlinthTheme.defaultTheme);
final larderDark = _brand(PlinthTheme.darkTheme);

/// The `ThemeData` the app mounts, with the Plinth tokens riding along
/// as an extension.
///
/// Note what is *not* happening here: Material's own theme is not being
/// generated from Plinth. It is an ordinary `ThemeData` with an ordinary
/// `ColorScheme`, and `larder_theme_test.dart` asserts the two agree
/// about the fields Plinth owns rather than trusting that they do.
ThemeData larderThemeData(PlinthTheme plinth) => ThemeData(
      useMaterial3: true,
      brightness: plinth.brightness,
      colorScheme: plinth.toColorScheme(),
      scaffoldBackgroundColor: plinth.surfaceSunken,
      extensions: [plinth],
    );
