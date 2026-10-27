import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

import 'plinth_box.dart';
import 'plinth_button.dart';
import 'plinth_close_button.dart';
import 'plinth_localizations.dart';
import 'plinth_text.dart';
import 'overlay_host.dart';

/// An overlay dialog matching Mantine's `Modal`: centered content on a
/// dismissible backdrop, with an optional title bar and close button.
///
/// Visibility is driven by a [PlinthDisclosureController] rather than
/// Flutter's `showDialog` imperative API, so a single controller can
/// be shared between the trigger button and the modal itself (and
/// later, other overlays like Drawer can reuse the same controller
/// shape).
///
/// ```dart
/// final _modal = PlinthDisclosureController();
///
/// PlinthButton(onPressed: _modal.open, child: const Text('Open'));
///
/// PlinthModal(
///   controller: _modal,
///   title: 'Confirm',
///   child: const Text('Are you sure?'),
/// );
/// ```
///
/// [PlinthModal] renders nothing itself — call [show] to push it as a
/// route, typically from a listener on [controller]. See
/// [PlinthModalHost] for a zero-boilerplate way to wire that up.
class PlinthModal extends StatelessWidget {
  const PlinthModal({
    super.key,
    required this.controller,
    this.title,
    required this.child,
    this.size = PlinthSize.md,
    this.maxWidth,
    this.scrollable = false,
    this.closeOnBackdropTap = true,
    this.radius,
  });

  final PlinthDisclosureController controller;
  final String? title;
  final Widget child;

  /// Controls the modal's max width via the theme's spacing scale
  /// (larger [PlinthSize] -> wider modal).
  final PlinthSize size;

  /// Overrides the width [size] gives, in logical pixels. For the content
  /// that is genuinely wider than the largest step (a table, a form with
  /// two columns); the modal is still never wider than the screen.
  final double? maxWidth;

  /// Scrolls the body (not the title row) when it is taller than the screen.
  ///
  /// Off by default, as in Material's `AlertDialog`: a body that is itself a
  /// `ListView`, or a column with `Expanded` children, needs the bounded
  /// height it gets when nothing scrolls it. Turn it on for a form that can
  /// be longer than a phone is tall.
  final bool scrollable;

  final bool closeOnBackdropTap;
  final PlinthSize? radius;

  /// Pushes this modal as a dialog route. Automatically calls
  /// [PlinthDisclosureController.close] when dismissed via backdrop
  /// tap or the close button, keeping [controller] in sync with
  /// whatever else is listening to it.
  Future<void> show(BuildContext context) {
    return _showModalRoute<void>(
      context,
      title: title,
      size: size,
      maxWidth: maxWidth,
      scrollable: scrollable,
      radius: radius,
      closeOnBackdropTap: closeOnBackdropTap,
      builder: (_) => child,
    ).whenComplete(controller.close);
  }

  @override
  Widget build(BuildContext context) {
    // PlinthModal is driven imperatively via show(), not built inline
    // in the tree — see PlinthModalHost for the declarative wrapper.
    return const SizedBox.shrink();
  }
}

/// Wraps [child] and automatically calls [modal.show] whenever
/// [modal]'s controller opens, so you can declare the modal once and
/// forget about wiring listeners manually.
///
/// ```dart
/// PlinthModalHost(
///   modal: PlinthModal(controller: _modal, title: 'Hi', child: ...),
///   child: Scaffold(
///     body: PlinthButton(onPressed: _modal.open, child: const Text('Open')),
///   ),
/// )
/// ```
class PlinthModalHost extends StatelessWidget {
  const PlinthModalHost({super.key, required this.modal, required this.child});

  final PlinthModal modal;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlinthOverlayHost(
      controller: modal.controller,
      onOpen: modal.show,
      child: child,
    );
  }
}

/// Shows a modal and completes with whatever it is popped with.
///
/// [PlinthModal] is driven by a [PlinthDisclosureController], which is right
/// when a button toggles a panel and wrong when the question is "delete this?"
/// and the answer has to come back to the line that asked. This is the same
/// surface, as a route: `Navigator.pop(context, value)` from inside [builder]
/// completes the future with `value`, and dismissing it any other way (the
/// close button, the backdrop, Escape) completes it with `null`.
///
/// ```dart
/// final name = await showPlinthModal<String>(
///   context,
///   title: 'Rename',
///   builder: (context) => RenameForm(
///     onDone: (value) => Navigator.pop(context, value),
///   ),
/// );
/// ```
///
/// For the yes/no case, see [showPlinthConfirm].
Future<T?> showPlinthModal<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
  PlinthSize size = PlinthSize.md,
  double? maxWidth,
  bool scrollable = false,
  PlinthSize? radius,
  bool closeOnBackdropTap = true,
}) {
  return _showModalRoute<T>(
    context,
    title: title,
    size: size,
    maxWidth: maxWidth,
    scrollable: scrollable,
    radius: radius,
    closeOnBackdropTap: closeOnBackdropTap,
    builder: builder,
  );
}

