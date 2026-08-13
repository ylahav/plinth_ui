import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

import 'plinth_menu.dart';
import 'plinth_text.dart';

/// One top-level menu in a [PlinthMenubar].
class PlinthMenubarMenu {
  const PlinthMenubarMenu({required this.label, required this.items});

  final String label;
  final List<PlinthMenuItem> items;
}

/// A horizontal bar of menus, desktop-style, matching Mantine's
/// `Menubar`.
///
/// The behaviour that makes a menubar a menubar rather than a row of
/// [PlinthMenu]s: **once one menu is open, moving the pointer across
/// the bar opens the next one** without a second click. A row of
/// independent menus makes you click, dismiss, click again, which is
/// wrong for a File/Edit/View bar in a way that's hard to name until
/// you use one.
///
/// Only one menu is open at a time, and the bar owns that — which is
/// also why the controllers live here rather than being passed in.
///
/// ```dart
/// PlinthMenubar(
///   menus: [
///     PlinthMenubarMenu(label: 'File', items: [...]),
///     PlinthMenubarMenu(label: 'Edit', items: [...]),
///   ],
/// )
/// ```
class PlinthMenubar extends StatefulWidget {
  const PlinthMenubar({
    super.key,
    required this.menus,
    this.size = PlinthSize.sm,
    this.color,
  });

  final List<PlinthMenubarMenu> menus;
  final PlinthSize size;
  final String? color;

  @override
  State<PlinthMenubar> createState() => _PlinthMenubarState();
}

class _PlinthMenubarState extends State<PlinthMenubar> {
  late List<PlinthDisclosureController> _controllers;
  int? _open;

  @override
  void initState() {
    super.initState();
    _createControllers();
  }

  @override
  void didUpdateWidget(covariant PlinthMenubar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.menus.length != widget.menus.length) {
      _disposeControllers();
      _createControllers();
    }
  }

  void _createControllers() {
    _controllers = [
      for (var i = 0; i < widget.menus.length; i++)
        PlinthDisclosureController()..addListener(() => _onChanged(i)),
    ];
  }

  void _disposeControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _onChanged(int index) {
    if (!mounted) return;
    final isOpen = _controllers[index].isOpen;
    if (isOpen && _open != index) {
      setState(() => _open = index);
    } else if (!isOpen && _open == index) {
      setState(() => _open = null);
    }
  }

  /// Hovering a sibling while a menu is open switches to it. Doing
  /// nothing when nothing is open is the other half of the rule —
  /// otherwise merely crossing the bar would open menus.
  void _onHover(int index) {
    if (_open == null || _open == index) return;
    _controllers[_open!].close();
    _controllers[index].open();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = widget.color ?? theme.primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.menus.length; i++)
          MouseRegion(
            onEnter: (_) => _onHover(i),
            child: PlinthMenu(
              controller: _controllers[i],
              items: widget.menus[i].items,
              target: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing[PlinthSize.sm]!,
                  vertical: theme.spacing[PlinthSize.xs]! * 0.8,
                ),
                decoration: BoxDecoration(
                  color: _open == i ? theme.shaded(colorKey, 0) : null,
                  borderRadius:
                      BorderRadius.circular(theme.radius[PlinthSize.xs]!),
                ),
                child: PlinthText(
                  widget.menus[i].label,
                  size: widget.size,
                  color: _open == i ? colorKey : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
