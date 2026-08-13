import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plinth_core/plinth_core.dart';

/// Shows as many children as fit on one line and collapses the rest
/// into a `+N` marker, matching Mantine's `OverflowList`.
///
/// The avatar stack that ends in "+4", the tag row that doesn't wrap,
/// the attendee list in a calendar chip. Distinct from [PlinthGroup],
/// which wraps onto a second line, and from clipping, which hides the
/// overflow without admitting it exists.
///
/// How many children fit is only knowable once they have been laid
/// out, so this is a render object rather than a composition of
/// existing widgets: measuring in a `LayoutBuilder` and rebuilding
/// would cost a frame of the wrong answer every time the width
/// changed. The marker is painted directly for the same reason — its
/// text depends on the count that layout produces.
///
/// Children past the cut are still built (they have to be, to be
/// measured) but are not painted, not hit-testable, and not visible to
/// assistive technology.
///
/// ```dart
/// PlinthOverflowList(
///   children: [for (final user in users) PlinthAvatar(initials: user.initials)],
/// )
/// ```
class PlinthOverflowList extends StatelessWidget {
  const PlinthOverflowList({
    super.key,
    required this.children,
    this.gap = PlinthSize.sm,
    this.labelBuilder = _defaultLabel,
    this.size = PlinthSize.sm,
    this.color,
  });

  final List<Widget> children;

  /// Between children, and between the last visible child and the
  /// marker.
  final PlinthSize gap;

  /// Renders the marker text from the number of hidden children.
  /// Defaults to `+N`.
  final String Function(int remaining) labelBuilder;

  final PlinthSize size;

  /// Palette key for the marker. Defaults to the theme's muted text —
  /// the marker is a count, not one of the items.
  final String? color;

  static String _defaultLabel(int remaining) => '+$remaining';

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return _OverflowListLayout(
      gap: theme.spacing[gap]!,
      labelBuilder: labelBuilder,
      textDirection: Directionality.of(context),
      labelStyle: TextStyle(
        fontSize: theme.fontSizes[size],
        fontWeight: FontWeight.w600,
        color: color != null
            ? theme.readableOn(color!, theme.surface)
            : theme.textMuted,
      ),
      children: children,
    );
  }
}

class _OverflowListLayout extends MultiChildRenderObjectWidget {
  const _OverflowListLayout({
    required this.gap,
    required this.labelBuilder,
    required this.labelStyle,
    required this.textDirection,
    required super.children,
  });

  final double gap;
  final String Function(int remaining) labelBuilder;
  final TextStyle labelStyle;
  final TextDirection textDirection;

  @override
  RenderOverflowList createRenderObject(BuildContext context) {
    return RenderOverflowList(
      gap: gap,
      labelBuilder: labelBuilder,
      labelStyle: labelStyle,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderOverflowList renderObject) {
    renderObject
      ..gap = gap
      ..labelBuilder = labelBuilder
      ..labelStyle = labelStyle
      ..textDirection = textDirection;
  }
}

class _OverflowListParentData extends ContainerBoxParentData<RenderBox> {}

/// Lays [PlinthOverflowList] out and paints its `+N` marker.
///
/// Exposed so a test can assert on the counts directly: the hidden
/// children are still in the widget tree, so `find.text` can't tell
/// what was actually shown.
class RenderOverflowList extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverflowListParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverflowListParentData> {
  RenderOverflowList({
    required double gap,
    required String Function(int) labelBuilder,
    required TextStyle labelStyle,
    required TextDirection textDirection,
  })  : _gap = gap,
        _labelBuilder = labelBuilder,
        _labelStyle = labelStyle,
        _textDirection = textDirection;

  double _gap;
  double get gap => _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  String Function(int) _labelBuilder;
  set labelBuilder(String Function(int) value) {
    if (_labelBuilder == value) return;
    _labelBuilder = value;
    markNeedsLayout();
  }

  TextStyle _labelStyle;
  set labelStyle(TextStyle value) {
    if (_labelStyle == value) return;
    _labelStyle = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  int _visibleCount = 0;

  /// How many children were painted at the last layout.
  int get visibleCount => _visibleCount;

  /// How many were collapsed into the marker.
  int get overflowCount => childCount - _visibleCount;

  final TextPainter _marker = TextPainter(textAlign: TextAlign.left);
  Offset _markerOffset = Offset.zero;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverflowListParentData) {
      child.parentData = _OverflowListParentData();
    }
  }

  @override
  void dispose() {
    _marker.dispose();
    super.dispose();
  }

