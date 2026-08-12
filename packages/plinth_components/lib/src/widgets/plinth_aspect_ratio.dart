import 'package:flutter/material.dart';

/// Constrains [child] to a given width/height ratio, matching
/// Mantine's `AspectRatio` — the common case is reserving space for
/// an image or embed before it loads, so layout doesn't jump.
///
/// A thin wrapper around Flutter's own [AspectRatio] — exists for
/// API consistency with the rest of Plinth.
///
/// ```dart
/// PlinthAspectRatio(
///   ratio: 16 / 9,
///   child: Image.network(url, fit: BoxFit.cover),
/// )
/// ```
class PlinthAspectRatio extends StatelessWidget {
  const PlinthAspectRatio(
      {super.key, required this.ratio, required this.child});

  final double ratio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: ratio, child: child);
  }
}
