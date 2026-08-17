import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

/// A circular avatar matching Mantine's `Avatar`: shows [imageUrl] if
/// provided, falls back to [initials] on a theme-colored background,
/// and falls back further to a generic person icon if neither is set.
///
/// ```dart
/// PlinthAvatar(initials: 'YR', color: 'blue');
/// PlinthAvatar(imageUrl: 'https://example.com/photo.jpg', size: PlinthSize.lg);
///
/// // Initials and a colour derived from the name itself, so a list of
/// // people comes out varied without anyone assigning colours.
/// PlinthAvatar(name: 'Ada Lovelace');
/// ```
class PlinthAvatar extends StatelessWidget {
  const PlinthAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.color,
    this.size = PlinthSize.md,
    this.radius,
    this.name,
  });

  final String? imageUrl;

  /// Explicit initials. Wins over [name] when both are given.
  final String? initials;

  /// A person's full name, from which initials are derived — first
  /// letter of the first word and of the last, so "Ada Lovelace"
  /// reads AL and "Prince" reads P.
  ///
  /// When [color] is omitted the palette key is derived from the name
  /// too, so a list of people comes out varied and each person keeps
  /// the same colour everywhere they appear. That is the whole point
  /// of deriving it rather than picking at random.
  final String? name;

  /// Background color key for the initials/icon fallback. Ignored
  /// when [imageUrl] loads successfully, and derived from [name] when
  /// both this and [imageUrl] are absent.
  final String? color;

  final PlinthSize size;

  /// Corner radius — defaults to fully circular. Pass a smaller
  /// [PlinthSize] for a rounded-square avatar instead.
  final PlinthSize? radius;

  static const Map<PlinthSize, double> _diameters = {
    PlinthSize.xs: 24,
    PlinthSize.sm: 32,
    PlinthSize.md: 40,
    PlinthSize.lg: 56,
    PlinthSize.xl: 72,
  };

  static const Map<PlinthSize, double> _fontSizes = {
    PlinthSize.xs: 10,
    PlinthSize.sm: 13,
    PlinthSize.md: 16,
    PlinthSize.lg: 22,
    PlinthSize.xl: 28,
  };

  /// First letter of the first word and of the last.
  static String? initialsFrom(String? name) {
    if (name == null) return null;
    final words = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((w) => w.isEmpty);
    if (words.isEmpty) return null;
    if (words.length == 1) return words.first.characters.first;
    return words.first.characters.first + words.last.characters.first;
  }

  /// A stable palette key for [name].
  ///
  /// Deliberately a sum of code units rather than [Object.hashCode]:
  /// Dart's string hash is randomised per isolate, so the same person
  /// would change colour between runs of the same app.
  static String colorFor(String name, List<String> palette) {
    var sum = 0;
    for (final unit in name.codeUnits) {
      sum = (sum + unit) % palette.length;
    }
    return palette[sum];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final diameter = _diameters[size]!;
    final derived = initials ?? initialsFrom(name);
    final palette = theme.colors.keys.toList()..sort();
    final colorKey = color ??
        (name != null && palette.isNotEmpty
            ? colorFor(name!, palette)
            : theme.primaryColor);
    final backgroundColor = theme.shaded(colorKey, 1);
    final foregroundColor = theme.shaded(colorKey, 7);
    final borderRadius = radius != null
        ? BorderRadius.circular(theme.radius[radius]!)
        : BorderRadius.circular(diameter / 2);

    Widget fallback() {
      if (derived != null && derived.isNotEmpty) {
        return Center(
          child: Text(
            derived.toUpperCase(),
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: _fontSizes[size],
            ),
          ),
        );
      }
      return Center(
        child:
            Icon(Icons.person, color: foregroundColor, size: diameter * 0.55),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: diameter,
        height: diameter,
        color: backgroundColor,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback(),
              )
            : fallback(),
      ),
    );
  }
}
