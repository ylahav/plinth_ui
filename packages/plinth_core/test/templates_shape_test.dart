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

/// Every public class `plinth_blocks` defines.
Set<String> _blockNames(Directory root) {
  final names = <String>{};
  for (final entity in Directory('${root.path}/packages/plinth_blocks/lib/src')
      .listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    for (final m in RegExp(r'^class\s+(Plinth\w+)', multiLine: true)
        .allMatches(entity.readAsStringSync())) {
      names.add(m.group(1)!);
    }
  }
  return names;
}

/// Every `Plinth*` identifier a template's `lib/` mentions.
Set<String> _used(Directory template) {
  final names = <String>{};
  for (final entity
      in Directory('${template.path}/lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    for (final m
        in RegExp(r'\b(Plinth\w+)\b').allMatches(entity.readAsStringSync())) {
      names.add(m.group(1)!);
    }
  }
  return names;
}

/// The "Blocks it leans on" table in docs/BUILDING_A_TEMPLATE.md, as
/// `{template: {block, ...}}`. Rows whose first cell is not a directory
/// under templates/ are ignored, so the doc's other tables do not match.
Map<String, Set<String>> _documentedBlocks(Directory root) {
  final doc =
      File('${root.path}/docs/BUILDING_A_TEMPLATE.md').readAsLinesSync();
  final out = <String, Set<String>>{};
  for (final line in doc) {
    final row = RegExp(r'^\| `(\w+)` \| (.+) \|\s*$').firstMatch(line);
    if (row == null) continue;
    final name = row.group(1)!;
    if (!Directory('${root.path}/templates/$name').existsSync()) continue;
    out[name] = RegExp(r'`(Plinth\w+)`')
        .allMatches(row.group(2)!)
        .map((m) => m.group(1)!)
        .toSet();
  }
  return out;
}

void main() {
  final root = _repoRoot();
  final blockNames = _blockNames(root);
  final documented = _documentedBlocks(root);
  final templates = Directory('${root.path}/templates')
      .listSync()
      .whereType<Directory>()
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('there are templates to check', () {
    // Guards the guard: an empty list makes every group below vacuous.
    expect(templates.length, greaterThanOrEqualTo(4),
        reason: 'templates/ should hold at least the four starters');
    expect(blockNames.length, greaterThan(20),
        reason: 'the class pattern probably stopped matching plinth_blocks');
    expect(documented, isNotEmpty,
        reason: "the doc's block table stopped parsing");
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

      group('is assembled from the library', () {
        final used = _used(dir);

        test('uses blocks rather than hand-rolling arrangements', () {
          // A starter that composes nothing demonstrates nothing.
          expect(used.intersection(blockNames), isNotEmpty,
              reason: 'templates/$name uses no plinth_blocks widget');
        });

        test('uses every block the guide says it does', () {
          expect(documented, contains(name),
              reason: 'docs/BUILDING_A_TEMPLATE.md has no block row for '
                  'templates/$name');
          for (final block in documented[name] ?? const <String>{}) {
            expect(used, contains(block),
                reason: 'the guide lists $block under templates/$name, and '
                    'the template does not use it');
          }
        });

        test('and the guide names every block it uses', () {
          final missing =
              used.intersection(blockNames).difference(documented[name] ?? {});
          expect(missing, isEmpty,
              reason: 'templates/$name uses ${missing.join(', ')}, which the '
                  "guide's table omits — add them, or the table becomes a "
                  'sample rather than a list');
        });
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
