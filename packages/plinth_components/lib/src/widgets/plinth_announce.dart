import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Marks [child] as the message a screen reader should visit when
/// [message] changes, without the user having moved focus.
///
/// This is the declarative half of `F-3` — see
/// `docs/F3_ANNOUNCEMENTS.md`. Use it wherever the message is on screen
/// and stays there: a validation error, a notification, a status line.
/// Where the event has no lasting visual — loading finishing, and the
/// overlay leaving the tree with it — there is no node to attach to,
/// and [PlinthAnnounce.say] is the other half.
///
/// ```dart
/// if (error != null && error.isNotEmpty)
///   PlinthLiveRegion(
///     message: error,
///     child: PlinthText(error, size: PlinthSize.xs),
///   ),
/// ```
///
/// [message] is passed as well as the [child] that renders it, because
/// this needs to know whether there is anything to say. An empty string
/// is not a message: `''` and `null` both return [child] untouched
/// rather than a live region with nothing in it, which would be a node
/// a reader visits to hear silence.
///
/// `container: true` is deliberate, and is the one place this differs
/// from the hand-written live region in `PlinthPinInput` that `B0c`
/// heard working. Without it the flag is merged into whatever ancestor
/// node absorbs this subtree — which for a form field is the field
/// itself, label included, so every rebuild re-speaks the whole
/// control instead of the error. A dedicated node keeps the live
/// region exactly as wide as the message.
///
/// What this does not control: whether an unchanged message is spoken
/// twice. That is decided by the platform bridge, not the framework —
/// on web the flag becomes `aria-live`, which fires on text change.
/// What is guaranteed here is the part that is ours: no message, no
/// node.
class PlinthLiveRegion extends StatelessWidget {
  const PlinthLiveRegion({
    super.key,
    required this.message,
    required this.child,
  }) : _always = false;

  /// A live region whose content is a widget rather than a string, for
  /// something that exists only because it happened — a notification,
  /// an alert raised by an action.
  ///
  /// There is no message to check for emptiness, and none is needed:
  /// where the default constructor asks "is there anything to say?",
  /// here the widget being built is the answer.
  const PlinthLiveRegion.always({
    super.key,
    required this.child,
  })  : message = null,
        _always = true;

  /// The text [child] renders. Only its emptiness is read; the string
  /// itself reaches the reader through [child].
  final String? message;

  final Widget child;

  final bool _always;

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (!_always && (text == null || text.isEmpty)) return child;
    return Semantics(
      container: true,
      liveRegion: true,
      child: child,
    );
  }
}

/// Speaks a message that has no node to attach to.
///
/// The imperative half of `F-3`. Reach for [PlinthLiveRegion] first:
/// both Flutter and the Android platform docs prefer an implicit
/// announcement from the tree over an explicit one, because an
/// explicit announcement interrupts whatever the reader was saying.
/// This exists for the case a live region cannot express — an event
/// whose visual is *leaving*, where marking the departing widget
/// announces nothing because it is already gone.
abstract final class PlinthAnnounce {
  /// Announces [message], and reports whether it was actually sent.
  ///
  /// Returns `false` without sending when there is nothing to say, or
  /// when the platform does not take announcements. Both are ordinary
  /// outcomes rather than failures, which is why this returns a result
  /// instead of throwing — and why it returns one at all: an
  /// announcement leaves no trace in the semantics tree, so without a
  /// return value a caller has no way to know, and neither has a test.
  ///
  /// **Android is one of those platforms, on purpose.** It deprecated
  /// announcement events because TalkBack clears its speech queue to
  /// serve them, cutting off whatever the user was listening to.
  /// `MediaQuery.supportsAnnounceOf` is false there, so this stays
  /// quiet rather than degrading the platform's own behaviour — which
  /// is the second reason to carry a message in the tree with
  /// [PlinthLiveRegion] wherever it can be: that path works on every
  /// platform, this one does not.
  ///
  /// [assertiveness] is honoured on web only. Leave it
  /// [Assertiveness.polite] unless the message is worth interrupting
  /// for; a validation error usually is, a loading update is not.
  static Future<bool> say(
    BuildContext context,
    String? message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) async {
    if (message == null || message.isEmpty) return false;
    if (!MediaQuery.supportsAnnounceOf(context)) return false;
    // sendAnnouncement rather than the older announce(), which is
    // deprecated as of 3.35 for being incompatible with multiple
    // windows — it reaches for the implicit view, and asserts when
    // there is not exactly one.
    await SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
      assertiveness: assertiveness,
    );
    return true;
  }
}

/// Speaks [message] once, at the moment [when] turns true.
///
/// The edge case that neither half of the pair above covers on its
/// own. A live region is wrong for anything that changes continuously
/// — a progress bar marked live narrates every frame of its own
/// animation — but the moment it *finishes* is worth a word. This
/// watches for that moment and says one thing.
///
/// ```dart
/// PlinthAnnounceWhen(
///   when: value >= 1,
///   message: 'Upload complete',
///   child: bar,
/// )
/// ```
///
/// **Never on first build**, which is the whole reason this is a
/// widget with state rather than a check inside `build`. A progress
/// bar rendered at 100% is usually a statistic — storage used, quota
/// reached — and announcing "complete" for a number that was already
/// there would be reporting an event that never happened. Only a
/// transition speaks.
///
/// A null or empty [message] does nothing, so this can be wrapped
/// around a widget unconditionally and left silent by the caller.
/// Being an announcement, it is silent on Android by that platform's
/// policy — see [PlinthAnnounce.say].
class PlinthAnnounceWhen extends StatefulWidget {
  const PlinthAnnounceWhen({
    super.key,
    required this.when,
    required this.message,
    required this.child,
  });

  /// The condition to watch. Speaks on false → true, and never again
  /// until it has gone back to false.
  final bool when;

  final String? message;

  final Widget child;

  @override
  State<PlinthAnnounceWhen> createState() => _PlinthAnnounceWhenState();
}

class _PlinthAnnounceWhenState extends State<PlinthAnnounceWhen> {
  @override
  void didUpdateWidget(PlinthAnnounceWhen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.when && widget.when) {
      PlinthAnnounce.say(context, widget.message);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
