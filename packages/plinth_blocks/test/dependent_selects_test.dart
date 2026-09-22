/// The combination that cannot exist, and the silence that hides it.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

const _regions = <String, List<PlinthSelectOption<String>>>{
  'pt': [
    PlinthSelectOption('porto', 'Porto'),
    PlinthSelectOption('lisboa', 'Lisboa'),
  ],
  'es': [
    PlinthSelectOption('madrid', 'Madrid'),
  ],
  'fr': <PlinthSelectOption<String>>[],
};

class _Host extends StatefulWidget {
  const _Host({super.key, this.country = 'pt', this.region});
  final String? country;
  final String? region;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late String? _country = widget.country;
  late String? _region = widget.region;

  String? get country => _country;
  String? get region => _region;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 420,
              child: PlinthDependentSelects<String, String>(
                parentLabel: 'Country',
                childLabel: 'Region',
                parentOptions: const [
                  PlinthSelectOption('pt', 'Portugal'),
                  PlinthSelectOption('es', 'Spain'),
                  PlinthSelectOption('fr', 'France'),
                ],
                parentValue: _country,
                onParentChanged: (v) => setState(() => _country = v),
                childOptionsFor: (p) => _regions[p] ?? const [],
                childValue: _region,
                onChildChanged: (v) => setState(() => _region = v),
              ),
            ),
          ),
        ),
      );
}

List<String> _announcements(WidgetTester tester) {
  final announced = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility, (message) async {
    final m = message as Map<dynamic, dynamic>;
    if (m['type'] == 'announce') {
      announced.add((m['data'] as Map<dynamic, dynamic>)['message'] as String);
    }
    return null;
  });
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility, null));
  return announced;
}

Future<void> _pickCountry(WidgetTester tester, String label) async {
  await tester.tap(find.text('Portugal').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('changing the parent clears a child that no longer applies',
      (tester) async {
    // Porto is not in Spain. Leaving it selected holds a combination
    // that cannot exist.
    final key = GlobalKey<_HostState>();
    await tester.pumpWidget(_Host(key: key, region: 'porto'));
    await tester.pumpAndSettle();
    expect(key.currentState!.region, 'porto');

    await _pickCountry(tester, 'Spain');

    expect(key.currentState!.country, 'es');
    expect(key.currentState!.region, isNull);
  });

  testWidgets('and says so, because the reset is below the fold',
      (tester) async {
    await tester.pumpWidget(const _Host(region: 'porto'));
    await tester.pumpAndSettle();
    final announced = _announcements(tester);

    await _pickCountry(tester, 'Spain');

    expect(
      announced.single,
      contains('Region'),
      reason: 'the child emptied silently',
    );
  });

  testWidgets('a child that still applies is left alone', (tester) async {
    // Not every parent change invalidates the child, and clearing one
    // that was still valid is its own small betrayal.
    final key = GlobalKey<_HostState>();
    await tester.pumpWidget(_Host(key: key, country: 'pt', region: 'porto'));
    await tester.pumpAndSettle();
    final announced = _announcements(tester);

    // Re-picking the same country must not clear anything.
    await _pickCountry(tester, 'Portugal');

    expect(key.currentState!.region, 'porto');
    expect(announced, isEmpty);
  });

  testWidgets('nothing is announced when nothing was chosen', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pumpAndSettle();
    final announced = _announcements(tester);

    await _pickCountry(tester, 'Spain');

    expect(announced, isEmpty, reason: 'announced clearing an empty field');
  });

  testWidgets('a parent with no children disables the child select',
      (tester) async {
    // An enabled select that opens onto nothing tells the user they
    // did something wrong. The truth is the field above is unanswered.
    await tester.pumpWidget(const _Host(country: 'fr'));
    await tester.pumpAndSettle();

    final selects = tester.widgetList<PlinthSelect<String>>(
      find.byType(PlinthSelect<String>),
    );
    expect(selects.last.onChanged, isNull);
    expect(selects.first.onChanged, isNotNull);
  });
}
