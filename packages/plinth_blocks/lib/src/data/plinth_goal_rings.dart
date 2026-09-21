import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One target and how far along it is.
class PlinthGoal {
  const PlinthGoal({
    required this.label,
    required this.value,
    this.color,
    this.caption,
  });

  final String label;

  /// Progress from 0 to 1.
  final double value;

  /// Palette key for the ring. Null falls back to the theme's primary.
  final String? color;

  /// Shown in the ring instead of the percentage, when the raw figure
  /// matters more than the proportion.
  final String? caption;

  /// What the ring says out loud.
  String get spoken => caption ?? '${(value * 100).round()} percent';

  /// What the ring shows.
  String get display => caption ?? '${(value * 100).round()}%';
}

/// A row of progress rings, one per target.
///
/// **Rings rather than bars, and that is the point.** These are
/// separate targets, not parts of one total, and a row of bars would
/// imply they add up to something. Use `PlinthProgress.sections` when
/// the parts really are shares of a whole.
///
/// ```dart
/// PlinthGoalRings(
///   goals: const [
///     PlinthGoal(label: 'Signups', value: 0.82, color: 'teal'),
///     PlinthGoal(label: 'Activation', value: 0.46, color: 'blue'),
///   ],
/// )
/// ```
///
/// Each ring and its label are one semantics node — "Signups, 82
/// percent" — rather than a figure and a caption arriving separately.
class PlinthGoalRings extends StatelessWidget {
  const PlinthGoalRings({
    super.key,
    required this.goals,
    this.title,
    this.diameter = 72,
    this.gap = PlinthSize.xl,
    this.withBorder = true,
    this.width,
  });

  final List<PlinthGoal> goals;

  /// A heading above the rings.
  final String? title;

  final double diameter;
  final PlinthSize gap;
  final bool withBorder;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final card = PlinthPaper(
      withBorder: withBorder,
      p: PlinthSize.md,
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title case final title?)
            PlinthText(title, weight: FontWeight.w700),
          PlinthGroup(
            gap: gap,
            children: [
              for (final goal in goals)
                Semantics(
                  label: '${goal.label}, ${goal.spoken}',
                  container: true,
                  child: ExcludeSemantics(
                    child: PlinthStack(
                      gap: PlinthSize.xs,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PlinthRingProgress(
                          value: goal.value,
                          diameter: diameter,
                          color: goal.color,
                          label: PlinthText(
                            goal.display,
                            size: PlinthSize.sm,
                            weight: FontWeight.w700,
                          ),
                        ),
                        PlinthText(
                          goal.label,
                          size: PlinthSize.xs,
                          color: 'gray',
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}
