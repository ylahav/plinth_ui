/// The permissions tab: who is on the team, and what they can do.
///
/// Roles are badges whose colour comes from `teamRoles` and whose text
/// is the role. Four roles is already more than a red/green pair can
/// distinguish, which is the usual point at which colour-as-meaning
/// quietly stops working and nobody notices because they can see it.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import '../session.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlinthTable(
          columns: const ['Member', 'Role', 'Last seen'],
          highlightOnHover: true,
          rows: [
            for (final member in team)
              [
                PlinthUserTile(
                  name: member.name,
                  detail: member.email,
                  size: PlinthSize.sm,
                ),
                PlinthBadge(
                  member.role,
                  color: theme.semanticColors[member.role]?.ramp,
                ),
                Text(member.lastSeen),
              ],
          ],
        ),
        SizedBox(height: theme.space(6)),
        Align(
          alignment: Alignment.centerLeft,
          child: PlinthButton(
            onPressed: () {},
            child: const Text('Invite someone'),
          ),
        ),
      ],
    );
  }
}
