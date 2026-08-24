/// A pantry with something already in it, and a small recipe book.
///
/// The dates are relative to launch so the app is never stale: two items
/// are always about to go off and one is always past it, which is what
/// makes the freshness roles visible without anybody having to wait.
library;

import 'model.dart';

List<PantryItem> seedPantry(DateTime now) {
  DateTime inDays(int days) => now.add(Duration(days: days));

  return [
    PantryItem(
      name: 'Spinach',
      category: PantryCategory.produce,
      quantity: 200,
      unit: 'g',
      expiresOn: inDays(1),
    ),
    PantryItem(
      name: 'Greek yoghurt',
      category: PantryCategory.dairy,
      quantity: 500,
      unit: 'g',
      expiresOn: inDays(3),
    ),
    PantryItem(
      name: 'Coriander',
      category: PantryCategory.produce,
      quantity: 1,
      unit: 'bunch',
      expiresOn: inDays(-1),
    ),
    PantryItem(
      name: 'Eggs',
      category: PantryCategory.protein,
      quantity: 6,
      unit: '',
      expiresOn: inDays(11),
    ),
    PantryItem(
      name: 'Feta',
      category: PantryCategory.dairy,
      quantity: 200,
      unit: 'g',
      expiresOn: inDays(9),
    ),
    PantryItem(
      name: 'Onion',
      category: PantryCategory.produce,
      quantity: 3,
      unit: '',
      expiresOn: inDays(21),
    ),
    PantryItem(
      name: 'Garlic',
      category: PantryCategory.produce,
      quantity: 1,
      unit: 'head',
      expiresOn: inDays(30),
    ),
    PantryItem(
      name: 'Chickpeas',
      category: PantryCategory.pantry,
      quantity: 400,
      unit: 'g',
      expiresOn: inDays(400),
    ),
    PantryItem(
      name: 'Chopped tomatoes',
      category: PantryCategory.pantry,
      quantity: 400,
      unit: 'g',
      expiresOn: inDays(300),
    ),
    const PantryItem(
      name: 'Olive oil',
      category: PantryCategory.pantry,
      quantity: 500,
      unit: 'ml',
    ),
    const PantryItem(
      name: 'Rice',
      category: PantryCategory.grain,
      quantity: 1,
      unit: 'kg',
    ),
    const PantryItem(
      name: 'Cumin',
      category: PantryCategory.spice,
      quantity: 40,
      unit: 'g',
    ),
    const PantryItem(
      name: 'Paprika',
      category: PantryCategory.spice,
      quantity: 35,
      unit: 'g',
    ),
    const PantryItem(
      name: 'Salt',
      category: PantryCategory.spice,
      quantity: 500,
      unit: 'g',
    ),
  ];
}

