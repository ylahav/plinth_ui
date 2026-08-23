import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// When a [PlinthAnchor] shows its underline.
enum PlinthAnchorUnderline { always, hover, never }

/// Styled link text matching Mantine's `Anchor`: theme-colored, with
/// an underline on hover (desktop/web) — matches conventional link
/// affordance without needing a router integration, since this is
/// just a styled tap target, not a navigation widget itself.
///
/// ```dart
/// PlinthAnchor('Forgot password?', onTap: () {})
/// ```
class PlinthAnchor extends StatefulWidget {
  const PlinthAnchor(
    this.label, {
    super.key,
    required this.onTap,
    this.color,
    this.size = PlinthSize.md,
    this.underline = PlinthAnchorUnderline.hover,
  });

  final String label;
  final VoidCallback? onTap;
  final String? color;
  final PlinthSize size;
  final PlinthAnchorUnderline underline;

  @override
  State<PlinthAnchor> createState() => _PlinthAnchorState();
}

class _PlinthAnchorState extends State<PlinthAnchor> {
  bool _hovering = false;
  bool _focused = false;

  void _activate() => widget.onTap?.call();

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = widget.color ?? theme.primaryColor;
    // A link is text, so its colour is a foreground and has to be
    // resolved against what it sits on. It used to be `shaded(colorKey,
    // 6)` -- a raw shade -- which put the default blue at 3.56:1 on
    // white, under the body floor. Third component found with this same
    // mistake, after PlinthAlert's icons and PlinthText.
    final linkColor = theme.readableOn(colorKey, theme.surface);

    final showUnderline = switch (widget.underline) {
      PlinthAnchorUnderline.always => true,
      PlinthAnchorUnderline.never => false,
      // Focus underlines too. A ring alone is a weak signal on a line
      // of text, and the underline is the affordance a link already
      // has -- reusing it costs nothing and reads as the same thing.
      PlinthAnchorUnderline.hover => _hovering || _focused,
    };

    // FocusableActionDetector rather than MouseRegion, which is what
    // this used to be. A GestureDetector supplies a tap *action* but no
    // focus node, so this was a link a mouse could click and a screen
    // reader could activate while Tab walked straight past it -- WCAG
    // 2.1.1, found by ear rather than by any test here.
    //
    // It also decides *when* a focus ring is warranted: onShowFocusHighlight
    // fires only in traversal mode, so a tap does not leave a ring behind.
    return FocusableActionDetector(
      enabled: widget.onTap != null,
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (value) => setState(() => _hovering = value),
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      actions: <Type, Action<Intent>>{
        // Both, because the web splits them: there Enter arrives as
        // ButtonActivateIntent and Space as ActivateIntent, while every
        // other platform sends ActivateIntent for each. Handling one
        // would leave a key dead on some platform.
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => _activate(),
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) => _activate(),
        ),
      },
      child: Semantics(
        link: true,
        child: GestureDetector(
          onTap: widget.onTap,
          // WCAG 2.2 SC 2.5.8 asks 24x24 of a target. A line of 16px
          // text is 23 high, so the link missed it by a pixel -- the
          // kind of gap only a measurement finds. The box is centred on
          // the text so nothing shifts around it.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24),
            child: DecoratedBox(
              // Foreground, so the ring is painted over the link rather
              // than laid out around it. A real border would shift
              // every anchor by its own width the moment it took focus.
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  // A focus ring is non-text UI carrying meaning, so
                  // WCAG 1.4.11 asks 3:1 rather than the body floor.
                  color: _focused
                      ? theme.readableOn(colorKey, theme.surface,
                          level: PlinthContrast.nonText)
                      : Colors.transparent,
                  width: _focused ? 2 : 0,
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: linkColor,
                    fontSize: theme.fontSizes[widget.size],
                    decoration: showUnderline
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: linkColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
