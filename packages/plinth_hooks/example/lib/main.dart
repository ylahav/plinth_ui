// Driving disclosure state with PlinthDisclosureController.
//
// The controller is a plain ChangeNotifier holding one bool, which is
// the whole idea: anything that opens and closes — a panel, a modal, a
// drawer, a menu — shares one way of being opened and closed, so a
// button in one part of the tree can drive a panel in another.
//
// plinth_components' overlay widgets take this same controller. Nothing
// here depends on that package, though: this is the controller on its
// own, with plain Flutter widgets.
//
// See https://github.com/ylahav/plinth_ui for the full library.

import 'package:flutter/material.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

void main() => runApp(const DisclosureExampleApp());

class DisclosureExampleApp extends StatelessWidget {
  const DisclosureExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DisclosurePage());
  }
}

class DisclosurePage extends StatefulWidget {
  const DisclosurePage({super.key});

  @override
  State<DisclosurePage> createState() => _DisclosurePageState();
}

class _DisclosurePageState extends State<DisclosurePage> {
  final _panel = PlinthDisclosureController();

  @override
  void initState() {
    super.initState();
    // The controller notifies rather than rebuilding anything itself,
    // so listen to it wherever the UI needs to react.
    _panel.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    // Always both: removing the listener before disposing the
    // controller, and disposing it with the State that owns it.
    _panel.removeListener(_onChanged);
    _panel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlinthDisclosureController')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Any number of controls can drive the same state.
                FilledButton(
                  onPressed: _panel.toggle,
                  child: Text(_panel.isOpen ? 'Hide details' : 'Show details'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  // close() on an already-closed controller is a no-op
                  // and notifies nobody, so calling it defensively is
                  // safe.
                  onPressed: _panel.isOpen ? _panel.close : null,
                  child: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _panel.isOpen
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'isOpen is ${_panel.isOpen}. The same controller can '
                    'drive a PlinthModal, PlinthDrawer, PlinthPopover, or '
                    'PlinthMenu from plinth_components.',
                  ),
                ),
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
