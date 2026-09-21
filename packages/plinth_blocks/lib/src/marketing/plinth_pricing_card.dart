import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// One plan on a pricing page.
///
/// ```dart
/// PlinthPricingCard(
///   plan: 'Pro',
///   price: r'$24',
///   period: '/ month',
///   badge: const PlinthBadge('Popular', color: 'violet'),
///   features: const ['Unlimited projects', 'Priority support'],
///   action: PlinthButton(
///     fullWidth: true,
///     onPressed: startTrial,
///     child: const Text('Start trial'),
///   ),
/// )
/// ```
///
/// **The price carries the weight, not the plan name.** The price is
/// the thing being compared across a row of these; the name above it is
/// a label for the column. It is also the card's heading, so a screen
/// reader running through a pricing page hears the plans rather than
/// three identical "Start trial" buttons.
///
/// [price] is a string. `$24`, `€19`, `Free` and `Let's talk` are all
/// valid prices and only one of them is a number — formatting one is a
/// locale question this package does not answer.
///
/// For the same plans as a matrix rather than a row of cards, see
/// `PlinthComparisonBlock`: cards are better when somebody is choosing
/// a tier, a matrix when they are asking what differs between them.
class PlinthPricingCard extends StatelessWidget {
  const PlinthPricingCard({
    super.key,
    required this.plan,
    required this.price,
    this.period,
    this.description,
    this.badge,
    this.features = const [],
    this.action,
    this.highlighted = false,
    this.featureIcon,
    this.planOrder = 4,
    this.width,
  });

  /// The tier's name — Free, Pro, Team.
  final String plan;

  /// What it costs, formatted.
  final String price;

  /// What the price is per — `/ month`, `per seat`.
  final String? period;

  /// A line under the price.
  final String? description;

  /// Beside the plan name, usually a "Popular" badge.
  final Widget? badge;

  /// What the tier includes.
  final List<String> features;

  /// The way in, usually a full-width button.
  final Widget? action;

  /// Draws attention to this card among its siblings.
  ///
  /// A border, not a scale transform or a shadow: a card that grows
  /// breaks the row's alignment, and the one being recommended is the
  /// one somebody needs to read most easily.
  final bool highlighted;

  /// The mark beside each feature. Decorative — hidden from assistive
  /// technology, because the same tick on every row says nothing a
  /// reader does not already have from the row being in the list.
  final Widget? featureIcon;

  final int planOrder;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    final card = PlinthCard(
      withBorder: true,
      header: PlinthGroup(
        children: [
          PlinthText(plan, size: PlinthSize.lg, weight: FontWeight.w700),
          if (badge case final badge?) badge,
        ],
      ),
      footer: action,
      child: PlinthStack(
        gap: PlinthSize.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: PlinthGroup(
              gap: PlinthSize.xs,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PlinthTitle(price, order: planOrder),
                if (period case final period?)
                  PlinthText(period, size: PlinthSize.xs, color: 'gray'),
              ],
            ),
          ),
          if (description case final description?)
            PlinthText(description, size: PlinthSize.sm, color: 'gray'),
          if (features.isNotEmpty)
            PlinthList(
              size: PlinthSize.sm,
              items: [
                for (final feature in features)
                  PlinthListItem(
                    PlinthText(feature),
                    icon: ExcludeSemantics(
                      child: featureIcon ??
                          Icon(
                            Icons.check,
                            size: 14,
                            color: theme.readableOn('green', theme.surface),
                          ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );

    final framed = !highlighted
        ? card
        : DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.readableOn(theme.primaryColor, theme.surface),
                width: 2,
              ),
              borderRadius:
                  BorderRadius.circular(theme.radius[theme.defaultRadius]!),
            ),
            child: card,
          );

    return width == null ? framed : SizedBox(width: width, child: framed);
  }
}
