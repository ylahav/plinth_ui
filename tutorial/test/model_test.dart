// The rules that decide what is urgent and what to cook, tested against
// a fixed Tuesday rather than the clock.
//
// This is why `daysLeft` and `freshness` take a `now` instead of calling
// `DateTime.now()` themselves: a rule about time that reads the clock
// can only be tested by waiting.
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_tutorial/src/data.dart';
import 'package:plinth_tutorial/src/model.dart';

final _tuesday = DateTime(2026, 8, 25, 9);

PantryItem _item(String name, {int? days, double quantity = 100}) => PantryItem(
      name: name,
      category: PantryCategory.produce,
      quantity: quantity,
      unit: 'g',
      expiresOn: days == null ? null : _tuesday.add(Duration(days: days)),
    );

void main() {
  group('freshness', () {
    test('something with no date always keeps', () {
      expect(_item('Salt').freshness(_tuesday), Freshness.fresh);
      expect(_item('Salt').daysLeft(_tuesday), isNull);
    });

    test('three days out is still "use soon", four is fresh', () {
      expect(_item('Yoghurt', days: 3).freshness(_tuesday), Freshness.soon);
      expect(_item('Yoghurt', days: 4).freshness(_tuesday), Freshness.fresh);
    });

    test('today counts as "use soon", not expired', () {
      expect(_item('Spinach', days: 0).freshness(_tuesday), Freshness.soon);
    });

    test('yesterday is expired', () {
      expect(
          _item('Coriander', days: -1).freshness(_tuesday), Freshness.expired);
    });

    test('the boundary is the date, not the hour', () {
      // Expiring later today is still today. A comparison on raw
      // DateTimes would call this expired at 09:01.
      final item = PantryItem(
        name: 'Milk',
        category: PantryCategory.dairy,
        quantity: 1,
        unit: 'l',
        expiresOn: DateTime(2026, 8, 25, 8),
      );
      expect(item.daysLeft(_tuesday), 0);
      expect(item.freshness(_tuesday), Freshness.soon);
    });
  });

  group('the pantry', () {
    test('adding the same thing twice merges the quantities', () {
      final pantry = Pantry([_item('Flour', quantity: 250)]);
      pantry.add(_item('Flour', quantity: 250));

      expect(pantry.items, hasLength(1));
      expect(pantry.items.single.quantity, 500);
    });

    test('a merge keeps the sooner date, not the later one', () {
      // The older half is what will spoil. Claiming the later date
      // would hide it.
      final pantry = Pantry([_item('Yoghurt', days: 2)]);
      pantry.add(_item('Yoghurt', days: 30));

      expect(pantry.items.single.freshness(_tuesday), Freshness.soon);
    });

    test('different units stay separate', () {
      final pantry = Pantry([_item('Milk', quantity: 1)]);
      pantry.add(
        const PantryItem(
          name: 'Milk',
          category: PantryCategory.dairy,
          quantity: 500,
          unit: 'ml',
        ),
      );

      expect(pantry.items, hasLength(2));
    });

    test('urgent items sort to the top', () {
      final pantry = Pantry([
        _item('Apples', days: 20),
        _item('Coriander', days: -1),
        _item('Spinach', days: 1),
      ]);

      expect(
        pantry.sorted(_tuesday).map((i) => i.name),
        ['Coriander', 'Spinach', 'Apples'],
      );
    });

    test('cooking deducts what was used and drops what ran out', () {
      final pantry = Pantry([
        _item('Spinach', quantity: 200),
        _item('Feta', quantity: 300),
      ]);
      const match = RecipeMatch(
        recipe: Recipe(
          name: 'Test',
          summary: '',
          serves: 1,
          minutes: 1,
          needs: [
            RecipeNeed('Spinach', 200, 'g'),
            RecipeNeed('Feta', 100, 'g')
          ],
          steps: [],
        ),
        have: [
          RecipeNeed('Spinach', 200, 'g'),
          RecipeNeed('Feta', 100, 'g'),
        ],
        missing: [],
        uses: [],
      );

      pantry.consume(match);

      expect(pantry.items.map((i) => i.name), ['Feta']);
      expect(pantry.items.single.quantity, 200);
    });
  });

  group('ranking', () {
    test('what you can cook comes before what you cannot', () {
      final ranked =
          rankRecipes(recipeBook, Pantry(seedPantry(_tuesday)), _tuesday);
      final firstUncookable = ranked.indexWhere((m) => !m.canCook);
      final lastCookable = ranked.lastIndexWhere((m) => m.canCook);

      expect(lastCookable, lessThan(firstUncookable),
          reason: 'a suggestion you cannot act on is not a suggestion');
    });

    test('the seed pantry can actually cook something', () {
      // Guards the guard: a seed that cooks nothing would let every
      // ordering assertion above pass for the wrong reason.
      final ranked =
          rankRecipes(recipeBook, Pantry(seedPantry(_tuesday)), _tuesday);
      expect(ranked.where((m) => m.canCook), isNotEmpty);
    });

    test('among cookable recipes, the one rescuing more food wins', () {
      final pantry = Pantry(seedPantry(_tuesday));
      final ranked = rankRecipes(recipeBook, pantry, _tuesday)
          .where((m) => m.canCook)
          .toList();

      for (var i = 1; i < ranked.length; i++) {
        expect(
          ranked[i - 1].urgentCount(_tuesday),
          greaterThanOrEqualTo(ranked[i].urgentCount(_tuesday)),
          reason: 'cookable recipes are ordered by how much they use up',
        );
      }
    });

    test('a recipe needing something absent reports it as missing', () {
      final flatbreads =
          recipeBook.firstWhere((r) => r.name == 'Yoghurt flatbreads');
      final match =
          rankRecipes([flatbreads], Pantry(seedPantry(_tuesday)), _tuesday)
              .single;

      expect(match.canCook, isFalse);
      expect(match.missing.map((n) => n.name), ['Flour']);
      expect(match.coverage, closeTo(2 / 3, 0.001));
    });

    test('not enough of something counts as missing, not as having it', () {
      final pantry = Pantry([_item('Eggs', quantity: 1)]);
      final match = rankRecipes(
        [
          const Recipe(
            name: 'Omelette',
            summary: '',
            serves: 1,
            minutes: 5,
            needs: [RecipeNeed('Eggs', 4, '')],
            steps: [],
          ),
        ],
        pantry,
        _tuesday,
      ).single;

      expect(match.canCook, isFalse);
    });
  });
}
