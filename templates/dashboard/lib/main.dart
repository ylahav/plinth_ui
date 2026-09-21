import 'package:flutter/material.dart';

import 'src/app_shell.dart';
import 'src/theme.dart';

void main() => runApp(
      DashboardApp(
        light: dashboardThemeData(dashboardLight),
        dark: dashboardThemeData(dashboardDark),
      ),
    );
