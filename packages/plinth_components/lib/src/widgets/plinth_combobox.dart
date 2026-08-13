import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

import 'plinth_scroll_area.dart';
import 'plinth_text.dart';

/// One option in a [PlinthCombobox].
class PlinthComboboxOption<T> {
  const PlinthComboboxOption(this.value, this.label, {this.disabled = false});

  final T value;
  final String label;

  /// Skipped by keyboard navigation as well as by tapping — a
  /// disabled option the arrow keys still land on is a trap.
  final bool disabled;
}

/// The option-list primitive behind a select-shaped control, matching
/// Mantine's `Combobox`.
///
/// This is the part that is genuinely fiddly and genuinely shared: an
/// overlay anchored to a field that tracks it through scrolling, a
/// highlighted option that moves with the arrow keys and skips
/// disabled entries, Enter to take the highlight, Escape to abandon
/// it, and a list that stays in sync when its options change
/// underneath.
///
/// **Mantine's `Combobox.Dropdown` is folded in rather than exported
/// separately.** In React the dropdown is a distinct component because
/// it is a distinct piece of markup; here the overlay is plumbing, not
/// a thing a caller composes, and [PlinthPopover] already covers
/// "anchored panel with arbitrary content". A second wrapper would be
/// API surface with nothing behind it.
///
/// [PlinthSelect], [PlinthAutocomplete], [PlinthMultiSelect] and
/// [PlinthTagsInput] predate this and keep their own dropdown
/// mechanics. This is for building the next one — or a control none of
/// them cover, like a command palette.
///
/// ```dart
/// PlinthCombobox<String>(
///   controller: _dropdown,
///   target: PlinthTextInput(controller: _search),
///   options: _matches,
///   onSelected: _choose,
/// )
/// ```
class PlinthCombobox<T> extends StatefulWidget {
  const PlinthCombobox({
    super.key,
    required this.controller,
    required this.target,
    required this.options,
    required this.onSelected,
    this.selected,
    this.width,
    this.maxHeight = 240,
    this.empty,
    this.size = PlinthSize.md,
    this.color,
    this.closeOnSelect = true,
  });

  final PlinthDisclosureController controller;

  /// The field the list hangs off. Tapping it is *not* wired up —
  /// unlike [PlinthPopover], the trigger here is usually a text field
  /// that needs its taps for the caret, so opening is the caller's
  /// call.
  final Widget target;

  final List<PlinthComboboxOption<T>> options;
  final ValueChanged<T> onSelected;

  /// Marked with a check, and where the highlight starts when the list
  /// opens.
  final T? selected;

  /// Defaults to the target's width, which is what a select-shaped
  /// dropdown almost always wants.
  final double? width;

  final double maxHeight;

  /// Shown when [options] is empty. Omit to render nothing at all —
  /// an empty bordered box is worse than no box.
  final Widget? empty;

  final PlinthSize size;
  final String? color;

  final bool closeOnSelect;

  @override
  State<PlinthCombobox<T>> createState() => _PlinthComboboxState<T>();
}

