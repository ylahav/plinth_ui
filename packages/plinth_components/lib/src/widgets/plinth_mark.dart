import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Highlighted inline text matching Mantine's `Mark`, e.g. for
/// highlighting search-match terms within a larger block of text.
///
/// ```dart
/// Text.rich(TextSpan(children: [
///   const TextSpan(text: 'The '),
///   WidgetSpan(child: PlinthMark('quick brown fox')),
///   const TextSpan(text: ' jumps.'),
/// ]))
/// ```
class PlinthMark extends StatelessWidget {
  const PlinthMark(this.label, {super.key, this.color});

  final String label;

  /// Highlight color key. Defaults to `'yellow'` if the active theme
  /// defines it, matching the conventional highlighter look;
  /// otherwise falls back to a literal amber so this doesn't silently
  /// render in the theme's primary brand color instead.
  final String? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? 'yellow';
    final background = theme.colors.containsKey(colorKey)
        ? theme.shaded(colorKey, 2)
        : const Color(0xFFFFF3BF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      color: background,
      child: Text(label),
    );
  }
}
