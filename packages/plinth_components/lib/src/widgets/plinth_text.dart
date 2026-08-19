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
    this.on,
    this.weight,
    this.textAlign,
    this.italic = false,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final PlinthSize size;

  /// Color key into the theme palette (e.g. 'red'), resolved to a shade
  /// legible on [on]. Pass `null` to inherit the ambient
  /// [DefaultTextStyle] color.
  final String? color;

  /// The background this text actually sits on, for resolving [color].
  ///
  /// Defaults to the theme's `surface`, which is right for text on a
  /// page and wrong on a tint — and the library put it on tints. An
  /// alert renders its title over `shaded(color, 0)`, and against that
  /// background 3 of the 13 ramps did not clear the body floor the
  /// resolution had just reported clearing.
  ///
  /// It is the silent kind of miss: `readableOn` was called, a number
  /// was cleared, and the number was against a surface the text never
  /// touches. Pass the real background wherever the text is composited
  /// over one.
  final Color? on;

  final FontWeight? weight;
  final TextAlign? textAlign;
  final bool italic;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    // A colour prop on text is always a foreground, so it resolves
    // against its background rather than at a fixed shade — cyan and
    // lime at shade 6 are visible on white but not readable on it.
    final resolvedColor =
        color != null ? theme.readableOn(color!, on ?? theme.surface) : null;

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
