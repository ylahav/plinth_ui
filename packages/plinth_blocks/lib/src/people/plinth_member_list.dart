import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import 'plinth_user_tile.dart';

/// One person in a [PlinthMemberList].
class PlinthMember {
  const PlinthMember({
    required this.name,
    this.role,
    this.initials,
    this.avatar,
    this.presence,
    this.roleColor,
    this.onTap,
  });

  final String name;

  /// What they can do here — Owner, Editor, Viewer.
  final String? role;

  final String? initials;
  final Widget? avatar;
  final PlinthPresence? presence;

  /// Palette key for the role badge.
  final String? roleColor;

  final VoidCallback? onTap;
}

/// The people on a team, with the ones who did not fit summarised.
///
/// ```dart
/// PlinthMemberList(
///   title: 'Members',
///   members: const [
///     PlinthMember(initials: 'AN', name: 'Alice Nguyen', role: 'Owner'),
///     PlinthMember(initials: 'BK', name: 'Ben Kaur', role: 'Editor'),
///   ],
///   overflowAvatars: [...],
/// )
/// ```
///
/// [overflowAvatars] is a [PlinthOverflowList] in the header: the
/// people beyond the first few, without a second row and without making
/// the list itself longer than the card.
class PlinthMemberList extends StatelessWidget {
  const PlinthMemberList({
    super.key,
    required this.members,
    this.title,
    this.overflowAvatars = const [],
    this.action,
    this.emptyLabel = 'Nobody here yet.',
    this.width,
  });

  final List<PlinthMember> members;
  final String? title;

  /// Avatars for the whole team, collapsed into a stack in the header.
  final List<Widget> overflowAvatars;

  /// A button at the foot — "Invite", usually.
  final Widget? action;

  /// Shown when there are no members. A list that renders nothing at
  /// all reads as a card that failed to load.
  final String emptyLabel;

  final double? width;

  @override
  Widget build(BuildContext context) {
    final card = PlinthPaper(
      p: PlinthSize.md,
      withBorder: true,
      child: PlinthStack(
        gap: PlinthSize.sm,
        children: [
          if (title != null || overflowAvatars.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: title == null
                      ? const SizedBox.shrink()
                      : PlinthText(title!, weight: FontWeight.w700),
                ),
                if (overflowAvatars.isNotEmpty)
                  PlinthOverflowList(children: overflowAvatars),
              ],
            ),
          if (members.isEmpty)
            PlinthText(emptyLabel, size: PlinthSize.sm, color: 'gray')
          else
            for (final member in members)
              PlinthUserTile(
                name: member.name,
                detail: null,
                initials: member.initials,
                avatar: member.avatar,
                presence: member.presence,
                size: PlinthSize.sm,
                onTap: member.onTap,
                trailing: member.role == null
                    ? null
                    : PlinthBadge(member.role!, color: member.roleColor),
              ),
          if (action case final action?) action,
        ],
      ),
    );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}
