import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_close_button.dart';
import 'plinth_pill.dart';
import 'plinth_text.dart';

/// A single option for [PlinthMultiSelect].
class PlinthMultiSelectOption<T> {
  const PlinthMultiSelectOption(this.value, this.label);

  final T value;
  final String label;
}

/// A multi-value select matching Mantine's `MultiSelect`: chosen
/// values render as removable pills inside the field; tapping the
/// field opens a dropdown of the remaining options.
///
/// Unlike [PlinthSelect] (single value, wraps [DropdownButton]), this
/// is a bespoke implementation — [DropdownButton] has no multi-select
/// mode, and a pills-in-field layout needs its own field chrome
/// regardless.
///
/// The values are [PlinthPill]s, not [PlinthChip]s: a chip is a
/// *selectable toggle* with selected/unselected state, while a value
/// here is one entry in a collection whose only action is to leave.
/// This used Flutter's raw [Chip] until `PlinthPill` was extracted —
/// `Chip` modelled the delete affordance correctly but carried
/// Material's own sizing and colours through a themed field.
///
/// ```dart
/// PlinthMultiSelect<String>(
///   label: 'Skills',
///   value: _skills,
///   onChanged: (v) => setState(() => _skills = v),
///   options: const [
///     PlinthMultiSelectOption('dart', 'Dart'),
///     PlinthMultiSelectOption('flutter', 'Flutter'),
///   ],
/// )
/// ```
class PlinthMultiSelect<T> extends StatefulWidget {
  const PlinthMultiSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.placeholder,
    this.error,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.enabled = true,
    this.clearable = false,
  });

  final List<PlinthMultiSelectOption<T>> options;
  final List<T> value;
  final ValueChanged<List<T>> onChanged;

  /// Shows a button that empties the field in one move. Each pill can
  /// already remove itself; this is the difference between undoing a
  /// choice and starting the filter over.
  final bool clearable;
  final String? label;
  final String? description;
  final String? placeholder;
  final String? error;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool enabled;

  @override
  State<PlinthMultiSelect<T>> createState() => _PlinthMultiSelectState<T>();
}

class _PlinthMultiSelectState<T> extends State<PlinthMultiSelect<T>> {
  final _layerLink = LayerLink();
  // Anchors to the field rather than the whole widget: the outer Column
  // stretches to whatever height it is given, so linking to that put the
  // dropdown a screen-height below the field inside a tall parent.
  final _fieldKey = GlobalKey();
  OverlayEntry? _entry;

  List<PlinthMultiSelectOption<T>> get _unselected =>
      widget.options.where((o) => !widget.value.contains(o.value)).toList();

  void _toggleDropdown() {
    if (_entry != null) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!widget.enabled || _unselected.isEmpty) return;
    final theme = context.plinth;
    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final fieldWidth = renderBox?.size.width;

    _entry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 4),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(resolvedRadius),
              child: Container(
                width: fieldWidth,
                constraints: const BoxConstraints(maxHeight: 240),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(resolvedRadius),
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(
                      vertical: theme.spacing[PlinthSize.xs]! * 0.5),
                  children: [
                    for (final option in _unselected)
                      InkWell(
                        key: ValueKey(
                            'plinth_multi_select_option_${option.value}'),
                        onTap: () {
                          widget.onChanged([...widget.value, option.value]);
                          setState(() {});
                          _closeDropdown();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.spacing[PlinthSize.sm]!,
                            vertical: theme.spacing[PlinthSize.xs]!,
                          ),
                          child: Text(option.label),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _closeDropdown() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  void _removeValue(T value) {
    widget.onChanged(widget.value.where((v) => v != value).toList());
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final colorKey = widget.color ?? theme.primaryColor;
    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;
    final borderColor =
        hasError ? theme.roleShaded(PlinthRole.error, 6) : theme.border;

    final selectedLabels = {
      for (final o in widget.options) o.value: o.label,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          PlinthText(widget.label!, size: widget.size, weight: FontWeight.w600),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        if (widget.description != null) ...[
          PlinthText(widget.description!,
              size: PlinthSize.xs, color: theme.rampFor(PlinthRole.neutral)),
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
        ],
        CompositedTransformTarget(
          key: _fieldKey,
          link: _layerLink,
          // The label is a sibling of the field, so it reaches sighted
          // users and nobody else. `PlinthTreeSelect` already did this;
          // this is the same shape.
          child: Semantics(
            button: true,
            label: widget.label,
            child: InkWell(
              // Kept as-is: existing tests and callers target this key.
              key: const Key('plinth_multi_select_field'),
              onTap: _toggleDropdown,
              borderRadius: BorderRadius.circular(resolvedRadius),
              child: Container(
                constraints: BoxConstraints(
                    minHeight: theme.spacing[widget.size]! * 2.2),
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing[PlinthSize.xs]!,
                  vertical: theme.spacing[PlinthSize.xs]! * 0.6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(resolvedRadius),
                  border:
                      Border.all(color: borderColor, width: hasError ? 2 : 1),
                  color: widget.enabled ? theme.surface : theme.surfaceMuted,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: widget.value.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 6),
                              child: Text(
                                widget.placeholder ?? '',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: theme.fontSizes[widget.size]),
                              ),
                            )
                          : Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                for (final v in widget.value)
                                  PlinthPill(
                                    selectedLabels[v] ?? '$v',
                                    size: widget.size == PlinthSize.xs
                                        ? PlinthSize.xs
                                        : PlinthSize.sm,
                                    color: colorKey,
                                    onRemove: widget.enabled
                                        ? () => _removeValue(v)
                                        : null,
                                  ),
                              ],
                            ),
                    ),
                    // Each pill removes itself; this empties the field in
                    // one move, which is the difference between undoing a
                    // choice and starting the filter over.
                    if (widget.clearable &&
                        widget.value.isNotEmpty &&
                        widget.enabled)
                      PlinthCloseButton(
                        size: PlinthSize.xs,
                        semanticLabel: 'Clear all selections',
                        onPressed: () => widget.onChanged(const []),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.4),
          PlinthText(widget.error!,
              size: PlinthSize.xs, color: theme.rampFor(PlinthRole.error)),
        ],
      ],
    );
  }
}
