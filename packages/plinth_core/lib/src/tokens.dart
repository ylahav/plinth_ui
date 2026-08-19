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

/// How much room interactive controls are given, as a minimum tap
/// target.
///
/// **Plinth sizes like the web, because it is modelled on a web
/// library.** Measured at default size, its controls are 23 to 40
/// logical pixels tall: Button 39, TextInput 40, ActionIcon 36,
/// Checkbox 32, Pagination 32. Against the three standards that exist:
///
/// | Standard | Plinth at [standard] |
/// |---|---|
/// | WCAG 2.2 AA — 24x24 (SC 2.5.8) | passes |
/// | iOS HIG — 44 | fails |
/// | Android Material — 48 | fails |
///
/// That is a positioning choice rather than a defect — a dense admin
/// table on a desktop does not want 48px rows — but it is the wrong
/// choice for a phone, and until this existed an app had no way to say
/// so.
///
/// The floor applies to the *target*, not the text. Nothing shrinks a
/// control below its content, and nothing here changes type size or
/// padding; a control already taller than the floor is untouched.
enum PlinthDensity {
  /// Web and desktop. The default, and what every Plinth control was
  /// sized for.
  ///
  /// Floors at **24**, which is WCAG 2.2 AA's minimum (SC 2.5.8), so
  /// the accessible baseline holds without asking.
  standard(24),

  /// iOS's Human Interface Guidelines minimum.
  comfortable(44),

  /// Android Material's minimum, and the largest of the three.
  touch(48);

  const PlinthDensity(this.minTapTarget);

  /// The smallest square an interactive control may occupy.
  final double minTapTarget;
}

/// A shade ramp for a single color, indexed 0 (lightest) to 9 (darkest),
/// matching Mantine's 10-shade convention.
typedef PlinthColorShades = List<Color>;
