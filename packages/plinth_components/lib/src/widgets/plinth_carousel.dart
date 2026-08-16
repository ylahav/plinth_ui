import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_action_icon.dart';

/// A slide carousel matching Mantine's `Carousel`: swipeable slides
/// with optional arrows, dot indicators, and looping.
///
/// Position is presentation-local, so this manages it internally the
/// way [PlinthAccordion] manages expansion, rather than demanding a
/// `value`/`onChanged` pair like [PlinthTabs]. Pass [onSlideChanged]
/// to hear about it — to drive a caption or a URL — and [jumpTo] on a
/// [PlinthCarouselController] to drive it from outside.
///
/// **No autoplay.** Mantine ships its own as a separate plugin, and
/// the reason applies here too: slides that move on their own take
/// content away from a slow reader, and doing it properly means
/// pausing on hover, on focus, on `MediaQuery.disableAnimations`, and
/// while the tab is hidden. A carousel that only moves when someone
/// asks it to needs none of that.
///
/// ```dart
/// PlinthCarousel(
///   height: 220,
///   slideSize: 0.8,
///   withIndicators: true,
///   slides: [for (final image in images) Image.network(image)],
/// )
/// ```
class PlinthCarousel extends StatefulWidget {
  const PlinthCarousel({
    super.key,
    required this.slides,
    this.height = 240,
    this.slideSize = 1.0,
    this.gap = PlinthSize.sm,
    this.loop = false,
    this.withControls = true,
    this.withIndicators = false,
    this.initialSlide = 0,
    this.onSlideChanged,
    this.controller,
    this.color,
  })  : assert(slides.length > 0, 'a carousel needs at least one slide'),
        assert(slideSize > 0 && slideSize <= 1,
            'slideSize is a fraction of the viewport, from just above 0 to 1'),
        assert(initialSlide >= 0, 'initialSlide must not be negative');

  final List<Widget> slides;

  /// Height of the slide area. Indicators, when shown, sit below it.
  ///
  /// Required in spirit rather than in the signature: a `PageView`
  /// needs a bounded height, and inheriting one from an unbounded
  /// column is the usual way to end up with an unhelpful layout
  /// exception rather than a carousel.
  final double height;

  /// Fraction of the viewport one slide takes, matching Mantine's
  /// `slideSize`. Below 1 the neighbouring slides peek in, which is
  /// what tells a reader there is more to swipe to.
  final double slideSize;

  /// Space between slides. Applied as padding inside each slide, so it
  /// doesn't distort [slideSize].
  final PlinthSize gap;

  /// Wraps around past either end. Off by default: an end that stops
  /// is how a reader knows they have seen everything.
  final bool loop;

  final bool withControls;
  final bool withIndicators;

  /// Slide shown first. Clamped into range rather than asserted, since
  /// it is commonly computed from data that may have shrunk.
  final int initialSlide;

  /// Called with the new index after a swipe, an arrow, an indicator,
  /// or an arrow key. Not called for the initial slide.
  final ValueChanged<int>? onSlideChanged;

  final PlinthCarouselController? controller;

  final String? color;

  @override
  State<PlinthCarousel> createState() => _PlinthCarouselState();
}

/// Drives a [PlinthCarousel] from outside it — a "next" button in a
/// toolbar, a step that advances when a form is valid.
///
/// Attach one carousel at a time; a second attachment replaces the
/// first, which is the same rule Flutter's own controllers follow.
class PlinthCarouselController extends ChangeNotifier {
  _PlinthCarouselState? _state;

  void _attach(_PlinthCarouselState state) => _state = state;

  void _detach(_PlinthCarouselState state) {
    if (identical(_state, state)) _state = null;
  }

  /// Index of the slide currently in view, or null before the
  /// carousel this controls has been built.
  int? get index => _state?._index;

  void next() => _state?._step(1);

  void previous() => _state?._step(-1);

  /// Animates to [slide]. Out-of-range values are ignored rather than
  /// throwing — the caller is often working from data that changed.
  void jumpTo(int slide) => _state?._goTo(slide);
}

class _PlinthCarouselState extends State<PlinthCarousel> {
  /// Where an infinite (looping) carousel starts. Large enough that
  /// nobody swipes past it, small enough to stay exact in a double.
  static const int _loopOrigin = 100000;

  late PageController _controller;
  late int _index;

  int get _count => widget.slides.length;

  /// [_loopOrigin] rounded down to a whole number of laps.
  ///
  /// Page N shows slide `N % count`, so an origin that isn't a
  /// multiple of the count starts the carousel on the wrong slide —
  /// 100000 with three slides opens on the second one.
  int get _origin => _loopOrigin - (_loopOrigin % _count);

