/// The orders table, with the filter above it and the status as a word.
///
/// Status is a badge whose colour comes from `orderRoles` and whose
/// *text* is the status itself. That is not redundancy — a badge that
/// carries its meaning in a hue alone is unreadable to a colour-blind
/// reader and silent to a screen reader, and this table has three
/// statuses that a red/green pair would collapse into one.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import '../data.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _query = '';
  String _status = 'all';

  List<Order> get _visible {
    final needle = _query.trim().toLowerCase();
    return [
      for (final order in recentOrders)
        if ((_status == 'all' || order.status == _status) &&
            (needle.isEmpty ||
                order.customer.toLowerCase().contains(needle) ||
                order.reference.toLowerCase().contains(needle)))
          order,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final rows = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlinthPageHeader(
          title: 'Orders',
          subtitle: '${recentOrders.length} in the last three days',
          actions: [
            PlinthButton(
              onPressed: () {},
              child: const Text('Export'),
            ),
          ],
        ),
        SizedBox(height: theme.space(6)),
        Row(
          children: [
            Expanded(
              child: PlinthTextInput(
                label: 'Search',
                placeholder: 'Customer or reference',
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            SizedBox(width: theme.space(4)),
            Expanded(
              child: PlinthSelect(
                label: 'Status',
                value: _status,
                options: const [
                  PlinthSelectOption('all', 'All statuses'),
                  PlinthSelectOption('paid', 'Paid'),
                  PlinthSelectOption('shipped', 'Shipped'),
                  PlinthSelectOption('refunded', 'Refunded'),
                ],
                onChanged: (value) => setState(() => _status = value ?? 'all'),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.space(5)),

        // The row count is announced, not just drawn. Filtering changes
        // the table silently otherwise: a reader that was on the search
        // field hears nothing at all happen.
        PlinthLiveRegion(
          message: '${rows.length} of ${recentOrders.length} orders',
          child: PlinthText(
            '${rows.length} of ${recentOrders.length} orders',
            size: PlinthSize.sm,
            color: 'dimmed',
          ),
        ),
        SizedBox(height: theme.space(2)),
        PlinthTable(
          columns: const ['Reference', 'Customer', 'Placed', 'Status', 'Total'],
          striped: true,
          highlightOnHover: true,
          emptyState: const PlinthEmptyState(
            title: 'No matching orders',
            description: 'Clear the search or pick another status.',
          ),
          rows: [
            for (final order in rows)
              [
                Text(order.reference),
                Text(order.customer),
                Text(order.placed),
                PlinthBadge(
                  order.status,
                  color: theme.semanticColors[order.status]?.ramp,
                ),
                Text(order.total),
              ],
          ],
        ),
      ],
    );
  }
}
