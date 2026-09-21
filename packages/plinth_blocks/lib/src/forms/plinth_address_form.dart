import 'package:flutter/material.dart';
import 'package:plinth_components/plinth_components.dart';

/// What a [PlinthAddressForm] reports.
typedef PlinthAddressValues = ({
  String street,
  String city,
  String postcode,
  String? country,
});

/// A country a [PlinthAddressForm] will accept.
class PlinthAddressCountry {
  const PlinthAddressCountry({
    required this.code,
    required this.label,
    this.postcodeMask,
  });

  /// What comes back in [PlinthAddressValues.country].
  final String code;

  final String label;

  /// The shape of this country's postcode, as a `PlinthMaskInput` mask.
  ///
  /// Null leaves the field unmasked, which is the right default for a
  /// country you have not described: a mask that is wrong rejects real
  /// addresses, and that is worse than no mask at all.
  final String? postcodeMask;
}

/// A postal address.
///
/// ```dart
/// PlinthAddressForm(
///   countries: const [
///     PlinthAddressCountry(code: 'gb', label: 'United Kingdom'),
///     PlinthAddressCountry(code: 'il', label: 'Israel',
///         postcodeMask: '#######'),
///   ],
///   onChanged: (values) => setState(() => _address = values),
/// )
/// ```
///
/// **A fieldset, not a heading above the fields.** The legend names the
/// group for a screen reader too, so a field is announced as "Shipping
/// address, City" rather than as a bare "City" — which matters most on
/// the page that has a billing address under it.
///
/// **The spans are sized to their content.** A postcode box as wide as
/// the street line invites the wrong thing to be typed into it, and a
/// field's width is the only hint about its length that arrives before
/// you start typing.
class PlinthAddressForm extends StatefulWidget {
  const PlinthAddressForm({
    super.key,
    this.onChanged,
    this.legend = 'Address',
    this.streetLabel = 'Street address',
    this.cityLabel = 'City',
    this.postcodeLabel = 'Postcode',
    this.countryLabel = 'Country',
    this.countries = const [],
    this.initialCountry,
    this.width,
  });

  /// Called whenever any field changes.
  final ValueChanged<PlinthAddressValues>? onChanged;

  /// Names the group. Required in spirit — "Address" is a poor legend
  /// on a page with two of them.
  final String legend;

  final String streetLabel;
  final String cityLabel;
  final String postcodeLabel;
  final String countryLabel;

  /// The countries offered. Empty hides the country field entirely,
  /// for a form that only ever ships to one place.
  final List<PlinthAddressCountry> countries;

  /// Which country starts selected, by code.
  final String? initialCountry;

  final double? width;

  @override
  State<PlinthAddressForm> createState() => _PlinthAddressFormState();
}

class _PlinthAddressFormState extends State<PlinthAddressForm> {
  String _street = '';
  String _city = '';
  String _postcode = '';
  late String? _country = widget.initialCountry;

  void _report() => widget.onChanged?.call((
        street: _street,
        city: _city,
        postcode: _postcode,
        country: _country,
      ));

  String? get _mask {
    for (final country in widget.countries) {
      if (country.code == _country) return country.postcodeMask;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mask = _mask;

    final body = PlinthFieldset(
      legend: widget.legend,
      child: PlinthGrid(
        gutter: PlinthSize.sm,
        children: [
          PlinthGridCol(
            span: 12,
            child: PlinthTextInput(
              label: widget.streetLabel,
              onChanged: (v) {
                _street = v;
                _report();
              },
            ),
          ),
          PlinthGridCol(
            span: 12,
            spanXs: 7,
            child: PlinthTextInput(
              label: widget.cityLabel,
              onChanged: (v) {
                _city = v;
                _report();
              },
            ),
          ),
          PlinthGridCol(
            span: 12,
            spanXs: 5,
            child: mask == null
                ? PlinthTextInput(
                    label: widget.postcodeLabel,
                    onChanged: (v) {
                      _postcode = v;
                      _report();
                    },
                  )
                : PlinthMaskInput(
                    // Keyed on the mask so switching country rebuilds
                    // the field rather than leaving the old shape
                    // holding the new country's digits.
                    key: ValueKey(mask),
                    mask: mask,
                    label: widget.postcodeLabel,
                    onChanged: (v) {
                      _postcode = v;
                      _report();
                    },
                  ),
          ),
          if (widget.countries.isNotEmpty)
            PlinthGridCol(
              span: 12,
              child: PlinthSelect<String>(
                label: widget.countryLabel,
                value: _country,
                onChanged: (v) {
                  setState(() => _country = v);
                  _report();
                },
                options: [
                  for (final country in widget.countries)
                    PlinthSelectOption(country.code, country.label),
                ],
              ),
            ),
        ],
      ),
    );

    return widget.width == null
        ? body
        : SizedBox(width: widget.width, child: body);
  }
}
