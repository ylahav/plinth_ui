import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

/// A button that copies [value] to the clipboard, matching Mantine's
/// `CopyButton`, showing a transient checkmark for [confirmDuration]
/// after a successful copy before reverting to the copy icon.
///
/// ```dart
/// PlinthCopyButton(value: apiKey)
/// ```
class PlinthCopyButton extends StatefulWidget {
  const PlinthCopyButton({
    super.key,
    required this.value,
    this.color,
    this.size = PlinthSize.md,
    this.confirmDuration = const Duration(seconds: 2),
  });

  final String value;
  final String? color;
  final PlinthSize size;
  final Duration confirmDuration;

  @override
  State<PlinthCopyButton> createState() => _PlinthCopyButtonState();
}

class _PlinthCopyButtonState extends State<PlinthCopyButton> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(widget.confirmDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  static const Map<PlinthSize, double> _iconSizes = {
    PlinthSize.xs: 14,
    PlinthSize.sm: 16,
    PlinthSize.md: 18,
    PlinthSize.lg: 22,
    PlinthSize.xl: 26,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = widget.color ?? theme.primaryColor;
    final iconColor = _copied
        ? theme.roleShaded(PlinthRole.success, 6)
        : theme.shaded(colorKey, 6);

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          _copied ? Icons.check : Icons.copy_outlined,
          size: _iconSizes[widget.size],
          color: iconColor,
        ),
      ),
    );
  }
}
