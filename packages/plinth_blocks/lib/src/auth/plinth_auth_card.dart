import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// The card every authentication block is built in.
///
/// Sign in, sign up and password reset are the same shape — a bordered
/// card holding a title, an optional line of explanation, a column of
/// fields, one full-width action, and a way back out. Writing that
/// shape three times is how the three drift apart, so it is written
/// once and the blocks supply what differs.
///
/// Public rather than internal because the four blocks here are not the
/// only authentication screens an app has. A "check your email"
/// interstitial or an SSO hand-off is the same card with different
/// contents, and an app that has to rebuild the card to add one ends up
/// with a screen that does not match the others.
///
/// ```dart
/// PlinthAuthCard(
///   title: 'Confirm your email',
///   subtitle: 'We sent a link to name@example.com.',
///   action: PlinthButton(
///     fullWidth: true,
///     onPressed: resend,
///     child: const Text('Resend'),
///   ),
///   footer: PlinthAnchor('Back to sign in', onTap: signIn),
/// )
/// ```
class PlinthAuthCard extends StatelessWidget {
  const PlinthAuthCard({
    super.key,
    required this.title,
    this.subtitle,
    this.fields = const [],
    this.action,
    this.secondaryActions = const [],
    this.secondaryLabel,
    this.footer,
    this.width = 360,
    this.titleOrder = 3,
  });

  /// The heading. Required, because a card that does not say what it is
  /// for is one a password manager and a person both have to guess at.
  final String title;

  /// One line under the title. Null renders nothing rather than a gap.
  final String? subtitle;

  /// The form controls, laid out in a column with consistent gaps.
  ///
  /// Taken as widgets rather than a typed field description so a caller
  /// can put anything in the form — a phone field, a tenant picker, a
  /// captcha — without this needing a case for it.
  final List<Widget> fields;

  /// The primary action, usually a full-width [PlinthButton].
  final Widget? action;

  /// Alternative ways in, shown under a divider — SSO or social
  /// buttons. Empty renders no divider at all.
  final List<Widget> secondaryActions;

  /// The divider label above [secondaryActions]. Defaults to `OR`.
  ///
  /// A parameter rather than a constant because it is user-facing text,
  /// and this package has no localisation of its own: every string it
  /// would otherwise hardcode in English is something the caller can
  /// pass. See the note in the package README.
  final String? secondaryLabel;

  /// The way back out — typically a [PlinthAnchor], centred.
  ///
  /// A reset screen with no exit strands anyone who mistyped a URL, so
  /// this is offered on every block rather than only where it was
  /// remembered.
  final Widget? footer;

  /// The card's width. Null lets it fill whatever it is given, which is
  /// what a full-page auth route wants.
  final double? width;

  /// Heading level for [title], passed to [PlinthTitle.order].
  ///
  /// Exposed because a block dropped into a page that already has an
  /// `h1` needs to sit below it; a card that always announced itself as
  /// the same level would break the document outline a screen reader
  /// navigates by.
  final int titleOrder;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final card = PlinthCard(
      withBorder: true,
      p: PlinthSize.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          PlinthTitle(title, order: titleOrder),
          if (subtitle case final subtitle?) ...[
            SizedBox(height: theme.space(1)),
            PlinthText(subtitle, size: PlinthSize.sm, color: 'gray'),
          ],
          if (fields.isNotEmpty) ...[
            SizedBox(height: theme.space(5)),
            for (final (index, field) in fields.indexed) ...[
              if (index > 0) SizedBox(height: theme.space(3)),
              field,
            ],
          ],
          if (action case final action?) ...[
            SizedBox(height: theme.space(5)),
            action,
          ],
          if (secondaryActions.isNotEmpty) ...[
            SizedBox(height: theme.space(4)),
            PlinthDivider(label: secondaryLabel ?? 'OR'),
            SizedBox(height: theme.space(4)),
            for (final (index, secondary) in secondaryActions.indexed) ...[
              if (index > 0) SizedBox(height: theme.space(3)),
              secondary,
            ],
          ],
          if (footer case final footer?) ...[
            SizedBox(height: theme.space(4)),
            Center(child: footer),
          ],
        ],
      ),
    );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}
