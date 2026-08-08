import 'package:flutter/widgets.dart';

/// The Plinth size scale, used across nearly every component
/// (buttons, inputs, badges, etc.) so sizing stays consistent
/// throughout an app.
enum PlinthSize { xs, sm, md, lg, xl }

/// The Plinth visual variant scale, mirroring Mantine's approach:
/// each component interprets these consistently so switching a
/// component's "loudness" is a one-line change.
enum PlinthVariant {
  filled,
  light,
  outline,
  subtle,
  defaultVariant,
  transparent
}

/// A shade ramp for a single color, indexed 0 (lightest) to 9 (darkest),
/// matching Mantine's 10-shade convention.
typedef PlinthColorShades = List<Color>;
