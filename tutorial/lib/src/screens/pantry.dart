/// Part 2 and Part 3 — the pantry list, and the freshness roles that
/// make it readable.
///
/// Nothing in this file names a colour. Every coloured thing on screen
/// comes from either a role (`'fresh'`, `'soon'`, `'expired'`) or the
/// categorical palette, both declared in `larder_theme.dart`.
library;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import '../model.dart';

/// Which slice of the pantry the list is showing.
enum PantryFilter { all, soon, expired }

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key, required this.pantry, required this.now});

  final Pantry pantry;
  final DateTime now;

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final _addModal = PlinthDisclosureController();
  PantryFilter _filter = PantryFilter.all;

  /// The last thing added or removed, spoken by a live region.
  ///
  /// Adding an item changes a list somewhere below the fold and moves no
  /// focus, so without this the whole interaction is silent to a screen
  /// reader — the `F-2` shape, in an app rather than a component.
  String? _lastChange;

  @override
  void dispose() {
    _addModal.dispose();
    super.dispose();
  }

  List<PantryItem> get _visible {
    final all = widget.pantry.sorted(widget.now);
    return switch (_filter) {
      PantryFilter.all => all,
      PantryFilter.soon =>
        all.where((i) => i.freshness(widget.now) == Freshness.soon).toList(),
      PantryFilter.expired =>
        all.where((i) => i.freshness(widget.now) == Freshness.expired).toList(),
    };
  }

  void _add(PantryItem item) {
    widget.pantry.add(item);
    _addModal.close();
    setState(() => _lastChange = '${item.name} added to the pantry');
  }

  void _remove(PantryItem item) {
    widget.pantry.remove(item);
    setState(() => _lastChange = '${item.name} removed from the pantry');
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    final soon = widget.pantry.expiring(widget.now);
    final expired = widget.pantry.expired(widget.now);

    return PlinthModalHost(
      modal: PlinthModal(
        controller: _addModal,
        title: 'Add to the pantry',
        size: PlinthSize.md,
        child: AddIngredientForm(now: widget.now, onAdd: _add),
      ),
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: PlinthTitle('Pantry', order: 2)),
              PlinthButton(
                onPressed: _addModal.open,
                leadingIcon: const Icon(Icons.add),
                child: const Text('Add item'),
              ),
            ],
          ),
          const PlinthSpace(h: PlinthSize.md),

          // A standing banner, so `live: false`. It is part of the page
          // rather than an event — announcing it on arrival would say
          // the same thing the list below is about to say anyway.
          if (expired.isNotEmpty || soon.isNotEmpty) ...[
            PlinthAlert(
              title: _bannerTitle(soon.length, expired.length),
              color: expired.isEmpty
                  ? context.plinth.roleFor('soon').ramp
                  : context.plinth.roleFor('expired').ramp,
              icon: const Icon(Icons.schedule),
              live: false,
              child: Text(_bannerBody(soon, expired)),
            ),
            const PlinthSpace(h: PlinthSize.md),
          ],

          FreshnessSummary(pantry: widget.pantry, now: widget.now),
          const PlinthSpace(h: PlinthSize.lg),

          PlinthSegmentedControl<PantryFilter>(
            value: _filter,
            onChanged: (value) => setState(() => _filter = value),
            fullWidth: true,
            items: [
              const PlinthSegmentedControlItem(
                PantryFilter.all,
                'Everything',
              ),
              PlinthSegmentedControlItem(
                PantryFilter.soon,
                'Use soon (${soon.length})',
              ),
              PlinthSegmentedControlItem(
                PantryFilter.expired,
                'Expired (${expired.length})',
              ),
            ],
          ),
          const PlinthSpace(h: PlinthSize.md),

          // The live region wraps the list, so the message is spoken
          // when it changes and the list stays where it is. Pass the
          // message as well as the widget: a live region with nothing
          // in it is a node a reader visits to hear silence.
          PlinthLiveRegion(
            message: _lastChange,
            child: items.isEmpty
                ? PlinthEmptyState(
                    title: _emptyTitle(),
                    description: 'Nothing in this slice of the pantry.',
                    icon: const Icon(Icons.inventory_2_outlined),
                    action: PlinthButton(
                      onPressed: () =>
                          setState(() => _filter = PantryFilter.all),
                      variant: PlinthVariant.light,
                      child: const Text('Show everything'),
                    ),
                  )
                : PlinthPaper(
                    p: PlinthSize.xs,
                    withBorder: true,
                    child: Column(
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0) const PlinthDivider(),
                          PantryRow(
                            item: items[i],
                            now: widget.now,
                            onRemove: () => _remove(items[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
          const PlinthSpace(h: PlinthSize.xl),
        ],
      ),
    );
  }

  String _emptyTitle() => switch (_filter) {
        PantryFilter.all => 'The pantry is empty',
        PantryFilter.soon => 'Nothing needs using up',
        PantryFilter.expired => 'Nothing has gone off',
      };

  static String _bannerTitle(int soon, int expired) {
    if (expired > 0 && soon > 0) {
      return '$expired past its date, $soon to use soon';
    }
    if (expired > 0) {
      return '$expired item${expired == 1 ? '' : 's'} past its date';
    }
    return '$soon item${soon == 1 ? '' : 's'} to use in the next few days';
  }

  static String _bannerBody(List<PantryItem> soon, List<PantryItem> expired) {
    final names = [...expired, ...soon].map((i) => i.name).toList();
    if (names.length == 1) {
      return '${names.single}. Suggestions will put it first.';
    }
    return '${names.join(', ')}. Suggestions will put them first.';
  }
}

