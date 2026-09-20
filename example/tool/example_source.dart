// Pulls each showcase block's own source out of `examples.dart`.
//
// The "Show code" panel used to be fed by hand-written string literals
// in `examples_code.dart`, transcribed from the widget beside them and
// checked by nothing. They had already drifted three different ways:
//
//  * `SimpleNavbarExample` showed `PlinthText('Acme', ...)` on one line
//    where the formatted source wraps it across two.
//  * Half the snippets stripped the `return` and kept the widget's
//    indentation; the other half kept the `return` and dedented to
//    column zero.
//  * The stateful ones showed a `build` body referring to `_query` and
//    `setState` with no sign of the field or the class — so the thing
//    behind the copy button could not compile if you pasted it.
//
// None of that is anyone's fault: a stale snippet still compiles and
// still renders a working panel, so nothing ever surfaced it. The fix
// is to stop writing it twice. This extracts the real source, and
// `test/examples_code_fresh_test.dart` fails if the committed
// generated file no longer matches it.
//
// Parsed rather than pattern-matched. Brace counting would be close
// enough almost always, and then wrong in exactly the interesting
// cases — a `}` inside a string literal or an interpolation. The
// analyser knows where a declaration ends, so it is used instead.
//
// Lives in `tool/` rather than `lib/` deliberately: this pulls in
// `package:analyzer`, and nothing that the app itself compiles should
// depend on it. The app only ever sees the generated strings.
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Extracts `{'<Name>Example': '<its source>'}` from [source].
///
/// The value is the full text of the block's class, plus its `State`
/// class where it has one — what the demo actually runs, rather than a
/// summary of it. A reader who copies the panel gets something that
/// compiles.
///
/// Throws [FormatException] if [source] does not parse, or if a block's
/// source contains a `'''` that would break out of the generated raw
/// string.
Map<String, String> extractExampleSource(String source) {
  final parsed = parseString(content: source, throwIfDiagnostics: false);
  if (parsed.errors.isNotEmpty) {
    throw FormatException(
      'examples.dart does not parse:\n'
      '${parsed.errors.take(5).join('\n')}',
    );
  }

  // Collected in one pass, then paired, because a `State` class can be
  // declared before the widget it belongs to.
  final widgets = <String, ClassDeclaration>{};
  final states = <String, ClassDeclaration>{};

  for (final declaration in parsed.unit.declarations) {
    if (declaration is! ClassDeclaration) continue;
    // `namePart.typeName` rather than `name`: the analyzer keeps a
    // declaration's identifier behind a `ClassNamePart`, so the name
    // and its type parameters travel together.
    final name = declaration.namePart.typeName.lexeme;

    if (name.endsWith('Example')) {
      widgets[name] = declaration;
    } else if (name.startsWith('_') && name.endsWith('ExampleState')) {
      // `_SimpleNavbarExampleState` -> `SimpleNavbarExample`
      states[name.substring(1, name.length - 'State'.length)] = declaration;
    }
  }

  final result = <String, String>{};

  for (final entry in widgets.entries) {
    final parts = [
      _sourceOf(source, entry.value),
      if (states[entry.key] case final state?) _sourceOf(source, state),
    ];
    final text = parts.join('\n\n');

    if (text.contains("'''")) {
      throw FormatException(
        "${entry.key} contains ''' , which cannot be emitted inside the "
        'generated raw string. Rewrite it with \\" quotes.',
      );
    }
    result[entry.key] = text;
  }

  return result;
}

/// The declaration's text, without any doc comment above it.
///
/// The comments in `examples.dart` explain the block to whoever
/// maintains this repo — which overflow a `PlinthGroup` catches, why a
/// width is what it is. They are not addressed to somebody reading the
/// panel to find out how to use the component, so they are left behind.
String _sourceOf(String source, ClassDeclaration node) => source
    .substring(node.firstTokenAfterCommentAndMetadata.offset, node.end)
    .trimRight();

/// Renders [examples] as the body of `examples_code.dart`.
String renderExampleCodeLibrary(Map<String, String> examples) {
  final keys = examples.keys.toList()..sort();

  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE — DO NOT EDIT BY HAND.')
    ..writeln('//')
    ..writeln('// Written by `tool/generate_example_code.dart` from the real')
    ..writeln('// source of each block in `examples.dart`, so the "Show code"')
    ..writeln('// panel cannot drift from the widget it claims to describe.')
    ..writeln('//')
    ..writeln('// To change what a panel shows, change the block. Then run:')
    ..writeln('//')
    ..writeln('//     cd example && dart run tool/generate_example_code.dart')
    ..writeln('//')
    ..writeln('// `test/examples_code_fresh_test.dart` fails if you forget,')
    ..writeln('// which is the whole point of generating it.')
    ..writeln()
    ..writeln('/// Source of every showcase block, keyed by class name.')
    ..writeln('const Map<String, String> exampleCode = {');

  for (final key in keys) {
    buffer
      ..writeln("  '$key': r'''")
      ..writeln(examples[key])
      ..writeln("''',");
  }

  buffer.writeln('};');
  return buffer.toString();
}
