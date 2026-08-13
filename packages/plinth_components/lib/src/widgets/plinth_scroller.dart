import 'package:flutter/material.dart';

import 'plinth_action_icon.dart';

/// A back-to-top affordance that appears once there is something to
/// go back to, matching Mantine's `Scroller` helpers around
/// `ScrollArea`.
///
/// Wraps a scrollable and watches its [controller]: past [threshold]
/// the button fades in, and tapping it animates back to the start.
///
/// It listens rather than rebuilding the subtree — the button's
/// visibility is driven by an [AnimatedOpacity] fed from the scroll
/// position, so scrolling a long list doesn't rebuild the list on
/// every pixel.
///
/// ```dart
/// PlinthScroller(
///   controller: _controller,
///   child: ListView(controller: _controller, children: [...]),
/// )
/// ```
class PlinthScroller extends StatefulWidget {
  const PlinthScroller({
    super.key,
    required this.controller,
    required this.child,
    this.threshold = 200,
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.all(16),
    this.duration = const Duration(milliseconds: 300),
    this.color,
    this.icon = const Icon(Icons.arrow_upward),
    this.semanticLabel = 'Back to top',
  });

  /// The same controller the scrollable inside uses. Shared rather
  /// than created here, because the child has to be built with it.
  final ScrollController controller;

  final Widget child;

  /// Pixels scrolled before the button appears.
  final double threshold;

  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;
  final Duration duration;
  final String? color;
  final Widget icon;
  final String semanticLabel;

  @override
  State<PlinthScroller> createState() => _PlinthScrollerState();
}

class _PlinthScrollerState extends State<PlinthScroller> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant PlinthScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients) return;
    final shouldShow = widget.controller.offset > widget.threshold;
    // Only when it actually crosses the line — a setState per scroll
    // pixel is the thing this widget most needs to avoid.
    if (shouldShow != _visible) setState(() => _visible = shouldShow);
  }

  void _toTop() {
    widget.controller.animateTo(
      0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Align(
            alignment: widget.alignment,
            child: Padding(
              padding: widget.padding,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: widget.duration,
                // Hidden means unreachable, not just invisible: a
                // transparent button that still takes taps is worse
                // than no button.
                child: IgnorePointer(
                  ignoring: !_visible,
                  child: Semantics(
                    button: true,
                    label: widget.semanticLabel,
                    child: PlinthActionIcon(
                      onPressed: _toTop,
                      color: widget.color,
                      icon: widget.icon,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
