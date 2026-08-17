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

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.surfaceMuted,
        borderRadius: BorderRadius.circular(resolvedRadius + 3),
      ),
      child: fullWidth
          ? Row(children: [for (final s in segments) Expanded(child: s)])
          : Row(mainAxisSize: MainAxisSize.min, children: segments),
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
            duration: const Duration(milliseconds: 150),
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
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? fillColor : theme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
