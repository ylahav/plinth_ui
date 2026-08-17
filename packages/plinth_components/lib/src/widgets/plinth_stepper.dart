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
  });

  final List<PlinthStep> steps;

  /// Which way the sequence runs.
  final Axis direction;

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
                  margin: EdgeInsets.only(left: _circleSize / 2 - 1),
                  color: connectorColor(i),
                ),
              ),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(child: stepAt(i)),
          if (i != steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.only(bottom: theme.spacing[PlinthSize.lg]!),
                color: connectorColor(i),
              ),
            ),
        ],
      ],
    );
  }
}

/// The step marker's diameter. Fixed rather than themed — the
/// connector has to line up with its centre, and a stepper is chrome
/// around a flow rather than a sized control.
const double _circleSize = 32;

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
  });

  final PlinthStep step;
  final int index;
  final _StepState state;
  final Color activeColor;
  final VoidCallback? onTap;
  final Axis direction;

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
      width: _circleSize,
      height: _circleSize,
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
          ? Icon(Icons.check, size: 16, color: theme.contrastingOn(activeColor))
          : Text(
              '${index + 1}',
              style: TextStyle(
                color: isFilled
                    ? theme.contrastingOn(activeColor)
                    : theme.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
    );

    final labels = [
      PlinthText(
        step.label,
        size: PlinthSize.sm,
        weight: state == _StepState.active ? FontWeight.w700 : FontWeight.w400,
        textAlign: align,
      ),
      if (step.description != null)
        PlinthText(
          step.description!,
          size: PlinthSize.xs,
          color: 'gray',
          textAlign: align,
        ),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(radius == null ? 999 : theme.radius[radius!]!),
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
    );
  }
}
