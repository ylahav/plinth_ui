import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A "show more/less" collapsible content wrapper matching Mantine's
/// `Spoiler`: clips [child] to [maxHeight] when collapsed, with a
/// toggle control to expand/collapse.
///
/// Unlike [PlinthAccordion] (a list of independently toggleable
/// sections), this wraps a *single* block of content that's either
/// fully shown or height-clipped — the common "long paragraph with a
/// 'Show more' link at the bottom" pattern.
///
/// ```dart
/// PlinthSpoiler(
///   maxHeight: 80,
///   child: Text(longDescription),
/// )
/// ```
class PlinthSpoiler extends StatefulWidget {
  const PlinthSpoiler({
    super.key,
    required this.child,
    this.maxHeight = 100,
    this.showLabel = 'Show more',
    this.hideLabel = 'Show less',
    this.color,
  });

  final Widget child;

  /// Collapsed height, in logical pixels. Content taller than this
  /// gets clipped (with layout also constrained, not just visually
  /// hidden) until expanded.
  final double maxHeight;

  final String showLabel;
  final String hideLabel;
  final String? color;

  @override
  State<PlinthSpoiler> createState() => _PlinthSpoilerState();
}

class _PlinthSpoilerState extends State<PlinthSpoiler> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final colorKey = widget.color ?? theme.primaryColor;
    final linkColor = theme.color(colorKey, 6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: _expanded ? double.infinity : widget.maxHeight,
            ),
            child: ClipRect(child: widget.child),
          ),
        ),
        SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.5),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? widget.hideLabel : widget.showLabel,
            style: TextStyle(
                color: linkColor, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
