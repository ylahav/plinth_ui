import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One question and its answer.
class PlinthFaqItem {
  const PlinthFaqItem({
    required this.question,
    required this.answer,
    String? value,
  }) : _value = value;

  final String question;
  final String answer;

  final String? _value;

  /// The key the accordion tracks this entry by.
  ///
  /// Defaults to the question, which is unique in every FAQ worth
  /// publishing. Pass one explicitly if two questions really do read
  /// the same.
  String get value => _value ?? question;
}

/// How a [PlinthFaqBlock] lays its questions out.
enum PlinthFaqLayout {
  /// One collapsible list. The right default: a reader scans the
  /// questions and opens the one that is theirs.
  accordion,

  /// Every question and answer visible at once, in two columns.
  ///
  /// Better when the answers are one line each — an accordion whose
  /// panels are shorter than the click that opens them is friction for
  /// no gain — and better for anyone using find-in-page, since a
  /// collapsed answer is not text on the page.
  twoColumn,
}

/// A frequently-asked-questions section.
///
/// One widget for the four FAQ arrangements, which differ in layout and
/// in what surrounds them rather than in what they are.
///
/// ```dart
/// PlinthFaqBlock(
///   title: 'Frequently asked questions',
///   searchable: true,
///   items: const [
///     PlinthFaqItem(
///       question: 'When am I billed?',
///       answer: 'On the same day each month.',
///     ),
///   ],
///   footer: PlinthButton(onPressed: contact, child: const Text('Ask us')),
/// )
/// ```
class PlinthFaqBlock extends StatefulWidget {
  const PlinthFaqBlock({
    super.key,
    required this.items,
    this.title,
    this.subtitle,
    this.layout = PlinthFaqLayout.accordion,
    this.searchable = false,
    this.searchPlaceholder = 'Search questions',
    this.emptyLabel = 'No questions match that.',
    this.footer,
    this.multiple = false,
    this.width = 560,
    this.titleOrder = 3,
  });

  final List<PlinthFaqItem> items;

  final String? title;
  final String? subtitle;
  final PlinthFaqLayout layout;

  /// Whether to offer a filter box above the questions.
  ///
  /// Worth it past roughly a dozen questions and a cost below that: a
  /// search box over six items is a control that takes longer to use
  /// than reading them.
  final bool searchable;

  final String searchPlaceholder;

  /// Shown when a search matches nothing. Not silence — an empty list
  /// with no explanation reads as a broken filter.
  final String emptyLabel;

  /// Usually a way to ask a question that isn't here.
  final Widget? footer;

  /// Whether more than one answer can be open at once. Accordion only.
  final bool multiple;

  final double? width;
  final int titleOrder;

  @override
  State<PlinthFaqBlock> createState() => _PlinthFaqBlockState();
}

class _PlinthFaqBlockState extends State<PlinthFaqBlock> {
  String _query = '';

  List<PlinthFaqItem> get _visible {
    if (_query.trim().isEmpty) return widget.items;
    final needle = _query.toLowerCase();
    // Answers too, not just questions: people search for the word they
    // remember, and it is usually in the answer.
    return widget.items
        .where((item) =>
            item.question.toLowerCase().contains(needle) ||
            item.answer.toLowerCase().contains(needle))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    final body = PlinthStack(
      gap: PlinthSize.md,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title case final title?)
          PlinthTitle(title, order: widget.titleOrder),
        if (widget.subtitle case final subtitle?)
          PlinthText(subtitle, size: PlinthSize.sm, color: 'gray'),
        if (widget.searchable)
          PlinthTextInput(
            placeholder: widget.searchPlaceholder,
            leadingIcon: const Icon(Icons.search, size: 16),
            onChanged: (value) => setState(() => _query = value),
          ),
        if (visible.isEmpty)
          PlinthText(widget.emptyLabel, size: PlinthSize.sm, color: 'gray')
        else if (widget.layout == PlinthFaqLayout.accordion)
          PlinthAccordion(
            multiple: widget.multiple,
            items: [
              for (final item in visible)
                PlinthAccordionItem(
                  value: item.value,
                  title: item.question,
                  content: PlinthText(item.answer, size: PlinthSize.sm),
                ),
            ],
          )
        else
          // `minColWidth` rather than a LayoutBuilder counting columns:
          // the grid already drops to one column when two would not
          // each get a readable measure, and two columns of three words
          // is worse than one column of sentences.
          PlinthSimpleGrid(
            columns: 2,
            minColWidth: 220,
            children: [
              for (final item in visible)
                PlinthStack(
                  gap: PlinthSize.xs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlinthText(item.question, weight: FontWeight.w600),
                    PlinthText(item.answer, size: PlinthSize.sm, color: 'gray'),
                  ],
                ),
            ],
          ),
        if (widget.footer case final footer?) footer,
      ],
    );

    return widget.width == null
        ? body
        : SizedBox(width: widget.width, child: body);
  }
}
