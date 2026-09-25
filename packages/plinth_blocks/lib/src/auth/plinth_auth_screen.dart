/// The shell a sign-in screen sits in, and the strip of brand colour
/// across the top of it.
///
/// Found while converting an existing app onto Plinth, where login and
/// the boot screen were each a raw `Scaffold` with the same 8px green
/// bar at the top — the one piece of branding on an otherwise plain
/// screen, hand-written twice.
///
/// Neither of these knows anything about authentication.
/// [PlinthAuthCard] is still the form; this is the page it is centred
/// on, and the boot screen is the same shell with a [PlinthLoader] in
/// it.
library;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A band of theme colour, full width.
///
/// Knows nothing about safe areas or where it sits — [PlinthAuthScreen]
/// decides that. On its own it is the strip, so it is equally usable at
/// the top of a card or under a header.
class PlinthAccentBar extends StatelessWidget {
  const PlinthAccentBar({
    super.key,
    this.color,
    this.height = 8,
    this.shade = 6,
  });

  /// Palette key. Null takes the theme's primary colour.
  final String? color;

  /// In logical pixels, not a [PlinthSize]: this is a visual weight
  /// chosen against a specific design, not a step on the spacing scale.
  final double height;

  /// Which shade of [color]. 6 is the base shade.
  final int shade;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ColoredBox(
        color: theme.shaded(color ?? theme.primaryColor, shade),
      ),
    );
  }
}

/// A full-screen shell with an accent bar across the top and content
/// centred under it.
///
/// ```dart
/// PlinthAuthScreen(
///   accentColor: 'green',
///   child: PlinthAuthCard(onSubmit: signIn),
/// )
/// ```
///
/// The boot screen is the same call with a loader:
///
/// ```dart
/// PlinthAuthScreen(accentColor: 'green', child: const PlinthLoader())
/// ```
class PlinthAuthScreen extends StatelessWidget {
  const PlinthAuthScreen({
    super.key,
    required this.child,
    this.accentColor,
    this.accentHeight = 8,
    this.background,
    this.maxWidth = 420,
    this.padding,
  });

  /// Centred under the accent bar, inside the safe area.
  final Widget child;

  /// Palette key for the bar. Null takes the theme's primary colour.
  final String? accentColor;

  /// Height of the bar *below* the status bar — the top inset is added
  /// on top of it.
  ///
  /// **The bar is painted from the physical top edge**, and extends
  /// through whatever the status bar occupies, so the accent colour
  /// fills that strip instead of leaving a band of background above it.
  /// Drawn the other way, an 8px bar on a notched phone is either
  /// hidden under the status bar or floating below a stripe of white.
  /// Only [child] takes the safe area.
  final double accentHeight;

  /// Defaults to [PlinthTheme.surface] — plain, because the accent bar
  /// is the only colour this screen is meant to have.
  final Color? background;

  /// Caps the content width so a sign-in form does not stretch across a
  /// desktop window. Null removes the cap.
  final double? maxWidth;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final topInset = MediaQuery.paddingOf(context).top;
    final gutter = theme.space(6);

    Widget content = Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: gutter),
      child: child,
    );
    if (maxWidth case final width?) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: background ?? theme.surface,
      body: Column(
        children: [
          PlinthAccentBar(
            color: accentColor,
            height: accentHeight + topInset,
          ),
          Expanded(
            child: SafeArea(
              // The bar already covered it, and taking it twice would
              // push the content down by the inset a second time.
              top: false,
              child: Center(
                child: SingleChildScrollView(child: content),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
