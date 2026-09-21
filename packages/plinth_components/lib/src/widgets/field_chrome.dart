/// The label, description and error message a field wears, and the
/// border it wears them around.
///
/// Eleven inputs carried their own copy of this — every text field,
/// and every dropdown too: `PlinthTextInput`, `PlinthTextarea`,
/// `PlinthPasswordInput`, `PlinthNumberInput`, `PlinthPillsInput`,
/// `PlinthTagsInput`, `PlinthAutocomplete`, `PlinthSelect`,
/// `PlinthMultiSelect`, `PlinthFileInput` and `PlinthTreeSelect` —
/// byte-identical down to the same four `hasError` branches and the
/// same `* 0.4` gap. `docs/PRE_1_0_AUDIT.md` could not see it: that
/// audit compares Plinth's props against Mantine's, and the eleven
/// agreed with each other about every prop they exposed. They differed
/// only in having written it out eleven times.
///
/// The cost of that was not the duplication itself but what it did to
/// the next prop: anything that belongs on "every input" — `loading`,
/// `clearable` — was eleven edits that could be got subtly wrong in ten.
///
/// **Deliberately not exported.** This is internal machinery, and
/// promoting it to public API is a separate decision with a 1.0 in
/// front of it. A caller who wants to build a field that matches the
/// library's chrome is a real use case and a real API, not a side
/// effect of a refactor.
library;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_announce.dart';
import 'plinth_loader.dart';
import 'plinth_text.dart';

/// Whether [error] is present *and* says something.
///
/// A free function because every field needs the answer before it can
/// pick a border colour, which happens before any of them build the
/// chrome. An empty string is not an error — it is a caller who
/// cleared one and passed `''` rather than null.
bool plinthHasError(String? error) => error != null && error.isNotEmpty;

/// The border colour for a field in a given state.
///
/// Error beats focus: a focused field that is also invalid should read
/// as invalid, because that is the condition the user has to act on.
Color plinthFieldBorderColor(
  PlinthTheme theme, {
  required bool hasError,
  required bool focused,
  required String colorKey,
}) {
  if (hasError) return theme.roleShaded(PlinthRole.error, 6);
  if (focused) return theme.shaded(colorKey, 6);
  return theme.border;
}

/// The border width for a field in a given state — thicker once it is
/// focused or invalid, so the state is carried by more than hue.
double plinthFieldBorderWidth(
  PlinthTheme theme, {
  required bool hasError,
  required bool focused,
}) =>
    theme.borderWidth(hasError || focused ? PlinthSize.md : PlinthSize.xs);

/// Wraps [child] — the field itself — in its label, description and
/// error message.
class PlinthFieldChrome extends StatelessWidget {
  const PlinthFieldChrome({
    super.key,
    required this.child,
    this.label,
    this.description,
    this.error,
    this.size = PlinthSize.md,
    this.mainAxisSize = MainAxisSize.max,
  });

  /// The field. Everything else here is the frame around it.
  final Widget child;

  final String? label;
  final String? description;
  final String? error;

  /// Sizes the label. The description and error stay at `xs` in every
  /// field in the library, which is why they are not parameters.
  final PlinthSize size;

  /// `Column`'s own default, except in `PlinthAutocomplete`, which
  /// renders inside an overlay-anchoring `Semantics` group and needs
  /// `min` so the group does not claim the height of the screen.
  /// A parameter rather than a silent change, because swapping a
  /// `Column`'s main-axis size is a layout change and this refactor
  /// was supposed to have none.
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final gap = theme.spacing[PlinthSize.xs]! * 0.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: mainAxisSize,
      children: [
        if (label != null) ...[
          PlinthText(
            label!,
            size: size,
            weight: theme.weight(PlinthWeight.semibold),
          ),
          SizedBox(height: gap),
        ],
        if (description != null) ...[
          PlinthText(
            description!,
            size: PlinthSize.xs,
            color: theme.rampFor(PlinthRole.neutral),
          ),
          SizedBox(height: gap),
        ],
        child,
        if (plinthHasError(error)) ...[
          SizedBox(height: gap),

          // A live region, because an error that appears after the
          // field has been left is a change nothing else announces —
          // and it is attached to the field's message rather than to
          // the field's own label, so a reader hears what is wrong
          // rather than hearing the field named again.
          PlinthLiveRegion(
            message: error,
            child: PlinthText(
              error!,
              size: PlinthSize.xs,
              color: theme.rampFor(PlinthRole.error),
            ),
          ),
        ],
      ],
    );
  }
}

/// The busy indicator a field shows while something it depends on is in
/// flight — options being fetched, a value being validated server-side.
///
/// **A loading field stays operable**, which is where this parts company
/// with [PlinthButton]. A button mid-request drops its callback, because
/// a second press would submit twice. A field has no such hazard, and
/// disabling one would be actively harmful: an autocomplete that went
/// dead while fetching would eat the next keystroke and move focus, so
/// the user would be punished for typing faster than the network.
///
/// It is *busy*, not unavailable, and nothing here says otherwise.
class PlinthFieldLoader extends StatelessWidget {
  const PlinthFieldLoader({
    super.key,
    this.size = PlinthSize.md,
    this.label = 'Loading',
  });

  /// The field's size, which the spinner matches so that starting to
  /// load does not change the field's height.
  final PlinthSize size;

  /// What a screen reader hears on reaching the spinner.
  ///
  /// Not announced when loading starts, deliberately. An autocomplete
  /// loads on nearly every keystroke, and a live region there would
  /// talk over the thing the user is typing — which is worse than
  /// silence, because it makes the field unusable rather than merely
  /// uninformative. The node is here to be found, not to interrupt.
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    return PlinthLoader(
      dimension: theme.fontSizes[size]!,
      colorValue: theme.textMuted,
      semanticLabel: label,
    );
  }
}
