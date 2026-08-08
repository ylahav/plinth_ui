import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

void main() => runApp(const PlinthExampleApp());

class PlinthExampleApp extends StatelessWidget {
  const PlinthExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plinth UI',
      theme: ThemeData(
        useMaterial3: true,
        extensions: [PlinthTheme.defaultTheme],
      ),
      home: const ShowcasePage(),
    );
  }
}

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  final _panel = PlinthDisclosureController();
  final _modal = PlinthDisclosureController();
  final _drawer = PlinthDisclosureController();
  final _popover = PlinthDisclosureController();
  final _menu = PlinthDisclosureController();

  String _email = '';
  bool _agreed = false;
  String? _plan = 'free';
  String? _country;
  bool _alertVisible = true;
  bool _notifications = true;
  String _activeTab = 'account';

  @override
  void initState() {
    super.initState();
    _panel.addListener(_onPanelChanged);
  }

  void _onPanelChanged() => setState(() {});

  @override
  void dispose() {
    _panel.removeListener(_onPanelChanged);
    _panel.dispose();
    _modal.dispose();
    _drawer.dispose();
    _popover.dispose();
    _menu.dispose();
    super.dispose();
  }

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold));

  Widget _gap([double height = 32]) => SizedBox(height: height);

  @override
  Widget build(BuildContext context) {
    final deleteModal = PlinthModal(
      controller: _modal,
      title: 'Delete item?',
      child: Builder(
        builder: (dialogContext) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PlinthText(
              'This action cannot be undone. This will permanently remove the item.',
              color: 'gray',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PlinthButton(
                  variant: PlinthVariant.subtle,
                  color: 'gray',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                PlinthButton(
                  color: 'red',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final navDrawer = PlinthDrawer(
      controller: _drawer,
      title: 'Navigation',
      position: PlinthDrawerPosition.left,
      child: Builder(
        builder: (dialogContext) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in ['Dashboard', 'Projects', 'Settings'])
              PlinthButton(
                variant: PlinthVariant.subtle,
                color: 'gray',
                fullWidth: true,
                onPressed: () => Navigator.of(dialogContext).pop(),
                child:
                    Align(alignment: Alignment.centerLeft, child: Text(item)),
              ),
          ],
        ),
      ),
    );

    return PlinthModalHost(
      modal: deleteModal,
      child: PlinthDrawerHost(
        drawer: navDrawer,
        child: Scaffold(
          appBar: AppBar(title: const Text('Plinth UI — Component Showcase')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                if (_alertVisible) ...[
                  PlinthAlert(
                    title: 'Heads up',
                    color: 'blue',
                    icon: const Icon(Icons.info_outline),
                    onClose: () => setState(() => _alertVisible = false),
                    child: const Text(
                      'Full primitive set: forms, feedback, overlays, and now '
                      'Switch, Avatar, Tooltip, and Popover.',
                    ),
                  ),
                  _gap(),
                ],
                _sectionTitle('Avatars'),
                _gap(12),
                Row(
                  children: [
                    const PlinthAvatar(initials: 'YR', color: 'blue'),
                    const SizedBox(width: 12),
                    const PlinthAvatar(
                        initials: 'AB', color: 'green', size: PlinthSize.lg),
                    const SizedBox(width: 12),
                    PlinthAvatar(color: 'gray', size: PlinthSize.sm),
                    const SizedBox(width: 12),
                    const PlinthAvatar(
                      initials: 'SQ',
                      color: 'red',
                      radius: PlinthSize.sm,
                    ),
                  ],
                ),
                _gap(),
                _sectionTitle('Tooltip'),
                _gap(12),
                PlinthTooltip(
                  message: 'Delete this item',
                  child: PlinthButton(
                    variant: PlinthVariant.outline,
                    color: 'red',
                    onPressed: () {},
                    child: const Icon(Icons.delete_outline, size: 18),
                  ),
                ),
                _gap(),
                _sectionTitle('Popover'),
                _gap(12),
                PlinthPopover(
                  controller: _popover,
                  target: PlinthButton(
                    variant: PlinthVariant.outline,
                    onPressed: () {},
                    child: const Text('Show info'),
                  ),
                  width: 240,
                  content: const PlinthText(
                    'This is a popover — anchored to its target, tracks scroll '
                    'position, dismisses on outside tap.',
                    size: PlinthSize.sm,
                  ),
                ),
                _gap(),
                _sectionTitle('Menu'),
                _gap(12),
                PlinthMenu(
                  controller: _menu,
                  target: PlinthButton(
                    variant: PlinthVariant.outline,
                    onPressed: () {},
                    child: const Icon(Icons.more_vert, size: 18),
                  ),
                  items: [
                    PlinthMenuItem(
                      label: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onTap: () {},
                    ),
                    PlinthMenuItem(
                      label: 'Duplicate',
                      icon: const Icon(Icons.copy_outlined),
                      onTap: () {},
                    ),
                    const PlinthMenuItem.divider(),
                    PlinthMenuItem(
                      label: 'Delete',
                      color: 'red',
                      icon: const Icon(Icons.delete_outline),
                      onTap: () {},
                    ),
                  ],
                ),
                _gap(),
                _sectionTitle('Tabs'),
                _gap(12),
                PlinthTabs<String>(
                  value: _activeTab,
                  onChanged: (v) => setState(() => _activeTab = v),
                  tabs: const [
                    PlinthTabItem('account', 'Account'),
                    PlinthTabItem('security', 'Security'),
                    PlinthTabItem('billing', 'Billing'),
                  ],
                ),
                _gap(12),
                PlinthTabView<String>(
                  value: _activeTab,
                  children: const {
                    'account': PlinthText('Account settings go here.'),
                    'security': PlinthText('Security settings go here.'),
                    'billing': PlinthText('Billing settings go here.'),
                  },
                ),
                _gap(),
                _sectionTitle('Switch'),
                _gap(12),
                PlinthSwitch(
                  label: 'Enable notifications',
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                _gap(),
                _sectionTitle('Badges'),
                _gap(12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    PlinthBadge('New', color: 'green'),
                    PlinthBadge('Beta',
                        variant: PlinthVariant.outline, color: 'blue'),
                    PlinthBadge('Deprecated',
                        variant: PlinthVariant.filled, color: 'red'),
                    PlinthBadge('Draft',
                        variant: PlinthVariant.subtle, color: 'gray'),
                  ],
                ),
                _gap(),
                _sectionTitle('Checkbox'),
                _gap(12),
                PlinthCheckbox(
                  label: 'I agree to the terms',
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v),
                ),
                _gap(),
                _sectionTitle('Radio Group'),
                _gap(12),
                PlinthRadioGroup<String>(
                  label: 'Plan',
                  value: _plan,
                  onChanged: (v) => setState(() => _plan = v),
                  options: const [
                    PlinthRadioOption('free', 'Free'),
                    PlinthRadioOption('pro', 'Pro'),
                    PlinthRadioOption('team', 'Team'),
                  ],
                ),
                _gap(),
                _sectionTitle('Select'),
                _gap(12),
                PlinthSelect<String>(
                  label: 'Country',
                  placeholder: 'Choose a country',
                  value: _country,
                  onChanged: (v) => setState(() => _country = v),
                  options: const [
                    PlinthSelectOption('us', 'United States'),
                    PlinthSelectOption('il', 'Israel'),
                    PlinthSelectOption('de', 'Germany'),
                  ],
                ),
                _gap(),
                _sectionTitle('Text Input'),
                _gap(12),
                PlinthTextInput(
                  label: 'Email',
                  description: "We'll never share it.",
                  placeholder: 'you@example.com',
                  error: _email.isNotEmpty && !_email.contains('@')
                      ? 'Enter a valid email'
                      : null,
                  onChanged: (value) => setState(() => _email = value),
                ),
                _gap(),
                _sectionTitle('Drawer'),
                _gap(12),
                PlinthButton(
                  variant: PlinthVariant.outline,
                  onPressed: _drawer.open,
                  child: const Text('Open navigation drawer'),
                ),
                _gap(),
                _sectionTitle('Modal'),
                _gap(12),
                PlinthButton(
                  color: 'red',
                  variant: PlinthVariant.outline,
                  onPressed: _modal.open,
                  child: const Text('Open delete confirmation'),
                ),
                _gap(),
                _sectionTitle('Box + Text + Disclosure'),
                _gap(12),
                PlinthBox(
                  p: PlinthSize.md,
                  radius: PlinthSize.md,
                  border: Colors.grey.shade300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PlinthText(
                        'Spacing, radius, and color all come from PlinthTheme.',
                      ),
                      const SizedBox(height: 8),
                      PlinthText(
                        _panel.isOpen ? 'Panel is open' : 'Panel is closed',
                        color: _panel.isOpen ? 'green' : 'gray',
                        weight: FontWeight.w600,
                      ),
                      const SizedBox(height: 8),
                      PlinthButton(
                        size: PlinthSize.sm,
                        variant: PlinthVariant.light,
                        onPressed: _panel.toggle,
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                ),
                _gap(),
                _sectionTitle('Button Variants'),
                _gap(12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final variant in PlinthVariant.values)
                      PlinthButton(
                        variant: variant,
                        onPressed: () {},
                        child: Text(variant.name),
                      ),
                  ],
                ),
                _gap(),
                _sectionTitle('Button Sizes'),
                _gap(12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final size in PlinthSize.values)
                      PlinthButton(
                        size: size,
                        onPressed: () {},
                        child: Text(size.name),
                      ),
                  ],
                ),
                _gap(),
                _sectionTitle('Button Colors'),
                _gap(12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final colorName in ['blue', 'red', 'green', 'gray'])
                      PlinthButton(
                        color: colorName,
                        onPressed: () {},
                        child: Text(colorName),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