const recipeBook = <Recipe>[
  Recipe(
    name: 'Shakshuka',
    summary: 'Eggs poached in a spiced tomato sauce. The one to cook when the '
        'eggs are fine and everything fresh is not.',
    serves: 2,
    minutes: 30,
    needs: [
      RecipeNeed('Eggs', 4, ''),
      RecipeNeed('Chopped tomatoes', 400, 'g'),
      RecipeNeed('Onion', 1, ''),
      RecipeNeed('Garlic', 1, 'head'),
      RecipeNeed('Cumin', 2, 'g'),
      RecipeNeed('Paprika', 2, 'g'),
      RecipeNeed('Olive oil', 30, 'ml'),
      RecipeNeed('Coriander', 1, 'bunch'),
    ],
    steps: [
      RecipeStep('Dice the onion and slice three cloves of garlic.'),
      RecipeStep(
        'Warm the oil in a wide pan and soften the onion until it is '
        'translucent.',
        minutes: 8,
      ),
      RecipeStep('Add the garlic, cumin and paprika. Stir for one minute — '
          'long enough to smell them, short enough not to burn them.'),
      RecipeStep(
        'Pour in the tomatoes, season, and simmer until the sauce holds '
        'the shape of a spoon dragged through it.',
        minutes: 12,
      ),
      RecipeStep('Make four wells and crack an egg into each.'),
      RecipeStep(
        'Cover and cook until the whites are set and the yolks still '
        'move.',
        minutes: 6,
      ),
      RecipeStep('Scatter the coriander over the top and take it to the '
          'table in the pan.'),
    ],
  ),
  Recipe(
    name: 'Spinach and feta eggs',
    summary: 'Ten minutes, one pan, and it uses the spinach before the '
        'spinach uses itself.',
    serves: 2,
    minutes: 12,
    needs: [
      RecipeNeed('Spinach', 200, 'g'),
      RecipeNeed('Feta', 100, 'g'),
      RecipeNeed('Eggs', 4, ''),
      RecipeNeed('Olive oil', 15, 'ml'),
      RecipeNeed('Garlic', 1, 'head'),
    ],
    steps: [
      RecipeStep('Heat the oil and add two sliced cloves of garlic.'),
      RecipeStep(
        'Add the spinach a handful at a time, letting each wilt before '
        'the next goes in.',
        minutes: 4,
      ),
      RecipeStep('Beat the eggs, crumble in the feta, and season lightly — '
          'the feta is already salty.'),
      RecipeStep(
        'Pour over the spinach and cook without stirring until the edges '
        'set.',
        minutes: 5,
      ),
      RecipeStep('Fold once and slide onto a plate.'),
    ],
  ),
  Recipe(
    name: 'Chickpeas with yoghurt',
    summary: 'Crisped chickpeas, warm spices, cold yoghurt underneath.',
    serves: 2,
    minutes: 20,
    needs: [
      RecipeNeed('Chickpeas', 400, 'g'),
      RecipeNeed('Greek yoghurt', 200, 'g'),
      RecipeNeed('Garlic', 1, 'head'),
      RecipeNeed('Cumin', 3, 'g'),
      RecipeNeed('Olive oil', 30, 'ml'),
      RecipeNeed('Coriander', 1, 'bunch'),
    ],
    steps: [
      RecipeStep('Drain the chickpeas and dry them properly. Wet chickpeas '
          'steam instead of crisping.'),
      RecipeStep(
        'Fry them in hot oil, undisturbed at first, until they blister.',
        minutes: 8,
      ),
      RecipeStep('Add the cumin and a grated clove of garlic off the heat.'),
      RecipeStep('Stir the remaining garlic through the yoghurt with a '
          'pinch of salt.'),
      RecipeStep('Spread the yoghurt on a plate, pile the chickpeas on '
          'top, and finish with the coriander.'),
    ],
  ),
  Recipe(
    name: 'Tomato rice',
    summary: 'The store-cupboard one. Nothing in it can go off.',
    serves: 4,
    minutes: 35,
    needs: [
      RecipeNeed('Rice', 300, 'g'),
      RecipeNeed('Chopped tomatoes', 400, 'g'),
      RecipeNeed('Onion', 1, ''),
      RecipeNeed('Olive oil', 30, 'ml'),
      RecipeNeed('Paprika', 3, 'g'),
    ],
    steps: [
      RecipeStep('Dice the onion and soften it in the oil.', minutes: 7),
      RecipeStep('Stir in the paprika and the rice until every grain is '
          'coated.'),
      RecipeStep(
        'Add the tomatoes and twice their volume of water. Simmer, '
        'covered, without lifting the lid.',
        minutes: 18,
      ),
      RecipeStep(
        'Take it off the heat and let it sit, still covered.',
        minutes: 5,
      ),
      RecipeStep('Fork it through and season.'),
    ],
  ),
  Recipe(
    name: 'Yoghurt flatbreads',
    summary: 'Two ingredients and a hot pan. Needs flour, which you are '
        'out of.',
    serves: 4,
    minutes: 25,
    needs: [
      RecipeNeed('Flour', 250, 'g'),
      RecipeNeed('Greek yoghurt', 250, 'g'),
      RecipeNeed('Salt', 5, 'g'),
    ],
    steps: [
      RecipeStep('Mix the flour, yoghurt and salt into a shaggy dough.'),
      RecipeStep('Knead until smooth.', minutes: 5),
      RecipeStep('Rest the dough under a cloth.', minutes: 10),
      RecipeStep('Divide into four and roll each out thinly.'),
      RecipeStep(
        'Cook in a dry, very hot pan until each side blisters.',
        minutes: 6,
      ),
    ],
  ),
  Recipe(
    name: 'Roast chicken',
    summary: 'Sunday food. Needs a chicken, and there is no chicken.',
    serves: 4,
    minutes: 90,
    needs: [
      RecipeNeed('Whole chicken', 1, ''),
      RecipeNeed('Onion', 2, ''),
      RecipeNeed('Olive oil', 30, 'ml'),
      RecipeNeed('Salt', 10, 'g'),
      RecipeNeed('Paprika', 5, 'g'),
    ],
    steps: [
      RecipeStep('Heat the oven as high as it goes.'),
      RecipeStep('Halve the onions and sit the chicken on top of them.'),
      RecipeStep('Rub with oil, salt and paprika, getting under the skin '
          'where you can.'),
      RecipeStep(
          'Roast, turning the heat down after the first twenty '
          'minutes.',
          minutes: 75),
      RecipeStep('Rest it for as long as you can stand to.', minutes: 15),
    ],
  ),
];
