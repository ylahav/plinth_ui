/// The strings this library says out loud, in one place a caller can
/// replace.
///
/// **This ships a seam, not translations.** There are no `.arb` files
/// here, no generated code, and no `intl` dependency — `plinth_blocks`
/// promises the last of those in its README and this keeps it. What it
/// provides is the one thing an app cannot add from outside: a way to
/// reach strings the library previously hardcoded.
///
/// The gap it closes is narrower and worse than "the library is in
/// English". Twenty-one strings were hardcoded, and **every one is a
/// screen-reader label** — "Previous slide", "Close dialog", "Dismiss
/// alert". A visible English string in a Spanish app is obvious to
/// whoever sees it. An *audible* one is not: the person it fails is the
/// person who cannot see that it is wrong.
///
/// Every widget still takes its own label parameter, and that parameter
/// still wins. This is the fallback beneath it, not a replacement for
/// it — nothing about the existing API changed.
library;

import 'package:flutter/material.dart';

/// Every string the library falls back on, as fields.
///
/// A plain class rather than a generated message bundle, so overriding
/// one string is a `copyWith` and not a build step. Names say what the
/// string *is for*, not what it currently says, because the English is
/// the part expected to change.
@immutable
class PlinthStrings {
  const PlinthStrings({
    this.dismissAlert = 'Dismiss alert',
    this.dismissNotification = 'Dismiss notification',
    this.closeDialog = 'Close dialog',
    this.previousSlide = 'Previous slide',
    this.nextSlide = 'Next slide',
    this.clearSearch = 'Clear search',
    this.clearSelection = 'Clear selection',
    this.clearAllSelections = 'Clear all selections',
    this.clearAllTags = 'Clear all tags',
    this.clearSelectedFiles = 'Clear selected files',
    this.clearColor = 'Clear colour',
    this.chooseColor = 'Choose colour',
    this.saturationAndBrightness = 'Saturation and brightness',
    this.opacity = 'Opacity',
    this.hue = 'Hue',
    this.angle = 'Angle',
    this.rating = 'Rating',
    this.resizeWindow = 'Resize window',
    this.decrease = 'Decrease',
    this.increase = 'Increase',
    this.passwordStrength = 'Password strength',
  });

  final String dismissAlert;
  final String dismissNotification;
  final String closeDialog;
  final String previousSlide;
  final String nextSlide;
  final String clearSearch;
  final String clearSelection;
  final String clearAllSelections;
  final String clearAllTags;
  final String clearSelectedFiles;

  /// Spelled `colour` in the English defaults and `color` in the field
  /// name, on purpose: the API is Dart, which spells it `Color`, and
  /// the string is prose, which the rest of this library spells in
  /// British English. A caller overriding it chooses either.
  final String clearColor;
  final String chooseColor;

  final String saturationAndBrightness;
  final String opacity;
  final String hue;
  final String angle;
  final String rating;
  final String resizeWindow;
  final String decrease;
  final String increase;
  final String passwordStrength;

