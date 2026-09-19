// Regenerates `lib/src/showcase/examples_code.dart` from the real
// source of every block in `examples.dart`.
//
// Run it after changing any block:
//
//     cd example && dart run tool/generate_example_code.dart
//
// It writes a file that is committed, rather than generating at build
// time, for the same reason the golden images are committed: `flutter
// run` and the web build should need no code-generation step, and a
// diff should show what changed in the panel. `dart format` is applied
// to the result so the generated file passes `melos run format` like
// everything else.
//
// Forgetting to run this is caught by `test/examples_code_fresh_test.dart`
// in CI, so the failure mode is a red build rather than a stale panel.
import 'dart:io';

import 'example_source.dart';

const _examplesPath = 'lib/src/showcase/examples.dart';
const _outputPath = 'lib/src/showcase/examples_code.dart';

void main(List<String> args) {
  final examplesFile = File(_examplesPath);
  if (!examplesFile.existsSync()) {
    stderr.writeln(
      'Cannot find $_examplesPath — run this from the example/ directory:\n'
      '  cd example && dart run tool/generate_example_code.dart',
    );
    exitCode = 1;
    return;
  }

  final extracted = extractExampleSource(examplesFile.readAsStringSync());
  if (extracted.isEmpty) {
    stderr.writeln('Found no *Example classes in $_examplesPath.');
    exitCode = 1;
    return;
  }

  File(_outputPath).writeAsStringSync(renderExampleCodeLibrary(extracted));

  // The generated file has to satisfy the same formatter as the rest of
  // the repo, and raw strings holding arbitrary source do not reliably
  // come out formatted by construction.
  final formatted = Process.runSync('dart', ['format', _outputPath]);
  if (formatted.exitCode != 0) {
    stderr.writeln('dart format failed on $_outputPath:\n${formatted.stderr}');
    exitCode = 1;
    return;
  }

  stdout.writeln('Wrote ${extracted.length} block sources to $_outputPath.');
}
