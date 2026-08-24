/// Part 5 — the preparation guide, and the two ways a Flutter app can
/// say something out loud.
///
/// This screen is the reason the app exists. It is also the only place
/// in it where something changes *without the user moving*, which is
/// exactly the blind spot every semantics-tree test in the world shares:
/// a test can only find what is reachable, and a timer finishing is not.
///
/// Two mechanisms, and the choice between them is not a style question:
///
///   * **`PlinthLiveRegion`** — the step changed, and the new step is on
///     screen to be read. A live region carries the message in the tree,
///     which works on every platform.
///   * **`PlinthAnnounceWhen`** — the timer finished. Nothing lasting
///     appears, so there is no node for a reader to visit; the message
///     has to be pushed. This path is silent on Android by that
///     platform's own policy, which is why it is used only where the
///     first cannot work.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import '../model.dart';

class CookScreen extends StatefulWidget {
  const CookScreen({
    super.key,
    required this.match,
    required this.onDone,
    required this.onAbandon,
  });

  final RecipeMatch match;
  final VoidCallback onDone;
  final VoidCallback onAbandon;

  @override
  State<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends State<CookScreen> {
  int _step = 0;
  bool _finished = false;

  /// The ingredients ticked off before starting.
  final _prepped = <String>{};

  Timer? _timer;
  int _secondsLeft = 0;
  int _secondsTotal = 0;

  Recipe get _recipe => widget.match.recipe;
  RecipeStep get _current => _recipe.steps[_step];
  bool get _timerRunning => _timer != null;
  bool get _timerDone => _secondsTotal > 0 && _secondsLeft == 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _go(int index) {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _secondsLeft = 0;
      _secondsTotal = 0;
      _step = index.clamp(0, _recipe.steps.length - 1);
    });
  }

  void _startTimer() {
    final minutes = _current.minutes;
    if (minutes == null) return;
    _timer?.cancel();
    setState(() {
      _secondsTotal = minutes * 60;
      _secondsLeft = _secondsTotal;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft -= 1;
        if (_secondsLeft <= 0) {
          _secondsLeft = 0;
          timer.cancel();
          _timer = null;
        }
      });
    });
  }

  /// Skips the wait. A tutorial nobody can finish in under twenty
  /// minutes is a tutorial nobody finishes.
  void _skipTimer() {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _secondsLeft = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _Finished(recipe: _recipe, onDone: widget.onDone);

    final total = _recipe.steps.length;
    final last = _step == total - 1;

    return ListView(
      children: [
        PlinthBreadcrumbs(
          items: [
            PlinthBreadcrumbItem(label: 'Suggestions', onTap: widget.onAbandon),
            PlinthBreadcrumbItem(label: _recipe.name),
          ],
        ),
        const PlinthSpace(h: PlinthSize.sm),
        PlinthTitle(_recipe.name, order: 2),
        const PlinthSpace(h: PlinthSize.md),

        MiseEnPlace(
          match: widget.match,
          prepped: _prepped,
          onToggle: (name, on) => setState(
            () => on ? _prepped.add(name) : _prepped.remove(name),
          ),
        ),
        const PlinthSpace(h: PlinthSize.lg),

        // The stepper says where you are; `F-6` is why each step also
        // carries a spoken state rather than only a filled circle.
        PlinthStepper(
          currentStep: _step,
          onStepTapped: _go,
          direction: Axis.vertical,
          steps: [
            for (var i = 0; i < total; i++)
              PlinthStep(
                label: 'Step ${i + 1}',
                description: _recipe.steps[i].instruction,
              ),
          ],
        ),
        const PlinthSpace(h: PlinthSize.lg),

        // Moving between steps changes what is on screen, so the message
        // belongs *in the tree* — a live region, which works everywhere.
        PlinthLiveRegion(
          message: 'Step ${_step + 1} of $total. ${_current.instruction}',
          child: PlinthCard(
            withBorder: true,
            header: Row(
              children: [
                PlinthBadge(
                  'Step ${_step + 1} of $total',
                  variant: PlinthVariant.light,
                  size: PlinthSize.sm,
                ),
                const Spacer(),
                if (_current.minutes != null)
                  PlinthBadge(
                    '${_current.minutes} min',
                    color: 'gray',
                    variant: PlinthVariant.outline,
                    size: PlinthSize.sm,
                  ),
              ],
            ),
            child: PlinthStack(
              gap: PlinthSize.md,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlinthText(_current.instruction, size: PlinthSize.lg),
                if (_current.minutes != null)
                  StepTimer(
                    running: _timerRunning,
                    done: _timerDone,
                    secondsLeft: _secondsLeft,
                    secondsTotal: _secondsTotal,
                    onStart: _startTimer,
                    onSkip: _skipTimer,
                  ),
              ],
            ),
          ),
        ),
        const PlinthSpace(h: PlinthSize.md),

        PlinthGroup(
          wrap: false,
          children: [
            PlinthButton(
              onPressed: _step == 0 ? null : () => _go(_step - 1),
              variant: PlinthVariant.defaultVariant,
              leadingIcon: const Icon(Icons.arrow_back),
              child: const Text('Back'),
            ),
            Expanded(
              child: PlinthButton(
                onPressed: last
                    ? () => setState(() => _finished = true)
                    : () => _go(_step + 1),
                fullWidth: true,
                leadingIcon: Icon(last ? Icons.done_all : Icons.arrow_forward),
                child: Text(last ? 'Finished cooking' : 'Next step'),
              ),
            ),
          ],
        ),
        const PlinthSpace(h: PlinthSize.md),
        PlinthAnchor('Stop cooking this', onTap: widget.onAbandon),
        const PlinthSpace(h: PlinthSize.xl),
      ],
    );
  }
}

