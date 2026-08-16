import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import '../../main.dart' show ShowcasePage, ThemeToggleButton;
import 'category_detail_page.dart';
import 'showcase_data.dart';

/// Landing page matching https://ui.mantine.dev/#main's layout: a
/// handful of top-level categories (Application UI, Page Sections,
/// Blog UI), each showing its subcategories as tappable boxes that
/// navigate to a detail page with a few example layouts.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // A phone has room for the title, one icon and the theme toggle —
    // not for a labelled button as well. The tooltip carries the label
    // that the button drops.
    final compact = width < 600;

    void openGallery() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ShowcasePage()),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plinth UI'),
        actions: [
          if (compact)
            IconButton(
              onPressed: openGallery,
              icon: const Icon(Icons.widgets_outlined),
              tooltip: 'Component gallery',
            )
          else ...[
            TextButton.icon(
              onPressed: openGallery,
              icon: const Icon(Icons.widgets_outlined, size: 18),
              label: const Text('Component gallery'),
            ),
            const SizedBox(width: 8),
          ],
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: PlinthContainer(
          size: PlinthContainerSize.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlinthText(
                'Ready-made layouts, built from Plinth components',
                size: PlinthSize.xl,
                weight: FontWeight.w800,
              ),
              const PlinthSpace(h: PlinthSize.xs),
              const PlinthText(
                'Browse by category to see real compositions, not just isolated widgets.',
                size: PlinthSize.sm,
                color: 'gray',
              ),
              const PlinthSpace(h: PlinthSize.xl),
              for (final category in showcaseCategories) ...[
                _CategorySection(category: category),
                const PlinthSpace(h: PlinthSize.xl),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category});

  final CategoryData category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlinthText(category.title,
            size: PlinthSize.lg, weight: FontWeight.w700),
        const PlinthSpace(h: PlinthSize.xs),
        PlinthText(category.description, size: PlinthSize.sm, color: 'gray'),
        const PlinthSpace(h: PlinthSize.md),
        // Mobile-first: three tiles across a phone leaves each title
        // about 40px of room, which wraps it to one letter per line.
        PlinthSimpleGrid(
          columns: 1,
          columnsXs: 2,
          columnsMd: 3,
          spacing: PlinthSize.md,
          children: [
            for (final sub in category.subcategories)
              _SubcategoryBox(category: category, subcategory: sub),
          ],
        ),
      ],
    );
  }
}

class _SubcategoryBox extends StatelessWidget {
  const _SubcategoryBox({required this.category, required this.subcategory});

  final CategoryData category;
  final SubcategoryData subcategory;

  @override
  Widget build(BuildContext context) {
    return PlinthUnstyledButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              CategoryDetailPage(category: category, subcategory: subcategory),
        ),
      ),
      child: PlinthPaper(
        p: PlinthSize.md,
        withBorder: true,
        radius: PlinthSize.sm,
        child: Row(
          children: [
            PlinthThemeIcon(
                icon: Icon(subcategory.icon), variant: PlinthVariant.light),
            const SizedBox(width: 12),
            Expanded(
              child: PlinthText(subcategory.title, weight: FontWeight.w600),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
