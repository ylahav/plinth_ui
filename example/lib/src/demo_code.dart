/// Source snippets shown by each section's "Show code" toggle,
/// extracted from this file's own demo widgets — kept next to the
/// UI they describe rather than hand-duplicated, so they can't
/// silently drift out of sync with what's actually rendered above.
const Map<String, String> demoCode = {
  'Avatars': r'''
Row(
  children: [
    const PlinthAvatar(initials: 'YR', color: 'blue'),
    const SizedBox(width: 12),
    const PlinthAvatar(initials: 'AB', color: 'green', size: PlinthSize.lg),
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
Row(
  children: const [
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
const PlinthTable(
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
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const PlinthSkeleton(width: 40, height: 40, circle: true),
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
''',
  'Badges': r'''
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: const [
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
Row(
  children: [
    PlinthThemeIcon(icon: const Icon(Icons.check), color: 'green'),
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
''',
  'Indicator': r'''
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
Row(
  children: [
    const Text('sk_live_51H8x...'),
    const SizedBox(width: 4),
    const PlinthCopyButton(value: 'sk_live_51H8xExampleKey'),
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
      icon: Stack(
        children: [
          const Icon(Icons.close),
          const PlinthVisuallyHidden(child: Text('Close dialog')),
        ],
      ),
      onPressed: () {},
    ),
    const SizedBox(width: 12),
    Expanded(
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
PlinthGroup(
  gap: PlinthSize.sm,
  children: const [
    PlinthBadge('New'),
    PlinthBadge('Updated'),
    PlinthBadge('Popular', color: 'grape'),
  ],
),
''',
  'List': r'''
PlinthList(
  type: PlinthListType.ordered,
  items: const [
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
Row(
  children: [
    const PlinthText('Left', size: PlinthSize.sm),
    const PlinthSpace(w: PlinthSize.xl),
    const PlinthText('Right (spaced apart)', size: PlinthSize.sm),
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
PlinthFlex(
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
};
