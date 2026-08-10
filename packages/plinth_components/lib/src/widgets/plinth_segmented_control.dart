import 'package:flutter/material.dart';
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
class PlinthSegmentedControl<T> extends StatelessWidget {
  const PlinthSegmentedControl({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.color,
    this.size = PlinthSize.md,
    this.fullWidth = false,
  });

  final List<PlinthSegmentedControlItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;
  final String? color;
  final PlinthSize size;

  /// Stretches segments to fill available width when true (default
  /// sizes each segment to its label).
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
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
          onTap: () => onChanged(item.value),
          fillColor: theme.color(colorKey, 6),
          radius: resolvedRadius,
          verticalPadding: verticalPadding,
          horizontalPadding: horizontalPadding,
          fontSize: fontSize,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
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
    required this.onTap,
    required this.fillColor,
    required this.radius,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.fontSize,
  });

  final PlinthSegmentedControlItem<T> item;
  final bool selected;
  final VoidCallback onTap;
  final Color fillColor;
  final double radius;
  final double verticalPadding;
  final double horizontalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 2)]
              : null,
        ),
        child: Text(
          item.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? fillColor : Colors.black54,
          ),
        ),
      ),
    );
  }
}
