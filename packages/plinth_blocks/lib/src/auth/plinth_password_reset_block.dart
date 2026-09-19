import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import 'plinth_auth_card.dart';

/// A "send me a reset link" card.
///
/// Two states in one widget: the form, and the confirmation that
/// replaces it once a link has been sent. [sent] switches between them,
/// so the caller holds one bool rather than deciding which of two
/// blocks to render.
///
/// The confirmation is part of the block rather than left to the app
/// because it is the half that gets skipped. A reset form that submits
/// and then looks unchanged reads as broken, and the usual result is
/// somebody requesting four emails.
///
/// ```dart
/// PlinthPasswordResetBlock(
///   sent: _sent,
///   onSubmit: (email) async {
///     await auth.sendReset(email);
///     setState(() => _sent = true);
///   },
///   onBack: () => router.go('/sign-in'),
/// )
/// ```
class PlinthPasswordResetBlock extends StatefulWidget {
  const PlinthPasswordResetBlock({
    super.key,
    this.onSubmit,
    this.onBack,
    this.sent = false,
    this.title = 'Reset your password',
    this.subtitle = 'We will send a link to the address on your account.',
    this.emailLabel = 'Email',
    this.emailPlaceholder = 'you@example.com',
    this.submitLabel = 'Send reset link',
    this.backLabel = 'Back to sign in',
    this.sentTitle = 'Check your email',
    this.sentSubtitle = 'If that address has an account, a reset link is on '
        'its way.',
    this.width = 340,
    this.titleOrder = 4,
  });

  /// Called with the entered address. Null disables the submit button.
  final ValueChanged<String>? onSubmit;

  /// The way back to sign-in. Null hides the link.
  ///
  /// Offered by default because a reset screen with no exit strands
  /// anyone who arrived at it by mistyping a URL.
  final VoidCallback? onBack;

  /// Whether the link has been sent — swaps the form for the
  /// confirmation.
  final bool sent;

  final String title;
  final String? subtitle;
  final String emailLabel;
  final String? emailPlaceholder;
  final String submitLabel;
  final String backLabel;

  /// Heading shown once [sent] is true.
  final String sentTitle;

  /// Explanation shown once [sent] is true.
  ///
  /// Worded not to confirm whether the address has an account, which is
  /// the default because the opposite turns a reset form into a way to
  /// enumerate who has registered.
  final String? sentSubtitle;

  final double? width;
  final int titleOrder;

  @override
  State<PlinthPasswordResetBlock> createState() =>
      _PlinthPasswordResetBlockState();
}

class _PlinthPasswordResetBlockState extends State<PlinthPasswordResetBlock> {
  String _email = '';

  @override
  Widget build(BuildContext context) {
    final back = widget.onBack == null
        ? null
        : PlinthAnchor(widget.backLabel, onTap: widget.onBack!);

    if (widget.sent) {
      return PlinthAuthCard(
        title: widget.sentTitle,
        subtitle: widget.sentSubtitle,
        width: widget.width,
        titleOrder: widget.titleOrder,
        footer: back,
      );
    }

    return PlinthAuthCard(
      title: widget.title,
      subtitle: widget.subtitle,
      width: widget.width,
      titleOrder: widget.titleOrder,
      footer: back,
      fields: [
        PlinthTextInput(
          label: widget.emailLabel,
          placeholder: widget.emailPlaceholder,
          onChanged: (value) => _email = value,
        ),
      ],
      action: PlinthButton(
        fullWidth: true,
        onPressed:
            widget.onSubmit == null ? null : () => widget.onSubmit!(_email),
        child: Text(widget.submitLabel),
      ),
    );
  }
}
