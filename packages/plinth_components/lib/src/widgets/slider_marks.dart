import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A named position on a [PlinthSlider] or [PlinthRangeSlider] track,
/// matching Mantine's `marks`.
///
/// [value] is in the slider's own units, not a fraction: a mark at 250
/// on a 0–500 slider sits halfway along, and the same list works if the
/// range later changes.
class PlinthSliderMark {
  const PlinthSliderMark({required this.value, this.label});

  final double value;

  /// Shown under the track. A mark without one is a position nobody
  /// can read, so it renders nothing — pass `divisions` if what you
  /// wanted was ticks.
  final String? label;
}

/// The row of labels under a slider track.
///
/// Internal: exported neither from `plinth_slider.dart` nor the
/// package barrel. Callers reach it through the `marks` parameter of
/// the two sliders.
class SliderMarkLabels extends StatelessWidget {
  const SliderMarkLabels({
    super.key,
    required this.marks,
    required this.min,
    required this.max,
    required this.inset,
    required this.activeValues,
  });

  final List<PlinthSliderMark> marks;
  final double min;
  final double max;

  /// Half a thumb's width. Flutter's slider insets its track by that
  /// much at each end, so labels measured against the raw width drift
  /// inward — most visibly at the two ends, which are the marks people
  /// check alignment against.
  final double inset;

  /// The value(s) currently selected, so the label under the thumb can
  /// be emphasised. Two entries for a range slider.
  final List<double> activeValues;

  bool _isActive(PlinthSliderMark mark) =>
      activeValues.any((v) => (v - mark.value).abs() < 1e-9);

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final fontSize = theme.fontSizes[PlinthSize.xs]!;
    final labelled = marks.where((m) => m.label != null).toList();

    // A zero-width range would divide by zero, and there is nothing
    // meaningful to place along it anyway.
    if (labelled.isEmpty || max <= min) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final usable = constraints.maxWidth - inset * 2;

        return SizedBox(
          width: double.infinity,
          height: fontSize * 1.6,
          child: Stack(
            // The first and last labels stick out past the track by
            // half their width by design; clipping them would cut the
            // ends off "Off" and "Max".
            clipBehavior: Clip.none,
            children: [
              for (final mark in labelled)
                Positioned(
                  left: inset + usable * ((mark.value - min) / (max - min)),
                  top: 0,
                  // Positioned by its centre rather than its left edge:
                  // the label's width isn't known here, and a label
                  // hung off the left edge of its mark points at the
                  // wrong place by half of itself.
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, 0),
                    child: PlinthText(
                      mark.label!,
                      size: PlinthSize.xs,
                      color: _isActive(mark) ? null : 'gray',
                      weight: _isActive(mark) ? FontWeight.w700 : null,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
