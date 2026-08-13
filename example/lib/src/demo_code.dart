/// Source snippets shown by each section's "Show code" toggle,
/// transcribed from the matching demo widgets in `main.dart` and
/// keyed by the same section title passed to `_sectionTitle`.
///
/// These are hand-maintained string literals, not extracted at build
/// time — nothing enforces that they match, so **edit the snippet
/// here whenever you change the demo it mirrors**. A stale snippet
/// still compiles and still renders a working code panel, which is
/// exactly why the drift is easy to miss.
const Map<String, String> demoCode = {
  'Avatars': r'''
const Row(
  children: [
    PlinthAvatar(initials: 'YR', color: 'blue'),
    SizedBox(width: 12),
    PlinthAvatar(initials: 'AB', color: 'green', size: PlinthSize.lg),
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
''',
  'Tooltip': r'''
PlinthTooltip(
  message: 'Delete this item',
  child: PlinthButton(
    variant: PlinthVariant.outline,
    color: 'red',
    onPressed: () {},
    child: const Icon(Icons.delete_outline, size: 18),
  ),
),
''',
  'Popover': r'''
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
''',
  'Menu': r'''
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
''',
  'Tabs': r'''
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
''',
  'Switch': r'''
PlinthSwitch(
  label: 'Enable notifications',
  value: _notifications,
  onChanged: (v) => setState(() => _notifications = v),
),
''',
  'Progress': r'''
const PlinthProgress(value: 0.35, color: 'blue'),
_gap(8),
const PlinthProgress(value: 0.7, color: 'green'),
''',
  'Ring Progress': r'''
const Row(
  children: [
    PlinthRingProgress(value: 0.72, color: 'green'),
    SizedBox(width: 16),
    PlinthRingProgress(
      value: 0.35,
      color: 'blue',
      size: 60,
      thickness: 6,
      label: Text('35%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    ),
  ],
),
''',
  'Slider': r'''
PlinthSlider(
  value: _sliderValue,
  onChanged: (v) => setState(() => _sliderValue = v),
  label: _sliderValue.round().toString(),
),
''',
  'Accordion': r'''
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
      content: Text('30-day returns, no questions asked.'),
    ),
  ],
),
''',
  'Table': r'''
const PlinthTable.text(
  striped: true,
  columns: ['Name', 'Role', 'Status'],
  rows: [
    ['Alice', 'Engineer', 'Active'],
    ['Bob', 'Designer', 'Invited'],
    ['Carol', 'PM', 'Active'],
  ],
),
''',
  'Notification': r'''
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
''',
  'Stepper': r'''
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
''',
  'Skeleton': r'''
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
''',
  'Badges': r'''
const Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    PlinthBadge('New', color: 'green'),
    PlinthBadge('Beta', variant: PlinthVariant.outline, color: 'blue'),
    PlinthBadge('Deprecated', variant: PlinthVariant.filled, color: 'red'),
    PlinthBadge('Draft', variant: PlinthVariant.subtle, color: 'gray'),
  ],
),
''',
  'Checkbox': r'''
PlinthCheckbox(
  label: 'I agree to the terms',
  value: _agreed,
  onChanged: (v) => setState(() => _agreed = v),
),
''',
  'Radio Group': r'''
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
''',
  'Select': r'''
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
''',
  'Text Input': r'''
PlinthTextInput(
  label: 'Email',
  description: "We'll never share it.",
  placeholder: 'you@example.com',
  error: _email.isNotEmpty && !_email.contains('@')
      ? 'Enter a valid email'
      : null,
  onChanged: (value) => setState(() => _email = value),
),
''',
  'Drawer': r'''
PlinthButton(
  variant: PlinthVariant.outline,
  onPressed: _drawer.open,
  child: const Text('Open navigation drawer'),
),
''',
  'Modal': r'''
PlinthButton(
  color: 'red',
  variant: PlinthVariant.outline,
  onPressed: _modal.open,
  child: const Text('Open delete confirmation'),
),
''',
  'Breadcrumbs': r'''
PlinthBreadcrumbs(
  items: [
    PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
    PlinthBreadcrumbItem(label: 'Settings', onTap: () {}),
    const PlinthBreadcrumbItem(label: 'Profile'),
  ],
),
''',
  'Divider': r'''
const PlinthDivider(),
_gap(12),
const PlinthDivider(label: 'OR'),
''',
  'Card': r'''
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
''',
  'Segmented Control': r'''
PlinthSegmentedControl<String>(
  value: _view,
  onChanged: (v) => setState(() => _view = v),
  items: const [
    PlinthSegmentedControlItem('list', 'List'),
    PlinthSegmentedControlItem('grid', 'Grid'),
    PlinthSegmentedControlItem('table', 'Table'),
  ],
),
''',
  'Number Input': r'''
PlinthNumberInput(
  label: 'Quantity',
  value: _quantity,
  min: 0,
  max: 10,
  onChanged: (v) => setState(() => _quantity = v),
),
''',
  'Chip': r'''
Wrap(
  spacing: 8,
  children: [
    for (final tag in ['flutter', 'dart', 'ui', 'design'])
      PlinthChip(
        label: tag,
        selected: _selectedTags.contains(tag),
        onSelected: (selected) => setState(() {
          selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
        }),
      ),
  ],
),
''',
  'Rating': r'''
PlinthRating(
  value: _rating,
  onChanged: (v) => setState(() => _rating = v),
),
''',
  'Action Icon': r'''
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
''',
  'Textarea': r'''
PlinthTextarea(
  label: 'Bio',
  placeholder: 'Tell us about yourself',
  onChanged: (v) {},
),
''',
  'Password Input': r'''
PlinthPasswordInput(
  label: 'Password',
  placeholder: 'Enter your password',
  onChanged: (v) {},
),
''',
  'Pagination': r'''
PlinthPagination(
  page: _page,
  total: 20,
  onChanged: (p) => setState(() => _page = p),
),
''',
  'Timeline': r'''
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
''',
  'Kbd': r'''
const Row(
  children: [
    PlinthKbd('Ctrl'),
    SizedBox(width: 4),
    Text(' + '),
    SizedBox(width: 4),
    PlinthKbd('K'),
  ],
),
''',
  'Code': r'''
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
''',
  'Mark': r'''
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
''',
  'Theme Icon': r'''
const Row(
  children: [
    PlinthThemeIcon(icon: Icon(Icons.check), color: 'green'),
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
''',
  'Indicator': r'''
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
''',
  'Affix': r'''
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
''',
  'Spoiler': r'''
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
''',
  'Loading Overlay': r'''
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
    child: const Text('Form content that gets dimmed while saving.'),
  ),
),
''',
  'Anchor': r'''
PlinthAnchor('Forgot password?', onTap: () {}),
''',
  'Blockquote': r'''
const PlinthBlockquote(
  quote: 'The best way to predict the future is to invent it.',
  citation: 'Alan Kay',
),
''',
  'Copy Button': r'''
const Row(
  children: [
    Text('sk_live_51H8x...'),
    SizedBox(width: 4),
    PlinthCopyButton(value: 'sk_live_51H8xExampleKey'),
  ],
),
''',
  'Nav Link': r'''
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
''',
  'Color Swatch': r'''
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
''',
  'Burger': r'''
PlinthBurger(
  opened: _burgerOpen,
  onPressed: () => setState(() => _burgerOpen = !_burgerOpen),
),
''',
  'Hover Card': r'''
PlinthHoverCard(
  target: PlinthAnchor('Hover for details', onTap: () {}),
  content: const PlinthText(
    'Extra context shown on hover — desktop/web only, '
    'touch devices have no hover concept.',
    size: PlinthSize.sm,
  ),
),
''',
  'Range Slider': r'''
PlinthRangeSlider(
  values: _priceRange,
  onChanged: (v) => setState(() => _priceRange = v),
),
''',
  'Multi Select': r'''
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
''',
  'Pin Input': r'''
PlinthPinInput(
  length: 4,
  value: _pin,
  onChanged: (v) => setState(() => _pin = v),
  onCompleted: (v) => debugPrint('PIN complete: $v'),
),
''',
  'Button Group': r'''
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
''',
  'Overlay': r'''
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ],
  ),
),
''',
  'Visually Hidden': r'''
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    PlinthActionIcon(
      icon: const Stack(
        children: [
          Icon(Icons.close),
          PlinthVisuallyHidden(child: Text('Close dialog')),
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
''',
  'Center': r'''
Container(
  width: double.infinity,
  height: 80,
  decoration: BoxDecoration(
    border: Border.all(color: const Color(0xFFCED4DA)),
    borderRadius: BorderRadius.circular(8),
  ),
  child: const PlinthCenter(
    child: PlinthText('Centered content', size: PlinthSize.sm),
  ),
),
''',
  'Aspect Ratio': r'''
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
        child: Text('16:9', style: TextStyle(color: Colors.white)),
      ),
    ),
  ),
),
''',
  'Group': r'''
const PlinthGroup(
  gap: PlinthSize.sm,
  children: [
    PlinthBadge('New'),
    PlinthBadge('Updated'),
    PlinthBadge('Popular', color: 'grape'),
  ],
),
''',
  'List': r'''
const PlinthList(
  type: PlinthListType.ordered,
  items: [
    PlinthListItem(PlinthText('Install the package')),
    PlinthListItem(PlinthText('Wrap your app in a PlinthTheme')),
    PlinthListItem(PlinthText('Start using components')),
  ],
),
''',
  'Container': r'''
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
''',
  'Space': r'''
const Row(
  children: [
    PlinthText('Left', size: PlinthSize.sm),
    PlinthSpace(w: PlinthSize.xl),
    PlinthText('Right (spaced apart)', size: PlinthSize.sm),
  ],
),
''',
  'Unstyled Button': r'''
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
        PlinthText('Fully custom tap target', size: PlinthSize.sm),
      ],
    ),
  ),
),
''',
  'Simple Grid': r'''
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
''',
  'Flex': r'''
const PlinthFlex(
  direction: Axis.horizontal,
  gap: PlinthSize.sm,
  children: [
    PlinthBadge('Dart'),
    PlinthBadge('Flutter'),
    PlinthBadge('Widgets'),
  ],
),
''',
  'Scroll Area': r'''
SizedBox(
  height: 120,
  child: PlinthScrollArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 1; i <= 12; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: PlinthText('Scrollable item $i', size: PlinthSize.sm),
          ),
      ],
    ),
  ),
),
''',
  'Portal': r'''
const PlinthText(
  'PlinthPortal renders its child into the ambient Overlay rather than '
  'in place — every overlay component (Modal, Drawer, Popover, Menu) in '
  'this section is already built on it. There is no standalone visual '
  'to show here beyond those.',
  size: PlinthSize.sm,
  color: 'gray',
),
''',
  'Image': r'''
const SizedBox(
  width: 240,
  height: 160,
  child: PlinthImage(
    src: 'https://picsum.photos/id/1015/480/320',
    radius: PlinthSize.sm,
  ),
),
''',
  'Box + Text + Disclosure': r'''
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
''',
  'Button Variants': r'''
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
''',
  'Button Sizes': r'''
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
''',
  'Button Colors': r'''
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
''',
  'Title': r'''
const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    PlinthTitle('Heading level 1'),
    PlinthTitle('Heading level 3', order: 3),
    PlinthTitle('Heading level 5', order: 5),
  ],
)
''',
  'Paper': r'''
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
)
''',
  'Stack': r'''
const PlinthStack(
  gap: PlinthSize.sm,
  children: [
    PlinthPaper(p: PlinthSize.sm, child: Text('One')),
    PlinthPaper(p: PlinthSize.sm, child: Text('Two')),
    PlinthPaper(p: PlinthSize.sm, child: Text('Three')),
  ],
)
''',
  'Grid': r'''
const PlinthGrid(
  gutter: PlinthSize.sm,
  children: [
    PlinthGridCol(
      span: 6,
      child: PlinthPaper(p: PlinthSize.sm, child: Text('span 6')),
    ),
    PlinthGridCol(
      span: 3,
      child: PlinthPaper(p: PlinthSize.sm, child: Text('span 3')),
    ),
    PlinthGridCol(
      span: 3,
      child: PlinthPaper(p: PlinthSize.sm, child: Text('span 3')),
    ),
  ],
)
''',
  'Fieldset': r'''
const PlinthFieldset(
  legend: 'Shipping address',
  child: PlinthStack(
    gap: PlinthSize.sm,
    children: [
      PlinthTextInput(label: 'Street'),
      PlinthTextInput(label: 'City'),
    ],
  ),
)
''',
  'Collapse': r'''
PlinthStack(
  gap: PlinthSize.sm,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    PlinthButton(
      size: PlinthSize.sm,
      variant: PlinthVariant.outline,
      onPressed: () => setState(() => _collapsed = !_collapsed),
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
)
''',
  'Splitter': r'''
const SizedBox(
  height: 120,
  child: PlinthSplitter(
    first: PlinthPaper(p: PlinthSize.sm, child: Text('Drag the divider')),
    second: PlinthPaper(p: PlinthSize.sm, child: Text('→')),
  ),
)
''',
  'App Shell': r'''
// Bounded height on purpose: the shell fills whatever it is given.
const SizedBox(
  height: 200,
  child: PlinthAppShell(
    header: PlinthPaper(p: PlinthSize.sm, child: PlinthText('Header')),
    navbar: PlinthPaper(p: PlinthSize.sm, child: PlinthText('Navbar')),
    child: PlinthPaper(p: PlinthSize.sm, child: PlinthText('Content')),
  ),
)
''',
  'Marquee': r'''
const PlinthMarquee(
  speed: 30,
  child: PlinthGroup(
    wrap: false,
    children: [
      PlinthBadge('Flutter'),
      PlinthBadge('Dart'),
      PlinthBadge('Plinth'),
    ],
  ),
)
''',
  'Highlight': r'''
const PlinthHighlight(
  'Search terms are highlighted in place.',
  highlight: ['highlighted'],
)
''',
  'Data List': r'''
const PlinthDataList(
  items: [
    PlinthDataListItem.text('Order', '#4021'),
    PlinthDataListItem.text('Placed', '12 Aug 2026'),
    PlinthDataListItem(
      label: 'Status',
      value: PlinthBadge('Shipped', color: 'green'),
    ),
  ],
)
''',
  'Overflow List': r'''
const PlinthOverflowList(
  children: [
    PlinthBadge('Design'),
    PlinthBadge('Research'),
    PlinthBadge('Copy'),
    PlinthBadge('QA'),
    PlinthBadge('Ops'),
  ],
)
''',
  'Empty State': r'''
PlinthEmptyState(
  icon: const Icon(Icons.inbox_outlined),
  title: 'No messages',
  description: 'Anything sent to your team lands here.',
  action: PlinthButton(
    onPressed: () {},
    child: const Text('Compose'),
  ),
)
''',
  'Color Input': r'''
PlinthColorInput(
  label: 'Brand colour',
  value: _brand,
  onChanged: (c) => setState(() => _brand = c),
  swatches: const [
    Color(0xFF2F9E44),
    Color(0xFF1971C2),
    Color(0xFFE03131),
    Color(0xFF7048E8),
  ],
)
''',
  'Color Picker': r'''
PlinthColorPicker(
  value: _brand,
  onChanged: (c) => setState(() => _brand = c),
)
''',
  'Hue Slider': r'''
PlinthHueSlider(
  value: _hue,
  onChanged: (h) => setState(() => _hue = h),
)
''',
  'Alpha Slider': r'''
PlinthAlphaSlider(
  color: const Color(0xFF1971C2),
  value: _alpha,
  onChanged: (a) => setState(() => _alpha = a),
)
''',
  'Angle Slider': r'''
PlinthAngleSlider(
  value: _angle,
  onChanged: (a) => setState(() => _angle = a),
)
''',
  'Mask Input': r'''
PlinthMaskInput(
  mask: '(###) ###-####',
  label: 'Phone',
  onChanged: (_) {},
)
''',
  'JSON Input': r'''
const PlinthJsonInput(
  label: 'Payload',
  description: 'Validated when focus leaves',
  minLines: 3,
  maxLines: 6,
)
''',
  'File Input': r'''
PlinthFileInput<String>(
  label: 'Attachments',
  multiple: true,
  value: _attachments,
  // A real app opens file_picker here.
  onPick: () async => ['file-${_attachments.length + 1}.pdf'],
  onChanged: (f) => setState(() => _attachments = f),
  labelBuilder: (f) => f,
)
''',
  'File Button': r'''
PlinthFileButton<String>(
  variant: PlinthVariant.outline,
  onPick: () async => ['avatar.png'],
  onChanged: (_) {},
  leadingIcon: const Icon(Icons.upload, size: 16),
  child: const Text('Upload'),
)
''',
  'Tags Input': r'''
PlinthTagsInput(
  label: 'Tags',
  value: _tags,
  onChanged: (t) => setState(() => _tags = t),
)
''',
  'Autocomplete': r'''
PlinthAutocomplete(
  label: 'Fruit',
  value: _fruit,
  onChanged: (v) => setState(() => _fruit = v),
  options: const ['Apple', 'Apricot', 'Banana', 'Blackberry', 'Cherry'],
)
''',
  'Pill': r'''
PlinthGroup(
  children: [
    const PlinthPill('read only'),
    PlinthPill('removable', onRemove: () {}),
    PlinthPill('coloured', color: 'grape', onRemove: () {}),
  ],
)
''',
  'Pills Input': r'''
PlinthPillsInput(
  label: 'Recipients',
  placeholder: 'Nobody yet',
  children: [
    for (final p in _pills)
      PlinthPill(p, onRemove: () => setState(() => _pills.remove(p))),
  ],
)
''',
  'Combobox': r'''
PlinthCombobox<String>(
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
    // Arrow keys skip a disabled option rather than landing on it.
    PlinthComboboxOption('react', 'React', disabled: true),
    PlinthComboboxOption('svelte', 'Svelte'),
  ],
  onSelected: (v) => setState(() => _framework = v),
)
''',
  'Tree': r'''
PlinthTree(
  nodes: _demoTree,
  expanded: _treeOpen,
  onExpandedChanged: (e) => setState(() => _treeOpen = e),
  selected: _treeSelected,
  onSelected: (v) => setState(() => _treeSelected = v),
)
''',
  'Tree Select': r'''
PlinthTreeSelect(
  label: 'File',
  nodes: _demoTree,
  value: _treeSelectValue,
  onChanged: (v) => setState(() => _treeSelectValue = v),
)
''',
  'Cascader': r'''
PlinthCascader(
  options: _demoPlaces,
  // The value is the path, not a leaf — a partial selection is a
  // normal state rather than an error.
  value: _place,
  columnWidth: 130,
  height: 150,
  onChanged: (p) => setState(() => _place = p),
)
''',
  'Table of Contents': r'''
PlinthTableOfContents(
  activeIndex: _tocActive,
  onSelected: (i) => setState(() => _tocActive = i),
  items: const [
    PlinthTocItem(label: 'Introduction'),
    PlinthTocItem(label: 'Installing', order: 2),
    PlinthTocItem(label: 'From pub.dev', order: 3),
    PlinthTocItem(label: 'Theming', order: 2),
  ],
)
''',
  'Menubar': r'''
PlinthMenubar(
  menus: [
    PlinthMenubarMenu(
      label: 'File',
      items: [
        PlinthMenuItem(label: 'New', onTap: () {}),
        PlinthMenuItem(label: 'Open…', onTap: () {}),
      ],
    ),
    PlinthMenubarMenu(
      label: 'Edit',
      items: [
        PlinthMenuItem(label: 'Undo', onTap: () {}),
        PlinthMenuItem(label: 'Redo', onTap: () {}),
      ],
    ),
  ],
)
''',
  'Dialog': r'''
// Renders nothing inline — the panel is in the overlay, anchored to
// a screen corner, and nothing behind it is blocked.
PlinthDialog(
  controller: _dialog,
  title: 'Subscribe',
  child: const PlinthText(
    'Not a modal: the rest of the page still works.',
    size: PlinthSize.sm,
  ),
)
''',
  'Floating Window': r'''
Stack(
  children: [
    const Workspace(),
    PlinthFloatingWindow(
      title: 'Inspector',
      onClose: () => setState(() => _showWindow = false),
      child: const PlinthText('Several can be open at once.'),
    ),
  ],
)
''',
  'Scroller': r'''
PlinthScroller(
  // The same controller the scrollable inside uses — it has to be
  // built with it, so the widget can't create one.
  controller: _scroller,
  threshold: 80,
  child: ListView.builder(
    controller: _scroller,
    itemCount: 30,
    itemBuilder: (context, i) => PlinthText('Row $i'),
  ),
)
''',
  'Background Image': r'''
const PlinthBackgroundImage(
  src: 'https://picsum.photos/seed/plinth/600/200',
  height: 140,
  // A scrim goes between the photo and the text by default, because
  // text over a photograph is unreadable against its light parts.
  child: PlinthTitle('Ships tomorrow', order: 3),
)
''',
  'Loader': r'''
const PlinthGroup(
  children: [
    PlinthLoader(),
    PlinthLoader(type: PlinthLoaderType.dots),
    PlinthLoader(type: PlinthLoaderType.bars),
  ],
)
''',
  'Close Button': r'''
PlinthGroup(
  children: [
    PlinthCloseButton(onPressed: () {}),
    PlinthCloseButton(size: PlinthSize.lg, onPressed: () {}),
  ],
)
''',
  'Number Formatter': r'''
const PlinthStack(
  gap: PlinthSize.xs,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    PlinthNumberFormatter(value: 1234567.5, prefix: r'$', decimalScale: 2),
    PlinthNumberFormatter(value: 42, suffix: ' km'),
    // Not localised on purpose — the separators are yours to pass.
    PlinthNumberFormatter(
      value: 1234.56,
      thousandSeparator: '.',
      decimalSeparator: ',',
      decimalScale: 2,
    ),
  ],
)
''',
  'Rolling Number': r'''
PlinthRollingNumber(
  value: _quantity * 1250,
  prefix: r'$',
  size: PlinthSize.xl,
  weight: FontWeight.w700,
)
''',
  'Semi Circle Progress': r'''
PlinthSemiCircleProgress(
  value: _rating / 5,
  label: PlinthText(
    '${(_rating / 5 * 100).round()}%',
    weight: FontWeight.w700,
  ),
)
''',
};
