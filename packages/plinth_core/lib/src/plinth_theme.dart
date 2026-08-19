import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Default spacing scale (in logical pixels), matching Mantine's defaults.
const Map<PlinthSize, double> kDefaultSpacing = {
  PlinthSize.xs: 10,
  PlinthSize.sm: 12,
  PlinthSize.md: 16,
  PlinthSize.lg: 20,
  PlinthSize.xl: 32,
};

/// The base spacing unit. Every step on the spacing scale, and every
/// ad-hoc gap a caller needs, should be a whole multiple of this.
///
/// Four rather than five or ten because that is what the values already
/// in use round to. `plinth_components` writes
/// `theme.spacing[PlinthSize.xs]! * 0.4` in 38 places and `* 0.8` in 8
/// more — with `xs` at 10 those are 4px and 8px, i.e. the library has
/// been reconstructing a sub-`xs` scale out of fractions because the
/// scale does not reach down that far. 80 of its 87 spacing multipliers
/// resolve to something below 10.
///
/// See [PlinthTheme.space].
const double kSpaceUnit = 4;

/// The spacing scale as compile-time constants.
///
/// [PlinthTheme.space] and [PlinthTheme.spacing] both need a theme, so
/// both cost a `BuildContext` and force a widget out of `const`. That is
/// the right trade for colour, which genuinely varies by theme — and the
/// wrong one for spacing, which does not. Applying a token layer to one
/// real app meant touching 355 spacing literals; routing them through a
/// theme lookup would have traded 355 `const` widgets for 355 runtime
/// ones and bought nothing.
///
/// ```dart
/// const SizedBox(height: PlinthSpacing.xs)          // still const
/// const EdgeInsets.all(PlinthSpacing.md)
/// ```
///
/// Use [PlinthTheme.space] only where the multiple is computed at
/// runtime, and [PlinthTheme.spacing] only where a caller passed a
/// [PlinthSize] you have to honour.
abstract final class PlinthSpacing {
  /// 4 — the base unit. Icon-to-label, chip padding, hairline gaps.
  static const double xxs = kSpaceUnit;

  /// 8 — the workhorse. Gaps inside a row or a form field.
  static const double xs = kSpaceUnit * 2;

  /// 12 — between related blocks.
  static const double sm = kSpaceUnit * 3;

  /// 16 — card padding, between sections.
  static const double md = kSpaceUnit * 4;

  /// 24 — between major regions.
  static const double lg = kSpaceUnit * 6;

  /// 32 — page gutters.
  static const double xl = kSpaceUnit * 8;
}

/// Default corner radius scale (in logical pixels).
const Map<PlinthSize, double> kDefaultRadius = {
  PlinthSize.xs: 2,
  PlinthSize.sm: 4,
  PlinthSize.md: 8,
  PlinthSize.lg: 16,
  PlinthSize.xl: 32,
};

/// Default font size scale (in logical pixels).
const Map<PlinthSize, double> kDefaultFontSizes = {
  PlinthSize.xs: 12,
  PlinthSize.sm: 14,
  PlinthSize.md: 16,
  PlinthSize.lg: 18,
  PlinthSize.xl: 20,
};

/// Surface, text, and border colors for the light theme.
///
/// These are *not* drawn from the color ramps. A ramp answers "what
/// does blue look like at shade 6"; these answer "what colour is a
/// panel, a body paragraph, a hairline" — the neutral chrome every
/// component paints regardless of which palette colour it was given.
/// Keeping them here rather than as literals inside widgets is what
/// makes a dark theme a matter of swapping values instead of editing
/// forty files.
const Color kLightSurface = Color(0xFFFFFFFF);
const Color kLightSurfaceMuted = Color(0xFFF1F3F5);
const Color kLightSurfaceSunken = Color(0xFFE9ECEF);
const Color kLightBorder = Color(0xFFCED4DA);
const Color kLightBorderMuted = Color(0xFFDEE2E6);
const Color kLightText = Color(0xDD000000);
const Color kLightTextMuted = Color(0x8A000000);
const Color kLightTextDisabled = Color(0x42000000);

