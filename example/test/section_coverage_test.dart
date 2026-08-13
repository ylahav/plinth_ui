import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_example/main.dart';
import 'package:plinth_example/src/demo_code.dart';

/// Holds the two hand-maintained lists behind the component tour
/// against each other.
///
/// `componentSectionOrder` drives the sidebar nav and `demoCode` fills
/// the "Show code" panels, and nothing else connects them. A section
/// with no snippet still compiles and still renders — as an empty
/// panel — which is exactly the kind of drift that survives review.
void main() {
  test('every section has a code snippet', () {
    final missing =
        componentSectionOrder.where((s) => !demoCode.containsKey(s)).toList();

    expect(
      missing,
      isEmpty,
      reason: 'sections in componentSectionOrder with no demoCode entry: '
          '${missing.join(', ')}',
    );
  });

  test('every snippet belongs to a section', () {
    // The other direction: a snippet left behind after its section was
    // renamed is dead weight nothing would otherwise flag.
    final orphaned =
        demoCode.keys.where((k) => !componentSectionOrder.contains(k)).toList();

    expect(
      orphaned,
      isEmpty,
      reason: 'demoCode entries with no matching section: '
          '${orphaned.join(', ')}',
    );
  });

  test('section titles are unique', () {
    // Titles key both the nav's scroll targets and the snippet map, so
    // a duplicate silently points two sections at one place.
    expect(componentSectionOrder.toSet().length, componentSectionOrder.length);
  });

  test('the tour is not empty', () {
    // Guards against the list being emptied and the suite passing with
    // three vacuous assertions.
    expect(componentSectionOrder.length, greaterThan(100));
  });
}
