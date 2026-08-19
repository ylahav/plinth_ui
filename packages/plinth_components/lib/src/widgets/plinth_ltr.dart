import 'package:flutter/widgets.dart';

/// Pins [child] to left-to-right inside a right-to-left page.
///
/// Some content is not language and must not flip with it: a chart's
/// bars and axis, a time axis, a currency figure, a version string. In
/// an RTL app those read wrong — or plot backwards — if they inherit
/// the page direction.
///
/// ```dart
/// PlinthLtr(
///   child: CustomPaint(painter: BarsPainter(months)),
/// )
/// ```
///
/// This is `Directionality(textDirection: TextDirection.ltr, …)` with a
/// name. The wrapper exists because every bidirectional app writes that
/// line by hand, and because the bare version says *what it does* while
/// this says *why* — the next person to read it does not have to work
/// out whether the direction was pinned on purpose.
///
/// **Reach for it narrowly.** Validating the library against a
/// Hebrew/English app found RTL already correct: 12 of 12
/// page × language combinations rendered clean, and a setup wizard
/// walked end to end at `textScaler` 2.0 in both directions. This is not
/// a fix for RTL problems, and wrapping a page in it to make one go away
/// will produce a page that is wrong in a harder-to-see way. It is for
/// the specific content that genuinely has no direction of its own.
///
/// Text inside stays subject to Unicode bidi as usual — pinning the
/// direction sets the base direction for layout and for resolving
/// neutral characters, it does not force glyph order.
class PlinthLtr extends StatelessWidget {
  const PlinthLtr({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: child);
  }
}
