import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/theme.dart';

void main() => runApp(
      AccountApp(
        light: accountThemeData(accountLight),
        dark: accountThemeData(accountDark),
      ),
    );
