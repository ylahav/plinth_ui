import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/theme.dart';

void main() => runApp(
      MobileApp(
        light: mobileThemeData(mobileLight),
        dark: mobileThemeData(mobileDark),
      ),
    );