/// The same set for the dark theme, using Mantine's `dark` ramp.
const Color kDarkSurface = Color(0xFF1A1B1E);
const Color kDarkSurfaceMuted = Color(0xFF25262B);
const Color kDarkSurfaceSunken = Color(0xFF2C2E33);
const Color kDarkBorder = Color(0xFF373A40);
const Color kDarkBorderMuted = Color(0xFF2C2E33);
const Color kDarkText = Color(0xFFC1C2C5);
const Color kDarkTextMuted = Color(0xFF909296);
const Color kDarkTextDisabled = Color(0xFF5C5F66);

/// The contrast floor a colour has to clear, by what it is being used
/// for. WCAG 2.x gives three, and picking between them is a decision
/// about the content — not something a caller should have to remember
/// as a bare number.
enum PlinthContrast {
  /// Normal body text: anything under ~18pt regular / ~14pt bold.
  /// The default, because most text is this and getting it wrong is
  /// invisible.
  body(4.5),

  /// Large text — headings at or above ~18pt regular / ~14pt bold.
  large(3.0),

  /// Non-text UI that carries meaning on its own: icons, chart marks,
  /// borders, focus rings (WCAG 1.4.11).
  nonText(3.0);

  const PlinthContrast(this.ratio);

  /// The minimum WCAG contrast ratio for this use.
  final double ratio;
}

/// The default categorical sequence, as keys into [PlinthTheme.colors].
///
/// Ten ramps, chosen and ordered by measurement rather than by taste.
/// Of the twelve non-neutral ramps, this is the ten-subset with the
/// largest **minimum pairwise CIE76 ΔE** (30.5), ordered so the
/// **minimum ΔE between neighbours** is as large as it can be (112.7).
/// `violet` and `green` are the two left out: violet collides with
/// `grape`, green with `teal` and `lime`.
///
/// Neighbours matter separately from the worst pair because adjacent
/// series are the ones a reader compares — touching pie slices, stacked
/// bars, consecutive legend rows.
///
/// `gray` is excluded on purpose. A categorical palette that includes
/// the neutral makes one series look disabled.
///
/// **Not verified for colour-vision deficiency.** The separation above
/// is measured in ordinary trichromatic vision; nothing here simulates
/// deuteranopia or protanopia, and `red` next to `orange` and `yellow`
/// is exactly where that would show. Pass your own
/// [PlinthTheme.seriesRamps] if you need a CVD-safe sequence.
const List<String> kDefaultSeriesRamps = [
  'red',
  'indigo',
  'teal',
  'pink',
  'lime',
  'grape',
  'yellow',
  'blue',
  'orange',
  'cyan',
];

/// A colour named by the role it plays, rather than by its hue.
///
/// An app does not think in "red shade 6"; it thinks in *expense*,
/// *income*, *pension*. Migrating one real app onto these packages cost
/// 110 lines of hand-written `app_tokens.dart` — ramp anchors, semantic
/// getters and resolvers — which is a design-token layer sitting on top
/// of a design-token package.
///
/// That layer worked only because [PlinthTheme.colors] accepts
/// arbitrary string keys, so role names could be smuggled in as ramps.
/// **That was an accident, not an API:** nothing documented it, nothing
/// validated it, and it collided with the ramp names
/// `plinth_components` hardcodes for itself (`red` is already the
/// destructive/error ramp — an app repurposing it silently restyles
/// every component error state).
///
/// Declaring roles here instead keeps the two namespaces apart: an app
/// owns [PlinthTheme.semanticColors], the component library owns
/// [PlinthTheme.colors].
///
/// ```dart
/// PlinthTheme.defaultTheme.copyWith(
///   colors: {
///     ...PlinthTheme.defaultTheme.colors,
///     'expenseRamp': PlinthTheme.generateShades(const Color(0xFFFF3B30)),
///   },
///   semanticColors: {'expense': const PlinthSemanticColor('expenseRamp')},
/// );
/// ```
@immutable
class PlinthSemanticColor {
  const PlinthSemanticColor(
    this.ramp, {
    this.shade = 6,
    this.level = PlinthContrast.body,
  });

  /// The key into [PlinthTheme.colors] this role resolves against.
  final String ramp;

  /// The role-shade for the fill. 6 to match what components default
  /// to, and what [PlinthTheme.generateShades] treats as the base.
  final int shade;

