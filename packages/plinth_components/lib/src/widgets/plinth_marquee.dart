import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:plinth_core/plinth_core.dart';

/// Content that scrolls past continuously, matching Mantine's
/// `Marquee`.
///
/// A logo strip, a ticker of headlines, a run of testimonials. The
/// child is repeated as many times as the width needs, so the loop has
/// no visible seam.
///
/// **Motion here is an accessibility question, not just a style one.**
/// WCAG asks that movement lasting more than five seconds can be
/// paused, and a marquee by definition never stops on its own. So this
/// honours the platform's reduce-motion setting by rendering the
/// content once, stationary, and pauses under the pointer by default.
/// Neither is optional decoration — they're the reason this is safe to
/// put on a page.
///
/// ```dart
/// PlinthMarquee(
///   child: PlinthGroup(children: [for (final l in logos) Logo(l)]),
/// )
/// ```
class PlinthMarquee extends StatefulWidget {
  const PlinthMarquee({
    super.key,
    required this.child,
    this.speed = 40,
    this.gap = PlinthSize.xl,
    this.pauseOnHover = true,
    this.reverse = false,
  });

  final Widget child;

  /// Logical pixels per second. Slow is usually right: text that moves
  /// faster than it can be read is decoration, not content.
  final double speed;

  /// Between one copy of [child] and the next.
  final PlinthSize gap;

  /// Stops while the pointer is over it. Desktop and web only —
  /// there's no hover on touch, which is why this can't be the whole
  /// accessibility story on its own.
  final bool pauseOnHover;

  /// Scroll left-to-right instead of right-to-left.
  final bool reverse;

  @override
  State<PlinthMarquee> createState() => _PlinthMarqueeState();
}

class _PlinthMarqueeState extends State<PlinthMarquee>
    with SingleTickerProviderStateMixin {
  final GlobalKey _itemKey = GlobalKey();

  /// Drives the transform without rebuilding the (potentially
  /// expensive) child on every frame.
  final ValueNotifier<double> _offset = ValueNotifier<double>(0);

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  bool _hovered = false;

  /// One copy's size, known only after it has been laid out once.
  /// Until then the marquee renders a single stationary copy, which is
  /// also exactly what it renders under reduce-motion.
  ///
  /// The height matters as much as the width: the scrolling track is
  /// deliberately wider than its viewport, so it has to be given a
  /// definite height rather than sizing to a child that overflows.
  Size? _itemSize;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant PlinthMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  void _syncTicker() {
    final shouldRun = !_reduceMotion;
    if (shouldRun && !_ticker!.isActive) {
      _lastTick = Duration.zero;
      _ticker!.start();
    } else if (!shouldRun && _ticker!.isActive) {
      _ticker!.stop();
      _offset.value = 0;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _offset.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = (elapsed - _lastTick).inMicroseconds / 1000000;
    _lastTick = elapsed;

    final size = _itemSize;
    if (size == null || size.width <= 0) return;
    if (widget.pauseOnHover && _hovered) return;

    final period = size.width + context.plinth.spacing[widget.gap]!;
    _offset.value = (_offset.value + widget.speed * delta) % period;
  }

  /// Measured after each frame rather than once, so a child that
  /// changes size — a font finishing loading, an image arriving —
  /// doesn't leave the loop wrapping at a stale width.
  void _measureAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _itemKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final measured = box.size;
      final previous = _itemSize;
      if (previous == null ||
          (measured.width - previous.width).abs() > 0.5 ||
          (measured.height - previous.height).abs() > 0.5) {
        setState(() => _itemSize = measured);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _measureAfterFrame();

    final gap = context.plinth.spacing[widget.gap]!;
    final item = _itemSize;

    // Stationary: reduce-motion, or the first frame before the child
    // has been measured. Same tree either way, so measurement still
    // happens and turning motion back on needs no extra frame.
    if (_reduceMotion || item == null || item.width <= 0) {
      return ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          child: KeyedSubtree(key: _itemKey, child: widget.child),
        ),
      );
    }

    final period = item.width + gap;

    return MouseRegion(
      onEnter: widget.pauseOnHover ? (_) => _hovered = true : null,
      onExit: widget.pauseOnHover ? (_) => _hovered = false : null,
      child: SizedBox(
        height: item.height,
        child: ClipRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Enough copies to cover the viewport plus the full
              // period the transform travels through, so no edge is
              // ever blank.
              final needed = constraints.hasBoundedWidth
                  ? (constraints.maxWidth / period).ceil() + 2
                  : 2;
              final copies = math.max(2, needed);

              // The track is wider than the viewport by design, which
              // is exactly what a Row calls an overflow. OverflowBox
              // hands it unbounded width so the intended layout stops
              // being reported as a mistake.
              return OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: ValueListenableBuilder<double>(
                  valueListenable: _offset,
                  builder: (context, value, child) {
                    final dx = widget.reverse ? value - period : -value;
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < copies; i++) ...[
                        if (i > 0) SizedBox(width: gap),
                        // Only the first copy is measured; the rest are
                        // the same widget and the same width.
                        i == 0
                            ? KeyedSubtree(key: _itemKey, child: widget.child)
                            : widget.child,
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
