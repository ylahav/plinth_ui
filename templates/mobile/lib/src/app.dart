/// List and detail, and the one decision that makes this template
/// worth copying: on a phone the detail is a *route*, and on a tablet
/// it is the other half of the screen.
///
/// Most list–detail starters pick one. Picking one is why a tablet
/// shows a phone layout with 400px of wasted margin, or why the back
/// button on a phone does nothing because the app never pushed a route.
///
/// The selection lives here, above both, so neither screen knows which
/// arrangement it is in.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import 'data.dart';
import 'screens/shipment_detail.dart';
import 'screens/shipment_list.dart';

/// Where one pane stops being enough.
const twoPaneBreakpoint = 720.0;

class MobileApp extends StatelessWidget {
  const MobileApp({super.key, required this.light, required this.dark});

  final ThemeData light;
  final ThemeData dark;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Shipments',
        theme: light,
        darkTheme: dark,
        debugShowCheckedModeBanner: false,
        home: const MobileShell(),
      );
}

class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  Shipment? _selected;

  void _select(Shipment shipment, {required bool twoPane}) {
    setState(() => _selected = shipment);

    if (twoPane) {
      // The right pane changed under a reader who is still in the list.
      // Nothing about replacing a pane's contents announces itself.
      PlinthAnnounce.say(context, '${shipment.reference}, details');
      return;
    }

    // On a phone it is a real route, so Android's back gesture and the
    // system back button work without this app implementing either.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(shipment.reference)),
          body: SafeArea(child: ShipmentDetailScreen(shipment: shipment)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final twoPane = MediaQuery.sizeOf(context).width >= twoPaneBreakpoint;
    final theme = context.plinth;
    final selected = _selected;

    final list = ShipmentListScreen(
      selected: twoPane ? selected : null,
      onSelect: (shipment) => _select(shipment, twoPane: twoPane),
    );

    return Scaffold(
      body: SafeArea(
        child: twoPane
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 340, child: list),
                  VerticalDivider(width: 1, color: theme.border),
                  Expanded(
                    child: selected == null
                        ? const Center(
                            child: PlinthEmptyState(
                              title: 'Nothing selected',
                              description: 'Pick a shipment from the list.',
                            ),
                          )
                        : ShipmentDetailScreen(shipment: selected),
                  ),
                ],
              )
            : list,
      ),
    );
  }
}