/// The fresh / use-soon / expired split as one part-to-whole bar.
///
/// `PlinthProgress.sections` rather than three bars: the sections are
/// fractions of the *whole*, which is exactly what "how much of the
/// pantry is in trouble" means.
class FreshnessSummary extends StatelessWidget {
  const FreshnessSummary({super.key, required this.pantry, required this.now});

  final Pantry pantry;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final items = pantry.items;
    if (items.isEmpty) return const SizedBox.shrink();

    int count(Freshness state) =>
        items.where((i) => i.freshness(now) == state).length;

    final fresh = count(Freshness.fresh);
    final soon = count(Freshness.soon);
    final expired = count(Freshness.expired);
    final total = items.length;

    return PlinthCard(
      withBorder: true,
      child: PlinthStack(
        gap: PlinthSize.sm,
        children: [
          Row(
            children: [
              const PlinthText('Condition of the pantry',
                  weight: FontWeight.w600),
              const Spacer(),
              PlinthText('$total items', color: 'gray'),
            ],
          ),
          PlinthProgress.sections(
            size: PlinthSize.lg,
            sections: [
              if (fresh > 0)
                PlinthProgressSection(
                  value: fresh / total,
                  color: theme.roleFor('fresh').ramp,
                  label: '$fresh fresh',
                ),
              if (soon > 0)
                PlinthProgressSection(
                  value: soon / total,
                  color: theme.roleFor('soon').ramp,
                  label: '$soon to use soon',
                ),
              if (expired > 0)
                PlinthProgressSection(
                  value: expired / total,
                  color: theme.roleFor('expired').ramp,
                  label: '$expired expired',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One line of the pantry.
class PantryRow extends StatelessWidget {
  const PantryRow({
    super.key,
    required this.item,
    required this.now,
    required this.onRemove,
  });

  final PantryItem item;
  final DateTime now;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final state = item.freshness(now);
    final days = item.daysLeft(now);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PlinthSpacing.sm,
        vertical: PlinthSpacing.xs,
      ),
      child: Row(
        children: [
          // The shelf's colour comes from a *name*. `model.dart` has no
          // theme and no BuildContext, so a Color could never have come
          // from there — a key can.
          Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
              color: theme.seriesFor(item.category.name),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const PlinthSpace(w: PlinthSize.sm),
          Expanded(
            flex: 3,
            child: PlinthStack(
              gap: PlinthSize.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlinthText(item.name, weight: FontWeight.w500),
                PlinthText(
                  item.category.label,
                  size: PlinthSize.xs,
                  color: 'gray',
                ),
              ],
            ),
          ),
          Expanded(
            child: PlinthText(item.amount, color: 'gray'),
          ),
          Expanded(
            flex: 2,
            child: FreshnessLabel(state: state, days: days),
          ),
          PlinthActionIcon(
            icon: const Icon(Icons.close),
            onPressed: onRemove,
            variant: PlinthVariant.subtle,
            size: PlinthSize.sm,
            // Without this every remove button in the list announces as
            // "button" and nothing else, which is 14 identical buttons.
            semanticLabel: 'Remove ${item.name}',
          ),
        ],
      ),
    );
  }
}

/// The freshness state as a word and a colour, never a colour alone.
///
/// WCAG 1.4.1: colour cannot be the only channel. The tint says it
/// quickly, the text says it at all.
class FreshnessLabel extends StatelessWidget {
  const FreshnessLabel({super.key, required this.state, required this.days});

  final Freshness state;
  final int? days;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PlinthSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        // A wash, not shade 0: mirrored for a dark theme, the lightest
        // shade becomes the most saturated one, and a "barely tinted
        // row" turns into a saturated panel.
        color: theme.semanticWash(state.role),
        borderRadius: BorderRadius.circular(theme.radius[PlinthSize.sm]!),
      ),
      child: Text(
        _text(),
        style: TextStyle(
          // Not `semantic(role)`. The fill colour of "use soon" is amber
          // at 1.86:1 on white — visible, unreadable. This walks the
          // ramp until it clears 4.5:1 against the surface behind it.
          color: theme.semanticText(state.role),
          fontSize: theme.fontSizes[PlinthSize.xs],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _text() {
    if (days == null) return 'Keeps';
    return switch (state) {
      Freshness.expired =>
        days == -1 ? 'Expired yesterday' : 'Expired ${-days!} days ago',
      Freshness.soon => switch (days!) {
          0 => 'Today',
          1 => 'Tomorrow',
          _ => 'In $days days',
        },
      Freshness.fresh => 'In $days days',
    };
  }
}

/// The add form, in a modal.
class AddIngredientForm extends StatefulWidget {
  const AddIngredientForm({super.key, required this.now, required this.onAdd});

  final DateTime now;
  final ValueChanged<PantryItem> onAdd;

  @override
  State<AddIngredientForm> createState() => _AddIngredientFormState();
}

class _AddIngredientFormState extends State<AddIngredientForm> {
  final _name = TextEditingController();
  final _unit = TextEditingController(text: 'g');
  PantryCategory _category = PantryCategory.produce;
  num _quantity = 100;
  num _keepsFor = 7;
  bool _perishable = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      // The error text is the live region — the field's own label is
      // not, so a message appearing beneath it moves no focus and would
      // otherwise be spoken by nothing at all.
      setState(() => _error = 'Give it a name so you can find it again');
      return;
    }
    widget.onAdd(
      PantryItem(
        name: name,
        category: _category,
        quantity: _quantity.toDouble(),
        unit: _unit.text.trim(),
        expiresOn: _perishable
            ? widget.now.add(Duration(days: _keepsFor.toInt()))
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlinthStack(
      gap: PlinthSize.md,
      children: [
        PlinthTextInput(
          label: 'Name',
          placeholder: 'Flour',
          controller: _name,
          error: _error,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PlinthNumberInput(
                label: 'Quantity',
                value: _quantity,
                min: 1,
                step: 50,
                onChanged: (value) => setState(() => _quantity = value),
              ),
            ),
            const PlinthSpace(w: PlinthSize.sm),
            Expanded(
              child: PlinthTextInput(
                label: 'Unit',
                placeholder: 'g',
                controller: _unit,
              ),
            ),
          ],
        ),
        PlinthSelect<PantryCategory>(
          label: 'Shelf',
          value: _category,
          onChanged: (value) => setState(() => _category = value ?? _category),
          options: [
            for (final category in PantryCategory.values)
              PlinthSelectOption(category, category.label),
          ],
        ),
        PlinthSwitch(
          value: _perishable,
          onChanged: (value) => setState(() => _perishable = value),
          label: 'This goes off',
          description: 'Turn it off for salt, rice, anything that keeps.',
        ),
        if (_perishable)
          PlinthNumberInput(
            label: 'Good for (days)',
            value: _keepsFor,
            min: 0,
            max: 730,
            onChanged: (value) => setState(() => _keepsFor = value),
          ),
        PlinthGroup(
          wrap: false,
          grow: true,
          children: [
            PlinthButton(
              onPressed: _submit,
              fullWidth: true,
              child: const Text('Add to pantry'),
            ),
          ],
        ),
      ],
    );
  }
}
