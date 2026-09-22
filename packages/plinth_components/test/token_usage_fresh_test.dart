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
// **It builds the document in process and compares strings.** A first
// version shelled out to `flutter test tool/generate_token_usage.dart`
// and deadlocked CI: melos runs packages in parallel, each holding the
// Flutter SDK's startup lock, and a nested `flutter` invocation waits
// for a lock the process around it already holds. Every package sat on
// "Waiting for another flutter command to release the startup lock".
//
// If this fails, you changed a component's token usage and did not
// regenerate:
//
//     cd packages/plinth_components
//     flutter test tool/generate_token_usage.dart
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/token_usage.dart';

void main() {
  test('docs/TOKENS.md is up to date', () {
    final doc = File(tokensDocPath);
    expect(doc.existsSync(), isTrue,
        reason: 'docs/TOKENS.md is missing — run the generator');

    // Nothing is written. The generator returns text, and this
    // compares it to what is committed, so a failing run leaves the
    // working tree exactly as it found it.
    expect(
      buildTokenUsageDoc(),
      doc.readAsStringSync().replaceAll('\r\n', '\n'),
      reason: 'docs/TOKENS.md is behind the source. Regenerate it:\n'
          '  cd packages/plinth_components\n'
          '  flutter test tool/generate_token_usage.dart',
    );
  });
}
