import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Text with matching substrings marked, following Mantine's
/// `Highlight`.
///
/// [PlinthMark] highlights a span you have already split out of a
/// sentence yourself; this does the splitting, which is what you
/// actually want when the terms come from a search box and you don't
/// know where they land.
///
/// ```dart
/// PlinthHighlight(
///   result.title,
///   highlight: query.split(' '),
/// )
/// ```
///
/// Matching is case-insensitive and literal — terms are escaped before
/// use, so a query containing `.` or `(` matches those characters
/// rather than being read as a pattern.
class PlinthHighlight extends StatelessWidget {
  const PlinthHighlight(
    this.data, {
    super.key,
    required this.highlight,
    this.color,
    this.size = PlinthSize.md,
    this.textColor,
    this.weight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;

  /// Terms to mark. Empty and blank entries are ignored, so passing a
  /// raw `query.split(' ')` doesn't highlight the whole string when the
  /// query has a trailing space.
  final List<String> highlight;

  /// Color key for the highlight background. Defaults to `yellow`,
  /// matching [PlinthMark].
  final String? color;

  final PlinthSize size;

  /// Color key for the text itself. Null inherits the ambient style.
  final String? textColor;

  final FontWeight? weight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? 'yellow';
    // A wash rather than `shaded(colorKey, 2)`, for the reason PR-05
    // gave for alerts: `shadeFor` mirrors 2 to 7 in a dark theme, and a
    // shade-7 mark is a saturated block rather than a highlight. It also
    // left the marked text unreadable -- 8 of 13 ramps had *no* shade
    // clearing 4.5:1 against their own mark in dark, because the mark
    // sat in the middle of the ramp.
    //
    // Compositing over the surface keeps the mark a tint in both
    // themes. Alpha 0.30 is chosen to sit closest to the old light-mode
    // mark (mean ΔE 3.3), so the theme that was already correct barely
    // moves.
    final markColor = theme.colors.containsKey(colorKey)
        ? theme.wash(colorKey, alpha: 0.30)
        : const Color(0xFFFFF3BF);

    final baseStyle = TextStyle(
      fontSize: theme.fontSizes[size],
      fontWeight: weight,
      color: textColor != null
          ? theme.readableOn(textColor!, theme.surface)
          : null,
    );

    return Text.rich(
      TextSpan(
        children: [
          for (final (text, isMatch) in _split())
            TextSpan(
              text: text,
              // backgroundColor rather than wrapping each match in a
              // WidgetSpan: a widget span is laid out as one atomic box,
              // so a long match could not wrap and would push the line
              // past its bounds.
              // A matched run has a different background from the rest,
              // so it needs a different foreground. Resolving one colour
              // against the surface and painting it on the mark left 9
              // of 13 ramps under the floor in light and all 13 in dark
              // -- and the marked run is the whole point of the widget.
              //
              // Per-span rather than one colour clearing both: for 8 of
              // the 26 ramp/theme pairings no shade clears 4.5:1 against
              // the surface and the mark at once, because the tint sits
              // too close to the ramp's own middle.
              style: isMatch
                  ? baseStyle.copyWith(
                      backgroundColor: markColor,
                      color: textColor != null
                          ? theme.readableOn(textColor!, markColor)
                          : theme.readableOn(colorKey, markColor),
                    )
                  : baseStyle,
            ),
        ],
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Splits [data] into runs, each flagged as matching or not.
  List<(String, bool)> _split() {
    final terms = highlight
        .where((term) => term.trim().isNotEmpty)
        .map(RegExp.escape)
        .toList();
    if (terms.isEmpty) return [(data, false)];

    // Longest first, so overlapping terms mark the larger span rather
    // than leaving a fragment of it unhighlighted.
    terms.sort((a, b) => b.length.compareTo(a.length));
    final pattern = RegExp(terms.join('|'), caseSensitive: false);

    final runs = <(String, bool)>[];
    var index = 0;
    for (final match in pattern.allMatches(data)) {
      if (match.start > index) {
        runs.add((data.substring(index, match.start), false));
      }
      runs.add((match.group(0)!, true));
      index = match.end;
    }
    if (index < data.length) runs.add((data.substring(index), false));
    return runs;
  }
}
