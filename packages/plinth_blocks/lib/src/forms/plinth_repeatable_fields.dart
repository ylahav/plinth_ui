/// A group of rows the user can add to and take away from.
///
/// Phone numbers, email addresses, line items, team invitations. The
/// visible part is a button and a list. The part that is usually wrong
/// is what happens to focus and to what a screen reader hears.
library;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// Builds the field for one row.
///
/// [index] is the row's position, which the caller needs for its own
/// state and for a label that says *which* row this is.
typedef PlinthRepeatableRowBuilder = Widget Function(
  BuildContext context,
  int index,
);

/// Rows that can be added and removed, with the announcements that
/// makes necessary.
///
/// Adding a row moves nothing on screen that a reader would notice —
/// a new empty field appears below the last one, out of sight of
/// wherever focus was. Removing one is worse: the row the user was in
/// stops existing, and focus lands wherever Flutter decides, which is
/// usually the top of the page.
///
/// So: **adding focuses the new row**, and **removing announces what
/// went and how many are left**. Neither is visible in a screenshot and
/// both are the difference between a usable form and a maze.
class PlinthRepeatableFields extends StatefulWidget {
  const PlinthRepeatableFields({
    super.key,
    required this.count,
    required this.rowBuilder,
    required this.onAdd,
    required this.onRemove,
    this.label,
    this.description,
    this.addLabel = 'Add another',
    this.removeLabel = 'Remove',
    this.rowName = 'row',
    this.minRows = 1,
    this.maxRows,
    this.size = PlinthSize.md,
    this.width,
  });

  /// How many rows there are. The caller owns the data; this owns the
  /// chrome around it.
  final int count;

  final PlinthRepeatableRowBuilder rowBuilder;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  final String? label;
  final String? description;
  final String addLabel;

  /// The remove button's accessible name, which becomes
  /// "Remove phone number 2" rather than an unlabelled bin icon.
  final String removeLabel;

  /// What one row is called, in the announcements. Singular.
  final String rowName;

  /// Below this the remove buttons disappear rather than being
  /// disabled: a control that is always there and never works is a
  /// worse answer than one that is not there until it applies.
  final int minRows;

  final int? maxRows;
  final PlinthSize size;
  final double? width;

  @override
  State<PlinthRepeatableFields> createState() => _PlinthRepeatableFieldsState();
}

class _PlinthRepeatableFieldsState extends State<PlinthRepeatableFields> {
  /// One per row, so a newly added row can be focused.
  final _focusNodes = <FocusNode>[];

  @override
  void didUpdateWidget(PlinthRepeatableFields old) {
    super.didUpdateWidget(old);

    // Grew since the last build, and it grew because `onAdd` was
    // pressed — so put the caret where the user is about to type.
    if (widget.count > old.count) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _nodeFor(widget.count - 1).requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _nodeFor(int index) {
    while (_focusNodes.length <= index) {
      _focusNodes.add(FocusNode());
    }
    return _focusNodes[index];
  }

  void _remove(int index) {
    widget.onRemove(index);

    // Said, not shown. The row the user was in has stopped existing,
    // and a reader that was inside it hears nothing about where it
    // went or what is left.
    final remaining = widget.count - 1;
    PlinthAnnounce.say(
      context,
      '${widget.rowName} ${index + 1} removed, '
      '$remaining ${remaining == 1 ? widget.rowName : '${widget.rowName}s'} '
      'remaining',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final canRemove = widget.count > widget.minRows;
    final canAdd = widget.maxRows == null || widget.count < widget.maxRows!;

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            PlinthText(
              widget.label!,
              size: widget.size,
              weight: theme.weight(PlinthWeight.semibold),
            ),
            SizedBox(height: theme.space(1)),
          ],
          if (widget.description != null) ...[
            PlinthText(
              widget.description!,
              size: PlinthSize.xs,
              color: theme.rampFor(PlinthRole.neutral),
            ),
            SizedBox(height: theme.space(2)),
          ],
          for (var i = 0; i < widget.count; i++) ...[
            if (i > 0) SizedBox(height: theme.space(2)),

            // The row and its remove button are one thing to a reader:
            // "phone number 2, remove". Without the group, the button
            // is an unlabelled control beside an unnamed field.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Focus(
                    focusNode: _nodeFor(i),
                    child: widget.rowBuilder(context, i),
                  ),
                ),
                if (canRemove) ...[
                  SizedBox(width: theme.space(2)),
                  PlinthCloseButton(
                    size: PlinthSize.sm,
                    semanticLabel:
                        '${widget.removeLabel} ${widget.rowName} ${i + 1}',
                    onPressed: () => _remove(i),
                  ),
                ],
              ],
            ),
          ],
          SizedBox(height: theme.space(3)),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: PlinthButton(
              variant: PlinthVariant.subtle,
              size: widget.size,
              leadingIcon: const Icon(Icons.add, size: 16),
              onPressed: canAdd ? widget.onAdd : null,
              child: Text(widget.addLabel),
            ),
          ),
        ],
      ),
    );
  }
}
