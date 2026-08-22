import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const PlinthWidgetbookApp());

/// Wraps a use-case's content with its own [PlinthTheme] registration
/// and some padding, so each use case is self-contained and doesn't
/// depend on Widgetbook's outer `MaterialApp` carrying the theme
/// extension (avoids needing a Widgetbook theme addon just to get
/// PlinthTheme registered).
Widget _themed(Widget child, {Color? background}) {
  return Builder(
    builder: (context) {
      // Read the addon's brightness rather than pinning the light
      // theme, so the Theme toolbar switches every use case at once.
      // Falls back to light when no addon is configured.
      final dark = Theme.of(context).brightness == Brightness.dark;
      final plinth = dark ? PlinthTheme.darkTheme : PlinthTheme.defaultTheme;

      return Theme(
        data: ThemeData(
          useMaterial3: true,
          brightness: plinth.brightness,
          extensions: [plinth],
        ),
        child: Material(
          color: background ?? plinth.surface,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: DefaultTextStyle(
              // Without this, unstyled Text inside a use case keeps
              // Material's default near-black and vanishes on a dark
              // surface.
              style: TextStyle(color: plinth.text, fontSize: 14),
              child: Align(alignment: Alignment.topLeft, child: child),
            ),
          ),
        ),
      );
    },
  );
}

/// Owns one piece of mutable state for a use case, so controlled
/// components (checkbox, switch, slider, ...) actually respond to
/// interaction in the gallery rather than being pinned in place by a
/// no-op `onChanged`. Knobs drive the presentational props; this
/// drives the value the user is directly manipulating.
///
/// Deliberately generic rather than one `_FooDemo` widget per
/// component — the older `_SliderDemo`/`_RatingDemo`/... widgets below
/// each exist only to hold a single value, which is this class.
class _Local<T> extends StatefulWidget {
  const _Local({required this.initial, required this.builder});

  final T initial;
  final Widget Function(T value, ValueChanged<T> onChanged) builder;

  @override
  State<_Local<T>> createState() => _LocalState<T>();
}

class _LocalState<T> extends State<_Local<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(_value, (v) => setState(() => _value = v));
}

/// Owns a [PlinthDisclosureController] for a use case — the overlay
/// analogue of [_Local].
///
/// Use-case builders are stateless functions, but Modal/Drawer/Popover/
/// Menu need a controller that survives rebuilds (a knob change
/// rebuilds the builder, and a fresh controller each time would drop
/// the open state) and that gets disposed when the use case goes away.
/// Generalizes the per-component `_PopoverDemo`/`_MenuDemo` widgets
/// further down, which each exist only to do exactly this.
class _Disclosed extends StatefulWidget {
  const _Disclosed({required this.builder});

  final Widget Function(PlinthDisclosureController controller) builder;

  @override
  State<_Disclosed> createState() => _DisclosedState();
}

class _DisclosedState extends State<_Disclosed> {
  final _controller = PlinthDisclosureController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}

/// The palette keys `PlinthTheme.defaultTheme` actually defines.
///
/// Keep this in step with that map: an unrecognized color name falls
/// back to the primary color silently, so offering a name the default
/// theme doesn't define would make the knob look broken rather than
/// informative — you'd pick it and nothing would change.
const _paletteColors = [
  'gray',
  'red',
  'pink',
  'grape',
  'violet',
  'indigo',
  'blue',
  'cyan',
  'teal',
  'green',
  'lime',
  'yellow',
  'orange',
];

/// Shared knob definitions for the props nearly every Plinth component
/// accepts, so the playground use cases offer one consistent
/// vocabulary instead of re-declaring these fifteen times.
/// Owns a [ScrollController] for the Scroller use case — the widget
/// and the scrollable inside it have to share one, so a use-case
/// builder (a stateless function) can't create it inline.
class _Scrolled extends StatefulWidget {
  const _Scrolled({required this.threshold, this.color});

  final double threshold;
  final String? color;

  @override
  State<_Scrolled> createState() => _ScrolledState();
}

class _ScrolledState extends State<_Scrolled> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlinthScroller(
      controller: _controller,
      threshold: widget.threshold,
      color: widget.color,
      child: ListView.builder(
        controller: _controller,
        itemCount: 60,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: PlinthText('Row $i'),
        ),
      ),
    );
  }
}

/// Shared by the Tree and TreeSelect use cases, so the two show the
/// same data arranged for their two different questions.
const List<PlinthTreeNode> _fileTree = [
  PlinthTreeNode(
    value: 'src',
    label: 'src',
    icon: Icon(Icons.folder_outlined),
    children: [
      PlinthTreeNode(
        value: 'widgets',
        label: 'widgets',
        icon: Icon(Icons.folder_outlined),
        children: [
          PlinthTreeNode(
            value: 'button',
            label: 'plinth_button.dart',
            icon: Icon(Icons.description_outlined),
          ),
          PlinthTreeNode(
            value: 'tree',
            label: 'plinth_tree.dart',
            icon: Icon(Icons.description_outlined),
          ),
        ],
      ),
      PlinthTreeNode(
        value: 'main',
        label: 'main.dart',
        icon: Icon(Icons.description_outlined),
      ),
    ],
  ),
  PlinthTreeNode(
    value: 'test',
    label: 'test',
    icon: Icon(Icons.folder_outlined),
    children: [
      PlinthTreeNode(
        value: 'tree_test',
        label: 'plinth_tree_test.dart',
        icon: Icon(Icons.description_outlined),
      ),
    ],
  ),
];

/// Country → region → city, the canonical shape a cascader is for.
const List<PlinthCascaderOption> _places = [
  PlinthCascaderOption(
    value: 'eu',
    label: 'Europe',
    children: [
      PlinthCascaderOption(
        value: 'fr',
        label: 'France',
        children: [
          PlinthCascaderOption(value: 'paris', label: 'Paris'),
          PlinthCascaderOption(value: 'lyon', label: 'Lyon'),
        ],
      ),
      PlinthCascaderOption(
        value: 'de',
        label: 'Germany',
        children: [
          PlinthCascaderOption(value: 'berlin', label: 'Berlin'),
          PlinthCascaderOption(value: 'munich', label: 'Munich'),
        ],
      ),
    ],
  ),
  PlinthCascaderOption(
    value: 'as',
    label: 'Asia',
    children: [
      PlinthCascaderOption(
        value: 'jp',
        label: 'Japan',
        children: [PlinthCascaderOption(value: 'tokyo', label: 'Tokyo')],
      ),
    ],
  ),
  PlinthCascaderOption(value: 'an', label: 'Antarctica'),
];

PlinthSize _sizeKnob(
  BuildContext context, {
  PlinthSize initial = PlinthSize.md,
}) {
  return context.knobs.object.dropdown(
    label: 'size',
    options: PlinthSize.values,
    initialOption: initial,
    labelBuilder: (size) => size.name,
  );
}

String? _colorKnob(BuildContext context) {
  return context.knobs.objectOrNull.dropdown(
    label: 'color',
    options: _paletteColors,
    description: 'null falls back to the theme primary color',
    defaultToNull: true,
  );
}

PlinthVariant _variantKnob(
  BuildContext context, {
  PlinthVariant initial = PlinthVariant.filled,
}) {
  return context.knobs.object.dropdown(
    label: 'variant',
    options: PlinthVariant.values,
    initialOption: initial,
    labelBuilder: (variant) => variant.name,
  );
}

/// A short list of recognizable icons for the slots that take one.
///
/// A knob can only offer values it's given, and an icon has no useful
/// text representation to type — so this trades completeness for a
/// picker that reads as names rather than code points.
const _iconOptions = <({String name, IconData icon})>[
  (name: 'download', icon: Icons.download),
  (name: 'check', icon: Icons.check),
  (name: 'star', icon: Icons.star),
  (name: 'settings', icon: Icons.settings),
  (name: 'delete', icon: Icons.delete_outline),
];

IconData? _iconKnob(BuildContext context, {String label = 'leadingIcon'}) {
  return context.knobs.objectOrNull
      .dropdown(
        label: label,
        options: _iconOptions,
        labelBuilder: (option) => option.name,
        defaultToNull: true,
      )
      ?.icon;
}

/// The colour knob for Alert and Notification, which take a
/// *non-nullable* `color` defaulting to `'blue'` — unlike every other
/// component, whose nullable `color` falls back to the theme's primary.
///
/// That difference is deliberate and worth exercising: a feedback
/// banner rendering in your brand colour regardless of intent (info vs.
/// error vs. success) would be a worse default than a conventional
/// blue. So this knob offers no null option.
String _feedbackColorKnob(BuildContext context) {
  return context.knobs.object.dropdown(
    label: 'color',
    options: _paletteColors,
    initialOption: 'blue',
    description: 'Non-nullable here — no theme-primary fallback',
  );
}

/// Spacing between children, shared by Group, Flex, and SimpleGrid.
/// Separate from [_sizeKnob] so the panel labels it as a gap rather
/// than the component's own size.
PlinthSize _gapKnob(
  BuildContext context, {
  String label = 'gap',
  PlinthSize initial = PlinthSize.md,
}) {
  return context.knobs.object.dropdown(
    label: label,
    options: PlinthSize.values,
    initialOption: initial,
    labelBuilder: (size) => size.name,
  );
}

MainAxisAlignment _mainAxisAlignmentKnob(BuildContext context) {
  return context.knobs.object.dropdown(
    label: 'mainAxisAlignment',
    options: MainAxisAlignment.values,
    initialOption: MainAxisAlignment.start,
    labelBuilder: (alignment) => alignment.name,
  );
}

/// Shared by Paper and Card, which differ in default: Paper is flat
/// (`none`) and Card is raised (`sm`), so each passes its own initial.
PlinthShadow _shadowKnob(
  BuildContext context, {
  PlinthShadow initial = PlinthShadow.none,
}) {
  return context.knobs.object.dropdown(
    label: 'shadow',
    options: PlinthShadow.values,
    initialOption: initial,
    labelBuilder: (shadow) => shadow.name,
  );
}

/// Shared by Popover, HoverCard, and Menu — Menu is built directly on
/// Popover, and HoverCard reuses its position enum, so all three offer
/// the same four anchor points.
PlinthPopoverPosition _popoverPositionKnob(BuildContext context) {
  return context.knobs.object.dropdown(
    label: 'position',
    options: PlinthPopoverPosition.values,
    initialOption: PlinthPopoverPosition.bottom,
    labelBuilder: (position) => position.name,
  );
}

PlinthSize? _radiusKnob(BuildContext context) {
  return context.knobs.objectOrNull.dropdown(
    label: 'radius',
    options: PlinthSize.values,
    labelBuilder: (size) => size.name,
    description: 'null uses the component default',
    defaultToNull: true,
  );
}