  /// The contrast floor [PlinthTheme.semanticText] has to clear.
  ///
  /// Per-role because the floor is a fact about the content, not about
  /// the colour: a role only ever used for a heading can honestly sit
  /// at [PlinthContrast.large], and one used in a table cell cannot.
  final PlinthContrast level;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlinthSemanticColor &&
          other.ramp == ramp &&
          other.shade == shade &&
          other.level == level;

  @override
  int get hashCode => Object.hash(ramp, shade, level);
}

/// The design-token layer for Plinth. Every Plinth widget reads its
/// colors, spacing, radius, and font sizes from an instance of this
/// class rather than hardcoding values, so a single theme swap
/// restyles the whole app.
///
/// Register it on your [ThemeData]:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [PlinthTheme.defaultTheme],
///   ),
/// )
/// ```
@immutable
class PlinthTheme extends ThemeExtension<PlinthTheme> {
  const PlinthTheme({
    required this.colors,
    required this.primaryColor,
    this.semanticColors = const {},
    this.seriesRamps = kDefaultSeriesRamps,
    this.seriesKeys = const {},
    this.spacing = kDefaultSpacing,
    this.radius = kDefaultRadius,
    this.fontSizes = kDefaultFontSizes,
    this.defaultRadius = PlinthSize.sm,
    this.brightness = Brightness.light,
    this.surface = kLightSurface,
    this.surfaceMuted = kLightSurfaceMuted,
    this.surfaceSunken = kLightSurfaceSunken,
    this.border = kLightBorder,
    this.borderMuted = kLightBorderMuted,
    this.text = kLightText,
    this.textMuted = kLightTextMuted,
    this.textDisabled = kLightTextDisabled,
    this.onFilled = const Color(0xFFFFFFFF),
    this.onFilledInverse = const Color(0xFF1A1B1E),
    this.shadow = const Color(0xFF000000),
    this.scrim = const Color(0xFF000000),
  });

  /// Named color palettes (e.g. 'blue', 'red', 'gray'), each with a
  /// 10-shade ramp from lightest (0) to darkest (9), mirroring Mantine.
  final Map<String, PlinthColorShades> colors;

  /// The ordered categorical palette, as keys into [colors].
  ///
  /// Chart series, legend swatches, tag colours — anywhere the only
  /// thing that matters is that the *n*th thing is tellable apart from
  /// the others. That is neither a brand ramp nor a status colour, and
  /// thirteen named ramps answer a different question.
  ///
  /// Read through [series] and [seriesFor] rather than directly.
  final List<String> seriesRamps;

  /// Domain keys pinned to a position in [seriesRamps] — `'groceries'`
  /// to 0, `'transport'` to 1.
  ///
  /// Registering a key fixes its colour. An unregistered key still
  /// resolves, deterministically, so a chart never has to invent one;
  /// see [seriesIndexFor].
  final Map<String, int> seriesKeys;

  /// Colours the *app* names by role — `expense`, `income`, `brand` —
  /// each resolving to a ramp in [colors] plus a shade.
  ///
  /// Empty by default: `plinth_components` declares no roles, so this
  /// map belongs entirely to the consuming app and cannot collide with
  /// the ramp names the library hardcodes for itself. See
  /// [PlinthSemanticColor], and [semantic] / [semanticText] /
  /// [semanticWash] for the three roles a real app actually read.
  final Map<String, PlinthSemanticColor> semanticColors;

  /// The key into [colors] used by components when no explicit
  /// `color` prop is given.
  final String primaryColor;

  final Map<PlinthSize, double> spacing;
  final Map<PlinthSize, double> radius;
  final Map<PlinthSize, double> fontSizes;

  /// The radius used when a component doesn't specify a [PlinthSize]
  /// for its `radius` prop.
  final PlinthSize defaultRadius;

  /// Whether this theme reads as light or dark. Components rarely need
  /// to branch on it — the tokens below already carry the difference —
  /// but it's here for the cases that genuinely do, and for callers
  /// deciding which theme to register.
  final Brightness brightness;

  /// Panel and field backgrounds: cards, modals, drawers, inputs.
  final Color surface;

  /// A step back from [surface], for fills that should read as
  /// recessed rather than raised: disabled inputs, keyboard keys, the
  /// track behind a segmented control.
  final Color surfaceMuted;

