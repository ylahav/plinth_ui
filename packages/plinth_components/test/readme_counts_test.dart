// The component count appears on three pub.dev pages and drifted on two
// of them: plinth_components said 51 and plinth_core said "45+" while
// the library held 115. Both are the first line a prospective adopter
// reads, and both undersold it by more than half for months, because a
// number in prose has nothing keeping it honest.
//
// docs/COMPONENTS.md is the maintained list — one heading per component
// — so it is the source of truth here, and these fail when a README
// disagrees with it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Walks up from the test's working directory to the repository root,
/// so this works under `flutter test` from either the package or the
/// workspace.
Directory _repoRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}/docs/COMPONENTS.md').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      fail('could not find docs/COMPONENTS.md above ${Directory.current}');
    }
    dir = parent;
  }
  return dir;
}

void main() {
  final root = _repoRoot();

  final documented = File('${root.path}/docs/COMPONENTS.md')
      .readAsLinesSync()
      .where((l) => RegExp(r'^#{2,3} `?Plinth').hasMatch(l))
      .length;

  test('COMPONENTS.md still lists a plausible number of components', () {
    // Guards the guard: if the heading pattern ever stops matching, the
    // count collapses to zero and every assertion below passes for the
    // wrong reason.
    expect(documented, greaterThan(100),
        reason: 'the heading pattern probably stopped matching');
  });

  test('plinth_components README states the documented count', () {
    final readme = File('${root.path}/packages/plinth_components/README.md')
        .readAsStringSync();
    expect(readme, contains('$documented themeable Flutter widgets'),
        reason: 'COMPONENTS.md documents $documented components; the '
            'README opening line disagrees, and it is the first thing '
            'shown on pub.dev');
  });

  test('the attribution buckets still add up to the total', () {
    // The root README and the claims gate both split the total three
    // ways: tracking @mantine/core, answering a Flutter-only question,
    // and found by using the library. 112 + 5 = 117 was true until
    // PlinthClock, and the README said "the rest answer questions only
    // Flutter has" for one release after that stopped being so. Prose
    // sums stop adding up silently.
    for (final file in ['README.md', 'docs/ROADMAP.md']) {
      final text = File('${root.path}/$file')
          .readAsStringSync()
          .replaceAll(RegExp(r'\s+'), ' ');
      final buckets =
          RegExp(r'112 (?:components track|tracking)').allMatches(text).length;
      expect(buckets, greaterThan(0),
          reason: '$file no longer states the Mantine-tracking count');
    }

    // The three buckets are 112 / 5 / 1 against a documented total.
    expect(112 + 5 + 1, documented,
        reason: 'COMPONENTS.md documents $documented components, but the '
            'attribution split quoted in README.md and docs/ROADMAP.md '
            'sums to ${112 + 5 + 1}. One of them is now wrong — a new '
            'component belongs in a bucket, and the prose has to say '
            'which');
  });

  test('plinth_core README states the documented count', () {
    final readme =
        File('${root.path}/packages/plinth_core/README.md').readAsStringSync();
    // Core points at the others, so it names everything but the three
    // it lists by hand.
    expect(readme, contains('and ${documented - 3} others'),
        reason: 'COMPONENTS.md documents $documented components, so core '
            'should name ${documented - 3} beyond the three it lists');
  });
}
