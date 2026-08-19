import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A single step in a [PlinthStepper].
class PlinthStep {
  const PlinthStep({required this.label, this.description});

  final String label;
  final String? description;
}

/// A numbered step progress indicator matching Mantine's `Stepper`.
///
/// Purely a visual indicator of progress through a sequence — like
/// [PlinthTabs] vs [PlinthTabView], this doesn't manage step *content*
/// itself; pair it with your own `IndexedStack`/`PageView`/conditional
/// rendering driven by the same `currentStep` index you pass in here.
/// Tapping a step calls [onStepTapped] if provided, but doesn't change
/// [currentStep] itself — that stays owned by the caller, the same
/// controlled-component pattern as [PlinthTabs].
///
/// ```dart
/// PlinthStepper(
///   currentStep: _step,
///   onStepTapped: (i) => setState(() => _step = i),
///   steps: const [
///     PlinthStep(label: 'Account'),
///     PlinthStep(label: 'Shipping'),
///     PlinthStep(label: 'Confirm'),
///   ],
/// )
/// ```
///
/// `direction: Axis.vertical` runs the steps down the page instead,
/// with each label beside its circle rather than under it. That is the
/// shape a long checkout or an onboarding flow wants — descriptions
/// get a line's width to sit on instead of a column's.
class PlinthStepper extends StatelessWidget {
  const PlinthStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
    this.color,
    this.radius,
    this.direction = Axis.horizontal,
    this.size = PlinthSize.md,
  });

  final List<PlinthStep> steps;

  /// Which way the sequence runs.
  final Axis direction;

  /// Scales the marker and the text under or beside it together.
  /// Defaults to [PlinthSize.md], which is what this drew before the
  /// prop existed.
  final PlinthSize size;

  /// Zero-based index of the active step. Steps before this are
  /// shown completed (filled circle with a check); steps after are
  /// shown pending (outlined circle with their number).
  final int currentStep;

  final ValueChanged<int>? onStepTapped;
  final String? color;

  /// Squares off the fully rounded default. Omit unless it has to
  /// match squarer chrome around it.
  final PlinthSize? radius;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.shaded(colorKey, 6);
    final metrics = _metricsFor(size);

    _StepState stateOf(int i) => i < currentStep
        ? _StepState.completed
        : i == currentStep
            ? _StepState.active
            : _StepState.pending;

    Widget stepAt(int i) => _StepCircleAndLabel(
          radius: radius,
          step: steps[i],
          index: i,
          direction: direction,
          metrics: metrics,
          state: stateOf(i),
          activeColor: activeColor,
          onTap: onStepTapped == null ? null : () => onStepTapped!(i),
        );

    Color connectorColor(int i) =>
        i < currentStep ? activeColor : theme.surfaceSunken;

    if (direction == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            stepAt(i),
            if (i != steps.length - 1)
              // The Align is load-bearing: this column stretches its
              // children so the steps share a left edge, and a bare
              // Container would have that stretch overrule its width
              // and paint a full-width bar across the step below.
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 2,
                  height: theme.spacing[PlinthSize.md]!,
                  // Centred under the circle above it: half the
                  // circle, less half the connector's own width.
                  margin: EdgeInsets.only(left: metrics.circle / 2 - 1),
                  color: connectorColor(i),
                ),
              ),
          ],
        ],
      );
    }

    return Row(
      // Start rather than the default centre. Each step is a column of
      // circle-then-label, and centring sized every one of those
      // columns against the tallest — so a stepper where only some
      // steps carry a description drew its markers on two different
      // lines, 8px apart at the default size and further at a larger
      // one. Aligned to the top, every circle starts at the same y and
      // the connector has one line to sit on.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(child: stepAt(i)),
          if (i != steps.length - 1)
            Expanded(
              child: Padding(
                // Half the circle, less half the connector, from the
                // top the circles now share — which is the circle's
                // centre line at any size.
                padding: EdgeInsets.only(top: metrics.circle / 2 - 1),
                child: Container(height: 2, color: connectorColor(i)),
              ),
            ),
        ],
      ],
    );
  }
}

/// The measurements a [PlinthSize] resolves to for a step marker.
///
/// A record rather than four lookups: the circle and the connector's
/// offset have to agree, and the surest way for them to agree is for
/// them to come from the same place.
typedef _StepMetrics = ({
  double circle,
  double number,
  PlinthSize label,
  PlinthSize description,
});

_StepMetrics _metricsFor(PlinthSize size) => switch (size) {
      PlinthSize.xs => (
          circle: 20,
          number: 10,
          label: PlinthSize.xs,
          description: PlinthSize.xs
        ),
      PlinthSize.sm => (
          circle: 26,
          number: 11,
          label: PlinthSize.xs,
          description: PlinthSize.xs
        ),
      PlinthSize.md => (
          circle: 32,
          number: 13,
          label: PlinthSize.sm,
          description: PlinthSize.xs
        ),
      PlinthSize.lg => (
          circle: 40,
          number: 16,
          label: PlinthSize.md,
          description: PlinthSize.sm
        ),
      PlinthSize.xl => (
          circle: 48,
          number: 19,
          label: PlinthSize.lg,
          description: PlinthSize.md
        ),
    };

enum _StepState { completed, active, pending }

class _StepCircleAndLabel extends StatelessWidget {
  const _StepCircleAndLabel({
    required this.step,
    required this.index,
    required this.state,
    required this.activeColor,
    required this.onTap,
    required this.radius,
    required this.direction,
    required this.metrics,
  });

  final PlinthStep step;
  final int index;
  final _StepState state;
  final Color activeColor;
  final VoidCallback? onTap;
  final Axis direction;
  final _StepMetrics metrics;

  /// Null keeps the circular default, which is what a step marker is.
  final PlinthSize? radius;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final isFilled =
        state == _StepState.completed || state == _StepState.active;
    final isVertical = direction == Axis.vertical;
    final align = isVertical ? TextAlign.start : TextAlign.center;

    final circle = Container(
      width: metrics.circle,
      height: metrics.circle,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? activeColor : theme.surface,
        border: Border.all(
          color: isFilled ? activeColor : theme.border,
          width: 2,
        ),
      ),
      child: state == _StepState.completed
          ? Icon(
              Icons.check,
              // Half the circle, which is what 16 was at the default
              // size - the tick has to grow with the disc it sits in.
              size: metrics.circle / 2,
              color: theme.contrastingOn(activeColor),
            )
          : Text(
              '${index + 1}',
              style: TextStyle(
                color: isFilled
                    ? theme.contrastingOn(activeColor)
                    : theme.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: metrics.number,
              ),
            ),
    );

    final labels = [
      PlinthText(
        step.label,
        size: metrics.label,
        weight: state == _StepState.active ? FontWeight.w700 : FontWeight.w400,
        textAlign: align,
      ),
      if (step.description != null)
        PlinthText(
          step.description!,
          size: metrics.description,
          color: theme.rampFor(PlinthRole.neutral),
          textAlign: align,
        ),
    ];

    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
            radius == null ? 999 : theme.radius[radius!]!),
        child: isVertical
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  circle,
                  SizedBox(width: theme.spacing[PlinthSize.sm]),
                  Expanded(
                    child: Padding(
                      // Nudged down so the label's first line sits on the
                      // circle's centre line rather than its top edge.
                      padding: EdgeInsets.only(
                        top: theme.spacing[PlinthSize.xs]! * 0.5,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: labels,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  circle,
                  SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.5),
                  ...labels,
                ],
              ),
      ),
    );
  }
}
