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
class PlinthStepper extends StatelessWidget {
  const PlinthStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
    this.color,
  });

  final List<PlinthStep> steps;

  /// Zero-based index of the active step. Steps before this are
  /// shown completed (filled circle with a check); steps after are
  /// shown pending (outlined circle with their number).
  final int currentStep;

  final ValueChanged<int>? onStepTapped;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.color(colorKey, 6);

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(
            child: _StepCircleAndLabel(
              step: steps[i],
              index: i,
              state: i < currentStep
                  ? _StepState.completed
                  : i == currentStep
                      ? _StepState.active
                      : _StepState.pending,
              activeColor: activeColor,
              onTap: onStepTapped == null ? null : () => onStepTapped!(i),
            ),
          ),
          if (i != steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.only(bottom: theme.spacing[PlinthSize.lg]!),
                color: i < currentStep ? activeColor : const Color(0xFFE9ECEF),
              ),
            ),
        ],
      ],
    );
  }
}

enum _StepState { completed, active, pending }

class _StepCircleAndLabel extends StatelessWidget {
  const _StepCircleAndLabel({
    required this.step,
    required this.index,
    required this.state,
    required this.activeColor,
    required this.onTap,
  });

  final PlinthStep step;
  final int index;
  final _StepState state;
  final Color activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final isFilled = state == _StepState.completed || state == _StepState.active;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? activeColor : Colors.white,
              border: Border.all(
                color: isFilled ? activeColor : const Color(0xFFCED4DA),
                width: 2,
              ),
            ),
            child: state == _StepState.completed
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isFilled ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
          ),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.5),
          PlinthText(
            step.label,
            size: PlinthSize.sm,
            weight: state == _StepState.active ? FontWeight.w700 : FontWeight.w400,
            textAlign: TextAlign.center,
          ),
          if (step.description != null)
            PlinthText(
              step.description!,
              size: PlinthSize.xs,
              color: 'gray',
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
