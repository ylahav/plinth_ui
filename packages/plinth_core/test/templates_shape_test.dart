// The four starters in templates/ share a shape, and that shape is a
// contract — see docs/BUILDING_A_TEMPLATE.md, which is derived from them.
//
// The three theme assertions are the part worth guarding. They are what
// make rebrand survival checkable rather than claimed: the brand is
// exactly what was asked for, every domain value has a role, and every
// role is readable in both themes. A fifth template written by reading
// the other four would plausibly keep the widget tests and drop these,
// because nothing would complain.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Directory _repoRoot() {
  var dir = Directory.current;
  while (!Directory('${dir.path}/templates').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      fail('could not find templates/ above ${Directory.current}');
    }
    dir = parent;
  }
  return dir;
}

/// Present in every template, whatever the app does.
const _fixedFiles = [
  'pubspec.yaml',
  'analysis_options.yaml',
  '.gitignore',
  'README.md',
  'lib/main.dart',
  'lib/src/theme.dart',
];

/// The three assertions, as patterns rather than strings — each is worded
/// for its own domain ("every order status is a declared role" against
/// "every section in the content is declared in the theme").
const _contract = <String, String>{
  'the brand is exactly what was asked for':
      r"the brand colour is the one the theme paints",
  'every domain value has a declared role': r"every .*declared",
  'every role is readable in both themes':
      r"clear the contrast floor on both surfaces",
};

void main() {
  final root = _repoRoot();
  final templates = Directory('${root.path}/templates')
      .listSync()
      .whereType<Directory>()
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('there are templates to check', () {
    // Guards the guard: an empty list makes every group below vacuous.
    expect(templates.length, greaterThanOrEqualTo(4),
        reason: 'templates/ should hold at least the four starters');
  });

  for (final dir in templates) {
    final name = dir.path.split(RegExp(r'[/\\]')).last;

    group('templates/$name', () {
      for (final file in _fixedFiles) {
        test('has $file', () {
          expect(File('${dir.path}/$file').existsSync(), isTrue,
              reason: 'every template has this — see '
                  'docs/BUILDING_A_TEMPLATE.md');
        });
      }

      test('has exactly one test file, named after itself', () {
        final tests = Directory('${dir.path}/test')
            .listSync()
            .where((e) => e.path.endsWith('_test.dart'))
            .toList();
        expect(tests, hasLength(1));
        expect(tests.single.path, endsWith('${name}_test.dart'));
      });

      test('is not publishable', () {
        // A starter is copied, not depended on.
        expect(File('${dir.path}/pubspec.yaml').readAsStringSync(),
            contains('publish_to: none'));
      });

      test('depends on plinth_blocks and not on plinth_components', () {
        // plinth_blocks re-exports components, which re-exports core, so
        // one dependency reaches all three. Naming components directly
        // means a template can drift onto an older components than the
        // blocks it also uses.
        final pubspec = File('${dir.path}/pubspec.yaml').readAsStringSync();
        expect(pubspec, contains('plinth_blocks:'));
        expect(pubspec, isNot(contains('plinth_components:')));
      });

      group('holds the theme contract', () {
        final source = File('${dir.path}/test/${name}_test.dart');
        final text =
            source.existsSync() ? source.readAsStringSync() : '<missing>';

        _contract.forEach((claim, pattern) {
          test(claim, () {
            expect(text, matches(RegExp(pattern)),
                reason: 'templates/$name/test/${name}_test.dart is missing '
                    'the assertion for "$claim" — this is the contract '
                    'docs/BUILDING_A_TEMPLATE.md describes, and dropping it '
                    'is how a starter ships an unreadable brand');
          });
        });
      });
    });
  }
}
