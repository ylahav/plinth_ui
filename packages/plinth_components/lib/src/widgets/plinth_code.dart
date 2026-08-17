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
///
/// [PlinthCode.block] is the multi-line form — a snippet that stands on
/// its own rather than sitting inside a sentence:
///
/// ```dart
/// PlinthCode.block('flutter pub get\nflutter run')
/// ```
class PlinthCode extends StatelessWidget {
  const PlinthCode(this.label,
      {super.key, this.color, this.size = PlinthSize.md})
      : block = false;

  /// A standalone block: full width, roomier padding, and every line
  /// of [label] kept rather than collapsed onto one.
  ///
  /// Lines are not wrapped — a wrapped line of code is a line of code
  /// that has been silently rewritten — so a block scrolls sideways
  /// when a line is too long for it, the way every code viewer does.
  const PlinthCode.block(this.label,
      {super.key, this.color, this.size = PlinthSize.md})
      : block = true;

  final String label;
  final String? color;
  final PlinthSize size;

  /// Whether this is the standalone multi-line form.
  final bool block;

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
    final background = theme.shaded(colorKey, 1);
    final foreground = theme.shaded(colorKey, 8);

    final text = Text(
      label,
      softWrap: !block,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: _fontSizes[size],
        color: foreground,
        // Lines of code sit closer together than prose does, and the
        // default leading is tuned for prose.
        height: block ? 1.45 : null,
      ),
    );

    return Container(
      width: block ? double.infinity : null,
      padding: block
          ? EdgeInsets.all(theme.spacing[PlinthSize.sm]!)
          : const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: block
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: text,
            )
          : text,
    );
  }
}
