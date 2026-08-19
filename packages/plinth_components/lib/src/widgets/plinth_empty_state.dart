import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';
import 'plinth_theme_icon.dart';
import 'plinth_title.dart';

/// The "nothing here" placeholder, matching Mantine's `EmptyState`.
///
/// Distinct from [PlinthSkeleton], which stands in for content that is
/// *coming*. This is for content that isn't there — an empty search
/// result, an unused inbox, a project with no members yet — where the
/// useful thing is usually an action rather than an apology.
///
/// ```dart
/// PlinthEmptyState(
///   icon: const Icon(Icons.inbox_outlined),
///   title: 'No messages',
///   description: 'Anything sent to your team lands here.',
///   action: PlinthButton(onPressed: _compose, child: const Text('Compose')),
/// )
/// ```
class PlinthEmptyState extends StatelessWidget {
  const PlinthEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.action,
    this.color,
    this.size = PlinthSize.md,
  });

  final String title;
  final String? description;

  /// Shown above the title in a [PlinthThemeIcon]. Decorative, so it's
  /// hidden from assistive technology — the title already says what
  /// the icon is illustrating.
  final Widget? icon;

  /// The way out. An empty state without one tells the user their
  /// situation but not what to do about it.
  final Widget? action;

  final String? color;
  final PlinthSize size;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing[PlinthSize.lg]!,
        vertical: theme.spacing[PlinthSize.xl]!,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            ExcludeSemantics(
              child: PlinthThemeIcon(
                icon: icon!,
                variant: PlinthVariant.light,
                color: color,
                size: PlinthSize.xl,
              ),
            ),
            SizedBox(height: theme.spacing[PlinthSize.md]),
          ],
          PlinthTitle(
            title,
            // An empty state heads a region rather than a page, so it
            // takes a lower heading level than a page title would.
            order: 4,
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            SizedBox(height: theme.spacing[PlinthSize.xs]),
            PlinthText(
              description!,
              size: size == PlinthSize.xs ? PlinthSize.xs : PlinthSize.sm,
              color: theme.rampFor(PlinthRole.neutral),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            SizedBox(height: theme.spacing[PlinthSize.lg]),
            action!,
          ],
        ],
      ),
    );
  }
}
