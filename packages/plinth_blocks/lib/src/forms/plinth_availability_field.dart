/// A field that asks another system whether what you typed is free.
///
/// Usernames, workspace slugs, email addresses at signup. The shape is
/// always the same and always got wrong in one of three ways, so this
/// gets it right once.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// What the field currently knows.
enum PlinthAvailability {
  /// Nothing typed yet, or too little to be worth asking about.
  idle,

  /// Typed, but the debounce has not elapsed. Deliberately distinct
  /// from [checking]: nothing has been asked yet, so claiming to be
  /// checking would be a lie the user can see through when the answer
  /// arrives too fast.
  waiting,

  /// A request is in flight.
  checking,

  available,
  taken,

  /// The check itself failed — the network, not the name.
  failed,
}

/// A text field that checks its value against something asynchronous
/// and says what came back.
///
/// Three things go wrong in hand-rolled versions of this, and each is
/// handled here:
///
/// **It asks on every keystroke.** Typing `ada` is three requests, two
/// of them about prefixes nobody chose. [debounce] waits for a pause.
///
/// **Answers arrive out of order.** `ad` is slow and `ada` is fast, so
/// the answer about `ad` lands last and overwrites it. Every request
/// carries a sequence number and a stale answer is dropped — this is
/// the bug that survives review, because it needs two requests in
/// flight and a particular ordering to show itself.
///
/// **The result is silent.** It appears after the user stopped typing,
/// which is exactly when a sighted user glances down and a screen
/// reader user hears nothing at all. The result is a live region; the
/// spinner is not, because the spinner changes on every pause and
/// would interrupt the typing that caused it.
class PlinthAvailabilityField extends StatefulWidget {
  const PlinthAvailabilityField({
    super.key,
    required this.check,
    this.onChanged,
    this.controller,
    this.label,
    this.description,
    this.placeholder,
    this.prefix,
    this.minLength = 3,
    this.debounce = const Duration(milliseconds: 400),
    this.availableLabel = 'Available',
    this.takenLabel = 'Already taken',
    this.failedLabel = 'Could not check just now',
    this.availableColor = 'green',
    this.takenColor = 'red',
    this.failedColor = 'yellow',
    this.size = PlinthSize.md,
    this.width,
  });

  /// Asks whether [value] is free. `true` means available.
  ///
  /// Throwing is a legitimate answer — it becomes
  /// [PlinthAvailability.failed] and the user is told the *check*
  /// failed rather than that the name is taken. Those are different
  /// facts and conflating them tells somebody their preferred name is
  /// gone when it is not.
  final Future<bool> Function(String value) check;

  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? label;
  final String? description;
  final String? placeholder;

  /// Rendered before the field — `plinth.app/` in front of a slug.
  final Widget? prefix;

  /// Below this, nothing is asked. A one-character prefix matches
  /// everything and tells the user nothing.
  final int minLength;

  final Duration debounce;
  final String availableLabel;
  final String takenLabel;
  final String failedLabel;

  /// Palette keys, not semantic roles.
  ///
  /// A block cannot assume the app declared a role called `available` —
  /// `semanticColors` is the app's, and a block that reached into it
  /// would resolve to the primary ramp in every app that had not read
  /// this file. Ramps exist in every theme, and `PlinthText` walks them
  /// against the surface for contrast anyway, so the floor holds
  /// without the block knowing which ramp it got.
  final String availableColor;
  final String takenColor;
  final String failedColor;

  final PlinthSize size;
  final double? width;

  @override
  State<PlinthAvailabilityField> createState() =>
      _PlinthAvailabilityFieldState();
}

class _PlinthAvailabilityFieldState extends State<PlinthAvailabilityField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  Timer? _debounce;
  var _state = PlinthAvailability.idle;

  /// Bumped per request. An answer whose number is not the current one
  /// is about a value the user has already typed past.
  var _sequence = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    _debounce?.cancel();

    if (value.trim().length < widget.minLength) {
      // Also bump the sequence: a request already in flight is now
      // about a value that is no longer being asked about.
      _sequence++;
      setState(() => _state = PlinthAvailability.idle);
      return;
    }

    setState(() => _state = PlinthAvailability.waiting);
    _debounce = Timer(widget.debounce, () => _ask(value.trim()));
  }

  Future<void> _ask(String value) async {
    final seq = ++_sequence;
    setState(() => _state = PlinthAvailability.checking);

    PlinthAvailability result;
    try {
      result = await widget.check(value)
          ? PlinthAvailability.available
          : PlinthAvailability.taken;
    } catch (_) {
      result = PlinthAvailability.failed;
    }

    // The two guards that matter: the widget may be gone, and the
    // answer may be about a value the user has typed past.
    if (!mounted || seq != _sequence) return;
    setState(() => _state = result);
  }

  String? get _message => switch (_state) {
        PlinthAvailability.available => widget.availableLabel,
        PlinthAvailability.taken => widget.takenLabel,
        PlinthAvailability.failed => widget.failedLabel,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final message = _message;

    final field = PlinthTextInput(
      label: widget.label,
      description: widget.description,
      placeholder: widget.placeholder,
      controller: _controller,
      onChanged: _onChanged,
      size: widget.size,
      leadingIcon: widget.prefix,
      loading: _state == PlinthAvailability.checking,
      trailing: switch (_state) {
        PlinthAvailability.available => Icon(
            Icons.check,
            size: theme.fontSizes[widget.size],

            // `nonText` because an icon is not text: WCAG 1.4.11 asks
            // 3:1 of it, and holding it to 4.5 would darken a tick
            // nobody needed darkened.
            color: theme.readableOn(
              widget.availableColor,
              theme.surface,
              level: PlinthContrast.nonText,
            ),
          ),
        PlinthAvailability.taken => Icon(
            Icons.close,
            size: theme.fontSizes[widget.size],
            color: theme.readableOn(
              widget.takenColor,
              theme.surface,
              level: PlinthContrast.nonText,
            ),
          ),
        _ => null,
      },
    );

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          field,
          if (message != null) ...[
            SizedBox(height: theme.space(1)),

            // The answer is announced. It lands after the user stopped
            // typing, so nothing else would tell a reader it arrived.
            PlinthLiveRegion(
              message: message,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlinthText(
                    message,
                    size: PlinthSize.xs,
                    color: switch (_state) {
                      PlinthAvailability.available => widget.availableColor,
                      PlinthAvailability.taken => widget.takenColor,
                      _ => widget.failedColor,
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
