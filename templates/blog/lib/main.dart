import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/theme.dart';

void main() => runApp(
      BlogApp(
        light: blogThemeData(blogLight),
        dark: blogThemeData(blogDark),
      ),
    );
