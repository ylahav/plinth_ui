import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// "You are offline" — as a notice the page keeps working around,
/// rather than a page that replaces itself.
///
/// Deliberately not a [PlinthErrorPageBlock] constructor. A dropped
/// connection resolves itself, and an app that swaps the screen for an
/// apology throws away whatever the person was in the middle of. The
/// useful design is a banner plus the state of the queue: what is
/// waiting, when it last synced, and a way to try now.
///
/// ```dart
/// PlinthOfflineNotice(
///   onRetry: sync.retryNow,
///   details: const [
///     PlinthDataListItem.text('Queued changes', '3'),
///     PlinthDataListItem.text('Last synced', '11:42'),
///   ],
/// )
/// ```
///
/// Yellow rather than red, because nothing has failed — work is being
/// held. Red here would spend the colour that means "something is
/// broken" on a state that resolves on its own.
class PlinthOfflineNotice extends StatelessWidget {
  const PlinthOfflineNotice({
    super.key,
    this.onRetry,
    this.title = 'You are offline',
    this.message = 'Changes are saved locally and will sync when the '
        'connection returns.',
    this.retryLabel = 'Retry now',
    this.details = const [],
    this.actions = const [],
    this.color = 'yellow',
    this.icon = const Icon(Icons.wifi_off),
    this.width = 420,
  });

  /// Try the connection now. Null hides the retry button — offer it
  /// only where trying again actually does something.
  final VoidCallback? onRetry;

  final String title;
  final String message;
  final String retryLabel;

  /// What is waiting, as a [PlinthDataList]. Empty renders nothing.
  ///
  /// This is the part that makes the notice worth more than a banner:
  /// "3 queued changes, last synced 11:42" answers the question
  /// somebody offline actually has.
  final List<PlinthDataListItem> details;

  /// Extra actions beside retry.
  final List<Widget> actions;

  final String color;
  final Widget icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (onRetry case final onRetry?)
        PlinthButton(
          variant: PlinthVariant.outline,
          onPressed: onRetry,
          leadingIcon: const Icon(Icons.refresh, size: 16),
          child: Text(retryLabel),
        ),
      ...actions,
    ];

    final card = PlinthPaper(
      p: PlinthSize.lg,
      withBorder: true,
      child: PlinthStack(
        gap: PlinthSize.sm,
        children: [
          PlinthAlert(
            title: title,
            color: color,
            icon: icon,
            child: Text(message),
          ),
          if (details.isNotEmpty) PlinthDataList(items: details),
          if (buttons.isNotEmpty) PlinthGroup(children: buttons),
        ],
      ),
    );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}
