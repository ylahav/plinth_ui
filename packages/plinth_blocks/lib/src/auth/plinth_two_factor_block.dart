import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import 'plinth_auth_card.dart';

/// The second-factor step: enter the code, verify, or ask for another.
///
/// The submit button stays disabled until the code is the full length,
/// which is doing more work than it looks like — the button is the
/// affordance that tells someone how many digits are expected, and a
/// verify that fails on a five-digit code says nothing useful.
///
/// ```dart
/// PlinthTwoFactorBlock(
///   onSubmit: (code) => auth.verify(code),
///   onResend: auth.resendCode,
///   error: _lastAttemptFailed ? 'That code has expired.' : null,
/// )
/// ```
class PlinthTwoFactorBlock extends StatefulWidget {
  const PlinthTwoFactorBlock({
    super.key,
    this.onSubmit,
    this.onResend,
    this.length = 6,
    this.autoSubmit = false,
    this.title = 'Two-factor code',
    this.subtitle = 'Enter the six digits from your authenticator app.',
    this.submitLabel = 'Verify',
    this.resendLabel = 'Send a new code',
    this.width = 340,
    this.titleOrder = 4,
    this.error,
  });

  /// Called with the completed code. Null disables the button even when
  /// the code is complete.
  final ValueChanged<String>? onSubmit;

  /// Called to request another code. Null hides the link.
  final VoidCallback? onResend;

  /// How many digits. Change [subtitle] to match — it is a separate
  /// parameter rather than interpolated, because the sentence differs
  /// by more than the number in most languages.
  final int length;

  /// Whether to submit as soon as the last digit is entered.
  ///
  /// Off by default. It saves a tap and it takes the decision away: an
  /// auto-submit that fires on a mistyped digit spends an attempt
  /// before the person has finished reading what they typed.
  final bool autoSubmit;

  final String title;
  final String? subtitle;
  final String submitLabel;
  final String resendLabel;
  final double? width;
  final int titleOrder;

  /// A failed or expired attempt, rendered above the input.
  final String? error;

  @override
  State<PlinthTwoFactorBlock> createState() => _PlinthTwoFactorBlockState();
}

class _PlinthTwoFactorBlockState extends State<PlinthTwoFactorBlock> {
  String _code = '';

  bool get _complete => _code.length == widget.length;

  void _onChanged(String value) {
    setState(() => _code = value);
    if (widget.autoSubmit && _complete) widget.onSubmit?.call(_code);
  }

  @override
  Widget build(BuildContext context) {
    return PlinthAuthCard(
      title: widget.title,
      subtitle: widget.subtitle,
      width: widget.width,
      titleOrder: widget.titleOrder,
      footer: widget.onResend == null
          ? null
          : PlinthAnchor(widget.resendLabel, onTap: widget.onResend!),
      fields: [
        if (widget.error case final error?)
          PlinthAlert(color: 'red', child: Text(error)),
        Center(
          child: PlinthPinInput(
            length: widget.length,
            value: _code,
            onChanged: _onChanged,
          ),
        ),
      ],
      action: PlinthButton(
        fullWidth: true,
        onPressed: _complete && widget.onSubmit != null
            ? () => widget.onSubmit!(_code)
            : null,
        child: Text(widget.submitLabel),
      ),
    );
  }
}
