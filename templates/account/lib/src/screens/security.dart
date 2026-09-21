/// The security tab: a password that is judged as it is typed, and a
/// second factor that can be turned on.
///
/// `PlinthPasswordStrength` is the block worth looking at. Its rules
/// carry their own tests, so "at least 10 characters" is checked by the
/// same object that renders it — a checklist that drifts from the
/// validator is the usual way these two disagree, and then the meter
/// says green while the form says no.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import '../session.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key, required this.session});

  final Session session;

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final account = widget.session.account!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlinthCard(
          withBorder: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PlinthText('Change password', weight: FontWeight.w600),
              SizedBox(height: theme.space(4)),
              PlinthPasswordInput(
                label: 'New password',
                onChanged: (value) => setState(() => _password = value),
              ),
              SizedBox(height: theme.space(4)),

              // The meter takes the value; it does not capture it. Two
              // widgets rather than one, because the same meter has to
              // work under a field you already have.
              PlinthPasswordStrength(value: _password),
            ],
          ),
        ),
        SizedBox(height: theme.space(6)),
        PlinthCard(
          withBorder: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PlinthText(
                'Two-factor authentication',
                weight: FontWeight.w600,
              ),
              SizedBox(height: theme.space(4)),
              PlinthSwitch(
                value: account.twoFactor,
                label: 'Require a code at sign-in',
                description: 'From an authenticator app on your phone.',
                onChanged: (on) {
                  widget.session.setTwoFactor(on: on);

                  // The switch's own state change is announced by the
                  // switch. This says what it *means*, which the switch
                  // has no way to know.
                  PlinthAnnounce.say(
                    context,
                    on
                        ? 'Two-factor authentication is on'
                        : 'Two-factor authentication is off',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
