/// The app's brand, and the only file in it that names a colour.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

/// The one colour to change.
const brandColor = Color(0xFFE8590C);

/// Delivery states as roles.
///
/// `delayed` is the one that earns it: it wants to be amber, and amber
/// at shade 6 is about 1.9:1 on white. Declared as a role, the ramp is
/// walked until it clears 4.5:1 and no screen has to know.
const shipmentRoles = <String, PlinthSemanticColor>{
  'delivered': PlinthSemanticColor('green'),
  'in transit': PlinthSemanticColor('blue'),
  'delayed': PlinthSemanticColor('yellow'),
  'lost': PlinthSemanticColor('red'),
};

PlinthTheme _brand(PlinthTheme base) => base.copyWith(
      primaryColor: 'brand',
      colors: {
        ...base.colors,
        'brand': PlinthTheme.generateShades(brandColor),
      },
      semanticColors: shipmentRoles,
    );

final mobileLight = _brand(PlinthTheme.defaultTheme);
final mobileDark = _brand(PlinthTheme.darkTheme);

ThemeData mobileThemeData(PlinthTheme plinth) => ThemeData(
      useMaterial3: true,
      brightness: plinth.brightness,
      colorScheme: plinth.toColorScheme(),
      scaffoldBackgroundColor: plinth.surfaceSunken,
      extensions: [plinth],
    );
