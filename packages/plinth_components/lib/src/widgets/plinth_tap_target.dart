import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Gives [child] at least the theme's [PlinthDensity.minTapTarget] in
/// both directions, without changing how it looks.
///
/// Plinth sizes like the web library it is modelled on, so its controls
/// clear WCAG 2.2 AA's 24x24 and miss iOS's 44 and Android's 48 —
/// measured across eleven controls, none of which passed either
/// platform bar at default size. On a desktop that is the right answer;
/// on a phone it is not, and this is how an app says which it is:
///
/// ```dart
/// ThemeData(extensions: [
///   PlinthTheme.defaultTheme.copyWith(density: PlinthDensity.touch),
/// ])
/// ```
///
/// **The control itself grows**, rather than gaining transparent
/// padding around a smaller painted box. Flutter's own
/// `MaterialTapTargetSize` takes the other approach and needs a custom
/// render object to do it; the widget-level version of that shrink-wraps
/// its child, which quietly collapsed every `fullWidth: true` button to
/// the width of its label. A golden caught it. Growing the control is
/// both simpler and what density usually means — a touch-density button
/// is a taller button.
///
/// A control already larger than the floor passes through untouched, so
/// this costs nothing at [PlinthDensity.standard], where every Plinth
/// control already clears 24.
class PlinthTapTarget extends StatelessWidget {
  const PlinthTapTarget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final floor = context.plinth.density.minTapTarget;
    // Deliberately just a minimum, with no alignment or shrink-wrap.
    // Anything that centres the child also changes how it sizes, and a
    // tap-target floor has no business doing that: it has to be
    // transparent to a Row that gives unbounded width and to a child
    // that asks for infinite width.
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: floor, minHeight: floor),
      child: child,
    );
  }
}
