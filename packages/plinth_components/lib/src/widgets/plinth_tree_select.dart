import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

import 'plinth_popover.dart';
import 'plinth_scroll_area.dart';
import 'plinth_text.dart';
import 'plinth_tree.dart';

/// A select whose options are a hierarchy, matching Mantine's
/// `TreeSelect`.
///
/// [PlinthSelect] flattens everything into one list, which stops
/// working the moment the options have structure — a category and its
/// subcategories, a folder and its files, an org chart. This is that
/// list with the structure kept.
///
/// Opening it expands the branches leading to the current value, so a
/// deep selection is visible rather than hidden three levels down.
///
/// ```dart
/// PlinthTreeSelect(
///   label: 'Category',
///   nodes: _categories,
///   value: _selected,
///   onChanged: (v) => setState(() => _selected = v),
/// )
/// ```
class PlinthTreeSelect extends StatefulWidget {
  const PlinthTreeSelect({
    super.key,
    required this.nodes,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.placeholder = 'Select…',
    this.error,
    this.selectableBranches = true,
    this.size = PlinthSize.md,
    this.radius,
    this.enabled = true,
    this.dropdownWidth = 260,
    this.dropdownMaxHeight = 260,
  });

  final List<PlinthTreeNode> nodes;

  /// The selected node's value, or null for nothing selected.
  final String? value;

  /// Null disables the field.
  final ValueChanged<String?>? onChanged;

  final String? label;
  final String? description;
  final String placeholder;
  final String? error;

  /// When false, tapping a branch only opens it — useful when only
  /// leaves are real choices, like files in a folder tree.
  final bool selectableBranches;

  final PlinthSize size;
  final PlinthSize? radius;
  final bool enabled;

  final double dropdownWidth;
  final double dropdownMaxHeight;

  @override
  State<PlinthTreeSelect> createState() => _PlinthTreeSelectState();
}

class _PlinthTreeSelectState extends State<PlinthTreeSelect> {
  /// Owned here rather than by the caller: the dropdown is this
  /// field's own mechanism, the same call [PlinthColorInput] makes.
  final PlinthDisclosureController _dropdown = PlinthDisclosureController();

  Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _dropdown.addListener(_onDropdownChanged);
    _expanded = _ancestorsOf(widget.value);
  }

  @override
  void dispose() {
    _dropdown.removeListener(_onDropdownChanged);
    _dropdown.dispose();
    super.dispose();
  }

  void _onDropdownChanged() {
    if (!mounted || !_dropdown.isOpen) return;
    // Re-expand on every open rather than once: the value may have
    // changed while it was shut.
    setState(() => _expanded = {..._expanded, ..._ancestorsOf(widget.value)});
  }

  /// The values of every branch above [target], so opening the
  /// dropdown reveals the current selection instead of hiding it.
  Set<String> _ancestorsOf(String? target) {
    if (target == null) return {};
    final path = <String>{};

    bool walk(List<PlinthTreeNode> level, List<String> trail) {
      for (final node in level) {
        if (node.value == target) {
          path.addAll(trail);
          return true;
        }
        if (walk(node.children, [...trail, node.value])) return true;
      }
      return false;
    }

    walk(widget.nodes, const []);
    return path;
  }

  PlinthTreeNode? _find(String? target) {
    if (target == null) return null;

    PlinthTreeNode? walk(List<PlinthTreeNode> level) {
      for (final node in level) {
        if (node.value == target) return node;
        final found = walk(node.children);
        if (found != null) return found;
      }
      return null;
    }

    return walk(widget.nodes);
  }

  void _onSelected(String value) {
    final node = _find(value);
    if (node == null) return;

    if (node.hasChildren && !widget.selectableBranches) {
      // The tree has already toggled it open; choosing it would be a
      // lie about what the field now holds.
      return;
    }

    widget.onChanged?.call(value);
    _dropdown.close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final enabled = widget.enabled && widget.onChanged != null;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final selected = _find(widget.value);

    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;
    final fontSize = theme.fontSizes[widget.size]!;

    final trigger = Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing[widget.size]!,
        vertical: theme.spacing[widget.size]! * 0.5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(
          color:
              hasError ? theme.roleShaded(PlinthRole.error, 6) : theme.border,
          width: hasError ? 2 : 1,
        ),
        color: enabled ? theme.surface : theme.surfaceMuted,
      ),
      child: Row(
        children: [
          Expanded(
            child: PlinthText(
              selected?.label ?? widget.placeholder,
              size: widget.size,
              color: selected == null ? 'gray' : null,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            size: fontSize * 1.2,
            color: theme.textMuted,
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Semantics(
          button: true,
          enabled: enabled,
          label: widget.label,
          value: selected?.label ?? widget.placeholder,
          child: PlinthPopover(
            controller: _dropdown,
            width: widget.dropdownWidth,
            target: enabled
                ? trigger
                // Wrapping in IgnorePointer rather than dropping the
                // popover keeps the layout identical between states.
                : IgnorePointer(child: trigger),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.dropdownMaxHeight),
              child: PlinthScrollArea(
                child: PlinthTree(
                  nodes: widget.nodes,
                  expanded: _expanded,
                  onExpandedChanged: (e) => setState(() => _expanded = e),
                  selected: widget.value,
                  onSelected: _onSelected,
                  size: widget.size,
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
