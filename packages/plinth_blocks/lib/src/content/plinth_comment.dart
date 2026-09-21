import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import '../people/plinth_user_tile.dart';

/// One comment, and the replies under it.
class PlinthCommentData {
  const PlinthCommentData({
    required this.author,
    required this.body,
    this.when,
    this.initials,
    this.avatar,
    this.replies = const [],
    this.actions = const [],
  });

  final String author;
  final String body;

  /// When it was posted, already formatted — "2 hours ago" is a
  /// locale-and-clock question this package does not answer.
  final String? when;

  final String? initials;
  final Widget? avatar;

  /// Replies to this comment, rendered indented under it.
  final List<PlinthCommentData> replies;

  /// Per-comment controls: reply, edit, report.
  final List<Widget> actions;
}

/// A comment thread.
///
/// ```dart
/// PlinthCommentThread(
///   comments: const [
///     PlinthCommentData(
///       initials: 'AB',
///       author: 'Ada Byron',
///       when: '2 hours ago',
///       body: 'Does the shade mirroring apply to custom palettes?',
///       replies: [
///         PlinthCommentData(
///           initials: 'YL',
///           author: 'Yair Lahav',
///           when: '1 hour ago',
///           body: 'Any ramp registered on the theme.',
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// **Indent marks a reply as a reply** — it is the whole reason a
/// thread reads differently to a list. It is also only visual, so each
/// reply is announced as one, and the nesting level travels in the
/// label rather than in the left margin.
///
/// Nesting stops at [maxDepth]. A thread that indents forever runs out
/// of page, and a reply four levels in is a reply to something nobody
/// can still see.
class PlinthCommentThread extends StatelessWidget {
  const PlinthCommentThread({
    super.key,
    required this.comments,
    this.indent = 32,
    this.maxDepth = 3,
    this.replyLabel = 'reply',
    this.emptyLabel = 'No comments yet.',
    this.width,
  });

  final List<PlinthCommentData> comments;

  /// How far each level is indented.
  final double indent;

  /// How deep the indenting goes before replies render flat.
  final int maxDepth;

  /// The word a nested comment is announced with, as in
  /// "Yair Lahav, reply".
  final String replyLabel;

  final String emptyLabel;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final body = comments.isEmpty
        ? PlinthText(emptyLabel, size: PlinthSize.sm, color: 'gray')
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final comment in comments)
                _Comment(
                  comment: comment,
                  depth: 0,
                  indent: indent,
                  maxDepth: maxDepth,
                  replyLabel: replyLabel,
                ),
            ],
          );

    return width == null ? body : SizedBox(width: width, child: body);
  }
}

class _Comment extends StatelessWidget {
  const _Comment({
    required this.comment,
    required this.depth,
    required this.indent,
    required this.maxDepth,
    required this.replyLabel,
  });

  final PlinthCommentData comment;
  final int depth;
  final double indent;
  final int maxDepth;
  final String replyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final head = PlinthUserTile(
      name: comment.author,
      detail: comment.when,
      initials: comment.initials,
      avatar: comment.avatar,
      size: PlinthSize.sm,
    );

    return Padding(
      padding: EdgeInsets.only(
        // Each level nests inside the last, so the indent accumulates
        // on its own — past [maxDepth] this contributes nothing rather
        // than capping a number that was never the total.
        left: depth == 0 || depth > maxDepth ? 0 : indent,
        top: depth == 0 ? 0 : theme.space(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // The indent is visual only, so the nesting is said as well as
          // shown — otherwise a reply and a top-level comment sound
          // identical.
          Semantics(
            container: true,
            label: depth == 0 ? null : replyLabel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                head,
                SizedBox(height: theme.space(2)),
                PlinthText(comment.body, size: PlinthSize.sm),
                if (comment.actions.isNotEmpty) ...[
                  SizedBox(height: theme.space(2)),
                  PlinthGroup(gap: PlinthSize.xs, children: comment.actions),
                ],
              ],
            ),
          ),
          for (final reply in comment.replies)
            _Comment(
              comment: reply,
              depth: depth + 1,
              indent: indent,
              maxDepth: maxDepth,
              replyLabel: replyLabel,
            ),
        ],
      ),
    );
  }
}
