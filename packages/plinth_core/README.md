# plinth_core

**A design-token engine for Flutter.** Colour that resolves against a
WCAG contrast floor at lookup time, ramps anchored to your own brand
colour, and a way to check your existing `ThemeData` against your
tokens instead of replacing it.

This is the foundation [Plinth UI](https://github.com/ylahav/plinth_ui)
is built on — but it is not only for Plinth's widgets. Most apps
adopting it already have a UI layer they are not going to rewrite. It
themes *your* widgets just as well.

```bash
flutter pub add plinth_core
```

## Four things it does that a colour scheme does not

### Colour resolved against a contrast floor, not a fixed shade

Ask for a palette colour as *text*, and you get a shade that clears
4.5:1 against the background it actually sits on:

```dart
final theme = context.plinth;

Text('Overdue', style: TextStyle(color: theme.readableOn('cyan', theme.surface)))
```

A fixed shade cannot do this, because ramps differ in intrinsic
lightness. Of the thirteen built-in ramps, **exactly one — `violet`, at
4.95:1 — clears 4.5:1 on white at shade 6**, the shade components
default to. `cyan` is 2.79:1 and `yellow` is 1.86:1: colours you can
see but cannot read.

`readableOn` walks the ramp from the shade you asked for toward
whichever end contrasts, and returns the first one that clears the
floor — `cyan` becomes `#157785` at 5.24:1, and `violet` comes back
untouched because it already passed.

The floor is named by what the colour is *for* —
`PlinthContrast.body` (4.5:1) is the default, because that is the table
cell most callers are actually painting, not the heading.

### Ramps anchored to your colour

Feed in your brand colour, ask for shade 6, get your brand colour back:

```dart
PlinthTheme.generateShades(const Color(0xFFFF3B30))[6]  // 0xFFFF3B30
```

That sounds obvious and most generators do not do it. Normalising a
base colour onto a fixed lightness curve turned `#FA5252` into
`#E90707`, and the best-matching index landed anywhere from 5 to 8
depending on hue — so there was no shade a caller could reliably ask
for. Both endpoints stay put, so shade 0 is still a usable tint.

### Colours named by role, not by hue

An app's palette is `expense`, `income`, `brand` — not `red`, `green`,
`blue`. Declare the mapping once, with a contrast floor per role:

```dart
PlinthTheme.defaultTheme.copyWith(
  semanticColors: const {
    'expense': PlinthSemanticColor('red'),
    'income': PlinthSemanticColor('green'),
  },
)

theme.semantic('expense')      // the fill
theme.semanticText('expense')  // dark enough to read as a label
theme.semanticWash('expense')  // a tint for the row behind it
```

The three are deliberately different colours. A brand red that looks
right as a fill is routinely unreadable as a label — `#FF9500` on white
is 2.20:1 — and `semanticText` is the hand-darkening every app ends up
doing, done for you and held to a threshold.

### Keep your own `ThemeData`

The question most teams actually have is not "how do I generate a
theme", it is **"are the two palettes I already have the same
colours?"**

```dart
test('the two palettes agree', () {
  expect(myPlinthTheme.colorSchemeDisagreements(myScheme), isEmpty);
});
```

You get back a list of every field where your `ColorScheme` and your
tokens disagree, with both values. Assert it is empty in CI and the
drift cannot come back silently. Comparison is exact — a tolerance
would only decide for you how much drift is acceptable, which is the
judgement this exists to surface rather than make.

There is a `toColorScheme()` for apps willing to hand over the
decision. It is the less useful direction, and that is a finding from
migrating a real app: a wholesale `toThemeData()` was the
highest-priority item on this package's roadmap, and during the
migration it was never reached for once.

## Registering it

`PlinthTheme` is a `ThemeExtension`, so it rides along with the theme
you already have:

```dart
MaterialApp(
  theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
  darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
)
```

Then read it from any `BuildContext` with `context.plinth`.

Light and dark **share the same ramps**. A shade's *role* is mirrored
for the active brightness rather than the palette being swapped, so a
blue button stays the same blue and only the chrome around it changes.

## Spacing does not need a context

Colour genuinely varies by theme, so paying a `BuildContext` for it
buys something. Spacing does not, so the scale ships twice:

```dart
const SizedBox(height: PlinthSpacing.md)   // still const
theme.spacing[PlinthSize.md]               // when the size is chosen at runtime
```

The app this was validated against had 355 spacing literals. Routing
those through a theme lookup would have traded 355 `const` widgets for
355 runtime ones and bought nothing.
[Adopting tokens](https://github.com/ylahav/plinth_ui/blob/main/docs/ADOPTING_TOKENS.md)
covers the rest of what that migration cost.

## What's in the package

- **`PlinthTheme`** — the `ThemeExtension` holding colour ramps,
  semantic roles, spacing, radius and font-size scales, plus the
  lookups above (`readableOn`, `semantic`, `wash`, `contrastingOn`,
  `series`).
- **`PlinthSemanticColor`** — a role: a ramp, a shade, and the contrast
  floor it is held to.
- **`PlinthRole`**, **`PlinthSize`** (`xs`–`xl`), **`PlinthVariant`**,
  **`PlinthDensity`** — the shared vocabulary.
- **`PlinthMaterialBridge`** — `colorSchemeDisagreements`,
  `toColorScheme`, `toTextTheme`.
- **`context.plinth`** — the accessor.

## The widgets

If you want components rather than only tokens — buttons, inputs,
cards, and 114 others —
[`plinth_components`](https://pub.dev/packages/plinth_components) is
built entirely on this package, and is the evidence that the token
layer holds up at scale.

🌐 **[Live demo](https://ylahav.github.io/plinth_ui/)** · 📖 **[Full documentation](https://github.com/ylahav/plinth_ui)**
