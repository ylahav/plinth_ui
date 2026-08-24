/// Larder — what is in the house, what to cook, and how to cook it.
///
/// The app built step by step in `docs/TUTORIAL_LARDER_APP.md`. Start
/// there; this file is Part 1 and Part 6.
library;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import 'src/data.dart';
import 'src/larder_theme.dart';
import 'src/model.dart';
import 'src/screens/cook.dart';
import 'src/screens/pantry.dart';
import 'src/screens/suggestions.dart';

void main() => runApp(const LarderApp());

class LarderApp extends StatefulWidget {
  const LarderApp({super.key});

  @override
  State<LarderApp> createState() => _LarderAppState();
}

class _LarderAppState extends State<LarderApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Larder',
      debugShowCheckedModeBanner: false,
      theme: larderThemeData(larderLight),
      darkTheme: larderThemeData(larderDark),
      themeMode: _mode,
      home: LarderHome(
        dark: _mode == ThemeMode.dark,
        onDarkChanged: (value) => setState(
          () => _mode = value ? ThemeMode.dark : ThemeMode.light,
        ),
      ),
    );
  }
}

/// Which screen is showing.
enum LarderView { pantry, suggestions, cook }

class LarderHome extends StatefulWidget {
  const LarderHome({
    super.key,
    required this.dark,
    required this.onDarkChanged,
  });

  final bool dark;
  final ValueChanged<bool> onDarkChanged;

  @override
  State<LarderHome> createState() => _LarderHomeState();
}

class _LarderHomeState extends State<LarderHome> {
  /// One clock for the whole app, captured at launch.
  ///
  /// Every freshness decision reads this rather than `DateTime.now()`,
  /// so a rebuild cannot quietly move an item from "use soon" to
  /// "expired" halfway through a frame — and a test can hand the same
  /// screens a different Tuesday.
  final DateTime _now = DateTime.now();

  late final Pantry _pantry = Pantry(seedPantry(_now));

  LarderView _view = LarderView.pantry;

  /// The recipe being cooked, if any. Set by the suggestions screen and
  /// cleared when cooking finishes.
  RecipeMatch? _cooking;

  @override
  void initState() {
    super.initState();
    _pantry.addListener(_onPantryChanged);
  }

  @override
  void dispose() {
    _pantry.removeListener(_onPantryChanged);
    _pantry.dispose();
    super.dispose();
  }

  void _onPantryChanged() => setState(() {});

  List<RecipeMatch> get _matches =>
      rankRecipes(recipeBook, _pantry, _now).toList();

  void _startCooking(RecipeMatch match) => setState(() {
        _cooking = match;
        _view = LarderView.cook;
      });

  void _finishCooking(RecipeMatch match) {
    _pantry.consume(match);
    setState(() {
      _cooking = null;
      _view = LarderView.pantry;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expiring =
        _pantry.expiring(_now).length + _pantry.expired(_now).length;
    final cookable = _matches.where((m) => m.canCook).length;

    return Scaffold(
      body: PlinthAppShell(
        headerHeight: 64,
        navbarWidth: 240,
        withBorder: true,
        header: _Header(
          dark: widget.dark,
          onDarkChanged: widget.onDarkChanged,
        ),
        navbar: _Navbar(
          view: _view,
          onView: (view) => setState(() => _view = view),
          expiringCount: expiring,
          cookableCount: cookable,
          cooking: _cooking,
        ),
        padding: PlinthSize.lg,
        child: switch (_view) {
          LarderView.pantry => PantryScreen(pantry: _pantry, now: _now),
          LarderView.suggestions => SuggestionsScreen(
              matches: _matches,
              now: _now,
              onCook: _startCooking,
            ),
          LarderView.cook => _cooking == null
              ? const _NothingCooking()
              : CookScreen(
                  match: _cooking!,
                  onDone: () => _finishCooking(_cooking!),
                  onAbandon: () => setState(() {
                    _cooking = null;
                    _view = LarderView.suggestions;
                  }),
                ),
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dark, required this.onDarkChanged});

  final bool dark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PlinthSpacing.lg),
      child: Row(
        children: [
          PlinthThemeIcon(
            icon: const Icon(Icons.kitchen_outlined),
            color: theme.primaryColor,
            size: PlinthSize.md,
          ),
          const PlinthSpace(w: PlinthSize.sm),
          const PlinthTitle('Larder', order: 4),
          const Spacer(),
          PlinthSwitch(
            value: dark,
            onChanged: onDarkChanged,
            label: 'Dark',
            size: PlinthSize.sm,
          ),
        ],
      ),
    );
  }
}

class _Navbar extends StatelessWidget {
  const _Navbar({
    required this.view,
    required this.onView,
    required this.expiringCount,
    required this.cookableCount,
    required this.cooking,
  });

  final LarderView view;
  final ValueChanged<LarderView> onView;
  final int expiringCount;
  final int cookableCount;
  final RecipeMatch? cooking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PlinthSpacing.sm),
      child: PlinthStack(
        gap: PlinthSize.xs,
        children: [
          PlinthNavLink(
            label: 'Pantry',
            leadingIcon: const Icon(Icons.inventory_2_outlined),
            active: view == LarderView.pantry,
            onTap: () => onView(LarderView.pantry),
            trailing: expiringCount == 0
                ? null
                // The badge colour is a *role*, not a hue: this is the
                // same 'soon' that paints every row on the pantry
                // screen, so the two can never drift apart.
                : PlinthBadge(
                    '$expiringCount',
                    color: context.plinth.roleFor('soon').ramp,
                    size: PlinthSize.xs,
                  ),
          ),
          PlinthNavLink(
            label: 'Suggestions',
            leadingIcon: const Icon(Icons.restaurant_menu_outlined),
            active: view == LarderView.suggestions,
            onTap: () => onView(LarderView.suggestions),
            trailing: PlinthBadge(
              '$cookableCount',
              variant: PlinthVariant.light,
              size: PlinthSize.xs,
            ),
          ),
          if (cooking != null)
            // The recipe name goes in the label, not in `trailing`.
            // `label` is the flexible child of the link's row and
            // `trailing` is not, so anything longer than a count put
            // there overflows a 240px navbar rather than wrapping.
            PlinthNavLink(
              label: cooking!.recipe.name,
              leadingIcon: const Icon(Icons.local_fire_department_outlined),
              active: view == LarderView.cook,
              onTap: () => onView(LarderView.cook),
            ),
        ],
      ),
    );
  }
}

class _NothingCooking extends StatelessWidget {
  const _NothingCooking();

  @override
  Widget build(BuildContext context) {
    return const PlinthEmptyState(
      title: 'Nothing on the stove',
      description: 'Pick something from Suggestions and it will show up here.',
      icon: Icon(Icons.local_fire_department_outlined),
    );
  }
}
