/// The ring a control paints to say the keyboard is on it.
///
/// Five controls reached 1.3.0 Tab-reachable, correctly announced, and
/// invisible once reached — close button, checkbox, radio, switch and
/// chip. Each wrapped an `InkWell`, whose focus highlight is a fill
/// drawn from `ThemeData.focusColor`, and that fill was not painting.
///
/// `plinth_focus_visible_test.dart` is what found them, by comparing
/// pixels. No semantics test could: a focus ring is not in the
/// semantics tree, it is paint. Same shape as `F-4` one layer over —
/// the tree was right and the screen was wrong.
///
/// **Deliberately not exported.** Internal machinery, like
/// `PlinthFieldChrome`.
library;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Wraps [child] in a ring that appears when anything inside it has
/// the keyboard.
///
/// Painted as a **foreground** decoration with no padding, so it costs
/// no layout at all. That is not a style preference: `PlinthCloseButton`
/// is pinned at exactly 24 logical pixels and `PlinthChip` at 36 by
/// `plinth_density_test.dart`, whose comment is explicit — a control
/// that changes size "ships as a silent restyle of every screen". The
/// first version of this ring added 8px to both and that test caught
/// it.
///
/// A foreground decoration also keeps the ring out of the way of
/// `plinth_radius_coverage_test.dart`, which reads the *first*
/// descendant carrying a `decoration` to find a control's own shape.
/// An outer `decoration` here would have answered for every pill in the
/// library.
///
/// **It holds the focus flag and hands out the callback**, rather than
/// detecting focus itself or making every control stateful.
///
/// The first version wrapped the child in a `Focus` node to detect
/// focus by itself. That read as tidier and made all five controls
/// *unreachable by Tab* — the ring meant to reveal them hid them
/// completely. Adding a node to a subtree that already has one is not
/// free, whatever flags you set on it.
///
/// The second version pushed the flag into each control, which meant
/// converting five `StatelessWidget`s and tripped over static members
/// and a generic class on the way. This shape needs neither: the
/// control passes `onFocusChange` straight to the `InkWell` it already
/// had.
///
/// **Two more versions broke focus outright, both worth knowing about.**
///
/// Holding the flag in `setState` rebuilt the subtree *during* the
/// focus notification that set it. So the flag is a `ValueNotifier` and
/// the child goes through `ValueListenableBuilder`'s `child` parameter,
/// which rebuilds the decoration and leaves the control alone.
///
/// That was still not enough, for a reason that is invisible in the
/// source: **`Container` inserts a `DecoratedBox` only when its
/// decoration is non-null.** Flipping `foregroundDecoration` between
/// null and a value therefore changes the *shape* of the element tree,
/// which re-parents the child, which recreates the `InkWell`'s state,
/// which disposes the focus node at the instant it is focused. Tab
/// looked like it did nothing at all.
///
/// So the decoration is always present and merely transparent when
/// unfocused. The tree shape never changes, and neither does layout —
/// a foreground decoration costs no space either way.
class PlinthFocusRing extends StatefulWidget {
  const PlinthFocusRing({
    super.key,
    required this.builder,
    this.color,
    this.radius,
  });

  /// Builds the control, given the callback to hand to its `InkWell`'s
  /// `onFocusChange`.
  final Widget Function(ValueChanged<bool> onFocusChange) builder;

  /// Palette key for the ring. Defaults to the theme's primary.
  final String? color;

  final BorderRadius? radius;

  @override
  State<PlinthFocusRing> createState() => _PlinthFocusRingState();
}

class _PlinthFocusRingState extends State<PlinthFocusRing> {
  final _focused = ValueNotifier(false);

  @override
  void dispose() {
    _focused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final key = widget.color ?? theme.primaryColor;

    // `nonText` — WCAG 1.4.11 asks 3:1 of a focus indicator, not the
    // 4.5:1 it asks of body text. Holding a ring to the text floor
    // would darken it past what the guideline wants and make it read
    // as a border rather than as a highlight.
    final ring = theme.readableOn(
      key,
      theme.surface,
      level: PlinthContrast.nonText,
    );

    final shape =
        widget.radius ?? BorderRadius.circular(theme.radius[PlinthSize.sm]!);

    return ValueListenableBuilder<bool>(
      valueListenable: _focused,

      // Built here, outside the builder below, and passed through as
      // `child`. That is the whole trick: a focus change rebuilds the
      // decoration and leaves this widget instance alone, so the focus
      // node inside it is never disposed mid-notification.
      child: widget.builder((value) => _focused.value = value),
      builder: (context, focused, child) => Container(
        // Always non-null — see the note above about `Container` and
        // element shape. Transparent when unfocused rather than absent.
        //
        // `foregroundDecoration` rather than `decoration`, for two
        // reasons: it costs no layout, and
        // `plinth_radius_coverage_test.dart` finds a control's shape by
        // reading the first descendant with a `decoration`. An outer
        // `decoration` here would have answered for every pill in the
        // library.
        foregroundDecoration: BoxDecoration(
          borderRadius: shape,
          border: Border.all(
            color: focused ? ring : Colors.transparent,
            width: theme.borderWidth(PlinthSize.md),
          ),
        ),
        child: child,
      ),
    );
  }
}
