/// Holds `docs/PUBLISHING.md`'s state table to the pubspecs it claims
/// to describe.
///
/// That table went stale twice: it said `1.0.0` through two releases,
/// then carried `1.2.0` in its right-hand column through the whole of
/// 1.3.0's development. The file says so about itself, and until now
/// the remedy on offer was "update it when you publish" — which is the
/// same instruction that had already failed twice.
///
/// Only the **repo** column is checkable here. What is actually on
/// pub.dev cannot be known without asking pub.dev, and a test that made
/// a network call to find out would fail offline, in CI, and in a
/// sandbox, for reasons unrelated to the change under test. That column
/// stays a human promise; this one does not.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Walks up from wherever the runner started until the repo root.
Directory _repoRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    if (File('${dir.path}/melos.yaml').existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError('could not find the repo root from ${Directory.current}');
}

void main() {
  final root = _repoRoot();
  final doc = File('${root.path}/docs/PUBLISHING.md').readAsStringSync();

  /// `| `plinth_core` | **1.2.0** | 1.3.0 |` → ('plinth_core', '1.3.0')
  final rows = RegExp(
    r'^\|\s*`(plinth_\w+)`\s*\|\s*[^|]*\|\s*([0-9]+\.[0-9]+\.[0-9]+|—)\s*\|',
    multiLine: true,
  ).allMatches(doc).map((m) => (m.group(1)!, m.group(2)!)).toList();

  test('the table lists every published-capable package', () {
    final packages = Directory('${root.path}/packages')
        .listSync()
        .whereType<Directory>()
        // `uri.pathSegments` rather than splitting the path: it is
        // already separator-agnostic, and a directory URI ends in an
        // empty segment.
        .map((d) => d.uri.pathSegments.where((s) => s.isNotEmpty).last)
        .where((n) => n.startsWith('plinth_'))
        .toList()
      ..sort();

    final listed = rows.map((r) => r.$1).toList()..sort();
    expect(
      listed,
      packages,
      reason: 'PUBLISHING.md\'s state table and packages/ disagree about '
          'which packages exist',
    );
  });

  test('every "In this repo" version is the pubspec version', () {
    expect(rows, isNotEmpty, reason: 'the state table was not found at all');

    for (final (name, claimed) in rows) {
      final pubspec =
          File('${root.path}/packages/$name/pubspec.yaml').readAsStringSync();
      final actual = RegExp(r'^version:\s*(\S+)', multiLine: true)
          .firstMatch(pubspec)!
          .group(1)!;

      expect(
        claimed,
        actual,
        reason: 'PUBLISHING.md says $name is at $claimed in this repo; '
            'its pubspec says $actual',
      );
    }
  });
}
