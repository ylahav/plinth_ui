/// Shipments, standing in for whatever your list is of.
///
/// No Flutter import. Status is a name — `'delayed'` — resolved through
/// the theme in the widget layer.
library;

class Event {
  const Event({required this.what, required this.where, required this.when});

  final String what;
  final String where;
  final String when;
}

class Shipment {
  const Shipment({
    required this.reference,
    required this.customer,
    required this.destination,
    required this.status,
    required this.eta,
    required this.weightKg,
    required this.history,
  });

  final String reference;
  final String customer;
  final String destination;

  /// A key in `shipmentRoles`, not a colour.
  final String status;
  final String eta;
  final double weightKg;
  final List<Event> history;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return reference.toLowerCase().contains(needle) ||
        customer.toLowerCase().contains(needle) ||
        destination.toLowerCase().contains(needle);
  }
}

const shipments = <Shipment>[
  Shipment(
    reference: 'SHP-2291',
    customer: 'Beacon Coffee',
    destination: 'Porto',
    status: 'in transit',
    eta: 'Tomorrow, 14:00',
    weightKg: 42.5,
    history: [
      Event(what: 'Left the depot', where: 'Lisbon', when: 'Today, 06:12'),
      Event(what: 'Scanned in', where: 'Lisbon', when: 'Yesterday, 19:40'),
      Event(what: 'Collected', where: 'Setúbal', when: 'Yesterday, 15:02'),
    ],
  ),
  Shipment(
    reference: 'SHP-2287',
    customer: 'Northfield Supply',
    destination: 'Braga',
    status: 'delayed',
    eta: 'Thursday, 09:00',
    weightKg: 310.0,
    history: [
      Event(what: 'Held at customs', where: 'Porto', when: 'Today, 08:30'),
      Event(what: 'Arrived', where: 'Porto', when: 'Today, 04:15'),
    ],
  ),
  Shipment(
    reference: 'SHP-2280',
    customer: 'Ama Boateng',
    destination: 'Faro',
    status: 'delivered',
    eta: 'Delivered Monday',
    weightKg: 3.2,
    history: [
      Event(what: 'Signed for', where: 'Faro', when: 'Monday, 11:20'),
      Event(what: 'Out for delivery', where: 'Faro', when: 'Monday, 07:55'),
    ],
  ),
  Shipment(
    reference: 'SHP-2274',
    customer: 'Run Dynamics Ltd',
    destination: 'Coimbra',
    status: 'lost',
    eta: 'Under investigation',
    weightKg: 88.0,
    history: [
      Event(what: 'Last scan', where: 'Aveiro', when: 'Friday, 22:10'),
    ],
  ),
  Shipment(
    reference: 'SHP-2270',
    customer: 'Tomas Ruiz',
    destination: 'Évora',
    status: 'delivered',
    eta: 'Delivered Friday',
    weightKg: 12.8,
    history: [
      Event(what: 'Signed for', where: 'Évora', when: 'Friday, 16:44'),
    ],
  ),
];

/// Shipments handled per day this week, for the sparkline on the list.
const weeklyVolume = <double>[18, 24, 21, 29, 34, 31, 27];
