import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A network image with an automatic loading placeholder and error
/// fallback, matching Mantine's `Image`.
///
/// Flutter's own `Image.network` shows nothing while loading and
/// throws an unhandled render error visible to the user if the URL
/// fails — this fills both gaps with a themed loading indicator and
/// a broken-image icon, the two states a real app almost always
/// wants handled rather than left to fail silently or crash the
/// frame.
///
/// ```dart
/// PlinthImage(
///   src: 'https://example.com/photo.jpg',
///   height: 200,
///   fit: BoxFit.cover,
///   radius: PlinthSize.sm,
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
  });

  final String src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final PlinthSize? radius;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final resolvedRadius = radius != null ? theme.radius[radius]! : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(resolvedRadius),
      child: Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
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
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: width,
            height: height,
            child: ColoredBox(
              color: theme.roleShaded(PlinthRole.neutral, 1),
              child: Icon(Icons.broken_image_outlined,
                  color: theme.roleShaded(PlinthRole.neutral, 5)),
            ),
          );
        },
      ),
    );
  }
}
