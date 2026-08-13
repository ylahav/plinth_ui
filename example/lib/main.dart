import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import 'src/demo_code.dart';
import 'src/showcase/home_page.dart';

void main() => runApp(const PlinthExampleApp());

/// Lets any page below flip the app between light and dark.
///
/// An `InheritedWidget` rather than passing a callback down: the toggle
/// button sits several levels inside the page tree, and threading a
/// setter through every intermediate widget to reach it is worse than
/// looking it up.
class ThemeSwitcher extends InheritedWidget {
  const ThemeSwitcher({
    super.key,
    required this.mode,
    required this.onChanged,
    required super.child,
  });

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  static ThemeSwitcher of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeSwitcher>()!;

  bool get isDark => mode == ThemeMode.dark;

  void toggle() => onChanged(isDark ? ThemeMode.light : ThemeMode.dark);

  @override
  bool updateShouldNotify(ThemeSwitcher oldWidget) => mode != oldWidget.mode;
}

/// The button itself, so every page can drop one in without repeating
/// the lookup.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final switcher = ThemeSwitcher.of(context);

    return PlinthTooltip(
      message: switcher.isDark ? 'Switch to light' : 'Switch to dark',
      child: PlinthActionIcon(
        icon: Icon(
          switcher.isDark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          size: 18,
        ),
        variant: PlinthVariant.subtle,
        onPressed: switcher.toggle,
      ),
    );
  }
}

class PlinthExampleApp extends StatefulWidget {
  const PlinthExampleApp({super.key});

  @override
  State<PlinthExampleApp> createState() => _PlinthExampleAppState();
}

