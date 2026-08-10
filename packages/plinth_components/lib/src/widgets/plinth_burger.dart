import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// An animated hamburger-menu toggle matching Mantine's `Burger`: three
/// bars that morph into an X when [opened], for driving a nav drawer
/// or mobile menu.
///
/// This is a standalone icon control — it doesn't open anything
/// itself, `opened` is a controlled prop like the rest of Plinth's
/// toggle-style components (`PlinthCheckbox`, `PlinthSwitch`). Pair it
/// with a `PlinthDisclosureController` or your own bool state.
///
/// ```dart
/// PlinthBurger(
///   opened: _menu.isOpen,
///   onPressed: _menu.toggle,
/// )
/// ```
class PlinthBurger extends StatelessWidget {
  const PlinthBurger({
    super.key,
    required this.opened,
    this.onPressed,
    this.color,
    this.size = PlinthSize.md,
  });

  final bool opened;
  final VoidCallback? onPressed;
  final String? color;
  final PlinthSize size;

  static const Map<PlinthSize, double> _dimensions = {
    PlinthSize.xs: 24,
    PlinthSize.sm: 30,
    PlinthSize.md: 36,
    PlinthSize.lg: 44,
    PlinthSize.xl: 52,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final barColor = theme.color(colorKey, 7);
    final dimension = _dimensions[size]!;
    final barWidth = dimension * 0.5;
    // Fixed-height box the three bars are absolutely positioned
    // within — explicit pixel targets (via AnimatedPositioned) rather
    // than widget-relative offsets (AnimatedSlide), which would be
    // relative to each thin bar's own ~2px height and not produce
    // the intended movement.
    const barHeight = 2.0;
    final boxHeight = barWidth * 0.7;
    final middleY = (boxHeight - barHeight) / 2;

    return Semantics(
      button: true,
      toggled: opened,
      enabled: onPressed != null,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(dimension / 2),
        child: SizedBox(
          width: dimension,
          height: dimension,
          child: Center(
            child: SizedBox(
              width: barWidth,
              height: boxHeight,
              child: Stack(
                children: [
                  // Top bar: slides down to center and rotates +45°.
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    top: opened ? middleY : 0,
                    left: 0,
                    width: barWidth,
                    height: barHeight,
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 150),
                      turns: opened ? 0.125 : 0,
                      child: Container(color: barColor),
                    ),
                  ),
                  // Middle bar: fades out.
                  Positioned(
                    top: middleY,
                    left: 0,
                    width: barWidth,
                    height: barHeight,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: opened ? 0 : 1,
                      child: Container(color: barColor),
                    ),
                  ),
                  // Bottom bar: slides up to center and rotates -45°.
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    top: opened ? middleY : boxHeight - barHeight,
                    left: 0,
                    width: barWidth,
                    height: barHeight,
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 150),
                      turns: opened ? -0.125 : 0,
                      child: Container(color: barColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
