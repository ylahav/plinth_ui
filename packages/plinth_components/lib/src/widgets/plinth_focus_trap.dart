import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keeps keyboard focus inside an overlay, and gives it back when the
/// overlay goes away.
///
/// **Why this exists, and why only for some overlays.** A route gets a
/// `FocusScope` from Flutter for free, so anything opened with
/// `showGeneralDialog` — [PlinthModal], [PlinthDrawer] — already
/// contains Tab. An [OverlayEntry] does not: it sits in the *same*
/// route and the same focus scope as the page behind it, so Tab walks
/// straight out of the panel and into content the user cannot see.
/// Measured before this was written: Popover, Menu and Combobox all
/// leaked; Modal and Drawer did not.
///
/// ```dart
/// PlinthFocusTrap(
///   onEscape: controller.close,
///   child: myPanel,
/// )
/// ```
///
/// Three things, all of which a trap needs to be usable rather than
/// merely correct:
///
/// - **Focus moves in** when the trap mounts, so the first Tab lands
///   inside the panel rather than teleporting somewhere behind it.
/// - **Focus goes back** to whatever held it before — usually the
///   trigger — when the trap is disposed. Without this, closing a menu
///   drops the user at the top of the page and they have to Tab all the
///   way back.
/// - **Escape calls [onEscape]**, because a keyboard user who cannot
///   leave by Tab needs a way out that is not the mouse.
///
/// **Not for the dropdown family.** `Combobox`, `Autocomplete` and
/// `MultiSelect` also leak Tab, and a trap is the wrong fix: focus
/// should stay in the text field while the list is open, with arrow
/// keys moving a highlighted option. That is roving focus, and trapping
/// them would make them worse.
class PlinthFocusTrap extends StatefulWidget {
  const PlinthFocusTrap({
    super.key,
    required this.child,
    this.onEscape,
    this.autofocus = true,
  });

  final Widget child;

  /// Called when Escape is pressed inside the trap. Usually the
  /// controller's `close`.
  final VoidCallback? onEscape;

  /// Whether to move focus into the trap when it mounts.
  ///
  /// Leave this on unless something inside is claiming focus itself —
  /// a text field with its own `autofocus`, say — in which case two
  /// requests race and the loser wins silently.
  final bool autofocus;

  @override
  State<PlinthFocusTrap> createState() => _PlinthFocusTrapState();
}

class _PlinthFocusTrapState extends State<PlinthFocusTrap> {
  late final FocusScopeNode _scope =
      FocusScopeNode(debugLabel: 'PlinthFocusTrap');

  /// Whatever held focus when this opened, so it can be handed back.
  ///
  /// Captured in `initState` rather than on first build: by the time a
  /// frame has rendered, the trap may already have taken focus and the
  /// answer would be itself.
  FocusNode? _previous;

  @override
  void initState() {
    super.initState();
    _previous = FocusManager.instance.primaryFocus;
    if (widget.autofocus) {
      // After the frame, because nothing inside is focusable until the
      // panel has actually been laid out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scope.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    final previous = _previous;
    _scope.dispose();
    // After the current frame: disposing the scope unfocuses on this
    // one, and a request made now would be undone by it.
    if (previous != null && previous.context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (previous.context != null) previous.requestFocus();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shortcuts sits *outside* the FocusScope deliberately. Key events
    // travel up from the focused node, and when nothing inside has
    // taken focus yet the focused node is the scope itself — so a
    // Shortcuts placed under the scope is not on that path, and Escape
    // silently does nothing. Costing one test to find.
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              widget.onEscape?.call();
              return null;
            },
          ),
        },
        child: FocusScope(
          node: _scope,
          // Traversal stops at the group boundary, which is what turns
          // "focus happens to be inside" into "focus cannot get out".
          child: FocusTraversalGroup(child: widget.child),
        ),
      ),
    );
  }
}