  /// A further step back, for dividers, progress tracks, and skeleton
  /// placeholders — things that are structure rather than content.
  final Color surfaceSunken;

  /// The default hairline around inputs and bordered containers.
  final Color border;

  /// A softer border, for decoration rather than delineation.
  final Color borderMuted;

  /// Body text.
  final Color text;

  /// Secondary text: descriptions, captions, inactive labels.
  final Color textMuted;

  /// Text and icons in a disabled control.
  final Color textDisabled;

  /// The light foreground for content sitting *on* a saturated fill —
  /// the label of a filled button, the tick in a checked checkbox.
  ///
  /// Deliberately not tied to [brightness]: a filled button is
  /// saturated in either theme. Which foreground a *given* fill needs
  /// depends on that fill's own lightness, not the theme's — use
  /// [contrastingOn] rather than reaching for this directly.
  final Color onFilled;

  /// The dark counterpart to [onFilled], for fills too light to carry
  /// white text — `yellow`, `lime`, `teal`, and the rest of the light
  /// half of the palette.
  final Color onFilledInverse;

  /// Base color for elevation shadows, applied at low opacity.
  final Color shadow;

  /// Base color for the barrier behind a modal or drawer.
  final Color scrim;

  /// A gap of [steps] base units, in logical pixels.
  ///
  /// The named scale ([spacing]) answers "how big is a medium gap".
  /// This answers "how big is *this* gap", which is the question a
  /// layout actually asks and the one the named scale keeps failing:
  /// its smallest step is `xs: 10`, above the values both this library
  /// and its adopters reach for most. Measured on one real app, 355
  /// spacing literals produced zero uses of [spacing], because its two
  /// commonest values — 8 (128 uses) and 4 (29) — are not on the scale
  /// at all.
  ///
  /// ```dart
  /// SizedBox(height: theme.space(2))   // 8
  /// EdgeInsets.all(theme.space(4))     // 16
  /// ```
  ///
  /// Half steps are allowed (`space(1.5)` is 6) but are a smell: if a
  /// layout needs many of them, the base unit is wrong for it.
  double space(double steps) => kSpaceUnit * steps;

  /// Resolves a color name + shade index to a concrete [Color].
  /// Falls back to [primaryColor] if the name isn't found.
  Color color(String name, int shade) {
    final ramp = colors[name] ?? colors[primaryColor]!;
    return ramp[shade.clamp(0, ramp.length - 1)];
  }

  /// Mirrors [shade] for the active brightness.
  ///
  /// A ramp runs light (0) to dark (9), and components pick shades on
  /// the assumption that low ones are gentle backgrounds and high ones
  /// carry contrast. That assumption inverts on a dark surface: a
  /// shade-0 wash behind an alert is nearly white, and a shade-6 accent
  /// as text is too dark to read. Mirroring keeps each shade's *role*
  /// while flipping its lightness.
  ///
  /// Use [shaded] rather than calling this directly.
  int shadeFor(int shade) => brightness == Brightness.light ? shade : 9 - shade;

  /// Resolves a palette key and a role-shade to a concrete colour,
  /// mirroring the shade when the theme is dark.
  ///
  /// This is what components should use. [color] stays available for
  /// an exact shade regardless of brightness.
  Color shaded(String name, int shade) => color(name, shadeFor(shade));