  /// The page a fresh controller should open on.
  int get _startPage => widget.loop ? _origin + _index : _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialSlide.clamp(0, _count - 1);
    _controller = PageController(
      initialPage: _startPage,
      viewportFraction: widget.slideSize,
    );
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(PlinthCarousel old) {
    super.didUpdateWidget(old);

    if (old.controller != widget.controller) {
      old.controller?._detach(this);
      widget.controller?._attach(this);
    }

    // The viewport fraction is fixed at construction, so a changed
    // slideSize needs a new controller rather than a new value.
    if (old.slideSize != widget.slideSize || old.loop != widget.loop) {
      final previous = _controller;
      _controller = PageController(
        initialPage: widget.loop ? _loopOrigin + _index : _index,
        viewportFraction: widget.slideSize,
      );
      // Disposed next frame: the old controller is still attached to
      // the PageView being replaced during this build.
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }

    // Slides can be removed under a carousel that is already past the
    // new end — clamping beats an index error on the next paint.
    if (_index > _count - 1) _goTo(_count - 1);
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _controller.dispose();
    super.dispose();
  }

  /// The page the controller is actually on, which for a looping
  /// carousel is somewhere near [_loopOrigin] rather than [_index].
  int get _rawPage =>
      (_controller.hasClients ? _controller.page?.round() : null) ??
      _controller.initialPage;

  bool get _canGoBack => widget.loop || _index > 0;
  bool get _canGoForward => widget.loop || _index < _count - 1;

  void _step(int delta) {
    if (delta < 0 && !_canGoBack) return;
    if (delta > 0 && !_canGoForward) return;
    _animateTo(_rawPage + delta);
  }

  void _goTo(int slide) {
    if (slide < 0 || slide > _count - 1) return;
    if (slide == _index) return;

    // Move by the shortest run of pages rather than to an absolute
    // page: under looping, page N of the underlying list is one of
    // infinitely many pages showing slide N.
    _animateTo(_rawPage + (slide - _index));
  }

  void _animateTo(int page) {
    if (!_controller.hasClients) return;
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _handlePageChanged(int page) {
    final slide = page % _count;
    if (slide == _index) return;
    setState(() => _index = slide);
    widget.onSlideChanged?.call(slide);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _step(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _step(1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final gap = theme.spacing[widget.gap]!;

    final viewport = PageView.builder(
      controller: _controller,
      onPageChanged: _handlePageChanged,
      // A null count is an endless list in both directions, which is
      // how the loop is built: every page maps back onto a slide by
      // remainder, so there is no seam to cross at either end.
      itemCount: widget.loop ? null : _count,
      itemBuilder: (context, page) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gap / 2),
        child: widget.slides[page % _count],
      ),
    );

    return Focus(
      onKeyEvent: _handleKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                Positioned.fill(child: viewport),
                if (widget.withControls && _count > 1) ...[
                  _control(
                    alignment: Alignment.centerLeft,
                    icon: Icons.chevron_left,
                    label: 'Previous slide',
                    onPressed: _canGoBack ? () => _step(-1) : null,
                  ),
                  _control(
                    alignment: Alignment.centerRight,
                    icon: Icons.chevron_right,
                    label: 'Next slide',
                    onPressed: _canGoForward ? () => _step(1) : null,
                  ),
                ],
              ],
            ),
          ),
          if (widget.withIndicators && _count > 1) ...[
            SizedBox(height: theme.spacing[PlinthSize.xs]!),
            _indicators(theme),
          ],
        ],
      ),
    );
  }

  Widget _control({
    required Alignment alignment,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Semantics(
          button: true,
          label: label,
          textDirection: TextDirection.ltr,
          child: PlinthActionIcon(
            icon: Icon(icon),
            onPressed: onPressed,
            variant: PlinthVariant.filled,
            color: widget.color,
            circle: true,
          ),
        ),
      ),
    );
  }

  Widget _indicators(PlinthTheme theme) {
    final active = theme.shaded(widget.color ?? theme.primaryColor, 6);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _count; i++)
          Semantics(
            button: true,
            selected: i == _index,
            label: 'Go to slide ${i + 1}',
            textDirection: TextDirection.ltr,
            child: GestureDetector(
              onTap: () => _goTo(i),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  // The current dot stretches rather than only
                  // changing colour: position stays readable when the
                  // dots are small or the palette is low-contrast.
                  width: i == _index ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? active : theme.surfaceSunken,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