  Size _layoutMarker(int remaining) {
    _marker
      ..text = TextSpan(text: _labelBuilder(remaining), style: _labelStyle)
      ..textDirection = _textDirection
      ..layout();
    return _marker.size;
  }

  /// The shared fit calculation, run against real layout during
  /// [performLayout] and against dry sizes for [computeDryLayout].
  (int visible, Size size, double markerWidth) _fit(
    BoxConstraints constraints,
    List<Size> sizes,
  ) {
    final n = sizes.length;
    if (n == 0) return (0, constraints.constrain(Size.zero), 0);

    final maxWidth = constraints.maxWidth;

    var allWidth = 0.0;
    for (final s in sizes) {
      allWidth += s.width;
    }
    allWidth += _gap * (n - 1);

    var visible = n;
    var markerWidth = 0.0;

    if (allWidth > maxWidth) {
      // Walk down from "all but one" until a count fits alongside the
      // marker that count implies. The marker is measured per
      // candidate rather than reserved at a worst case, so no item is
      // dropped for space a shorter label would not have needed.
      visible = 0;
      markerWidth = _layoutMarker(n).width;
      for (var k = n - 1; k >= 0; k--) {
        final mw = _layoutMarker(n - k).width;
        var used = mw;
        for (var i = 0; i < k; i++) {
          used += sizes[i].width + _gap;
        }
        if (used <= maxWidth) {
          visible = k;
          markerWidth = mw;
          break;
        }
      }
    }

    var width = 0.0;
    var height = 0.0;
    for (var i = 0; i < visible; i++) {
      width += sizes[i].width + _gap;
      height = math.max(height, sizes[i].height);
    }
    if (visible > 0) width -= _gap;

    if (visible < n) {
      if (visible > 0) width += _gap;
      width += markerWidth;
      height = math.max(height, _marker.height);
    }

    return (visible, constraints.constrain(Size(width, height)), markerWidth);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
    final sizes = <Size>[];
    var child = firstChild;
    while (child != null) {
      sizes.add(child.getDryLayout(childConstraints));
      child = childAfter(child);
    }
    return _fit(constraints, sizes).$2;
  }

  @override
  void performLayout() {
    // Children are measured against unbounded width: what matters is
    // how wide each one wants to be, not how wide this row is.
    final childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);

    final sizes = <Size>[];
    var child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      sizes.add(child.size);
      child = childAfter(child);
    }

    final (visible, laidOut, _) = _fit(constraints, sizes);
    _visibleCount = visible;
    size = laidOut;

    var x = 0.0;
    var index = 0;
    child = firstChild;
    while (child != null) {
      final data = child.parentData! as _OverflowListParentData;
      if (index < visible) {
        data.offset = Offset(x, (size.height - sizes[index].height) / 2);
        x += sizes[index].width + _gap;
      } else {
        // Parked; never painted, but an offset is still required.
        data.offset = Offset.zero;
      }
      child = childAfter(child);
      index++;
    }

    // Only laid out when there is something to mark — a TextPainter
    // that was never given text throws on any metric.
    if (visible < sizes.length) {
      _layoutMarker(sizes.length - visible);
      _markerOffset = Offset(x, (size.height - _marker.height) / 2);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var index = 0;
    var child = firstChild;
    while (child != null) {
      if (index >= _visibleCount) break;
      final data = child.parentData! as _OverflowListParentData;
      context.paintChild(child, offset + data.offset);
      child = childAfter(child);
      index++;
    }

    if (_visibleCount < childCount) {
      _marker.paint(context.canvas, offset + _markerOffset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Only what is painted can be tapped — an invisible avatar past the
    // cut must not swallow a tap meant for the marker beside it.
    var index = 0;
    var child = firstChild;
    while (child != null && index < _visibleCount) {
      final data = child.parentData! as _OverflowListParentData;
      final hit = result.addWithPaintOffset(
        offset: data.offset,
        position: position,
        hitTest: (result, transformed) =>
            child!.hitTest(result, position: transformed),
      );
      if (hit) return true;
      child = childAfter(child);
      index++;
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    // Announcing hidden items would be worse than not showing them:
    // the count says there are more, and a screen reader walking items
    // nobody can see has no way to act on them.
    var index = 0;
    var child = firstChild;
    while (child != null && index < _visibleCount) {
      visitor(child);
      child = childAfter(child);
      index++;
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    if (_visibleCount < childCount) {
      config
        ..label = _labelBuilder(childCount - _visibleCount)
        // A label without a direction trips an assertion in the
        // semantics layer rather than rendering wrong.
        ..textDirection = _textDirection;
    }
  }
}
