import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One ranked row.
class PlinthLeaderboardRow {
  const PlinthLeaderboardRow({
    required this.label,
    required this.value,
    this.display,
    this.onTap,
  });

  /// What is ranked — a page path, a product, a referrer.
  final String label;

  /// The figure the ranking is by.
  final num value;

  /// [value] formatted for display. Null shows the raw number, which is
  /// right for small counts and wrong for large ones — format it and
  /// pass the result, since that is a locale question this package
  /// does not answer.
  final String? display;

  final VoidCallback? onTap;
}

/// A ranked list with a bar behind each row.
///
/// **Shares are measured against the leader, not the total.** The
/// question a ranking answers is "how far behind is second", and
/// dividing by a total nobody sees makes every bar look small — a page
/// with 40% of traffic and one with 4% both render as a stub when the
/// denominator is the sum of a long tail.
///
/// ```dart
/// PlinthLeaderboard(
///   title: 'Top pages',
///   rows: const [
///     PlinthLeaderboardRow(label: '/docs', value: 8420, display: '8,420'),
///     PlinthLeaderboardRow(label: '/pricing', value: 1240, display: '1,240'),
///   ],
/// )
/// ```
class PlinthLeaderboard extends StatelessWidget {
  const PlinthLeaderboard({
    super.key,
    required this.rows,
    this.title,
    this.color,
    this.emptyLabel = 'Nothing to rank yet.',
    this.withBorder = true,
    this.width,
  });

  final List<PlinthLeaderboardRow> rows;
  final String? title;

  /// Palette key for the bars.
  final String? color;

  /// Shown instead of an empty card. A ranking with no rows and no
  /// explanation reads as a broken query.
  final String emptyLabel;

  final bool withBorder;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final leader = rows.isEmpty
        ? 0
        : rows.map((r) => r.value).reduce((a, b) => a > b ? a : b);

    final card = PlinthPaper(
      withBorder: withBorder,
      p: PlinthSize.md,
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title case final title?)
            PlinthText(title, weight: FontWeight.w700),
          if (rows.isEmpty)
            PlinthText(emptyLabel, size: PlinthSize.sm, color: 'gray')
          else
            for (final row in rows)
              _LeaderboardRow(
                row: row,
                share: leader == 0 ? 0 : row.value / leader,
                color: color,
              ),
        ],
      ),
    );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.row, required this.share, this.color});

  final PlinthLeaderboardRow row;
  final double share;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final display = row.display ?? '${row.value}';

    final content = Semantics(
      label: '${row.label}, $display',
      container: true,
      child: ExcludeSemantics(
        child: PlinthStack(
          gap: PlinthSize.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: PlinthText(
                    row.label,
                    size: PlinthSize.sm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PlinthText(display, size: PlinthSize.sm, color: 'gray'),
              ],
            ),
            PlinthProgress(value: share, size: PlinthSize.xs, color: color),
          ],
        ),
      ),
    );

    if (row.onTap case final onTap?) {
      return PlinthUnstyledButton(onPressed: onTap, child: content);
    }
    return content;
  }
}
