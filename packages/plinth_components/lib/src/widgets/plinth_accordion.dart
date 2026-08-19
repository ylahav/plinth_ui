import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A single collapsible entry in a [PlinthAccordion].
class PlinthAccordionItem {
  const PlinthAccordionItem({
    required this.value,
    required this.title,
    required this.content,
    this.icon,
  });

  /// Unique identifier for this item, used to track open/closed state.
  final String value;
  final String title;
  final Widget content;
  final Widget? icon;
}

/// An expandable/collapsible list matching Mantine's `Accordion`.
///
/// By default only one item can be open at a time (matching
/// Mantine's default); pass [multiple] to allow several open
/// simultaneously. Manages its own open/closed state internally —
/// unlike the overlay components, there's no external controller to
/// wire up, since an accordion's expanded set is presentation state
/// specific to this widget rather than something another part of the
/// UI needs to react to.
///
/// ```dart
/// PlinthAccordion(
///   items: [
///     PlinthAccordionItem(
///       value: 'shipping',
///       title: 'Shipping details',
///       content: const Text('Ships within 3-5 business days.'),
///     ),
///     PlinthAccordionItem(
///       value: 'returns',
///       title: 'Return policy',
///       content: const Text('30-day returns, no questions asked.'),
///     ),
///   ],
/// )
/// ```
class PlinthAccordion extends StatefulWidget {
  const PlinthAccordion({
    super.key,
    required this.items,
    this.multiple = false,
    this.initiallyOpen = const {},
    this.color,
  });

  final List<PlinthAccordionItem> items;

  /// If true, more than one item can be expanded at once. If false
  /// (default), opening an item closes any other open item.
  final bool multiple;

  /// Values (matching [PlinthAccordionItem.value]) that start expanded.
  final Set<String> initiallyOpen;

  final String? color;

  @override
  State<PlinthAccordion> createState() => _PlinthAccordionState();
}

class _PlinthAccordionState extends State<PlinthAccordion> {
  // `late` is required here, not just stylistic: a plain field
  // initializer runs during State's constructor, before the
  // framework has assigned `widget` — accessing widget.initiallyOpen
  // there would fail. `late` defers evaluation to first access
  // (i.e. build()), by which point `widget` is safely available.
  late Set<String> _openValues = Set.of(widget.initiallyOpen);

  void _toggle(String value) {
    setState(() {
      final isOpen = _openValues.contains(value);
      if (widget.multiple) {
        isOpen ? _openValues.remove(value) : _openValues.add(value);
      } else {
        _openValues = isOpen ? {} : {value};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = widget.color ?? theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in widget.items)
          _AccordionTile(
            item: item,
            isOpen: _openValues.contains(item.value),
            onTap: () => _toggle(item.value),
            colorKey: colorKey,
          ),
      ],
    );
  }
}

class _AccordionTile extends StatelessWidget {
  const _AccordionTile({
    required this.item,
    required this.isOpen,
    required this.onTap,
    required this.colorKey,
  });

  final PlinthAccordionItem item;
  final bool isOpen;
  final VoidCallback onTap;
  final String colorKey;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.surfaceSunken)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            // The probe found the trigger labelled but roleless, so it
            // announced as text: reachable, tappable, and giving no
            // clue that it is a control or that it opens something.
            expanded: isOpen,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing[PlinthSize.sm]!,
                  vertical: theme.spacing[PlinthSize.sm]!,
                ),
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      item.icon!,
                      SizedBox(width: theme.spacing[PlinthSize.xs]!),
                    ],
                    Expanded(
                      child: PlinthText(item.title, weight: FontWeight.w600),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(Icons.keyboard_arrow_down, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Deliberately *not* PlinthCollapse. That keeps its child
          // mounted so state survives, which is right for a filter
          // panel but wrong here: an accordion holds page content, and
          // a closed panel should leave the tree entirely rather than
          // linger as something a screen reader can still reach.
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: isOpen
                ? Padding(
                    padding: EdgeInsets.only(
                      left: theme.spacing[PlinthSize.sm]!,
                      right: theme.spacing[PlinthSize.sm]!,
                      bottom: theme.spacing[PlinthSize.sm]!,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: item.content,
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}
