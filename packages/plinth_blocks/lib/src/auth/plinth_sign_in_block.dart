import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import 'plinth_auth_card.dart';

/// What a [PlinthSignInBlock] hands back when it is submitted.
///
/// A record rather than three callback arguments so adding a field
/// later is not a breaking change to every call site.
typedef PlinthSignInValues = ({
  String email,
  String password,
  bool rememberMe,
});

/// A sign-in card: email, password, remember-me, and a way in.
///
/// Holds the field values itself and reports them on submit, because
/// the alternative — making every caller wire three controllers before
/// they can see a sign-in form — is most of the work the block exists
/// to remove. An app that already has form state can ignore this and
/// build the same card from [PlinthAuthCard] directly.
///
/// ```dart
/// PlinthSignInBlock(
///   onSubmit: (values) => auth.signIn(values.email, values.password),
///   onForgotPassword: () => router.go('/reset'),
///   alternatives: [
///     PlinthButton(
///       variant: PlinthVariant.defaultVariant,
///       fullWidth: true,
///       onPressed: auth.google,
///       child: const Text('Continue with Google'),
///     ),
///   ],
/// )
/// ```
///
/// Every visible string is a parameter. The defaults are English
/// because something has to render before a caller has translated
/// anything, not because this package assumes an English app.
class PlinthSignInBlock extends StatefulWidget {
  const PlinthSignInBlock({
    super.key,
    this.onSubmit,
    this.onForgotPassword,
    this.title = 'Welcome back',
    this.subtitle,
    this.emailLabel = 'Email',
    this.emailPlaceholder = 'you@example.com',
    this.passwordLabel = 'Password',
    this.passwordPlaceholder,
    this.rememberMeLabel = 'Remember me',
    this.forgotPasswordLabel = 'Forgot password?',
    this.submitLabel = 'Sign in',
    this.showRememberMe = true,
    this.alternatives = const [],
    this.alternativesLabel,
    this.footer,
    this.width = 360,
    this.titleOrder = 3,
    this.error,
  });

  /// Called with the entered values. A null callback disables the
  /// submit button, which is the library's convention for "not usable
  /// right now" — see the naming rules in docs/COMPONENTS.md.
  final ValueChanged<PlinthSignInValues>? onSubmit;

  /// Called when the "forgot password" link is tapped. Null hides the
  /// link rather than rendering one that does nothing.
  final VoidCallback? onForgotPassword;

  final String title;
  final String? subtitle;
  final String emailLabel;
  final String? emailPlaceholder;
  final String passwordLabel;
  final String? passwordPlaceholder;
  final String rememberMeLabel;
  final String forgotPasswordLabel;
  final String submitLabel;

  /// Whether to offer the remember-me checkbox.
  final bool showRememberMe;

  /// Other ways in — SSO or social buttons — shown under a divider.
  final List<Widget> alternatives;

  /// The divider label above [alternatives]. Defaults to `OR`.
  final String? alternativesLabel;

  /// Shown centred at the bottom, usually a link to sign up.
  final Widget? footer;

  final double? width;
  final int titleOrder;

  /// A failed-attempt message, rendered above the fields.
  ///
  /// An [PlinthAlert] rather than red text under the password field:
  /// "those credentials did not match" is about the attempt, not about
  /// either field, and attaching it to one of them tells a screen
  /// reader the password is malformed when it is not.
  final String? error;

  @override
  State<PlinthSignInBlock> createState() => _PlinthSignInBlockState();
}

class _PlinthSignInBlockState extends State<PlinthSignInBlock> {
  String _email = '';
  String _password = '';
  bool _rememberMe = false;

  void _submit() => widget.onSubmit?.call((
        email: _email,
        password: _password,
        rememberMe: _rememberMe,
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
          PlinthAlert(
            color: 'red',
            // Announced when it appears: a sign-in failure that only
            // shows up visually is a dead end for anyone not looking
            // at that part of the screen.
            child: Text(error),
          ),
        PlinthTextInput(
          label: widget.emailLabel,
          placeholder: widget.emailPlaceholder,
          onChanged: (value) => _email = value,
        ),
        PlinthPasswordInput(
          label: widget.passwordLabel,
          placeholder: widget.passwordPlaceholder,
          onChanged: (value) => _password = value,
        ),
        if (widget.showRememberMe || widget.onForgotPassword != null)
          // Wrap rather than Row: at a large text scale these two stop
          // fitting side by side in a 360-wide card, and a sign-in form
          // is exactly where that has to degrade rather than clip.
          PlinthGroup(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            gap: PlinthSize.xs,
            children: [
              if (widget.showRememberMe)
                PlinthCheckbox(
                  label: widget.rememberMeLabel,
                  value: _rememberMe,
                  size: PlinthSize.sm,
                  onChanged: (value) => setState(() => _rememberMe = value),
                ),
              if (widget.onForgotPassword case final onForgot?)
                PlinthAnchor(
                  widget.forgotPasswordLabel,
                  size: PlinthSize.sm,
                  onTap: onForgot,
                ),
            ],
          ),
      ],
      action: PlinthButton(
        fullWidth: true,
        onPressed: widget.onSubmit == null ? null : _submit,
        child: Text(widget.submitLabel),
      ),
    );
  }
}
