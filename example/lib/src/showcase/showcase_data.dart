import 'package:flutter/material.dart';

import 'examples.dart';
import 'examples_code.dart';

/// One example layout shown on a [SubcategoryData]'s detail page.
class ExampleEntry {
  const ExampleEntry(this.title, this.builder, this.code);

  final String title;
  final WidgetBuilder builder;

  /// Source snippet shown by this example's "Show code" panel.
  final String code;
}

/// One subcategory box shown within a [CategoryData]'s section on
/// the home page (e.g. "Navbars" within "Application UI").
class SubcategoryData {
  const SubcategoryData(this.title, this.icon, this.examples);

  final String title;
  final IconData icon;
  final List<ExampleEntry> examples;
}

/// One top-level section on the home page (e.g. "Application UI"),
/// matching https://ui.mantine.dev/#main's grouping.
class CategoryData {
  const CategoryData(this.title, this.description, this.subcategories);

  final String title;
  final String description;
  final List<SubcategoryData> subcategories;
}

final List<CategoryData> showcaseCategories = [
  CategoryData(
    'Application UI',
    'Navigation and chrome for real apps',
    [
      SubcategoryData('Navbars', Icons.view_sidebar_outlined, [
        ExampleEntry('Simple navbar', _simpleNavbar,
            exampleCode['SimpleNavbarExample']!),
        ExampleEntry(
          'Navbar with avatar',
          _navbarWithAvatar,
          exampleCode['NavbarWithAvatarExample']!,
        ),
      ]),
      SubcategoryData('Headers', Icons.view_headline, [
        ExampleEntry('Centered header', _centeredHeader,
            exampleCode['CenteredHeaderExample']!),
        ExampleEntry(
          'Header with breadcrumbs',
          _headerWithBreadcrumbs,
          exampleCode['HeaderWithBreadcrumbsExample']!,
        ),
      ]),
      SubcategoryData('Stats', Icons.insights_outlined, [
        ExampleEntry(
            'Stat tiles', _statTileRow, exampleCode['StatTileRowExample']!),
        ExampleEntry('Stat with progress', _statWithProgress,
            exampleCode['StatWithProgressExample']!),
      ]),
      SubcategoryData('Footers', Icons.horizontal_rule, [
        ExampleEntry('Simple footer', _simpleFooter,
            exampleCode['SimpleFooterExample']!),
        ExampleEntry(
          'Footer with link columns',
          _footerWithLinkColumns,
          exampleCode['FooterWithLinkColumnsExample']!,
        ),
      ]),
    ],
  ),
  CategoryData(
    'Page Sections',
    'Building blocks for marketing pages',
    [
      SubcategoryData('Hero Sections', Icons.crop_landscape_outlined, [
        ExampleEntry('Centered hero', _heroCentered,
            exampleCode['HeroCenteredExample']!),
        ExampleEntry(
            'Split hero', _heroSplit, exampleCode['HeroSplitExample']!),
      ]),
      SubcategoryData('Feature Sections', Icons.grid_view_outlined, [
        ExampleEntry(
            'Feature grid', _featureGrid, exampleCode['FeatureGridExample']!),
        ExampleEntry(
            'Feature list', _featureList, exampleCode['FeatureListExample']!),
      ]),
      SubcategoryData('Authentication', Icons.lock_outline, [
        ExampleEntry('Sign in', _signInForm, exampleCode['SignInFormExample']!),
        ExampleEntry('Sign up', _signUpForm, exampleCode['SignUpFormExample']!),
      ]),
      SubcategoryData('Error Pages', Icons.error_outline, [
        ExampleEntry('404 not found', _notFoundPage,
            exampleCode['NotFoundPageExample']!),
        ExampleEntry('500 server error', _serverErrorPage,
            exampleCode['ServerErrorPageExample']!),
      ]),
    ],
  ),
  CategoryData(
    'Blog UI',
    'Content and author presentation',
    [
      SubcategoryData('Article Cards', Icons.article_outlined, [
        ExampleEntry(
          'Simple article card',
          _simpleArticleCard,
          exampleCode['SimpleArticleCardExample']!,
        ),
        ExampleEntry(
          'Article card with author',
          _articleCardWithAuthor,
          exampleCode['ArticleCardWithAuthorExample']!,
        ),
      ]),
      SubcategoryData('Author Info', Icons.person_outline, [
        ExampleEntry('Inline author', _authorInline,
            exampleCode['AuthorInlineExample']!),
        ExampleEntry(
            'Author card', _authorCard, exampleCode['AuthorCardExample']!),
      ]),
    ],
  ),
];

// Wrapped as plain functions matching WidgetBuilder (BuildContext) ->
// Widget — a constructor tear-off like `SimpleNavbarExample.new` has
// the constructor's own signature ({Key? key}) -> Widget instead,
// which isn't assignable to WidgetBuilder.
Widget _simpleNavbar(BuildContext context) => const SimpleNavbarExample();
Widget _navbarWithAvatar(BuildContext context) =>
    const NavbarWithAvatarExample();
Widget _centeredHeader(BuildContext context) => const CenteredHeaderExample();
Widget _headerWithBreadcrumbs(BuildContext context) =>
    const HeaderWithBreadcrumbsExample();
Widget _heroCentered(BuildContext context) => const HeroCenteredExample();
Widget _heroSplit(BuildContext context) => const HeroSplitExample();
Widget _featureGrid(BuildContext context) => const FeatureGridExample();
Widget _featureList(BuildContext context) => const FeatureListExample();
Widget _simpleArticleCard(BuildContext context) =>
    const SimpleArticleCardExample();
Widget _articleCardWithAuthor(BuildContext context) =>
    const ArticleCardWithAuthorExample();
Widget _authorInline(BuildContext context) => const AuthorInlineExample();
Widget _authorCard(BuildContext context) => const AuthorCardExample();
Widget _signInForm(BuildContext context) => const SignInFormExample();
Widget _signUpForm(BuildContext context) => const SignUpFormExample();
Widget _statTileRow(BuildContext context) => const StatTileRowExample();
Widget _statWithProgress(BuildContext context) =>
    const StatWithProgressExample();
Widget _notFoundPage(BuildContext context) => const NotFoundPageExample();
Widget _serverErrorPage(BuildContext context) => const ServerErrorPageExample();
Widget _simpleFooter(BuildContext context) => const SimpleFooterExample();
Widget _footerWithLinkColumns(BuildContext context) =>
    const FooterWithLinkColumnsExample();
