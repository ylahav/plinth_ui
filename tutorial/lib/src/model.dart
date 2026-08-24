/// Larder's domain: what is in the house, what can be cooked from it,
/// and how far through cooking it you are.
///
/// Deliberately plain Dart — no Flutter import, no `BuildContext`, no
/// colours. Part 3 of the tutorial leans on that: the layer that knows a
/// jar of chickpeas expires on Tuesday has no business knowing what
/// colour "expiring" is, and `PlinthTheme` is what carries a *name*
/// across that boundary instead of a `Color`.
library;

import 'package:flutter/foundation.dart' show ChangeNotifier;

/// What shelf something lives on.
///
/// Also the key the categorical palette is asked for, via
/// `theme.seriesFor(category.name)` — a name crosses the boundary above,
/// a colour cannot.
enum PantryCategory {
  produce('Produce'),
  dairy('Dairy'),
  protein('Protein'),
  grain('Grains'),
  pantry('Pantry'),
  spice('Spices');

  const PantryCategory(this.label);

  final String label;
}

/// How urgent a pantry item is, which is the whole reason the app has a
/// semantic colour tier at all.
///
/// Three states, three role names, and **not** three hardcoded colours:
/// `fresh`, `soon` and `expired` are declared once in `larder_theme.dart`
/// and resolved per theme.
enum Freshness {
  fresh('fresh', 'Fresh'),
  soon('soon', 'Use soon'),
  expired('expired', 'Expired');

  const Freshness(this.role, this.label);

  /// The semantic role this maps to. Matches a key in the theme's
  /// `semanticColors`.
  final String role;

  final String label;
}

/// Something in the house, in a quantity, going off on a date.
class PantryItem {
  const PantryItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiresOn,
  });

  final String name;
  final PantryCategory category;
  final double quantity;
  final String unit;

  /// Null for things that do not meaningfully expire — salt, rice.
  final DateTime? expiresOn;

  /// Days until this goes off, negative once it has.
  ///
  /// Takes [now] rather than reading the clock, so the freshness rules
  /// are testable without waiting three days to see what happens.
  int? daysLeft(DateTime now) {
    final date = expiresOn;
    if (date == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    return due.difference(today).inDays;
  }

  Freshness freshness(DateTime now) {
    final days = daysLeft(now);
    if (days == null) return Freshness.fresh;
    if (days < 0) return Freshness.expired;
    if (days <= 3) return Freshness.soon;
    return Freshness.fresh;
  }

  /// `2 tbsp`, `1.5 kg`, `3 eggs` — trailing `.0` dropped, because
  /// "1.0 onion" reads like a rounding error.
  String get amount {
    final whole = quantity == quantity.roundToDouble();
    final number = whole ? quantity.toStringAsFixed(0) : quantity.toString();
    return unit.isEmpty ? number : '$number $unit';
  }

  PantryItem copyWith({double? quantity, DateTime? expiresOn}) => PantryItem(
        name: name,
        category: category,
        quantity: quantity ?? this.quantity,
        unit: unit,
        expiresOn: expiresOn ?? this.expiresOn,
      );
}

/// One line of a recipe's ingredient list.
class RecipeNeed {
  const RecipeNeed(this.name, this.quantity, this.unit);

  final String name;
  final double quantity;
  final String unit;

  String get amount {
    final whole = quantity == quantity.roundToDouble();
    final number = whole ? quantity.toStringAsFixed(0) : quantity.toString();
    return unit.isEmpty ? number : '$number $unit';
  }
}

/// One instruction, and optionally how long it takes.
class RecipeStep {
  const RecipeStep(this.instruction, {this.minutes});

  final String instruction;

  /// Minutes this step takes unattended — a simmer, a rest, a bake.
  /// Null for "chop the onion", which takes as long as it takes.
  final int? minutes;
}

class Recipe {
  const Recipe({
    required this.name,
    required this.summary,
    required this.serves,
    required this.minutes,
    required this.needs,
    required this.steps,
  });

  final String name;
  final String summary;
  final int serves;
  final int minutes;
  final List<RecipeNeed> needs;
  final List<RecipeStep> steps;
}

/// A recipe measured against what is actually in the house.
class RecipeMatch {
  const RecipeMatch({
    required this.recipe,
    required this.have,
    required this.missing,
    required this.uses,
  });

  final Recipe recipe;

  /// Needs the pantry can cover.
  final List<RecipeNeed> have;

  /// Needs it cannot.
  final List<RecipeNeed> missing;

  /// The pantry items this recipe would use up, in the order the
  /// ingredient list names them. Drives the "uses two things that are
  /// about to go off" ranking.
  final List<PantryItem> uses;

  bool get canCook => missing.isEmpty;

