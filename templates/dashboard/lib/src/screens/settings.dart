/// Settings, as the form every admin app grows within a week.
///
/// Worth noting what the save button does: it is a `PlinthAsyncButton`,
/// which runs the future and cannot be started twice. A plain button
/// plus a `_saving` flag is the same thing written out by hand in every
/// screen that has one, and wrong in at least one of them.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // The controller is the state for this field. Keeping a `String`
  // beside it as well is the usual way these two drift apart.
  final _nameController = TextEditingController(text: 'Northwind Trading');
  String _currency = 'usd';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _digest = true;
  bool _refundAlerts = false;

  Future<void> _save() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    PlinthAnnounce.say(context, 'Settings saved');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlinthPageHeader(
          title: 'Settings',
          subtitle: 'Applies to everyone in this workspace',
        ),
        SizedBox(height: theme.space(6)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlinthTextInput(
                label: 'Workspace name',
                controller: _nameController,
              ),
              SizedBox(height: theme.space(5)),
              PlinthSelect(
                label: 'Reporting currency',
                description: 'Totals across the dashboard are shown in this.',
                value: _currency,
                options: const [
                  PlinthSelectOption('usd', 'US dollar'),
                  PlinthSelectOption('eur', 'Euro'),
                  PlinthSelectOption('gbp', 'Pound sterling'),
                ],
                onChanged: (value) =>
                    setState(() => _currency = value ?? 'usd'),
              ),
              SizedBox(height: theme.space(6)),
              const PlinthText('Notifications', weight: FontWeight.w600),
              SizedBox(height: theme.space(3)),
              PlinthSwitch(
                value: _digest,
                label: 'Weekly digest',
                description: 'Monday morning, with last week’s totals.',
                onChanged: (value) => setState(() => _digest = value),
              ),
              SizedBox(height: theme.space(3)),
              PlinthSwitch(
                value: _refundAlerts,
                label: 'Refund alerts',
                description: 'Every refund over \$500, as it happens.',
                onChanged: (value) => setState(() => _refundAlerts = value),
              ),
              SizedBox(height: theme.space(6)),
              Align(
                alignment: Alignment.centerLeft,
                child: PlinthAsyncButton(
                  onPressed: _save,
                  child: const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
