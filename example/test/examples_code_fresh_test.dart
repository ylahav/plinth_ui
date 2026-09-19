// `examples_code.dart` is generated. This is what makes that true.
//
// The "Show code" panel is only worth having if it shows what the demo
// beside it actually does, and for as long as the snippets were written
// by hand nothing checked that. They drifted — wrapped lines that the
// formatter had since moved, a `return` kept in half the blocks and
// stripped in the other half, and stateful examples whose panels
// referred to fields they never showed.
//
// So the panel's text is now extracted from the block's own source, and
// this fails if the committed generated file has fallen behind. It is
// the same trade the golden images make: a generated artifact is
// committed so the app needs no build step, and a test refuses to let
// the artifact go stale.
//
// If this fails, you changed a block and did not regenerate:
//
//     cd example && dart run tool/generate_example_code.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_example/src/showcase/examples_code.dart';
import 'package:plinth_example/src/showcase/showcase_data.dart';

import '../tool/example_source.dart';

void main() {
  // `flutter test` runs with the package root as the working directory,
  // so these resolve without any path juggling.
  final examplesSource =
      File('lib/src/showcase/examples.dart').readAsStringSync();
  final generated =
      File('lib/src/showcase/examples_code.dart').readAsStringSync();

  test('every block in examples.dart was extracted', () {
    final extracted = extractExampleSource(examplesSource);

    // Guards the suite from passing vacuously if extraction silently
    // started returning nothing.
    expect(extracted, isNotEmpty);
    expect(
      extracted.length,
      equals(exampleCode.length),
      reason: 'extraction found ${extracted.length} blocks but the generated '
          'file holds ${exampleCode.length}',
    );
  });

  test('the committed file matches what the generator would write now', () {
    final expected =
        renderExampleCodeLibrary(extractExampleSource(examplesSource));

    // Compared after normalising line endings: the generator writes
    // whatever the platform uses, and this repo is developed on Windows
    // and built on Linux.
    expect(
      generated.replaceAll('\r\n', '\n').trim(),
      equals(expected.replaceAll('\r\n', '\n').trim()),
      reason: 'examples_code.dart is stale — run\n'
          '  cd example && dart run tool/generate_example_code.dart',
    );
  });

  test('every snippet is the real source, not a paraphrase of it', () {
    // The property the hand-written snippets could not hold: whatever
    // the panel shows appears verbatim in the file the app compiles.
    //
    // Line endings are normalised on both sides. `dart format` rewrites
    // the generated file with LF, including inside the raw strings,
    // while a checkout on Windows has CRLF in `examples.dart` — a
    // difference in the file, not in the code either one describes.
    final source = examplesSource.replaceAll('\r\n', '\n');

    for (final entry in exampleCode.entries) {
      expect(
        source.contains(entry.value.replaceAll('\r\n', '\n').trim()),
        isTrue,
        reason: '${entry.key}: the panel shows text that is not in '
            'examples.dart',
      );
    }
  });

  test('every registered block has a snippet, and every snippet a block', () {
    // The orphan check `section_coverage_test.dart` does for the
    // component tour's `demoCode`, which the blocks never had — an
    // unused key used to sit there unnoticed.
    final registered = {
      for (final category in showcaseCategories)
        for (final subcategory in category.subcategories)
          for (final example in subcategory.examples) example.code,
    };

    expect(registered, hasLength(exampleCode.length));
    for (final code in registered) {
      expect(exampleCode.values, contains(code));
    }
  });

  test('a snippet shows the state a stateful block depends on', () {
    // The concrete regression: this panel used to open with
    // `return SizedBox(...)` referring to `_query` and `setState`, with
    // no field and no class around them.
    final searchBar = exampleCode['SearchBarExample'];

    expect(searchBar, isNotNull);
    expect(searchBar, contains('class SearchBarExample'));
    expect(searchBar, contains('class _SearchBarExampleState'));
    expect(searchBar, contains("String _query = ''"));
  });
}
