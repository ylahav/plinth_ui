import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A single tab for [PlinthTabs].
class PlinthTabItem<T> {
  const PlinthTabItem(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final Widget? icon;
}

/// A themeable tab bar matching Mantine's `Tabs`: an underline
/// indicator on the active tab, theme-driven color and sizing.
///
/// Deliberately implemented as a plain row of bordered tabs rather
/// than a measured sliding-indicator animation (the kind that needs
/// `GlobalKey`/`RenderBox` size lookups to animate an indicator's
/// position between arbitrary-width tabs) — that approach is easy to
/// get subtly wrong without a live SDK to iterate against, and a
/// static per-tab underline is both simpler and just as readable.
///
/// Pair with [PlinthTabView] to switch content based on the same
/// `value`:
///
/// ```dart
/// PlinthTabs<String>(
///   value: _tab,
///   onChanged: (v) => setState(() => _tab = v),
///   tabs: const [
///     PlinthTabItem('account', 'Account'),
///     PlinthTabItem('security', 'Security'),
///   ],
/// ),
/// PlinthTabView<String>(
///   value: _tab,
///   children: const {
///     'account': Text('Account settings'),
///     'security': Text('Security settings'),
///   },
/// ),
/// ```
///
/// `direction: Axis.vertical` stacks the tabs instead, with the
/// indicator down the trailing edge — the shape a settings sidebar
/// wants, and the one where a dozen tabs stay readable.
///
/// ## Keyboard
///
/// The strip is **one stop** in the tab order, not one per tab. `Tab`
/// moves onto the selected tab and the next `Tab` leaves the strip
/// entirely — the roving-focus pattern WAI-ARIA specifies, and the
/// reason a twelve-tab settings page doesn't cost twelve presses to
/// walk past.
///
/// Once inside: the arrows along the strip's own axis move between
/// tabs (left/right when horizontal, up/down when vertical), `Home`
/// and `End` jump to the ends, and [loop] decides whether the ends
/// wrap. The arrows are direction-aware, so in an RTL locale the left
/// arrow still moves the way the strip reads.
///
/// **Moving selects.** Arrowing onto a tab reports it through
/// [onChanged] rather than only moving a focus ring, which is the
/// automatic-activation half of the ARIA pattern — right for panels
/// that are cheap to build, which is what [PlinthTabView] encourages.
/// If a panel is expensive enough that arrowing through the strip
/// should not build all of them, keep the panel behind its own
/// loading state rather than reaching for manual activation.
class PlinthTabs<T> extends StatefulWidget {
  const PlinthTabs({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.size = PlinthSize.md,
    this.color,
    this.direction = Axis.horizontal,
    this.loop = true,
  });

  final List<PlinthTabItem<T>> tabs;
  final T value;
  final ValueChanged<T> onChanged;
  final PlinthSize size;
  final String? color;

  /// Which way the strip runs. Vertical puts the tabs in a column and
  /// moves both the divider and the active indicator to their trailing
  /// edge, so the content sits to the right of the list.
  final Axis direction;

  /// Whether arrowing past either end wraps around to the other.
  ///
  /// On by default, matching Mantine. Turn it off where the strip
  /// stands for a sequence — a wizard, a set of steps — and arriving
  /// back at the first item by pressing "next" would be a lie about
  /// what comes next.
  final bool loop;

  @override
  State<PlinthTabs<T>> createState() => _PlinthTabsState<T>();
}

class _PlinthTabsState<T> extends State<PlinthTabs<T>> {
  /// One node per tab value, kept across rebuilds so focus survives
  /// the selection change an arrow key causes.
  final Map<T, FocusNode> _nodes = {};

  FocusNode _nodeFor(T value) =>
      _nodes.putIfAbsent(value, () => FocusNode(debugLabel: 'PlinthTab'));

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  /// Reports [value] and keeps focus with it — only the selected tab
  /// is in the traversal order, so leaving focus on the old one would
  /// strand it outside.
  void _select(T value) {
    widget.onChanged(value);
    _nodeFor(value).requestFocus();
  }

  void _move(int delta) {
    final tabs = widget.tabs;
    if (tabs.isEmpty) return;

    final current = tabs.indexWhere((t) => t.value == widget.value);
    final from = current < 0 ? 0 : current;
    final next = widget.loop
        ? (from + delta) % tabs.length
        : (from + delta).clamp(0, tabs.length - 1);

    if (next == from) return;
    _select(tabs[next].value);
  }

