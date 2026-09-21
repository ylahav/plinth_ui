import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A destructive action that asks once, in place.
///
/// ```dart
/// PlinthConfirmButton(
///   label: 'Delete project',
///   question: 'Delete permanently?',
///   confirmLabel: 'Delete',
///   onConfirm: deleteProject,
/// )
/// ```
///
/// **Two steps in place rather than a modal.** A dialog is right when
/// the consequence needs explaining; for a single row it costs a modal,
/// a focus trap and a dismissal to ask a question the button can ask
/// itself.
///
/// **The question is announced when it appears.** Pressing "Delete
/// project" and having the control silently become three controls is
/// the failure this avoids — a screen reader user would hear nothing
/// and find the button gone.
class PlinthConfirmButton extends StatefulWidget {
  const PlinthConfirmButton({
    super.key,
    required this.label,
    this.onConfirm,
    this.question = 'Are you sure?',
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.color = 'red',
    this.icon,
    this.variant = PlinthVariant.subtle,
    this.size = PlinthSize.md,
    this.announceQuestion = true,
  });

  /// What the button says before it asks.
  final String label;

  /// The action. Null disables the button — a delete that deletes
  /// nothing should not offer to.
  final VoidCallback? onConfirm;

  /// What it asks. Short: it sits inline, beside the answer.
  final String question;

  final String confirmLabel;
  final String cancelLabel;

  /// Palette key. Red by default, because this shape is for the actions
  /// worth asking about.
  final String color;

  final Widget? icon;
  final PlinthVariant variant;
  final PlinthSize size;

  /// Whether to announce [question] when the control switches. Off only
  /// if something else on the page already says it.
  final bool announceQuestion;

  @override
  State<PlinthConfirmButton> createState() => _PlinthConfirmButtonState();
}

class _PlinthConfirmButtonState extends State<PlinthConfirmButton> {
  bool _asking = false;

  void _ask() {
    setState(() => _asking = true);
    if (widget.announceQuestion) {
      PlinthAnnounce.say(context, widget.question);
    }
  }

  void _answer({required bool confirmed}) {
    setState(() => _asking = false);
    if (confirmed) widget.onConfirm?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_asking) {
      return PlinthButton(
        variant: widget.variant,
        color: widget.color,
        size: widget.size,
        onPressed: widget.onConfirm == null ? null : _ask,
        leadingIcon: widget.icon,
        child: Text(widget.label),
      );
    }

    return PlinthGroup(
      gap: PlinthSize.xs,
      children: [
        PlinthText(widget.question, size: PlinthSize.sm),
        PlinthButton(
          size: PlinthSize.sm,
          color: widget.color,
          onPressed: () => _answer(confirmed: true),
          child: Text(widget.confirmLabel),
        ),
        PlinthButton(
          size: PlinthSize.sm,
          variant: PlinthVariant.subtle,
          onPressed: () => _answer(confirmed: false),
          child: Text(widget.cancelLabel),
        ),
      ],
    );
  }
}
