/// The profile tab: who you are, as the app understands it.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import '../session.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlinthProfileCard(
          name: account.name,
          detail: account.email,
          centered: false,
          badge: PlinthBadge(
            account.role,
            color: theme.semanticColors[account.role]?.ramp,
          ),
          bio: 'Signing things off since 2019.',
          actions: [
            PlinthButton(
              variant: PlinthVariant.defaultVariant,
              onPressed: () {},
              child: const Text('Edit profile'),
            ),
          ],
        ),
        SizedBox(height: theme.space(6)),
        PlinthCard(
          withBorder: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlinthText('Danger zone', weight: FontWeight.w600),
              SizedBox(height: theme.space(2)),
              const PlinthText(
                'Deleting an account removes its team memberships too.',
                size: PlinthSize.sm,
                color: 'dimmed',
              ),
              SizedBox(height: theme.space(4)),

              // Asks in place rather than in a dialog, and says so out
              // loud. A destructive action that only *looks* different
              // after the first tap is one a reader never notices arming.
              Align(
                alignment: Alignment.centerLeft,
                child: PlinthConfirmButton(
                  label: 'Delete account',
                  question: 'Delete this account for good?',
                  confirmLabel: 'Delete',
                  onConfirm: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