  /// A palette colour dark or light enough to read as text on
  /// [background].
  ///
  /// [shaded] mirrors a shade for the theme's brightness, which fixes
  /// the *theme* half of the problem. It cannot fix the *palette* half:
  /// the ramps differ in intrinsic lightness, so one shade index can't
  /// serve every hue. Shade 6 of `violet` reads comfortably on white
  /// while shade 6 of `cyan` lands near 2.2:1 — a colour you can see
  /// but not read.
  ///
  /// This walks the ramp from the role shade toward whichever end
  /// contrasts with [background] and returns the first shade clearing
  /// [minRatio], falling back to the ramp's extreme if none does. Use
  /// it wherever a palette colour is *text or an icon*; [shaded] is
  /// right for fills, which carry their own foreground via
  /// [contrastingOn].
  /// [level] names the floor by what the colour is for; [minRatio]
  /// overrides it with an explicit number when nothing fits.
  ///
  /// The default is [PlinthContrast.body] (4.5:1). It used to be 3.0,
  /// which is WCAG's *large text* threshold — a value that is correct
  /// for a heading and wrong for the table cell most callers are
  /// actually painting. Adopting this against a real app moved six of
  /// its seven text tokens from "large text only" up to AA.
  Color readableOn(
    String name,
    Color background, {
    int from = 6,
    PlinthContrast level = PlinthContrast.body,
    double? minRatio,
  }) {
    final target = minRatio ?? level.ratio;
    final start = shadeFor(from);
    // Darken against a light background, lighten against a dark one.
    final step = _luminance(background) > 0.5 ? 1 : -1;

    for (var shade = start; shade >= 0 && shade <= 9; shade += step) {
      final candidate = color(name, shade);
      if (_contrastRatio(candidate, background) >= target) return candidate;
    }
    return color(name, step > 0 ? 9 : 0);
  }

  /// A barely-there tint of [name], for the background of a status
  /// panel, a highlighted row, a callout.
  ///
  /// Deliberately *not* `shaded(name, 0)`. [shadeFor] mirrors 0 to 9 in
  /// a dark theme, which is right for a foreground — a shade's role
  /// survives the flip — but exactly wrong for a wash, whose role is
  /// "almost the same as the surface". Mirrored, the lightest shade
  /// becomes the most saturated one: `shaded('green', 0)` is `#F2F8F3`
  /// in light and `#245B2E` in dark, a saturated green panel.
  ///
  /// Compositing over [surface] keeps the role in both themes.
  Color wash(String name, {double alpha = 0.08}) =>
      Color.alphaBlend(color(name, 6).withValues(alpha: alpha), surface);

  /// A foreground that stays legible on [background].
  ///
  /// Returns whichever of [onFilled] and [onFilledInverse] contrasts
  /// better. A fixed light foreground fails badly on the lighter half
  /// of the palette — white on `yellow` or `teal` lands near a 2:1
  /// ratio, well under the 4.5:1 WCAG AA asks for — and which way it
  /// falls depends on the fill, not on the theme's brightness.
  Color contrastingOn(Color background) {
    return _contrastRatio(onFilledInverse, background) >
            _contrastRatio(onFilled, background)
        ? onFilledInverse
        : onFilled;
  }

