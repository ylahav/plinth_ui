import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// Where a [PlinthImage] loads from, decided by its `src`.
enum PlinthImageSource {
  /// `http://` or `https://`.
  network,

  /// A bundled asset — anything else that looks like a path.
  asset,

  /// Nothing loadable: empty, or a bare identifier. Renders the
  /// fallback without attempting a fetch.
  none,
}

/// An image with a loading placeholder and an error fallback, matching
/// Mantine's `Image`.
///
/// Flutter's own `Image.network` shows nothing while loading and throws
/// an unhandled render error visible to the user if the URL fails —
/// this fills both gaps.
///
/// **`src` decides where it loads from**, so one widget serves a
/// profile photo from an API and an illustration from the bundle
/// without the caller branching:
///
/// | `src` | loads via |
/// |---|---|
/// | `https://…`, `http://…` | `Image.network` |
/// | anything containing `/`, or with a file extension | `Image.asset` |
/// | empty, or a bare word | nothing — [fallback] |
///
/// ```dart
/// PlinthImage(
///   src: photo,
///   height: 180,
///   radius: PlinthSize.lg,
///   headers: {'Authorization': 'Bearer $token'},
///   fallback: PlinthImageFallback(seed: photo, color: 'green'),
/// )
/// ```
class PlinthImage extends StatelessWidget {
  const PlinthImage({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
    this.headers,
    this.fallback,
    this.semanticLabel,
  });

  final String src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final PlinthSize? radius;

  /// Sent with a network request — an `Authorization` header for an
  /// image behind a login, most often.
  ///
  /// Ignored for an asset, which has nothing to send them to.
  final Map<String, String>? headers;

  /// Shown instead of the broken-image icon when the image cannot be
  /// loaded, and when [src] names nothing loadable.
  ///
  /// [PlinthImageFallback] is the generic one. Omitted, the icon
  /// stands.
  final Widget? fallback;

  /// Described to a screen reader. Omitted, the image is decorative and
  /// announced as nothing — which is right for a thumbnail beside a
  /// label that already says it, and wrong for an image carrying
  /// information of its own.
  final String? semanticLabel;

  /// Which loader [src] selects. Exposed because an app deciding
  /// whether to even build an image wants the same answer this does.
  static PlinthImageSource sourceOf(String src) {
    final trimmed = src.trim();
    if (trimmed.isEmpty) return PlinthImageSource.none;
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return PlinthImageSource.network;
    }
    // A bare identifier is not a path. Requiring a separator or an
    // extension keeps an id like `hero-42` out of the asset bundle,
    // where it would throw rather than fall back.
    if (trimmed.contains('/') || RegExp(r'\.\w{2,5}$').hasMatch(trimmed)) {
      return PlinthImageSource.asset;
    }
    return PlinthImageSource.none;
  }

  Widget _fallback(BuildContext context) {
    if (fallback case final widget?) {
      return SizedBox(width: width, height: height, child: widget);
    }
    final theme = context.plinth;
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: theme.roleShaded(PlinthRole.neutral, 1),
        child: Icon(Icons.broken_image_outlined,
            color: theme.roleShaded(PlinthRole.neutral, 5)),
      ),
    );
  }

  Widget _loading(BuildContext context, double? progress) {
    final theme = context.plinth;
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.shaded(theme.primaryColor, 6),
            value: progress,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius = radius != null ? theme.radius[radius]! : 0.0;
    final source = sourceOf(src);

    final Widget image = switch (source) {
      PlinthImageSource.none => _fallback(context),
      PlinthImageSource.asset => Image.asset(
          src,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stack) => _fallback(context),
        ),
      PlinthImageSource.network => Image.network(
          src,
          width: width,
          height: height,
          fit: fit,
          headers: headers,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _loading(
              context,
              progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            );
          },
          errorBuilder: (context, error, stack) => _fallback(context),
        ),
    };

    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: image,
      ),
    );
  }
}

/// A placeholder for an image that is missing, not yet uploaded, or
/// behind a login the app has not got through.
///
/// Deliberately says nothing about what the image was of. A library
/// placeholder that drew a person, a product or a building would be
/// wrong more often than right, so this is a muted fill with a
/// **seed-stable** figure over it: the same [seed] always draws the same
/// shape, so a list of items keeps its placeholders distinct and they
/// do not reshuffle on every rebuild.
///
/// ```dart
/// PlinthImageFallback(seed: exercise.id, color: category.color)
/// ```
class PlinthImageFallback extends StatelessWidget {
  const PlinthImageFallback({
    super.key,
    this.seed = '',
    this.color,
    this.strokeWidth = 3,
  });

  /// Chooses the figure. Any stable string — an id, a slug, the src
  /// that failed.
  final String seed;

  /// Palette key for the figure, resolved against the fill at the
  /// non-text floor (3:1, WCAG 1.4.11) so it stays visible rather than
  /// becoming a suggestion. Null takes the theme's neutral ramp.
  final String? color;

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final ramp = color ?? theme.rampFor(PlinthRole.neutral);
    final fill = theme.wash(ramp, alpha: 0.10);

    return ColoredBox(
      color: fill,
      child: CustomPaint(
        painter: _ScribblePainter(
          seed: seed,
          color: theme.readableOn(
            ramp,
            fill,
            level: PlinthContrast.nonText,
          ),
          strokeWidth: strokeWidth,
        ),
        // So the painter gets the box even with no child to size it.
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Draws a closed figure whose vertices come from [seed].
class _ScribblePainter extends CustomPainter {
  _ScribblePainter({
    required this.seed,
    required this.color,
    required this.strokeWidth,
  });

  final String seed;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // seed.hashCode is not stable across runs in Dart; a fixed hash is,
    // which is the entire point of calling this seed-stable.
    var h = 2166136261;
    for (final unit in seed.codeUnits) {
      h = (h ^ unit) * 16777619 & 0xFFFFFFFF;
    }
    final random = math.Random(h);

    final centre = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) * 0.28;
    final points = 5 + random.nextInt(3);
    final path = Path();

    for (var i = 0; i < points; i++) {
      final angle = (i / points) * 2 * math.pi - math.pi / 2;
      final wobble = 0.65 + random.nextDouble() * 0.7;
      final point =
          centre + Offset(math.cos(angle), math.sin(angle)) * radius * wobble;
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ScribblePainter old) =>
      old.seed != seed || old.color != color || old.strokeWidth != strokeWidth;
}
