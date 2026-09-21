// The address form.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

Widget _wrap(Widget child, {double width = 560}) => MaterialApp(
      theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );

const _countries = [
  PlinthAddressCountry(code: 'gb', label: 'United Kingdom'),
  PlinthAddressCountry(code: 'il', label: 'Israel', postcodeMask: '#######'),
];

void main() {
  group('PlinthAddressForm', () {
    testWidgets('it groups the fields under a legend', (tester) async {
      // So a field is announced as "Shipping address, City" rather
      // than as a bare "City".
      await tester.pumpWidget(_wrap(
        const PlinthAddressForm(legend: 'Shipping address'),
      ));

      expect(find.byType(PlinthFieldset), findsOneWidget);
      expect(find.text('Shipping address'), findsOneWidget);
    });

    testWidgets('it reports what was typed', (tester) async {
      PlinthAddressValues? values;

      await tester.pumpWidget(_wrap(
        PlinthAddressForm(onChanged: (v) => values = v),
      ));

      final fields = find.byType(PlinthTextInput);
      await tester.enterText(fields.at(0), '12 Example Street');
      await tester.enterText(fields.at(1), 'Lisbon');
      await tester.pump();

      expect(values?.street, equals('12 Example Street'));
      expect(values?.city, equals('Lisbon'));
    });

    testWidgets('no countries means no country field', (tester) async {
      // For a form that only ever ships to one place.
      await tester.pumpWidget(_wrap(const PlinthAddressForm()));

      expect(find.byType(PlinthSelect<String>), findsNothing);
    });

    testWidgets('a country with no mask leaves the postcode free',
        (tester) async {
      // A mask that is wrong rejects real addresses, which is worse
      // than no mask.
      await tester.pumpWidget(_wrap(
        const PlinthAddressForm(
          countries: _countries,
          initialCountry: 'gb',
        ),
      ));

      expect(find.byType(PlinthMaskInput), findsNothing);
      expect(find.byType(PlinthTextInput), findsNWidgets(3));
    });

    testWidgets('a country with a mask uses it', (tester) async {
      await tester.pumpWidget(_wrap(
        const PlinthAddressForm(
          countries: _countries,
          initialCountry: 'il',
        ),
      ));

      expect(find.byType(PlinthMaskInput), findsOneWidget);
    });

    testWidgets('the postcode field is narrower than the street',
        (tester) async {
      // A postcode box as wide as the street line invites the wrong
      // thing to be typed into it.
      //
      // 720 rather than the default: the `xs` breakpoint is 576, the
      // fieldset's padding comes off before the grid measures, and
      // below that every column is full width by design. The showcase
      // demo this came from was 560 wide — so its carefully chosen 7/5
      // split had never actually rendered.
      await tester.pumpWidget(_wrap(const PlinthAddressForm(), width: 720));

      final fields = find.byType(PlinthTextInput);
      final street = tester.getSize(fields.at(0)).width;
      final postcode = tester.getSize(fields.at(2)).width;

      expect(postcode, lessThan(street));
    });
  });
}
