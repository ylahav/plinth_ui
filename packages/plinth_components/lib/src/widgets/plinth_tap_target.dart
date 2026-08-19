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
/// **It grows the target, not the control.** The visual box keeps its
/// own size; the extra room is transparent padding around it, the same
/// way Flutter's own `MaterialTapTargetSize` works. A button does not
/// become a 48px slab, it becomes a 39px button with a 48px hit area.
///
/// A control already larger than the floor is returned untouched, so
/// this costs nothing at [PlinthDensity.standard] for most of the
/// library.
class PlinthTapTarget extends StatelessWidget {
  const PlinthTapTarget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final floor = context.plinth.density.minTapTarget;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: floor, minHeight: floor),
      // `Center` with both factors at 1 rather than an `alignment:` on a
      // Container: an alignment centres the child *and* expands the box
      // to fill whatever it is given, which turns a minimum into "as
      // tall as the viewport". That mistake cost a debugging round in
      // PlinthPagination, where a fixed size had been hiding it.
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
  }
}
