import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A blockquote matching Mantine's `Blockquote`: quoted text with a
/// colored left border and an optional citation line.
///
/// ```dart
/// PlinthBlockquote(
///   quote: 'The best way to predict the future is to invent it.',
///   citation: 'Alan Kay',
/// )
/// ```
class PlinthBlockquote extends StatelessWidget {
  const PlinthBlockquote({
    super.key,
    required this.quote,
    this.citation,
    this.color,
    this.icon,
  });

  final String quote;
  final String? citation;
  final String? color;

  /// Optional icon shown above the quote, e.g. a quotation-mark glyph.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final accentColor = theme.shaded(colorKey, 6);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing[PlinthSize.md]!,
        vertical: theme.spacing[PlinthSize.sm]!,
      ),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            IconTheme(
                data: IconThemeData(color: accentColor, size: 24),
                child: icon!),
            SizedBox(height: theme.spacing[PlinthSize.xs]),
          ],
          PlinthText(quote, size: PlinthSize.lg, italic: true),
          if (citation != null) ...[
            SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.5),
            PlinthText('— $citation',
                size: PlinthSize.sm, color: theme.rampFor(PlinthRole.neutral)),
          ],
        ],
      ),
    );
  }
}
