// `docs/TOKENS.md` is generated. This is what keeps that true.
//
// The file answers "which components read this token", which is the
// question you ask *before* changing a token. An answer that has
// quietly fallen behind the source is worse than no answer, because it
// is the kind you act on.
//
// Same trade as `examples_code.dart` and the golden images: a generated
// artifact is committed so nothing needs a build step, and a test
// refuses to let the artifact go stale.
//
// If this fails, you changed a component's token usage and did not
// regenerate:
//
//     cd packages/plinth_components
//     flutter test tool/generate_token_usage.dart
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('docs/TOKENS.md is up to date', () {
    final doc = File('../../docs/TOKENS.md');
    expect(doc.existsSync(), isTrue,
        reason: 'docs/TOKENS.md is missing — run the generator');

    final committed = doc.readAsStringSync();

    // Regenerate into a scratch copy and compare, rather than
    // re-implementing the scan here. A freshness check that duplicates
    // the generator's logic drifts from it, which is the failure it
    // exists to prevent, one level up.
    final before = committed;
    final result = Process.runSync(
      'flutter',
      ['test', 'tool/generate_token_usage.dart'],
      runInShell: true,
    );
    final after = doc.readAsStringSync();

    // Put it back either way, so a failing test does not also leave a
    // modified working tree behind.
    if (after != before) doc.writeAsStringSync(before);

    expect(result.exitCode, 0,
        reason: 'the generator itself failed:\n${result.stderr}');
    expect(
      after,
      before,
      reason: 'docs/TOKENS.md is behind the source. Regenerate it:\n'
          '  cd packages/plinth_components\n'
          '  flutter test tool/generate_token_usage.dart',
    );
  });
}
