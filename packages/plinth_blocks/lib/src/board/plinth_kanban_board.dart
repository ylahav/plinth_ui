import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One column of a [PlinthKanbanBoard].
class PlinthKanbanColumn {
  const PlinthKanbanColumn({
    required this.id,
    required this.title,
    required this.cards,
  });

  /// Identity, passed back to `onMove`. Distinct from [title] so a
  /// board can be renamed without rewriting the moves.
  final String id;

  final String title;

  /// The cards, in order.
  final List<String> cards;
}

/// A drag-and-drop board.
///
/// ```dart
/// PlinthKanbanBoard(
///   columns: _columns,
///   onMove: (card, from, to) => setState(() => move(card, from, to)),
/// )
/// ```
///
/// **Every move is available without a drag.** A drag is a pointer
/// gesture, and a board that only accepts one cannot be operated by
/// keyboard at all — WCAG 2.1.1, and the same class of defect the `F-4`
/// pass found by ear on this library's own anchors. So each card is a
/// button that opens a menu of the other columns, and dragging is the
/// shortcut rather than the mechanism.
///
/// **A completed move is announced.** A card that silently leaves one
/// column and appears in another has told the person watching and
/// nobody else.
class PlinthKanbanBoard extends StatelessWidget {
  const PlinthKanbanBoard({
    super.key,
    required this.columns,
    this.onMove,
    this.emptyLabel = 'Nothing here',
    this.moveLabel = 'Move to',
    this.columnWidth = 180,
    this.announceMoves = true,
  });

  final List<PlinthKanbanColumn> columns;

  /// Called with the card and the columns it moved between. Null makes
  /// the board read-only — cards render, nothing moves.
  final void Function(String card, String from, String to)? onMove;

  /// Shown in a column with no cards.
  final String emptyLabel;

  /// Prefix for the per-card move menu, as in "Move to Done".
  final String moveLabel;

  final double columnWidth;

  /// Whether to say a move happened. Off only when something else does.
  final bool announceMoves;

  void _move(BuildContext context, String card, String from, String to) {
    if (from == to) return;
    onMove?.call(card, from, to);
    if (announceMoves) {
      final target = columns.firstWhere((c) => c.id == to).title;
      PlinthAnnounce.say(context, '$card moved to $target');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlinthGroup(
      gap: PlinthSize.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final column in columns)
          SizedBox(
            width: columnWidth,
            child: _Column(
              column: column,
              others: columns.where((c) => c.id != column.id).toList(),
              moveLabel: moveLabel,
              emptyLabel: emptyLabel,
              enabled: onMove != null,
              onMove: (card, from, to) => _move(context, card, from, to),
            ),
          ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.column,
    required this.others,
    required this.moveLabel,
    required this.emptyLabel,
    required this.enabled,
    required this.onMove,
  });

  final PlinthKanbanColumn column;
  final List<PlinthKanbanColumn> others;
  final String moveLabel;
  final String emptyLabel;
  final bool enabled;
  final void Function(String card, String from, String to) onMove;

  @override
  Widget build(BuildContext context) {
    return DragTarget<({String card, String from})>(
      onAcceptWithDetails: (details) =>
          onMove(details.data.card, details.data.from, column.id),
      builder: (context, candidate, rejected) => PlinthPaper(
        p: PlinthSize.sm,
        withBorder: true,
        child: PlinthStack(
          gap: PlinthSize.xs,
          children: [
            PlinthText(
              column.title,
              size: PlinthSize.sm,
              weight: FontWeight.w700,
              // Highlighting the target is the whole feedback loop of a
              // drag — without it you are guessing.
              color: candidate.isEmpty ? 'gray' : 'blue',
            ),
            for (final card in column.cards)
              _Card(
                card: card,
                from: column.id,
                others: others,
                moveLabel: moveLabel,
                enabled: enabled,
                onMove: onMove,
              ),
            if (column.cards.isEmpty)
              PlinthText(emptyLabel, size: PlinthSize.xs, color: 'gray'),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  const _Card({
    required this.card,
    required this.from,
    required this.others,
    required this.moveLabel,
    required this.enabled,
    required this.onMove,
  });

  final String card;
  final String from;
  final List<PlinthKanbanColumn> others;
  final String moveLabel;
  final bool enabled;
  final void Function(String card, String from, String to) onMove;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  final _menu = PlinthDisclosureController();

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final face = PlinthPaper(
      p: PlinthSize.xs,
      withBorder: true,
      child: PlinthText(widget.card, size: PlinthSize.sm),
    );

    if (!widget.enabled || widget.others.isEmpty) return face;

    // The keyboard route. `PlinthMenu` gives it focus, arrow keys and a
    // dismissal, none of which a Draggable has.
    final keyboardRoute = PlinthMenu(
      controller: _menu,
      // Wider than PlinthMenu's 200 default, which these labels
      // overflow by 17px: "Move to" plus a column title is longer than
      // the menu items the default was sized for.
      width: 240,
      target: PlinthUnstyledButton(
        onPressed: _menu.toggle,
        child: Semantics(
          label: '${widget.card}, ${widget.moveLabel}',
          button: true,
          child: face,
        ),
      ),
      items: [
        for (final other in widget.others)
          PlinthMenuItem(
            label: '${widget.moveLabel} ${other.title}',
            onTap: () => widget.onMove(widget.card, widget.from, other.id),
          ),
      ],
    );

    return Draggable<({String card, String from})>(
      data: (card: widget.card, from: widget.from),
      feedback: PlinthBadge(widget.card, color: 'blue'),
      childWhenDragging: const SizedBox.shrink(),
      child: keyboardRoute,
    );
  }
}
