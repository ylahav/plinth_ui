import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// The animation style a [PlinthLoader] uses, mirroring Mantine's
/// `Loader` types.
enum PlinthLoaderType { oval, dots, bars }

/// Diameter (or overall extent) per [PlinthSize].
///
/// A spinner's size doesn't come from the spacing, radius, or
/// font-size scales — none of them mean "how big is this circle" — so
/// it gets its own scale here rather than borrowing one whose values
/// happen to look acceptable.
const Map<PlinthSize, double> _loaderSizes = {
  PlinthSize.xs: 16,
  PlinthSize.sm: 20,
  PlinthSize.md: 28,
  PlinthSize.lg: 36,
  PlinthSize.xl: 44,
};

/// A standalone loading indicator matching Mantine's `Loader`.
///
/// [PlinthLoadingOverlay] already shows a spinner, but only as part of
/// covering existing content — this is the indicator on its own, for a
/// button mid-submit, an empty panel awaiting its first fetch, or
/// anywhere the surrounding layout isn't what's loading.
///
/// ```dart
/// PlinthLoader(type: PlinthLoaderType.dots, color: 'blue')
/// ```
class PlinthLoader extends StatefulWidget {
  const PlinthLoader({
    super.key,
    this.type = PlinthLoaderType.oval,
    this.size = PlinthSize.md,
    this.color,
    this.colorValue,
    this.dimension,
  });

  final PlinthLoaderType type;
  final PlinthSize size;

  /// Color key into the theme palette, resolved at shade 6. Falls back
  /// to the theme's primary color.
  final String? color;

  /// An exact color, for a spinner sitting on something the palette
  /// cannot name — the foreground of a filled button, which is
  /// whatever `contrastingOn` resolved against that fill. Takes
  /// precedence over [color].
  ///
  /// Mantine's single `color` prop accepts a theme key *or* any CSS
  /// color; in Dart those are two types, so they are two parameters.
  final Color? colorValue;

  /// An exact extent in logical pixels, overriding [size].
  ///
  /// For a spinner that has to match something measured rather than
  /// something on the size scale — a button's line height, say, so the
  /// button doesn't change height when it starts loading.
  final double? dimension;

  @override
  State<PlinthLoader> createState() => _PlinthLoaderState();
}

class _PlinthLoaderState extends State<PlinthLoader>
    with SingleTickerProviderStateMixin {
  /// Null for the oval type, which defers to Flutter's own indicator
  /// and so drives its own animation.
  ///
  /// Deliberately not a `late final` initialized inline: that is only
  /// created on first *use*, so for the oval type it would still be
  /// uninitialized when `dispose()` ran — and `dispose()` touching it
  /// would construct a ticker against an already-deactivated element,
  /// which throws.
  AnimationController? _controller;

  bool get _needsController => widget.type != PlinthLoaderType.oval;

  @override
  void initState() {
    super.initState();
    if (_needsController) _startController();
  }

  @override
  void didUpdateWidget(covariant PlinthLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_needsController && _controller == null) {
      _startController();
    } else if (!_needsController && _controller != null) {
      // A repeating controller schedules a frame forever, so switching
      // to the oval type has to stop it rather than leave it running
      // behind an indicator that ignores it.
      _controller!.dispose();
      _controller = null;
    }
  }

  void _startController() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final color = widget.colorValue ??
        theme.shaded(widget.color ?? theme.primaryColor, 6);
    final extent = widget.dimension ?? _loaderSizes[widget.size]!;

    return switch (widget.type) {
      // The oval type defers to Flutter's own indicator rather than
      // reimplementing an arc sweep, the same rationale as PlinthSlider
      // wrapping Slider.
      PlinthLoaderType.oval => SizedBox(
          width: extent,
          height: extent,
          child: CircularProgressIndicator(
            strokeWidth: extent / 9,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      PlinthLoaderType.dots => _PulsingRow(
          controller: _controller!,
          color: color,
          extent: extent,
          count: 3,
          builder: (color, unit, scale) => Container(
            width: unit * scale,
            height: unit * scale,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      PlinthLoaderType.bars => _PulsingRow(
          controller: _controller!,
          color: color,
          extent: extent,
          count: 3,
          builder: (color, unit, scale) => Container(
            width: unit * 0.7,
            height: extent * scale,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(unit * 0.35),
            ),
          ),
        ),
    };
  }
}

/// Three elements pulsing out of phase, shared by the dots and bars
/// types — they differ only in what each element looks like, not in
/// how the stagger works.
class _PulsingRow extends StatelessWidget {
  const _PulsingRow({
    required this.controller,
    required this.color,
    required this.extent,
    required this.count,
    required this.builder,
  });

  final AnimationController controller;
  final Color color;
  final double extent;
  final int count;
  final Widget Function(Color color, double unit, double scale) builder;

  @override
  Widget build(BuildContext context) {
    final unit = extent / 3.5;
    final gap = unit * 0.5;

    return SizedBox(
      height: extent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(width: gap),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                // Each element is offset by a third of the cycle, and
                // the phase wraps rather than clamping so the sequence
                // reads as a travelling pulse instead of three
                // independent blinks.
                final phase = (controller.value + i / count) % 1.0;
                final scale = 0.5 + 0.5 * (1 - (phase * 2 - 1).abs());
                return builder(color, unit, scale);
              },
            ),
          ],
        ],
      ),
    );
  }
}
