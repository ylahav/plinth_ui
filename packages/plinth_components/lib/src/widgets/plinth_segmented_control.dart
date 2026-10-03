import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

/// A single option in a [PlinthSegmentedControl].
class PlinthSegmentedControlItem<T> {
  const PlinthSegmentedControlItem(this.value, this.label);

  final T value;
  final String label;
}

/// A pill-shaped single-select toggle group matching Mantine's
/// `SegmentedControl`: options laid out in a row inside a rounded
/// track, with the active option's segment filled.
///
/// Like [PlinthTabs], this is a static per-segment fill rather than a
/// measured sliding indicator — segments can have different widths
/// depending on label length, and animating a highlight smoothly
/// between arbitrary-width segments needs `GlobalKey`/`RenderBox`
/// size lookups that are easy to get subtly wrong without a live SDK
/// to iterate against. A direct fill-swap keeps this simple and
/// reliable.
///
/// ```dart
/// PlinthSegmentedControl<String>(
///   value: _view,
///   onChanged: (v) => setState(() => _view = v),
///   items: const [
///     PlinthSegmentedControlItem('list', 'List'),
///     PlinthSegmentedControlItem('grid', 'Grid'),
///   ],
/// )
/// ```
///
/// ## Keyboard
///
/// The same roving-focus arrangement as [PlinthTabs], because it is
/// the same shape: the control is **one stop** in the tab order rather
/// than one per segment, the left/right arrows move between segments
/// and select as they go, `Home` and `End` reach the ends, and [loop]
/// decides whether the ends wrap. The arrows follow the reading
/// direction.
///
/// ARIA calls this a radio group rather than a tab list, which changes
/// what it announces — each segment reports being in a mutually
/// exclusive group — but not how it is driven.
///
/// ## When it does not fit
///
/// **Segments shrink and their labels truncate.** Each takes its natural
/// width while there is room; once there is not, the row divides what it
/// has and labels ellipsize. Previously the row kept every segment at
/// its label's width and overflowed — found by an app whose German
/// labels did not fit the phone, and worked around in two places.
///
/// **This is deliberately not what [PlinthTabs] does.** A tab strip that
/// outgrows its width pans horizontally, because a dozen tabs is
/// ordinary and panning to reach one is the platform's own answer. A
/// segmented control is two to four options forming a *single* choice,
/// and panning would hide options the user is choosing between. A
/// truncated label you can see beats a whole option you cannot.
///
/// The full label still reaches a screen reader, so truncation costs
/// sighted users precision and costs assistive-technology users nothing.
///
/// In an unbounded width — inside a horizontal scroll view — segments
/// keep their natural size, since there is no width to divide and
/// nothing to overflow.
class PlinthSegmentedControl<T> extends StatefulWidget {
  const PlinthSegmentedControl({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.color,
    this.size = PlinthSize.md,
    this.fullWidth = false,
    this.loop = true,
  });

  final List<PlinthSegmentedControlItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;
  final String? color;
  final PlinthSize size;

  /// Stretches segments to fill available width when true (default
  /// sizes each segment to its label).
  final bool fullWidth;

  /// Whether arrowing past either end wraps around to the other.
  final bool loop;

  @override
  State<PlinthSegmentedControl<T>> createState() =>
      _PlinthSegmentedControlState<T>();
}

class _PlinthSegmentedControlState<T> extends State<PlinthSegmentedControl<T>> {
  final Map<T, FocusNode> _nodes = {};

  FocusNode _nodeFor(T value) =>
      _nodes.putIfAbsent(value, () => FocusNode(debugLabel: 'PlinthSegment'));

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _select(T value) {
    widget.onChanged(value);
    _nodeFor(value).requestFocus();
  }

  void _move(int delta) {
    final items = widget.items;
    if (items.isEmpty) return;

    final current = items.indexWhere((i) => i.value == widget.value);
    final from = current < 0 ? 0 : current;
    final next = widget.loop
        ? (from + delta) % items.length
        : (from + delta).clamp(0, items.length - 1);

    if (next == from) return;
    _select(items[next].value);
  }

  void _jumpTo(int index) {
    final items = widget.items;
    if (items.isEmpty) return;
    final target = items[index.clamp(0, items.length - 1)];
    if (target.value == widget.value) return;
    _select(target.value);
  }

