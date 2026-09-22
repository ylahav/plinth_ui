// Writes docs/TOKENS.md.
//
// Run explicitly — it writes a file, so like `generate_screenshots.dart`
// it lives outside `test/` and is not picked up by `melos run test`:
//
//     cd packages/plinth_components
//     flutter test tool/generate_token_usage.dart
//
// `flutter test` rather than `dart run` because the values half needs
// `PlinthTheme`, which imports Flutter.
//
// The scan itself lives in `token_usage.dart` so that
// `token_usage_fresh_test.dart` can call it without spawning a second
// `flutter` process — see the note there.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'token_usage.dart';

void main() {
  test('write docs/TOKENS.md', () {
    final doc = buildTokenUsageDoc();
    File(tokensDocPath).writeAsStringSync(doc);
    // ignore: avoid_print
    print('Wrote docs/TOKENS.md (${doc.length} bytes).');
  });
}
