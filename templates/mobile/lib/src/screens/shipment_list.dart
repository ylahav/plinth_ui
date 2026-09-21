/// The list: a search field, a week of volume, and the shipments.
///
/// Takes `selected` as a parameter rather than keeping it. On a phone
/// there is no selection to show — the detail is a pushed route — so
/// the shell passes null and this screen highlights nothing.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';
import 'package:plinth_charts/plinth_charts.dart';

import '../data.dart';

class ShipmentListScreen extends StatefulWidget {
  const ShipmentListScreen({
    super.key,
    required this.onSelect,
    this.selected,
  });

  final ValueChanged<Shipment> onSelect;
  final Shipment? selected;

  @override
  State<ShipmentListScreen> createState() => _ShipmentListScreenState();
}

class _ShipmentListScreenState extends State<ShipmentListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final visible = [
      for (final shipment in shipments)
        if (shipment.matches(_query)) shipment,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(theme.space(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlinthTitle('Shipments', order: 2),
              SizedBox(height: theme.space(3)),
              PlinthSparkline(
                values: weeklyVolume,
                label: 'Handled this week',
                describeValue: (v) => v.toStringAsFixed(0),
              ),
              SizedBox(height: theme.space(4)),
              PlinthTextInput(
                placeholder: 'Search shipments',
                leadingIcon: const Icon(Icons.search, size: 18),
                onChanged: (value) => setState(() => _query = value),
              ),
              SizedBox(height: theme.space(3)),

              // Announced, not only drawn. Typing into a search field
              // that silently empties a list below it tells a reader
              // nothing at all.
              PlinthLiveRegion(
                message: '${visible.length} of ${shipments.length} shipments',
                child: PlinthText(
                  '${visible.length} of ${shipments.length} shipments',
                  size: PlinthSize.sm,
                  color: 'dimmed',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const Center(
                  child: PlinthEmptyState(
                    title: 'No matching shipments',
                    description: 'Try a reference, a customer or a city.',
                  ),
                )
              : ListView.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => PlinthDivider(),
                  itemBuilder: (context, index) {
                    final shipment = visible[index];
                    return PlinthUserTile(
                      name: shipment.reference,
                      detail: '${shipment.customer} · ${shipment.destination}',
                      initials: shipment.destination[0],
                      onTap: () => widget.onSelect(shipment),
                      trailing: PlinthBadge(
                        shipment.status,
                        color: theme.semanticColors[shipment.status]?.ramp,
                      ),
                      withBorder: false,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
