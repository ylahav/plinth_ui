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

### Notes

Replaces a `CustomPaint` that lived in the demo app's showcase, which
is where the gap announced itself: a block hand-rolling a chart is a
charts package in disguise.
