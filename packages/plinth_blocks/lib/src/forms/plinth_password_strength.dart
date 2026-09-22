import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One requirement a password has to meet.
///
/// The label and the test travel together, which is what stops a
/// checklist drifting out of step with what actually passes.
class PlinthPasswordRule {
  const PlinthPasswordRule(this.label, this.met);

  final String label;

  /// Whether [label] is satisfied by a given password.
  final bool Function(String) met;

  /// A reasonable starting set, in English.
  ///
  /// Not a policy — your server's rules are the ones that decide, and a
  /// meter that disagrees with them is worse than no meter. Pass your
  /// own; these exist so something renders before you have.
  static final List<PlinthPasswordRule> defaults = [
    PlinthPasswordRule('At least 8 characters', (v) => v.length >= 8),
    PlinthPasswordRule('Includes a number', (v) => v.contains(RegExp(r'\d'))),
    PlinthPasswordRule(
      'Includes a capital letter',
      (v) => v.contains(RegExp('[A-Z]')),
    ),
    PlinthPasswordRule(
      'Includes a symbol',
      (v) => v.contains(RegExp(r'[!@#$%^&*(),.?:{}|<>]')),
    ),
  ];
}

/// A strength meter and the checklist behind it.
///
/// Display only — the field stays yours. Put it under a
/// [PlinthPasswordInput] and feed it what was typed.
///
/// ```dart
/// PlinthPasswordInput(
///   label: 'Password',
///   onChanged: (v) => setState(() => _password = v),
/// ),
/// PlinthPasswordStrength(value: _password),
/// ```
///
/// **Three bands rather than a gradient.** The useful question is
/// whether this will be accepted, and a colour that creeps toward green
/// answers it less clearly than one that changes when the answer does.
///
/// **Every rule stays on screen, met or not.** A checklist that hides
/// what you have satisfied leaves you re-reading the remainder to work
/// out what changed.
class PlinthPasswordStrength extends StatelessWidget {
  const PlinthPasswordStrength({
    super.key,
    required this.value,
    this.rules,
    this.showChecklist = true,
    this.weakColor = 'red',
    this.fairColor = 'yellow',
    this.strongColor = 'green',
    this.width,
  });

  /// What has been typed so far.
  final String value;

  /// The requirements. Null uses [PlinthPasswordRule.defaults].
  final List<PlinthPasswordRule>? rules;

  /// Whether to list the rules under the meter.
  final bool showChecklist;

  final String weakColor;
  final String fairColor;
  final String strongColor;
  final double? width;

  List<PlinthPasswordRule> get _rules => rules ?? PlinthPasswordRule.defaults;

  /// How many rules are satisfied, from 0 to 1.
  double get strength {
    final all = _rules;
    if (all.isEmpty) return 0;
    return all.where((r) => r.met(value)).length / all.length;
  }

  String get _band => strength == 1
      ? strongColor
      : strength >= 0.5
          ? fairColor
          : weakColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final all = _rules;
    final metCount = all.where((r) => r.met(value)).length;

    final body = PlinthStack(
      gap: PlinthSize.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlinthProgress(
          value: strength,
          size: PlinthSize.xs,
          color: _band,
          semanticLabel: context.plinthStrings.passwordStrength,
        ),
        if (showChecklist)
          for (final rule in all)
            _RuleRow(rule: rule, met: rule.met(value), theme: theme)
        else
          PlinthText(
            '$metCount of ${all.length} requirements met',
            size: PlinthSize.xs,
            color: 'gray',
          ),
      ],
    );

    return width == null ? body : SizedBox(width: width, child: body);
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule, required this.met, required this.theme});

  final PlinthPasswordRule rule;
  final bool met;
  final PlinthTheme theme;

  @override
  Widget build(BuildContext context) {
    // "met" is in the label rather than carried by the icon alone: a
    // tick and a dash differ by shape as well as colour, and neither
    // of them is a word.
    return Semantics(
      label: '${rule.label}, ${met ? 'met' : 'not met'}',
      container: true,
      child: ExcludeSemantics(
        child: Row(
          children: [
            Icon(
              met ? Icons.check_circle : Icons.remove_circle_outline,
              size: 14,
              color: met
                  ? theme.readableOn('green', theme.surface)
                  : theme.textMuted,
            ),
            SizedBox(width: theme.space(2)),
            Expanded(
              child: PlinthText(
                rule.label,
                size: PlinthSize.xs,
                color: met ? null : 'gray',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
