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
