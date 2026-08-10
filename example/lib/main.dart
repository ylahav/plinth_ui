import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import 'src/demo_code.dart';

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
  double _sliderValue = 40;
  int _currentStep = 0;
  String _view = 'list';
  num _quantity = 3;
  final Set<String> _selectedTags = {'flutter'};
  double _rating = 3;
  int _page = 1;
  bool _isSaving = false;
  String _selectedColor = 'blue';

  // Keyed per section title so the sidebar nav can scroll to each one
  // via Scrollable.ensureVisible — populated lazily inside
  // _sectionTitle() rather than declared upfront, so adding a new
  // section anywhere in the page automatically gets nav support.
  final Map<String, GlobalKey> _sectionKeys = {};

  /// Section names whose "Show code" panel is currently expanded.
  final Set<String> _codeVisible = {};

  // Mirrors the order sections actually appear in the page below —
  // used to build the sidebar list. Keep this in sync when adding a
  // new _sectionTitle(...) call.
  static const List<String> _sectionOrder = [
    'Avatars',
    'Tooltip',
    'Popover',
    'Menu',
    'Tabs',
    'Switch',
    'Progress',
    'Ring Progress',
    'Slider',
    'Accordion',
    'Table',
    'Notification',
    'Stepper',
    'Skeleton',
    'Badges',
    'Checkbox',
    'Radio Group',
    'Select',
    'Text Input',
    'Drawer',
    'Modal',
    'Breadcrumbs',
    'Divider',
    'Card',
    'Segmented Control',
    'Number Input',
    'Chip',
    'Rating',
    'Action Icon',
    'Textarea',
    'Password Input',
    'Pagination',
    'Timeline',
    'Kbd',
    'Code',
    'Mark',
    'Theme Icon',
    'Indicator',
    'Affix',
    'Spoiler',
    'Loading Overlay',
    'Anchor',
    'Blockquote',
    'Copy Button',
    'Nav Link',
    'Color Swatch',
    'Box + Text + Disclosure',
    'Button Variants',
    'Button Sizes',
    'Button Colors',
  ];

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

  Widget _sectionTitle(String text) {
    final key = _sectionKeys.putIfAbsent(text, () => GlobalKey());
    final code = demoCode[text];
    final expanded = _codeVisible.contains(text);
    final isFirst = text == _sectionOrder.first;

    return Container(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFirst) ...[
            const Divider(height: 1, color: Color(0xFFE9ECEF)),
            const SizedBox(height: 32),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF228BE6),
                  ),
                ),
              ),
              if (code != null)
                TextButton.icon(
                  onPressed: () => setState(() {
                    expanded
                        ? _codeVisible.remove(text)
                        : _codeVisible.add(text);
                  }),
                  icon: Icon(expanded ? Icons.code_off : Icons.code, size: 16),
                  label: Text(expanded ? 'Hide code' : 'Show code'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          if (code != null)
            AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? _codePanel(code)
                  : const SizedBox(width: double.infinity),
            ),
        ],
      ),
    );
  }

  static const _codeBaseStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12.5,
    color: Color(0xFFC1C2C5),
    height: 1.5,
  );

  static final _codeKeywordStyle = _codeBaseStyle.copyWith(
    color: const Color(0xFF74C0FC),
    fontWeight: FontWeight.w700,
  );

  static final _plinthIdentifier = RegExp(r'Plinth\w*');

  /// Splits [code] into a span tree so every `Plinth*` identifier
  /// (PlinthButton, PlinthCard, etc.) renders bold in the theme's
  /// light-blue accent, while everything else stays the normal
  /// muted code color.
  TextSpan _highlightPlinthCode(String code) {
    final spans = <TextSpan>[];
    var lastEnd = 0;
    for (final match in _plinthIdentifier.allMatches(code)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
            text: code.substring(lastEnd, match.start), style: _codeBaseStyle));
      }
      spans.add(TextSpan(text: match.group(0), style: _codeKeywordStyle));
      lastEnd = match.end;
    }
    if (lastEnd < code.length) {
      spans.add(TextSpan(text: code.substring(lastEnd), style: _codeBaseStyle));
    }
    return TextSpan(children: spans);
  }

  Widget _codePanel(String code) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 44, 12),
            child: SelectableText.rich(
              _highlightPlinthCode(code),
              style: _codeBaseStyle,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PlinthCopyButton(value: code, color: 'gray'),
          ),
        ],
      ),
    );
  }

  Widget _gap([double height = 40]) => SizedBox(height: height);

  void _scrollToSection(String name) {
    final key = _sectionKeys[name];
    final ctx = key?.currentContext;
    if (ctx == null) {
      // Fails silently by design elsewhere, but during development
      // this is the one thing that would explain "nothing happens on
      // click" with no visible error — surfacing it loudly here.
      debugPrint('Plinth showcase: no section registered for "$name"');
      return;
    }
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      alignment: 0.05,
    );
  }

  /// A literal pedestal silhouette — three stacked bars of decreasing
  /// width, evoking the "plinth" the library is named after. Used as
  /// the wordmark's icon in the hero and sidebar header rather than a
  /// generic geometric shape, so the one piece of branding this app
  /// has is actually tied to the product's own name.
  Widget _plinthMark({double scale = 1}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 22 * scale,
            height: 5 * scale,
            color: const Color(0xFF228BE6)),
        const SizedBox(height: 2),
        Container(
            width: 30 * scale,
            height: 5 * scale,
            color: const Color(0xFF228BE6)),
        const SizedBox(height: 2),
        Container(
            width: 38 * scale,
            height: 5 * scale,
            color: const Color(0xFF228BE6)),
      ],
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _plinthMark(scale: 1.4),
              const SizedBox(width: 16),
              const Text(
                'Plinth UI',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'A themeable Flutter component library — every widget below\n'
            'reads its color, spacing, and radius from one PlinthTheme.',
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              PlinthBadge('${_sectionOrder.length} sections', color: 'blue'),
              const SizedBox(width: 8),
              const PlinthBadge('Web + Desktop',
                  color: 'green', variant: PlinthVariant.outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({required bool inDrawer}) {
    final content = ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (inDrawer)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                _plinthMark(scale: 0.7),
                const SizedBox(width: 10),
                const Text('Plinth UI',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
          ),
        for (final name in _sectionOrder)
          ListTile(
            dense: true,
            title: Text(name, style: const TextStyle(fontSize: 13.5)),
            onTap: () {
              if (inDrawer) {
                Navigator.of(context).pop();
                // Let the drawer's own closing animation finish
                // before scrolling the page underneath it — jumping
                // both at once looks like the scroll didn't register.
                Future.delayed(const Duration(milliseconds: 250), () {
                  if (mounted) _scrollToSection(name);
                });
              } else {
                // No drawer to close on the persistent wide-screen
                // sidebar — scroll immediately.
                _scrollToSection(name);
              }
            },
          ),
      ],
    );

    if (inDrawer) return Drawer(child: SafeArea(child: content));

    return SizedBox(
      width: 220,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Color(0xFFE9ECEF))),
        ),
        child: content,
      ),
    );
  }

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

    // Computed once, shared by both `drawer:` (below) and the body's
    // sidebar-vs-drawer branch — previously `drawer:` was set
    // unconditionally while only `body:` checked width, so on wide
    // screens the persistent sidebar AND a redundant hamburger menu
    // (opening a second copy of the same nav) both showed at once.
    final isWide = MediaQuery.of(context).size.width > 900;

    return PlinthModalHost(
      modal: deleteModal,
      child: PlinthDrawerHost(
        drawer: navDrawer,
        child: Scaffold(
          appBar: AppBar(title: const Text('Plinth UI — Component Showcase')),
          // Only offered as a drawer (hamburger icon) on narrow
          // screens — on wide screens the persistent sidebar below
          // already provides this navigation, so showing both would
          // be redundant. Scaffold hides the hamburger automatically
          // when `drawer` is null.
          drawer: isWide ? null : _buildSidebar(inDrawer: true),
          body: Builder(
            builder: (context) {
              final content = Padding(
                padding: const EdgeInsets.all(24),
                // SingleChildScrollView + Column rather than
                // ListView: ListView is virtualized by Flutter's
                // Sliver system even when given a fixed children
                // list — only widgets near the current viewport are
                // actually mounted, so a section's GlobalKey has no
                // valid context (and Scrollable.ensureVisible nothing
                // to scroll to) until it's already near-visible. A
                // plain Column mounts everything up front, which is
                // exactly what "click a nav item, scroll to it"
                // needs — fine performance-wise at 50 sections.
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHero(),
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
                              initials: 'AB',
                              color: 'green',
                              size: PlinthSize.lg),
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
                      _sectionTitle('Progress'),
                      _gap(12),
                      const PlinthProgress(value: 0.35, color: 'blue'),
                      _gap(8),
                      const PlinthProgress(value: 0.7, color: 'green'),
                      _gap(),
                      _sectionTitle('Ring Progress'),
                      _gap(12),
                      Row(
                        children: const [
                          PlinthRingProgress(value: 0.72, color: 'green'),
                          SizedBox(width: 16),
                          PlinthRingProgress(
                            value: 0.35,
                            color: 'blue',
                            size: 60,
                            thickness: 6,
                            label: Text('35%',
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Slider'),
                      _gap(12),
                      PlinthSlider(
                        value: _sliderValue,
                        onChanged: (v) => setState(() => _sliderValue = v),
                        label: _sliderValue.round().toString(),
                      ),
                      _gap(),
                      _sectionTitle('Accordion'),
                      _gap(12),
                      const PlinthAccordion(
                        items: [
                          PlinthAccordionItem(
                            value: 'shipping',
                            title: 'Shipping details',
                            content: Text('Ships within 3-5 business days.'),
                          ),
                          PlinthAccordionItem(
                            value: 'returns',
                            title: 'Return policy',
                            content:
                                Text('30-day returns, no questions asked.'),
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Table'),
                      _gap(12),
                      const PlinthTable(
                        striped: true,
                        columns: ['Name', 'Role', 'Status'],
                        rows: [
                          ['Alice', 'Engineer', 'Active'],
                          ['Bob', 'Designer', 'Invited'],
                          ['Carol', 'PM', 'Active'],
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Notification'),
                      _gap(12),
                      PlinthButton(
                        variant: PlinthVariant.outline,
                        color: 'green',
                        onPressed: () => PlinthNotification.show(
                          context,
                          title: 'Saved',
                          color: 'green',
                          icon: const Icon(Icons.check_circle_outline),
                          child: const Text('Your changes have been saved.'),
                        ),
                        child: const Text('Show notification'),
                      ),
                      _gap(),
                      _sectionTitle('Stepper'),
                      _gap(12),
                      PlinthStepper(
                        currentStep: _currentStep,
                        onStepTapped: (i) => setState(() => _currentStep = i),
                        steps: const [
                          PlinthStep(label: 'Account'),
                          PlinthStep(label: 'Shipping'),
                          PlinthStep(label: 'Confirm'),
                        ],
                      ),
                      _gap(12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PlinthButton(
                            variant: PlinthVariant.subtle,
                            color: 'gray',
                            onPressed: _currentStep == 0
                                ? null
                                : () => setState(() => _currentStep -= 1),
                            child: const Text('Back'),
                          ),
                          const SizedBox(width: 8),
                          PlinthButton(
                            onPressed: _currentStep == 2
                                ? null
                                : () => setState(() => _currentStep += 1),
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Skeleton'),
                      _gap(12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PlinthSkeleton(
                              width: 40, height: 40, circle: true),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                PlinthSkeleton(height: 14),
                                SizedBox(height: 8),
                                PlinthSkeleton(height: 14, width: 160),
                              ],
                            ),
                          ),
                        ],
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
                      _sectionTitle('Breadcrumbs'),
                      _gap(12),
                      PlinthBreadcrumbs(
                        items: [
                          PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
                          PlinthBreadcrumbItem(label: 'Settings', onTap: () {}),
                          const PlinthBreadcrumbItem(label: 'Profile'),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Divider'),
                      _gap(12),
                      const PlinthDivider(),
                      _gap(12),
                      const PlinthDivider(label: 'OR'),
                      _gap(),
                      _sectionTitle('Card'),
                      _gap(12),
                      PlinthCard(
                        withBorder: true,
                        header: const Text(
                          'Card title',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        footer: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PlinthButton(
                              size: PlinthSize.sm,
                              onPressed: () {},
                              child: const Text('Action'),
                            ),
                          ],
                        ),
                        child: const Text('Card body content goes here.'),
                      ),
                      _gap(),
                      _sectionTitle('Segmented Control'),
                      _gap(12),
                      PlinthSegmentedControl<String>(
                        value: _view,
                        onChanged: (v) => setState(() => _view = v),
                        items: const [
                          PlinthSegmentedControlItem('list', 'List'),
                          PlinthSegmentedControlItem('grid', 'Grid'),
                          PlinthSegmentedControlItem('table', 'Table'),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Number Input'),
                      _gap(12),
                      PlinthNumberInput(
                        label: 'Quantity',
                        value: _quantity,
                        min: 0,
                        max: 10,
                        onChanged: (v) => setState(() => _quantity = v),
                      ),
                      _gap(),
                      _sectionTitle('Chip'),
                      _gap(12),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final tag in ['flutter', 'dart', 'ui', 'design'])
                            PlinthChip(
                              label: tag,
                              selected: _selectedTags.contains(tag),
                              onSelected: (selected) => setState(() {
                                selected
                                    ? _selectedTags.add(tag)
                                    : _selectedTags.remove(tag);
                              }),
                            ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Rating'),
                      _gap(12),
                      PlinthRating(
                        value: _rating,
                        onChanged: (v) => setState(() => _rating = v),
                      ),
                      _gap(),
                      _sectionTitle('Action Icon'),
                      _gap(12),
                      Row(
                        children: [
                          PlinthActionIcon(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          PlinthActionIcon(
                            icon: const Icon(Icons.delete_outline),
                            color: 'red',
                            variant: PlinthVariant.outline,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          PlinthActionIcon(
                            icon: const Icon(Icons.share_outlined),
                            variant: PlinthVariant.filled,
                            circle: true,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Textarea'),
                      _gap(12),
                      PlinthTextarea(
                        label: 'Bio',
                        placeholder: 'Tell us about yourself',
                        onChanged: (v) {},
                      ),
                      _gap(),
                      _sectionTitle('Password Input'),
                      _gap(12),
                      PlinthPasswordInput(
                        label: 'Password',
                        placeholder: 'Enter your password',
                        onChanged: (v) {},
                      ),
                      _gap(),
                      _sectionTitle('Pagination'),
                      _gap(12),
                      PlinthPagination(
                        page: _page,
                        total: 20,
                        onChanged: (p) => setState(() => _page = p),
                      ),
                      _gap(),
                      _sectionTitle('Timeline'),
                      _gap(12),
                      const PlinthTimeline(
                        items: [
                          PlinthTimelineItem(
                            title: 'Order placed',
                            description: 'Jan 3, 10:24 AM',
                            active: true,
                          ),
                          PlinthTimelineItem(
                            title: 'Shipped',
                            description: 'Jan 4, 2:10 PM',
                          ),
                          PlinthTimelineItem(
                            title: 'Delivered',
                            description: 'Pending',
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Kbd'),
                      _gap(12),
                      const Row(
                        children: [
                          PlinthKbd('Ctrl'),
                          SizedBox(width: 4),
                          Text(' + '),
                          SizedBox(width: 4),
                          PlinthKbd('K'),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Code'),
                      _gap(12),
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Run '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: PlinthCode('flutter pub get'),
                            ),
                            TextSpan(text: ' before building.'),
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Mark'),
                      _gap(12),
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'The '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: PlinthMark('quick brown fox'),
                            ),
                            TextSpan(text: ' jumps over the lazy dog.'),
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Theme Icon'),
                      _gap(12),
                      Row(
                        children: [
                          PlinthThemeIcon(
                              icon: const Icon(Icons.check), color: 'green'),
                          const SizedBox(width: 8),
                          PlinthThemeIcon(
                            icon: const Icon(Icons.info_outline),
                            variant: PlinthVariant.light,
                          ),
                          const SizedBox(width: 8),
                          PlinthThemeIcon(
                            icon: const Icon(Icons.star),
                            color: 'red',
                            circle: true,
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Indicator'),
                      _gap(12),
                      Row(
                        children: [
                          const PlinthIndicator(
                            label: '3',
                            child: Icon(Icons.notifications_outlined, size: 28),
                          ),
                          const SizedBox(width: 24),
                          const PlinthIndicator(
                            color: 'green',
                            child: PlinthAvatar(initials: 'AB'),
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Affix'),
                      _gap(12),
                      const PlinthText(
                        'Needs a Stack ancestor — shown here in a bounded demo box '
                        'rather than affixed to the whole page.',
                        size: PlinthSize.sm,
                        color: 'gray',
                      ),
                      _gap(8),
                      SizedBox(
                        width: double.infinity,
                        height: 140,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            PlinthAffix(
                              bottom: 12,
                              right: 12,
                              child: PlinthActionIcon(
                                icon: const Icon(Icons.arrow_upward),
                                variant: PlinthVariant.filled,
                                circle: true,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Spoiler'),
                      _gap(12),
                      const PlinthSpoiler(
                        maxHeight: 60,
                        child: Text(
                          'This is a long block of text that gets clipped to a fixed '
                          'height until the user taps "Show more" to reveal the rest '
                          'of the content, and "Show less" to collapse it again. '
                          'Useful for long descriptions, comments, or bios where you '
                          "don't want to overwhelm the page by default.",
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Loading Overlay'),
                      _gap(12),
                      PlinthButton(
                        variant: PlinthVariant.outline,
                        onPressed: () async {
                          setState(() => _isSaving = true);
                          await Future.delayed(const Duration(seconds: 2));
                          if (mounted) setState(() => _isSaving = false);
                        },
                        child: const Text('Simulate save (2s)'),
                      ),
                      _gap(12),
                      PlinthLoadingOverlay(
                        visible: _isSaving,
                        child: PlinthBox(
                          p: PlinthSize.md,
                          radius: PlinthSize.md,
                          border: Colors.grey.shade300,
                          child: const Text(
                              'Form content that gets dimmed while saving.'),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Anchor'),
                      _gap(12),
                      PlinthAnchor('Forgot password?', onTap: () {}),
                      _gap(),
                      _sectionTitle('Blockquote'),
                      _gap(12),
                      const PlinthBlockquote(
                        quote:
                            'The best way to predict the future is to invent it.',
                        citation: 'Alan Kay',
                      ),
                      _gap(),
                      _sectionTitle('Copy Button'),
                      _gap(12),
                      Row(
                        children: [
                          const Text('sk_live_51H8x...'),
                          const SizedBox(width: 4),
                          const PlinthCopyButton(
                              value: 'sk_live_51H8xExampleKey'),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Nav Link'),
                      _gap(12),
                      Column(
                        children: [
                          PlinthNavLink(
                            label: 'Dashboard',
                            icon: const Icon(Icons.dashboard_outlined),
                            active: true,
                            onTap: () {},
                          ),
                          PlinthNavLink(
                            label: 'Settings',
                            icon: const Icon(Icons.settings_outlined),
                            onTap: () {},
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Color Swatch'),
                      _gap(12),
                      Row(
                        children: [
                          for (final c in ['blue', 'red', 'green', 'gray']) ...[
                            PlinthColorSwatch(
                              color: c,
                              selected: _selectedColor == c,
                              onTap: () => setState(() => _selectedColor = c),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
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
                              _panel.isOpen
                                  ? 'Panel is open'
                                  : 'Panel is closed',
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
                          for (final colorName in [
                            'blue',
                            'red',
                            'green',
                            'gray'
                          ])
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
              );

              if (!isWide) return content;
              return Row(
                children: [
                  _buildSidebar(inDrawer: false),
                  Expanded(child: content),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
