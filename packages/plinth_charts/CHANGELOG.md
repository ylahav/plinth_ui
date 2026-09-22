# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

Like `plinth_blocks`, this package is **outside the lockstep** the other
three keep from `1.0.0` — a chart catalogue will churn while a token
engine does not. See
[PUBLISHING.md](../../docs/PUBLISHING.md#plinth_blocks-is-outside-the-lockstep-for-now).

## 0.1.1

### Added

- **An `example/`.** Worth 10 pub points, lost since the first release
  because nothing asks for one until pana scores the published package.

## 0.1.0

Released 21 Sep 2026. The first charts, and the shape the rest will
follow.

### Added

- `PlinthSparkline` — a line with no axes, for sitting beside the
  number it belongs to.

  **It carries a sentence built from its own data**: "Monthly revenue,
  12 to 38, rising". A chart is pixels, and a hand-written label
  describes a different series to the one drawn the first time the data
  changes. `describeValue` formats the endpoints — `38` is rarely what
  a reader wants to hear when the axis is money — and `semanticsLabel`
  replaces the sentence entirely.

  The line resolves through `readableOn` rather than taking shade 6: at
  2px it is the thinnest mark in the library, and the raw shade is
  under the floor for several ramps.

  Fewer than two points draws nothing. One reading is a dot, not a
  trend, and a flat line would claim a shape the data does not have.
- `PlinthLineChart` — several series on one scale, with a legend.

  **Colour is not load-bearing.** Each line gets its own dash pattern
  as well as its own colour, and the legend swatch carries the pattern
  too, so a reader who cannot tell the hues apart can still match a
  line to a name.

  **Faint lines are lifted to the non-text floor**, which is a finding
  about the palette rather than about this chart. `seriesColors` varies
  *lightness* on purpose so dichromats keep a second channel — and four
  of its six defaults land between 1.48:1 and 2.09:1 against a light
  surface, which is faint for everybody. Each colour resolves with
  `PlinthContrast.nonText` starting from the palette's own shade, so
  only the ones under 3:1 move and the rest keep their place in the
  ordering the CVD work depends on.

  One scale across every series, because two lines on their own axes
  can cross without ever having met.
- `PlinthBarChart` — categories as horizontal bars.

  **Horizontal by default**, which is the opposite of most defaults and
  the right one here: category names are words, and words fit along a
  horizontal bar without being rotated, truncated, or moved into a
  legend somebody has to cross-reference.

  **Every bar is its own semantics node** — "Direct, 5,200" — rather
  than the chart being one sentence. That is the difference from
  `PlinthLineChart`: a line is a shape and reads as a summary, a bar
  chart is a list of figures and a list should be walkable.

  Bars take the palette's colours **unlifted**, unlike lines. A bar is
  a large filled area and is perfectly visible at 2:1 where a 2px line
  is not, so lifting would flatten the lightness variation the palette
  exists to provide for no gain.

  Bars are measured against the largest, not a total: the question is
  how the categories compare, and dividing by a sum nobody sees makes a
  long tail out of every one of them.
- `PlinthDonutChart` — slices with the total in the middle.

  Its own documentation tells you to **reach for a bar first**: angles
  are harder to compare than lengths, and `PlinthProgress.sections`
  already shows the same split more legibly. The donut earns its place
  when the total is the headline, which is what the middle of a ring is
  for and what a bar has nowhere to put.

  The legend carries the value and the percentage, because a slice is
  an angle and an angle is not a number. Every slice is its own
  semantics node, like a bar chart and unlike a line.

  A negative slice is clamped to zero rather than drawn backwards,
  which would silently corrupt every slice after it. An empty or
  all-zero donut says "No data" instead of drawing an empty ring.

### Notes

Replaces a `CustomPaint` that lived in the demo app's showcase, which
is where the gap announced itself: a block hand-rolling a chart is a
charts package in disguise.
