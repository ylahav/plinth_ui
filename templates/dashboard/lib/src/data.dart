/// The dashboard's data, standing in for whatever yours comes from.
///
/// Deliberately free of any Flutter import. Colour is named here — as
/// `'paid'`, as `'web'` — and resolved in the widget layer through the
/// theme, which is what keeps this file swappable for a real client
/// without dragging the UI's colour decisions along with it.
library;

/// A figure on the overview, with its own direction of good.
class Metric {
  const Metric({
    required this.label,
    required this.value,
    required this.delta,
    required this.rising,
    this.higherIsBetter = true,
    this.caption,
  });

  final String label;
  final String value;

  /// The change, already formatted — '12.4%', '-3'.
  final String delta;

  /// Which way it moved. Separate from [higherIsBetter], because a
  /// rising refund rate is a rise and also bad, and a tile that conflates
  /// the two paints a green arrow on the worst number on the page.
  final bool rising;
  final bool higherIsBetter;
  final String? caption;
}

const overviewMetrics = <Metric>[
  Metric(
    label: 'Revenue',
    value: r'$84,210',
    delta: '12.4%',
    rising: true,
    caption: 'vs. last month',
  ),
  Metric(
    label: 'Orders',
    value: '1,284',
    delta: '4.1%',
    rising: true,
    caption: 'vs. last month',
  ),
  Metric(
    label: 'Refund rate',
    value: '2.3%',
    delta: '0.4pp',
    rising: true,
    higherIsBetter: false,
    caption: 'vs. last month',
  ),
];

/// Revenue by channel over the last eight weeks, in thousands.
///
/// The keys match `channelSeries` in `theme.dart`, which is how each
/// line keeps its colour when another channel is added above it.
const revenueByChannel = <String, List<double>>{
  'web': [32, 35, 34, 38, 41, 39, 44, 47],
  'retail': [18, 19, 17, 21, 20, 23, 22, 24],
  'wholesale': [11, 10, 13, 12, 15, 14, 16, 18],
};

/// Where this month's orders came from.
const ordersBySource = <String, double>{
  'Direct': 412,
  'Search': 356,
  'Referral': 248,
  'Social': 168,
  'Email': 100,
};

/// One row of the orders table.
class Order {
  const Order({
    required this.reference,
    required this.customer,
    required this.total,
    required this.status,
    required this.placed,
  });

  final String reference;
  final String customer;
  final String total;

  /// A key in `orderRoles`, not a colour.
  final String status;
  final String placed;
}

const recentOrders = <Order>[
  Order(
    reference: 'ORD-4471',
    customer: 'Ama Boateng',
    total: r'$1,240.00',
    status: 'paid',
    placed: '21 Sep',
  ),
  Order(
    reference: 'ORD-4470',
    customer: 'Run Dynamics Ltd',
    total: r'$8,905.50',
    status: 'shipped',
    placed: '21 Sep',
  ),
  Order(
    reference: 'ORD-4469',
    customer: 'Ingrid Sørensen',
    total: r'$96.00',
    status: 'refunded',
    placed: '20 Sep',
  ),
  Order(
    reference: 'ORD-4468',
    customer: 'Northfield Supply',
    total: r'$2,310.75',
    status: 'paid',
    placed: '20 Sep',
  ),
  Order(
    reference: 'ORD-4467',
    customer: 'Tomas Ruiz',
    total: r'$418.20',
    status: 'shipped',
    placed: '19 Sep',
  ),
  Order(
    reference: 'ORD-4466',
    customer: 'Beacon Coffee',
    total: r'$645.00',
    status: 'paid',
    placed: '19 Sep',
  ),
];
