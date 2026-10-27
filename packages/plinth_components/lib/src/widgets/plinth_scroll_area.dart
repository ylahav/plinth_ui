import 'package:flutter/material.dart';

/// A scrollable region with a themed, draggable scrollbar rendered
/// alongside the content, matching Mantine's `ScrollArea`.
///
/// A thin wrapper around Flutter's own `Scrollbar` + `SingleChildScrollView`
/// — Flutter's default scrollbar is platform-styled and easy to miss
/// on desktop/web; this makes it always visible and thumb-draggable,
/// which is the behavior most apps actually want for a custom-styled
/// scrolling panel (a sidebar, a long settings list, a code panel).
///
/// ```dart
/// SizedBox(
///   height: 300,
///   child: PlinthScrollArea(child: Column(children: [...])),
/// )
/// ```
class PlinthScrollArea extends StatefulWidget {
  const PlinthScrollArea({
    super.key,
    required this.child,
    this.direction = Axis.vertical,
    this.controller,
  });

  final Widget child;
  final Axis direction;

  /// Use this controller instead of creating one, for a caller that also
  /// scrolls the area itself (to the top after a reload, to an error). The
  /// caller owns it and disposes it.
  final ScrollController? controller;

  @override
  State<PlinthScrollArea> createState() => _PlinthScrollAreaState();
}

class _PlinthScrollAreaState extends State<PlinthScrollArea> {
  ScrollController? _own;

  ScrollController get _controller =>
      widget.controller ?? (_own ??= ScrollController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      interactive: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: widget.direction,
        child: widget.child,
      ),
    );
  }
}