class _PlinthComboboxState<T> extends State<PlinthCombobox<T>> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode(debugLabel: 'PlinthCombobox');
  OverlayEntry? _entry;

  int _highlighted = -1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    if (widget.controller.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  @override
  void didUpdateWidget(covariant PlinthCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }

    // Filtering as you type replaces the list wholesale, so a
    // highlight held by index would drift onto an unrelated option.
    if (oldWidget.options.length != widget.options.length) {
      _highlighted = _firstEnabled();
    }

    // The panel lives in an OverlayEntry, which doesn't rebuild just
    // because this widget did. Deferred because didUpdateWidget runs
    // during the build phase, where marking a non-descendant dirty is
    // illegal — the same trap PlinthPopover hit.
    if (_entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _hide();
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    widget.controller.isOpen ? _show() : _hide();
  }

  int _firstEnabled() {
    for (var i = 0; i < widget.options.length; i++) {
      if (!widget.options[i].disabled) return i;
    }
    return -1;
  }

  void _show() {
    if (_entry != null) return;

    // Opening onto the current value rather than the top of the list:
    // the first arrow press should move from where you are.
    final current =
        widget.options.indexWhere((o) => o.value == widget.selected);
    _highlighted = current >= 0 ? current : _firstEnabled();

    _entry = OverlayEntry(builder: _buildPanel);
    Overlay.of(context).insert(_entry!);

    // Take keyboard control, but only if nothing inside the target
    // already has it. `hasFocus` covers descendants, so a text-field
    // target keeps its caret and the arrow keys still reach this node
    // by bubbling; a target that took no focus at all (a button, say)
    // would otherwise leave the list unreachable from the keyboard.
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
  }

  // No setState in either direction: this widget's own build depends
  // on none of it — the panel is the overlay's, and the highlight is
  // read only while building the panel. Calling setState here would
  // also fire during dispose, where it is illegal.
  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  /// Steps to the next selectable option, skipping disabled ones and
  /// stopping at the ends rather than wrapping — wrapping past the
  /// bottom of a long filtered list reads as a glitch.
  void _move(int delta) {
    if (widget.options.isEmpty) return;

    var next = _highlighted;
    for (var i = 0; i < widget.options.length; i++) {
      next += delta;
      if (next < 0 || next >= widget.options.length) return;
      if (!widget.options[next].disabled) {
        _highlighted = next;
        _entry?.markNeedsBuild();
        return;
      }
    }
  }

  void _select(PlinthComboboxOption<T> option) {
    if (option.disabled) return;
    widget.onSelected(option.value);
    if (widget.closeOnSelect) widget.controller.close();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    // Closed, the arrow keys belong to whatever the target is.
    if (!widget.controller.isOpen) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        widget.controller.open();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _move(1);
      case LogicalKeyboardKey.arrowUp:
        _move(-1);
      case LogicalKeyboardKey.enter:
        if (_highlighted >= 0 && _highlighted < widget.options.length) {
          _select(widget.options[_highlighted]);
        } else {
          return KeyEventResult.ignored;
        }
      case LogicalKeyboardKey.escape:
        widget.controller.close();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  Widget _buildPanel(BuildContext overlayContext) {
    final theme = context.plinth;
    final radius = theme.radius[theme.defaultRadius]!;
    final colorKey = widget.color ?? theme.primaryColor;

    if (widget.options.isEmpty && widget.empty == null) {
      return const SizedBox.shrink();
    }

    // This State's context *is* the target, so its render box gives
    // the width to match without a measuring wrapper.
    final box = context.findRenderObject() as RenderBox?;
    final width =
        widget.width ?? (box != null && box.hasSize ? box.size.width : null);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.controller.close,
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: width,
                constraints: BoxConstraints(maxHeight: widget.maxHeight),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: theme.border),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadow.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.options.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(theme.spacing[PlinthSize.sm]!),
                        child: widget.empty,
                      )
                    : PlinthScrollArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < widget.options.length; i++)
                              _OptionRow(
                                option: widget.options[i],
                                highlighted: i == _highlighted,
                                selected:
                                    widget.options[i].value == widget.selected,
                                size: widget.size,
                                colorKey: colorKey,
                                onTap: () => _select(widget.options[i]),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        focusNode: _focusNode,
        // A key handler rather than a shortcut map: these keys have to
        // be intercepted before the text field inside the target sees
        // them, and only while the list is open.
        onKeyEvent: _onKey,
        child: widget.target,
      ),
    );
  }
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.highlighted,
    required this.selected,
    required this.size,
    required this.colorKey,
    required this.onTap,
  });

  final PlinthComboboxOption<T> option;
  final bool highlighted;
  final bool selected;
  final PlinthSize size;
  final String colorKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Semantics(
      button: true,
      selected: selected,
      enabled: !option.disabled,
      label: option.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: option.disabled ? null : onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing[PlinthSize.sm]!,
            vertical: theme.spacing[PlinthSize.xs]! * 0.8,
          ),
          color: highlighted ? theme.shaded(colorKey, 0) : null,
          child: Row(
            children: [
              Expanded(
                child: PlinthText(
                  option.label,
                  size: size,
                  color: option.disabled ? 'gray' : null,
                  weight: selected ? FontWeight.w600 : null,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected)
                Icon(
                  Icons.check,
                  size: theme.fontSizes[size],
                  color: theme.shaded(colorKey, 6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
