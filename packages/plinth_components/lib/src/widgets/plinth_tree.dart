import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// One node in a [PlinthTree].
class PlinthTreeNode {
  const PlinthTreeNode({
    required this.value,
    required this.label,
    this.children = const [],
    this.icon,
  });

  /// Identity, unique across the whole tree — expansion and selection
  /// are tracked by this rather than by position, so a tree can be
  /// reordered or lazily filled without losing its open branches.
  final String value;

  final String label;
  final List<PlinthTreeNode> children;
  final Widget? icon;

  bool get hasChildren => children.isNotEmpty;
}

/// Hierarchical navigation with expandable branches, matching
/// Mantine's `Tree`.
///
/// Controlled, like the rest of the library: it owns neither which
/// branches are open nor what is selected, and reports the set it
/// would become. That matters more here than elsewhere — a file tree
/// that loads children on expand, or restores its open branches
/// between sessions, needs that state to live above the widget.
///
/// Keyboard traversal works the way a tree is expected to: arrow
/// up/down move between visible rows (Flutter's own directional
/// traversal, since every row is focusable), right opens a branch or
/// steps into it, left closes it or steps out to the parent.
///
/// ```dart
/// PlinthTree(
///   nodes: _nodes,
///   expanded: _expanded,
///   onExpandedChanged: (e) => setState(() => _expanded = e),
///   selected: _selected,
///   onSelected: (v) => setState(() => _selected = v),
/// )
/// ```
class PlinthTree extends StatelessWidget {
  const PlinthTree({
    super.key,
    required this.nodes,
    required this.expanded,
    this.onExpandedChanged,
    this.selected,
    this.onSelected,
    this.size = PlinthSize.md,
    this.color,
    this.indent = 20,
  });

  final List<PlinthTreeNode> nodes;

  /// Values of the open branches.
  final Set<String> expanded;

  /// Null leaves every branch fixed as given.
  final ValueChanged<Set<String>>? onExpandedChanged;

  final String? selected;
  final ValueChanged<String>? onSelected;

  final PlinthSize size;
  final String? color;

  /// Pixels of indent per level.
  final double indent;

  /// Every node the current expansion makes visible, in render order,
  /// paired with its depth and its parent.
  List<_VisibleNode> _flatten() {
    final out = <_VisibleNode>[];

    void walk(List<PlinthTreeNode> level, int depth, String? parent) {
      for (final node in level) {
        out.add(_VisibleNode(node: node, depth: depth, parent: parent));
        if (node.hasChildren && expanded.contains(node.value)) {
          walk(node.children, depth + 1, node.value);
        }
      }
    }

    walk(nodes, 0, null);
    return out;
  }

  void _toggle(String value) {
    final next = Set<String>.from(expanded);
    if (!next.remove(value)) next.add(value);
    onExpandedChanged?.call(next);
  }

  void _open(String value) {
    if (expanded.contains(value)) return;
    onExpandedChanged?.call(Set<String>.from(expanded)..add(value));
  }

  void _close(String value) {
    if (!expanded.contains(value)) return;
    onExpandedChanged?.call(Set<String>.from(expanded)..remove(value));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _flatten();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in visible)
          _TreeRow(
            key: ValueKey(entry.node.value),
            entry: entry,
            isExpanded: expanded.contains(entry.node.value),
            isSelected: selected == entry.node.value,
            size: size,
            color: color,
            indent: indent,
            onTap: () {
              onSelected?.call(entry.node.value);
              if (entry.node.hasChildren) _toggle(entry.node.value);
            },
            onExpand:
                entry.node.hasChildren ? () => _open(entry.node.value) : null,
            onCollapse: () {
              // Left on an open branch closes it; on anything else it
              // steps out to the parent, which is what makes the key
              // useful on a leaf rather than a no-op.
              if (entry.node.hasChildren &&
                  expanded.contains(entry.node.value)) {
                _close(entry.node.value);
              } else if (entry.parent != null) {
                onSelected?.call(entry.parent!);
              }
            },
          ),
      ],
    );
  }
}

class _VisibleNode {
  const _VisibleNode({
    required this.node,
    required this.depth,
    required this.parent,
  });

  final PlinthTreeNode node;
  final int depth;
  final String? parent;
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    super.key,
    required this.entry,
    required this.isExpanded,
    required this.isSelected,
    required this.size,
    required this.color,
    required this.indent,
    required this.onTap,
    required this.onExpand,
    required this.onCollapse,
  });

  final _VisibleNode entry;
  final bool isExpanded;
  final bool isSelected;
  final PlinthSize size;
  final String? color;
  final double indent;
  final VoidCallback onTap;
  final VoidCallback? onExpand;
  final VoidCallback onCollapse;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
        if (onExpand != null && !isExpanded) {
          onExpand!();
        } else {
          return KeyEventResult.ignored;
        }
      case LogicalKeyboardKey.arrowLeft:
        onCollapse();
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        onTap();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final fontSize = theme.fontSizes[size]!;

    return Semantics(
      button: true,
      selected: isSelected,
      // Null for a leaf: announcing "collapsed" on something that can
      // never open is worse than saying nothing.
      expanded: entry.node.hasChildren ? isExpanded : null,
      label: entry.node.label,
      excludeSemantics: true,
      child: Focus(
        onKeyEvent: _onKey,
        child: Builder(
          builder: (context) {
            final focused = Focus.of(context).hasFocus;

            return InkWell(
              onTap: onTap,
              onFocusChange: (_) {},
              child: Container(
                padding: EdgeInsets.only(
                  left: theme.spacing[PlinthSize.xs]! + entry.depth * indent,
                  right: theme.spacing[PlinthSize.xs]!,
                  top: theme.spacing[PlinthSize.xs]! * 0.6,
                  bottom: theme.spacing[PlinthSize.xs]! * 0.6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.shaded(colorKey, 0)
                      : focused
                          ? theme.surfaceMuted
                          : null,
                  borderRadius:
                      BorderRadius.circular(theme.radius[PlinthSize.xs]!),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: fontSize * 1.1,
                      child: entry.node.hasChildren
                          ? Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_right,
                              size: fontSize * 1.1,
                              color: theme.textMuted,
                            )
                          // Leaves still reserve the caret's width, so
                          // labels line up down a level instead of
                          // stepping in and out.
                          : null,
                    ),
                    if (entry.node.icon != null) ...[
                      SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.5),
                      IconTheme.merge(
                        data: IconThemeData(
                          size: fontSize,
                          color: theme.textMuted,
                        ),
                        child: entry.node.icon!,
                      ),
                    ],
                    SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
                    Flexible(
                      child: PlinthText(
                        entry.node.label,
                        size: size,
                        weight: isSelected ? FontWeight.w600 : null,
                        color: isSelected ? colorKey : null,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