/// Asks a yes/no question and completes with the answer.
///
/// Completes with `true` only when the person presses the confirm button.
/// Cancelling, closing, tapping the backdrop and pressing Escape all complete
/// with `false`, so `if (await showPlinthConfirm(...))` is safe to put in
/// front of anything that cannot be undone.
///
/// [destructive] colours the confirm button red: the button that deletes
/// should not look like the button that saves. Labels default to
/// [PlinthStrings.confirm] and [PlinthStrings.cancel], which an app
/// translates once for the whole library.
///
/// ```dart
/// if (await showPlinthConfirm(
///   context,
///   title: 'Delete station?',
///   message: 'Its history is deleted with it.',
///   confirmLabel: 'Delete',
///   destructive: true,
/// )) {
///   await repository.delete(station);
/// }
/// ```
Future<bool> showPlinthConfirm(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
  PlinthSize size = PlinthSize.sm,
}) async {
  assert(message == null || content == null,
      'Pass either message or content, not both.');
  final strings = context.plinthStrings;
  final theme = context.plinth;
  final answer = await showPlinthModal<bool>(
    context,
    title: title,
    size: size,
    scrollable: true,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null) PlinthText(message),
        if (content != null) content,
        SizedBox(height: theme.spacing[PlinthSize.lg]),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: theme.spacing[PlinthSize.sm]!,
          runSpacing: theme.spacing[PlinthSize.sm]!,
          children: [
            PlinthButton(
              variant: PlinthVariant.subtle,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel ?? strings.cancel),
            ),
            PlinthButton(
              color: destructive ? 'red' : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel ?? strings.confirm),
            ),
          ],
        ),
      ],
    ),
  );
  return answer ?? false;
}

Future<T?> _showModalRoute<T>(
  BuildContext context, {
  required String? title,
  required PlinthSize size,
  required double? maxWidth,
  required bool scrollable,
  required PlinthSize? radius,
  required bool closeOnBackdropTap,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: closeOnBackdropTap,
    barrierLabel: title ?? 'Modal',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: context.plinth.duration(PlinthSize.sm),
    pageBuilder: (context, _, __) => _PlinthModalSurface(
      title: title,
      size: size,
      maxWidth: maxWidth,
      scrollable: scrollable,
      radius: radius,
      child: Builder(builder: builder),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
          parent: animation, curve: context.plinth.curve(PlinthCurve.standard));
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _PlinthModalSurface extends StatelessWidget {
  const _PlinthModalSurface({
    required this.title,
    required this.size,
    required this.maxWidth,
    required this.scrollable,
    required this.radius,
    required this.child,
  });

  final String? title;
  final PlinthSize size;
  final double? maxWidth;
  final bool scrollable;
  final PlinthSize? radius;
  final Widget child;

  static const Map<PlinthSize, double> _widths = {
    PlinthSize.xs: 320,
    PlinthSize.sm: 380,
    PlinthSize.md: 440,
    PlinthSize.lg: 560,
    PlinthSize.xl: 720,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius = theme.radius[radius ?? theme.defaultRadius]!;
    final margin = theme.spacing[PlinthSize.md]!;

    // The body sits in a Flexible, so it never gets more height than the
    // screen has left. [scrollable] decides whether a taller body scrolls
    // (title row fixed) or is left to manage itself.
    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: MediaQuery.viewInsetsOf(context) + EdgeInsets.all(margin),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? _widths[size]!),
          child: Material(
            color: theme.surface,
            borderRadius: BorderRadius.circular(resolvedRadius),
            clipBehavior: Clip.antiAlias,
            child: PlinthBox(
              p: PlinthSize.lg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: PlinthText(
                            title!,
                            size: PlinthSize.lg,
                            weight: theme.weight(PlinthWeight.bold),
                          ),
                        ),
                        PlinthCloseButton(
                          size: PlinthSize.lg,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: theme.spacing[PlinthSize.sm]),
                  ],
                  Flexible(
                    child: scrollable
                        ? SingleChildScrollView(child: child)
                        : child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
