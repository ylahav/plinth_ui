import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_close_button.dart';
import 'plinth_text.dart';

/// A draggable, resizable panel, matching Mantine's `FloatingWindow`.
///
/// Not a modal and not a dialog: it stays where it's put, several can
/// be open at once, and nothing behind it is blocked. The use is a
/// tool palette, an inspector, a preview you want beside your work
/// rather than over it.
///
/// Position and size are presentation-local and kept here — a window
/// the user dragged is a view preference, not application state.
/// [onMoved] and [onResized] report changes for callers restoring a
/// layout between sessions.
///
/// Drag the header to move it, the bottom-right corner to resize.
/// Both are clamped to the parent's bounds, so a window can't be
/// dragged off the edge and stranded where its header is unreachable.
///
/// Expects a bounded parent — put it in a [Stack] that fills the area
/// it should float over.
///
/// ```dart
/// Stack(
///   children: [
///     const Workspace(),
///     PlinthFloatingWindow(
///       title: 'Inspector',
///       onClose: () => setState(() => _showInspector = false),
///       child: const Inspector(),
///     ),
///   ],
/// )
/// ```
class PlinthFloatingWindow extends StatefulWidget {
  const PlinthFloatingWindow({
    super.key,
    required this.child,
    this.title,
    this.initialOffset = const Offset(40, 40),
    this.initialSize = const Size(280, 200),
    this.minSize = const Size(160, 120),
    this.resizable = true,
    this.onClose,
    this.onMoved,
    this.onResized,
    this.radius,
  });

  final Widget child;
  final String? title;

  final Offset initialOffset;
  final Size initialSize;
  final Size minSize;

  final bool resizable;

  /// Null hides the close button. A window with no way out is a trap,
  /// so provide one unless something else closes it.
  final VoidCallback? onClose;

  final ValueChanged<Offset>? onMoved;
  final ValueChanged<Size>? onResized;

  final PlinthSize? radius;

  @override
  State<PlinthFloatingWindow> createState() => _PlinthFloatingWindowState();
}

class _PlinthFloatingWindowState extends State<PlinthFloatingWindow> {
  late Offset _offset = widget.initialOffset;
  late Size _size = widget.initialSize;

  void _move(Offset delta, BoxConstraints bounds) {
    final next = Offset(
      (_offset.dx + delta.dx)
          .clamp(0.0, math.max(0.0, bounds.maxWidth - _size.width)),
      (_offset.dy + delta.dy)
          .clamp(0.0, math.max(0.0, bounds.maxHeight - _size.height)),
    );
    if (next == _offset) return;
    setState(() => _offset = next);
    widget.onMoved?.call(next);
  }

  void _resize(Offset delta, BoxConstraints bounds) {
    final next = Size(
      (_size.width + delta.dx).clamp(widget.minSize.width,
          math.max(widget.minSize.width, bounds.maxWidth - _offset.dx)),
      (_size.height + delta.dy).clamp(widget.minSize.height,
          math.max(widget.minSize.height, bounds.maxHeight - _offset.dy)),
    );
    if (next == _size) return;
    setState(() => _size = next);
    widget.onResized?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final radius = theme.radius[widget.radius ?? PlinthSize.md]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              left: _offset.dx,
              top: _offset.dy,
              width: _size.width,
              height: _size.height,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(color: theme.border),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadow.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (d) => _move(d.delta, constraints),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.move,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: theme.spacing[PlinthSize.sm]!,
                              vertical: theme.spacing[PlinthSize.xs]! * 0.6,
                            ),
                            color: theme.surfaceMuted,
                            child: Row(
                              children: [
                                Expanded(
                                  child: PlinthText(
                                    widget.title ?? '',
                                    size: PlinthSize.sm,
                                    weight: FontWeight.w600,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.onClose != null)
                                  PlinthCloseButton(
                                    size: PlinthSize.xs,
                                    onPressed: widget.onClose,
                                    semanticLabel: widget.title == null
                                        ? 'Close window'
                                        : 'Close ${widget.title}',
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.all(theme.spacing[PlinthSize.sm]!),
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.resizable)
              Positioned(
                left: _offset.dx + _size.width - 16,
                top: _offset.dy + _size.height - 16,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeDownRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (d) => _resize(d.delta, constraints),
                    child: Semantics(
                      label: 'Resize window',
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CustomPaint(
                          painter: _GripPainter(color: theme.borderMuted),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The diagonal hatching that says "drag me" on a resize corner.
class _GripPainter extends CustomPainter {
  const _GripPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    for (var i = 1; i <= 3; i++) {
      final offset = i * 4.0;
      canvas.drawLine(
        Offset(size.width - offset, size.height),
        Offset(size.width, size.height - offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GripPainter old) => old.color != color;
}