class _PlinthExampleAppState extends State<PlinthExampleApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher(
      mode: _mode,
      onChanged: (mode) => setState(() => _mode = mode),
      child: MaterialApp(
        title: 'Plinth UI',
        themeMode: _mode,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: PlinthTheme.defaultTheme.surface,
          extensions: [PlinthTheme.defaultTheme],
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PlinthTheme.darkTheme.surface,
          extensions: [PlinthTheme.darkTheme],
        ),
        home: const HomePage(),
      ),
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
  bool _burgerOpen = false;
  RangeValues _priceRange = const RangeValues(20, 80);
  List<String> _skills = ['dart'];
  String _pin = '';
  bool _collapsed = true;
  Color _brand = const Color(0xFF2F9E44);
  double _hue = 210;
  double _alpha = 0.6;
  double _angle = 45;
  List<String> _tags = ['design'];
  List<String> _attachments = [];
  String _fruit = '';
  final List<String> _pills = ['ana@example.com', 'sam@example.com'];
  String? _framework;
  final PlinthDisclosureController _combobox = PlinthDisclosureController();

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
    'Burger',
    'Hover Card',
    'Range Slider',
    'Multi Select',
    'Pin Input',
    'Button Group',
    'Overlay',
    'Visually Hidden',
    'Center',
    'Aspect Ratio',
    'Group',
    'List',
    'Container',
    'Space',
    'Unstyled Button',
    'Simple Grid',
    'Flex',
    'Scroll Area',
    'Portal',
    'Image',
    'Box + Text + Disclosure',
    'Title',
    'Paper',
    'Stack',
    'Grid',
    'Fieldset',
    'Collapse',
    'Splitter',
    'App Shell',
    'Marquee',
    'Highlight',
    'Data List',
    'Overflow List',
    'Empty State',
    'Color Input',
    'Color Picker',
    'Hue Slider',
    'Alpha Slider',
    'Angle Slider',
    'Mask Input',
    'JSON Input',
    'File Input',
    'File Button',
    'Tags Input',
    'Autocomplete',
    'Pill',
    'Pills Input',
    'Combobox',
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
    _combobox.dispose();
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
            Divider(height: 1, color: context.plinth.surfaceSunken),
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
        decoration: BoxDecoration(
          border:
              Border(right: BorderSide(color: context.plinth.surfaceSunken)),
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
          appBar: AppBar(
            title: const Text('Plinth UI — Component Showcase'),
            actions: const [ThemeToggleButton(), SizedBox(width: 8)],
          ),
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
                      const Row(
                        children: [
                          PlinthAvatar(initials: 'YR', color: 'blue'),
                          SizedBox(width: 12),
                          PlinthAvatar(
                              initials: 'AB',
                              color: 'green',
                              size: PlinthSize.lg),
                          SizedBox(width: 12),
                          PlinthAvatar(color: 'gray', size: PlinthSize.sm),
                          SizedBox(width: 12),
                          PlinthAvatar(
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
                      const Row(
                        children: [
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
                      const PlinthTable.text(
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
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PlinthSkeleton(width: 40, height: 40, circle: true),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                      const Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
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
                      const Row(
                        children: [
                          PlinthThemeIcon(
                              icon: Icon(Icons.check), color: 'green'),
                          SizedBox(width: 8),
                          PlinthThemeIcon(
                            icon: Icon(Icons.info_outline),
                            variant: PlinthVariant.light,
                          ),
                          SizedBox(width: 8),
                          PlinthThemeIcon(
                            icon: Icon(Icons.star),
                            color: 'red',
                            circle: true,
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Indicator'),
                      _gap(12),
                      const Row(
                        children: [
                          PlinthIndicator(
                            label: '3',
                            child: Icon(Icons.notifications_outlined, size: 28),
                          ),
                          SizedBox(width: 24),
                          PlinthIndicator(
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
                      const Row(
                        children: [
                          Text('sk_live_51H8x...'),
                          SizedBox(width: 4),
                          PlinthCopyButton(value: 'sk_live_51H8xExampleKey'),
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
                      _sectionTitle('Burger'),
                      _gap(12),
                      PlinthBurger(
                        opened: _burgerOpen,
                        onPressed: () =>
                            setState(() => _burgerOpen = !_burgerOpen),
                      ),
                      _gap(),
                      _sectionTitle('Hover Card'),
                      _gap(12),
                      PlinthHoverCard(
                        target: PlinthAnchor('Hover for details', onTap: () {}),
                        content: const PlinthText(
                          'Extra context shown on hover — desktop/web only, '
                          'touch devices have no hover concept.',
                          size: PlinthSize.sm,
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Range Slider'),
                      _gap(12),
                      PlinthRangeSlider(
                        values: _priceRange,
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                      _gap(),
                      _sectionTitle('Multi Select'),
                      _gap(12),
                      PlinthMultiSelect<String>(
                        label: 'Skills',
                        placeholder: 'Choose skills',
                        value: _skills,
                        onChanged: (v) => setState(() => _skills = v),
                        options: const [
                          PlinthMultiSelectOption('dart', 'Dart'),
                          PlinthMultiSelectOption('flutter', 'Flutter'),
                          PlinthMultiSelectOption('ui', 'UI Design'),
                          PlinthMultiSelectOption('testing', 'Testing'),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Pin Input'),
                      _gap(12),
                      PlinthPinInput(
                        length: 4,
                        value: _pin,
                        onChanged: (v) => setState(() => _pin = v),
                        onCompleted: (v) => debugPrint('PIN complete: $v'),
                      ),
                      _gap(),
                      _sectionTitle('Button Group'),
                      _gap(12),
                      PlinthButtonGroup(
                        children: [
                          PlinthButton(
                            variant: PlinthVariant.outline,
                            onPressed: () {},
                            child: const Text('Day'),
                          ),
                          PlinthButton(
                            variant: PlinthVariant.outline,
                            onPressed: () {},
                            child: const Text('Week'),
                          ),
                          PlinthButton(
                            variant: PlinthVariant.outline,
                            onPressed: () {},
                            child: const Text('Month'),
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Overlay'),
                      _gap(12),
                      SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF228BE6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const PlinthOverlay(
                              opacity: 0.5,
                              child: Center(
                                child: Text(
                                  'Dimmed content',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Visually Hidden'),
                      _gap(12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PlinthActionIcon(
                            icon: const Stack(
                              children: [
                                Icon(Icons.close),
                                PlinthVisuallyHidden(
                                    child: Text('Close dialog')),
                              ],
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: PlinthText(
                              'The icon button to the left has a screen-reader-only '
                              '"Close dialog" label alongside its visible icon.',
                              size: PlinthSize.sm,
                              color: 'gray',
                            ),
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Center'),
                      _gap(12),
                      Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCED4DA)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const PlinthCenter(
                          child: PlinthText('Centered content',
                              size: PlinthSize.sm),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Aspect Ratio'),
                      _gap(12),
                      SizedBox(
                        width: 240,
                        child: PlinthAspectRatio(
                          ratio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF228BE6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('16:9',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Group'),
                      _gap(12),
                      const PlinthGroup(
                        gap: PlinthSize.sm,
                        children: [
                          PlinthBadge('New'),
                          PlinthBadge('Updated'),
                          PlinthBadge('Popular', color: 'grape'),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('List'),
                      _gap(12),
                      const PlinthList(
                        type: PlinthListType.ordered,
                        items: [
                          PlinthListItem(PlinthText('Install the package')),
                          PlinthListItem(
                              PlinthText('Wrap your app in a PlinthTheme')),
                          PlinthListItem(PlinthText('Start using components')),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Container'),
                      _gap(12),
                      PlinthContainer(
                        size: PlinthContainerSize.xs,
                        child: Container(
                          color: const Color(0xFFE7F5FF),
                          padding: const EdgeInsets.all(12),
                          child: const PlinthText(
                            'This content is capped at the "xs" container width and centered.',
                            size: PlinthSize.sm,
                          ),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Space'),
                      _gap(12),
                      const Row(
                        children: [
                          PlinthText('Left', size: PlinthSize.sm),
                          PlinthSpace(w: PlinthSize.xl),
                          PlinthText('Right (spaced apart)',
                              size: PlinthSize.sm),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Unstyled Button'),
                      _gap(12),
                      PlinthUnstyledButton(
                        onPressed: () {},
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_border, size: 18),
                              SizedBox(width: 8),
                              PlinthText('Fully custom tap target',
                                  size: PlinthSize.sm),
                            ],
                          ),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Simple Grid'),
                      _gap(12),
                      PlinthSimpleGrid(
                        columns: 3,
                        spacing: PlinthSize.sm,
                        children: [
                          for (final n in [1, 2, 3, 4, 5, 6])
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F5FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: PlinthText('$n', size: PlinthSize.sm),
                            ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Flex'),
                      _gap(12),
                      const PlinthFlex(
                        direction: Axis.horizontal,
                        gap: PlinthSize.sm,
                        children: [
                          PlinthBadge('Dart'),
                          PlinthBadge('Flutter'),
                          PlinthBadge('Widgets'),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Scroll Area'),
                      _gap(12),
                      SizedBox(
                        height: 120,
                        child: PlinthScrollArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 1; i <= 12; i++)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: PlinthText('Scrollable item $i',
                                      size: PlinthSize.sm),
                                ),
                            ],
                          ),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Portal'),
                      _gap(12),
                      const PlinthText(
                        'PlinthPortal renders its child into the ambient Overlay rather than '
                        'in place — every overlay component (Modal, Drawer, Popover, Menu) in '
                        'this section is already built on it. There is no standalone visual '
                        'to show here beyond those.',
                        size: PlinthSize.sm,
                        color: 'gray',
                      ),
                      _gap(),
                      _sectionTitle('Image'),
                      _gap(12),
                      const SizedBox(
                        width: 240,
                        height: 160,
                        child: PlinthImage(
                          src: 'https://picsum.photos/id/1015/480/320',
                          radius: PlinthSize.sm,
                        ),
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
                      _sectionTitle('Title'),
                      _gap(12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PlinthTitle('Heading level 1'),
                          PlinthTitle('Heading level 3', order: 3),
                          PlinthTitle('Heading level 5', order: 5),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Paper'),
                      _gap(12),
                      const PlinthGroup(
                        children: [
                          PlinthPaper(
                            p: PlinthSize.md,
                            withBorder: true,
                            child: PlinthText('Bordered'),
                          ),
                          PlinthPaper(
                            p: PlinthSize.md,
                            shadow: PlinthShadow.md,
                            child: PlinthText('Raised'),
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Stack'),
                      _gap(12),
                      const SizedBox(
                        width: 220,
                        child: PlinthStack(
                          gap: PlinthSize.sm,
                          children: [
                            PlinthPaper(p: PlinthSize.sm, child: Text('One')),
                            PlinthPaper(p: PlinthSize.sm, child: Text('Two')),
                            PlinthPaper(p: PlinthSize.sm, child: Text('Three')),
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Grid'),
                      _gap(12),
                      const PlinthGrid(
                        gutter: PlinthSize.sm,
                        children: [
                          PlinthGridCol(
                            span: 6,
                            child: PlinthPaper(
                                p: PlinthSize.sm, child: Text('span 6')),
                          ),
                          PlinthGridCol(
                            span: 3,
                            child: PlinthPaper(
                                p: PlinthSize.sm, child: Text('span 3')),
                          ),
                          PlinthGridCol(
                            span: 3,
                            child: PlinthPaper(
                                p: PlinthSize.sm, child: Text('span 3')),
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Fieldset'),
                      _gap(12),
                      const SizedBox(
                        width: 320,
                        child: PlinthFieldset(
                          legend: 'Shipping address',
                          child: PlinthStack(
                            gap: PlinthSize.sm,
                            children: [
                              PlinthTextInput(label: 'Street'),
                              PlinthTextInput(label: 'City'),
                            ],
                          ),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Collapse'),
                      _gap(12),
                      PlinthStack(
                        gap: PlinthSize.sm,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PlinthButton(
                            size: PlinthSize.sm,
                            variant: PlinthVariant.outline,
                            onPressed: () =>
                                setState(() => _collapsed = !_collapsed),
                            child: Text(_collapsed ? 'Show' : 'Hide'),
                          ),
                          PlinthCollapse(
                            opened: !_collapsed,
                            child: const PlinthPaper(
                              p: PlinthSize.sm,
                              withBorder: true,
                              child: Text('Animates its own height.'),
                            ),
                          ),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Splitter'),
                      _gap(12),
                      const SizedBox(
                        height: 120,
                        child: PlinthSplitter(
                          first: PlinthPaper(
                              p: PlinthSize.sm, child: Text('Drag the divider')),
                          second:
                              PlinthPaper(p: PlinthSize.sm, child: Text('→')),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('App Shell'),
                      _gap(12),
                      // Bounded height on purpose: the shell fills
                      // whatever it is given, so a page-length demo
                      // would push everything below it off-screen.
                      const SizedBox(
                        height: 200,
                        child: PlinthAppShell(
                          header: PlinthPaper(
                            p: PlinthSize.sm,
                            child: PlinthText('Header'),
                          ),
                          navbar: PlinthPaper(
                            p: PlinthSize.sm,
                            child: PlinthText('Navbar'),
                          ),
                          child: PlinthPaper(
                            p: PlinthSize.sm,
                            child: PlinthText('Content'),
                          ),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Marquee'),
                      _gap(12),
                      const SizedBox(
                        width: 360,
                        child: PlinthMarquee(
                          speed: 30,
                          child: PlinthGroup(
                            wrap: false,
                            children: [
                              PlinthBadge('Flutter'),
                              PlinthBadge('Dart'),
                              PlinthBadge('Plinth'),
                            ],
                          ),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Highlight'),
                      _gap(12),
                      const PlinthHighlight(
                        'Search terms are highlighted in place.',
                        highlight: ['highlighted'],
                      ),
                      _gap(),
                      _sectionTitle('Data List'),
                      _gap(12),
                      const SizedBox(
                        width: 320,
                        child: PlinthDataList(
                          items: [
                            PlinthDataListItem.text('Order', '#4021'),
                            PlinthDataListItem.text('Placed', '12 Aug 2026'),
                            PlinthDataListItem(
                              label: 'Status',
                              value: PlinthBadge('Shipped', color: 'green'),
                            ),
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Overflow List'),
                      _gap(12),
                      const SizedBox(
                        width: 240,
                        child: PlinthOverflowList(
                          children: [
                            PlinthBadge('Design'),
                            PlinthBadge('Research'),
                            PlinthBadge('Copy'),
                            PlinthBadge('QA'),
                            PlinthBadge('Ops'),
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Empty State'),
                      _gap(12),
                      PlinthEmptyState(
                        icon: const Icon(Icons.inbox_outlined),
                        title: 'No messages',
                        description: 'Anything sent to your team lands here.',
                        action: PlinthButton(
                          onPressed: () {},
                          child: const Text('Compose'),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Color Input'),
                      _gap(12),
                      SizedBox(
                        width: 320,
                        child: PlinthColorInput(
                          label: 'Brand colour',
                          value: _brand,
                          onChanged: (c) => setState(() => _brand = c),
                          swatches: const [
                            Color(0xFF2F9E44),
                            Color(0xFF1971C2),
                            Color(0xFFE03131),
                            Color(0xFF7048E8),
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Color Picker'),
                      _gap(12),
                      SizedBox(
                        width: 260,
                        child: PlinthColorPicker(
                          value: _brand,
                          onChanged: (c) => setState(() => _brand = c),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Hue Slider'),
                      _gap(12),
                      SizedBox(
                        width: 320,
                        child: PlinthHueSlider(
                          value: _hue,
                          onChanged: (h) => setState(() => _hue = h),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Alpha Slider'),
                      _gap(12),
                      SizedBox(
                        width: 320,
                        child: PlinthAlphaSlider(
                          color: const Color(0xFF1971C2),
                          value: _alpha,
                          onChanged: (a) => setState(() => _alpha = a),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Angle Slider'),
                      _gap(12),
                      PlinthGroup(
                        children: [
                          PlinthAngleSlider(
                            value: _angle,
                            onChanged: (a) => setState(() => _angle = a),
                          ),
                          PlinthText('${_angle.round()}°'),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Mask Input'),
                      _gap(12),
                      SizedBox(
                        width: 320,
                        child: PlinthMaskInput(
                          mask: '(###) ###-####',
                          label: 'Phone',
                          onChanged: (_) {},
                        ),
                      ),
                      _gap(),
                      _sectionTitle('JSON Input'),
                      _gap(12),
                      const SizedBox(
                        width: 360,
                        child: PlinthJsonInput(
                          label: 'Payload',
                          description: 'Validated when focus leaves',
                          minLines: 3,
                          maxLines: 6,
                        ),
                      ),
                      _gap(),
                      _sectionTitle('File Input'),
                      _gap(12),
                      SizedBox(
                        width: 360,
                        child: PlinthFileInput<String>(
                          label: 'Attachments',
                          multiple: true,
                          value: _attachments,
                          // A real app opens file_picker here; the demo
                          // stands one in so the section works offline.
                          onPick: () async =>
                              ['file-${_attachments.length + 1}.pdf'],
                          onChanged: (f) => setState(() => _attachments = f),
                          labelBuilder: (f) => f,
                        ),
                      ),
                      _gap(),
                      _sectionTitle('File Button'),
                      _gap(12),
                      PlinthFileButton<String>(
                        variant: PlinthVariant.outline,
                        onPick: () async => ['avatar.png'],
                        onChanged: (_) {},
                        leadingIcon: const Icon(Icons.upload, size: 16),
                        child: const Text('Upload'),
                      ),
                      _gap(),
                      _sectionTitle('Tags Input'),
                      _gap(12),
                      SizedBox(
                        width: 360,
                        child: PlinthTagsInput(
                          label: 'Tags',
                          value: _tags,
                          onChanged: (t) => setState(() => _tags = t),
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Autocomplete'),
                      _gap(12),
                      SizedBox(
                        width: 320,
                        child: PlinthAutocomplete(
                          label: 'Fruit',
                          value: _fruit,
                          onChanged: (v) => setState(() => _fruit = v),
                          options: const [
                            'Apple',
                            'Apricot',
                            'Banana',
                            'Blackberry',
                            'Cherry',
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Pill'),
                      _gap(12),
                      PlinthGroup(
                        children: [
                          const PlinthPill('read only'),
                          PlinthPill('removable', onRemove: () {}),
                          PlinthPill('coloured', color: 'grape', onRemove: () {}),
                        ],
                      ),
                      _gap(),
                      _sectionTitle('Pills Input'),
                      _gap(12),
                      SizedBox(
                        width: 360,
                        child: PlinthPillsInput(
                          label: 'Recipients',
                          placeholder: 'Nobody yet',
                          children: [
                            for (final p in _pills)
                              PlinthPill(
                                p,
                                onRemove: () =>
                                    setState(() => _pills.remove(p)),
                              ),
                          ],
                        ),
                      ),
                      _gap(),
                      _sectionTitle('Combobox'),
                      _gap(12),
                      SizedBox(
                        width: 320,
                        child: PlinthCombobox<String>(
                          controller: _combobox,
                          selected: _framework,
                          empty: const PlinthText('No matches'),
                          target: PlinthButton(
                            variant: PlinthVariant.outline,
                            fullWidth: true,
                            onPressed: _combobox.toggle,
                            child: Text(_framework ?? 'Pick a framework'),
                          ),
                          options: const [
                            PlinthComboboxOption('flutter', 'Flutter'),
                            PlinthComboboxOption('react', 'React',
                                disabled: true),
                            PlinthComboboxOption('svelte', 'Svelte'),
                          ],
                          onSelected: (v) => setState(() => _framework = v),
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