  /// 0.0 to 1.0 — what fraction of the ingredient list is covered.
  double get coverage =>
      recipe.needs.isEmpty ? 1 : have.length / recipe.needs.length;

  /// How many of the items it uses are expired or nearly so.
  int urgentCount(DateTime now) => uses
      .where((item) => item.freshness(now) != Freshness.fresh)
      .where((item) => item.freshness(now) != Freshness.expired)
      .length;

  /// True if cooking this would use something already past its date,
  /// which is a reason *not* to suggest it.
  bool usesExpired(DateTime now) =>
      uses.any((item) => item.freshness(now) == Freshness.expired);
}

/// The pantry, and the only mutable state in the app.
///
/// A plain `ChangeNotifier` on purpose: the tutorial is about the UI
/// layer, and reaching for a state-management package would put a second
/// thing to learn in front of the thing being taught.
class Pantry extends ChangeNotifier {
  Pantry(List<PantryItem> initial) : _items = [...initial];

  final List<PantryItem> _items;

  List<PantryItem> get items => List.unmodifiable(_items);

  /// Everything, sorted by urgency then by name — the order the pantry
  /// screen shows, and the order that puts what matters at the top.
  List<PantryItem> sorted(DateTime now) {
    final copy = [..._items];
    copy.sort((a, b) {
      final byUrgency =
          a.freshness(now).index.compareTo(b.freshness(now).index);
      if (byUrgency != 0) return -byUrgency;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return copy;
  }

  List<PantryItem> expiring(DateTime now) => _items
      .where((item) => item.freshness(now) == Freshness.soon)
      .toList(growable: false);

  List<PantryItem> expired(DateTime now) => _items
      .where((item) => item.freshness(now) == Freshness.expired)
      .toList(growable: false);

  /// Adds an item, merging quantities when the same thing is already
  /// there. Two half-jars of tahini are one jar of tahini.
  void add(PantryItem item) {
    final index = _items.indexWhere(
      (existing) =>
          existing.name.toLowerCase() == item.name.toLowerCase() &&
          existing.unit == item.unit,
    );
    if (index == -1) {
      _items.add(item);
    } else {
      final merged = _items[index];
      _items[index] = merged.copyWith(
        quantity: merged.quantity + item.quantity,
        // The sooner of the two dates: the older half is what will
        // spoil, and claiming the later date would hide it.
        expiresOn: _sooner(merged.expiresOn, item.expiresOn),
      );
    }
    notifyListeners();
  }

  void remove(PantryItem item) {
    _items.removeWhere(
      (existing) => existing.name == item.name && existing.unit == item.unit,
    );
    notifyListeners();
  }

  /// Deducts everything a cooked recipe used, dropping anything that
  /// reaches zero.
  void consume(RecipeMatch match) {
    for (final need in match.have) {
      final index = _items.indexWhere(
        (item) => item.name.toLowerCase() == need.name.toLowerCase(),
      );
      if (index == -1) continue;
      final left = _items[index].quantity - need.quantity;
      if (left <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: left);
      }
    }
    notifyListeners();
  }

  static DateTime? _sooner(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }
}

/// Ranks a recipe book against a pantry.
///
/// The ordering is the app's one piece of real opinion: cookable first,
/// then whichever uses the most food that is about to go off, then the
/// best-covered, then the quickest. "You can cook this" beats "this
/// rescues two things", because a suggestion you cannot act on is not a
/// suggestion.
List<RecipeMatch> rankRecipes(
  List<Recipe> book,
  Pantry pantry,
  DateTime now,
) {
  final matches = book.map((recipe) => _match(recipe, pantry)).toList();

  matches.sort((a, b) {
    if (a.canCook != b.canCook) return a.canCook ? -1 : 1;
    final urgency = b.urgentCount(now).compareTo(a.urgentCount(now));
    if (urgency != 0) return urgency;
    final coverage = b.coverage.compareTo(a.coverage);
    if (coverage != 0) return coverage;
    return a.recipe.minutes.compareTo(b.recipe.minutes);
  });

  return matches;
}

RecipeMatch _match(Recipe recipe, Pantry pantry) {
  final have = <RecipeNeed>[];
  final missing = <RecipeNeed>[];
  final uses = <PantryItem>[];

  for (final need in recipe.needs) {
    final index = pantry.items.indexWhere(
      (item) =>
          item.name.toLowerCase() == need.name.toLowerCase() &&
          item.quantity >= need.quantity,
    );
    if (index == -1) {
      missing.add(need);
    } else {
      have.add(need);
      uses.add(pantry.items[index]);
    }
  }

  return RecipeMatch(
    recipe: recipe,
    have: have,
    missing: missing,
    uses: uses,
  );
}