  /// What a segment wants, in logical pixels: its label at the heavier
  /// of the two weights, plus padding.
  ///
  /// Measured at **semibold** whichever segment is selected, so moving
  /// the selection does not change any segment's width. Weighing a
  /// selected label heavier than the others would make the control
  /// twitch on every tap.
  double _naturalWidth(
    String label,
    TextStyle style,
    double horizontalPadding,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.width + horizontalPadding * 2;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.home) {
      _jumpTo(0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _jumpTo(widget.items.length - 1);
      return KeyEventResult.handled;
    }

    final forward = Directionality.of(context) == TextDirection.rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;

    if (key == forward) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      _move(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    final items = widget.items;
    final value = widget.value;
    final color = widget.color;
    final size = widget.size;
    final fullWidth = widget.fullWidth;
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final resolvedRadius = theme.radius[theme.defaultRadius]!;
    final verticalPadding = theme.spacing[size]! * 0.4;
    final horizontalPadding = theme.spacing[size]!;
    final fontSize = theme.fontSizes[size]!;

    final segments = [
      for (final item in items)
        _Segment(
          item: item,
          selected: item.value == value,
          focusNode: _nodeFor(item.value),
          onKey: _onKey,
          onTap: () => _select(item.value),
          fillColor: theme.shaded(colorKey, 6),
          radius: resolvedRadius,
          verticalPadding: verticalPadding,
          horizontalPadding: horizontalPadding,
          fontSize: fontSize,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Segments shrink and truncate rather than overflow — see the
        // class doc for why this pans like `PlinthTabs` does not.
        //
        // `Flexible` only where the width is bounded, the same guard
        // `PlinthTabs` uses: a flex child in an unbounded row is a
        // layout error, and this control is small enough to sit inside
        // a horizontal scroll view where there is no width to divide.
        final canShrink = constraints.hasBoundedWidth;

        // Flex weighted by what each segment wants, not shared equally.
        // Equal shares truncate a long label while a short one keeps
        // slack — and would truncate even when the total fits, because
        // a segment wider than its 1/n share gets capped at it. Weighted
        // by natural width, a row that fits is untouched and a row that
        // does not shrinks every segment by the same proportion.
        final weights = [
          for (final item in items)
            math.max(
              1,
              _naturalWidth(
                item.label,
                TextStyle(
                  fontSize: fontSize,
                  fontWeight: theme.weight(PlinthWeight.semibold),
                ),
                horizontalPadding,
              ).round(),
            ),
        ];

        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: theme.surfaceMuted,
            borderRadius: BorderRadius.circular(resolvedRadius + 3),
          ),
          child: fullWidth
              ? Row(children: [for (final s in segments) Expanded(child: s)])
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (i, s) in segments.indexed)
                      if (canShrink)
                        Flexible(flex: weights[i], child: s)
                      else
                        s,
                  ],
                ),
        );
      },
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.item,
    required this.selected,
    required this.focusNode,
    required this.onKey,
    required this.onTap,
    required this.fillColor,
    required this.radius,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.fontSize,
  });

  final PlinthSegmentedControlItem<T> item;
  final bool selected;
  final FocusNode focusNode;
  final FocusOnKeyEventCallback onKey;
  final VoidCallback onTap;
  final Color fillColor;
  final double radius;
  final double verticalPadding;
  final double horizontalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Focus(
      focusNode: focusNode,
      // One stop for the whole control, the same roving arrangement
      // PlinthTabs uses.
      skipTraversal: !selected,
      onKeyEvent: onKey,
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        selected: selected,
        child: InkWell(
          // The Focus above owns the node.
          canRequestFocus: false,
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: AnimatedContainer(
            duration: theme.duration(PlinthSize.sm),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              // The selected segment reads as a raised chip on the muted
              // track behind it, so it takes the surface colour.
              color: selected ? theme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 2)
                    ]
                  : null,
            ),
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              // One line, clipped with an ellipsis. Without these a
              // squeezed segment wraps to two lines and changes the
              // control's height instead, which is the same bug wearing
              // a different hat. The full label still reaches a screen
              // reader — truncation is visual only.
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: selected
                    ? theme.weight(PlinthWeight.semibold)
                    : theme.weight(PlinthWeight.regular),
                color: selected ? fillColor : theme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
