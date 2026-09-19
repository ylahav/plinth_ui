// The rebrand control — the demo's whole argument in one widget.
//
// Every component library looks good in the palette its designer chose.
// The question an adopter actually has is what happens to it in *their*
// brand colour, and the usual answer is that the text on a filled button
// stops being readable, quietly, because the foreground was a constant.
//
// So this lets anyone re-skin the entire app from the header and watch
// the contrast readout stay above the AA floor while they do it —
// including with colours chosen to be hostile. Nothing here special-
// cases anything: it swaps one ramp and lets `readableOn` and
// `contrastingOn` do what they already do on every page.

import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// Re-skins [base] so its primary ramp is generated from [brand].
///
/// The ramp is *anchored*, so shade 6 comes back as exactly the colour
/// that went in rather than something near it — which is what makes this
/// a rebrand rather than an approximation. Everything else in the theme,
/// including the neutral chrome and the other twelve ramps, is untouched.
///
/// Keyed on [PlinthTheme.primaryColor] rather than the literal `'blue'`
/// so this stays correct if the default theme's primary ever moves, and
/// so it works unchanged on both the light and dark themes.
///
/// A null [brand] returns [base] untouched — the built-in palette is not
/// reconstructed as a special case of itself.
PlinthTheme brandedTheme(PlinthTheme base, Color? brand) {
  if (brand == null) return base;
  return base.copyWith(
    colors: {
      ...base.colors,
      base.primaryColor: PlinthTheme.generateShades(brand),
    },
  );
}

/// The brand colours offered as presets.
///
/// Deliberately not a flattering set. `yellow` and `cyan` are the two
/// the contrast tests single out as *failing* at shade 6 on white —
/// 1.86:1 and 2.79:1 — so picking one is the demonstration, not an edge
/// case to keep people away from.
const List<({String name, Color color})> kBrandPresets = [
  (name: 'Plinth blue', color: Color(0xFF228BE6)),
  (name: 'Violet', color: Color(0xFF7950F2)),
  (name: 'Teal', color: Color(0xFF12B886)),
  (name: 'Tomato', color: Color(0xFFFF3B30)),
  (name: 'Cyan', color: Color(0xFF15AABF)),
  (name: 'Yellow', color: Color(0xFFFFD43B)),
];

/// Lets any page below re-skin the app to a brand colour.
///
/// An `InheritedWidget` for the same reason [ThemeSwitcher] is one: the
/// control sits several levels inside the page tree, and threading a
/// setter down to it is worse than looking it up.
class BrandSwitcher extends InheritedWidget {
  const BrandSwitcher({
    super.key,
    required this.brand,
    required this.onChanged,
    required super.child,
  });

  /// The active brand colour, or null for the built-in palette.
  final Color? brand;
  final ValueChanged<Color?> onChanged;

  static BrandSwitcher of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BrandSwitcher>()!;

  @override
  bool updateShouldNotify(BrandSwitcher oldWidget) => brand != oldWidget.brand;
}

/// The header control: a swatch that opens the picker.
class BrandPickerButton extends StatefulWidget {
  const BrandPickerButton({super.key});

  @override
  State<BrandPickerButton> createState() => _BrandPickerButtonState();
}

class _BrandPickerButtonState extends State<BrandPickerButton> {
  final _popover = PlinthDisclosureController();

  @override
  void dispose() {
    _popover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final switcher = BrandSwitcher.of(context);
    final active = switcher.brand ?? theme.shaded(theme.primaryColor, 6);

    return PlinthPopover(
      controller: _popover,
      width: 320,
      target: PlinthTooltip(
        message: 'Change the brand colour',
        child: PlinthActionIcon(
          semanticLabel: 'Change the brand colour',
          variant: PlinthVariant.subtle,
          onPressed: _popover.toggle,
          icon: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: active,
              shape: BoxShape.circle,
              border: Border.all(color: theme.border),
            ),
          ),
        ),
      ),
      content: _BrandPickerPanel(
        onPicked: (color) => switcher.onChanged(color),
      ),
    );
  }
}

class _BrandPickerPanel extends StatelessWidget {
  const _BrandPickerPanel({required this.onPicked});

  final ValueChanged<Color?> onPicked;

