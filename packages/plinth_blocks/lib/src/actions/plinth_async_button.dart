import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A button that runs something slow and says so.
///
/// ```dart
/// PlinthAsyncButton(
///   onPressed: () => api.save(draft),
///   child: const Text('Save'),
///   doneLabel: 'Saved',
/// )
/// ```
///
/// **One piece of state drives the spinner and the disabling**, so they
/// cannot disagree: while the future is in flight `onPressed` is null,
/// which is both why the button is dead and why it is spinning.
///
/// **Finishing is announced.** A button that quietly becomes "Saved" has
/// told everyone looking at it and nobody else, and the moment a slow
/// action completes is exactly when attention has gone elsewhere.
///
/// It guards its own re-entry: a second press while busy cannot start a
/// second run, which is the bug every hand-rolled version of this has
/// the first time somebody double-clicks Save.
class PlinthAsyncButton extends StatefulWidget {
  const PlinthAsyncButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onError,
    this.busyChild,
    this.doneChild,
    this.doneLabel,
    this.errorLabel,
    this.variant = PlinthVariant.filled,
    this.color,
    this.size = PlinthSize.md,
    this.fullWidth = false,
    this.leadingIcon,
    this.resetAfter = const Duration(seconds: 2),
  });

  /// What the button says at rest.
  final Widget child;

  /// The work. Null disables the button, as everywhere else in this
  /// library.
  final Future<void> Function()? onPressed;

  /// Shown while the future is in flight. Null keeps [child] beside a
  /// spinner.
  final Widget? busyChild;

  /// Shown after it succeeds, until [resetAfter] elapses.
  final Widget? doneChild;

  /// What a screen reader hears when it finishes. Null announces
  /// nothing, which is right only when something else on the page does.
  final String? doneLabel;

  /// What a screen reader hears if the future throws.
  final String? errorLabel;

  /// Where a failure goes.
  ///
  /// The button never holds the result, so a caller cannot `catch`
  /// around it — without this, a thrown error has nowhere to go but the
  /// zone's handler, which is a long way from the button somebody just
  /// pressed. Given one, the error is delivered here and not rethrown;
  /// with none it is rethrown, because swallowing it silently would be
  /// worse than either.
  final void Function(Object error, StackTrace stackTrace)? onError;

  final PlinthVariant variant;
  final String? color;
  final PlinthSize size;
  final bool fullWidth;
  final Widget? leadingIcon;

  /// How long the done state lasts before returning to [child].
  final Duration resetAfter;

  @override
  State<PlinthAsyncButton> createState() => _PlinthAsyncButtonState();
}

enum _AsyncState { idle, busy, done }

class _PlinthAsyncButtonState extends State<PlinthAsyncButton> {
  _AsyncState _state = _AsyncState.idle;

  /// Held so `dispose` can cancel it. An `await Future.delayed` here
  /// would leave a timer running after the tree is gone — harmless,
  /// because every write is behind a `mounted` check, but a leak the
  /// test binding is right to refuse.
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _run() async {
    final work = widget.onPressed;
    // Re-entry guard as well as a null check: the button is disabled
    // while busy, but a keyboard repeat can arrive before the rebuild.
    if (work == null || _state == _AsyncState.busy) return;

    _reset?.cancel();
    setState(() => _state = _AsyncState.busy);
    try {
      await work();
      if (!mounted) return;
      setState(() => _state = _AsyncState.done);
      if (widget.doneLabel case final label?) {
        PlinthAnnounce.say(context, label);
      }
      _reset = Timer(widget.resetAfter, () {
        if (mounted && _state == _AsyncState.done) {
          setState(() => _state = _AsyncState.idle);
        }
      });
    } catch (error, stackTrace) {
      if (mounted) {
        setState(() => _state = _AsyncState.idle);
        if (widget.errorLabel case final label?) {
          PlinthAnnounce.say(context, label);
        }
      }
      final onError = widget.onError;
      if (onError == null) rethrow;
      onError(error, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _state == _AsyncState.busy;
    final done = _state == _AsyncState.done;

    final label = switch (_state) {
      _AsyncState.busy => widget.busyChild ?? widget.child,
      _AsyncState.done => widget.doneChild ?? widget.child,
      _AsyncState.idle => widget.child,
    };

    return PlinthButton(
      // Null while busy rather than a separate flag: the button is
      // disabled for the same reason it shows a spinner, so one piece
      // of state drives both.
      onPressed: busy || widget.onPressed == null ? null : _run,
      variant: widget.variant,
      color: widget.color,
      size: widget.size,
      fullWidth: widget.fullWidth,
      loading: busy,
      leadingIcon:
          done ? const Icon(Icons.check, size: 16) : widget.leadingIcon,
      child: label,
    );
  }
}
