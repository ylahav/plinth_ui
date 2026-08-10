import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const PlinthWidgetbookApp());

/// Wraps a use-case's content with its own [PlinthTheme] registration
/// and some padding, so each use case is self-contained and doesn't
/// depend on Widgetbook's outer `MaterialApp` carrying the theme
/// extension (avoids needing a Widgetbook theme addon just to get
/// PlinthTheme registered).
Widget _themed(Widget child, {Color background = Colors.white}) {
  return Theme(
    data: ThemeData(
      useMaterial3: true,
      extensions: [PlinthTheme.defaultTheme],
    ),
    child: Material(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
}

/// Isolated gallery for every Plinth UI component.
///
/// This uses Widgetbook's *manual* (non-codegen) API — directories
/// and use cases are registered directly in Dart rather than
/// generated via build_runner/@UseCase annotations. That keeps this
/// app runnable with zero codegen step, at the cost of not having
/// interactive knobs wired up yet (each variant/size/color is its
/// own static use case instead). Knobs can be layered in later via
/// `context.knobs.*` once the installed `widgetbook` version's knob
/// API is confirmed against its changelog.
class PlinthWidgetbookApp extends StatelessWidget {
  const PlinthWidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookCategory(
          name: 'Buttons & Actions',
          children: [
            WidgetbookComponent(
              name: 'PlinthButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Filled (default)',
                  builder: (context) => _themed(
                    PlinthButton(onPressed: () {}, child: const Text('Save')),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: (context) => _themed(
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
                  ),
                ),
                WidgetbookUseCase(
                  name: 'All sizes',
                  builder: (context) => _themed(
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
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Disabled',
                  builder: (context) => _themed(
                    const PlinthButton(onPressed: null, child: Text('Disabled')),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthBadge',
              useCases: [
                WidgetbookUseCase(
                  name: 'All colors, light variant',
                  builder: (context) => _themed(
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in ['blue', 'red', 'green', 'gray'])
                          PlinthBadge(c, color: c),
                      ],
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: (context) => _themed(
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final v in PlinthVariant.values)
                          PlinthBadge(v.name, variant: v, color: 'blue'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthActionIcon',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: (context) => _themed(
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final v in PlinthVariant.values)
                          PlinthActionIcon(
                            icon: const Icon(Icons.star),
                            variant: v,
                            onPressed: () {},
                          ),
                      ],
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Circle',
                  builder: (context) => _themed(
                    PlinthActionIcon(
                      icon: const Icon(Icons.share_outlined),
                      variant: PlinthVariant.filled,
                      circle: true,
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthCopyButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (context) => _themed(
                    const PlinthCopyButton(value: 'sk_live_51H8xExampleKey'),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Forms',
          children: [
            WidgetbookComponent(
              name: 'PlinthTextInput',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _themed(
                    const PlinthTextInput(
                      label: 'Email',
                      placeholder: 'you@example.com',
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'With description',
                  builder: (context) => _themed(
                    const PlinthTextInput(
                      label: 'Email',
                      description: "We'll never share it.",
                      placeholder: 'you@example.com',
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Error state',
                  builder: (context) => _themed(
                    const PlinthTextInput(
                      label: 'Email',
                      placeholder: 'you@example.com',
                      error: 'Enter a valid email',
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Disabled',
                  builder: (context) => _themed(
                    const PlinthTextInput(
                      label: 'Email',
                      placeholder: 'you@example.com',
                      enabled: false,
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthTextarea',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _themed(
                    PlinthTextarea(
                      label: 'Bio',
                      placeholder: 'Tell us about yourself',
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthPasswordInput',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive (toggle visibility)',
                  builder: (context) => _themed(
                    PlinthPasswordInput(
                      label: 'Password',
                      placeholder: 'Enter your password',
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthCheckbox',
              useCases: [
                WidgetbookUseCase(
                  name: 'Unchecked',
                  builder: (context) => _themed(
                    PlinthCheckbox(
                      label: 'I agree to the terms',
                      value: false,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Checked',
                  builder: (context) => _themed(
                    PlinthCheckbox(
                      label: 'I agree to the terms',
                      value: true,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Disabled',
                  builder: (context) => _themed(
                    const PlinthCheckbox(
                      label: 'I agree to the terms',
                      value: false,
                      onChanged: null,
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthRadioGroup',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _themed(
                    PlinthRadioGroup<String>(
                      label: 'Plan',
                      value: 'free',
                      onChanged: (_) {},
                      options: const [
                        PlinthRadioOption('free', 'Free'),
                        PlinthRadioOption('pro', 'Pro'),
                        PlinthRadioOption('team', 'Team'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthSelect',
              useCases: [
                WidgetbookUseCase(
                  name: 'Placeholder (no selection)',
                  builder: (context) => _themed(
                    PlinthSelect<String>(
                      label: 'Country',
                      placeholder: 'Choose a country',
                      value: null,
                      onChanged: (_) {},
                      options: const [
                        PlinthSelectOption('us', 'United States'),
                        PlinthSelectOption('il', 'Israel'),
                      ],
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'With selection',
                  builder: (context) => _themed(
                    PlinthSelect<String>(
                      label: 'Country',
                      value: 'il',
                      onChanged: (_) {},
                      options: const [
                        PlinthSelectOption('us', 'United States'),
                        PlinthSelectOption('il', 'Israel'),
                      ],
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Error state',
                  builder: (context) => _themed(
                    PlinthSelect<String>(
                      label: 'Country',
                      placeholder: 'Choose a country',
                      value: null,
                      error: 'Please select a country',
                      onChanged: (_) {},
                      options: const [
                        PlinthSelectOption('us', 'United States'),
                        PlinthSelectOption('il', 'Israel'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthSwitch',
              useCases: [
                WidgetbookUseCase(
                  name: 'Off',
                  builder: (context) => _themed(
                    PlinthSwitch(
                      label: 'Enable notifications',
                      value: false,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'On',
                  builder: (context) => _themed(
                    PlinthSwitch(
                      label: 'Enable notifications',
                      value: true,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Disabled',
                  builder: (context) => _themed(
                    const PlinthSwitch(
                      label: 'Enable notifications',
                      value: false,
                      onChanged: null,
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthSlider',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (context) => _themed(_SliderDemo()),
                ),
                WidgetbookUseCase(
                  name: 'Disabled',
                  builder: (context) => _themed(
                    const PlinthSlider(value: 30, onChanged: null),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthSegmentedControl',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (context) => _themed(_SegmentedControlDemo()),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthNumberInput',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (context) => _themed(_NumberInputDemo()),
                ),
                WidgetbookUseCase(
                  name: 'With min/max',
                  builder: (context) => _themed(
                    PlinthNumberInput(
                      label: 'Quantity',
                      value: 5,
                      min: 0,
                      max: 10,
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthChip',
              useCases: [
                WidgetbookUseCase(
                  name: 'Selected and unselected',
                  builder: (context) => _themed(
                    Wrap(
                      spacing: 8,
                      children: [
                        PlinthChip(label: 'Selected', selected: true, onSelected: (_) {}),
                        PlinthChip(label: 'Unselected', selected: false, onSelected: (_) {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthRating',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (context) => _themed(_RatingDemo()),
                ),
                WidgetbookUseCase(
                  name: 'Read-only, half star',
                  builder: (context) => _themed(const PlinthRating(value: 3.5)),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Navigation',
          children: [
            WidgetbookComponent(
              name: 'PlinthTabs',
              useCases: [
                WidgetbookUseCase(
                  name: 'With content (interactive)',
                  builder: (context) => _themed(_TabsDemo()),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthAccordion',
              useCases: [
                WidgetbookUseCase(
                  name: 'Single open (default)',
                  builder: (context) => _themed(
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
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Multiple open',
                  builder: (context) => _themed(
                    const PlinthAccordion(
                      multiple: true,
                      initiallyOpen: {'shipping'},
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
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthStepper',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (context) => _themed(_StepperDemo()),
                ),
                WidgetbookUseCase(
                  name: 'All completed',
                  builder: (context) => _themed(
                    const PlinthStepper(
                      currentStep: 3,
                      steps: [
                        PlinthStep(label: 'Account'),
                        PlinthStep(label: 'Shipping'),
                        PlinthStep(label: 'Confirm'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthBreadcrumbs',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _themed(
                    PlinthBreadcrumbs(
                      items: [
                        PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
                        PlinthBreadcrumbItem(label: 'Settings', onTap: () {}),
                        const PlinthBreadcrumbItem(label: 'Profile'),
                      ],
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Custom separator',
                  builder: (context) => _themed(
                    PlinthBreadcrumbs(
                      separator: '>',
                      items: [
                        PlinthBreadcrumbItem(label: 'Home', onTap: () {}),
                        const PlinthBreadcrumbItem(label: 'Profile'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthPagination',
              useCases: [
                WidgetbookUseCase(
                  name: 'Small total (no ellipsis)',
                  builder: (context) => _themed(_PaginationDemo(total: 5)),
                ),
                WidgetbookUseCase(
                  name: 'Large total (ellipsis)',
                  builder: (context) => _themed(_PaginationDemo(total: 20, initialPage: 10)),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthTimeline',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _themed(
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
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthNavLink',
              useCases: [
                WidgetbookUseCase(
                  name: 'Active and inactive',
                  builder: (context) => _themed(
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
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Feedback',
          children: [
            WidgetbookComponent(
              name: 'PlinthAlert',
              useCases: [
                WidgetbookUseCase(
                  name: 'Info',
                  builder: (context) => _themed(
                    PlinthAlert(
                      title: 'Heads up',
                      color: 'blue',
                      icon: const Icon(Icons.info_outline),
                      child: const Text('This is an informational message.'),
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Error',
                  builder: (context) => _themed(
                    PlinthAlert(
                      title: 'Something went wrong',
                      color: 'red',
                      icon: const Icon(Icons.error_outline),
                      child: const Text('Please try again in a few minutes.'),
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Dismissible',
                  builder: (context) => _themed(
                    PlinthAlert(
                      title: 'Dismissible',
                      color: 'green',
                      icon: const Icon(Icons.check_circle_outline),
                      onClose: () {},
                      child: const Text('Tap the close icon to dismiss.'),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthProgress',
              useCases: [
                WidgetbookUseCase(
                  name: 'Various fill levels',
                  builder: (context) => _themed(
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        PlinthProgress(value: 0.25, color: 'blue'),
                        SizedBox(height: 8),
                        PlinthProgress(value: 0.6, color: 'green'),
                        SizedBox(height: 8),
                        PlinthProgress(value: 0.9, color: 'red'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthNotification',
              useCases: [
                WidgetbookUseCase(
                  name: 'Static preview',
                  // Like Modal, the interesting entry point (show())
                  // is imperative and needs a Scaffold context to push
                  // a SnackBar — this shows the inner content layout
                  // only. See the example app for the full trigger flow.
                  builder: (context) => _themed(
                    PlinthNotification(
                      title: 'Saved',
                      color: 'green',
                      icon: const Icon(Icons.check_circle_outline),
                      onClose: () {},
                      child: const Text('Your changes have been saved.'),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthSkeleton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Text lines + avatar',
                  builder: (context) => _themed(
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
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthSpoiler',
              useCases: [
                WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (context) => _themed(
                    const PlinthSpoiler(
                      maxHeight: 60,
                      child: Text(
                        'This is a long block of text that gets clipped to a '
                        'fixed height until the user taps "Show more" to '
                        'reveal the rest of the content, and "Show less" to '
                        'collapse it again.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthLoadingOverlay',
              useCases: [
                WidgetbookUseCase(
                  name: 'Loading',
                  builder: (context) => _themed(
                    PlinthLoadingOverlay(
                      visible: true,
                      child: Container(
                        width: 240,
                        height: 100,
                        alignment: Alignment.center,
                        color: Colors.grey.shade100,
                        child: const Text('Form content'),
                      ),
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Not loading',
                  builder: (context) => _themed(
                    PlinthLoadingOverlay(
                      visible: false,
                      child: Container(
                        width: 240,
                        height: 100,
                        alignment: Alignment.center,
                        color: Colors.grey.shade100,
                        child: const Text('Form content'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Overlays',
          children: [
            WidgetbookComponent(
              name: 'PlinthModal',
              useCases: [
                WidgetbookUseCase(
                  name: 'Static content preview',
                  // Modal is driven imperatively via a controller and
                  // Navigator, which doesn't render meaningfully as a
                  // static use case — this shows its inner content
                  // layout only. See the example app for the full
                  // open/close interaction.
                  builder: (context) => _themed(
                    Container(
                      width: 360,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const PlinthText(
                            'Delete item?',
                            size: PlinthSize.lg,
                            weight: FontWeight.w700,
                          ),
                          const SizedBox(height: 8),
                          const PlinthText(
                            'This action cannot be undone.',
                            color: 'gray',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PlinthButton(
                                variant: PlinthVariant.subtle,
                                color: 'gray',
                                onPressed: () {},
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              PlinthButton(
                                color: 'red',
                                onPressed: () {},
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthTooltip',
              useCases: [
                WidgetbookUseCase(
                  name: 'Hover to reveal',
                  builder: (context) => _themed(
                    PlinthTooltip(
                      message: 'Delete this item',
                      child: PlinthButton(
                        variant: PlinthVariant.outline,
                        color: 'red',
                        onPressed: () {},
                        child: const Icon(Icons.delete_outline, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthPopover',
              useCases: [
                WidgetbookUseCase(
                  name: 'Click to toggle',
                  // Unlike Modal, Popover doesn't use a dialog route —
                  // it renders live via CompositedTransformFollower, so
                  // this use case is fully interactive in the gallery.
                  builder: (context) => _themed(
                    _PopoverDemo(),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthMenu',
              useCases: [
                WidgetbookUseCase(
                  name: 'Click to toggle',
                  // Same interactive-live rationale as Popover — Menu
                  // is built directly on PlinthPopover.
                  builder: (context) => _themed(_MenuDemo()),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Data Display',
          children: [
            WidgetbookComponent(
              name: 'PlinthAvatar',
              useCases: [
                WidgetbookUseCase(
                  name: 'Initials, all sizes',
                  builder: (context) => _themed(
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (final size in PlinthSize.values) ...[
                          PlinthAvatar(initials: 'YR', color: 'blue', size: size),
                          const SizedBox(width: 12),
                        ],
                      ],
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Icon fallback (no initials)',
                  builder: (context) => _themed(
                    const PlinthAvatar(color: 'gray'),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Rounded-square variant',
                  builder: (context) => _themed(
                    const PlinthAvatar(
                      initials: 'SQ',
                      color: 'red',
                      radius: PlinthSize.sm,
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthTable',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _themed(
                    const PlinthTable(
                      columns: ['Name', 'Role', 'Status'],
                      rows: [
                        ['Alice', 'Engineer', 'Active'],
                        ['Bob', 'Designer', 'Invited'],
                      ],
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Striped',
                  builder: (context) => _themed(
                    const PlinthTable(
                      striped: true,
                      columns: ['Name', 'Role', 'Status'],
                      rows: [
                        ['Alice', 'Engineer', 'Active'],
                        ['Bob', 'Designer', 'Invited'],
                        ['Carol', 'PM', 'Active'],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthKbd',
              useCases: [
                WidgetbookUseCase(
                  name: 'Shortcut example',
                  builder: (context) => _themed(
                    const Row(
                      children: [
                        PlinthKbd('Ctrl'),
                        SizedBox(width: 4),
                        Text(' + '),
                        SizedBox(width: 4),
                        PlinthKbd('K'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthThemeIcon',
              useCases: [
                WidgetbookUseCase(
                  name: 'All variants',
                  builder: (context) => _themed(
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final v in PlinthVariant.values)
                          PlinthThemeIcon(icon: const Icon(Icons.check), variant: v),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthIndicator',
              useCases: [
                WidgetbookUseCase(
                  name: 'With label',
                  builder: (context) => _themed(
                    const PlinthIndicator(
                      label: '3',
                      child: Icon(Icons.notifications_outlined, size: 28),
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Plain dot on an avatar',
                  builder: (context) => _themed(
                    const PlinthIndicator(
                      color: 'green',
                      child: PlinthAvatar(initials: 'AB'),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthColorSwatch',
              useCases: [
                WidgetbookUseCase(
                  name: 'Palette selector',
                  builder: (context) => _themed(_ColorSwatchDemo()),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Layout & Typography',
          children: [
            WidgetbookComponent(
              name: 'PlinthBox',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padding + border + radius',
                  builder: (context) => _themed(
                    PlinthBox(
                      p: PlinthSize.md,
                      radius: PlinthSize.md,
                      border: Colors.grey.shade300,
                      child: const Text('Box content'),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthText',
              useCases: [
                WidgetbookUseCase(
                  name: 'All sizes',
                  builder: (context) => _themed(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final size in PlinthSize.values)
                          PlinthText('${size.name} — the quick brown fox', size: size),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthDivider',
              useCases: [
                WidgetbookUseCase(
                  name: 'Plain',
                  builder: (context) => _themed(const PlinthDivider()),
                ),
                WidgetbookUseCase(
                  name: 'With label',
                  builder: (context) => _themed(const PlinthDivider(label: 'OR')),
                ),
                WidgetbookUseCase(
                  name: 'Vertical',
                  builder: (context) => _themed(
                    const SizedBox(
                      height: 60,
                      child: PlinthDivider(vertical: true, height: 60),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthAnchor',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _themed(
                    PlinthAnchor('Forgot password?', onTap: () {}),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthBlockquote',
              useCases: [
                WidgetbookUseCase(
                  name: 'With citation',
                  builder: (context) => _themed(
                    const PlinthBlockquote(
                      quote: 'The best way to predict the future is to invent it.',
                      citation: 'Alan Kay',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Surfaces',
          children: [
            WidgetbookComponent(
              name: 'PlinthPaper',
              useCases: [
                WidgetbookUseCase(
                  name: 'All shadow levels',
                  builder: (context) => _themed(
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final shadow in PlinthShadow.values)
                          PlinthPaper(
                            shadow: shadow,
                            withBorder: shadow == PlinthShadow.none,
                            child: Text(shadow.name),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'PlinthCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Body only',
                  builder: (context) => _themed(
                    const PlinthCard(
                      withBorder: true,
                      child: Text('Card body content.'),
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'With header and footer',
                  builder: (context) => _themed(
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
                      child: const Text('Card body content.'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// A minimal self-contained wrapper so the Popover use case owns its
/// own [PlinthDisclosureController] — Widgetbook use-case builders are
/// stateless functions, but [PlinthPopover] needs a controller that
/// survives rebuilds and gets disposed properly.
class _PopoverDemo extends StatefulWidget {
  @override
  State<_PopoverDemo> createState() => _PopoverDemoState();
}

class _PopoverDemoState extends State<_PopoverDemo> {
  final _controller = PlinthDisclosureController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlinthPopover(
      controller: _controller,
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
    );
  }
}

/// Owns a [PlinthDisclosureController] for the Menu use case, same
/// rationale as [_PopoverDemo] — use-case builders are stateless.
class _MenuDemo extends StatefulWidget {
  @override
  State<_MenuDemo> createState() => _MenuDemoState();
}

class _MenuDemoState extends State<_MenuDemo> {
  final _controller = PlinthDisclosureController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlinthMenu(
      controller: _controller,
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
        const PlinthMenuItem.divider(),
        PlinthMenuItem(
          label: 'Delete',
          color: 'red',
          icon: const Icon(Icons.delete_outline),
          onTap: () {},
        ),
      ],
    );
  }
}

/// Owns the active-tab state for the Tabs use case, since
/// [PlinthTabs] needs a value that changes on tap — a stateless
/// use-case builder can't hold that itself.
class _TabsDemo extends StatefulWidget {
  @override
  State<_TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<_TabsDemo> {
  String _value = 'account';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlinthTabs<String>(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
          tabs: const [
            PlinthTabItem('account', 'Account'),
            PlinthTabItem('security', 'Security'),
          ],
        ),
        const SizedBox(height: 12),
        PlinthTabView<String>(
          value: _value,
          children: const {
            'account': PlinthText('Account settings go here.'),
            'security': PlinthText('Security settings go here.'),
          },
        ),
      ],
    );
  }
}

/// Owns the current value for the Slider use case, since [PlinthSlider]
/// needs a value that changes on drag — a stateless use-case builder
/// can't hold that itself.
class _SliderDemo extends StatefulWidget {
  @override
  State<_SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<_SliderDemo> {
  double _value = 40;

  @override
  Widget build(BuildContext context) {
    return PlinthSlider(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
      label: _value.round().toString(),
    );
  }
}

/// Owns the current step index for the Stepper use case, since
/// [PlinthStepper] needs a value that changes on tap — a stateless
/// use-case builder can't hold that itself.
class _StepperDemo extends StatefulWidget {
  @override
  State<_StepperDemo> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<_StepperDemo> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return PlinthStepper(
      currentStep: _step,
      onStepTapped: (i) => setState(() => _step = i),
      steps: const [
        PlinthStep(label: 'Account'),
        PlinthStep(label: 'Shipping'),
        PlinthStep(label: 'Confirm'),
      ],
    );
  }
}

/// Owns the current value for the SegmentedControl use case, since it
/// needs a value that changes on tap — a stateless use-case builder
/// can't hold that itself.
class _SegmentedControlDemo extends StatefulWidget {
  @override
  State<_SegmentedControlDemo> createState() => _SegmentedControlDemoState();
}

class _SegmentedControlDemoState extends State<_SegmentedControlDemo> {
  String _value = 'list';

  @override
  Widget build(BuildContext context) {
    return PlinthSegmentedControl<String>(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
      items: const [
        PlinthSegmentedControlItem('list', 'List'),
        PlinthSegmentedControlItem('grid', 'Grid'),
      ],
    );
  }
}

/// Owns the current value for the NumberInput use case.
class _NumberInputDemo extends StatefulWidget {
  @override
  State<_NumberInputDemo> createState() => _NumberInputDemoState();
}

class _NumberInputDemoState extends State<_NumberInputDemo> {
  num _value = 3;

  @override
  Widget build(BuildContext context) {
    return PlinthNumberInput(
      label: 'Quantity',
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

/// Owns the current value for the Rating use case.
class _RatingDemo extends StatefulWidget {
  @override
  State<_RatingDemo> createState() => _RatingDemoState();
}

class _RatingDemoState extends State<_RatingDemo> {
  double _value = 3;

  @override
  Widget build(BuildContext context) {
    return PlinthRating(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

/// Owns the current page for the Pagination use case. [total] and
/// [initialPage] are constructor params (not hardcoded) so the two
/// use cases above can share this one demo widget with different
/// starting conditions.
class _PaginationDemo extends StatefulWidget {
  const _PaginationDemo({required this.total, this.initialPage = 1});

  final int total;
  final int initialPage;

  @override
  State<_PaginationDemo> createState() => _PaginationDemoState();
}

class _PaginationDemoState extends State<_PaginationDemo> {
  late int _page = widget.initialPage;

  @override
  Widget build(BuildContext context) {
    return PlinthPagination(
      page: _page,
      total: widget.total,
      onChanged: (p) => setState(() => _page = p),
    );
  }
}

/// Owns the selected color for the ColorSwatch use case.
class _ColorSwatchDemo extends StatefulWidget {
  @override
  State<_ColorSwatchDemo> createState() => _ColorSwatchDemoState();
}

class _ColorSwatchDemoState extends State<_ColorSwatchDemo> {
  String _selected = 'blue';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in ['blue', 'red', 'green', 'gray']) ...[
          PlinthColorSwatch(
            color: c,
            selected: _selected == c,
            onTap: () => setState(() => _selected = c),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}
