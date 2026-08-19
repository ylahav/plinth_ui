import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Font size and weight per heading order, matching Mantine's `Title`
/// defaults.
///
/// Deliberately its own scale rather than [PlinthTheme.fontSizes]:
/// that scale tops out at 20px because it sizes body text, badges, and
/// input labels, while an `h1` needs to be considerably larger than
/// any of them.
const Map<int, (double size, FontWeight weight)> _titleStyles = {
  1: (34, FontWeight.w700),
  2: (26, FontWeight.w700),
  3: (22, FontWeight.w700),
  4: (18, FontWeight.w600),
  5: (16, FontWeight.w600),
  6: (14, FontWeight.w600),
};

/// A semantic heading matching Mantine's `Title`.
///
/// Distinct from a [PlinthText] with a larger `size`, and the
/// difference is not only visual: this marks the text as a heading for
/// assistive technology, so screen-reader users can navigate a page by
/// its headings. A visually large paragraph gives them nothing to
/// navigate by.
///
/// [order] runs 1–6, matching `h1`–`h6`. Use it to reflect document
/// structure — for a heading that should *look* smaller without
/// changing its level, pass a smaller [order] only if that is genuinely
/// the level it sits at, otherwise reach for [PlinthText].
///
/// ```dart
/// PlinthTitle('Getting started', order: 2)
/// ```
class PlinthTitle extends StatelessWidget {
  const PlinthTitle(
    this.data, {
    super.key,
    this.order = 1,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : assert(order >= 1 && order <= 6, 'order must be 1-6, matching h1-h6');

  final String data;

  /// Heading level, 1–6. Drives both the visual scale and the
  /// heading semantics exposed to assistive technology.
  final int order;

  /// Color key into the theme palette (e.g. 'red'), resolved at shade
  /// 6. Pass `null` to inherit the ambient [DefaultTextStyle] color.
  final String? color;

  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final (size, weight) = _titleStyles[order]!;

    return Semantics(
      header: true,
      // headingLevel carries the actual 1-6 level through to the
      // platform, which is what lets "next heading" navigation know
      // whether it is moving to a sibling or a subsection.
      headingLevel: order,
      child: Text(
        data,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: TextStyle(
          fontSize: size,
          fontWeight: weight,
          // WCAG's large-text floor (3.0) applies at ~18pt regular or
          // ~14pt bold — 24px and 18.67px in logical pixels. Orders 1–3
          // are 34, 26 and 22px at w700 and clear it; orders 4–6 are 18,
          // 16 and 14px at w600 and do not, on either reading of
          // "bold". So the level is decided by the measurement, not by
          // the word "title".
          color: color == null
              ? null
              : theme.readableOn(
                  color!,
                  theme.surface,
                  level: size >= 18.67 && weight.value >= FontWeight.w700.value
                      ? PlinthContrast.large
                      : PlinthContrast.body,
                ),
          height: 1.3,
        ),
      ),
    );
  }
}