  void _jumpTo(int index) {
    final tabs = widget.tabs;
    if (tabs.isEmpty) return;
    final target = tabs[index.clamp(0, tabs.length - 1)];
    if (target.value == widget.value) return;
    _select(target.value);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    // Repeats included: holding an arrow down should keep moving, the
    // way it does in every other list.
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    final isVertical = widget.direction == Axis.vertical;

    if (key == LogicalKeyboardKey.home) {
      _jumpTo(0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _jumpTo(widget.tabs.length - 1);
      return KeyEventResult.handled;
    }

    // Only the strip's own axis, so a vertical strip doesn't swallow
    // the left/right keys a text field beside it might want.
    if (isVertical) {
      if (key == LogicalKeyboardKey.arrowUp) {
        _move(-1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        _move(1);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Horizontal reads in the locale's direction, so "next" is the
    // left arrow in an RTL one.
    final forward = Directionality.of(context) == TextDirection.rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final back = forward == LogicalKeyboardKey.arrowRight
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;

    if (key == forward) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == back) {
      _move(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    final value = widget.value;
    final size = widget.size;
    final color = widget.color;
    final direction = widget.direction;
    final tabs = widget.tabs;
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final activeColor = theme.shaded(colorKey, 6);
    final verticalPadding = theme.spacing[size]! * 0.5;
    final horizontalPadding = theme.spacing[size]!;
    final isVertical = direction == Axis.vertical;

    Widget tabButton(PlinthTabItem<T> tab) {
      final selected = tab.value == value;
      final indicator = BorderSide(
        color: selected ? activeColor : Colors.transparent,
        width: 2,
      );
      final label = PlinthText(
        tab.label,
        size: size,
        weight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? colorKey : null,
      );

      return Focus(
        focusNode: _nodeFor(tab.value),
        // Roving focus: only the selected tab is a stop in the tab
        // order, so the strip costs one press to enter and one to
        // leave however many tabs it holds.
        skipTraversal: !selected,
        onKeyEvent: _onKey,
        child: Builder(builder: (context) {
          final focused = Focus.of(context).hasFocus;

          return Semantics(
            selected: selected,
            child: InkWell(
              // The Focus above owns the node; letting the InkWell
              // claim one too would put two stops on every tab.
              canRequestFocus: false,
              onTap: () => _select(tab.value),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                decoration: BoxDecoration(
                  // Selection and focus land on the same tab while
                  // arrowing, so the tint is really saying "the strip
                  // has the keyboard" — which is the thing a pointer
                  // user never needs and a keyboard user always does.
                  color: focused ? theme.shaded(colorKey, 0) : null,
                  border: isVertical
                      ? Border(right: indicator)
                      : Border(bottom: indicator),
                ),
                child: Row(
                  // Vertical tabs are stretched to the strip's width,
                  // so their content would centre in whatever the
                  // widest label demands; a column of labels reads as
                  // a list only when they share a left edge.
                  mainAxisSize:
                      isVertical ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          size: 16,
                          color: selected ? activeColor : Colors.grey,
                        ),
                        child: tab.icon!,
                      ),
                      SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.6),
                    ],
                    // Flexible only where the width is bounded: a
                    // horizontal strip lays out inside a scroll view
                    // with no width to divide up, and a flex child
                    // there is a layout error.
                    if (isVertical) Flexible(child: label) else label,
                  ],
                ),
              ),
            ),
          );
        }),
      );
    }

    final strip = isVertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final tab in tabs) tabButton(tab)],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final tab in tabs) tabButton(tab)],
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: isVertical
            ? Border(right: BorderSide(color: theme.surfaceSunken))
            : Border(bottom: BorderSide(color: theme.surfaceSunken)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Nothing can overflow without room to overflow — and a
          // scroll view needs a bounded main axis, so a tab bar sitting
          // in a `Row`/`Column` without an `Expanded` keeps the plain
          // strip.
          if (isVertical) {
            // `stretch` needs a width to stretch to. Unbounded, the
            // column takes its widest tab's width instead, which still
            // gives every indicator the same edge to sit on.
            final sized = constraints.hasBoundedWidth
                ? strip
                : IntrinsicWidth(child: strip);
            if (!constraints.hasBoundedHeight) return sized;
            return SingleChildScrollView(child: sized);
          }

          if (!constraints.hasBoundedWidth) return strip;

          // More tabs than fit is the ordinary case on a phone, and
          // the platform answer to it is a strip that pans rather than
          // one that clips or wraps. The viewport fills the width it is
          // given, so the underline runs the width of the container the
          // way Mantine's list does, rather than stopping at the last
          // tab.
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: strip,
          );
        },
      ),
    );
  }
}

/// Switches between [children] based on [value], with a fade
/// transition. Pairs with [PlinthTabs] — pass the same `value`/type
/// parameter to both.
///
/// If [value] has no matching key in [children], renders nothing
/// (rather than throwing), since that's a recoverable state a caller
/// might hit transiently — e.g. a tab list built from async data that
/// hasn't loaded a matching panel yet.
class PlinthTabView<T> extends StatelessWidget {
  const PlinthTabView({
    super.key,
    required this.value,
    required this.children,
  });

  final T value;
  final Map<T, Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: KeyedSubtree(
        key: ValueKey(value),
        child: children[value] ?? const SizedBox.shrink(),
      ),
    );
  }
}
