import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// An inline code snippet matching Mantine's `Code`: monospace text
/// on a subtle tinted background, for referencing identifiers,
/// commands, or file names within a sentence.
///
/// ```dart
/// Text.rich(TextSpan(children: [
///   const TextSpan(text: 'Run '),
///   WidgetSpan(child: PlinthCode('flutter pub get')),
///   const TextSpan(text: ' first.'),
/// ]))
/// ```
class PlinthCode extends StatelessWidget {
  const PlinthCode(this.label,
      {super.key, this.color, this.size = PlinthSize.md});

  final String label;
  final String? color;
  final PlinthSize size;

  static const Map<PlinthSize, double> _fontSizes = {
    PlinthSize.xs: 11,
    PlinthSize.sm: 12,
    PlinthSize.md: 13,
    PlinthSize.lg: 15,
    PlinthSize.xl: 17,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? 'gray';
    final background = theme.color(colorKey, 1);
    final foreground = theme.color(colorKey, 8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: _fontSizes[size],
          color: foreground,
        ),
      ),
    );
  }
}
