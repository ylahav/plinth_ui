import 'package:flutter/material.dart';

/// Centers [child] within itself, matching Mantine's `Center`.
///
/// A thin wrapper around Flutter's own [Center] — exists for API
/// consistency with the rest of Plinth (so layout primitives are
/// all `Plinth*`) rather than adding new behavior.
///
/// ```dart
/// PlinthCenter(child: PlinthText('Centered'))
/// ```
class PlinthCenter extends StatelessWidget {
  const PlinthCenter(
      {super.key, required this.child, this.widthFactor, this.heightFactor});

  final Widget child;
  final double? widthFactor;
  final double? heightFactor;

  @override
  Widget build(BuildContext context) {
    return Center(
        widthFactor: widthFactor, heightFactor: heightFactor, child: child);
  }
}
