// Every widget in the input family that owns a text field should expose
// `autofocus`, and the exclusions should be stated rather than implied.
//
// This exists because the gap it guards was found by an app, not by this
// repo: `PlinthTextInput` had neither `autofocus` nor `onSubmitted` until
// bClock's one-field dialogs regressed against the Material `TextField`
// they replaced. Nine siblings had the same hole and nothing noticed,
// because no test asked the family a question — each widget only ever
// tested itself.
//
// A static check rather than a widget test: the point is coverage of the
// family, which no amount of per-widget testing gives you.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Owns a text field and should therefore take `autofocus`.
const _fields = {
  'plinth_text_input',
  'plinth_password_input',
  'plinth_number_input',
  'plinth_mask_input',
  'plinth_color_input',
  'plinth_textarea',
  'plinth_json_input',
  'plinth_tags_input',
  'plinth_pin_input',
  'plinth_autocomplete',
};

/// Owns no text field of its own, with the reason it does not.
const _exempt = {
  'plinth_pills_input':
      'a Stateless container for pills; the caller supplies the field',
  'plinth_file_input': 'a button and a drop zone, with no text entry',
};

/// Takes `autofocus` but deliberately not `onSubmitted`, with the reason.
/// Each reason is also asserted in the widget's own doc comment, so the
/// decision survives somebody reading only the source.
const _noSubmit = {
  'plinth_textarea': 'multiline',
  'plinth_json_input': 'multiline',
  'plinth_tags_input': 'Enter already',
  'plinth_pin_input': 'onCompleted',
};

String _source(String name) =>
    File('lib/src/widgets/$name.dart').readAsStringSync();

void main() {
  test('the widget list still matches what is on disk', () {
    // Guards the guard: a renamed or new input file should show up here
    // rather than silently dropping out of coverage.
    final onDisk = Directory('lib/src/widgets')
        .listSync()
        .map((e) => e.uri.pathSegments.last)
        .where((n) => n.endsWith('.dart'))
        .map((n) => n.substring(0, n.length - 5))
        .where((n) => n.contains('input') || n == 'plinth_textarea')
        .toSet();

    expect(onDisk.difference(_fields.union(_exempt.keys.toSet())), isEmpty,
        reason: 'a new input widget is not classified in input_family_test — '
            'decide whether it owns a text field, and whether Enter means '
            'anything in it');
  });

  group('every input that owns a field takes autofocus', () {
    for (final name in _fields) {
      test(name, () {
        expect(_source(name), contains('this.autofocus'),
            reason: '$name owns a text field, so a modal built around it '
                'should be able to focus it on open');
      });
    }
  });

  group('and the ones that do not are exempt for a stated reason', () {
    _exempt.forEach((name, why) {
      test('$name — $why', () {
        expect(_source(name), isNot(contains('this.autofocus')),
            reason: 'if $name grew a text field, it belongs in _fields');
      });
    });
  });

  group('onSubmitted is absent only where Enter is already spoken for', () {
    for (final name in _fields) {
      final reason = _noSubmit[name];
      test(name, () {
        final src = _source(name);
        if (reason == null) {
          expect(src, contains('this.onSubmitted'),
              reason: '$name has a free Enter key and should submit on it');
        } else {
          expect(src, isNot(contains('this.onSubmitted')),
              reason: '$name must not take onSubmitted ($reason)');
          // Mentioned in prose while absent from the constructor: the
          // omission has to be argued somewhere a reader will find it.
          // Keyed on the identifier rather than on a particular phrasing,
          // so rewording a doc comment does not fail the build.
          expect(src, contains('onSubmitted'),
              reason: "$name omits onSubmitted and its doc comment never "
                  'mentions it — an absent parameter with no explanation '
                  'reads as an oversight and gets "fixed"');
        }
      });
    }
  });
}
