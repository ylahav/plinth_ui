/// The shell every screen is mounted in: sidebar, top bar, body.
///
/// One widget owns which section is showing, because a shell that keeps
/// its own idea of the current page and a router that keeps another is
/// the bug every dashboard starter ships with. Swap [_Section] for your
/// router's state and the rest of this file is unchanged.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import 'screens/orders.dart';
import 'screens/overview.dart';
import 'screens/settings.dart';

enum _Section {
  overview('Overview', Icons.insights_outlined),
  orders('Orders', Icons.receipt_long_outlined),
  settings('Settings', Icons.tune_outlined);

  const _Section(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// The width at which the sidebar stops being worth its 220 pixels.
///
/// Below it the same sections move into a drawer rather than into a
/// bottom bar: there are three of them now, but a dashboard grows
/// sections and a bottom bar does not grow with it.
const _sidebarBreakpoint = 900.0;

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key, required this.light, required this.dark});

  final ThemeData light;
  final ThemeData dark;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Dashboard',
        theme: light,
        darkTheme: dark,
        debugShowCheckedModeBanner: false,
        home: const DashboardShell(),
      );
}

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  _Section _current = _Section.overview;
  bool _collapsed = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _go(_Section section) {
    setState(() => _current = section);

    // Closing the drawer is a navigation, so say so — the body changed
    // under a reader that was reading the drawer, and nothing on screen
    // would otherwise announce that.
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
      PlinthAnnounce.say(context, '${section.label} page');
    }
  }

  Widget _sidebar({required bool collapsible}) => PlinthSidebar(
        sections: [
          PlinthNavSection(
            items: [
              for (final section in _Section.values)
                PlinthNavItem(
                  label: section.label,
                  icon: Icon(section.icon),
                  onTap: () => _go(section),
                ),
            ],
          ),
        ],
        activeValue: _current.label,
        collapsed: collapsible && _collapsed,
        onToggleCollapsed:
            collapsible ? () => setState(() => _collapsed = !_collapsed) : null,
        header: const PlinthTopBarBrand(
          title: 'Northwind',
          icon: Icon(Icons.dashboard_outlined),
        ),
      );

  Widget _body() => switch (_current) {
        _Section.overview => const OverviewScreen(),
        _Section.orders => const OrdersScreen(),
        _Section.settings => const SettingsScreen(),
      };

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _sidebarBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      drawer: wide ? null : Drawer(child: _sidebar(collapsible: false)),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide) _sidebar(collapsible: true),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PlinthTopBar(
                    brand: wide
                        ? null
                        : Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu),
                              tooltip: 'Open navigation',
                              onPressed: Scaffold.of(context).openDrawer,
                            ),
                          ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        tooltip: 'Notifications',
                        onPressed: () => PlinthAnnounce.say(
                          context,
                          'No new notifications',
                        ),
                      ),
                      const SizedBox(width: 4),
                      const PlinthAvatar(
                          name: 'Ada Okafor', size: PlinthSize.sm),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _body(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
