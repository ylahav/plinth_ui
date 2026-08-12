import 'package:flutter/material.dart';

/// A bare tap target with no visual chrome — no color, border,
/// padding, or ripple by default — matching Mantine's
/// `UnstyledButton`. The building block for fully custom-styled
/// clickable elements (custom cards, avatars-as-buttons, nav items
/// with bespoke layouts) where [PlinthButton]'s built-in
/// variant/color/size resolution would fight the custom look rather
/// than help it.
///
/// Still provides proper semantics (announced as a button) and a
/// disabled state — the parts you'd otherwise have to reimplement
/// by hand with a bare `GestureDetector`.
///
/// ```dart
/// PlinthUnstyledButton(
///   onPressed: () => _selectCard(item),
///   child: MyCustomCard(item: item),
/// )
/// ```
class PlinthUnstyledButton extends StatelessWidget {
  const PlinthUnstyledButton({super.key, required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
