/// One shipment: where it is going, and everything that has happened to
/// it.
///
/// Knows nothing about whether it is a pushed route or the right half
/// of a tablet. That is the shell's business, and keeping it there is
/// what stops this screen growing two layouts.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import '../data.dart';

class ShipmentDetailScreen extends StatelessWidget {
  const ShipmentDetailScreen({super.key, required this.shipment});

  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.space(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: PlinthTitle(shipment.reference, order: 2)),
              PlinthBadge(
                shipment.status,
                color: theme.semanticColors[shipment.status]?.ramp,
                size: PlinthSize.md,
              ),
            ],
          ),
          SizedBox(height: theme.space(4)),
          PlinthStatGrid(
            columns: 2,
            tiles: [
              PlinthStatTile(
                label: 'Destination',
                value: shipment.destination,
                caption: shipment.customer,
              ),
              PlinthStatTile(
                label: 'Weight',
                value: '${shipment.weightKg} kg',
                caption: shipment.eta,
              ),
            ],
          ),
          SizedBox(height: theme.space(6)),
          PlinthTitle('History', order: 3),
          SizedBox(height: theme.space(4)),
          PlinthTimeline(
            items: [
              for (var i = 0; i < shipment.history.length; i++)
                PlinthTimelineItem(
                  title: shipment.history[i].what,
                  description: '${shipment.history[i].where} · '
                      '${shipment.history[i].when}',

                  // The most recent event is first, so it is the one
                  // that is still true.
                  active: i == 0,
                ),
            ],
          ),
          SizedBox(height: theme.space(6)),
          PlinthAsyncButton(
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 500));
            },
            child: const Text('Request an update'),
          ),
        ],
      ),
    );
  }
}
