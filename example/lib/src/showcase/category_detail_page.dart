import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import '../../main.dart' show ThemeToggleButton;
import 'code_panel.dart';
import 'showcase_data.dart';

/// Width of the widest showcase block. Blocks declare their own width
/// — most are 560 — and the preview area gives them at least this much
/// so a narrow screen pans rather than clips.
const double _widestBlock = 640;

/// Detail page for one subcategory (e.g. "Navbars"), listing its
/// example layouts stacked vertically with a title and a "Show code"
/// toggle above each — matching
/// https://ui.mantine.dev/category/navbars/'s layout.
class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage(
      {super.key, required this.category, required this.subcategory});

  final CategoryData category;
  final SubcategoryData subcategory;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  /// Example titles whose "Show code" panel is currently expanded.
  final Set<String> _codeVisible = {};

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subcategory.title),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: PlinthContainer(
          size: PlinthContainerSize.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlinthBreadcrumbs(
                items: [
                  PlinthBreadcrumbItem(
                    label: 'Home',
                    onTap: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                  ),
                  PlinthBreadcrumbItem(
                    label: widget.category.title,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  PlinthBreadcrumbItem(label: widget.subcategory.title),
                ],
              ),
              const PlinthSpace(h: PlinthSize.md),
              PlinthText(widget.subcategory.title,
                  size: PlinthSize.xl, weight: FontWeight.w800),
              const PlinthSpace(h: PlinthSize.xl),
              for (final example in widget.subcategory.examples) ...[
                _ExampleSection(
                    example: example,
                    expanded: _codeVisible.contains(example.title),
                    onToggle: () {
                      setState(() {
                        _codeVisible.contains(example.title)
                            ? _codeVisible.remove(example.title)
                            : _codeVisible.add(example.title);
                      });
                    }),
                const PlinthSpace(h: PlinthSize.xl),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleSection extends StatelessWidget {
  const _ExampleSection(
      {required this.example, required this.expanded, required this.onToggle});

  final ExampleEntry example;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: PlinthText(example.title, weight: FontWeight.w600)),
            TextButton.icon(
              onPressed: onToggle,
              icon: Icon(expanded ? Icons.code_off : Icons.code, size: 16),
              label: Text(expanded ? 'Hide code' : 'Show code'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const PlinthSpace(h: PlinthSize.sm),
        PlinthPaper(
          p: PlinthSize.lg,
          withBorder: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Blocks are laid out for a page — the widest is 640 —
              // so on a phone the preview pans sideways inside its
              // border rather than overflowing the screen. The child
              // keeps a *bounded* width: handing it the unbounded
              // width a bare scroller would give breaks every Row with
              // an Expanded or Spacer in it.
              final width = math.max(constraints.maxWidth, _widestBlock);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Nothing to scroll once the page is wide enough, and
                // a scrollable that can't move still eats trackpad
                // gestures aimed at the page behind it.
                physics: width > constraints.maxWidth
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Builder(builder: example.builder),
                ),
              );
            },
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CodePanel(code: example.code),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
