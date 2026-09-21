/// Composed sections for Plinth UI — whole arrangements rather than
/// the components they are made of.
///
/// A block is the thing a page is assembled from: a sign-in card, a
/// navbar, a stat tile. Each one is a real widget with a real API, not
/// a snippet to paste — Dart tree-shakes the ones an app does not use,
/// so breadth here costs a binary nothing.
///
/// Every visible string is a parameter, with an English default so a
/// block renders before anything has been translated. This package has
/// no localisation of its own and does not depend on `intl`.
///
/// Re-exports `plinth_components`, so an app that builds pages from
/// blocks and fills them with components needs one import.
library;

export 'package:plinth_components/plinth_components.dart';

export 'src/auth/plinth_auth_card.dart';
export 'src/auth/plinth_password_reset_block.dart';
export 'src/auth/plinth_sign_in_block.dart';
export 'src/auth/plinth_sign_up_block.dart';
export 'src/auth/plinth_split_auth_block.dart';
export 'src/auth/plinth_two_factor_block.dart';
export 'src/contact/plinth_contact_block.dart';
export 'src/contact/plinth_support_channels.dart';
export 'src/content/plinth_faq_block.dart';
export 'src/data/plinth_stat_tile.dart';
export 'src/feedback/plinth_banner_block.dart';
export 'src/feedback/plinth_error_page_block.dart';
export 'src/feedback/plinth_offline_notice.dart';
export 'src/marketing/plinth_comparison_block.dart';
export 'src/marketing/plinth_feature_block.dart';
export 'src/marketing/plinth_hero_block.dart';
export 'src/marketing/plinth_logo_strip.dart';
export 'src/marketing/plinth_stat_strip.dart';
export 'src/navigation/plinth_page_header.dart';
export 'src/navigation/plinth_sidebar.dart';
export 'src/navigation/plinth_top_bar.dart';
