import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Two resizable panes with a draggable divider, matching Mantine's
/// `Splitter`.
///
/// The divider position is presentation-local, like [PlinthSpoiler]'s
/// expanded state: it's a view preference, not application data, and
/// making every caller hold a double to get a draggable divider would
/// be friction with nothing behind it. [onFractionChanged] reports
/// moves for the callers who do want to persist it.
///
/// ```dart
/// PlinthSplitter(
///   first: const FileTree(),
///   second: const Editor(),
///   initialFraction: 0.3,
/// )
/// ```
class PlinthSplitter extends StatefulWidget {
  const PlinthSplitter({
    super.key,
    required this.first,
    required this.second,
    this.direction = Axis.horizontal,
    this.initialFraction = 0.5,
    this.minFraction = 0.1,
    this.maxFraction = 0.9,
    this.thickness = 8,
    this.onFractionChanged,
  }) : assert(
          initialFraction > 0 && initialFraction < 1,
          'initialFraction must be between 0 and 1',
        );

  final Widget first;
  final Widget second;

  /// `horizontal` puts the panes side by side with a vertical divider.
  final Axis direction;

  final double initialFraction;

  /// Bounds the drag, so a pane can't be dragged away entirely and
  /// left with no handle to drag back.
  final double minFraction;
  final double maxFraction;

  final double thickness;

  final ValueChanged<double>? onFractionChanged;

  @override
  State<PlinthSplitter> createState() => _PlinthSplitterState();
}

class _PlinthSplitterState extends State<PlinthSplitter> {
  late double _fraction = widget.initialFraction;
  bool _dragging = false;

  void _drag(double delta, double extent) {
    if (extent <= 0) return;
    final next = (_fraction + delta / extent)
        .clamp(widget.minFraction, widget.maxFraction);
    if (next == _fraction) return;

    setState(() => _fraction = next);
    widget.onFractionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final horizontal = widget.direction == Axis.horizontal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final extent =
            horizontal ? constraints.maxWidth : constraints.maxHeight;
        // Unbounded in the split direction means there's nothing to
        // divide up; fall back to letting the children size themselves.
        if (!extent.isFinite) {
          return Flex(
            direction: widget.direction,
            mainAxisSize: MainAxisSize.min,
            children: [widget.first, widget.second],
          );
        }

        final available = math.max(0.0, extent - widget.thickness);
        final firstExtent = available * _fraction;

        final divider = MouseRegion(
          key: const Key('plinth_splitter_divider'),
          cursor: horizontal
              ? SystemMouseCursors.resizeLeftRight
              : SystemMouseCursors.resizeUpDown,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart:
                horizontal ? (_) => setState(() => _dragging = true) : null,
            onHorizontalDragEnd:
                horizontal ? (_) => setState(() => _dragging = false) : null,
            onHorizontalDragUpdate:
                horizontal ? (d) => _drag(d.delta.dx, available) : null,
            onVerticalDragStart:
                horizontal ? null : (_) => setState(() => _dragging = true),
            onVerticalDragEnd:
                horizontal ? null : (_) => setState(() => _dragging = false),
            onVerticalDragUpdate:
                horizontal ? null : (d) => _drag(d.delta.dy, available),
            child: SizedBox(
              width: horizontal ? widget.thickness : null,
              height: horizontal ? null : widget.thickness,
              child: Center(
                child: Container(
                  width: horizontal ? 2 : 24,
                  height: horizontal ? 24 : 2,
                  decoration: BoxDecoration(
                    // The grip is only visible on hover or drag in most
                    // apps; here it stays, because a divider nobody can
                    // see is a divider nobody drags.
                    color: _dragging
                        ? theme.shaded(theme.primaryColor, 6)
                        : theme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        );

        return Flex(
          direction: widget.direction,
          children: [
            SizedBox(
              width: horizontal ? firstExtent : null,
              height: horizontal ? null : firstExtent,
              child: widget.first,
            ),
            divider,
            Expanded(child: widget.second),
          ],
        );
      },
    );
  }
}
