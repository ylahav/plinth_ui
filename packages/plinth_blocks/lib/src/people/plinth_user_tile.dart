import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// Whether somebody is around.
///
/// The colours are conventional; the *labels* are what make them
/// information. A green dot on its own is a fact only to people who can
/// see colour, so [PlinthUserTile] always announces the word.
enum PlinthPresence {
  online('green', 'online'),
  away('yellow', 'away'),
  busy('red', 'busy'),
  offline('gray', 'offline');

  const PlinthPresence(this.color, this.label);

  /// Palette key for the dot.
  final String color;

  /// The English default. Pass [PlinthUserTile.presenceLabel] to
  /// override it — this package ships no localisation.
  final String label;
}

/// A person: their face, their name, and one line about them.
///
/// The shape almost every user-facing row in an app turns out to be —
/// an account switcher, a member of a team, the signed-in user at the
/// foot of a sidebar, a contact.
///
/// ```dart
/// PlinthUserTile(
///   initials: 'YL',
///   name: 'Yair Lahav',
///   detail: 'yair@example.com',
///   presence: PlinthPresence.online,
///   onTap: openAccount,
/// )
/// ```
///
/// **The row is one thing to a screen reader** — "Yair Lahav,
/// yair@example.com, online" — rather than an avatar, a name and a
/// caption arriving as three fragments. The presence dot rides the
/// avatar, which is what makes it readable at a glance, and its colour
/// is excluded from the semantics because the word is already in the
/// label.
class PlinthUserTile extends StatelessWidget {
  const PlinthUserTile({
    super.key,
    required this.name,
    this.detail,
    this.initials,
    this.avatar,
    this.presence,
    this.presenceLabel,
    this.trailing,
    this.onTap,
    this.size = PlinthSize.md,
    this.withBorder = false,
    this.padding,
    this.width,
  });

  final String name;

  /// The line under the name — an address, a role, a handle.
  final String? detail;

  /// Fallback initials when there is no [avatar].
  final String? initials;

  /// A [PlinthAvatar] or an image. Null falls back to [initials].
  final Widget? avatar;

  /// Whether they are around. Null renders no dot at all, rather than
  /// a grey one that reads as "offline" when it means "unknown".
  final PlinthPresence? presence;

  /// Overrides the word [presence] is announced and captioned with.
  final String? presenceLabel;

  /// The far end — a role badge, a menu button, a chevron.
  final Widget? trailing;

  final VoidCallback? onTap;
  final PlinthSize size;
  final bool withBorder;
  final EdgeInsetsGeometry? padding;
  final double? width;

  String? get _presenceWord =>
      presence == null ? null : (presenceLabel ?? presence!.label);

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final face = avatar ?? PlinthAvatar(initials: initials ?? '', size: size);

    // The label owns the identity only. `trailing` stays outside it,
    // because a menu button inside a labelled row is still a button and
    // merging it in would cost it its own name and role.
    final word = _presenceWord;
    final spoken = [
      name,
      if (detail case final detail?) detail,
      // A plain `if` rather than a null-aware element: this package
      // supports Dart 3.4, and `?expr` in a list landed in 3.8.
      if (word != null) word,
    ].join(', ');

    final identity = Semantics(
      label: spoken,
      container: true,
      child: ExcludeSemantics(
        child: Row(
          children: [
            if (presence case final presence?)
              PlinthIndicator(color: presence.color, child: face)
            else
              face,
            SizedBox(width: theme.space(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlinthText(name, weight: FontWeight.w600, maxLines: 1),
                  if (detail case final detail?)
                    PlinthText(
                      detail,
                      size: PlinthSize.xs,
                      color: 'gray',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final row = Row(
      children: [
        Expanded(child: identity),
        if (trailing case final trailing?) ...[
          SizedBox(width: theme.space(2)),
          trailing,
        ],
      ],
    );

    final body = padding == null && !withBorder
        ? row
        : PlinthPaper(
            withBorder: withBorder,
            p: PlinthSize.sm,
            child: row,
          );

    final tappable = onTap == null
        ? body
        : PlinthUnstyledButton(onPressed: onTap, child: body);

    return width == null ? tappable : SizedBox(width: width, child: tappable);
  }
}
