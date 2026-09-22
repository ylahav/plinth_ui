/// Two selects where the second one's options depend on the first.
///
/// Country then region, category then subcategory, project then
/// environment. The pair is everywhere, and the bug is always the same.
library;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A parent select and a child select whose options it determines.
///
/// **The bug this exists to prevent:** the user picks Portugal, then
/// Porto, then changes the country to Spain. Porto is not in Spain's
/// regions, but the child's value is still `porto` — so the form holds
/// a combination that cannot exist, and either submits it or rejects it
/// later with an error about a field the user did not touch.
///
/// Clearing the child is the obvious half. The half that gets missed is
/// **saying so**: the child resets somewhere below where the user is
/// looking, and a screen reader user hears nothing at all. They then
/// submit a form with an empty required field they were never told
/// had emptied.
///
/// The caller still owns both values. This detects the invalid
/// combination and reports it through [onChildChanged]; it does not
/// keep a copy of the state and get it out of step.
class PlinthDependentSelects<P, C> extends StatelessWidget {
  const PlinthDependentSelects({
    super.key,
    required this.parentOptions,
    required this.parentValue,
    required this.onParentChanged,
    required this.childOptionsFor,
    required this.childValue,
    required this.onChildChanged,
    this.parentLabel,
    this.childLabel,
    this.parentDescription,
    this.childDescription,
    this.childPlaceholder = 'Choose one',
    this.clearedAnnouncement,
    this.loading = false,
    this.size = PlinthSize.md,
    this.width,
  });

  final List<PlinthSelectOption<P>> parentOptions;
  final P? parentValue;
  final ValueChanged<P?> onParentChanged;

  /// The child's options for a given parent. Called with the *new*
  /// parent when it changes, so an empty list is a legitimate answer
  /// and disables the child rather than showing stale choices.
  final List<PlinthSelectOption<C>> Function(P? parent) childOptionsFor;

  final C? childValue;
  final ValueChanged<C?> onChildChanged;

  final String? parentLabel;
  final String? childLabel;
  final String? parentDescription;
  final String? childDescription;
  final String childPlaceholder;

  /// What is said when the child is cleared. Defaults to naming the
  /// child field, which is the part the user needs — "cleared" alone
  /// does not say what was cleared.
  final String? clearedAnnouncement;

  /// Passed to the child, for options fetched rather than computed.
  final bool loading;

  final PlinthSize size;
  final double? width;

  void _onParent(BuildContext context, P? next) {
    onParentChanged(next);

    // Nothing was chosen below, so there is nothing to invalidate.
    if (childValue == null) return;

    final stillValid = childOptionsFor(next).any((o) => o.value == childValue);
    if (stillValid) return;

    onChildChanged(null);
    PlinthAnnounce.say(
      context,
      clearedAnnouncement ??
          '${childLabel ?? 'The dependent field'} was cleared, '
              'because it does not apply to the new selection',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final childOptions = childOptionsFor(parentValue);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          PlinthSelect<P>(
            label: parentLabel,
            description: parentDescription,
            options: parentOptions,
            value: parentValue,
            size: size,
            onChanged: (next) => _onParent(context, next),
          ),
          SizedBox(height: theme.space(4)),
          PlinthSelect<C>(
            label: childLabel,
            description: childDescription,
            placeholder: childPlaceholder,
            options: childOptions,
            value: childValue,
            size: size,
            loading: loading,

            // Disabled rather than empty-with-a-caret: an enabled
            // select that opens onto nothing tells the user they did
            // something wrong, when the truth is that the field above
            // has not been answered yet.
            onChanged: childOptions.isEmpty ? null : onChildChanged,
          ),
        ],
      ),
    );
  }
}
