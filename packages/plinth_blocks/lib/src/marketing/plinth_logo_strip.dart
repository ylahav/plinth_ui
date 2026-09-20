import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A row of customer names under a label.
///
/// ```dart
/// PlinthLogoStrip(
///   label: 'BUILT WITH PLINTH',
///   logos: const [Text('ACME'), Text('Globex'), Text('Initech')],
/// )
/// ```
///
/// **Scrolling by default, and that is a real choice.** A logo strip
/// usually has more names than fit, and a marquee shows them all
/// without a second line. [PlinthMarquee] stops under the pointer and
/// never starts at all under reduce-motion, which is what makes moving
/// text acceptable here — a strip that scrolls regardless is a
/// vestibular problem, not a design flourish.
///
/// Set [scroll] to false when the names do fit. Motion that earns
/// nothing is motion somebody has to sit through.
class PlinthLogoStrip extends StatelessWidget {
  const PlinthLogoStrip({
    super.key,
    required this.logos,
    this.label,
    this.scroll = true,
    this.speed = 25,
    this.gap = PlinthSize.xl,
    this.width,
  });

  /// The names or marks. Text is fine — a wordmark in the page's own
  /// font beats a blurry PNG at this size.
  final List<Widget> logos;

  /// The line above, usually in caps.
  ///
  /// Written as you want it read. This does not upper-case anything:
  /// a screen reader given `BUILT WITH PLINTH` may spell it out letter
  /// by letter, so the styling-versus-content decision stays yours.
  final String? label;

  final bool scroll;
  final double speed;
  final PlinthSize gap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final row = PlinthGroup(
      wrap: !scroll,
      gap: gap,
      mainAxisAlignment: MainAxisAlignment.center,
      children: logos,
    );

    final strip = PlinthStack(
      gap: PlinthSize.sm,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (label case final label?)
          PlinthText(
            label,
            size: PlinthSize.xs,
            color: 'gray',
            weight: FontWeight.w700,
          ),
        if (scroll) PlinthMarquee(speed: speed, child: row) else row,
      ],
    );

    return width == null ? strip : SizedBox(width: width, child: strip);
  }
}
