import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A text primitive that resolves its size from the active
/// [PlinthTheme]'s font-size scale (like `Text` + Mantine's `Text`
/// component's `size` prop), instead of a raw `fontSize` double.
class PlinthText extends StatelessWidget {
  const PlinthText(
    this.data, {
    super.key,
    this.size = PlinthSize.md,
    this.color,
    this.weight,
    this.textAlign,
    this.italic = false,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final PlinthSize size;

  /// Color key into the theme palette (e.g. 'red'), resolved at shade 6.
  /// Pass `null` to inherit the ambient [DefaultTextStyle] color.
  final String? color;

  final FontWeight? weight;
  final TextAlign? textAlign;
  final bool italic;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    // A colour prop on text is always a foreground, so it resolves
    // against the surface rather than at a fixed shade — cyan and lime
    // at shade 6 are visible on white but not readable on it.
    final resolvedColor =
        color != null ? theme.readableOn(color!, theme.surface) : null;

    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: theme.fontSizes[size],
        color: resolvedColor,
        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}
