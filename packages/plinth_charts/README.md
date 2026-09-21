# plinth_charts

**Charts for [Plinth UI](https://github.com/ylahav/plinth_ui)** — themed
from the same tokens as everything else, and readable by more people
than a chart usually is.

```bash
flutter pub add plinth_charts
```

## Two things that are not decoration

**The categorical palette is validated against colour vision
deficiency.** `plinth_core`'s `seriesColors` deliberately varies
*lightness* as well as hue, and is tested against protanopia,
deuteranopia and tritanopia — because a chart whose series are told
apart by hue alone is a chart roughly one in twelve men cannot read.
The obvious alternative, a row of equally saturated shade-6 colours,
looks better in a screenshot and collapses to 2.3 ΔE under tritanopia.

**Every chart carries a text alternative built from its own data.** A
chart is pixels, and pixels say nothing. The summary is generated
rather than passed, so it cannot describe a different series to the one
drawn — which is exactly what a hand-written label does the first time
the data changes.

```dart
const PlinthSparkline(label: 'Monthly revenue', values: [12, 24, 38])
// announces: "Monthly revenue, 12 to 38, rising"
```

Pass `describeValue` to format the endpoints, or `semanticsLabel` to
say something else entirely.

## What's here

| Chart | What it is |
|---|---|
| `PlinthSparkline` | A line with no axes, for beside a number |
| `PlinthLineChart` | Several series, told apart by shape as well as colour |

More to come. This package is new and its version says so.

## Register the theme first

Charts read colours, spacing and the series palette from a
`PlinthTheme`:

```dart
MaterialApp(theme: ThemeData(extensions: [PlinthTheme.defaultTheme]))
```

It depends on `plinth_core` only — you can chart without installing the
widget library.

## License

MIT
