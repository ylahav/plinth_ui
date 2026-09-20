import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// How a [PlinthBannerBlock] is arranged.
enum PlinthBannerLayout {
  /// Title above the message, actions below — a [PlinthAlert]. The
  /// shape for something worth reading: a release note, an update.
  notice,

  /// Message and actions on one line. The shape for something worth
  /// answering and getting out of the way: consent, a promotion.
  bar,
}

/// A page-level message with something to do about it.
///
/// One widget for the four banner shapes, because an announcement, a
/// consent prompt, a promotion and an update notice differ in layout
/// and wording rather than in kind.
///
/// Unlike [PlinthErrorPageBlock] this ships **no default copy**. An
/// error page can guess at "Nothing to see here"; nothing can guess
/// what your announcement says, and a banner with placeholder text in
/// it is worse than one that refuses to build.
///
/// ```dart
/// PlinthBannerBlock(
///   layout: PlinthBannerLayout.bar,
///   elevated: true,
///   message: 'We use one cookie to remember your theme.',
///   actions: [
///     PlinthButton(
///       variant: PlinthVariant.subtle,
///       size: PlinthSize.sm,
///       onPressed: decline,
///       child: const Text('Decline'),
///     ),
///     PlinthButton(size: PlinthSize.sm, onPressed: accept,
///         child: const Text('Accept')),
///   ],
/// )
/// ```
///
/// **Dismissal is a decision, not a default.** [onClose] null means no
/// close button, which is what a consent prompt needs — one somebody
/// can wave away has not obtained consent. A promotion is the opposite:
/// one that cannot be dismissed is a tax on everybody who has already
/// read it.
class PlinthBannerBlock extends StatelessWidget {
  const PlinthBannerBlock({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.leading,
    this.actions = const [],
    this.onClose,
    this.layout = PlinthBannerLayout.notice,
    this.color = 'blue',
    this.elevated = false,
    this.width = 560,
  });

  /// The body. Required — see the note above about default copy.
  final String message;

  /// A heading, in [PlinthBannerLayout.notice] only.
  final String? title;

  /// Leading icon, in [PlinthBannerLayout.notice] only.
  final Widget? icon;

  /// Leading widget for [PlinthBannerLayout.bar] — usually a
  /// [PlinthBadge] saying what kind of message this is.
  final Widget? leading;

  /// What to do about it. A banner with no action is a notification
  /// wearing a banner's clothes.
  final List<Widget> actions;

  /// Dismissal. Null renders no close button at all.
  final VoidCallback? onClose;

  final PlinthBannerLayout layout;
  final String color;

  /// Whether the bar floats above the page (border and shadow) or sits
  /// in it (a tint of [color]).
  ///
  /// The real distinction is where it lives: a consent prompt overlays
  /// the page and has to look like it, a promotion is part of the flow.
  /// Ignored by [PlinthBannerLayout.notice], which is always a tint.
  final bool elevated;

  final double? width;

  @override
  Widget build(BuildContext context) {
    final banner = switch (layout) {
      PlinthBannerLayout.notice => _notice(context),
      PlinthBannerLayout.bar => _bar(context),
    };

    return width == null ? banner : SizedBox(width: width, child: banner);
  }

  Widget _notice(BuildContext context) {
    return PlinthAlert(
      title: title,
      color: color,
      icon: icon,
      onClose: onClose,
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthText(message, size: PlinthSize.sm),
          if (actions.isNotEmpty)
            PlinthGroup(gap: PlinthSize.xs, children: actions),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context) {
    final theme = context.plinth;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading case final leading?) ...[
          leading,
          SizedBox(width: theme.space(3)),
        ],
        Expanded(child: PlinthText(message, size: PlinthSize.sm)),
        if (actions.isNotEmpty) ...[
          SizedBox(width: theme.space(4)),
          // `wrap: false` because these are a decision pair — splitting
          // "Decline" and "Accept" across two lines puts one of them
          // somewhere nobody is looking.
          PlinthGroup(gap: PlinthSize.xs, wrap: false, children: actions),
        ],
        if (onClose case final onClose?) ...[
          SizedBox(width: theme.space(2)),
          PlinthCloseButton(onPressed: onClose, size: PlinthSize.sm),
        ],
      ],
    );

    if (elevated) {
      return PlinthPaper(
        withBorder: true,
        shadow: PlinthShadow.md,
        p: PlinthSize.md,
        child: row,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing[PlinthSize.md]!,
        vertical: theme.spacing[PlinthSize.sm]!,
      ),
      decoration: BoxDecoration(
        color: theme.shaded(color, 0),
        borderRadius: BorderRadius.circular(theme.radius[theme.defaultRadius]!),
      ),
      child: row,
    );
  }
}