  /// Relative luminance per WCAG 2.x.
  static double _luminance(Color c) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  /// WCAG contrast ratio between two opaque colours, 1.0 to 21.0.
  static double _contrastRatio(Color a, Color b) {
    final la = _luminance(a);
    final lb = _luminance(b);
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Whether [colors] defines a ramp under [name].
  ///
  /// [color] deliberately falls back rather than throwing, which means
  /// a typo or an unavailable palette key renders as the primary color
  /// with no complaint. Use this when you need to know the difference —
  /// picking a swatch to offer in a UI, say, rather than rendering one.
  bool hasColor(String name) => colors.containsKey(name);

  /// Whether [semanticColors] declares a role under [name].
  bool hasSemantic(String name) => semanticColors.containsKey(name);

  /// The declaration behind a role name.
  ///
  /// An undeclared name resolves to `PlinthSemanticColor(name)` — the
  /// role is treated as a ramp key. That keeps [semantic] working for
  /// plain palette names, and keeps the pre-`semanticColors` pattern
  /// of smuggling role names into [colors] rendering as it did. Use
  /// [hasSemantic] where the difference matters; the fallback is
  /// silent, exactly like [color]'s.
  PlinthSemanticColor roleFor(String name) =>
      semanticColors[name] ?? PlinthSemanticColor(name);

  /// The fill for a role — the colour itself.
  ///
  /// One of the three roles a real app read. Migrating that app used
  /// exactly a fill, a text variant and a wash per pole, and **reached
  /// for nothing else: 7 of each ramp's 10 shades were never read.**
  /// The ramp still backs all three because [semanticText] has to walk
  /// it to find a shade that clears its floor.
  Color semantic(String name) {
    final role = roleFor(name);
    return shaded(role.ramp, role.shade);
  }

  /// The role as *text or an icon*, dark or light enough to read on
  /// [on] — [surface] when omitted.
  ///
  /// Not the same colour as [semantic]. A brand red that looks right as
  /// a fill is routinely unreadable as a label: the subject app
  /// hand-computed `#B26A00` from its own `#FF9500` for exactly this
  /// reason, because `#FF9500` on white is 2.20:1. That hand-computed
  /// darkening *is* this method, written before it existed.
  ///
  /// Expect this to drift from brand. Clearing 4.5:1 moved that app's
  /// income pole `#34C759` → `#277F3E`. [PlinthSemanticColor.level]
  /// names the floor the role is held to; nothing here can resolve the
  /// brand-fidelity-versus-legibility conflict, only surface it.
  Color semanticText(String name, {Color? on}) {
    final role = roleFor(name);
    return readableOn(
      role.ramp,
      on ?? surface,
      from: role.shade,
      level: role.level,
    );
  }

  /// The role as a barely-there tint, for a status panel or a
  /// highlighted row. See [wash] for why this composites rather than
  /// taking the lightest shade.
  Color semanticWash(String name, {double alpha = 0.08}) =>
      wash(roleFor(name).ramp, alpha: alpha);

  /// The *n*th categorical colour, wrapping past the end of
  /// [seriesRamps].
  ///
  /// Wraps rather than throwing or fading, because a chart with more
  /// series than the palette has colours still has to render. Past the
  /// tenth series a repeat is unavoidable and a legend is doing the
  /// work regardless — see [kDefaultSeriesRamps] for the separation
  /// this can actually promise.
  Color series(int index) {
    if (seriesRamps.isEmpty) return shaded(primaryColor, 6);
    return shaded(seriesRamps[index % seriesRamps.length], 6);
  }

  /// The categorical colour for a domain key — `'groceries'`,
  /// `'emerging'`, `'crypto'`.
  ///
  /// **The unit here is a name, not a [Color], and that is the point.**
  /// The layer that knows a slice is `'crypto'` is usually pure Dart
  /// with no [BuildContext] and no business importing a theme; the
  /// layer that paints it has both. A name passes across that boundary,
  /// a colour cannot without dragging the theme along with it.
  Color seriesFor(String key) => series(seriesIndexFor(key));

  /// The position [seriesFor] resolves [key] to.
  ///
  /// A key registered in [seriesKeys] gets its pinned position.
  /// Anything else is hashed — deterministically, and with an explicit
  /// FNV-1a rather than [Object.hashCode], which Dart does not promise
  /// to keep stable between runs. An unregistered key therefore keeps
  /// the same colour across restarts and platforms, which is the
  /// difference between a chart that looks broken after a reload and
  /// one that does not.
  ///
  /// It does **not** promise two different keys get different colours,
  /// and this is not a theoretical caveat: `'groceries'` and
  /// `'transport'` — two categories from the app this API was built
  /// for — both land on 0. Ten positions and an unbounded key space
  /// collide by the pigeonhole principle long before the hash is at
  /// fault.
  ///
  /// So the hash is a floor, not a solution: it stops an unregistered
  /// key from being colourless or random. **Any set of categories shown
  /// together should be registered in [seriesKeys].**
  int seriesIndexFor(String key) {
    final pinned = seriesKeys[key];
    if (pinned != null) return pinned;
    if (seriesRamps.isEmpty) return 0;
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
    }
    return hash % seriesRamps.length;
  }

  /// Whether [seriesKeys] pins [key] to a position.
  bool hasSeriesKey(String key) => seriesKeys.containsKey(key);

  /// The default palette: Mantine's standard color set, each generated
  /// from its base (shade 6) value.
  ///
  /// Keep this broad. An unrecognized key falls back to the primary
  /// color silently, so a palette missing a color that callers
  /// reasonably expect doesn't fail — it just quietly renders the wrong
  /// thing, which is harder to notice than an error would be.
  static final PlinthTheme defaultTheme = PlinthTheme(
    primaryColor: 'blue',
    colors: {
      'gray': generateShades(const Color(0xFF868E96)),
      'red': generateShades(const Color(0xFFFA5252)),
      'pink': generateShades(const Color(0xFFE64980)),
      'grape': generateShades(const Color(0xFFBE4BDB)),
      'violet': generateShades(const Color(0xFF7950F2)),
      'indigo': generateShades(const Color(0xFF4C6EF5)),
      'blue': generateShades(const Color(0xFF228BE6)),
      'cyan': generateShades(const Color(0xFF15AABF)),
      'teal': generateShades(const Color(0xFF12B886)),
      'green': generateShades(const Color(0xFF40C057)),
      'lime': generateShades(const Color(0xFF82C91E)),
      'yellow': generateShades(const Color(0xFFFAB005)),
      'orange': generateShades(const Color(0xFFFD7E14)),
    },
  );