/// Isolated gallery for every Plinth UI component.
///
/// This uses Widgetbook's *manual* (non-codegen) API — directories
/// and use cases are registered directly in Dart rather than
/// generated via build_runner/@UseCase annotations. That keeps this
/// app runnable with zero codegen step.
///
/// Two kinds of use case live here, deliberately:
///
/// - **"Playground"** — one instance whose props are driven by
///   `context.knobs.*`, for exploring combinations nobody enumerated
///   in advance. Knob values are encoded into the URL, so a specific
///   configuration is shareable as a link.
/// - **Static variants** ("All variants", "All sizes", "Error state",
///   ...) — fixed compositions, often rendering every option side by
///   side. These are *not* redundant with a playground: comparing
///   `subtle` against `transparent`, or `xs` against `sm`, needs them
///   on screen together, which a single knob-driven instance can't do.
///
/// Every category now has playgrounds, covering 70 of the 75
/// components. The handful without one have nothing to vary —
/// `PlinthPortal`, `PlinthCenter`, `PlinthVisuallyHidden`,
/// `PlinthUnstyledButton` take a child and little else, so a
/// playground there would be ceremony rather than a control surface.
///
/// Follow the same shape when adding more: knobs for presentational
/// props, `_Local` for any value the user should be able to change by
/// interacting with the component itself, `_Disclosed` for anything
/// driven by a `PlinthDisclosureController`, and a knob per prop the
/// component actually accepts rather than a fixed set — several
/// components deliberately default differently (badges to light/`sm`,
/// action icons to `light`, tooltips to `sm`), and a playground should
/// start where its widget does.
///
/// Check the *type* behind a prop name rather than assuming it from
/// the other components: `color` is a theme palette key on most of
/// them but a literal `Color` on `PlinthDivider`, `PlinthBox.bg` is a
/// key while its `border` is a `Color`, and `PlinthRingProgress.size`
/// is a pixel diameter rather than a `PlinthSize`.
class PlinthWidgetbookApp extends StatelessWidget {
  const PlinthWidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: plinthDirectories,
      addons: [
        // Switches every use case at once. `_themed` reads the
        // resulting brightness rather than the ThemeData itself, so a
        // use case gets the matching PlinthTheme registered as an
        // extension without the addon needing to know about Plinth.
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                scaffoldBackgroundColor: PlinthTheme.defaultTheme.surface,
                extensions: [PlinthTheme.defaultTheme],
              ),
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                scaffoldBackgroundColor: PlinthTheme.darkTheme.surface,
                extensions: [PlinthTheme.darkTheme],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Every category, component, and use case in the gallery.
///
/// Deliberately a top-level value rather than a literal inside
/// [PlinthWidgetbookApp.build], so `test/gallery_smoke_test.dart` can
/// walk the tree and build each use case without standing up the whole
/// Widgetbook UI.
final List<WidgetbookNode> plinthDirectories =
    _componentsAlphabetical(_plinthDirectories);

/// Sorts the components inside each category by name, leaving the
/// category order and each component's use cases alone.
///
/// The literal below is in the order the components were built, which
/// is no order a reader can predict: Forms alone holds 32 entries, so
/// finding one meant reading all of them. Sorting here rather than
/// reordering the literal keeps the diff to this function and makes it
/// impossible to drop a component while shuffling several thousand
/// lines.
///
/// Categories stay put. There are eight, all visible at once, and their
/// order is a deliberate progression rather than a list to search.
///
/// Use cases stay put too, and that one matters: their order carries
/// meaning — 'Default' and 'Interactive' first, variants after — and
/// alphabetising would file 'Disabled' ahead of 'Default'.
List<WidgetbookNode> _componentsAlphabetical(List<WidgetbookNode> nodes) {
  return nodes.map((node) {
    if (node is! WidgetbookCategory) return node;
    final children = _componentsAlphabetical(node.children ?? const [])
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return node.copyWith(children: children);
  }).toList();
}

final List<WidgetbookNode> _plinthDirectories = [
  WidgetbookCategory(
    name: 'Buttons & Actions',
    children: [
      WidgetbookComponent(
        name: 'PlinthButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final leadingIcon = _iconKnob(context);
              return _themed(
                PlinthButton(
                  variant: _variantKnob(context),
                  size: _sizeKnob(context),
                  color: _colorKnob(context),
                  radius: _radiusKnob(context),
                  fullWidth: context.knobs.boolean(label: 'fullWidth'),
                  // Worth toggling against `enabled`: loading keeps the
                  // button's own colors, disabled doesn't.
                  loading: context.knobs.boolean(label: 'loading'),
                  leadingIcon: leadingIcon == null ? null : Icon(leadingIcon),
                  // Disabled is expressed by a null callback rather
                  // than a flag, so the knob toggles the callback.
                  onPressed: context.knobs
                          .boolean(label: 'enabled', initialValue: true)
                      ? () {}
                      : null,
                  child: Text(
                    context.knobs.string(label: 'label', initialValue: 'Save'),
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final leadingIcon = _iconKnob(context);
              return _themed(
                PlinthBadge(
                  context.knobs.string(label: 'label', initialValue: 'New'),
                  // Badges default to light/sm rather than the
                  // filled/md every other component uses — matching
                  // that here keeps the playground's starting point
                  // the same as the widget's own default.
                  variant: _variantKnob(context, initial: PlinthVariant.light),
                  size: _sizeKnob(context, initial: PlinthSize.sm),
                  color: _colorKnob(context),
                  leadingIcon:
                      leadingIcon == null ? null : Icon(leadingIcon, size: 12),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final icon = _iconKnob(context, label: 'icon');
              final circle = context.knobs.boolean(label: 'circle');
              return _themed(
                PlinthActionIcon(
                  semanticLabel: 'Settings',
                  icon: Icon(icon ?? Icons.settings),
                  variant: _variantKnob(context, initial: PlinthVariant.light),
                  size: _sizeKnob(context),
                  color: _colorKnob(context),
                  circle: circle,
                  // radius is what rounds the square form, so it has
                  // no effect once circle is on — hide it rather than
                  // offer a control that silently does nothing.
                  radius: circle ? null : _radiusKnob(context),
                  loading: context.knobs.boolean(label: 'loading'),
                  onPressed: context.knobs
                          .boolean(label: 'enabled', initialValue: true)
                      ? () {}
                      : null,
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'All variants',
            builder: (context) => _themed(
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in PlinthVariant.values)
                    PlinthActionIcon(
                      semanticLabel: 'Favourite',
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
                semanticLabel: 'Share',
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
            name: 'Playground',
            builder: (context) => _themed(
              PlinthCopyButton(
                value: context.knobs.string(
                  label: 'value',
                  initialValue: 'sk_live_51H8xExampleKey',
                  description: 'The text written to the clipboard',
                ),
                size: _sizeKnob(context),
                color: _colorKnob(context),
                confirmDuration: Duration(
                  milliseconds: context.knobs.int.slider(
                    label: 'confirmDuration (ms)',
                    initialValue: 2000,
                    min: 250,
                    max: 5000,
                    description: 'How long the checkmark shows before '
                        'reverting to the copy icon',
                  ),
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Interactive',
            builder: (context) => _themed(
              const PlinthCopyButton(value: 'sk_live_51H8xExampleKey'),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthBurger',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              final enabled = context.knobs.boolean(
                label: 'enabled',
                initialValue: true,
              );
              return _themed(
                _Local<bool>(
                  initial: false,
                  builder: (opened, onChanged) => PlinthBurger(
                    opened: opened,
                    onPressed: enabled ? () => onChanged(!opened) : null,
                    size: size,
                    color: color,
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Interactive',
            builder: (context) => _themed(_BurgerDemo()),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthButtonGroup',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final count = context.knobs.int.slider(
                label: 'children',
                initialValue: 3,
                min: 2,
                max: 5,
                description: 'The group only squares off *inner* '
                    'corners, so the count is what makes that visible',
              );
              final variant = _variantKnob(
                context,
                initial: PlinthVariant.defaultVariant,
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                PlinthButtonGroup(
                  children: [
                    for (var i = 0; i < count; i++)
                      PlinthButton(
                        variant: variant,
                        size: size,
                        color: color,
                        onPressed: () {},
                        child: Text('Item ${i + 1}'),
                      ),
                  ],
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => _themed(
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
            name: 'Playground',
            builder: (context) => _themed(
              PlinthTextInput(
                label: context.knobs.string(
                  label: 'label',
                  initialValue: 'Email',
                ),
                placeholder: context.knobs.string(
                  label: 'placeholder',
                  initialValue: 'you@example.com',
                ),
                description: context.knobs.stringOrNull(
                  label: 'description',
                  initialValue: "We'll never share it.",
                  defaultToNull: true,
                ),
                error: context.knobs.stringOrNull(
                  label: 'error',
                  initialValue: 'Enter a valid email',
                  description: 'Takes precedence over the focus border',
                  defaultToNull: true,
                ),
                enabled:
                    context.knobs.boolean(label: 'enabled', initialValue: true),
                obscureText: context.knobs.boolean(label: 'obscureText'),
                size: _sizeKnob(context),
                color: _colorKnob(context),
                radius: _radiusKnob(context),
                onChanged: (_) {},
              ),
            ),
          ),
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
            name: 'Playground',
            builder: (context) {
              final minLines = context.knobs.int.slider(
                label: 'minLines',
                initialValue: 3,
                min: 1,
                max: 10,
              );
              final maxLines = context.knobs.int.slider(
                label: 'maxLines',
                initialValue: 6,
                min: 1,
                max: 20,
              );
              return _themed(
                PlinthTextarea(
                  label: context.knobs.string(
                    label: 'label',
                    initialValue: 'Bio',
                  ),
                  placeholder: context.knobs.string(
                    label: 'placeholder',
                    initialValue: 'Tell us about yourself',
                  ),
                  error: context.knobs.stringOrNull(
                    label: 'error',
                    initialValue: 'Keep it under 200 characters',
                    defaultToNull: true,
                  ),
                  minLines: minLines,
                  // Flutter's own TextField asserts minLines <=
                  // maxLines, so an unclamped pair of knobs would
                  // crash the use case rather than just look odd.
                  maxLines: maxLines < minLines ? minLines : maxLines,
                  enabled: context.knobs
                      .boolean(label: 'enabled', initialValue: true),
                  size: _sizeKnob(context),
                  color: _colorKnob(context),
                  onChanged: (_) {},
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) => _themed(
              PlinthPasswordInput(
                label: context.knobs.string(
                  label: 'label',
                  initialValue: 'Password',
                ),
                placeholder: context.knobs.string(
                  label: 'placeholder',
                  initialValue: 'Enter your password',
                ),
                description: context.knobs.stringOrNull(
                  label: 'description',
                  initialValue: 'At least 12 characters.',
                  defaultToNull: true,
                ),
                error: context.knobs.stringOrNull(
                  label: 'error',
                  initialValue: 'Too short',
                  defaultToNull: true,
                ),
                enabled:
                    context.knobs.boolean(label: 'enabled', initialValue: true),
                size: _sizeKnob(context),
                color: _colorKnob(context),
                radius: _radiusKnob(context),
                onChanged: (_) {},
              ),
            ),
          ),
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
            name: 'Playground',
            builder: (context) {
              final enabled =
                  context.knobs.boolean(label: 'enabled', initialValue: true);
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'I agree to the terms',
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              final radius = _radiusKnob(context);
              return _themed(
                _Local<bool>(
                  initial: false,
                  builder: (value, onChanged) => PlinthCheckbox(
                    label: label,
                    value: value,
                    // A null onChanged is how this library
                    // expresses disabled, so the knob toggles the
                    // callback itself rather than a flag.
                    onChanged: enabled ? onChanged : null,
                    size: size,
                    color: color,
                    radius: radius,
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final enabled =
                  context.knobs.boolean(label: 'enabled', initialValue: true);
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'Plan',
              );
              final description = context.knobs.stringOrNull(
                label: 'description',
                initialValue: 'You can change this later.',
                defaultToNull: true,
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                _Local<String>(
                  initial: 'free',
                  builder: (value, onChanged) => PlinthRadioGroup<String>(
                    label: label,
                    description: description,
                    value: value,
                    onChanged: enabled ? onChanged : null,
                    size: size,
                    color: color,
                    options: const [
                      PlinthRadioOption('free', 'Free'),
                      PlinthRadioOption('pro', 'Pro'),
                      PlinthRadioOption('team', 'Team'),
                    ],
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final enabled =
                  context.knobs.boolean(label: 'enabled', initialValue: true);
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'Country',
              );
              final placeholder = context.knobs.string(
                label: 'placeholder',
                initialValue: 'Choose a country',
              );
              final error = context.knobs.stringOrNull(
                label: 'error',
                initialValue: 'Please select a country',
                defaultToNull: true,
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              final radius = _radiusKnob(context);
              return _themed(
                _Local<String?>(
                  initial: null,
                  builder: (value, onChanged) => PlinthSelect<String>(
                    label: label,
                    placeholder: placeholder,
                    error: error,
                    value: value,
                    enabled: enabled,
                    onChanged: onChanged,
                    size: size,
                    color: color,
                    radius: radius,
                    options: const [
                      PlinthSelectOption('us', 'United States'),
                      PlinthSelectOption('il', 'Israel'),
                      PlinthSelectOption('jp', 'Japan'),
                    ],
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final enabled =
                  context.knobs.boolean(label: 'enabled', initialValue: true);
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'Enable notifications',
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                _Local<bool>(
                  initial: false,
                  builder: (value, onChanged) => PlinthSwitch(
                    label: label,
                    value: value,
                    onChanged: enabled ? onChanged : null,
                    size: size,
                    color: color,
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final enabled =
                  context.knobs.boolean(label: 'enabled', initialValue: true);
              final min =
                  context.knobs.double.input(label: 'min', initialValue: 0);
              final max =
                  context.knobs.double.input(label: 'max', initialValue: 100);
              final divisions = context.knobs.intOrNull.slider(
                label: 'divisions',
                initialValue: 5,
                min: 2,
                max: 20,
                description: 'null is a continuous slider',
                defaultToNull: true,
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                _Local<double>(
                  initial: 30,
                  builder: (value, onChanged) => PlinthSlider(
                    // The knobs can be dragged into min > max, and
                    // a value outside [min, max] asserts inside
                    // Flutter's own Slider — clamp both rather
                    // than let the use case throw.
                    min: min,
                    max: max <= min ? min + 1 : max,
                    value: value.clamp(min, max <= min ? min + 1 : max),
                    divisions: divisions,
                    onChanged: enabled ? onChanged : null,
                    size: size,
                    color: color,
                  ),
                ),
              );
            },
          ),
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
          WidgetbookUseCase(
            name: 'With marks',
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                child: _Local<double>(
                  initial: 50,
                  // Unevenly spaced on purpose, with restrictToMarks:
                  // this is the case `divisions` can't express, since
                  // it splits the range into equal steps.
                  builder: (value, onChanged) => PlinthSlider(
                    value: value,
                    onChanged: onChanged,
                    restrictToMarks: true,
                    marks: const [
                      PlinthSliderMark(value: 0, label: 'Off'),
                      PlinthSliderMark(value: 10, label: 'Low'),
                      PlinthSliderMark(value: 50, label: 'Mid'),
                      PlinthSliderMark(value: 100, label: 'Max'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthRangeSlider',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final enabled =
                  context.knobs.boolean(label: 'enabled', initialValue: true);
              final divisions = context.knobs.intOrNull.slider(
                label: 'divisions',
                initialValue: 10,
                min: 2,
                max: 20,
                description: 'null is a continuous range',
                defaultToNull: true,
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                _Local<RangeValues>(
                  initial: const RangeValues(20, 80),
                  builder: (values, onChanged) => PlinthRangeSlider(
                    values: values,
                    divisions: divisions,
                    onChanged: enabled ? onChanged : null,
                    size: size,
                    color: color,
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Interactive',
            builder: (context) => _themed(_RangeSliderDemo()),
          ),
          WidgetbookUseCase(
            name: 'Disabled',
            builder: (context) => _themed(
              const PlinthRangeSlider(
                  values: RangeValues(20, 80), onChanged: null),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthTagsInput',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'Skills',
              );
              final maxTags = context.knobs.intOrNull.slider(
                label: 'maxTags',
                initialValue: 5,
                min: 1,
                max: 10,
                description: 'null for no limit',
                defaultToNull: true,
              );
              final allowDuplicates =
                  context.knobs.boolean(label: 'allowDuplicates');
              final enabled = context.knobs.boolean(
                label: 'enabled',
                initialValue: true,
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                SizedBox(
                  width: 360,
                  child: _Local<List<String>>(
                    initial: const ['dart', 'flutter'],
                    builder: (tags, onChanged) => PlinthTagsInput(
                      label: label,
                      placeholder: 'Type and press Enter',
                      value: tags,
                      onChanged: onChanged,
                      maxTags: maxTags,
                      allowDuplicates: allowDuplicates,
                      enabled: enabled,
                      size: size,
                      color: color,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthAutocomplete',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final limit = context.knobs.int.slider(
                label: 'limit',
                initialValue: 8,
                min: 1,
                max: 10,
                description: 'How many suggestions show at once',
              );
              final enabled = context.knobs.boolean(
                label: 'enabled',
                initialValue: true,
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                SizedBox(
                  width: 320,
                  child: _Local<String>(
                    initial: '',
                    builder: (value, onChanged) => PlinthAutocomplete(
                      label: 'Company',
                      placeholder: 'Start typing…',
                      description: 'Free text is accepted — the list only '
                          'offers suggestions',
                      value: value,
                      onChanged: onChanged,
                      limit: limit,
                      enabled: enabled,
                      size: size,
                      color: color,
                      options: const [
                        'Acme',
                        'Globex',
                        'Initech',
                        'Umbrella',
                        'Soylent',
                        'Hooli',
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthFileInput',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final multiple = context.knobs.boolean(label: 'multiple');
              final enabled = context.knobs.boolean(
                label: 'enabled',
                initialValue: true,
              );
              final error = context.knobs.stringOrNull(
                label: 'error',
                initialValue: 'Attach at least one file',
                defaultToNull: true,
              );
              final size = _sizeKnob(context);
              return _themed(
                SizedBox(
                  width: 360,
                  child: _Local<List<String>>(
                    initial: const [],
                    builder: (files, onChanged) => PlinthFileInput<String>(
                      label: 'Attachments',
                      placeholder: 'Choose a file',
                      description: 'The picker is supplied by the caller — '
                          'this component takes no file-picking dependency',
                      error: error,
                      value: files,
                      labelBuilder: (f) => f,
                      multiple: multiple,
                      enabled: enabled,
                      size: size,
                      // Stands in for a real picker, which is exactly
                      // the seam this component is built around.
                      onPick: () async => ['document-${files.length + 1}.pdf'],
                      onChanged: onChanged,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthMultiSelect',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'Languages',
              );
              final placeholder = context.knobs.string(
                label: 'placeholder',
                initialValue: 'Pick a few',
              );
              final error = context.knobs.stringOrNull(
                label: 'error',
                initialValue: 'Choose at least one',
                defaultToNull: true,
              );
              final enabled =
                  context.knobs.boolean(label: 'enabled', initialValue: true);
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              final radius = _radiusKnob(context);
              return _themed(
                _Local<List<String>>(
                  initial: const ['dart'],
                  builder: (value, onChanged) => PlinthMultiSelect<String>(
                    label: label,
                    placeholder: placeholder,
                    error: error,
                    enabled: enabled,
                    value: value,
                    onChanged: onChanged,
                    size: size,
                    color: color,
                    radius: radius,
                    options: const [
                      PlinthMultiSelectOption('dart', 'Dart'),
                      PlinthMultiSelectOption('swift', 'Swift'),
                      PlinthMultiSelectOption('kotlin', 'Kotlin'),
                      PlinthMultiSelectOption('rust', 'Rust'),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Interactive',
            builder: (context) => _themed(_MultiSelectDemo()),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthPinInput',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final length = context.knobs.int.slider(
                label: 'length',
                initialValue: 4,
                min: 3,
                max: 8,
              );
              final obscureText = context.knobs.boolean(label: 'obscureText');
              final numbersOnly = context.knobs
                  .boolean(label: 'numbersOnly', initialValue: true);
              final error = context.knobs.boolean(label: 'error');
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                _Local<String>(
                  initial: '',
                  builder: (value, onChanged) => PlinthPinInput(
                    // Shortening the knob mid-entry would leave a
                    // value longer than the field, so trim it to
                    // whatever the current length allows.
                    value: value.length > length
                        ? value.substring(0, length)
                        : value,
                    length: length,
                    obscureText: obscureText,
                    numbersOnly: numbersOnly,
                    error: error,
                    onChanged: onChanged,
                    size: size,
                    color: color,
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Interactive',
            builder: (context) => _themed(_PinInputDemo()),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthSegmentedControl',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final fullWidth = context.knobs.boolean(label: 'fullWidth');
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                _Local<String>(
                  initial: 'list',
                  builder: (value, onChanged) => PlinthSegmentedControl<String>(
                    value: value,
                    onChanged: onChanged,
                    fullWidth: fullWidth,
                    size: size,
                    color: color,
                    items: const [
                      PlinthSegmentedControlItem('list', 'List'),
                      PlinthSegmentedControlItem('grid', 'Grid'),
                      PlinthSegmentedControlItem('board', 'Board'),
                    ],
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'Quantity',
              );
              final min = context.knobs.doubleOrNull.input(
                label: 'min',
                initialValue: 0,
                defaultToNull: true,
              );
              final max = context.knobs.doubleOrNull.input(
                label: 'max',
                initialValue: 10,
                defaultToNull: true,
              );
              final step =
                  context.knobs.double.input(label: 'step', initialValue: 1);
              final enabled =
                  context.knobs.boolean(label: 'enabled', initialValue: true);
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              final radius = _radiusKnob(context);
              return _themed(
                _Local<num>(
                  initial: 5,
                  builder: (value, onChanged) => PlinthNumberInput(
                    label: label,
                    value: value,
                    min: min,
                    max: max,
                    step: step,
                    enabled: enabled,
                    onChanged: onChanged,
                    size: size,
                    color: color,
                    radius: radius,
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'Flutter',
              );
              final enabled =
                  context.knobs.boolean(label: 'enabled', initialValue: true);
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                _Local<bool>(
                  initial: false,
                  builder: (selected, onSelected) => PlinthChip(
                    label: label,
                    selected: selected,
                    onSelected: enabled ? onSelected : null,
                    size: size,
                    color: color,
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Selected and unselected',
            builder: (context) => _themed(
              Wrap(
                spacing: 8,
                children: [
                  PlinthChip(
                      label: 'Selected', selected: true, onSelected: (_) {}),
                  PlinthChip(
                      label: 'Unselected', selected: false, onSelected: (_) {}),
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
            name: 'Playground',
            builder: (context) {
              final count = context.knobs.int.slider(
                label: 'count',
                initialValue: 5,
                min: 3,
                max: 10,
              );
              final readOnly = context.knobs.boolean(
                label: 'read-only',
                description: 'Omitting onChanged is how a rating '
                    'becomes display-only',
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                _Local<double>(
                  initial: 3,
                  builder: (value, onChanged) => PlinthRating(
                    // Lowering count below the current value would
                    // otherwise leave more stars filled than exist.
                    value: value > count ? count.toDouble() : value,
                    count: count,
                    onChanged: readOnly ? null : onChanged,
                    size: size,
                    color: color,
                  ),
                ),
              );
            },
          ),
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
      WidgetbookComponent(
        name: 'PlinthFieldset',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final legend = context.knobs.stringOrNull(
                label: 'legend',
                initialValue: 'Shipping address',
                defaultToNull: true,
              );
              return _themed(
                SizedBox(
                  width: 360,
                  child: PlinthFieldset(
                    legend: legend,
                    variant: _variantKnob(
                      context,
                      initial: PlinthVariant.defaultVariant,
                    ),
                    radius: _radiusKnob(context),
                    padding: _gapKnob(context, label: 'padding'),
                    enabled: context.knobs
                        .boolean(label: 'enabled', initialValue: true),
                    child: const PlinthStack(
                      gap: PlinthSize.sm,
                      children: [
                        PlinthTextInput(label: 'Street'),
                        PlinthTextInput(label: 'City'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Disabled section',
            // The reason the prop exists: one flag switches a whole
            // group off instead of each field carrying its own.
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                child: PlinthFieldset(
                  legend: 'Payment',
                  enabled: false,
                  child: PlinthStack(
                    gap: PlinthSize.sm,
                    children: [
                      const PlinthTextInput(label: 'Card number'),
                      PlinthButton(onPressed: () {}, child: const Text('Pay')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthMaskInput',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 320,
                child: PlinthMaskInput(
                  mask: context.knobs.object.dropdown(
                    label: 'mask',
                    options: const [
                      '(###) ###-####',
                      '##/##/####',
                      'AAA-####',
                      '**-**-**',
                    ],
                    description: '# digit, A letter, * either; anything '
                        'else is a literal the field fills in',
                  ),
                  label: 'Masked',
                  size: _sizeKnob(context),
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthJsonInput',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                child: PlinthJsonInput(
                  label: 'Payload',
                  description: 'Validates on blur — click away to see it. '
                      'Half-typed JSON is invalid by definition',
                  formatOnBlur: context.knobs.boolean(
                    label: 'formatOnBlur',
                    initialValue: true,
                  ),
                  minLines: 4,
                  maxLines: 12,
                  size: _sizeKnob(context),
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthFileButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              _Local<List<String>>(
                initial: const [],
                builder: (files, onChanged) => PlinthGroup(
                  children: [
                    PlinthFileButton<String>(
                      variant: _variantKnob(context),
                      size: _sizeKnob(context),
                      color: _colorKnob(context),
                      // Stands in for your picker — the button
                      // disables itself for as long as it runs.
                      onPick: () async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 800),
                        );
                        return ['photo-${files.length + 1}.png'];
                      },
                      onChanged: (picked) => onChanged([...files, ...picked]),
                      child: const Text('Upload'),
                    ),
                    PlinthText(
                      files.isEmpty ? 'Nothing picked' : files.join(', '),
                      size: PlinthSize.sm,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthPill',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final removable = context.knobs.boolean(
                label: 'removable',
                initialValue: true,
                description: 'A pill with no onRemove is a value shown '
                    'but not takeable out',
              );
              return _themed(
                PlinthPill(
                  context.knobs.string(label: 'label', initialValue: 'design'),
                  size: _sizeKnob(context, initial: PlinthSize.sm),
                  color: _colorKnob(context),
                  onRemove: removable ? () {} : null,
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Against Badge and Chip',
            builder: (context) => _themed(
              PlinthStack(
                gap: PlinthSize.md,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Three chip-shaped things that are not
                  // interchangeable: a label, a toggle, and a value.
                  const PlinthText('Badge — states something, does nothing',
                      size: PlinthSize.xs),
                  const PlinthBadge('Active', color: 'green'),
                  const PlinthText('Chip — a selectable toggle',
                      size: PlinthSize.xs),
                  PlinthChip(
                      label: 'Remote', selected: true, onSelected: (_) {}),
                  const PlinthText('Pill — one value, whose action is to leave',
                      size: PlinthSize.xs),
                  PlinthPill('design', onRemove: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthPillsInput',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final label = context.knobs.stringOrNull(
                label: 'label',
                initialValue: 'Recipients',
                defaultToNull: true,
              );
              final error = context.knobs.stringOrNull(
                label: 'error',
                defaultToNull: true,
              );
              final focused = context.knobs.boolean(
                label: 'focused',
                description: 'Passed in, not tracked — whatever owns the '
                    'input inside owns its focus node',
              );
              final empty = context.knobs.boolean(label: 'empty');

              return _themed(
                SizedBox(
                  width: 340,
                  child: _Local<List<String>>(
                    initial: const ['ana@example.com', 'sam@example.com'],
                    builder: (values, onChanged) => PlinthPillsInput(
                      label: label,
                      error: error,
                      focused: focused,
                      placeholder: 'Add someone',
                      size: _sizeKnob(context),
                      children: empty
                          ? const []
                          : [
                              for (final v in values)
                                PlinthPill(
                                  v,
                                  onRemove: () => onChanged(
                                    [...values]..remove(v),
                                  ),
                                ),
                            ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthCombobox',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final withDisabled = context.knobs.boolean(
                label: 'a disabled option',
                initialValue: true,
                description: 'Arrow keys skip it — a disabled option the '
                    'keyboard lands on is a trap',
              );

              return _themed(
                SizedBox(
                  width: 300,
                  child: _Disclosed(
                    builder: (controller) => _Local<String?>(
                      initial: null,
                      builder: (selected, onSelected) => PlinthCombobox<String>(
                        controller: controller,
                        selected: selected,
                        maxHeight: context.knobs.double
                            .slider(
                              label: 'maxHeight',
                              initialValue: 240,
                              min: 80,
                              max: 400,
                            )
                            .toDouble(),
                        empty: const PlinthText('No matches'),
                        target: PlinthButton(
                          onPressed: controller.toggle,
                          variant: PlinthVariant.outline,
                          fullWidth: true,
                          child: Text(selected ?? 'Pick a framework'),
                        ),
                        options: [
                          const PlinthComboboxOption('flutter', 'Flutter'),
                          PlinthComboboxOption(
                            'react',
                            'React',
                            disabled: withDisabled,
                          ),
                          const PlinthComboboxOption('svelte', 'Svelte'),
                          const PlinthComboboxOption('solid', 'Solid'),
                        ],
                        onSelected: onSelected,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Filtering as you type',
            builder: (context) => _themed(
              SizedBox(
                width: 300,
                child: _Disclosed(
                  builder: (controller) => _Local<String>(
                    initial: '',
                    builder: (query, onQuery) {
                      const all = [
                        'Flutter',
                        'React',
                        'Svelte',
                        'Solid',
                        'Angular',
                      ];
                      final matches = all
                          .where((o) =>
                              o.toLowerCase().contains(query.toLowerCase()))
                          .toList();

                      // The open panel has to follow a list replaced
                      // underneath it — the thing PlinthPopover used
                      // not to do.
                      return PlinthCombobox<String>(
                        controller: controller,
                        empty: const PlinthText('No matches'),
                        target: PlinthTextInput(
                          placeholder: 'Type to filter',
                          onChanged: (v) {
                            onQuery(v);
                            controller.open();
                          },
                        ),
                        options: [
                          for (final m in matches)
                            PlinthComboboxOption(m.toLowerCase(), m),
                        ],
                        onSelected: (_) {},
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthTreeSelect',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final selectableBranches = context.knobs.boolean(
                label: 'selectableBranches',
                initialValue: true,
                description: 'Off means folders only open — useful when '
                    'only leaves are real choices',
              );
              final error = context.knobs.stringOrNull(
                label: 'error',
                defaultToNull: true,
              );

              return _themed(
                SizedBox(
                  width: 300,
                  child: _Local<String?>(
                    initial: null,
                    builder: (value, onChanged) => PlinthTreeSelect(
                      nodes: _fileTree,
                      value: value,
                      onChanged: onChanged,
                      label: 'File',
                      error: error,
                      selectableBranches: selectableBranches,
                      size: _sizeKnob(context),
                    ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Opens onto the current value',
            builder: (context) => _themed(
              SizedBox(
                width: 300,
                child: _Local<String?>(
                  // Starts three levels deep: opening the dropdown has
                  // to reveal it rather than hide it.
                  initial: 'tree',
                  builder: (value, onChanged) => PlinthTreeSelect(
                    nodes: _fileTree,
                    value: value,
                    onChanged: onChanged,
                    label: 'File',
                    description: 'Open it — the branches down to the '
                        'selection are already expanded',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthCascader',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final columnWidth = context.knobs.double
                  .slider(
                    label: 'columnWidth',
                    initialValue: 150,
                    min: 90,
                    max: 260,
                  )
                  .toDouble();
              final height = context.knobs.double
                  .slider(
                      label: 'height', initialValue: 200, min: 100, max: 320)
                  .toDouble();

              return _themed(
                _Local<List<String>>(
                  initial: const ['eu', 'fr'],
                  builder: (value, onChanged) => PlinthStack(
                    gap: PlinthSize.sm,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlinthCascader(
                        options: _places,
                        value: value,
                        onChanged: onChanged,
                        columnWidth: columnWidth,
                        height: height,
                        size: _sizeKnob(context),
                        color: _colorKnob(context),
                      ),
                      // The value is the path, not the leaf — a partial
                      // selection is a normal state, not an error.
                      PlinthText(
                        value.isEmpty ? 'Nothing chosen' : value.join(' › '),
                        size: PlinthSize.sm,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'In a dropdown',
            builder: (context) => _themed(
              _Disclosed(
                builder: (controller) => PlinthPopover(
                  controller: controller,
                  target: PlinthButton(
                    onPressed: controller.toggle,
                    variant: PlinthVariant.outline,
                    child: const Text('Choose a place'),
                  ),
                  // Rendering inline is what makes this composable: the
                  // dropdown form is a popover wrapped around it.
                  content: _Local<List<String>>(
                    initial: const [],
                    builder: (value, onChanged) => PlinthCascader(
                      options: _places,
                      value: value,
                      onChanged: onChanged,
                      columnWidth: 130,
                      height: 160,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthColorInput',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final withAlpha = context.knobs.boolean(
                label: 'withAlpha',
                description: 'Adds an opacity slider and an eight-digit '
                    'hex',
              );
              final label = context.knobs.stringOrNull(
                label: 'label',
                initialValue: 'Brand colour',
                defaultToNull: true,
              );
              final error = context.knobs.stringOrNull(
                label: 'error',
                defaultToNull: true,
              );
              final enabled = context.knobs.boolean(
                label: 'enabled',
                initialValue: true,
              );

              return _themed(
                SizedBox(
                  width: 320,
                  child: _Local<Color>(
                    initial: const Color(0xFF2F9E44),
                    builder: (value, onChanged) => PlinthColorInput(
                      value: value,
                      onChanged: enabled ? onChanged : null,
                      label: label,
                      error: error,
                      withAlpha: withAlpha,
                      enabled: enabled,
                      size: _sizeKnob(context),
                      swatches: const [
                        Color(0xFF2F9E44),
                        Color(0xFF1971C2),
                        Color(0xFFE03131),
                        Color(0xFFF08C00),
                        Color(0xFF7048E8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Typing a hex',
            builder: (context) => _themed(
              SizedBox(
                width: 320,
                child: _Local<Color>(
                  initial: const Color(0xFF1971C2),
                  builder: (value, onChanged) => PlinthColorInput(
                    label: 'Type #abc, abc, or #aabbcc',
                    description: 'A half-typed value reports nothing and '
                        'is left alone under the caret',
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthColorPicker',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final withAlpha = context.knobs.boolean(label: 'withAlpha');
              final withSwatches = context.knobs.boolean(
                label: 'swatches',
                initialValue: true,
              );
              final areaHeight = context.knobs.double
                  .slider(
                    label: 'areaHeight',
                    initialValue: 140,
                    min: 80,
                    max: 240,
                  )
                  .toDouble();

              return _themed(
                SizedBox(
                  width: 260,
                  child: _Local<Color>(
                    initial: const Color(0xFF1971C2),
                    builder: (value, onChanged) => PlinthColorPicker(
                      value: value,
                      onChanged: onChanged,
                      withAlpha: withAlpha,
                      areaHeight: areaHeight,
                      swatches: withSwatches
                          ? const [
                              Color(0xFF2F9E44),
                              Color(0xFF1971C2),
                              Color(0xFFE03131),
                              Color(0xFFF08C00),
                              Color(0xFF7048E8),
                              Color(0xFF0C8599),
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Hue survives black',
            builder: (context) => _themed(
              SizedBox(
                width: 260,
                child: _Local<Color>(
                  initial: const Color(0xFF000000),
                  builder: (value, onChanged) => PlinthStack(
                    gap: PlinthSize.sm,
                    children: [
                      const PlinthText(
                        'Drag brightness to zero, then move the hue and '
                        'drag back up — the hue you chose is still there.',
                        size: PlinthSize.xs,
                      ),
                      PlinthColorPicker(value: value, onChanged: onChanged),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthHueSlider',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final height = context.knobs.double
                  .slider(label: 'height', initialValue: 14, min: 6, max: 40)
                  .toDouble();

              return _themed(
                SizedBox(
                  width: 320,
                  child: _Local<double>(
                    initial: 210,
                    builder: (value, onChanged) => PlinthStack(
                      gap: PlinthSize.sm,
                      children: [
                        PlinthHueSlider(
                          value: value,
                          onChanged: onChanged,
                          height: height,
                        ),
                        PlinthText('${value.round()}°'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthAlphaSlider',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final height = context.knobs.double
                  .slider(label: 'height', initialValue: 14, min: 6, max: 40)
                  .toDouble();

              return _themed(
                SizedBox(
                  width: 320,
                  child: _Local<double>(
                    initial: 0.6,
                    builder: (value, onChanged) => PlinthStack(
                      gap: PlinthSize.sm,
                      children: [
                        PlinthAlphaSlider(
                          color: const Color(0xFF1971C2),
                          value: value,
                          onChanged: onChanged,
                          height: height,
                        ),
                        // The chequer behind the track is what makes
                        // "transparent" readable as something other
                        // than "pale".
                        PlinthText('${(value * 100).round()}% opacity'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthAngleSlider',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final divisions = context.knobs.boolean(label: 'snap to steps')
                  ? context.knobs.int
                      .slider(
                        label: 'divisions',
                        initialValue: 8,
                        min: 2,
                        max: 24,
                      )
                      .toInt()
                  : null;

              return _themed(
                _Local<double>(
                  initial: 45,
                  builder: (value, onChanged) => PlinthGroup(
                    children: [
                      PlinthAngleSlider(
                        value: value,
                        onChanged: onChanged,
                        divisions: divisions,
                        diameter: context.knobs.double
                            .slider(
                              label: 'size',
                              initialValue: 72,
                              min: 40,
                              max: 160,
                            )
                            .toDouble(),
                        color: _colorKnob(context),
                      ),
                      PlinthText('${value.round()}°'),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Driving a gradient',
            builder: (context) => _themed(
              _Local<double>(
                initial: 45,
                builder: (value, onChanged) => PlinthGroup(
                  children: [
                    PlinthAngleSlider(value: value, onChanged: onChanged),
                    Container(
                      width: 120,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment(
                            -math.sin(value * math.pi / 180),
                            math.cos(value * math.pi / 180),
                          ),
                          end: Alignment(
                            math.sin(value * math.pi / 180),
                            -math.cos(value * math.pi / 180),
                          ),
                          colors: const [
                            Color(0xFF1971C2),
                            Color(0xFF2F9E44),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
        name: 'PlinthMenubar',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthStack(
                gap: PlinthSize.sm,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PlinthText(
                    'Open one, then move across the bar — the next opens '
                    'without a second click. That is what makes it a '
                    'menubar rather than a row of menus.',
                    size: PlinthSize.xs,
                  ),
                  PlinthMenubar(
                    size: _sizeKnob(context, initial: PlinthSize.sm),
                    color: _colorKnob(context),
                    menus: [
                      PlinthMenubarMenu(
                        label: 'File',
                        items: [
                          PlinthMenuItem(label: 'New', onTap: () {}),
                          PlinthMenuItem(label: 'Open…', onTap: () {}),
                          PlinthMenuItem(label: 'Save', onTap: () {}),
                        ],
                      ),
                      PlinthMenubarMenu(
                        label: 'Edit',
                        items: [
                          PlinthMenuItem(label: 'Undo', onTap: () {}),
                          PlinthMenuItem(label: 'Redo', onTap: () {}),
                        ],
                      ),
                      PlinthMenubarMenu(
                        label: 'View',
                        items: [
                          PlinthMenuItem(label: 'Zoom in', onTap: () {}),
                          PlinthMenuItem(label: 'Zoom out', onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthTree',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final indent = context.knobs.double
                  .slider(label: 'indent', initialValue: 20, min: 8, max: 48)
                  .toDouble();
              final size = _sizeKnob(context);
              final color = _colorKnob(context);

              // Two pieces of state, both owned by the caller — which
              // is the point of the component being controlled.
              return _themed(
                SizedBox(
                  width: 280,
                  child: _Local<Set<String>>(
                    initial: const {'src'},
                    builder: (expanded, onExpanded) => _Local<String?>(
                      initial: null,
                      builder: (selected, onSelected) => PlinthTree(
                        nodes: _fileTree,
                        expanded: expanded,
                        onExpandedChanged: onExpanded,
                        selected: selected,
                        onSelected: onSelected,
                        indent: indent,
                        size: size,
                        color: color,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Keyboard traversal',
            builder: (context) => _themed(
              SizedBox(
                width: 280,
                child: _Local<Set<String>>(
                  initial: const {},
                  builder: (expanded, onExpanded) => PlinthStack(
                    gap: PlinthSize.sm,
                    children: [
                      const PlinthText(
                        'Tab in, then arrow up/down to move, right to '
                        'open a branch, left to close it or step out.',
                        size: PlinthSize.xs,
                      ),
                      PlinthTree(
                        nodes: _fileTree,
                        expanded: expanded,
                        onExpandedChanged: onExpanded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthTableOfContents',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final withRail = context.knobs.boolean(
                label: 'withRail',
                initialValue: true,
              );
              final indent = context.knobs.double
                  .slider(label: 'indent', initialValue: 14, min: 4, max: 32)
                  .toDouble();

              return _themed(
                SizedBox(
                  width: 240,
                  child: _Local<int>(
                    initial: 1,
                    builder: (active, onSelected) => PlinthTableOfContents(
                      items: const [
                        PlinthTocItem(label: 'Introduction'),
                        PlinthTocItem(label: 'Installing', order: 2),
                        PlinthTocItem(label: 'From pub.dev', order: 3),
                        PlinthTocItem(label: 'From source', order: 3),
                        PlinthTocItem(label: 'Theming', order: 2),
                      ],
                      activeIndex: active,
                      onSelected: onSelected,
                      withRail: withRail,
                      indent: indent,
                      size: _sizeKnob(context, initial: PlinthSize.sm),
                      color: _colorKnob(context),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthTabs',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              final showContent = context.knobs.boolean(
                label: 'with PlinthTabView',
                initialValue: true,
                description: 'Tabs is only the bar — TabView is the '
                    'separate widget that swaps content',
              );
              return _themed(
                _Local<String>(
                  initial: 'account',
                  builder: (value, onChanged) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlinthTabs<String>(
                        value: value,
                        onChanged: onChanged,
                        size: size,
                        color: color,
                        tabs: const [
                          PlinthTabItem('account', 'Account'),
                          PlinthTabItem('security', 'Security'),
                          PlinthTabItem('billing', 'Billing'),
                        ],
                      ),
                      if (showContent) ...[
                        const SizedBox(height: 16),
                        PlinthTabView<String>(
                          value: value,
                          children: const {
                            'account': PlinthText('Account settings'),
                            'security': PlinthText('Security settings'),
                            'billing': PlinthText('Billing settings'),
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final multiple = context.knobs.boolean(
                label: 'multiple',
                description: 'Off means opening one closes the others',
              );
              final withIcons = context.knobs.boolean(label: 'item icons');
              final openFirst = context.knobs.boolean(
                label: 'first item initially open',
                initialValue: true,
              );
              return _themed(
                SizedBox(
                  width: 380,
                  child: PlinthAccordion(
                    // Unlike the overlay components, open state is
                    // internal here — initiallyOpen only seeds it, so
                    // a Key is needed for the knob to take effect on
                    // an already-built accordion.
                    key: ValueKey('$multiple-$openFirst'),
                    multiple: multiple,
                    initiallyOpen: openFirst ? const {'what'} : const {},
                    color: _colorKnob(context),
                    items: [
                      PlinthAccordionItem(
                        value: 'what',
                        title: 'What is Plinth UI?',
                        icon: withIcons ? const Icon(Icons.help_outline) : null,
                        content: const PlinthText(
                          'A Mantine-inspired component library for Flutter.',
                          size: PlinthSize.sm,
                        ),
                      ),
                      PlinthAccordionItem(
                        value: 'theme',
                        title: 'How does theming work?',
                        icon: withIcons
                            ? const Icon(Icons.palette_outlined)
                            : null,
                        content: const PlinthText(
                          'A PlinthTheme ThemeExtension registered at the '
                          'app root.',
                          size: PlinthSize.sm,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final withDescriptions = context.knobs.boolean(
                label: 'step descriptions',
                initialValue: true,
              );
              final tappable = context.knobs.boolean(
                label: 'onStepTapped',
                initialValue: true,
                description: 'Stepper is visual only — tapping calls '
                    'back but never moves currentStep itself',
              );
              final color = _colorKnob(context);
              return _themed(
                SizedBox(
                  width: 420,
                  child: _Local<int>(
                    initial: 1,
                    builder: (currentStep, onChanged) => PlinthStepper(
                      currentStep: currentStep,
                      // The caller owns currentStep, so advancing it
                      // is this use case's job, not the widget's.
                      onStepTapped: tappable ? onChanged : null,
                      color: color,
                      steps: [
                        PlinthStep(
                          label: 'Account',
                          description:
                              withDescriptions ? 'Email and password' : null,
                        ),
                        PlinthStep(
                          label: 'Shipping',
                          description:
                              withDescriptions ? 'Where it goes' : null,
                        ),
                        PlinthStep(
                          label: 'Confirm',
                          description:
                              withDescriptions ? 'Review the order' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final separator = context.knobs.string(
                label: 'separator',
                initialValue: '/',
              );
              final depth = context.knobs.int.slider(
                label: 'crumbs',
                initialValue: 3,
                min: 2,
                max: 5,
              );
              final color = _colorKnob(context);
              const labels = [
                'Home',
                'Settings',
                'Profile',
                'Privacy',
                'Advanced'
              ];
              return _themed(
                PlinthBreadcrumbs(
                  separator: separator,
                  color: color,
                  items: [
                    for (var i = 0; i < depth; i++)
                      PlinthBreadcrumbItem(
                        label: labels[i],
                        // Every crumb gets an onTap, including the
                        // last — the widget renders the final one as
                        // plain text regardless, which is the point
                        // worth seeing here.
                        onTap: () {},
                      ),
                  ],
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final total = context.knobs.int.slider(
                label: 'total',
                initialValue: 20,
                min: 1,
                max: 100,
              );
              final siblingCount = context.knobs.int.slider(
                label: 'siblingCount',
                initialValue: 1,
                min: 0,
                max: 4,
                description: 'Pages shown either side of the current '
                    'one before collapsing into an ellipsis',
              );
              final size = _sizeKnob(context);
              final color = _colorKnob(context);
              return _themed(
                _Local<int>(
                  initial: 1,
                  builder: (page, onChanged) => PlinthPagination(
                    // page is 1-based, and shrinking total below the
                    // current page would leave it pointing past the
                    // end.
                    page: page > total ? total : page,
                    total: total,
                    siblingCount: siblingCount,
                    onChanged: onChanged,
                    size: size,
                    color: color,
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Small total (no ellipsis)',
            builder: (context) => _themed(const _PaginationDemo(total: 5)),
          ),
          WidgetbookUseCase(
            name: 'Large total (ellipsis)',
            builder: (context) =>
                _themed(const _PaginationDemo(total: 20, initialPage: 10)),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthTimeline',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final activeIndex = context.knobs.int.slider(
                label: 'active item',
                initialValue: 1,
                min: 0,
                max: 2,
                description: 'active highlights the dot — use it for '
                    'the current or most recent event',
              );
              final withIcons = context.knobs.boolean(label: 'item icons');
              final withDescriptions = context.knobs.boolean(
                label: 'descriptions',
                initialValue: true,
              );
              final color = _colorKnob(context);
              const events = [
                ('Order placed', 'We received your order', Icons.receipt_long),
                ('Shipped', 'On its way to you', Icons.local_shipping_outlined),
                ('Delivered', 'Left at the front door', Icons.home_outlined),
              ];
              return _themed(
                SizedBox(
                  width: 360,
                  child: PlinthTimeline(
                    color: color,
                    items: [
                      for (var i = 0; i < events.length; i++)
                        PlinthTimelineItem(
                          title: events[i].$1,
                          description: withDescriptions ? events[i].$2 : null,
                          icon: withIcons ? Icon(events[i].$3) : null,
                          active: i == activeIndex,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final icon = _iconKnob(context, label: 'icon');
              final withBadge = context.knobs.boolean(
                label: 'trailing badge',
                description: 'trailing takes any widget — an unread '
                    'count is the common case',
              );
              final enabled = context.knobs.boolean(
                label: 'enabled',
                initialValue: true,
              );
              final label = context.knobs.string(
                label: 'label',
                initialValue: 'Inbox',
              );
              final color = _colorKnob(context);
              return _themed(
                SizedBox(
                  width: 260,
                  child: _Local<bool>(
                    initial: true,
                    builder: (active, onChanged) => PlinthNavLink(
                      label: label,
                      active: active,
                      leadingIcon: icon == null ? null : Icon(icon),
                      trailing: withBadge ? const PlinthBadge('3') : null,
                      color: color,
                      onTap: enabled ? () => onChanged(!active) : null,
                    ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Active and inactive',
            builder: (context) => _themed(
              Column(
                children: [
                  PlinthNavLink(
                    label: 'Dashboard',
                    leadingIcon: const Icon(Icons.dashboard_outlined),
                    active: true,
                    onTap: () {},
                  ),
                  PlinthNavLink(
                    label: 'Settings',
                    leadingIcon: const Icon(Icons.settings_outlined),
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
        name: 'PlinthLoader',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthLoader(
                type: context.knobs.object.dropdown(
                  label: 'type',
                  options: PlinthLoaderType.values,
                  initialOption: PlinthLoaderType.oval,
                  labelBuilder: (type) => type.name,
                ),
                size: _sizeKnob(context),
                color: _colorKnob(context),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'All types and sizes',
            builder: (context) => _themed(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final type in PlinthLoaderType.values) ...[
                    PlinthText(type.name, size: PlinthSize.xs, color: 'gray'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final size in PlinthSize.values) ...[
                          PlinthLoader(type: type, size: size),
                          const SizedBox(width: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthAlert',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final icon = _iconKnob(context, label: 'icon');
              final dismissible = context.knobs.boolean(
                label: 'dismissible',
                initialValue: true,
                description: 'A non-null onClose is what shows the '
                    'close button',
              );
              return _themed(
                SizedBox(
                  width: 420,
                  child: PlinthAlert(
                    title: context.knobs.stringOrNull(
                      label: 'title',
                      initialValue: 'Heads up',
                      defaultToNull: true,
                    ),
                    color: _feedbackColorKnob(context),
                    icon: icon == null ? null : Icon(icon),
                    radius: _radiusKnob(context),
                    onClose: dismissible ? () {} : null,
                    child: PlinthText(
                      context.knobs.string(
                        label: 'body',
                        initialValue: 'Your changes have been saved.',
                      ),
                      size: PlinthSize.sm,
                    ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Info',
            builder: (context) => _themed(
              const PlinthAlert(
                title: 'Heads up',
                color: 'blue',
                icon: Icon(Icons.info_outline),
                child: Text('This is an informational message.'),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Error',
            builder: (context) => _themed(
              const PlinthAlert(
                title: 'Something went wrong',
                color: 'red',
                icon: Icon(Icons.error_outline),
                child: Text('Please try again in a few minutes.'),
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
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                child: PlinthProgress(
                  // Asserted to 0..1, so the slider is bounded there
                  // rather than clamped after the fact.
                  value: context.knobs.double.slider(
                    label: 'value',
                    initialValue: 0.6,
                    min: 0,
                    max: 1,
                    divisions: 20,
                  ),
                  size: _sizeKnob(context),
                  color: _colorKnob(context),
                  radius: _radiusKnob(context),
                  trackColor: context.knobs.colorOrNull(
                    label: 'trackColor',
                    description: 'null uses the theme gray',
                    defaultToNull: true,
                  ),
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Various fill levels',
            builder: (context) => _themed(
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlinthProgress(value: 0.25, color: 'blue'),
                  SizedBox(height: 8),
                  PlinthProgress(value: 0.6, color: 'green'),
                  SizedBox(height: 8),
                  PlinthProgress(value: 0.9, color: 'red'),
                ],
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Sections (bar)',
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                // The parts sum to 0.9 on purpose: the last tenth
                // stays track, which is the behaviour that separates
                // fractions of the whole from ratios between parts.
                child: PlinthProgress.sections(
                  sections: const [
                    PlinthProgressSection(
                        value: 0.5, color: 'blue', label: 'Direct'),
                    PlinthProgressSection(
                        value: 0.3, color: 'teal', label: 'Search'),
                    PlinthProgressSection(
                        value: 0.1, color: 'grape', label: 'Social'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthNotification',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final icon = _iconKnob(context, label: 'icon');
              final dismissible = context.knobs.boolean(
                label: 'dismissible',
                initialValue: true,
              );
              return _themed(
                SizedBox(
                  width: 420,
                  // Rendered inline here so the knobs are visible
                  // against it. In real use this floats — push it with
                  // PlinthNotification.show(context, ...), which wires
                  // onClose up for you via ScaffoldMessenger.
                  child: PlinthNotification(
                    title: context.knobs.stringOrNull(
                      label: 'title',
                      initialValue: 'Upload complete',
                      defaultToNull: true,
                    ),
                    color: _feedbackColorKnob(context),
                    icon: icon == null ? null : Icon(icon),
                    radius: _radiusKnob(context),
                    onClose: dismissible ? () {} : null,
                    child: PlinthText(
                      context.knobs.string(
                        label: 'body',
                        initialValue: '3 files were uploaded.',
                      ),
                      size: PlinthSize.sm,
                    ),
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) {
              final circle = context.knobs.boolean(label: 'circle');
              final width = context.knobs.doubleOrNull.input(
                label: 'width',
                initialValue: 200,
                description: 'null fills the parent',
                defaultToNull: true,
              );
              final height = context.knobs.double.slider(
                label: 'height',
                initialValue: 16,
                min: 8,
                max: 80,
              );
              return _themed(
                SizedBox(
                  width: 320,
                  child: PlinthSkeleton(
                    width: circle ? height : width,
                    height: height,
                    circle: circle,
                    // radius is what rounds the rectangle, so it has
                    // no effect once circle is on.
                    radius: circle ? null : _radiusKnob(context),
                  ),
                ),
              );
            },
          ),
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
        name: 'PlinthCollapse',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final duration = context.knobs.int.slider(
                label: 'duration (ms)',
                initialValue: 200,
                min: 50,
                max: 1000,
              );
              return _themed(
                SizedBox(
                  width: 360,
                  child: _Local<bool>(
                    initial: true,
                    builder: (opened, onChanged) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PlinthButton(
                          variant: PlinthVariant.subtle,
                          leadingIcon: Icon(
                            opened ? Icons.expand_less : Icons.expand_more,
                            size: 16,
                          ),
                          onPressed: () => onChanged(!opened),
                          child: Text(opened ? 'Hide filters' : 'Show filters'),
                        ),
                        PlinthCollapse(
                          opened: opened,
                          duration: Duration(milliseconds: duration),
                          child: PlinthPaper(
                            withBorder: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PlinthCheckbox(
                                  label: 'In stock only',
                                  value: true,
                                  onChanged: (_) {},
                                ),
                                PlinthCheckbox(
                                  label: 'On sale',
                                  value: false,
                                  onChanged: (_) {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthCloseButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final enabled = context.knobs.boolean(
                label: 'enabled',
                initialValue: true,
              );
              return _themed(
                PlinthCloseButton(
                  size: _sizeKnob(context),
                  color: _colorKnob(context),
                  radius: _radiusKnob(context),
                  semanticLabel: context.knobs.string(
                    label: 'semanticLabel',
                    initialValue: 'Close',
                    description: 'What a screen reader announces',
                  ),
                  onPressed: enabled ? () {} : null,
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'All sizes',
            builder: (context) => _themed(
              PlinthGroup(
                children: [
                  for (final size in PlinthSize.values)
                    PlinthCloseButton(size: size, onPressed: () {}),
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
            name: 'Playground',
            builder: (context) {
              final maxHeight = context.knobs.double.slider(
                label: 'maxHeight',
                initialValue: 100,
                min: 40,
                max: 240,
                description: 'Collapsed height — above this the '
                    'toggle appears',
              );
              final paragraphs = context.knobs.int.slider(
                label: 'paragraphs',
                initialValue: 3,
                min: 1,
                max: 6,
              );
              return _themed(
                SizedBox(
                  width: 420,
                  child: PlinthSpoiler(
                    maxHeight: maxHeight,
                    showLabel: context.knobs.string(
                      label: 'showLabel',
                      initialValue: 'Show more',
                    ),
                    hideLabel: context.knobs.string(
                      label: 'hideLabel',
                      initialValue: 'Show less',
                    ),
                    color: _colorKnob(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < paragraphs; i++)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: PlinthText(
                              'One block of content that is either fully '
                              'shown or height-clipped — unlike an '
                              'accordion, which is a list of independently '
                              'toggleable sections.',
                              size: PlinthSize.sm,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                child: PlinthLoadingOverlay(
                  visible: context.knobs.boolean(
                    label: 'visible',
                    initialValue: true,
                    description: 'The child stays in the tree either '
                        'way, so layout does not shift on toggle',
                  ),
                  color: _colorKnob(context),
                  child: PlinthPaper(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PlinthText('Account settings'),
                        const SizedBox(height: 12),
                        PlinthButton(
                          onPressed: () {},
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
      // PlinthRingProgress had no use cases at all before this — one
      // of three exported components missing from the gallery
      // entirely, alongside PlinthCode and PlinthMark below.
      WidgetbookComponent(
        name: 'PlinthRingProgress',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final value = context.knobs.double.slider(
                label: 'value',
                initialValue: 0.72,
                min: 0,
                max: 1,
                divisions: 20,
              );
              final diameter = context.knobs.double.slider(
                label: 'size (diameter)',
                initialValue: 80,
                min: 40,
                max: 160,
                description: 'A raw pixel diameter, not a PlinthSize — '
                    'this is the one component whose size is a double',
              );
              final thickness = context.knobs.double.slider(
                label: 'thickness',
                initialValue: 8,
                min: 2,
                max: 24,
              );
              final withLabel = context.knobs.boolean(
                label: 'centre label',
                initialValue: true,
              );
              return _themed(
                PlinthRingProgress(
                  value: value,
                  // A thickness past the radius would paint the ring
                  // back over itself.
                  thickness:
                      thickness > diameter / 2 ? diameter / 2 : thickness,
                  diameter: diameter,
                  color: _colorKnob(context),
                  trackColor: context.knobs.colorOrNull(
                    label: 'trackColor',
                    defaultToNull: true,
                  ),
                  label: withLabel
                      ? PlinthText(
                          '${(value * 100).round()}%',
                          size: PlinthSize.xs,
                          weight: FontWeight.w700,
                        )
                      : null,
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Sections',
            builder: (context) => _themed(
              PlinthRingProgress.sections(
                diameter: 120,
                thickness: 14,
                sections: const [
                  PlinthProgressSection(
                      value: 0.45, color: 'blue', label: 'Docs'),
                  PlinthProgressSection(
                      value: 0.3, color: 'teal', label: 'Media'),
                  PlinthProgressSection(
                      value: 0.15, color: 'grape', label: 'Other'),
                ],
                label: const PlinthText('90%',
                    size: PlinthSize.sm, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthSemiCircleProgress',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final value = context.knobs.double.slider(
                label: 'value',
                initialValue: 0.72,
                min: 0,
                max: 1,
                divisions: 20,
              );
              final diameter = context.knobs.double.slider(
                label: 'size (diameter)',
                initialValue: 160,
                min: 60,
                max: 240,
                description: 'The rendered height is about half this — '
                    'only the top half of the circle is drawn',
              );
              return _themed(
                PlinthSemiCircleProgress(
                  value: value,
                  diameter: diameter,
                  thickness: context.knobs.double.slider(
                    label: 'thickness',
                    initialValue: 12,
                    min: 2,
                    max: 40,
                  ),
                  color: _colorKnob(context),
                  trackColor: context.knobs.colorOrNull(
                    label: 'trackColor',
                    defaultToNull: true,
                  ),
                  label: context.knobs.boolean(
                    label: 'centre label',
                    initialValue: true,
                  )
                      ? PlinthText(
                          '${(value * 100).round()}%',
                          size: PlinthSize.lg,
                          weight: FontWeight.w700,
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthEmptyState',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final icon = _iconKnob(context, label: 'icon');
              final withAction = context.knobs.boolean(
                label: 'action',
                initialValue: true,
                description: 'An empty state without one tells the user '
                    'their situation but not what to do about it',
              );
              return _themed(
                SizedBox(
                  width: 360,
                  child: PlinthEmptyState(
                    icon: icon == null ? null : Icon(icon),
                    title: context.knobs.string(
                      label: 'title',
                      initialValue: 'No messages',
                    ),
                    description: context.knobs.stringOrNull(
                      label: 'description',
                      initialValue: 'Anything sent to your team lands here.',
                      defaultToNull: true,
                    ),
                    color: _colorKnob(context),
                    action: withAction
                        ? PlinthButton(
                            onPressed: () {},
                            child: const Text('Compose'),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Empty search result',
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                child: PlinthEmptyState(
                  icon: const Icon(Icons.search_off),
                  title: 'No results for "plinth"',
                  description: 'Try a shorter or differently spelled term.',
                  action: PlinthButton(
                    variant: PlinthVariant.subtle,
                    onPressed: () {},
                    child: const Text('Clear search'),
                  ),
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
            name: 'Playground',
            builder: (context) {
              final title = context.knobs.stringOrNull(
                label: 'title',
                initialValue: 'Confirm deletion',
                defaultToNull: true,
              );
              final size = _sizeKnob(context);
              final radius = _radiusKnob(context);
              final closeOnBackdropTap = context.knobs.boolean(
                label: 'closeOnBackdropTap',
                initialValue: true,
              );
              return _themed(
                _Disclosed(
                  // PlinthModal doesn't render inline — the host shows
                  // it whenever the controller opens, so the use case
                  // is the trigger, not the modal itself.
                  builder: (controller) => PlinthModalHost(
                    modal: PlinthModal(
                      controller: controller,
                      title: title,
                      size: size,
                      radius: radius,
                      closeOnBackdropTap: closeOnBackdropTap,
                      child: const PlinthText(
                        'This action cannot be undone.',
                        size: PlinthSize.sm,
                      ),
                    ),
                    child: PlinthButton(
                      onPressed: controller.open,
                      child: const Text('Open modal'),
                    ),
                  ),
                ),
              );
            },
          ),
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
        name: 'PlinthDialog',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final title = context.knobs.stringOrNull(
                label: 'title',
                initialValue: 'Subscribe',
                defaultToNull: true,
              );
              final position = context.knobs.object.dropdown(
                label: 'position',
                options: PlinthDialogPosition.values,
                initialOption: PlinthDialogPosition.bottomRight,
                labelBuilder: (position) => position.name,
              );
              final width = context.knobs.double.slider(
                label: 'width',
                initialValue: 320,
                min: 200,
                max: 480,
              );
              final withCloseButton = context.knobs.boolean(
                label: 'withCloseButton',
                initialValue: true,
              );
              final radius = _radiusKnob(context);
              final margin = _gapKnob(
                context,
                label: 'margin',
                initial: PlinthSize.lg,
              );
              return _themed(
                _Disclosed(
                  // Like Modal, this renders nothing inline — the panel
                  // goes into the overlay when the controller opens.
                  // Unlike Modal, there's no barrier: the button below
                  // stays clickable while the dialog is up.
                  builder: (controller) => Stack(
                    children: [
                      Center(
                        child: PlinthButton(
                          onPressed: controller.open,
                          child: const Text('Open dialog'),
                        ),
                      ),
                      PlinthDialog(
                        controller: controller,
                        title: title,
                        position: position,
                        width: width,
                        withCloseButton: withCloseButton,
                        radius: radius,
                        margin: margin,
                        child: const PlinthText(
                          'Get a monthly note when something ships.',
                          size: PlinthSize.sm,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthTooltip',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthTooltip(
                message: context.knobs.string(
                  label: 'message',
                  initialValue: 'Copied to clipboard',
                ),
                // Tooltips default to sm, not the md most components
                // use — an md tooltip reads oversized.
                size: _sizeKnob(context, initial: PlinthSize.sm),
                radius: _radiusKnob(context),
                position: context.knobs.object.dropdown(
                  label: 'position',
                  options: PlinthTooltipPosition.values,
                  initialOption: PlinthTooltipPosition.top,
                  labelBuilder: (p) => p.name,
                  description: 'Two sides, not four — Flutter picks the '
                      'horizontal placement itself',
                ),
                openDelay: Duration(
                  milliseconds: context.knobs.int.slider(
                    label: 'openDelay (ms)',
                    initialValue: 400,
                    min: 0,
                    max: 1500,
                  ),
                ),
                color: _colorKnob(context),
                child: PlinthButton(
                  variant: PlinthVariant.outline,
                  onPressed: () {},
                  child: const Text('Hover me'),
                ),
              ),
            ),
          ),
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
        name: 'PlinthOverlay',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 320,
                height: 180,
                // PlinthOverlay renders via Positioned.fill, so it
                // needs a Stack ancestor and a bounded box to dim.
                child: Stack(
                  children: [
                    const PlinthPaper(
                      child: PlinthText(
                        'Content sitting underneath the overlay.',
                      ),
                    ),
                    PlinthOverlay(
                      color: context.knobs.boolean(label: 'white overlay')
                          ? Colors.white
                          : Colors.black,
                      opacity: context.knobs.double.slider(
                        label: 'opacity',
                        initialValue: 0.6,
                        min: 0,
                        max: 1,
                        divisions: 20,
                      ),
                      blockPointerEvents: context.knobs.boolean(
                        label: 'blockPointerEvents',
                        description: 'Off by default, unlike '
                            'PlinthLoadingOverlay which always blocks',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Dimmed content',
            builder: (context) => _themed(
              SizedBox(
                width: 240,
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
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthScrollArea',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final direction = context.knobs.object.dropdown(
                label: 'direction',
                options: Axis.values,
                initialOption: Axis.vertical,
                labelBuilder: (axis) => axis.name,
              );
              final itemCount = context.knobs.int.slider(
                label: 'items',
                initialValue: 12,
                min: 1,
                max: 30,
                description: 'Enough to overflow, or the scrollbar has '
                    'nothing to show',
              );
              final isVertical = direction == Axis.vertical;
              return _themed(
                SizedBox(
                  width: isVertical ? 260 : 320,
                  height: isVertical ? 160 : 80,
                  child: PlinthScrollArea(
                    direction: direction,
                    child: isVertical
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < itemCount; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: PlinthText('Row ${i + 1}'),
                                ),
                            ],
                          )
                        : Row(
                            children: [
                              for (var i = 0; i < itemCount; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: PlinthText('Col ${i + 1}'),
                                ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Always-visible scrollbar',
            builder: (context) => _themed(
              SizedBox(
                height: 120,
                width: 200,
                child: PlinthScrollArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 1; i <= 10; i++) Text('Item $i'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthPortal',
        useCases: [
          WidgetbookUseCase(
            name: 'Basic',
            builder: (context) => _themed(
              const PlinthPortal(
                  child: Text('Rendered via the ambient Overlay')),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthPopover',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final position = _popoverPositionKnob(context);
              final width = context.knobs.double.slider(
                label: 'width',
                initialValue: 240,
                min: 120,
                max: 360,
              );
              final closeOnOutsideTap = context.knobs.boolean(
                label: 'closeOnOutsideTap',
                initialValue: true,
              );
              return _themed(
                _Disclosed(
                  builder: (controller) => PlinthPopover(
                    controller: controller,
                    position: position,
                    width: width,
                    closeOnOutsideTap: closeOnOutsideTap,
                    // The popover wraps its own trigger, so tapping
                    // the target toggles the controller directly —
                    // no separate host widget.
                    target: PlinthButton(
                      variant: PlinthVariant.outline,
                      onPressed: () {},
                      child: const Text('Show info'),
                    ),
                    content: const PlinthText(
                      'Anchored to its target, tracks scroll position, '
                      'dismisses on outside tap.',
                      size: PlinthSize.sm,
                    ),
                  ),
                ),
              );
            },
          ),
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
        name: 'PlinthHoverCard',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthHoverCard(
                position: _popoverPositionKnob(context),
                width: context.knobs.double.slider(
                  label: 'width',
                  initialValue: 260,
                  min: 140,
                  max: 380,
                ),
                closeDelay: Duration(
                  milliseconds: context.knobs.int.slider(
                    label: 'closeDelay (ms)',
                    initialValue: 100,
                    min: 0,
                    max: 1000,
                    description: 'Grace period so the pointer can '
                        'travel from target onto content without the '
                        'card closing underneath it',
                  ),
                ),
                target: PlinthAnchor('@yairlahav', onTap: () {}),
                content: const PlinthGroup(
                  gap: PlinthSize.sm,
                  children: [
                    PlinthAvatar(initials: 'YL', size: PlinthSize.md),
                    PlinthText('Hover-triggered — inert on touch devices.',
                        size: PlinthSize.sm),
                  ],
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Hover the target',
            // Desktop/web-oriented — hover the target text in a
            // browser or desktop build to see the card; there's
            // no hover concept to simulate on touch.
            builder: (context) => _themed(
              PlinthHoverCard(
                target: PlinthAnchor('Hover for details', onTap: () {}),
                content: const PlinthText(
                  'Extra context shown on hover.',
                  size: PlinthSize.sm,
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthMenu',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final position = _popoverPositionKnob(context);
              final width = context.knobs.double.slider(
                label: 'width',
                initialValue: 200,
                min: 120,
                max: 320,
              );
              final showDivider = context.knobs.boolean(
                label: 'divider before destructive item',
                initialValue: true,
              );
              return _themed(
                _Disclosed(
                  builder: (controller) => PlinthMenu(
                    controller: controller,
                    position: position,
                    width: width,
                    target: PlinthActionIcon(
                      semanticLabel: 'More actions',
                      icon: const Icon(Icons.more_vert, size: 18),
                      variant: PlinthVariant.subtle,
                      onPressed: () {},
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
                      if (showDivider) const PlinthMenuItem.divider(),
                      PlinthMenuItem(
                        label: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        // A destructive item is coloured per-item
                        // rather than by a menu-wide setting.
                        color: 'red',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Click to toggle',
            // Same interactive-live rationale as Popover — Menu
            // is built directly on PlinthPopover.
            builder: (context) => _themed(_MenuDemo()),
          ),
        ],
      ),
      // PlinthDrawer and PlinthAffix had no use cases at all before
      // this — they were the only two exported overlay components
      // missing from the gallery entirely.
      WidgetbookComponent(
        name: 'PlinthDrawer',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final position = context.knobs.object.dropdown(
                label: 'position',
                options: PlinthDrawerPosition.values,
                initialOption: PlinthDrawerPosition.right,
                labelBuilder: (value) => value.name,
              );
              final title = context.knobs.stringOrNull(
                label: 'title',
                initialValue: 'Filters',
                defaultToNull: true,
              );
              final size = _sizeKnob(context);
              final closeOnBackdropTap = context.knobs.boolean(
                label: 'closeOnBackdropTap',
                initialValue: true,
              );
              return _themed(
                _Disclosed(
                  builder: (controller) => PlinthDrawerHost(
                    drawer: PlinthDrawer(
                      controller: controller,
                      title: title,
                      // size is a width for left/right and a height
                      // for top/bottom.
                      size: size,
                      position: position,
                      closeOnBackdropTap: closeOnBackdropTap,
                      child: const PlinthText(
                        'Drawer body content.',
                        size: PlinthSize.sm,
                      ),
                    ),
                    child: PlinthButton(
                      onPressed: controller.open,
                      child: const Text('Open drawer'),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthFloatingWindow',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 460,
                height: 320,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x22000000)),
                  ),
                  child: Stack(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: PlinthText(
                          'Drag the header to move it, the corner to '
                          'resize. Both clamp to this box — a window '
                          'dragged off the edge could never come back.',
                          size: PlinthSize.xs,
                        ),
                      ),
                      PlinthFloatingWindow(
                        title: 'Inspector',
                        resizable: context.knobs.boolean(
                          label: 'resizable',
                          initialValue: true,
                        ),
                        onClose: () {},
                        child: const PlinthText(
                          'Not a modal: nothing behind it is blocked.',
                          size: PlinthSize.sm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthAffix',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final inset = context.knobs.double.slider(
                label: 'inset',
                initialValue: 16,
                min: 0,
                max: 48,
              );
              final corner = context.knobs.object.dropdown(
                label: 'corner',
                options: const [
                  'bottomRight',
                  'bottomLeft',
                  'topRight',
                  'topLeft'
                ],
                initialOption: 'bottomRight',
              );
              final isTop = corner.startsWith('top');
              final isLeft = corner.endsWith('Left');
              return _themed(
                SizedBox(
                  width: 320,
                  height: 200,
                  // Affix is a thin wrapper around Positioned, so it
                  // needs a Stack ancestor — it anchors within an
                  // existing stack rather than inserting an overlay.
                  child: Stack(
                    children: [
                      const PlinthPaper(
                        child: PlinthText('Scrollable page content.'),
                      ),
                      PlinthAffix(
                        top: isTop ? inset : null,
                        bottom: isTop ? null : inset,
                        left: isLeft ? inset : null,
                        right: isLeft ? null : inset,
                        child: PlinthActionIcon(
                          semanticLabel: 'Move up',
                          icon: const Icon(Icons.arrow_upward),
                          circle: true,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
            name: 'Playground',
            builder: (context) {
              // The fallback chain is imageUrl -> initials -> a generic
              // person icon, so the knobs are ordered to walk down it.
              final source = context.knobs.object.dropdown(
                label: 'source',
                options: const ['initials', 'broken imageUrl', 'neither'],
                initialOption: 'initials',
                description: 'A failed image falls through to initials, '
                    'and no initials falls through to an icon',
              );
              return _themed(
                PlinthAvatar(
                  imageUrl: source == 'broken imageUrl'
                      ? 'https://example.invalid/missing.png'
                      : null,
                  initials: source == 'neither'
                      ? null
                      : context.knobs.string(
                          label: 'initials',
                          initialValue: 'YL',
                        ),
                  size: _sizeKnob(context),
                  color: _colorKnob(context),
                  radius: _radiusKnob(context),
                ),
              );
            },
          ),
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
            name: 'Sorting and filtering',
            builder: (context) {
              final sortable = context.knobs.boolean(
                label: 'sortable',
                initialValue: true,
                description: 'Tap a header to sort; tap again to '
                    'reverse. Score sorts as numbers, not text',
              );
              final query = context.knobs.string(
                label: 'filter',
                description: 'Matches any column, case insensitively',
              );

              return _themed(
                SizedBox(
                  width: 480,
                  child: PlinthTable.text(
                    columns: const ['Name', 'Role', 'Score'],
                    sortable: sortable,
                    filter: query,
                    striped: context.knobs.boolean(label: 'striped'),
                    emptyState: const PlinthEmptyState(
                      title: 'No matches',
                      description: 'Try a shorter search.',
                    ),
                    rows: const [
                      ['Carol', 'Engineer', '9'],
                      ['Alice', 'Designer', '10'],
                      ['Bob', 'Engineer', '2'],
                      ['Dan', 'Support', '31'],
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Widget cells',
            builder: (context) => _themed(
              SizedBox(
                width: 480,
                // The default constructor takes widgets, so a status
                // column can hold a badge and an actions column a
                // button — PlinthTable.text is the shorthand for a
                // table that is only strings.
                child: PlinthTable(
                  striped: context.knobs.boolean(label: 'striped'),
                  size: _sizeKnob(context),
                  columns: const ['Member', 'Role', 'Status', ''],
                  rows: [
                    for (final row in const [
                      (
                        initials: 'AB',
                        name: 'Ada Byron',
                        role: 'Maintainer',
                        status: 'Active',
                        tone: 'green',
                      ),
                      (
                        initials: 'GH',
                        name: 'Grace Hopper',
                        role: 'Reviewer',
                        status: 'Invited',
                        tone: 'gray',
                      ),
                      (
                        initials: 'AT',
                        name: 'Alan Turing',
                        role: 'Contributor',
                        status: 'Blocked',
                        tone: 'red',
                      ),
                    ])
                      [
                        Row(
                          children: [
                            PlinthAvatar(
                              initials: row.initials,
                              size: PlinthSize.sm,
                            ),
                            const SizedBox(width: 8),
                            // A table cell is width-bounded, so the
                            // text has to flex or the row overflows.
                            Expanded(
                              child: PlinthText(
                                row.name,
                                size: PlinthSize.sm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        PlinthText(row.role, size: PlinthSize.sm),
                        PlinthBadge(row.status, color: row.tone),
                        PlinthActionIcon(
                          semanticLabel: 'More actions',
                          icon: const Icon(Icons.more_horiz, size: 16),
                          variant: PlinthVariant.subtle,
                          onPressed: () {},
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final rowCount = context.knobs.int.slider(
                label: 'rows',
                initialValue: 4,
                min: 1,
                max: 8,
              );
              const names = [
                'Ada',
                'Grace',
                'Alan',
                'Edsger',
                'Barbara',
                'Donald',
                'Ken',
                'Dennis'
              ];
              return _themed(
                SizedBox(
                  width: 420,
                  child: PlinthTable.text(
                    striped: context.knobs.boolean(label: 'striped'),
                    size: _sizeKnob(context),
                    columns: const ['Name', 'Role', 'Commits'],
                    // Each row must match columns.length — the widget
                    // takes plain strings, with no per-cell widgets.
                    rows: [
                      for (var i = 0; i < rowCount; i++)
                        [
                          names[i],
                          i.isEven ? 'Maintainer' : 'Contributor',
                          '${(i + 1) * 37}'
                        ],
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => _themed(
              const PlinthTable.text(
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
              const PlinthTable.text(
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
            name: 'Playground',
            builder: (context) {
              final icon = _iconKnob(context, label: 'icon');
              final circle = context.knobs.boolean(label: 'circle');
              return _themed(
                // Same shape as PlinthActionIcon but decorative — no
                // onPressed, so nothing here toggles enabled state.
                PlinthThemeIcon(
                  icon: Icon(icon ?? Icons.check),
                  variant: _variantKnob(context),
                  size: _sizeKnob(context),
                  color: _colorKnob(context),
                  circle: circle,
                  radius: circle ? null : _radiusKnob(context),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) => _themed(
              PlinthIndicator(
                label: context.knobs.stringOrNull(
                  label: 'label',
                  initialValue: '3',
                  description: 'null renders a plain dot',
                  defaultToNull: true,
                ),
                position: context.knobs.object.dropdown(
                  label: 'position',
                  options: PlinthIndicatorPosition.values,
                  initialOption: PlinthIndicatorPosition.topEnd,
                  labelBuilder: (position) => position.name,
                ),
                // Defaults to red rather than the theme primary — a
                // notification dot reads as attention, not brand.
                color: _colorKnob(context),
                visible: context.knobs.boolean(
                  label: 'visible',
                  initialValue: true,
                  description: 'Hides the indicator without removing '
                      'the child from the tree',
                ),
                child: const Icon(Icons.notifications_outlined, size: 28),
              ),
            ),
          ),
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
            name: 'Playground',
            builder: (context) {
              final size = _sizeKnob(context);
              final enabled = context.knobs.boolean(
                label: 'enabled',
                initialValue: true,
              );
              return _themed(
                // Standalone and controlled — selection lives in the
                // caller, so a picker is several of these plus your
                // own state, which is what this use case builds.
                _Local<String>(
                  initial: 'blue',
                  builder: (selected, onChanged) => PlinthGroup(
                    gap: PlinthSize.sm,
                    children: [
                      for (final key in _paletteColors)
                        PlinthColorSwatch(
                          color: key,
                          selected: key == selected,
                          size: size,
                          onTap: enabled ? () => onChanged(key) : null,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Palette selector',
            builder: (context) => _themed(_ColorSwatchDemo()),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthNumberFormatter',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final scaled = context.knobs.boolean(
                label: 'fixed decimalScale',
                initialValue: true,
              );
              return _themed(
                PlinthNumberFormatter(
                  value: context.knobs.double.input(
                    label: 'value',
                    initialValue: 1234567.5,
                  ),
                  prefix: context.knobs.stringOrNull(
                    label: 'prefix',
                    initialValue: r'$',
                    defaultToNull: true,
                  ),
                  suffix: context.knobs.stringOrNull(
                    label: 'suffix',
                    defaultToNull: true,
                  ),
                  thousandSeparator: context.knobs.string(
                    label: 'thousandSeparator',
                    initialValue: ',',
                    description: 'Empty groups nothing. Not localised — '
                        'use intl for that',
                  ),
                  decimalSeparator: context.knobs.string(
                    label: 'decimalSeparator',
                    initialValue: '.',
                  ),
                  decimalScale: scaled
                      ? context.knobs.int
                          .slider(
                            label: 'decimalScale',
                            initialValue: 2,
                            min: 0,
                            max: 4,
                          )
                          .toInt()
                      : null,
                  trimTrailingZeros: context.knobs.boolean(
                    label: 'trimTrailingZeros',
                    description: 'No effect without a decimalScale',
                  ),
                  size: _sizeKnob(context, initial: PlinthSize.xl),
                  color: _colorKnob(context),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Formats side by side',
            builder: (context) => _themed(
              const PlinthStack(
                crossAxisAlignment: CrossAxisAlignment.start,
                gap: PlinthSize.sm,
                children: [
                  PlinthNumberFormatter(
                    value: 1234567.5,
                    prefix: r'$',
                    decimalScale: 2,
                  ),
                  PlinthNumberFormatter(value: 42, suffix: ' km'),
                  PlinthNumberFormatter(value: -1500, prefix: r'$'),
                  PlinthNumberFormatter(
                    value: 1234.56,
                    thousandSeparator: '.',
                    decimalSeparator: ',',
                    decimalScale: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthDataList',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                child: PlinthDataList(
                  orientation: context.knobs.object.dropdown(
                    label: 'orientation',
                    options: PlinthDataListOrientation.values,
                    initialOption: PlinthDataListOrientation.horizontal,
                    labelBuilder: (o) => o.name,
                    description: 'Horizontal aligns labels in one '
                        'intrinsic column; vertical stacks each pair',
                  ),
                  gap: _sizeKnob(context, initial: PlinthSize.sm),
                  labelGap: _sizeKnob(context, initial: PlinthSize.md),
                  size: _sizeKnob(context),
                  labelColor: _colorKnob(context),
                  items: const [
                    PlinthDataListItem.text('Order', '#4021'),
                    PlinthDataListItem.text('Placed', '12 Aug 2026'),
                    PlinthDataListItem.text('Total', r'$149.00'),
                  ],
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Widget values',
            builder: (context) => _themed(
              const SizedBox(
                width: 360,
                child: PlinthDataList(
                  items: [
                    PlinthDataListItem.text('Customer', 'Alice Nguyen'),
                    PlinthDataListItem(
                      label: 'Status',
                      value: PlinthBadge('Active', color: 'green'),
                    ),
                    PlinthDataListItem(
                      label: 'Plan',
                      value: PlinthBadge('Pro', color: 'violet'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthOverflowList',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final count = context.knobs.int
                  .slider(label: 'items', initialValue: 8, min: 1, max: 16)
                  .toInt();
              return _themed(
                SizedBox(
                  // Narrow the width and watch the marker count climb —
                  // the fit is computed during layout, so it tracks the
                  // width exactly rather than a frame behind it.
                  width: context.knobs.double
                      .slider(
                        label: 'available width',
                        initialValue: 260,
                        min: 40,
                        max: 600,
                      )
                      .toDouble(),
                  child: PlinthOverflowList(
                    gap: _sizeKnob(context, initial: PlinthSize.sm),
                    size: _sizeKnob(context, initial: PlinthSize.sm),
                    color: _colorKnob(context),
                    children: [
                      for (var i = 0; i < count; i++)
                        PlinthBadge('Tag ${i + 1}'),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Avatar stack',
            builder: (context) => _themed(
              const SizedBox(
                width: 200,
                child: PlinthOverflowList(
                  children: [
                    PlinthAvatar(initials: 'AN'),
                    PlinthAvatar(initials: 'BK'),
                    PlinthAvatar(initials: 'CD'),
                    PlinthAvatar(initials: 'EF'),
                    PlinthAvatar(initials: 'GH'),
                    PlinthAvatar(initials: 'IJ'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthRollingNumber',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final prefix = context.knobs.stringOrNull(
                label: 'prefix',
                initialValue: r'$',
                defaultToNull: true,
              );
              final scale = context.knobs.int
                  .slider(
                      label: 'decimalScale', initialValue: 2, min: 0, max: 3)
                  .toInt();
              final size = _sizeKnob(context, initial: PlinthSize.xl);
              final color = _colorKnob(context);

              // A rolling number is only itself in motion, so the use
              // case owns a value and a button to change it.
              return _themed(
                _Local<num>(
                  initial: 1250,
                  builder: (value, onChanged) => PlinthGroup(
                    children: [
                      PlinthRollingNumber(
                        value: value,
                        prefix: prefix,
                        decimalScale: scale,
                        size: size,
                        color: color,
                        weight: FontWeight.w700,
                      ),
                      PlinthButton(
                        onPressed: () => onChanged(value + 137),
                        child: const Text('+137'),
                      ),
                      PlinthButton(
                        variant: PlinthVariant.outline,
                        onPressed: () => onChanged(value - 48),
                        child: const Text('-48'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Crossing a power of ten',
            builder: (context) => _themed(
              _Local<num>(
                initial: 999,
                builder: (value, onChanged) => PlinthGroup(
                  children: [
                    PlinthRollingNumber(
                      value: value,
                      size: PlinthSize.xl,
                      weight: FontWeight.w700,
                    ),
                    PlinthButton(
                      onPressed: () => onChanged(value == 999 ? 1000 : 999),
                      child: const Text('Toggle 999 / 1000'),
                    ),
                  ],
                ),
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
        name: 'PlinthLtr',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final rtl = context.knobs.boolean(
                label: 'page is RTL',
                initialValue: true,
              );
              final pinned = context.knobs.boolean(
                label: 'wrap in PlinthLtr',
                initialValue: true,
              );
              Widget row() => const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlinthBadge('1'),
                      SizedBox(width: 4),
                      PlinthBadge('2'),
                      SizedBox(width: 4),
                      PlinthBadge('3'),
                      SizedBox(width: 8),
                      PlinthNumberFormatter(
                          value: 1234567.5, prefix: r'$', decimalScale: 2),
                    ],
                  );
              return _themed(
                Directionality(
                  textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: PlinthStack(
                    children: [
                      const PlinthText(
                        'Turn the page RTL and the axis reverses. Pin it and '
                        'the figures read the way numbers do.',
                        size: PlinthSize.sm,
                      ),
                      if (pinned) PlinthLtr(child: row()) else row(),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Pinned vs inherited in an RTL page',
            builder: (context) => _themed(
              const Directionality(
                textDirection: TextDirection.rtl,
                child: PlinthStack(
                  children: [
                    PlinthText('inherited — reverses', size: PlinthSize.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PlinthBadge('1'),
                        SizedBox(width: 4),
                        PlinthBadge('2'),
                        SizedBox(width: 4),
                        PlinthBadge('3'),
                      ],
                    ),
                    PlinthText('PlinthLtr — stays put', size: PlinthSize.xs),
                    PlinthLtr(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlinthBadge('1'),
                          SizedBox(width: 4),
                          PlinthBadge('2'),
                          SizedBox(width: 4),
                          PlinthBadge('3'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthSplitter',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 460,
                height: 220,
                child: PlinthSplitter(
                  direction: context.knobs.object.dropdown(
                    label: 'direction',
                    options: Axis.values,
                    labelBuilder: (a) => a.name,
                  ),
                  initialFraction: context.knobs.double
                      .slider(
                        label: 'initialFraction',
                        initialValue: 0.4,
                        min: 0.15,
                        max: 0.85,
                      )
                      .toDouble(),
                  thickness: context.knobs.double
                      .slider(
                          label: 'thickness', initialValue: 8, min: 4, max: 20)
                      .toDouble(),
                  first: const PlinthPaper(
                    p: PlinthSize.sm,
                    child: PlinthText('First pane'),
                  ),
                  second: const PlinthPaper(
                    p: PlinthSize.sm,
                    child: PlinthText('Second pane'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthScroller',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 320,
                height: 300,
                child: _Scrolled(
                  threshold: context.knobs.double
                      .slider(
                        label: 'threshold',
                        initialValue: 200,
                        min: 40,
                        max: 600,
                      )
                      .toDouble(),
                  color: _colorKnob(context),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthMarquee',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 420,
                child: PlinthMarquee(
                  speed: context.knobs.double
                      .slider(
                        label: 'speed (px/sec)',
                        initialValue: 40,
                        min: 5,
                        max: 200,
                      )
                      .toDouble(),
                  gap: _sizeKnob(context, initial: PlinthSize.xl),
                  reverse: context.knobs.boolean(label: 'reverse'),
                  pauseOnHover: context.knobs.boolean(
                    label: 'pauseOnHover',
                    initialValue: true,
                    description: 'Hover the strip to stop it. Desktop '
                        'and web only — there is no hover on touch',
                  ),
                  child: const PlinthGroup(
                    wrap: false,
                    children: [
                      PlinthBadge('Flutter'),
                      PlinthBadge('Dart'),
                      PlinthBadge('Mantine'),
                      PlinthBadge('Widgetbook'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Headline ticker',
            builder: (context) => _themed(
              const SizedBox(
                width: 420,
                child: PlinthMarquee(
                  speed: 25,
                  child: PlinthText(
                    'Plinth 0.12.0 is out  ·  Four new components  ·  '
                    'Reduce-motion aware',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthAppShell',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final navbarCollapsed = context.knobs.boolean(
                label: 'navbarCollapsed',
                description: 'Controlled by the caller — pair with a '
                    'Burger and a Drawer for narrow screens',
              );
              final withAside = context.knobs.boolean(label: 'aside');
              final withFooter = context.knobs.boolean(
                label: 'footer',
                initialValue: true,
              );
              final withHeader = context.knobs.boolean(
                label: 'header',
                initialValue: true,
              );
              return _themed(
                // The shell fills the height it is given, so the
                // gallery hands it a fixed box to read as a page.
                SizedBox(
                  width: 520,
                  height: 340,
                  child: PlinthAppShell(
                    navbarCollapsed: navbarCollapsed,
                    navbarWidth: context.knobs.double.slider(
                      label: 'navbarWidth',
                      initialValue: 160,
                      min: 100,
                      max: 260,
                    ),
                    withBorder: context.knobs.boolean(
                      label: 'withBorder',
                      initialValue: true,
                    ),
                    bg: _colorKnob(context),
                    header: withHeader
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: PlinthTitle('Dashboard', order: 4),
                            ),
                          )
                        : null,
                    navbar: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          PlinthNavLink(label: 'Overview', active: true),
                          PlinthNavLink(label: 'Reports'),
                          PlinthNavLink(label: 'Settings'),
                        ],
                      ),
                    ),
                    aside: withAside
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: PlinthText('Aside', size: PlinthSize.sm),
                          )
                        : null,
                    footer: withFooter
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: PlinthText(
                                'Footer',
                                size: PlinthSize.xs,
                                color: 'gray',
                              ),
                            ),
                          )
                        : null,
                    child: const PlinthText('Main content region.'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthGrid',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final span = context.knobs.int.slider(
                label: 'span (per column)',
                initialValue: 4,
                min: 1,
                max: 12,
              );
              final count = context.knobs.int.slider(
                label: 'columns rendered',
                initialValue: 3,
                min: 1,
                max: 8,
              );
              return _themed(
                SizedBox(
                  width: 480,
                  child: PlinthGrid(
                    gutter: _gapKnob(context, label: 'gutter'),
                    children: [
                      for (var i = 0; i < count; i++)
                        PlinthGridCol(
                          span: span,
                          child: Container(
                            height: 56,
                            color: const Color(0xFFE7F5FF),
                            alignment: Alignment.center,
                            child: PlinthText('span $span'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Responsive spans (resize the window)',
            builder: (context) => _themed(
              // spanMd applies from 992px up, so this is one column on
              // a phone-width workbench and two on a desktop one —
              // resize to see it, since a knob can't change the
              // viewport.
              PlinthGrid(
                children: [
                  PlinthGridCol(
                    span: 12,
                    spanMd: 8,
                    child: Container(
                      height: 80,
                      color: const Color(0xFFE7F5FF),
                      alignment: Alignment.center,
                      child: const PlinthText('span 12 / md 8'),
                    ),
                  ),
                  PlinthGridCol(
                    span: 12,
                    spanMd: 4,
                    child: Container(
                      height: 80,
                      color: const Color(0xFFFFF3BF),
                      alignment: Alignment.center,
                      child: const PlinthText('span 12 / md 4'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthTitle',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthTitle(
                context.knobs.string(
                  label: 'data',
                  initialValue: 'Getting started',
                ),
                order: context.knobs.int.slider(
                  label: 'order',
                  initialValue: 1,
                  min: 1,
                  max: 6,
                  description: 'h1-h6 — drives the visual scale and the '
                      'heading level exposed to screen readers',
                ),
                color: _colorKnob(context),
                textAlign: context.knobs.objectOrNull.dropdown(
                  label: 'textAlign',
                  options: const [
                    TextAlign.left,
                    TextAlign.center,
                    TextAlign.right,
                  ],
                  labelBuilder: (align) => align.name,
                  defaultToNull: true,
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'All orders',
            builder: (context) => _themed(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var order = 1; order <= 6; order++) ...[
                    PlinthTitle('Heading level $order', order: order),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthBox',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthBox(
                p: context.knobs.objectOrNull.dropdown(
                  label: 'p (padding)',
                  options: PlinthSize.values,
                  initialOption: PlinthSize.md,
                  labelBuilder: (size) => size.name,
                ),
                m: context.knobs.objectOrNull.dropdown(
                  label: 'm (margin)',
                  options: PlinthSize.values,
                  labelBuilder: (size) => size.name,
                  defaultToNull: true,
                ),
                w: context.knobs.doubleOrNull.input(
                  label: 'w',
                  initialValue: 240,
                  defaultToNull: true,
                ),
                h: context.knobs.doubleOrNull.input(
                  label: 'h',
                  initialValue: 100,
                  defaultToNull: true,
                ),
                // bg is a theme palette key, not a Color — it resolves
                // through the ramp like every other `color` prop.
                bg: _colorKnob(context),
                radius: _radiusKnob(context),
                // border, by contrast, is a literal Color.
                border: context.knobs.colorOrNull(
                  label: 'border',
                  initialValue: const Color(0xFFDEE2E6),
                ),
                alignment: context.knobs.objectOrNull.dropdown(
                  label: 'alignment',
                  options: const [
                    Alignment.topLeft,
                    Alignment.center,
                    Alignment.bottomRight,
                  ],
                  labelBuilder: (alignment) => alignment == Alignment.topLeft
                      ? 'topLeft'
                      : alignment == Alignment.center
                          ? 'center'
                          : 'bottomRight',
                  defaultToNull: true,
                ),
                child: const PlinthText('Box content', size: PlinthSize.sm),
              ),
            ),
          ),
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
        name: 'PlinthCenter',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => _themed(
              Container(
                width: 200,
                height: 80,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300)),
                child: const PlinthCenter(child: Text('Centered')),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthAspectRatio',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final ratio = context.knobs.object.dropdown(
                label: 'ratio',
                options: const [16 / 9, 4 / 3, 1.0, 3 / 4],
                initialOption: 16 / 9,
                labelBuilder: (value) => switch (value) {
                  1.0 => '1:1',
                  final v when v > 1.7 => '16:9',
                  final v when v > 1.0 => '4:3',
                  _ => '3:4',
                },
              );
              return _themed(
                SizedBox(
                  width: 260,
                  // The common case is reserving space for an image or
                  // embed before it loads, so layout doesn't jump.
                  child: PlinthAspectRatio(
                    ratio: ratio,
                    child: Container(
                      color: const Color(0xFFE7F5FF),
                      alignment: Alignment.center,
                      child: const PlinthText('Reserved space'),
                    ),
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: '16:9',
            builder: (context) => _themed(
              SizedBox(
                width: 240,
                child: PlinthAspectRatio(
                  ratio: 16 / 9,
                  child: Container(color: Colors.blue.shade100),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthGroup',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final count = context.knobs.int.slider(
                label: 'children',
                initialValue: 6,
                min: 1,
                max: 14,
                description: 'Enough to overflow the width shows the '
                    'wrap behaviour',
              );
              final wrap = context.knobs.boolean(
                label: 'wrap',
                initialValue: true,
                description: 'On (the default) uses Wrap; off falls '
                    'back to a Row that clips and overflows',
              );
              return _themed(
                SizedBox(
                  width: 360,
                  child: PlinthGroup(
                    gap: _gapKnob(context),
                    wrap: wrap,
                    mainAxisAlignment: _mainAxisAlignmentKnob(context),
                    children: [
                      for (var i = 0; i < count; i++)
                        PlinthBadge('Tag ${i + 1}'),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Wrapping row',
            builder: (context) => _themed(
              const PlinthGroup(
                gap: PlinthSize.sm,
                children: [
                  PlinthBadge('New'),
                  PlinthBadge('Updated'),
                  PlinthBadge('Popular'),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthStack',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 320,
                child: PlinthStack(
                  gap: _gapKnob(context),
                  crossAxisAlignment: context.knobs.object.dropdown(
                    label: 'crossAxisAlignment',
                    options: CrossAxisAlignment.values,
                    initialOption: CrossAxisAlignment.stretch,
                    labelBuilder: (alignment) => alignment.name,
                    description: 'Stretches by default, unlike PlinthGroup — '
                        'a column of fields usually wants full width',
                  ),
                  mainAxisAlignment: _mainAxisAlignmentKnob(context),
                  children: [
                    PlinthButton(onPressed: () {}, child: const Text('One')),
                    PlinthButton(onPressed: () {}, child: const Text('Two')),
                    PlinthButton(onPressed: () {}, child: const Text('Three')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthList',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final type = context.knobs.object.dropdown(
                label: 'type',
                options: PlinthListType.values,
                initialOption: PlinthListType.bullet,
                labelBuilder: (value) => value.name,
              );
              final withIcon = context.knobs.boolean(
                label: 'per-item icon on the 2nd item',
                description: 'An item icon overrides that item\'s '
                    'marker while the others keep the default',
              );
              return _themed(
                SizedBox(
                  width: 360,
                  child: PlinthList(
                    type: type,
                    spacing: _gapKnob(
                      context,
                      label: 'spacing',
                      initial: PlinthSize.xs,
                    ),
                    size: _sizeKnob(context),
                    items: [
                      const PlinthListItem(
                        PlinthText('Install the package'),
                      ),
                      PlinthListItem(
                        const PlinthText('Wrap your app in a PlinthTheme'),
                        icon: withIcon
                            ? const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Color(0xFF40C057),
                              )
                            : null,
                      ),
                      const PlinthListItem(
                        PlinthText('Start using components'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Ordered',
            builder: (context) => _themed(
              const PlinthList(
                type: PlinthListType.ordered,
                items: [
                  PlinthListItem(Text('First step')),
                  PlinthListItem(Text('Second step')),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthContainer',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthContainer(
                size: context.knobs.object.dropdown(
                  label: 'size (max width)',
                  options: PlinthContainerSize.values,
                  initialOption: PlinthContainerSize.md,
                  labelBuilder: (value) => value.name,
                ),
                padding: _gapKnob(context, label: 'padding'),
                child: Container(
                  color: const Color(0xFFE7F5FF),
                  padding: const EdgeInsets.all(12),
                  child: const PlinthText(
                    'Capped at the chosen container width and centred — '
                    'the standard "page content should not get absurdly '
                    'wide on a big monitor" wrapper.',
                    size: PlinthSize.sm,
                  ),
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'xs width',
            builder: (context) => _themed(
              PlinthContainer(
                size: PlinthContainerSize.xs,
                child: Container(
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.all(12),
                  child: const Text('Capped-width content'),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthSpace',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              // Invisible on its own, so it's shown between two labels
              // — the gap is the thing the knobs change.
              final horizontal = context.knobs.boolean(
                label: 'horizontal',
                initialValue: true,
              );
              final amount = _gapKnob(
                context,
                label: 'w / h',
                initial: PlinthSize.xl,
              );
              return _themed(
                horizontal
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PlinthText('Left', size: PlinthSize.sm),
                          PlinthSpace(w: amount),
                          const PlinthText('Right', size: PlinthSize.sm),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PlinthText('Above', size: PlinthSize.sm),
                          PlinthSpace(h: amount),
                          const PlinthText('Below', size: PlinthSize.sm),
                        ],
                      ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Horizontal',
            builder: (context) => _themed(
              const Row(
                children: [
                  Text('Left'),
                  PlinthSpace(w: PlinthSize.xl),
                  Text('Right'),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthUnstyledButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Custom tap target',
            builder: (context) => _themed(
              PlinthUnstyledButton(
                onPressed: () {},
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Fully custom'),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthSimpleGrid',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final columns = context.knobs.int.slider(
                label: 'columns',
                initialValue: 3,
                min: 1,
                max: 6,
              );
              final count = context.knobs.int.slider(
                label: 'children',
                initialValue: 6,
                min: 1,
                max: 12,
              );
              return _themed(
                // Not scrollable or virtualized — it sizes to content
                // and needs a bounded-width ancestor, so this supplies
                // one rather than relying on the use-case layout.
                SizedBox(
                  width: 380,
                  child: PlinthSimpleGrid(
                    columns: columns,
                    spacing: _gapKnob(context, label: 'spacing'),
                    children: [
                      for (var i = 0; i < count; i++)
                        Container(
                          height: 48,
                          color: const Color(0xFFE7F5FF),
                          alignment: Alignment.center,
                          child: PlinthText('${i + 1}'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: '3 columns',
            builder: (context) => _themed(
              SizedBox(
                width: 240,
                child: PlinthSimpleGrid(
                  columns: 3,
                  spacing: PlinthSize.sm,
                  children: [
                    for (final n in [1, 2, 3])
                      Container(
                        height: 40,
                        color: Colors.blue.shade50,
                        alignment: Alignment.center,
                        child: Text('$n'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthFlex',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                // PlinthGroup is this specialized to horizontal with
                // wrap-by-default; reach for Flex when the direction
                // itself needs to vary, which is what this knob shows.
                child: PlinthFlex(
                  direction: context.knobs.object.dropdown(
                    label: 'direction',
                    options: Axis.values,
                    initialOption: Axis.horizontal,
                    labelBuilder: (axis) => axis.name,
                  ),
                  gap: _gapKnob(context),
                  mainAxisAlignment: _mainAxisAlignmentKnob(context),
                  mainAxisSize: context.knobs.object.dropdown(
                    label: 'mainAxisSize',
                    options: MainAxisSize.values,
                    initialOption: MainAxisSize.min,
                    labelBuilder: (value) => value.name,
                  ),
                  children: const [
                    PlinthBadge('Dart'),
                    PlinthBadge('Flutter'),
                    PlinthBadge('Widgets'),
                  ],
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Horizontal',
            builder: (context) => _themed(
              const PlinthFlex(
                gap: PlinthSize.sm,
                children: [
                  PlinthBadge('Dart'),
                  PlinthBadge('Flutter'),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthImage',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              // The reason this exists over Image.network is the
              // loading placeholder and error fallback, so the knob
              // makes both reachable.
              final broken = context.knobs.boolean(
                label: 'broken src',
                description: 'A failed URL shows a themed broken-image '
                    'icon instead of surfacing a render error',
              );
              return _themed(
                PlinthImage(
                  src: broken
                      ? 'https://example.invalid/missing.png'
                      : 'https://picsum.photos/400/300',
                  width: context.knobs.double.slider(
                    label: 'width',
                    initialValue: 240,
                    min: 80,
                    max: 360,
                  ),
                  height: context.knobs.double.slider(
                    label: 'height',
                    initialValue: 160,
                    min: 80,
                    max: 300,
                  ),
                  fit: context.knobs.object.dropdown(
                    label: 'fit',
                    options: const [
                      BoxFit.cover,
                      BoxFit.contain,
                      BoxFit.fill,
                      BoxFit.fitWidth,
                    ],
                    initialOption: BoxFit.cover,
                    labelBuilder: (fit) => fit.name,
                  ),
                  radius: _radiusKnob(context),
                ),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'Network image',
            builder: (context) => _themed(
              const SizedBox(
                width: 200,
                height: 140,
                child: PlinthImage(
                  src: 'https://picsum.photos/id/1015/480/320',
                  radius: PlinthSize.sm,
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthCarousel',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 420,
                child: PlinthCarousel(
                  height: context.knobs.double.slider(
                    label: 'height',
                    initialValue: 200,
                    min: 120,
                    max: 320,
                  ),
                  // Below 1 the neighbours peek in, which is the knob
                  // worth playing with: it is what tells a reader
                  // there is more to swipe to.
                  slideSize: context.knobs.double.slider(
                    label: 'slideSize',
                    initialValue: 1,
                    min: 0.4,
                    max: 1,
                  ),
                  loop: context.knobs.boolean(label: 'loop'),
                  withControls: context.knobs
                      .boolean(label: 'withControls', initialValue: true),
                  withIndicators: context.knobs
                      .boolean(label: 'withIndicators', initialValue: true),
                  color: _colorKnob(context),
                  slides: [
                    for (var i = 1; i <= 4; i++)
                      PlinthPaper(
                        withBorder: true,
                        p: PlinthSize.lg,
                        child: Center(child: PlinthText('Slide $i')),
                      ),
                  ],
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Peeking slides',
            builder: (context) => _themed(
              SizedBox(
                width: 420,
                child: PlinthCarousel(
                  height: 160,
                  slideSize: 0.7,
                  loop: true,
                  withIndicators: true,
                  slides: [
                    for (final id in [1015, 1016, 1018, 1020])
                      PlinthImage(
                        src: 'https://picsum.photos/id/$id/480/320',
                        fit: BoxFit.cover,
                        radius: PlinthSize.sm,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthBackgroundImage',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthBackgroundImage(
                src: 'https://picsum.photos/id/1015/960/540',
                width: 420,
                height: context.knobs.double.slider(
                  label: 'height',
                  initialValue: 220,
                  min: 120,
                  max: 360,
                ),
                fit: context.knobs.object.dropdown(
                  label: 'fit',
                  options: BoxFit.values,
                  initialOption: BoxFit.cover,
                  labelBuilder: (fit) => fit.name,
                ),
                radius: _radiusKnob(context),
                scrimOpacity: context.knobs.double.slider(
                  label: 'scrimOpacity',
                  initialValue: 0.35,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  description: 'Drag to 0 to see why it defaults on — text '
                      'over a photograph disappears into its light parts',
                ),
                alignment: context.knobs.object.dropdown(
                  label: 'alignment',
                  options: const [
                    Alignment.center,
                    Alignment.topLeft,
                    Alignment.bottomLeft,
                    Alignment.bottomRight,
                  ],
                  initialOption: Alignment.center,
                  labelBuilder: (alignment) => switch (alignment) {
                    Alignment.topLeft => 'topLeft',
                    Alignment.bottomLeft => 'bottomLeft',
                    Alignment.bottomRight => 'bottomRight',
                    _ => 'center',
                  },
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: PlinthTitle('Ships tomorrow', order: 3),
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthText',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 360,
                child: PlinthText(
                  context.knobs.string(
                    label: 'data',
                    initialValue: 'The quick brown fox jumps over the lazy '
                        'dog and keeps going well past one line.',
                    maxLines: 3,
                  ),
                  // size resolves through theme.fontSizes rather than
                  // a raw fontSize double.
                  size: _sizeKnob(context),
                  color: _colorKnob(context),
                  italic: context.knobs.boolean(label: 'italic'),
                  weight: context.knobs.objectOrNull.dropdown(
                    label: 'weight',
                    options: const [
                      FontWeight.w400,
                      FontWeight.w600,
                      FontWeight.w700,
                    ],
                    labelBuilder: (weight) => 'w${weight.value}',
                    defaultToNull: true,
                  ),
                  textAlign: context.knobs.objectOrNull.dropdown(
                    label: 'textAlign',
                    options: const [
                      TextAlign.left,
                      TextAlign.center,
                      TextAlign.right,
                    ],
                    labelBuilder: (align) => align.name,
                    defaultToNull: true,
                  ),
                  maxLines: context.knobs.intOrNull.slider(
                    label: 'maxLines',
                    initialValue: 2,
                    min: 1,
                    max: 5,
                    defaultToNull: true,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
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
      WidgetbookComponent(
        name: 'PlinthDivider',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final vertical = context.knobs.boolean(label: 'vertical');
              final label = context.knobs.stringOrNull(
                label: 'label',
                initialValue: 'OR',
                description: 'Centres a label with rules either side',
                defaultToNull: true,
              );
              return _themed(
                SizedBox(
                  width: 300,
                  child: PlinthDivider(
                    label: label,
                    direction: vertical ? Axis.vertical : Axis.horizontal,
                    // A VerticalDivider needs an explicit extent from
                    // its parent to render visibly, so height is only
                    // meaningful in the vertical case.
                    height: vertical ? 80 : null,
                    // A literal Color here, not a palette key — one of
                    // the few components whose `color` is not a theme
                    // ramp lookup.
                    color: context.knobs.colorOrNull(
                      label: 'color',
                      defaultToNull: true,
                    ),
                  ),
                ),
              );
            },
          ),
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
                child: PlinthDivider(direction: Axis.vertical, height: 60),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthHighlight',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final query = context.knobs.string(
                label: 'query',
                initialValue: 'disclosure controller',
                description: 'Split on spaces — every term is marked',
              );
              return _themed(
                SizedBox(
                  width: 420,
                  child: PlinthHighlight(
                    context.knobs.string(
                      label: 'data',
                      initialValue: 'The disclosure controller drives every '
                          'overlay component in this library.',
                      maxLines: 3,
                    ),
                    highlight: query.split(' '),
                    color: _colorKnob(context),
                    size: _sizeKnob(context),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthCode',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthCode(
                context.knobs.string(
                  label: 'label',
                  initialValue: 'melos run test',
                ),
                // Defaults to gray rather than the theme primary — an
                // inline code span in brand blue reads as a link.
                color: context.knobs.object.dropdown(
                  label: 'color',
                  options: _paletteColors,
                  initialOption: 'gray',
                ),
                size: _sizeKnob(context),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthMark',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Results for '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: PlinthMark(
                        context.knobs.string(
                          label: 'label',
                          initialValue: 'disclosure controller',
                        ),
                        // Defaults to 'yellow' when the theme defines
                        // it — the default theme doesn't, so it falls
                        // back to a literal amber.
                        color: _colorKnob(context),
                      ),
                    ),
                    const TextSpan(text: ' in this page.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthAnchor',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) => _themed(
              PlinthAnchor(
                context.knobs.string(
                  label: 'label',
                  initialValue: 'Read the documentation',
                ),
                // Defaults to hover, matching conventional link
                // affordance rather than always-underlined.
                underline: context.knobs.object.dropdown(
                  label: 'underline',
                  options: PlinthAnchorUnderline.values,
                  initialOption: PlinthAnchorUnderline.hover,
                  labelBuilder: (value) => value.name,
                ),
                size: _sizeKnob(context),
                color: _colorKnob(context),
                onTap: () {},
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => _themed(
              PlinthAnchor('Forgot password?', onTap: () {}),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthVisuallyHidden',
        useCases: [
          WidgetbookUseCase(
            name: 'Icon button with a hidden label',
            builder: (context) => _themed(
              PlinthActionIcon(
                semanticLabel: 'Close',
                icon: const Stack(
                  children: [
                    Icon(Icons.close),
                    PlinthVisuallyHidden(child: Text('Close dialog')),
                  ],
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'PlinthBlockquote',
        useCases: [
          WidgetbookUseCase(
            name: 'Playground',
            builder: (context) {
              final icon = _iconKnob(context, label: 'icon');
              return _themed(
                SizedBox(
                  width: 420,
                  child: PlinthBlockquote(
                    quote: context.knobs.string(
                      label: 'quote',
                      initialValue: 'The best way to predict the future is '
                          'to invent it.',
                      maxLines: 3,
                    ),
                    citation: context.knobs.stringOrNull(
                      label: 'citation',
                      initialValue: 'Alan Kay',
                      defaultToNull: true,
                    ),
                    color: _colorKnob(context),
                    icon: icon == null ? null : Icon(icon),
                  ),
                ),
              );
            },
          ),
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
            name: 'Playground',
            builder: (context) => _themed(
              SizedBox(
                width: 320,
                child: PlinthPaper(
                  p: _sizeKnob(context),
                  shadow: _shadowKnob(context),
                  withBorder: context.knobs.boolean(label: 'withBorder'),
                  radius: _radiusKnob(context),
                  bg: context.knobs.colorOrNull(
                    label: 'bg',
                    defaultToNull: true,
                  ),
                  child: const PlinthText(
                    'The base surface PlinthCard builds on — reach for '
                    'this when you want a raised container without card '
                    'section conventions.',
                    size: PlinthSize.sm,
                  ),
                ),
              ),
            ),
          ),
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
            name: 'Playground',
            builder: (context) {
              // Sections left null are omitted entirely rather than
              // rendered empty, and a divider appears only between
              // sections that are actually present — so toggling
              // these is the thing worth seeing.
              final withHeader = context.knobs.boolean(
                label: 'header',
                initialValue: true,
              );
              final withFooter = context.knobs.boolean(
                label: 'footer',
                initialValue: true,
              );
              return _themed(
                SizedBox(
                  width: 320,
                  child: PlinthCard(
                    p: _sizeKnob(context),
                    shadow: _shadowKnob(context, initial: PlinthShadow.sm),
                    withBorder: context.knobs.boolean(
                      label: 'withBorder',
                      initialValue: true,
                    ),
                    radius: _radiusKnob(context),
                    header: withHeader
                        ? const PlinthText(
                            'Card header',
                            weight: FontWeight.w600,
                          )
                        : null,
                    footer: withFooter
                        ? const PlinthText(
                            'Card footer',
                            size: PlinthSize.xs,
                            color: 'gray',
                          )
                        : null,
                    child: const PlinthText(
                      'Card body content.',
                      size: PlinthSize.sm,
                    ),
                  ),
                ),
              );
            },
          ),
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
];

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

/// Owns the opened state for the Burger use case.
class _BurgerDemo extends StatefulWidget {
  @override
  State<_BurgerDemo> createState() => _BurgerDemoState();
}

class _BurgerDemoState extends State<_BurgerDemo> {
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    return PlinthBurger(
      opened: _opened,
      onPressed: () => setState(() => _opened = !_opened),
    );
  }
}

/// Owns the current range for the RangeSlider use case.
class _RangeSliderDemo extends StatefulWidget {
  @override
  State<_RangeSliderDemo> createState() => _RangeSliderDemoState();
}

class _RangeSliderDemoState extends State<_RangeSliderDemo> {
  RangeValues _values = const RangeValues(20, 80);

  @override
  Widget build(BuildContext context) {
    return PlinthRangeSlider(
      values: _values,
      onChanged: (v) => setState(() => _values = v),
    );
  }
}

/// Owns the selected values for the MultiSelect use case.
class _MultiSelectDemo extends StatefulWidget {
  @override
  State<_MultiSelectDemo> createState() => _MultiSelectDemoState();
}

class _MultiSelectDemoState extends State<_MultiSelectDemo> {
  List<String> _value = ['dart'];

  @override
  Widget build(BuildContext context) {
    return PlinthMultiSelect<String>(
      label: 'Skills',
      placeholder: 'Choose skills',
      value: _value,
      onChanged: (v) => setState(() => _value = v),
      options: const [
        PlinthMultiSelectOption('dart', 'Dart'),
        PlinthMultiSelectOption('flutter', 'Flutter'),
        PlinthMultiSelectOption('ui', 'UI Design'),
        PlinthMultiSelectOption('testing', 'Testing'),
      ],
    );
  }
}

/// Owns the entered code for the PinInput use case.
class _PinInputDemo extends StatefulWidget {
  @override
  State<_PinInputDemo> createState() => _PinInputDemoState();
}

class _PinInputDemoState extends State<_PinInputDemo> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    return PlinthPinInput(
      length: 4,
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
