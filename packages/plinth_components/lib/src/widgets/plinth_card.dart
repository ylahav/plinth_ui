import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_paper.dart';

/// A themed card matching Mantine's `Card`: a [PlinthPaper] with an
/// established header/body/footer section convention.
///
/// Sections that are `null` are simply omitted — pass only [child]
/// for a plain card, or add [header]/[footer] for the full
/// three-section layout. Header and footer get a divider between
/// them and the body when present, matching Mantine's default card
/// styling.
///
/// ```dart
/// PlinthCard(
///   shadow: PlinthShadow.sm,
///   withBorder: true,
///   header: const Text('Card title', style: TextStyle(fontWeight: FontWeight.w700)),
///   footer: Row(
///     mainAxisAlignment: MainAxisAlignment.end,
///     children: [PlinthButton(onPressed: () {}, child: const Text('Action'))],
///   ),
///   child: const Text('Card body content.'),
/// )
/// ```
class PlinthCard extends StatelessWidget {
  const PlinthCard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.p = PlinthSize.md,
    this.radius,
    this.shadow = PlinthShadow.sm,
    this.withBorder = false,
  });

  final Widget child;
  final Widget? header;
  final Widget? footer;
  final PlinthSize? p;
  final PlinthSize? radius;
  final PlinthShadow shadow;
  final bool withBorder;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final spacing = p != null ? theme.spacing[p]! : 0.0;

    return PlinthPaper(
      p: null,
      radius: radius,
      shadow: shadow,
      withBorder: withBorder,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) ...[
            Padding(padding: EdgeInsets.all(spacing), child: header),
            const Divider(height: 1),
          ],
          Padding(padding: EdgeInsets.all(spacing), child: child),
          if (footer != null) ...[
            const Divider(height: 1),
            Padding(padding: EdgeInsets.all(spacing), child: footer),
          ],
        ],
      ),
    );
  }
}