  /// The same palette as [defaultTheme], with the neutral chrome
  /// inverted.
  ///
  /// The color ramps are shared rather than darkened: a blue button
  /// should be the same blue in either theme, and Mantine takes the
  /// same approach. What changes is everything the ramps don't cover —
  /// surfaces, text, and borders.
  ///
  /// ```dart
  /// MaterialApp(
  ///   theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
  ///   darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
  /// )
  /// ```
  static final PlinthTheme darkTheme = PlinthTheme(
    primaryColor: defaultTheme.primaryColor,
    colors: defaultTheme.colors,
    brightness: Brightness.dark,
    surface: kDarkSurface,
    surfaceMuted: kDarkSurfaceMuted,
    surfaceSunken: kDarkSurfaceSunken,
    border: kDarkBorder,
    borderMuted: kDarkBorderMuted,
    text: kDarkText,
    textMuted: kDarkTextMuted,
    textDisabled: kDarkTextDisabled,
  );

  /// Generates a 10-shade ramp from a single base color, following
  /// the same idea as Mantine's/most design systems' generated
  /// palettes: light shades are desaturated tints suitable for
  /// backgrounds, dark shades are more saturated for contrast and
  /// text-on-color use, and shade 6 — the shade [PlinthButton] and
  /// friends default to for filled/base color — lands closest to
  /// how a typical brand color actually reads.
  ///
  /// Hue is held fixed across the ramp. Real Mantine palettes drift
  /// hue slightly at the extremes for richer darks and lights, and
  /// that was tried here — `+8°` down to `-6°`, zero at shades 5–6 so
  /// the brand colour a caller supplies comes back unchanged.
  ///
  /// It was reverted, and the reason is worth keeping: **one signed
  /// drift cannot suit every hue on a circle.** Rotating darks the
  /// same direction for all thirteen ramps sends red toward magenta
  /// and yellow toward orange, which reads fine, but blue toward cyan,
  /// which reads worse — dark blues get richer drifting the other way.
  /// The effect measured 8–10 RGB units at the dark end and 1–4 at the
  /// light end, so it is a real visual change, not a free one.
  ///
  /// Hand-tuned palettes drift each hue in the direction that suits it
  /// individually, which is precisely what a single generated formula
  /// can't express. Doing this properly means per-hue drift tables —
  /// a different and much larger job than a curve tweak. Contrast is
  /// not the blocker: `plinth_contrast_test.dart` passed throughout.
  static PlinthColorShades generateShades(Color base) {
    final baseHsl = HSLColor.fromColor(base);
    final hue = baseHsl.hue;

    // Non-linear lightness stops (index 0 = lightest, 9 = darkest).
    // Front-loaded spacing keeps shades 0-2 usable as subtle
    // backgrounds without washing out, while 5-6 stay close to the
    // base color's natural saturation/lightness for filled buttons,
    // badges, etc.
    const lightnessStops = [
      0.96,
      0.91,
      0.83,
      0.74,
      0.64,
      0.55,
      0.47,
      0.39,
      0.32,
      0.25,
    ];

    // Light shades are pulled toward white (desaturated) so they
    // read as soft tints rather than pale versions of the same hue;
    // dark shades are boosted slightly for richness.
    const saturationMultipliers = [
      0.55,
      0.65,
      0.75,
      0.85,
      0.92,
      1.0,
      1.0,
      0.95,
      0.90,
      0.85,
    ];

    // Re-anchor the curve so shade 6 *is* the supplied colour.
    //
    // The stops above are absolute, which normalises a base colour onto
    // the curve rather than anchoring it to it: feeding in `#FA5252`
    // and asking for shade 6 — the shade every component defaults to —
    // returned `#E90707`. The best-matching index was not even
    // consistent, landing anywhere from 5 to 8 depending on hue, so
    // there was no shade a caller could reliably ask for.
    //
    // Both endpoints stay put: shade 0 remains a usable tint and shade
    // 9 a usable dark, so only the interior stretches. Rescaling each
    // side rather than shifting the whole curve is what keeps the ramp
    // monotonic for any base colour, which a taper cannot promise — a
    // near-white base would otherwise push shade 1 past shade 0.
    //
    // Hue is already preserved and `saturationMultipliers[6]` is
    // already 1.0, so lightness was the only axis that drifted.
    const anchorIndex = 6;
    final anchor = baseHsl.lightness;
    // Widen an endpoint only if the base sits outside it — a near-white
    // or near-black base cannot have a lighter tint or a darker shade,
    // and the anchor is worth more than a spread it cannot have.
    final lightEnd = math.max(lightnessStops.first, anchor);
    final darkEnd = math.min(lightnessStops.last, anchor);
    final lightSpan = lightnessStops.first - lightnessStops[anchorIndex];
    final darkSpan = lightnessStops[anchorIndex] - lightnessStops.last;

    return List.generate(10, (i) {
      final double lightness;
      if (i <= anchorIndex) {
        final t = (lightnessStops.first - lightnessStops[i]) / lightSpan;
        lightness = lightEnd - (lightEnd - anchor) * t;
      } else {
        final t = (lightnessStops[i] - lightnessStops.last) / darkSpan;
        lightness = darkEnd + (anchor - darkEnd) * t;
      }
      final saturation =
          (baseHsl.saturation * saturationMultipliers[i]).clamp(0.0, 1.0);
      return HSLColor.fromAHSL(1.0, hue, saturation, lightness.clamp(0.0, 1.0))
          .toColor();
    });
  }

