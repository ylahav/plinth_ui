import 'package:flutter/material.dart';

import 'plinth_theme.dart';
import 'tokens.dart';

/// One field where a `ColorScheme` and a [PlinthTheme] disagree about
/// what colour something is.
@immutable
class PlinthSchemeDisagreement {
  const PlinthSchemeDisagreement(this.field, this.plinth, this.material);

  /// The `ColorScheme` field, as it is named on the class — `primary`,
  /// `error`, `outline`.
  final String field;

  /// What [PlinthTheme] says the colour is.
  final Color plinth;

  /// What the `ColorScheme` being checked says it is.
  final Color material;

  @override
  String toString() => '$field: plinth ${_hex(plinth)} '
      'vs material ${_hex(material)}';

  static String _hex(Color c) =>
      '#${((c.r * 255).round() << 16 | (c.g * 255).round() << 8 | (c.b * 255).round()).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlinthSchemeDisagreement &&
          other.field == field &&
          other.plinth == plinth &&
          other.material == material;

  @override
  int get hashCode => Object.hash(field, plinth, material);
}

/// Reconciling a [PlinthTheme] with Material's `ThemeData`.
///
/// **The need here is agreement, not generation** — a finding from
/// migrating a real app, which is worth stating because it reverses
/// what this package originally planned to build.
///
/// A `toThemeData()` that constructs a whole `ThemeData` was ranked the
/// highest-priority task in the roadmap, and during the migration it
/// **was never reached for once**. The app already had a working
/// `ThemeData` — six hand-written lines — and replacing it wholesale is
/// riskier than the six lines it saves.
///
/// What actually broke was that the app then read colour from two
/// systems at the same time: 58 `plinth.*` lookups beside 31
/// `colorScheme.*` and 80 `textTheme.*` ones, with `colorScheme.error`
/// (Material's red, from the seed) sitting in the same tables as the
/// app's own red, and **nothing keeping them in agreement.**
///
/// So this extension offers both directions, and the second is the one
/// the migration actually wanted:
///
/// - [toColorScheme] / [toTextTheme] — derive Material's types from
///   Plinth, for an app willing to hand over the decision.
/// - [colorSchemeDisagreements] — keep your own `ThemeData` and get a
///   list of where the two disagree. Assert it is empty in a test and
///   the drift cannot come back silently.
extension PlinthMaterialBridge on PlinthTheme {
  /// The `ColorScheme` this theme implies.
  ///
  /// Plinth does not have an opinion about every `ColorScheme` field, so
  /// this starts from `ColorScheme.fromSeed` and overrides only what it
  /// genuinely owns — see [ownedSchemeFields]. Secondary, tertiary, the
  /// container roles and the inverse roles are **Material's answers, not
  /// Plinth's**, because inventing values for them would produce
  /// agreement that means nothing.
  ///
  /// `error` comes from [PlinthRole.error], so remapping that role moves
  /// Material's error colour with it and the two cannot drift apart.
  ColorScheme toColorScheme() {
    final primary = shaded(primaryColor, 6);
    final error = roleShaded(PlinthRole.error, 6);
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: contrastingOn(primary),
      error: error,
      onError: contrastingOn(error),
      surface: surface,
      onSurface: text,
      outline: border,
      outlineVariant: borderMuted,
      shadow: shadow,
      scrim: scrim,
    );
  }

  /// The `ColorScheme` fields [toColorScheme] decides, as opposed to the
  /// ones it inherits from `ColorScheme.fromSeed`.
  ///
  /// [colorSchemeDisagreements] checks exactly these, because a
  /// disagreement about a field Plinth has no opinion on is not a
  /// disagreement.
  static const List<String> ownedSchemeFields = [
    'primary',
    'onPrimary',
    'error',
    'onError',
    'surface',
    'onSurface',
    'outline',
    'outlineVariant',
    'shadow',
    'scrim',
  ];

  /// Where [other] disagrees with this theme, over the fields Plinth
  /// actually owns.
  ///
  /// For an app that keeps its own `ThemeData` — which is most of them —
  /// this is the whole point of the bridge:
  ///
  /// ```dart
  /// test('the two palettes agree', () {
  ///   expect(myPlinthTheme.colorSchemeDisagreements(myScheme), isEmpty);
  /// });
  /// ```
  ///
  /// Comparison is exact. A near-match is still two colours, and a
  /// tolerance would only decide for you how much drift is acceptable —
  /// which is the judgement this is meant to surface rather than make.
  ///
  /// An empty list does **not** mean the themes agree about everything;
  /// it means they agree about [ownedSchemeFields].
  List<PlinthSchemeDisagreement> colorSchemeDisagreements(ColorScheme other) {
    final mine = toColorScheme();
    final pairs = <String, (Color, Color)>{
      'primary': (mine.primary, other.primary),
      'onPrimary': (mine.onPrimary, other.onPrimary),
      'error': (mine.error, other.error),
      'onError': (mine.onError, other.onError),
      'surface': (mine.surface, other.surface),
      'onSurface': (mine.onSurface, other.onSurface),
      'outline': (mine.outline, other.outline),
      'outlineVariant': (mine.outlineVariant, other.outlineVariant),
      'shadow': (mine.shadow, other.shadow),
      'scrim': (mine.scrim, other.scrim),
    };
    return [
      for (final entry in pairs.entries)
        if (entry.value.$1 != entry.value.$2)
          PlinthSchemeDisagreement(entry.key, entry.value.$1, entry.value.$2),
    ];
  }

  /// [base] with every size Plinth has a scale for replaced by that
  /// scale.
  ///
  /// **Only the body, title and label roles.** `fontSizes` runs 12 to 20,
  /// so it cannot answer what a `displayLarge` is without inventing a
  /// number — and `headline`/`display` are left exactly as [base] had
  /// them rather than guessed at. The migration's evidence is that this
  /// is where the mismatch actually lives: **80 `textTheme.*` lookups
  /// against 0 `fontSizes` ones**, so the app was reading Material's
  /// scale exclusively while Plinth's sat unread beside it.
  ///
  /// Defaults to `Typography.material2021`'s English theme for the
  /// theme's brightness when [base] is omitted.
  TextTheme toTextTheme({TextTheme? base}) {
    final start = base ??
        (brightness == Brightness.light
            ? Typography.material2021().black
            : Typography.material2021().white);
    double size(PlinthSize step) => fontSizes[step]!;
    return start.copyWith(
      bodySmall: start.bodySmall?.copyWith(fontSize: size(PlinthSize.xs)),
      bodyMedium: start.bodyMedium?.copyWith(fontSize: size(PlinthSize.sm)),
      bodyLarge: start.bodyLarge?.copyWith(fontSize: size(PlinthSize.md)),
      labelSmall: start.labelSmall?.copyWith(fontSize: size(PlinthSize.xs)),
      labelMedium: start.labelMedium?.copyWith(fontSize: size(PlinthSize.xs)),
      labelLarge: start.labelLarge?.copyWith(fontSize: size(PlinthSize.sm)),
      titleSmall: start.titleSmall?.copyWith(fontSize: size(PlinthSize.sm)),
      titleMedium: start.titleMedium?.copyWith(fontSize: size(PlinthSize.md)),
      titleLarge: start.titleLarge?.copyWith(fontSize: size(PlinthSize.xl)),
    );
  }
}
