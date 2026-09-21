# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

Like `plinth_blocks`, this package is **outside the lockstep** the other
three keep from `1.0.0` — a chart catalogue will churn while a token
engine does not. See
[PUBLISHING.md](../../docs/PUBLISHING.md#plinth_blocks-is-outside-the-lockstep-for-now).

## 0.1.0

Unreleased. The first chart, and the shape the rest will follow.

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

### Notes

Replaces a `CustomPaint` that lived in the demo app's showcase, which
is where the gap announced itself: a block hand-rolling a chart is a
charts package in disguise.