/// The ingredients, tickable before the cooking starts.
class MiseEnPlace extends StatelessWidget {
  const MiseEnPlace({
    super.key,
    required this.match,
    required this.prepped,
    required this.onToggle,
  });

  final RecipeMatch match;
  final Set<String> prepped;
  final void Function(String name, bool prepped) onToggle;

  @override
  Widget build(BuildContext context) {
    final needs = match.recipe.needs;
    final done = needs.where((n) => prepped.contains(n.name)).length;

    return PlinthCard(
      withBorder: true,
      header: Row(
        children: [
          const PlinthText('Everything out and measured',
              weight: FontWeight.w600),
          const Spacer(),
          PlinthText('$done of ${needs.length}', color: 'gray'),
        ],
      ),
      child: PlinthStack(
        gap: PlinthSize.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final need in needs)
            PlinthCheckbox(
              value: prepped.contains(need.name),
              onChanged: (value) => onToggle(need.name, value),
              label: '${need.name} · ${need.amount}',
            ),
        ],
      ),
    );
  }
}

/// A countdown for the steps that are mostly waiting.
///
/// The interesting line is `PlinthAnnounceWhen`. A progress bar marked
/// as a live region narrates every frame of its own animation, which is
/// unusable — but the moment it *finishes* is worth exactly one word,
/// and there is no lasting visual for a reader to find it in.
class StepTimer extends StatelessWidget {
  const StepTimer({
    super.key,
    required this.running,
    required this.done,
    required this.secondsLeft,
    required this.secondsTotal,
    required this.onStart,
    required this.onSkip,
  });

  final bool running;
  final bool done;
  final int secondsLeft;
  final int secondsTotal;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    if (secondsTotal == 0) {
      return PlinthButton(
        onPressed: onStart,
        variant: PlinthVariant.light,
        leadingIcon: const Icon(Icons.timer_outlined),
        child: const Text('Start the timer'),
      );
    }

    final elapsed = (secondsTotal - secondsLeft) / secondsTotal;

    return PlinthAnnounceWhen(
      when: done,
      message: 'Timer finished. Move on to the next step.',
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlinthProgress(
            value: elapsed,
            size: PlinthSize.md,
            color: done ? theme.roleFor('fresh').ramp : theme.primaryColor,
            semanticLabel: 'Time elapsed on this step',
          ),
          PlinthGroup(
            gap: PlinthSize.sm,
            children: [
              PlinthText(
                done ? 'Done' : _clock(secondsLeft),
                weight: FontWeight.w600,
                color: done ? theme.roleFor('fresh').ramp : null,
              ),
              if (running)
                PlinthAnchor('Skip the wait', onTap: onSkip)
              else if (!done)
                PlinthAnchor('Start again', onTap: onStart),
            ],
          ),
        ],
      ),
    );
  }

  static String _clock(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest left';
  }
}

class _Finished extends StatefulWidget {
  const _Finished({required this.recipe, required this.onDone});

  final Recipe recipe;
  final VoidCallback onDone;

  @override
  State<_Finished> createState() => _FinishedState();
}

class _FinishedState extends State<_Finished> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        PlinthAlert(
          title: '${widget.recipe.name} is done',
          icon: const Icon(Icons.done_all),
          color: context.plinth.roleFor('fresh').ramp,
          child: const Text(
            'Everything it used has been taken out of the pantry.',
          ),
        ),
        const PlinthSpace(h: PlinthSize.lg),
        PlinthCard(
          withBorder: true,
          header: const PlinthText('Was it any good?', weight: FontWeight.w600),
          child: PlinthStack(
            gap: PlinthSize.md,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlinthRating(
                value: _rating,
                onChanged: (value) => setState(() => _rating = value),
                fractions: 2,
              ),
              PlinthButton(
                onPressed: widget.onDone,
                child: const Text('Back to the pantry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
