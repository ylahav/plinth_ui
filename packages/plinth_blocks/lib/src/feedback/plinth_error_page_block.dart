import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A whole-page apology: a status, a heading, an explanation, and a way
/// out.
///
/// One widget with named constructors rather than four near-identical
/// blocks, because 404, 500, maintenance and permission-denied differ
/// only in their words. Every default is overridable, so the
/// constructor is a starting point and not a straitjacket.
///
/// ```dart
/// PlinthErrorPageBlock.notFound(
///   actions: [
///     PlinthButton(
///       variant: PlinthVariant.defaultVariant,
///       onPressed: router.pop,
///       child: const Text('Go back'),
///     ),
///     PlinthButton(onPressed: router.home, child: const Text('Take me home')),
///   ],
/// )
/// ```
///
/// **There is always somewhere to go.** [actions] is not optional in
/// spirit even though it defaults to empty: a page that tells someone
/// their situation and not what to do about it is a dead end, and the
/// browser back button is not a substitute inside an app.
///
/// **Offline is deliberately not one of these.** A connection that
/// drops resolves itself, so the page should keep working with a
/// notice rather than replace itself with an apology — see
/// `PlinthOfflineNotice` for that shape.
class PlinthErrorPageBlock extends StatelessWidget {
  const PlinthErrorPageBlock({
    super.key,
    required this.title,
    this.status,
    this.description,
    this.actions = const [],
    this.icon,
    this.width = 460,
    this.titleOrder = 3,
  });

  /// 404 — the address is wrong.
  const PlinthErrorPageBlock.notFound({
    super.key,
    this.status = '404',
    this.title = 'Nothing to see here',
    this.description = 'The page you are looking for was moved, removed, '
        'or never existed in the first place.',
    this.actions = const [],
    this.icon,
    this.width = 460,
    this.titleOrder = 3,
  });

  /// 500 — it is not the visitor's fault, and saying so matters.
  const PlinthErrorPageBlock.serverError({
    super.key,
    this.status = '500',
    this.title = 'Something went wrong on our end',
    this.description = 'This one is not your fault. Try again in a moment, '
        'and if it keeps happening let us know.',
    this.actions = const [],
    this.icon,
    this.width = 460,
    this.titleOrder = 3,
  });

  /// Planned downtime, which is the one where a time is the whole point.
  const PlinthErrorPageBlock.maintenance({
    super.key,
    this.status,
    this.title = 'Back shortly',
    this.description = 'We are making some changes and will be back soon.',
    this.actions = const [],
    this.icon = const Icon(Icons.build_outlined),
    this.width = 460,
    this.titleOrder = 3,
  });

  /// 403 — signed in, and still not allowed.
  ///
  /// Worded to point at the person who can fix it. "Access denied" on
  /// its own leaves someone with nothing to do but email support.
  const PlinthErrorPageBlock.permissionDenied({
    super.key,
    this.status = '403',
    this.title = 'You do not have access to this',
    this.description = 'Ask a workspace admin to grant you access, or '
        'switch to an account that already has it.',
    this.actions = const [],
    this.icon = const Icon(Icons.lock_outline),
    this.width = 460,
    this.titleOrder = 3,
  });

  /// The status code, shown large and muted above the title.
  ///
  /// Muted on purpose: it is the least useful thing on the page to the
  /// person reading it, and the most useful thing to whoever they
  /// report it to.
  final String? status;

  final String title;
  final String? description;

  /// The ways out, laid out in a centred group that wraps.
  final List<Widget> actions;

  /// Shown above the status. Decorative — the title carries the
  /// meaning, so this is hidden from assistive technology.
  final Widget? icon;

  final double? width;
  final int titleOrder;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon case final icon?) ...[
          ExcludeSemantics(child: PlinthThemeIcon(icon: icon, color: 'gray')),
          SizedBox(height: theme.space(3)),
        ],
        if (status case final status?) ...[
          PlinthTitle(status, color: 'gray'),
          SizedBox(height: theme.space(2)),
        ],
        PlinthTitle(title, order: titleOrder, textAlign: TextAlign.center),
        if (description case final description?) ...[
          SizedBox(height: theme.space(2)),
          PlinthText(
            description,
            size: PlinthSize.sm,
            color: 'gray',
            textAlign: TextAlign.center,
          ),
        ],
        if (actions.isNotEmpty) ...[
          SizedBox(height: theme.space(6)),
          PlinthGroup(
            mainAxisAlignment: MainAxisAlignment.center,
            children: actions,
          ),
        ],
      ],
    );

    final centred = PlinthCenter(child: column);
    return width == null ? centred : SizedBox(width: width, child: centred);
  }
}
