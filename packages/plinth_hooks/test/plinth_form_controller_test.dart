import 'package:flutter_test/flutter_test.dart';
import 'package:plinth_hooks/plinth_hooks.dart';

String? _required(Object? v, Map<String, Object?> _) =>
    (v == null || v == '') ? 'Required' : null;

void main() {
  group('PlinthFormController', () {
    test('starts from the initial values, no errors, not dirty', () {
      final form = PlinthFormController(initialValues: {'a': 'x', 'n': 3});
      expect(form.value<String>('a'), 'x');
      expect(form.value<int>('n'), 3);
      expect(form.value<String>('missing'), isNull);
      expect(form.errors, isEmpty);
      expect(form.isDirty, isFalse);
      expect(form.isValid, isTrue);
    });

    test('setValue stores, notifies, and marks dirty; same value is quiet', () {
      final form = PlinthFormController(initialValues: {'a': ''});
      var n = 0;
      form.addListener(() => n++);

      form.setValue('a', 'hi');
      expect(form.values['a'], 'hi');
      expect(form.isDirty, isTrue);
      expect(form.isFieldDirty('a'), isTrue);
      expect(n, 1);

      form.setValue('a', 'hi');
      expect(n, 1, reason: 'unchanged value should not notify');

      form.setValue('a', '');
      expect(form.isDirty, isFalse, reason: 'back to the initial value');
    });

    test('list values compare by content', () {
      final form = PlinthFormController(initialValues: {
        'roles': <String>['a']
      });
      form.setValue('roles', <String>['a']);
      expect(form.isDirty, isFalse);
      form.setValue('roles', <String>['a', 'b']);
      expect(form.isDirty, isTrue);
    });

    test('values is a copy that cannot be edited', () {
      final form = PlinthFormController(initialValues: {'a': 1});
      expect(() => form.values['a'] = 2, throwsUnsupportedError);
    });

    test('validate shows every error at once and returns false', () {
      final form = PlinthFormController(
        initialValues: {'a': '', 'b': '', 'c': 'ok'},
        validators: {'a': _required, 'b': _required, 'c': _required},
      );
      expect(form.validate(), isFalse);
      expect(form.errors, {'a': 'Required', 'b': 'Required'});
      expect(form.error('c'), isNull);
      expect(form.isValid, isFalse);
    });

    test('validate returns true and clears old errors once all are fine', () {
      final form = PlinthFormController(
        initialValues: {'a': ''},
        validators: {'a': _required},
      );
      form.validate();
      form.setValue('a', 'x');
      expect(form.validate(), isTrue);
      expect(form.errors, isEmpty);
    });

    test('the first edit is quiet, the next ones are checked', () {
      final form = PlinthFormController(
        initialValues: {'a': 'x'},
        validators: {'a': _required},
      );
      form.setValue('a', '');
      expect(form.error('a'), isNull, reason: 'first change stays quiet');
      form.setValue('a', 'y');
      form.setValue('a', '');
      expect(form.error('a'), 'Required');
    });

    test('validateOnChange: false waits for validate()', () {
      final form = PlinthFormController(
        initialValues: {'a': 'x'},
        validators: {'a': _required},
        validateOnChange: false,
      );
      form.setValue('a', 'y');
      form.setValue('a', '');
      expect(form.error('a'), isNull);
      form.validate();
      expect(form.error('a'), 'Required');
    });

    test('a showing error clears as soon as the edit fixes it', () {
      final form = PlinthFormController(
        initialValues: {'a': ''},
        validators: {'a': _required},
        validateOnChange: false,
      );
      form.validate();
      expect(form.error('a'), 'Required');
      form.setValue('a', 'x');
      expect(form.error('a'), isNull);
    });

    test('a validator sees the other values', () {
      final form = PlinthFormController(
        initialValues: {'start': 5, 'end': 3},
        validators: {
          'end': (v, all) =>
              (v as int) < (all['start'] as int) ? 'End is before start' : null,
        },
      );
      expect(form.validateField('end'), isFalse);
      expect(form.error('end'), 'End is before start');
      form.setValue('end', 9);
      expect(form.validateField('end'), isTrue);
    });

    test('setValidator adds and removes a rule', () {
      final form = PlinthFormController(initialValues: {'a': ''});
      expect(form.validate(), isTrue);
      form.setValidator('a', _required);
      expect(form.validate(), isFalse);
      form.setValidator('a', null);
      expect(form.validate(), isTrue);
    });

    test('setError shows a message the validators did not make', () {
      final form = PlinthFormController(initialValues: {'email': 'a@b'});
      form.setError('email', 'Already registered');
      expect(form.error('email'), 'Already registered');
      expect(form.isValid, isFalse);
      form.clearErrors();
      expect(form.isValid, isTrue);
    });

    test('reset restores values and forgets errors and touched fields', () {
      final form = PlinthFormController(
        initialValues: {'a': 'x'},
        validators: {'a': _required},
      );
      form.setValue('a', 'y');
      form.setValue('a', '');
      expect(form.error('a'), 'Required');

      form.reset();
      expect(form.values, {'a': 'x'});
      expect(form.errors, isEmpty);
      expect(form.isDirty, isFalse);

      form.setValue('a', '');
      expect(form.error('a'), isNull,
          reason: 'first edit after reset is quiet');
    });
  });
}
