/// The dashboard's brand, and the only file in it that names a colour.
///
/// Change [brandColor] and every screen re-skins: buttons, charts,
/// badges, the sidebar's active row. Nothing below this file asks for a
/// hue, so nothing below it has to be revisited when the brand changes.
///
/// That is the part worth copying. Most starters hand you a palette and
/// leave contrast as your problem — change the brand to something pale
/// and the labels on it quietly stop being readable. Here the ramp is
/// anchored (shade 6 *is* [brandColor], exactly) and text colours are
/// resolved against a WCAG floor at lookup time, so a brand change moves
/// the colour without dropping the floor.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

/// The one colour to change.
///
/// `generateShades` anchors shade 6 to exactly this value, so what a
/// filled button paints is this colour and not something near it —
/// `test/theme_test.dart` asserts that, so a bad brand fails the build
/// rather than shipping.
const brandColor = Color(0xFF3B5BDB);

/// Order states as roles, not colours.
///
/// `shipped` is the one that earns the indirection: amber at shade 6 is
/// about 1.9:1 on white, nowhere near readable. Declaring it as a role
/// means `semanticText('shipped')` walks the ramp until it clears 4.5:1
/// instead of handing back a label nobody can read. No screen knows that
/// happened.
const orderRoles = <String, PlinthSemanticColor>{
  'paid': PlinthSemanticColor('green'),
  'shipped': PlinthSemanticColor('yellow'),
  'refunded': PlinthSemanticColor('red'),
};

/// One palette slot per revenue channel, held stable by name.
///
/// Charts read these through `theme.seriesFor('web')` rather than being
/// handed a `Color`, which is what lets `data.dart` stay free of any
/// Flutter import. A string crosses that boundary; a `Color` cannot.
const channelSeries = <String, int>{
  'web': 0,
  'retail': 1,
  'wholesale': 2,
  'partners': 3,
};

PlinthTheme _brand(PlinthTheme base) => base.copyWith(
      primaryColor: 'brand',
      colors: {
        ...base.colors,
        'brand': PlinthTheme.generateShades(brandColor),
      },
      semanticColors: orderRoles,
      seriesKeys: channelSeries,
    );

final dashboardLight = _brand(PlinthTheme.defaultTheme);
final dashboardDark = _brand(PlinthTheme.darkTheme);

/// An ordinary `ThemeData` with the Plinth tokens riding along.
///
/// Material's theme is not generated from Plinth — the two are kept in
/// agreement about the fields Plinth owns, and `theme_test.dart` asserts
/// that rather than assuming it.
ThemeData dashboardThemeData(PlinthTheme plinth) => ThemeData(
      useMaterial3: true,
      brightness: plinth.brightness,
      colorScheme: plinth.toColorScheme(),
      scaffoldBackgroundColor: plinth.surfaceSunken,
      extensions: [plinth],
    );