  @override
  PlinthTheme copyWith({
    Map<String, PlinthColorShades>? colors,
    String? primaryColor,
    Map<String, PlinthSemanticColor>? semanticColors,
    List<String>? seriesRamps,
    Map<String, int>? seriesKeys,
    Map<PlinthSize, double>? spacing,
    Map<PlinthSize, double>? radius,
    Map<PlinthSize, double>? fontSizes,
    PlinthSize? defaultRadius,
    Brightness? brightness,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceSunken,
    Color? border,
    Color? borderMuted,
    Color? text,
    Color? textMuted,
    Color? textDisabled,
    Color? onFilled,
    Color? onFilledInverse,
    Color? shadow,
    Color? scrim,
  }) {
    return PlinthTheme(
      colors: colors ?? this.colors,
      primaryColor: primaryColor ?? this.primaryColor,
      semanticColors: semanticColors ?? this.semanticColors,
      seriesRamps: seriesRamps ?? this.seriesRamps,
      seriesKeys: seriesKeys ?? this.seriesKeys,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      fontSizes: fontSizes ?? this.fontSizes,
      defaultRadius: defaultRadius ?? this.defaultRadius,
      brightness: brightness ?? this.brightness,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      border: border ?? this.border,
      borderMuted: borderMuted ?? this.borderMuted,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      onFilled: onFilled ?? this.onFilled,
      onFilledInverse: onFilledInverse ?? this.onFilledInverse,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  PlinthTheme lerp(ThemeExtension<PlinthTheme>? other, double t) {
    if (other is! PlinthTheme) return this;
    // Colors/spacing maps aren't meaningfully lerped key-by-key here;
    // snap at the midpoint. Replace with per-key Color.lerp if you
    // need smooth theme-transition animations.
    return t < 0.5 ? this : other;
  }
}

/// Convenience accessor: `context.plinth`.
extension PlinthThemeContext on BuildContext {
  PlinthTheme get plinth => Theme.of(this).plinth;
}

/// The same lookup for code that already holds a [ThemeData].
///
/// A helper written the idiomatic Flutter way — `Widget _badge(ThemeData
/// theme, …)` — has the theme and still could not reach the tokens,
/// because `context.plinth` was the only accessor. It had to grow a
/// [BuildContext] parameter, which then ripples to every call site.
extension PlinthThemeData on ThemeData {
  PlinthTheme get plinth =>
      extension<PlinthTheme>() ?? PlinthTheme.defaultTheme;
}
