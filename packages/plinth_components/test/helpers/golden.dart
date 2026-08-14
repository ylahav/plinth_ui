import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// The key every golden test matches against. Shared so the boundary
/// and the finder can't drift apart.
const ValueKey<String> goldenBoundary = ValueKey('golden-boundary');

/// Wraps [child] for a golden test: sized to a fixed rectangle via
/// [RepaintBoundary] + [SizedBox] rather than filling the whole test
/// surface.
///
/// Golden images should be tightly cropped around the widget under
/// test, not a full-screen screenshot, so a diff highlights what
/// changed instead of drowning it in unrelated whitespace.
///
/// Extracted from `plinth_button_golden_test.dart` once there were
/// three golden files, which is the point `docs/TESTING.md` names for
/// sharing it rather than copying it a third time. The light path is
/// deliberately identical to what that file used — anything else here
/// would shift the committed button images, since the scaffold's
/// background shows through the cropped region.
///
/// Note that `flutter test` renders with a placeholder test font, so
/// text appears as solid blocks. That's what makes these images
/// reproducible across machines; it does mean they catch colour,
/// layout, padding and border changes but not font rendering.
Widget goldenWrap(
  Widget child, {
  double width = 300,
  double height = 100,
  bool dark = false,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark
        ? ThemeData(
            brightness: Brightness.dark,
            extensions: [PlinthTheme.darkTheme],
          )
        : ThemeData(extensions: [PlinthTheme.defaultTheme]),
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: goldenBoundary,
          child: SizedBox(
            width: width,
            height: height,
            child: Center(child: child),
          ),
        ),
      ),
    ),
  );
}
