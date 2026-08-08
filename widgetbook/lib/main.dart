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
                    const PlinthButton(
                        onPressed: null, child: Text('Disabled')),
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
                          PlinthAvatar(
                              initials: 'YR', color: 'blue', size: size),
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
                          PlinthText('${size.name} — the quick brown fox',
                              size: size),
                      ],
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
