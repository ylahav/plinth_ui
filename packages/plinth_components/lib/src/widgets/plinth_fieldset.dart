import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A bordered group of related fields with a legend, matching Mantine's
/// `Fieldset`.
///
/// The legend sits *in* the border rather than above it, which is what
/// distinguishes a fieldset from a titled [PlinthCard]: the frame says
/// "these belong together", and the legend names the grouping without
/// reading as a section heading for the rest of the page.
///
/// ```dart
/// PlinthFieldset(
///   legend: 'Shipping address',
///   child: PlinthStack(children: [/* fields */]),
/// )
/// ```
class PlinthFieldset extends StatelessWidget {
  const PlinthFieldset({
    super.key,
    required this.child,
    this.legend,
    this.variant = PlinthVariant.defaultVariant,
    this.radius,
    this.padding = PlinthSize.md,
    this.disabled = false,
  });

  final Widget child;

  /// Names the grouping. Announced as a label for everything inside,
  /// so a screen reader reaches "Shipping address, Street" rather than
  /// a bare "Street".
  final String? legend;

  /// `defaultVariant` draws a border; `filled` uses a muted fill with
  /// no border. Other variants fall back to the border treatment.
  final PlinthVariant variant;

  final PlinthSize? radius;
  final PlinthSize padding;

  /// Greys the contents and blocks interaction with everything inside,
  /// so a whole section can be switched off without each field needing
  /// its own `enabled` wired up.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius = theme.radius[radius ?? theme.defaultRadius]!;
    final filled = variant == PlinthVariant.filled;

    final body = Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.spacing[padding]!),
      decoration: BoxDecoration(
        color: filled ? theme.surfaceMuted : null,
        border: filled ? null : Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(resolvedRadius),
      ),
      child: child,
    );

    return Semantics(
      label: legend,
      // Container groups the children under the legend rather than
      // letting it be read as a sibling of them.
      container: true,
      enabled: !disabled,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: IgnorePointer(
          ignoring: disabled,
          child: legend == null
              ? body
              : Stack(
                  children: [
                    Padding(
                      // Room for the legend to sit over the top border.
                      padding: EdgeInsets.only(
                        top: theme.fontSizes[PlinthSize.sm]! * 0.6,
                      ),
                      child: body,
                    ),
                    Positioned(
                      left: theme.spacing[PlinthSize.sm]!,
                      top: 0,
                      child: Container(
                        // Painted on the surface so the border appears
                        // to break around the text.
                        color: filled ? null : theme.surface,
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacing[PlinthSize.xs]! * 0.4,
                        ),
                        child: ExcludeSemantics(
                          child: PlinthText(
                            legend!,
                            size: PlinthSize.sm,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