  /// Every field, in order, for equality and hashing.
  ///
  /// A list rather than twenty-one `&&` clauses, because the next
  /// string added would have to be remembered in three places and
  /// would be forgotten in at least one. Here it is remembered in two,
  /// and forgetting shows up as a delegate that reloads when it should
  /// not — which the test for `shouldReload` catches.
  List<Object> get _fields => [
        dismissAlert,
        dismissNotification,
        closeDialog,
        previousSlide,
        nextSlide,
        clearSearch,
        clearSelection,
        clearAllSelections,
        clearAllTags,
        clearSelectedFiles,
        clearColor,
        chooseColor,
        saturationAndBrightness,
        opacity,
        hue,
        angle,
        rating,
        resizeWindow,
        decrease,
        increase,
        passwordStrength,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlinthStrings) return false;
    final a = _fields;
    final b = other._fields;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_fields);

  PlinthStrings copyWith({
    String? dismissAlert,
    String? dismissNotification,
    String? closeDialog,
    String? previousSlide,
    String? nextSlide,
    String? clearSearch,
    String? clearSelection,
    String? clearAllSelections,
    String? clearAllTags,
    String? clearSelectedFiles,
    String? clearColor,
    String? chooseColor,
    String? saturationAndBrightness,
    String? opacity,
    String? hue,
    String? angle,
    String? rating,
    String? resizeWindow,
    String? decrease,
    String? increase,
    String? passwordStrength,
  }) =>
      PlinthStrings(
        dismissAlert: dismissAlert ?? this.dismissAlert,
        dismissNotification: dismissNotification ?? this.dismissNotification,
        closeDialog: closeDialog ?? this.closeDialog,
        previousSlide: previousSlide ?? this.previousSlide,
        nextSlide: nextSlide ?? this.nextSlide,
        clearSearch: clearSearch ?? this.clearSearch,
        clearSelection: clearSelection ?? this.clearSelection,
        clearAllSelections: clearAllSelections ?? this.clearAllSelections,
        clearAllTags: clearAllTags ?? this.clearAllTags,
        clearSelectedFiles: clearSelectedFiles ?? this.clearSelectedFiles,
        clearColor: clearColor ?? this.clearColor,
        chooseColor: chooseColor ?? this.chooseColor,
        saturationAndBrightness:
            saturationAndBrightness ?? this.saturationAndBrightness,
        opacity: opacity ?? this.opacity,
        hue: hue ?? this.hue,
        angle: angle ?? this.angle,
        rating: rating ?? this.rating,
        resizeWindow: resizeWindow ?? this.resizeWindow,
        decrease: decrease ?? this.decrease,
        increase: increase ?? this.increase,
        passwordStrength: passwordStrength ?? this.passwordStrength,
      );
}

/// Reaches the [PlinthStrings] in scope.
///
/// **Works with nothing registered.** Most apps will never add a
/// delegate, and a library whose accessibility labels vanish unless you
/// opt in has made things worse rather than better — so [of] falls back
/// to the English defaults rather than asserting. That is the opposite
/// of `MaterialLocalizations`, which throws, and the difference is
/// deliberate: Material's strings are load-bearing for its own widgets,
/// where these are a translation seam over labels that already worked.
class PlinthLocalizations {
  const PlinthLocalizations(this.strings);

  final PlinthStrings strings;

  /// The delegate that supplies the built-in English.
  ///
  /// Registering it changes nothing on its own. It exists so an app
  /// that lists its delegates explicitly can include this one, and so
  /// [override] has something to sit beside.
  static const LocalizationsDelegate<PlinthLocalizations> delegate =
      _PlinthLocalizationsDelegate(PlinthStrings());

  /// A delegate supplying [strings] instead of the defaults.
  ///
  /// ```dart
  /// MaterialApp(
  ///   localizationsDelegates: [
  ///     PlinthLocalizations.override(
  ///       const PlinthStrings(
  ///         closeDialog: 'Cerrar diálogo',
  ///         nextSlide: 'Siguiente',
  ///       ),
  ///     ),
  ///   ],
  /// )
  /// ```
  ///
  /// Every field has a default, so overriding two of twenty-one is two
  /// lines rather than a file.
  static LocalizationsDelegate<PlinthLocalizations> override(
    PlinthStrings strings,
  ) =>
      _PlinthLocalizationsDelegate(strings);

  /// The strings in scope, or the English defaults if none are.
  static PlinthStrings of(BuildContext context) =>
      Localizations.of<PlinthLocalizations>(context, PlinthLocalizations)
          ?.strings ??
      const PlinthStrings();
}

class _PlinthLocalizationsDelegate
    extends LocalizationsDelegate<PlinthLocalizations> {
  const _PlinthLocalizationsDelegate(this.strings);

  final PlinthStrings strings;

  // Every locale, because this delegate carries one set of strings
  // rather than a table keyed by language. An app that wants different
  // strings per locale resolves that itself and passes the right set —
  // which is the same seam, used once more.
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<PlinthLocalizations> load(Locale locale) async =>
      PlinthLocalizations(strings);

  @override
  bool shouldReload(_PlinthLocalizationsDelegate old) => old.strings != strings;
}

/// Reads the strings the same way the tokens are read.
extension PlinthStringsContext on BuildContext {
  /// `context.plinthStrings.closeDialog`
  PlinthStrings get plinthStrings => PlinthLocalizations.of(this);
}
