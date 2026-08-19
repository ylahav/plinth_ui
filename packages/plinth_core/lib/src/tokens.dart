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

/// The colour roles **the component library itself** needs, independent
/// of which ramp answers them.
///
/// Not to be confused with `PlinthTheme.semanticColors`, which is the
/// *app's* role namespace (`expense`, `income`). These three are
/// Plinth's own, and the distinction is the whole point: before this
/// existed, `plinth_components` reached straight into
/// `PlinthTheme.colors` for `'red'`, `'gray'` and `'green'`, which meant
/// the library and its consumer shared one namespace and **neither
/// knew**.
///
/// An app that repurposed `red` as its expense colour silently
/// restyled every form field's error state; an app that did not ended
/// up with two different reds on screen. Both happened.
enum PlinthRole {
  /// Invalid input, destructive actions, error messages. The single
  /// biggest consumer — every form field's error border and message.
  error,

  /// Secondary and de-emphasised content: field descriptions,
  /// breadcrumb separators, empty-state icons, placeholder chrome.
  neutral,

  /// Confirmation of something that just worked — the copy button's
  /// "copied" flash.
  success,
}

/// A shade ramp for a single color, indexed 0 (lightest) to 9 (darkest),
/// matching Mantine's 10-shade convention.
typedef PlinthColorShades = List<Color>;
