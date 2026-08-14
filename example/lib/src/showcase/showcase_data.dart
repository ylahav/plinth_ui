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
        ExampleEntry('Collapsible navbar', _collapsibleNavbar,
            exampleCode['CollapsibleNavbarExample']!),
        ExampleEntry('Sectioned navbar', _sectionedNavbar,
            exampleCode['SectionedNavbarExample']!),
        ExampleEntry('Navbar with search', _navbarWithSearch,
            exampleCode['NavbarWithSearchExample']!),
      ]),
      SubcategoryData('Headers', Icons.view_headline, [
        ExampleEntry('Centered header', _centeredHeader,
            exampleCode['CenteredHeaderExample']!),
        ExampleEntry(
          'Header with breadcrumbs',
          _headerWithBreadcrumbs,
          exampleCode['HeaderWithBreadcrumbsExample']!,
        ),
        ExampleEntry('Header with tabs', _headerWithTabs,
            exampleCode['HeaderWithTabsExample']!),
        ExampleEntry('Header with filters', _headerWithFilters,
            exampleCode['HeaderWithFiltersExample']!),
        ExampleEntry('Sticky header', _stickyHeader,
            exampleCode['StickyHeaderExample']!),
      ]),
      SubcategoryData('Stats', Icons.insights_outlined, [
        ExampleEntry(
            'Stat tiles', _statTileRow, exampleCode['StatTileRowExample']!),
        ExampleEntry('Stat with progress', _statWithProgress,
            exampleCode['StatWithProgressExample']!),
        ExampleEntry(
            'Live metrics', _liveMetrics, exampleCode['LiveMetricsExample']!),
      ]),
      SubcategoryData('User Info & Controls', Icons.account_circle_outlined, [
        ExampleEntry(
            'User button', _userButton, exampleCode['UserButtonExample']!),
        ExampleEntry('Profile card', _userProfileCard,
            exampleCode['UserProfileCardExample']!),
      ]),
      SubcategoryData('Application Cards', Icons.dashboard_outlined, [
        ExampleEntry(
            'Project card', _projectCard, exampleCode['ProjectCardExample']!),
        ExampleEntry('Task card', _taskCard, exampleCode['TaskCardExample']!),
      ]),
      SubcategoryData('Inputs', Icons.input, [
        ExampleEntry(
            'Search bar', _searchBar, exampleCode['SearchBarExample']!),
        ExampleEntry('Filter fields', _filterFields,
            exampleCode['FilterFieldsExample']!),
        ExampleEntry('Formatted fields', _formattedFields,
            exampleCode['FormattedFieldsExample']!),
      ]),
      SubcategoryData('Buttons', Icons.smart_button_outlined, [
        ExampleEntry('Toolbar actions', _toolbarActions,
            exampleCode['ToolbarActionsExample']!),
        ExampleEntry('Destructive actions', _destructiveActions,
            exampleCode['DestructiveActionsExample']!),
      ]),
      SubcategoryData('Sliders', Icons.tune, [
        ExampleEntry('Price range filter', _priceRangeFilter,
            exampleCode['PriceRangeFilterExample']!),
        ExampleEntry('Setting sliders', _settingSliders,
            exampleCode['SettingSlidersExample']!),
      ]),
      SubcategoryData('Grids', Icons.grid_view, [
        ExampleEntry('Dashboard grid', _dashboardGrid,
            exampleCode['DashboardGridExample']!),
        ExampleEntry('Card gallery', _cardGalleryGrid,
            exampleCode['CardGalleryGridExample']!),
      ]),
      SubcategoryData('Tables', Icons.table_rows_outlined, [
        ExampleEntry(
            'Member table', _memberTable, exampleCode['MemberTableExample']!),
        ExampleEntry('Invoice table', _invoiceTable,
            exampleCode['InvoiceTableExample']!),
        ExampleEntry('Sortable table', _sortableTable,
            exampleCode['SortableTableExample']!),
      ]),
      SubcategoryData('Dropzones', Icons.upload_file_outlined, [
        ExampleEntry('File dropzone', _fileDropzone,
            exampleCode['FileDropzoneExample']!),
        ExampleEntry('Avatar upload', _avatarUpload,
            exampleCode['AvatarUploadExample']!),
      ]),
      SubcategoryData("Drag'n'Drop", Icons.drag_indicator, [
        ExampleEntry('Reorderable list', _reorderableList,
            exampleCode['ReorderableListExample']!),
        ExampleEntry(
            'Kanban columns', _kanbanDrop, exampleCode['KanbanDropExample']!),
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
      SubcategoryData('FAQ', Icons.help_outline, [
        ExampleEntry('FAQ accordion', _faqAccordion,
            exampleCode['FaqAccordionExample']!),
        ExampleEntry('FAQ with contact', _faqWithContact,
            exampleCode['FaqWithContactExample']!),
      ]),
      SubcategoryData('Banners', Icons.campaign_outlined, [
        ExampleEntry('Announcement', _announcementBanner,
            exampleCode['AnnouncementBannerExample']!),
        ExampleEntry('Consent banner', _consentBanner,
            exampleCode['ConsentBannerExample']!),
      ]),
      SubcategoryData('Contact Us', Icons.alternate_email, [
        ExampleEntry(
            'Contact form', _contactForm, exampleCode['ContactFormExample']!),
        ExampleEntry('Contact with details', _contactWithDetails,
            exampleCode['ContactWithDetailsExample']!),
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
      SubcategoryData('Comments', Icons.forum_outlined, [
        ExampleEntry('Single comment', _singleComment,
            exampleCode['SingleCommentExample']!),
        ExampleEntry('Comment thread', _commentThread,
            exampleCode['CommentThreadExample']!),
      ]),
      SubcategoryData('Author Info', Icons.person_outline, [
        ExampleEntry('Inline author', _authorInline,
            exampleCode['AuthorInlineExample']!),
        ExampleEntry(
            'Author card', _authorCard, exampleCode['AuthorCardExample']!),
      ]),
      SubcategoryData('Table of Contents', Icons.list_alt_outlined, [
        ExampleEntry('Article contents', _articleContents,
            exampleCode['ArticleContentsExample']!),
        ExampleEntry('Contents rail', _articleContentsRail,
            exampleCode['ArticleWithContentsRailExample']!),
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
Widget _faqAccordion(BuildContext context) => const FaqAccordionExample();
Widget _faqWithContact(BuildContext context) => const FaqWithContactExample();
Widget _userButton(BuildContext context) => const UserButtonExample();
Widget _userProfileCard(BuildContext context) => const UserProfileCardExample();
Widget _projectCard(BuildContext context) => const ProjectCardExample();
Widget _taskCard(BuildContext context) => const TaskCardExample();
Widget _singleComment(BuildContext context) => const SingleCommentExample();
Widget _commentThread(BuildContext context) => const CommentThreadExample();
Widget _announcementBanner(BuildContext context) =>
    const AnnouncementBannerExample();
Widget _consentBanner(BuildContext context) => const ConsentBannerExample();
Widget _memberTable(BuildContext context) => const MemberTableExample();
Widget _invoiceTable(BuildContext context) => const InvoiceTableExample();
Widget _searchBar(BuildContext context) => const SearchBarExample();
Widget _filterFields(BuildContext context) => const FilterFieldsExample();
Widget _toolbarActions(BuildContext context) => const ToolbarActionsExample();
Widget _destructiveActions(BuildContext context) =>
    const DestructiveActionsExample();
Widget _priceRangeFilter(BuildContext context) =>
    const PriceRangeFilterExample();
Widget _settingSliders(BuildContext context) => const SettingSlidersExample();
Widget _dashboardGrid(BuildContext context) => const DashboardGridExample();
Widget _cardGalleryGrid(BuildContext context) => const CardGalleryGridExample();
Widget _contactForm(BuildContext context) => const ContactFormExample();
Widget _contactWithDetails(BuildContext context) =>
    const ContactWithDetailsExample();
Widget _fileDropzone(BuildContext context) => const FileDropzoneExample();
Widget _avatarUpload(BuildContext context) => const AvatarUploadExample();
Widget _reorderableList(BuildContext context) => const ReorderableListExample();
Widget _kanbanDrop(BuildContext context) => const KanbanDropExample();
Widget _articleContents(BuildContext context) => const ArticleContentsExample();
Widget _articleContentsRail(BuildContext context) =>
    const ArticleWithContentsRailExample();
Widget _liveMetrics(BuildContext context) => const LiveMetricsExample();
Widget _sortableTable(BuildContext context) => const SortableTableExample();
Widget _formattedFields(BuildContext context) => const FormattedFieldsExample();
Widget _collapsibleNavbar(BuildContext context) =>
    const CollapsibleNavbarExample();
Widget _sectionedNavbar(BuildContext context) => const SectionedNavbarExample();
Widget _navbarWithSearch(BuildContext context) =>
    const NavbarWithSearchExample();
Widget _headerWithTabs(BuildContext context) => const HeaderWithTabsExample();
Widget _headerWithFilters(BuildContext context) =>
    const HeaderWithFiltersExample();
Widget _stickyHeader(BuildContext context) => const StickyHeaderExample();
