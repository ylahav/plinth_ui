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
/// **The clipped remainder stays readable.** Unlike [PlinthCollapse],
/// which excludes its hidden child from semantics, a spoiler shows a
/// teaser — the first [maxHeight] of the content — so there is no
/// boundary in the semantics tree to cut at. A screen reader therefore
/// reaches the whole text whether it is expanded or not, and "Show
/// more" is a visual affordance rather than a promise of hidden
/// content. That is a deliberate trade rather than an oversight:
/// clipping the reading as well would mean cutting a sentence at a
/// pixel, which semantics cannot express.
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
    final linkColor = theme.shaded(colorKey, 6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? widget.child
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight),
                  // A bare ConstrainedBox lays the child out *within*
                  // maxHeight, so a child that manages its own overflow
                  // — any Column/Row — reports a RenderFlex overflow and
                  // paints overflow stripes instead of being quietly
                  // clipped, which is the entire point of a spoiler. A
                  // ClipRect only hides the painting; the error still
                  // fires. A non-scrolling SingleChildScrollView gives
                  // the child its natural unbounded height and clips the
                  // viewport to maxHeight, and still shrink-wraps when
                  // the content is shorter than that.
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: widget.child,
                  ),
                ),
        ),
        SizedBox(height: theme.spacing[PlinthSize.xs]! * 0.5),
        // The toggle was a bare InkWell around text: reachable and
        // tappable, announcing as neither a control nor as something
        // that opens anything. Exactly what the B0c pass found on the
        // accordion header, in the widget next door.
        Semantics(
          button: true,
          expanded: _expanded,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? widget.hideLabel : widget.showLabel,
              style: TextStyle(
                  color: linkColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
