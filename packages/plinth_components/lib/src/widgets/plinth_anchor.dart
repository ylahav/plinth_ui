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
    final linkColor = theme.color(colorKey, 6);

    final showUnderline = switch (widget.underline) {
      PlinthAnchorUnderline.always => true,
      PlinthAnchorUnderline.never => false,
      PlinthAnchorUnderline.hover => _hovering,
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            color: linkColor,
            fontSize: theme.fontSizes[widget.size],
            decoration:
                showUnderline ? TextDecoration.underline : TextDecoration.none,
            decorationColor: linkColor,
          ),
        ),
      ),
    );
  }
}