  @override
  Widget build(BuildContext context) {
    final switcher = BrandSwitcher.of(context);

    return PlinthStack(
      children: [
        const PlinthText(
          'Brand colour',
          weight: FontWeight.w600,
        ),
        const PlinthText(
          'Re-skins every page. The readout below is measured, not '
          'claimed.',
          size: PlinthSize.xs,
          color: 'gray',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in kBrandPresets)
              _PresetSwatch(
                name: preset.name,
                color: preset.color,
                selected: switcher.brand == preset.color,
                onPicked: onPicked,
              ),
          ],
        ),
        if (switcher.brand != null)
          PlinthButton(
            variant: PlinthVariant.subtle,
            size: PlinthSize.xs,
            onPressed: () => onPicked(null),
            child: const Text('Reset to the built-in palette'),
          ),
        const PlinthDivider(),
        const ContrastReadout(),
      ],
    );
  }
}

/// One preset, as a focusable swatch.
///
/// Not [PlinthColorSwatch], which takes a palette *key* — these are
/// arbitrary colours that are not in the theme yet, which is the whole
/// point of picking one. [PlinthUnstyledButton] supplies the button
/// semantics and the focus ring that a bare `GestureDetector` would not.
class _PresetSwatch extends StatelessWidget {
  const _PresetSwatch({
    required this.name,
    required this.color,
    required this.selected,
    required this.onPicked,
  });

  final String name;
  final Color color;
  final bool selected;
  final ValueChanged<Color?> onPicked;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return PlinthTooltip(
      message: name,
      child: Semantics(
        selected: selected,
        child: PlinthUnstyledButton(
          onPressed: () => onPicked(color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(theme.radius[PlinthSize.sm]!),
              border: Border.all(
                color: selected ? theme.text : theme.border,
                width: selected ? 2 : 1,
              ),
            ),
            // The tick has to be legible on whatever was picked, which
            // is the same problem the rest of the page has.
            child: selected
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: theme.contrastingOn(color),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// What the current brand actually measures, against the AA floor.
///
/// Two rows, because they are two different claims and only the second
/// one is the interesting one:
///
///  * **Filled** — the label a button picks for itself via
///    `contrastingOn`, on the raw brand colour.
///  * **On the page** — the accent colour `readableOn` resolves for text
///    on the surface. This is the row that moves: ask for yellow and it
///    walks down the ramp until something clears 4.5:1, so the number
///    stays passing while the swatch beside it plainly would not.
class ContrastReadout extends StatelessWidget {
  const ContrastReadout({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final ramp = theme.primaryColor;
    final fill = theme.shaded(ramp, 6);

    final filledRatio = PlinthTheme.contrastRatio(
      theme.contrastingOn(fill),
      fill,
    );
    final accent = theme.readableOn(ramp, theme.surface);
    final accentRatio = PlinthTheme.contrastRatio(accent, theme.surface);
    // What shade 6 would have scored if nothing had resolved it — the
    // number every library that hardcodes its foreground ships with.
    final naiveRatio = PlinthTheme.contrastRatio(fill, theme.surface);

    return PlinthStack(
      children: [
        _ContrastRow(
          label: 'Label on a filled button',
          ratio: filledRatio,
          sample: fill,
          sampleText: theme.contrastingOn(fill),
        ),
        _ContrastRow(
          label: 'Accent text on the page',
          ratio: accentRatio,
          sample: theme.surface,
          sampleText: accent,
        ),
        PlinthText(
          'Shade 6 unresolved would be ${naiveRatio.toStringAsFixed(2)}:1 '
          '— what a fixed foreground ships.',
          size: PlinthSize.xs,
          color: 'gray',
        ),
      ],
    );
  }
}

class _ContrastRow extends StatelessWidget {
  const _ContrastRow({
    required this.label,
    required this.ratio,
    required this.sample,
    required this.sampleText,
  });

  final String label;
  final double ratio;
  final Color sample;
  final Color sampleText;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final passes = ratio >= PlinthContrast.body.ratio;

    return Row(
      children: [
        Container(
          width: 36,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sample,
            borderRadius: BorderRadius.circular(theme.radius[PlinthSize.xs]!),
            border: Border.all(color: theme.border),
          ),
          child: Text(
            'Aa',
            style: TextStyle(
              color: sampleText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PlinthText(label, size: PlinthSize.xs),
        ),
        PlinthBadge(
          '${ratio.toStringAsFixed(2)}:1',
          color: passes ? 'green' : 'red',
        ),
      ],
    );
  }
}
