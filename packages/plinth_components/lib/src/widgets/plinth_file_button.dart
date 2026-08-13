import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_button.dart';
import 'plinth_loader.dart';

/// A button that opens your file picker, matching Mantine's
/// `FileButton`.
///
/// **This does not open a file picker**, for the same reason
/// [PlinthFileInput] doesn't: Flutter has no built-in one, and every
/// package that provides it would become a dependency of
/// `plinth_components` for every app using the library. [onPick] is
/// yours.
///
/// Where [PlinthFileInput] is a form field — label, error, the chosen
/// files listed underneath — this is only the trigger. Reach for it
/// when the selection is shown somewhere else entirely, or isn't shown
/// at all: an avatar that replaces itself, an import that starts
/// immediately.
///
/// It disables itself while [onPick] is in flight, which is the one
/// thing a plain button gets wrong here — a picker is slow enough to
/// invite a second tap, and two open pickers is a state nobody
/// handles.
///
/// ```dart
/// PlinthFileButton<XFile>(
///   onPick: () => openFile().then((f) => f == null ? null : [f]),
///   onChanged: (files) => setState(() => _avatar = files.first),
///   child: const Text('Upload'),
/// )
/// ```
class PlinthFileButton<T> extends StatefulWidget {
  const PlinthFileButton({
    super.key,
    required this.onPick,
    required this.onChanged,
    required this.child,
    this.variant = PlinthVariant.filled,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.fullWidth = false,
    this.leadingIcon,
    this.enabled = true,
  });

  /// Opens your picker and returns what was chosen. Returning null or
  /// an empty list is treated as "cancelled" and reports nothing —
  /// cancelling should not clear a previous selection.
  final Future<List<T>?> Function() onPick;

  final ValueChanged<List<T>> onChanged;

  final Widget child;

  final PlinthVariant variant;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool fullWidth;
  final Widget? leadingIcon;
  final bool enabled;

  @override
  State<PlinthFileButton<T>> createState() => _PlinthFileButtonState<T>();
}

class _PlinthFileButtonState<T> extends State<PlinthFileButton<T>> {
  bool _picking = false;

  Future<void> _pick() async {
    if (_picking) return;
    setState(() => _picking = true);

    try {
      final picked = await widget.onPick();
      if (picked != null && picked.isNotEmpty) widget.onChanged(picked);
    } finally {
      // The picker can outlive this widget — a route change while the
      // dialog is open is ordinary, not exceptional.
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && !_picking;

    return PlinthButton(
      onPressed: enabled ? _pick : null,
      variant: widget.variant,
      size: widget.size,
      color: widget.color,
      radius: widget.radius,
      fullWidth: widget.fullWidth,
      leadingIcon: _picking
          ? PlinthLoader(size: widget.size, color: widget.color)
          : widget.leadingIcon,
      child: widget.child,
    );
  }
}
