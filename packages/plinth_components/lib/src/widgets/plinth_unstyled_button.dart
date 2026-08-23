import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A bare tap target with no visual chrome — no color, border,
/// padding, or ripple by default — matching Mantine's
/// `UnstyledButton`. The building block for fully custom-styled
/// clickable elements (custom cards, avatars-as-buttons, nav items
/// with bespoke layouts) where [PlinthButton]'s built-in
/// variant/color/size resolution would fight the custom look rather
/// than help it.
///
/// Still provides proper semantics (announced as a button), keyboard
/// operation, and a disabled state — the parts you'd otherwise have to
/// reimplement by hand with a bare `GestureDetector`.
///
/// ```dart
/// PlinthUnstyledButton(
///   onPressed: () => _selectCard(item),
///   child: MyCustomCard(item: item),
/// )
/// ```
///
/// **"Unstyled" stops at the focus ring.** Mantine's own
/// `UnstyledButton` renders a real `<button>`, which the browser gives
/// a focus indicator whether or not anyone styled it; a control that
/// cannot be seen to have focus is not decorated differently, it is
/// unusable by keyboard (WCAG 2.4.7). Set [focusRing] to false only
/// where the child paints its own, and then paint one.
class PlinthUnstyledButton extends StatefulWidget {
  const PlinthUnstyledButton({
    super.key,
    required this.child,
    this.onPressed,
    this.focusRing = true,
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// Whether to paint a ring while this holds keyboard focus. It is
  /// drawn as a foreground decoration, so it never changes layout.
  final bool focusRing;

  @override
  State<PlinthUnstyledButton> createState() => _PlinthUnstyledButtonState();
}

class _PlinthUnstyledButtonState extends State<PlinthUnstyledButton> {
  bool _focused = false;

  void _activate() => widget.onPressed?.call();

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    Widget target = GestureDetector(
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );

    if (widget.focusRing) {
      target = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.radius[PlinthSize.sm]!),
          border: Border.all(
            // Non-text UI carrying meaning, so WCAG 1.4.11's 3:1 rather
            // than the body floor.
            color: _focused
                ? theme.readableOn(theme.primaryColor, theme.surface,
                    level: PlinthContrast.nonText)
                : Colors.transparent,
            width: _focused ? 2 : 0,
          ),
        ),
        child: target,
      );
    }

    // A GestureDetector supplies a tap action but no focus node, so
    // this announced as a button while Tab walked straight past it --
    // the same WCAG 2.1.1 failure found in PlinthAnchor, and worse
    // here for being named one.
    return FocusableActionDetector(
      enabled: widget.onPressed != null,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      actions: <Type, Action<Intent>>{
        // The web routes Enter to ButtonActivateIntent and Space to
        // ActivateIntent; elsewhere both arrive as ActivateIntent.
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => _activate(),
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) => _activate(),
        ),
      },
      child: Semantics(
        button: true,
        enabled: widget.onPressed != null,
        child: target,
      ),
    );
  }
}
