# What adopting tokens costs you

Moving an app onto `plinth_core` is mostly mechanical, and one part of
it is not: **a token lookup needs a `BuildContext`, so it cannot be
`const`.** That single fact ripples further than it looks, and every
adopter rediscovers the same five patterns.

This page is that hour of rediscovery, written down. Everything here
came from migrating one real app — see
[ADOPTION_REQUIREMENTS.md](ADOPTION_REQUIREMENTS.md) for the numbered
gaps it produced, of which this page is [PR-15](ADOPTION_REQUIREMENTS.md#pr-15--a-migration-guide-for-the-constcontext-tax).

## The rule, and the exception that matters

> **Colour needs a context. Spacing does not.**

Colour genuinely varies by theme, so paying a `BuildContext` for it buys
something. Spacing does not vary, and paying for it buys nothing —
which is why `plinth_core` ships the spacing scale twice:

```dart
// Needs a context. Use only where the multiple is computed at runtime,
// or where a caller passed a PlinthSize you have to honour.
theme.spacing[PlinthSize.md]        // 16
theme.space(2)                      // 8

// Compile-time constants. Use these everywhere else.
const SizedBox(height: PlinthSpacing.md)      // still const
const EdgeInsets.all(PlinthSpacing.sm)
```

The subject app had **355 spacing literals**. Routing those through a
theme lookup would have traded 355 `const` widgets for 355 runtime ones
and bought nothing at all. Reach for `PlinthSpacing` first and the tax
below applies to a much smaller surface.

**Radius has no const equivalent yet**, so `theme.radius[…]` still costs
a context. That is a real gap, not an oversight you should work around
with a magic number.

---

## 1. `const` colour maps become methods

A lookup table of colours cannot survive as a `const`, because its
values now come from the theme.

```dart
// Before
static const _actionColors = {
  'buy': Color(0xFF34C759),
  'sell': Color(0xFFFF3B30),
};

// After — takes the theme, returns the colour
Color _actionColor(PlinthTheme t, String action) => switch (action) {
      'buy' => t.semantic('income'),
      'sell' => t.semantic('expense'),
      _ => t.textMuted,
    };
```

Passing `PlinthTheme` rather than `BuildContext` is the better shape:
the function stays testable without pumping a widget, and it composes
with helpers that already hold a theme.

## 2. `const` widgets carrying colour stop being `const`

```dart
// Before
const Icon(Icons.delete_outline, color: Color(0xFFFF3B30))
const TextStyle(color: Color(0xFFFF3B30))

// After — the const goes away, and that is fine
Icon(Icons.delete_outline, color: theme.roleShaded(PlinthRole.error, 6))
TextStyle(color: theme.roleShaded(PlinthRole.error, 6))
```

Don't fight this. A `const` widget saves a rebuild of a leaf; a themed
one is why the app has a dark mode. The trade is worth it, and it only
applies to the widgets that actually carry colour.

## 3. Helpers grow a parameter, and it ripples

Seven helper methods in the subject app grew a parameter, and each
change reached every call site.

```dart
// Before
Color flowColor(String flow) => flow == 'in' ? _green : _red;

// After
Color flowColor(PlinthTheme t, String flow) =>
    t.semantic(flow == 'in' ? 'income' : 'expense');
```

Budget for the ripple rather than being surprised by it. Passing the
theme down explicitly is usually less painful than threading a
`BuildContext` through layers that have no other use for one — and a
pure-Dart layer *cannot* take a context at all. Where that is the case,
pass a **name** and resolve it at the widget layer:

```dart
// Engine layer, no Flutter import
String categoryKey(Txn t) => t.category;      // 'groceries'

// Widget layer
theme.seriesFor(categoryKey(txn));
```

## 4. Painters take colours, and `shouldRepaint` becomes load-bearing

A `CustomPainter` has no context, so every colour it draws with has to
arrive through its constructor.

```dart
class BarsPainter extends CustomPainter {
  BarsPainter({required this.bars, required this.barColor, required this.axisColor});

  final List<double> bars;
  final Color barColor;
  final Color axisColor;

  @override
  bool shouldRepaint(BarsPainter old) =>
      old.bars != bars ||
      old.barColor != barColor ||     // <- easy to forget
      old.axisColor != axisColor;
}
```

**This is the one that bites silently.** Once colour is state, a
`shouldRepaint` that ignores it will happily keep the old pixels when
the theme changes — the chart simply does not follow your dark-mode
toggle, and nothing errors.

The subject app already had this latent: a painter compared `years`,
`retireAge` and `unlockAge` but not the themed colour it *already* took.
Threading three more colours through is what made the omission live.

**Audit every `shouldRepaint` you own as part of the migration**, not
after. Grep for the ones that only compare data.

## 5. The `use_build_context_synchronously` lint can't see through a function

```dart
// Your helper — the guard inside is invisible to the analyzer
void notify(BuildContext context, String message) {
  if (!context.mounted) return;
  PlinthNotification.show(context, child: Text(message));
}

// Call site — the lint still fires here, and it is right to
await store.save();
notify(context, 'Saved');            // ← use_build_context_synchronously
```

The lint is not being pedantic: it cannot prove your helper guards, and
a future edit could remove the guard without touching this line.

**For notifications there is a better answer than the guard.** Capture
the messenger *before* the `await` and no context is needed afterwards:

```dart
final messenger = ScaffoldMessenger.of(context);
await store.save();
PlinthNotification.showOn(messenger, child: const Text('Saved'));
```

That is not just quieter — it is *different behaviour*. The captured
messenger still delivers when the widget has gone away; the
`context.mounted` guard silently drops the message. For "save finished"
that is usually the wrong drop, and either way it should be your choice.
See [PR-12](ADOPTION_REQUIREMENTS.md#pr-12--showon-for-messenger-backed-apis).

---

## What this does not cost

Worth stating, because the list above reads heavier than the migration
felt:

- **Not your `ThemeData`.** `plinth_core` registers as a
  `ThemeExtension`; your existing Material theme keeps working. If you
  want the two palettes to agree, assert it rather than rewriting:
  `expect(myTheme.colorSchemeDisagreements(scheme), isEmpty)`.
- **Not your widgets.** Nothing here requires `plinth_components`. The
  token layer is usable on its own, and for many apps that is the whole
  adoption.
- **Not your layout.** Spacing, via `PlinthSpacing`, stays `const`.
- **Not RTL.** Validating against a Hebrew/English app found 12 of 12
  page × language combinations already clean. The one primitive that was
  missing is `PlinthLtr`, for charts and figures that must stay
  left-to-right.

## Sequence that worked

1. Register the theme, change nothing else. Confirm the app still builds
   and looks identical.
2. Replace spacing literals with `PlinthSpacing`. Large, mechanical,
   `const`-preserving, no visual change.
3. Name your colours — declare `semanticColors` roles — before replacing
   any of them. Naming first means step 4 is a rename, not a redesign.
4. Replace colour literals role by role, not file by file. One role
   fully migrated is reviewable; one file half-migrated is not.
5. Audit `shouldRepaint` and painter constructors.
6. Only then look at whether the palettes agree.

**Colour drift will not fail your tests.** The subject app's full suite
— 202 tests, including page-level widget tests — passed before, after,
and through intermediate states where the rendered palette was
materially different. Not one test asserted on a colour. If you want a
migration you can trust, add a golden or a contrast assertion *first*;
"the tests pass" is not evidence here.
