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
      PlinthAnchorUnderline.hover => _hovering,
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
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
    );
  }
}
