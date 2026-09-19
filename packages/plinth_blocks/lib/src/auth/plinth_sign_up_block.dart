import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import 'plinth_auth_card.dart';

/// What a [PlinthSignUpBlock] hands back when it is submitted.
typedef PlinthSignUpValues = ({
  String name,
  String email,
  String password,
  bool acceptedTerms,
});

/// A registration card: name, email, password, terms, and a way in.
///
/// The terms checkbox gates the submit button when [requireTerms] is
/// set, which is the behaviour an app wants and the one it is easy to
/// forget — a disabled button says "something is missing" where a
/// button that submits and then fails does not.
///
/// ```dart
/// PlinthSignUpBlock(
///   onSubmit: (values) => auth.register(values),
///   termsLabel: 'I agree to the terms of service',
///   footer: PlinthAnchor('Already have an account?', onTap: signIn),
/// )
/// ```
class PlinthSignUpBlock extends StatefulWidget {
  const PlinthSignUpBlock({
    super.key,
    this.onSubmit,
    this.title = 'Create an account',
    this.subtitle,
    this.nameLabel = 'Name',
    this.namePlaceholder,
    this.emailLabel = 'Email',
    this.emailPlaceholder = 'you@example.com',
    this.passwordLabel = 'Password',
    this.passwordDescription,
    this.termsLabel = 'I agree to the terms of service',
    this.submitLabel = 'Create account',
    this.requireTerms = true,
    this.showTerms = true,
    this.alternatives = const [],
    this.alternativesLabel,
    this.footer,
    this.width = 360,
    this.titleOrder = 3,
    this.error,
  });

  /// Called with the entered values. Null disables the submit button.
  final ValueChanged<PlinthSignUpValues>? onSubmit;

  final String title;
  final String? subtitle;
  final String nameLabel;
  final String? namePlaceholder;
  final String emailLabel;
  final String? emailPlaceholder;
  final String passwordLabel;

  /// Help text under the password field — a length or complexity rule.
  ///
  /// Under the field rather than in a tooltip, because a requirement
  /// somebody has to hover to discover is one they will meet by
  /// failing the form first.
  final String? passwordDescription;

  final String termsLabel;
  final String submitLabel;

  /// Whether the terms checkbox has to be ticked before submitting.
  final bool requireTerms;

  /// Whether to show the terms checkbox at all.
  final bool showTerms;

  final List<Widget> alternatives;
  final String? alternativesLabel;
  final Widget? footer;
  final double? width;
  final int titleOrder;
  final String? error;

  @override
  State<PlinthSignUpBlock> createState() => _PlinthSignUpBlockState();
}

class _PlinthSignUpBlockState extends State<PlinthSignUpBlock> {
  String _name = '';
  String _email = '';
  String _password = '';
  bool _acceptedTerms = false;

  bool get _canSubmit {
    if (widget.onSubmit == null) return false;
    if (widget.showTerms && widget.requireTerms) return _acceptedTerms;
    return true;
  }

  void _submit() => widget.onSubmit?.call((
        name: _name,
        email: _email,
        password: _password,
        acceptedTerms: _acceptedTerms,
      ));

  @override
  Widget build(BuildContext context) {
    return PlinthAuthCard(
      title: widget.title,
      subtitle: widget.subtitle,
      width: widget.width,
      titleOrder: widget.titleOrder,
      secondaryActions: widget.alternatives,
      secondaryLabel: widget.alternativesLabel,
      footer: widget.footer,
      fields: [
        if (widget.error case final error?)
          PlinthAlert(color: 'red', child: Text(error)),
        PlinthTextInput(
          label: widget.nameLabel,
          placeholder: widget.namePlaceholder,
          onChanged: (value) => _name = value,
        ),
        PlinthTextInput(
          label: widget.emailLabel,
          placeholder: widget.emailPlaceholder,
          onChanged: (value) => _email = value,
        ),
        PlinthPasswordInput(
          label: widget.passwordLabel,
          description: widget.passwordDescription,
          onChanged: (value) => _password = value,
        ),
        if (widget.showTerms)
          PlinthCheckbox(
            label: widget.termsLabel,
            value: _acceptedTerms,
            size: PlinthSize.sm,
            onChanged: (value) => setState(() => _acceptedTerms = value),
          ),
      ],
      action: PlinthButton(
        fullWidth: true,
        onPressed: _canSubmit ? _submit : null,
        child: Text(widget.submitLabel),
      ),
    );
  }
}
