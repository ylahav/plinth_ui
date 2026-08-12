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
    final markColor = theme.colors.containsKey(colorKey)
        ? theme.shaded(colorKey, 2)
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
              style: isMatch
                  ? baseStyle.copyWith(backgroundColor: markColor)
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
