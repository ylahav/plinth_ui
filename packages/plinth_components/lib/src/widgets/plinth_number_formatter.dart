import 'package:flutter/material.dart';
import 'package:plinth_core/plinth_core.dart';

import 'plinth_text.dart';

/// Formatted number display, matching Mantine's `NumberFormatter`.
///
/// Grouping, decimals, prefix, and suffix — the formatting a figure in
/// a table or a stat tile needs, without reaching for a package.
///
/// **Not localised.** The separators are yours to pass, so this is
/// correct for a fixed format and wrong for anything that should follow
/// the user's locale. For that, format with `package:intl`'s
/// `NumberFormat` and render the result with [PlinthText] — this widget
/// deliberately doesn't pull `intl` into the dependency graph of every
/// app using the library.
///
/// ```dart
/// PlinthNumberFormatter(value: 1234567.5, prefix: r'$', decimalScale: 2)
/// // $1,234,567.50
/// ```
class PlinthNumberFormatter extends StatelessWidget {
  const PlinthNumberFormatter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.thousandSeparator = ',',
    this.decimalSeparator = '.',
    this.decimalScale,
    this.trimTrailingZeros = false,
    this.size = PlinthSize.md,
    this.color,
    this.weight,
  });

  final num value;

  final String? prefix;
  final String? suffix;

  /// Pass an empty string to group nothing.
  final String thousandSeparator;
  final String decimalSeparator;

  /// Fixed number of decimal places. Null keeps whatever the value has.
  final int? decimalScale;

  /// Drops trailing zeros after formatting, so 1.50 reads as 1.5. Has
  /// no effect without [decimalScale].
  final bool trimTrailingZeros;

  final PlinthSize size;
  final String? color;
  final FontWeight? weight;

  /// The formatted string, exposed so callers can reuse the same
  /// formatting somewhere this widget doesn't fit — a chart axis, an
  /// exported CSV, a semantics label.
  String get formatted {
    final negative = value < 0;
    final magnitude = value.abs();

    var text = decimalScale != null
        ? magnitude.toStringAsFixed(decimalScale!)
        : magnitude.toString();

    if (trimTrailingZeros && text.contains('.')) {
      text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    }

    final parts = text.split('.');
    var whole = parts.first;

    if (thousandSeparator.isNotEmpty) {
      // Group from the right, so the leading group can be 1-3 digits.
      final buffer = StringBuffer();
      for (var i = 0; i < whole.length; i++) {
        if (i > 0 && (whole.length - i) % 3 == 0) {
          buffer.write(thousandSeparator);
        }
        buffer.write(whole[i]);
      }
      whole = buffer.toString();
    }

    final body =
        parts.length > 1 ? '$whole$decimalSeparator${parts[1]}' : whole;
    return '${negative ? '-' : ''}${prefix ?? ''}$body${suffix ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    return PlinthText(formatted, size: size, color: color, weight: weight);
  }
}
