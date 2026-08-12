import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// A dark code panel with `Plinth*` identifiers highlighted and a
/// copy button — the same visual language as `ShowcasePage`'s
/// per-section "Show code" panels, factored out so the new
/// category/example pages can reuse it without duplicating the
/// syntax-highlighting logic.
class CodePanel extends StatelessWidget {
  const CodePanel({super.key, required this.code});

  final String code;

  static const _baseStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12.5,
    color: Color(0xFFC1C2C5),
    height: 1.5,
  );

  static final _keywordStyle = _baseStyle.copyWith(
    color: const Color(0xFF74C0FC),
    fontWeight: FontWeight.w700,
  );

  static final _plinthIdentifier = RegExp(r'Plinth\w*');

  /// Splits [code] into a span tree so every `Plinth*` identifier
  /// renders bold in the theme's light-blue accent, while everything
  /// else stays the normal muted code color.
  static TextSpan _highlight(String code) {
    final spans = <TextSpan>[];
    var lastEnd = 0;
    for (final match in _plinthIdentifier.allMatches(code)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
            text: code.substring(lastEnd, match.start), style: _baseStyle));
      }
      spans.add(TextSpan(text: match.group(0), style: _keywordStyle));
      lastEnd = match.end;
    }
    if (lastEnd < code.length) {
      spans.add(TextSpan(text: code.substring(lastEnd), style: _baseStyle));
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 44, 12),
            child: SelectableText.rich(_highlight(code), style: _baseStyle),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PlinthCopyButton(value: code, color: 'gray'),
          ),
        ],
      ),
    );
  }
}
