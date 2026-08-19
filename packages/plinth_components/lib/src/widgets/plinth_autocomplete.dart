import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_close_button.dart';
import 'plinth_highlight.dart';
import 'plinth_text.dart';

/// A text field with suggestions, matching Mantine's `Autocomplete`.
///
/// The distinction from [PlinthSelect] is what the field accepts, not
/// how it looks: a select constrains the user to your list, while this
/// takes any text and merely *offers* the list. Reach for it where the
/// options are a convenience rather than a constraint — a city, a tag,
/// an email domain the user may well need to type in full.
///
/// Suggestions filter as you type, matching anywhere in the option
/// rather than only at the start, and the matched run is highlighted so
/// it's clear why each one is being offered.
///
/// ```dart
/// PlinthAutocomplete(
///   label: 'Company',
///   value: _company,
///   options: const ['Acme', 'Globex', 'Initech'],
///   onChanged: (v) => setState(() => _company = v),
/// )
/// ```
class PlinthAutocomplete extends StatefulWidget {
  const PlinthAutocomplete({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
    this.label,
    this.description,
    this.placeholder,
    this.error,
    this.size = PlinthSize.md,
    this.color,
    this.radius,
    this.enabled = true,
    this.clearable = false,
    this.limit = 8,
    this.onOptionSelected,
  });

  /// The field's text. Controlled by the caller, like every other
  /// input here.
  final String value;
  final ValueChanged<String> onChanged;

  /// Suggestions to offer. Free text is still accepted — being absent
  /// from this list is not an error.
  final List<String> options;

  final String? label;
  final String? description;
  final String? placeholder;
  final String? error;
  final PlinthSize size;
  final String? color;
  final PlinthSize? radius;
  final bool enabled;

  /// Shows a button that empties the field, reporting an empty string.
  final bool clearable;

  /// How many suggestions to show at once. A long unfiltered list is
  /// noise rather than help.
  final int limit;

  /// Called *in addition to* [onChanged] when a suggestion is picked,
  /// for when choosing from the list should do more than set the text —
  /// filling the rest of a form from the chosen record, say.
  final ValueChanged<String>? onOptionSelected;

  @override
  State<PlinthAutocomplete> createState() => _PlinthAutocompleteState();
}

class _PlinthAutocompleteState extends State<PlinthAutocomplete> {
  final _layerLink = LayerLink();
  // The field itself, not the whole widget: the outer Column stretches
  // to whatever height it is given, so anchoring the dropdown to that
  // would drop it off the bottom of a tall parent.
  final _fieldKey = GlobalKey();
  final _focusNode = FocusNode();
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  OverlayEntry? _entry;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant PlinthAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Track an externally changed value without fighting the user's
    // in-progress typing, the same rule PlinthNumberInput follows.
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _showOptions();
    } else {
      _hideOptions();
    }
  }

  @override
  void dispose() {
    // Before the node itself, since removing the listener afterwards
    // would touch a disposed object.
    _focusNode.removeListener(_onFocusChanged);
    _hideOptions();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<String> get _matches {
    final query = _controller.text.trim().toLowerCase();
    final matches = widget.options.where((option) {
      if (query.isEmpty) return true;
      // Contains rather than startsWith: "mail" should still offer
      // "Gmail", which is usually what someone typing a fragment wants.
      return option.toLowerCase().contains(query);
    });
    return matches.take(widget.limit).toList();
  }

  void _showOptions() {
    _hideOptions();
    if (!widget.enabled || _matches.isEmpty) return;

    final theme = context.plinth;
    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;
    final fieldWidth =
        (_fieldKey.currentContext?.findRenderObject() as RenderBox?)
            ?.size
            .width;

    _entry = OverlayEntry(
      builder: (_) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 4),
        // No Align around this: an Align expands to the overlay's full
        // constraints before the follower anchors it, which pushed the
        // list a screen-height below the field. The Material sizes to
        // its own content instead, so the anchor lands where it should.
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(resolvedRadius),
          child: Container(
            width: fieldWidth,
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border.all(color: theme.border),
              borderRadius: BorderRadius.circular(resolvedRadius),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                vertical: theme.spacing[PlinthSize.xs]! * 0.5,
              ),
              children: [
                for (final option in _matches)
                  InkWell(
                    key: ValueKey('plinth_autocomplete_option_$option'),
                    onTap: () => _select(option),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing[PlinthSize.sm]!,
                        vertical: theme.spacing[PlinthSize.xs]!,
                      ),
                      child: PlinthHighlight(
                        option,
                        highlight: [_controller.text.trim()],
                        size: widget.size,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _hideOptions() {
    _entry?.remove();
    _entry = null;
  }

  void _refreshOptions() {
    if (_focusNode.hasFocus) _showOptions();
  }

  void _select(String option) {
    _controller.text = option;
    widget.onChanged(option);
    widget.onOptionSelected?.call(option);
    _hideOptions();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final colorKey = widget.color ?? theme.primaryColor;
    final resolvedRadius = theme.radius[widget.radius ?? theme.defaultRadius]!;
    final fontSize = theme.fontSizes[widget.size]!;

    final Color borderColor;
    if (hasError) {
      borderColor = theme.roleShaded(PlinthRole.error, 6);
    } else if (_isFocused) {
      borderColor = theme.shaded(colorKey, 6);
    } else {
      borderColor = theme.border;
    }

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
          link: _layerLink,
          child: Container(
            key: _fieldKey,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: Border.all(
                color: borderColor,
                width: _isFocused || hasError ? 2 : 1,
              ),
              color: widget.enabled ? theme.surface : theme.surfaceMuted,
            ),
            padding:
                EdgeInsets.symmetric(horizontal: theme.spacing[widget.size]!),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    style: TextStyle(fontSize: fontSize),
                    onChanged: (text) {
                      widget.onChanged(text);
                      // Rebuild the overlay so the list narrows as they
                      // type.
                      _refreshOptions();
                    },
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: theme.spacing[widget.size]! * 0.5,
                      ),
                    ),
                  ),
                ),
                // The controller is cleared as well as the value
                // reported: this field owns the text it displays, so
                // reporting an empty string alone would leave the old
                // text sitting there.
                if (widget.clearable &&
                    _controller.text.isNotEmpty &&
                    widget.enabled)
                  PlinthCloseButton(
                    size: PlinthSize.xs,
                    semanticLabel: 'Clear search',
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                      _refreshOptions();
                    },
                  ),
              ],
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
