import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

import '../../main.dart' show ShowcasePage;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plinth UI'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShowcasePage()),
            ),
            icon: const Icon(Icons.widgets_outlined, size: 18),
            label: const Text('Component gallery'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
        PlinthSimpleGrid(
          columns: 3,
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
