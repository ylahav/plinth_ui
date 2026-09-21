/// The account app's brand, and the only file in it that names a colour.
///
/// Same shape as every Plinth app: one brand colour, a handful of states
/// declared as *roles*, and nothing below this file asking for a hue.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

/// The one colour to change.
const brandColor = Color(0xFF7048E8);

/// Team roles as roles, in both senses.
///
/// `invited` is the one that earns the indirection — it wants to read as
/// "not yet real", which is grey, and grey is the family where a shade
/// chosen by eye is most likely to land under 4.5:1. Declaring it means
/// `semanticText('invited')` walks the ramp instead of trusting the
/// choice.
const teamRoles = <String, PlinthSemanticColor>{
  'owner': PlinthSemanticColor('violet'),
  'admin': PlinthSemanticColor('blue'),
  'member': PlinthSemanticColor('teal'),
  'invited': PlinthSemanticColor('gray'),
};

PlinthTheme _brand(PlinthTheme base) => base.copyWith(
      primaryColor: 'brand',
      colors: {
        ...base.colors,
        'brand': PlinthTheme.generateShades(brandColor),
      },
      semanticColors: teamRoles,
    );

final accountLight = _brand(PlinthTheme.defaultTheme);
final accountDark = _brand(PlinthTheme.darkTheme);

ThemeData accountThemeData(PlinthTheme plinth) => ThemeData(
      useMaterial3: true,
      brightness: plinth.brightness,
      colorScheme: plinth.toColorScheme(),
      scaffoldBackgroundColor: plinth.surfaceSunken,
      extensions: [plinth],
    );
