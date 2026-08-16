import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// One part of a multi-section [PlinthProgress] or
/// [PlinthRingProgress], matching Mantine's `Progress.Section`.
///
/// [value] is a fraction of the *whole bar*, not of the other
/// sections: three sections of 0.5, 0.3 and 0.1 leave a tenth of the
/// track empty, which is how a part-to-whole bar says "and this much
/// is neither".
class PlinthProgressSection {
  const PlinthProgressSection({
    required this.value,
    required this.color,
    this.label,
  }) : assert(value >= 0, 'a section cannot be a negative fraction');

  final double value;

  /// Palette key, required rather than optional: sections that share
  /// the theme's primary color are one bar drawn in several pieces.
  final String color;

  /// Names the section for screen readers, which otherwise get a bar
  /// with no reading at all. Sighted readers get it from the legend
  /// the caller draws beside the bar.
  final String? label;
}

/// A themeable linear progress bar matching Mantine's `Progress`: a
/// track filled proportionally to [value], animated on change.
///
/// ```dart
/// PlinthProgress(value: 0.6, color: 'green')
/// ```
///
/// Use [PlinthProgress.sections] for a part-to-whole bar — traffic
/// split by source, storage by file type — where the proportions
/// between the parts are the point:
///
/// ```dart
/// PlinthProgress.sections(
///   sections: const [
///     PlinthProgressSection(value: 0.5, color: 'blue', label: 'Direct'),
///     PlinthProgressSection(value: 0.3, color: 'teal', label: 'Search'),
///   ],
/// )
/// ```
class PlinthProgress extends StatelessWidget {
  const PlinthProgress({
    super.key,
    required this.value,
    this.color,
    this.size = PlinthSize.md,
    this.radius,
    this.trackColor,
  })  : sections = null,
        assert(value >= 0 && value <= 1, 'value must be between 0 and 1');

  /// A bar divided into coloured parts of one whole.
  ///
  /// Not a `const` constructor, unlike the single-value one: checking
  /// that the parts don't exceed the whole means summing them, which a
  /// const assert can't do.
  PlinthProgress.sections({
    super.key,
    required List<PlinthProgressSection> sections,
    this.size = PlinthSize.md,
    this.radius,
    this.trackColor,
  })  : sections = sections,
        value = 0,
        color = null,
        assert(sections.length > 0, 'a sectioned bar needs a section'),
        assert(
          sections.fold<double>(0, (sum, s) => sum + s.value) <= 1.0001,
          'sections are fractions of the whole bar, so they cannot sum '
          'above 1 — scale them yourself if you have raw counts',
        );

  /// Fraction filled, from 0.0 to 1.0. Ignored when [sections] is set.
  final double value;
  final String? color;
  final PlinthSize size;
  final PlinthSize? radius;

  /// The parts of a part-to-whole bar, or null for a single fill.
  final List<PlinthProgressSection>? sections;

  /// Background track color. Defaults to a light gray.
  final Color? trackColor;

  static const Map<PlinthSize, double> _heights = {
    PlinthSize.xs: 4,
    PlinthSize.sm: 6,
    PlinthSize.md: 10,
    PlinthSize.lg: 14,
    PlinthSize.xl: 20,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final fillColor = theme.shaded(colorKey, 6);
    final height = _heights[size]!;
    final resolvedRadius = theme.radius[radius ?? PlinthSize.xl]!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(resolvedRadius),
      child: Container(
        height: height,
        color: trackColor ?? theme.surfaceSunken,
        child: sections != null
            ? _sectionsFill(theme)
            : Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  widthFactor: value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: fillColor),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _sectionsFill(PlinthTheme theme) {
    final parts = sections!;
    final described = parts.where((s) => s.label != null);

    // Widths from the available width rather than `Expanded` flexes:
    // flex normalises to the sum, which would stretch three sections
    // adding up to 0.9 across the whole track and quietly lose the
    // tenth that belongs to nobody.
    final bar = LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          for (final section in parts)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: constraints.maxWidth * section.value,
              color: theme.shaded(section.color, 6),
            ),
        ],
      ),
    );

    if (described.isEmpty) return bar;

    // A bar with no text in it reads as nothing at all; the caller's
    // legend is separate content a screen reader meets out of context.
    return Semantics(
      label: described
          .map((s) => '${s.label}: ${(s.value * 100).round()}%')
          .join(', '),
      textDirection: TextDirection.ltr,
      child: bar,
    );
  }
}

/// [FractionallySizedBox] doesn't animate its factor changes on its
/// own — this wraps it in a [TweenAnimationBuilder] so the fill
/// smoothly grows/shrinks when [widthFactor] changes, rather than
/// snapping instantly.
class AnimatedFractionallySizedBox extends StatelessWidget {
  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required this.duration,
    this.curve = Curves.linear,
  });

  final double widthFactor;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: widthFactor, end: widthFactor),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: child,
    );
  }
}
