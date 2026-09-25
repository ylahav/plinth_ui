// The claims gate in docs/ROADMAP.md said "43 blocks" while the barrel
// exported 41, and "24 test files" while there were 25. Nothing was
// checking either, so both drifted the way plinth_components' README
// count drifted before readme_counts_test.dart went in — see the note
// at the top of that file.
//
// The barrel is the source of truth for what ships: a block nobody can
// import is not a block.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Directory _repoRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}/docs/ROADMAP.md').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      fail('could not find docs/ROADMAP.md above ${Directory.current}');
    }
    dir = parent;
  }
  return dir;
}

int _exports(String path) => File(path)
    .readAsLinesSync()
    .where((l) => l.startsWith("export 'src/"))
    .length;

int _testFiles(String dir) => Directory(dir)
    .listSync()
    .where((e) => e.path.endsWith('_test.dart'))
    .length;

void main() {
  final root = _repoRoot();
  // Whitespace-collapsed, because the gate is hard-wrapped and a claim
  // can straddle a newline. Matching the raw text would make these
  // tests fail on a reflow that changed nothing.
  final roadmap = File('${root.path}/docs/ROADMAP.md')
      .readAsStringSync()
      .replaceAll(RegExp(r'\s+'), ' ');

  final blocks =
      _exports('${root.path}/packages/plinth_blocks/lib/plinth_blocks.dart');
  final charts =
      _exports('${root.path}/packages/plinth_charts/lib/plinth_charts.dart');
  final blockTests = _testFiles('${root.path}/packages/plinth_blocks/test');
  final chartTests = _testFiles('${root.path}/packages/plinth_charts/test');

  test('the barrels export a plausible number of things', () {
    // Guards the guard: if the export pattern stops matching, every
    // assertion below would compare zero against zero.
    expect(blocks, greaterThan(20),
        reason: 'the export pattern probably stopped matching');
    expect(charts, greaterThan(2));
  });

  test('the claims gate states the exported block and chart counts', () {
    expect(
      roadmap,
      contains('*$blocks blocks in `plinth_blocks` and $charts charts in '
          '`plinth_charts`'),
      reason: 'the barrel exports $blocks blocks and $charts charts; the '
          'claims gate in docs/ROADMAP.md disagrees, and the README '
          'quotes it',
    );
  });

  test('and the test-file counts behind them', () {
    expect(
      roadmap,
      contains('with $blockTests and $chartTests test files behind them.'),
      reason: 'there are $blockTests block and $chartTests chart test '
          'files; the claims gate in docs/ROADMAP.md disagrees',
    );
  });
}
