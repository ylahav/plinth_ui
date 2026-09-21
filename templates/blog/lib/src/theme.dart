/// The blog's brand, and the only file in it that names a colour.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

/// The one colour to change.
const brandColor = Color(0xFF0B7285);

/// Section tags as roles.
///
/// Four sections, which is already more than a reader can tell apart by
/// hue — so the tag is always a word, and the colour is a second signal
/// rather than the only one.
const sectionRoles = <String, PlinthSemanticColor>{
  'engineering': PlinthSemanticColor('indigo'),
  'design': PlinthSemanticColor('grape'),
  'research': PlinthSemanticColor('teal'),
  'notes': PlinthSemanticColor('gray'),
};

PlinthTheme _brand(PlinthTheme base) => base.copyWith(
      primaryColor: 'brand',
      colors: {
        ...base.colors,
        'brand': PlinthTheme.generateShades(brandColor),
      },
      semanticColors: sectionRoles,
    );

final blogLight = _brand(PlinthTheme.defaultTheme);
final blogDark = _brand(PlinthTheme.darkTheme);

ThemeData blogThemeData(PlinthTheme plinth) => ThemeData(
      useMaterial3: true,
      brightness: plinth.brightness,
      colorScheme: plinth.toColorScheme(),
      scaffoldBackgroundColor: plinth.surface,
      extensions: [plinth],
    );
