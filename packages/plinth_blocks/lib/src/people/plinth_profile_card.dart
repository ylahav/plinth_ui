import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import '../marketing/plinth_stat_strip.dart';

/// A card about one person.
///
/// Centred it is a profile — avatar, name, a badge, the counts that go
/// with a profile. Left-aligned it is a contact card — the same person
/// with facts beside them instead of figures. Both are this widget,
/// because they differ in alignment and in what fills the middle, not
/// in what they are.
///
/// ```dart
/// PlinthProfileCard(
///   initials: 'YL',
///   name: 'Yair Lahav',
///   badge: const PlinthBadge('Maintainer', color: 'grape'),
///   stats: const [
///     PlinthStat(value: '128', label: 'Posts'),
///     PlinthStat(value: '2.4k', label: 'Followers'),
///   ],
///   actions: [PlinthButton(onPressed: follow, child: const Text('Follow'))],
/// )
/// ```
///
/// The counts reuse [PlinthStatStrip], which already merges each value
/// with its label so "128 posts" is one thing to a screen reader rather
/// than a number and a caption that happen to be stacked.
class PlinthProfileCard extends StatelessWidget {
  const PlinthProfileCard({
    super.key,
    required this.name,
    this.detail,
    this.initials,
    this.avatar,
    this.badge,
    this.bio,
    this.stats = const [],
    this.details = const [],
    this.actions = const [],
    this.centered = true,
    this.avatarSize = PlinthSize.xl,
    this.nameOrder = 4,
    this.width,
  });

  final String name;

  /// A line under the name — a role, a location, a handle.
  final String? detail;

  final String? initials;
  final Widget? avatar;

  /// Under the name, usually a [PlinthBadge].
  final Widget? badge;

  /// A paragraph about them.
  final String? bio;

  /// Counts, rendered as a [PlinthStatStrip].
  final List<PlinthStat> stats;

  /// Facts, rendered as a [PlinthDataList] — email, phone, timezone.
  ///
  /// Separate from [stats] because they answer different questions: a
  /// count is a measure of them, a fact is a way to reach them.
  final List<PlinthDataListItem> details;

  final List<Widget> actions;

  /// Centres the avatar, name and badge. False puts the avatar beside
  /// the name, which is the contact-card arrangement.
  final bool centered;

  final PlinthSize avatarSize;

  /// Heading level for [name]. A card about a person has a heading,
  /// which is how a screen reader finds it among a page of them.
  final int nameOrder;

  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final face =
        avatar ?? PlinthAvatar(initials: initials ?? '', size: avatarSize);

    final identity = centered
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              face,
              SizedBox(height: theme.space(3)),
              PlinthTitle(name, order: nameOrder, textAlign: TextAlign.center),
              if (detail case final detail?) ...[
                SizedBox(height: theme.space(1)),
                PlinthText(detail, size: PlinthSize.xs, color: 'gray'),
              ],
              if (badge case final badge?) ...[
                SizedBox(height: theme.space(1)),
                badge,
              ],
            ],
          )
        : Row(
            children: [
              face,
              SizedBox(width: theme.space(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlinthTitle(name, order: nameOrder),
                    if (detail case final detail?)
                      PlinthText(detail, size: PlinthSize.xs, color: 'gray'),
                  ],
                ),
              ),
              if (badge case final badge?) badge,
            ],
          );

    final card = PlinthPaper(
      withBorder: true,
      p: PlinthSize.md,
      child: Column(
        crossAxisAlignment:
            centered ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          identity,
          if (bio case final bio?) ...[
            SizedBox(height: theme.space(3)),
            PlinthText(
              bio,
              size: PlinthSize.sm,
              color: 'gray',
              textAlign: centered ? TextAlign.center : TextAlign.start,
            ),
          ],
          if (stats.isNotEmpty) ...[
            SizedBox(height: theme.space(4)),
            PlinthStatStrip(
              stats: stats,
              gap: PlinthSize.md,
              alignment:
                  centered ? MainAxisAlignment.center : MainAxisAlignment.start,
              valueSize: PlinthSize.md,
            ),
          ],
          if (details.isNotEmpty) ...[
            SizedBox(height: theme.space(3)),
            PlinthDataList(items: details),
          ],
          if (actions.isNotEmpty) ...[
            SizedBox(height: theme.space(4)),
            PlinthGroup(
              gap: PlinthSize.sm,
              mainAxisAlignment:
                  centered ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: actions,
            ),
          ],
        ],
      ),
    );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}
