import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A styled keyboard-key badge matching Mantine's `Kbd`, e.g. for
/// documenting a shortcut: "Press `Ctrl` + `K` to search."
///
/// ```dart
/// Row(
///   children: [
///     const PlinthKbd('Ctrl'),
///     const Text(' + '),
///     const PlinthKbd('K'),
///   ],
/// )
/// ```
class PlinthKbd extends StatelessWidget {
  const PlinthKbd(this.label, {super.key, this.size = PlinthSize.md});

  final String label;
  final PlinthSize size;

  static const Map<PlinthSize, double> _fontSizes = {
    PlinthSize.xs: 10,
    PlinthSize.sm: 11,
    PlinthSize.md: 12,
    PlinthSize.lg: 14,
    PlinthSize.xl: 16,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing[PlinthSize.xs]! * 0.6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFDEE2E6)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 0, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: _fontSizes[size],
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
