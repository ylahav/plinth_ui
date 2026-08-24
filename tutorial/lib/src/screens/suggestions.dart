/// Part 4 — what can actually be cooked, ranked.
///
/// The screen where the pantry stops being a list and starts being an
/// answer. Each card says three things: can you cook it, what is
/// missing, and whether cooking it rescues anything.
library;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import '../model.dart';

enum SuggestionFilter { cookable, close, all }

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({
    super.key,
    required this.matches,
    required this.now,
    required this.onCook,
  });

  final List<RecipeMatch> matches;
  final DateTime now;
  final ValueChanged<RecipeMatch> onCook;

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  SuggestionFilter _filter = SuggestionFilter.all;

  List<RecipeMatch> get _visible => switch (_filter) {
        SuggestionFilter.cookable =>
          widget.matches.where((m) => m.canCook).toList(),
        SuggestionFilter.close => widget.matches
            .where((m) => !m.canCook && m.missing.length <= 1)
            .toList(),
        SuggestionFilter.all => widget.matches,
      };

  @override
  Widget build(BuildContext context) {
    final cookable = widget.matches.where((m) => m.canCook).length;
    final close =
        widget.matches.where((m) => !m.canCook && m.missing.length <= 1).length;
    final visible = _visible;

    return ListView(
      children: [
        const PlinthTitle('Suggestions', order: 2),
        const PlinthSpace(h: PlinthSize.xs),
        PlinthText(
          _headline(cookable, close),
          color: 'gray',
        ),
        const PlinthSpace(h: PlinthSize.md),
        PlinthSegmentedControl<SuggestionFilter>(
          value: _filter,
          onChanged: (value) => setState(() => _filter = value),
          fullWidth: true,
          items: [
            PlinthSegmentedControlItem(
              SuggestionFilter.cookable,
              'Can cook now ($cookable)',
            ),
            PlinthSegmentedControlItem(
              SuggestionFilter.close,
              'One thing short ($close)',
            ),
            PlinthSegmentedControlItem(
              SuggestionFilter.all,
              'Everything (${widget.matches.length})',
            ),
          ],
        ),
        const PlinthSpace(h: PlinthSize.lg),
        if (visible.isEmpty)
          PlinthEmptyState(
            title: 'Nothing here',
            description: 'No recipe fits that filter with what is in the '
                'house right now.',
            icon: const Icon(Icons.restaurant_menu_outlined),
            action: PlinthButton(
              onPressed: () => setState(() => _filter = SuggestionFilter.all),
              variant: PlinthVariant.light,
              child: const Text('Show everything'),
            ),
          )
        else
          PlinthSimpleGrid(
            columns: 1,
            minColWidth: 360,
            spacing: PlinthSize.md,
            children: [
              for (final match in visible)
                RecipeCard(
                  match: match,
                  now: widget.now,
                  onCook: () => widget.onCook(match),
                ),
            ],
          ),
        const PlinthSpace(h: PlinthSize.xl),
      ],
    );
  }

  static String _headline(int cookable, int close) {
    if (cookable == 0 && close == 0) {
      return 'Nothing is cookable yet. Add a few staples to the pantry.';
    }
    if (cookable == 0) {
      return '$close recipe${close == 1 ? ' is' : 's are'} one ingredient '
          'short.';
    }
    return '$cookable ready to cook, ordered to use up what expires first.';
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.match,
    required this.now,
    required this.onCook,
  });

  final RecipeMatch match;
  final DateTime now;
  final VoidCallback onCook;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final recipe = match.recipe;
    final urgent = match.urgentCount(now);

    return PlinthCard(
      withBorder: true,
      header: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PlinthStack(
              gap: PlinthSize.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlinthTitle(recipe.name, order: 4),
                PlinthGroup(
                  gap: PlinthSize.xs,
                  children: [
                    PlinthBadge(
                      '${recipe.minutes} min',
                      variant: PlinthVariant.light,
                      size: PlinthSize.xs,
                    ),
                    PlinthBadge(
                      'serves ${recipe.serves}',
                      variant: PlinthVariant.light,
                      size: PlinthSize.xs,
                    ),
                    if (urgent > 0)
                      PlinthBadge(
                        'uses $urgent to use up',
                        color: theme.roleFor('soon').ramp,
                        size: PlinthSize.xs,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const PlinthSpace(w: PlinthSize.sm),
          CoverageRing(match: match),
        ],
      ),
      footer: PlinthGroup(
        wrap: false,
        children: [
          Expanded(
            child: PlinthButton(
              // A null callback disables it, Flutter's own convention,
              // and the library makes that visible rather than leaving
              // a full-strength button that does nothing.
              onPressed: match.canCook ? onCook : null,
              fullWidth: true,
              leadingIcon: const Icon(Icons.local_fire_department_outlined),
              child: Text(match.canCook ? 'Cook this' : 'Missing ingredients'),
            ),
          ),
        ],
      ),
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthText(recipe.summary, size: PlinthSize.sm, color: 'gray'),
          if (match.missing.isNotEmpty)
            MissingList(missing: match.missing)
          else
            PlinthGroup(
              gap: PlinthSize.xs,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: theme.semanticText('fresh'),
                ),
                PlinthText(
                  'Everything is in the house',
                  size: PlinthSize.sm,
                  color: theme.roleFor('fresh').ramp,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// How much of the ingredient list the pantry covers.
class CoverageRing extends StatelessWidget {
  const CoverageRing({super.key, required this.match});

  final RecipeMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final have = match.have.length;
    final total = match.recipe.needs.length;

    return PlinthRingProgress(
      value: match.coverage,
      diameter: 56,
      thickness: 6,
      color: match.canCook
          ? theme.roleFor('fresh').ramp
          : theme.roleFor('soon').ramp,
      label: PlinthText(
        '$have/$total',
        size: PlinthSize.xs,
        weight: FontWeight.w600,
      ),
    );
  }
}

class MissingList extends StatelessWidget {
  const MissingList({super.key, required this.missing});

  final List<RecipeNeed> missing;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return PlinthGroup(
      gap: PlinthSize.xs,
      children: [
        Icon(
          Icons.remove_shopping_cart_outlined,
          size: 16,
          color: theme.semanticText('expired'),
        ),
        for (final need in missing)
          PlinthBadge(
            '${need.name} · ${need.amount}',
            variant: PlinthVariant.outline,
            color: theme.roleFor('expired').ramp,
            size: PlinthSize.xs,
          ),
      ],
    );
  }
}
