import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A value the server issued and you need to get back out intact — an
/// API key, a webhook secret, a recovery code.
///
/// ```dart
/// PlinthSecretField(
///   label: 'Publishable key',
///   value: key,
///   onRegenerate: rotateKey,
///   warning: 'Regenerating takes effect immediately.',
/// )
/// ```
///
/// **A password field for its reveal toggle, not for secrecy.** The
/// value is already known to whoever is looking at the screen; what the
/// mask buys is that a key on screen in a shared window is a key in a
/// screenshot. So it starts hidden and reveals on request, rather than
/// being hidden from the person who owns it.
///
/// **Nobody types into it**, so it is read-only by construction. The
/// affordances that matter are copy and regenerate, which is why they
/// are the two parameters and the text is not editable.
class PlinthSecretField extends StatefulWidget {
  const PlinthSecretField({
    super.key,
    required this.value,
    this.label,
    this.description,
    this.warning,
    this.onRegenerate,
    this.regenerateLabel = 'Regenerate',
    this.copyLabel = 'Copy',
    this.width,
  });

  /// The secret itself.
  final String value;

  final String? label;

  /// A line under the field.
  final String? description;

  /// What regenerating costs, shown as an alert rather than as muted
  /// text — rotating a live key breaks whatever is using it, and that
  /// is not a footnote.
  final String? warning;

  /// Issues a new value. Null hides the button: a regenerate that does
  /// nothing is worse than no regenerate.
  final VoidCallback? onRegenerate;

  final String regenerateLabel;
  final String copyLabel;
  final double? width;

  @override
  State<PlinthSecretField> createState() => _PlinthSecretFieldState();
}

class _PlinthSecretFieldState extends State<PlinthSecretField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(PlinthSecretField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The value arrives from the server and can change under us — a
    // regenerate replaces it while this widget stays mounted.
    if (widget.value != oldWidget.value) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = PlinthStack(
      gap: PlinthSize.xs,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              // No `onChanged`, which in this library is how a field
              // says "read-only but still selectable" — as opposed to
              // `enabled: false`, which greys it out and takes it out
              // of the focus order. You have to be able to select a key
              // to copy it by hand.
              child: PlinthPasswordInput(
                label: widget.label,
                controller: _controller,
              ),
            ),
            const SizedBox(width: 8),
            PlinthCopyButton(value: widget.value),
            if (widget.onRegenerate case final onRegenerate?) ...[
              const SizedBox(width: 4),
              PlinthButton(
                variant: PlinthVariant.outline,
                onPressed: onRegenerate,
                child: Text(widget.regenerateLabel),
              ),
            ],
          ],
        ),
        if (widget.description case final description?)
          PlinthText(description, size: PlinthSize.xs, color: 'gray'),
        if (widget.warning case final warning?)
          PlinthAlert(color: 'yellow', child: Text(warning)),
      ],
    );

    return widget.width == null
        ? body
        : SizedBox(width: widget.width, child: body);
  }
}
