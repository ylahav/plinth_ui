import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One way to reach you.
class PlinthSupportChannel {
  const PlinthSupportChannel({
    required this.title,
    required this.detail,
    this.icon,
    this.color,
    this.onTap,
  });

  /// What it is — 'Live chat', 'Email', 'Docs'.
  final String title;

  /// When it is answered, or what it is for. The part that decides
  /// which channel somebody picks.
  final String detail;

  final Widget? icon;

  /// Palette key for the icon. Null falls back to the theme's primary.
  final String? color;

  /// Opening the channel. Null renders the tile as a statement rather
  /// than as something to press — a tile that looks tappable and is not
  /// is worse than one that plainly is not.
  final VoidCallback? onTap;
}

/// Ways to reach you, as a grid of routes.
///
/// Routing rather than a form. When several channels exist the
/// reader's first decision is which one, and a form presumes that
/// answer for them — often the slowest one, since a question the docs
/// already answer becomes an email somebody has to write and somebody
/// else has to reply to.
///
/// ```dart
/// PlinthSupportChannels(
///   channels: [
///     PlinthSupportChannel(
///       icon: const Icon(Icons.chat_bubble_outline),
///       title: 'Live chat',
///       detail: 'Weekdays, 9–17 UTC',
///       color: 'blue',
///       onTap: openChat,
///     ),
///   ],
/// )
/// ```
///
/// Each tile is one thing to assistive technology — "Live chat,
/// weekdays 9 to 17 UTC" — rather than an icon, a heading and a caption
/// announced as three unrelated fragments.
class PlinthSupportChannels extends StatelessWidget {
  const PlinthSupportChannels({
    super.key,
    required this.channels,
    this.title,
    this.subtitle,
    this.columns = 3,
    this.minColWidth = 160,
    this.width,
    this.titleOrder = 3,
  });

  final List<PlinthSupportChannel> channels;

  final String? title;
  final String? subtitle;
  final int columns;
  final double minColWidth;
  final double? width;
  final int titleOrder;

  @override
  Widget build(BuildContext context) {
    final body = PlinthStack(
      gap: PlinthSize.md,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title case final title?) PlinthTitle(title, order: titleOrder),
        if (subtitle case final subtitle?)
          PlinthText(subtitle, size: PlinthSize.sm, color: 'gray'),
        PlinthSimpleGrid(
          columns: columns,
          minColWidth: minColWidth,
          children: [
            for (final channel in channels) _ChannelTile(channel: channel),
          ],
        ),
      ],
    );

    return width == null ? body : SizedBox(width: width, child: body);
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({required this.channel});

  final PlinthSupportChannel channel;

  @override
  Widget build(BuildContext context) {
    final tile = PlinthPaper(
      withBorder: true,
      p: PlinthSize.md,
      child: PlinthStack(
        gap: PlinthSize.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (channel.icon case final icon?)
            ExcludeSemantics(
              child: PlinthThemeIcon(
                icon: icon,
                color: channel.color,
                variant: PlinthVariant.light,
              ),
            ),
          PlinthText(channel.title, weight: FontWeight.w600),
          PlinthText(channel.detail, size: PlinthSize.sm, color: 'gray'),
        ],
      ),
    );

    // Merged so the tile is announced as one route rather than as a
    // heading and a caption that happen to be adjacent.
    final merged = MergeSemantics(child: tile);

    if (channel.onTap case final onTap?) {
      return PlinthUnstyledButton(onPressed: onTap, child: merged);
    }
    return merged;
  }
}
