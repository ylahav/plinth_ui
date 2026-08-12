import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// A themeable toggle switch matching Mantine's `Switch`: a pill-shaped
/// track that fills with the active theme color when on, with an
/// animated thumb and an optional inline label.
///
/// ```dart
/// PlinthSwitch(
///   label: 'Enable notifications',
///   value: _notifications,
///   onChanged: (v) => setState(() => _notifications = v),
/// )
/// ```
class PlinthSwitch extends StatelessWidget {
  const PlinthSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = PlinthSize.md,
    this.color,
  });

  final bool value;

  /// Null disables the switch (matches Flutter's `Switch` convention).
  final ValueChanged<bool>? onChanged;
  final String? label;
  final PlinthSize size;
  final String? color;

  static const Map<PlinthSize, Size> _trackSizes = {
    PlinthSize.xs: Size(28, 16),
    PlinthSize.sm: Size(34, 20),
    PlinthSize.md: Size(40, 24),
    PlinthSize.lg: Size(46, 28),
    PlinthSize.xl: Size(52, 32),
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = color ?? theme.primaryColor;
    final baseColor = theme.color(colorKey, 6);
    final trackSize = _trackSizes[size]!;
    final enabled = onChanged != null;
    final thumbDiameter = trackSize.height - 4;

    final track = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: trackSize.width,
      height: trackSize.height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: value
            ? (enabled ? baseColor : baseColor.withValues(alpha: 0.5))
            : theme.border,
        borderRadius: BorderRadius.circular(trackSize.height / 2),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: thumbDiameter,
          height: thumbDiameter,
          decoration: BoxDecoration(
            // The thumb stays light in both themes — it reads as a
            // physical knob on the track, not as a surface.
            color: theme.onFilled,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: theme.shadow.withValues(alpha: 0.15),
                  blurRadius: 2,
                  offset: const Offset(0, 1)),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      toggled: value,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(trackSize.height / 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              track,
              if (label != null) ...[
                SizedBox(width: theme.spacing[PlinthSize.xs]! * 0.8),
                PlinthText(label!, size: size),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
