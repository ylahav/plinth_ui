import 'package:flutter/foundation.dart';

/// Checks one field. Gets the field's value and every value in the form (for
/// rules like "end after start"); returns the message to show, or null if the
/// value is fine.
typedef PlinthFieldValidator = String? Function(
    Object? value, Map<String, Object?> values);

/// A `ChangeNotifier`-based equivalent of Mantine's `useForm` — named values,
/// per-field errors, validation, dirty tracking and reset, with no widgets.
/// Bind each input to it by name:
///
/// ```dart
/// final _form = PlinthFormController(
///   initialValues: {'email': '', 'agree': false},
///   validators: {
///     'email': (v, _) => (v as String).contains('@') ? null : 'Not an email',
///   },
/// );
///
/// ListenableBuilder(
///   listenable: _form,
///   builder: (context, _) => PlinthTextInput(
///     label: 'Email',
///     controller: myController,           // or value: _form.value('email')
///     error: _form.error('email'),
///     onChanged: (v) => _form.setValue('email', v),
///   ),
/// );
///
/// if (_form.validate()) save(_form.values);
/// ```
///
/// Errors appear when [validate] runs, or, once a field has been changed,
/// every time it changes again (the "validate on interaction" behaviour; turn
/// it off with `validateOnChange: false`). Fields not listed in
/// `initialValues` can still be set; they start as null.
class PlinthFormController extends ChangeNotifier {
  PlinthFormController({
    Map<String, Object?> initialValues = const {},
    Map<String, PlinthFieldValidator> validators = const {},
    this.validateOnChange = true,
  })  : _initial = Map.of(initialValues),
        _values = Map.of(initialValues),
        _validators = Map.of(validators);

  /// Whether a changed field is re-checked on every change after its first.
  final bool validateOnChange;

  final Map<String, Object?> _initial;
  final Map<String, Object?> _values;
  final Map<String, PlinthFieldValidator> _validators;
  final Map<String, String> _errors = {};
  final Set<String> _touched = {};

  /// A read-only copy of every value, by field name.
  Map<String, Object?> get values => Map.unmodifiable(_values);

  /// A read-only copy of the current errors, by field name. Fields that are
  /// fine are absent.
  Map<String, String> get errors => Map.unmodifiable(_errors);

  /// The value of [name], or null if it was never set.
  T? value<T>(String name) => _values[name] as T?;

  /// The error showing for [name], or null.
  String? error(String name) => _errors[name];

  /// True once any value differs from its initial value.
  bool get isDirty => _values.keys.any(isFieldDirty);

  /// True if [name] differs from its initial value.
  bool isFieldDirty(String name) => !_same(_values[name], _initial[name]);

  /// True if no field has an error.
  bool get isValid => _errors.isEmpty;

  /// Sets [name]. Checks it right away if it was changed before (and
  /// [validateOnChange] is on); the first change stays quiet so a field is
  /// not flagged while it is still being typed into for the first time.
  void setValue(String name, Object? value) {
    if (_values.containsKey(name) && _same(_values[name], value)) return;
    _values[name] = value;
    // An error already showing is re-checked even with validateOnChange off,
    // so it does not outlive the edit that fixes it.
    if ((validateOnChange && _touched.contains(name)) ||
        _errors.containsKey(name)) {
      _check(name);
    }
    _touched.add(name);
    notifyListeners();
  }

  /// For an input that declares its own starting value and rule when it is
  /// built, rather than the form listing them up front. A field that already
  /// has a value keeps it (so a rebuild does not wipe what was typed); the
  /// starting value is remembered for [reset] and [isDirty] only the first
  /// time. Quiet: it does not notify, so it is safe to call from `initState`.
  void register(String name,
      {Object? initialValue, PlinthFieldValidator? validator}) {
    if (!_values.containsKey(name)) {
      _initial[name] = initialValue;
      _values[name] = initialValue;
    }
    if (validator != null) _validators[name] = validator;
  }

  /// Registers (or replaces) the check for [name], for inputs that bring their
  /// own rule. Pass null to remove it. Does not run the check.
  void setValidator(String name, PlinthFieldValidator? validator) {
    if (validator == null) {
      _validators.remove(name);
    } else {
      _validators[name] = validator;
    }
  }

  /// Shows [message] on [name], e.g. one the server sent back.
  void setError(String name, String message) {
    _errors[name] = message;
    notifyListeners();
  }

  /// Removes every error without touching values.
  void clearErrors() {
    if (_errors.isEmpty) return;
    _errors.clear();
    notifyListeners();
  }

  /// Checks one field and shows its error. Returns true if it is fine.
  bool validateField(String name) {
    _check(name);
    notifyListeners();
    return !_errors.containsKey(name);
  }

  /// Checks every field that has a validator, shows all the errors at once
  /// and returns true if there are none.
  bool validate() {
    _errors.clear();
    for (final name in _validators.keys) {
      _touched.add(name);
      _check(name);
    }
    notifyListeners();
    return _errors.isEmpty;
  }

  /// Puts every value back to what it started as and clears errors and the
  /// changed-before memory.
  void reset() {
    _values
      ..clear()
      ..addAll(_initial);
    _errors.clear();
    _touched.clear();
    notifyListeners();
  }

  void _check(String name) {
    final message = _validators[name]?.call(_values[name], values);
    if (message == null) {
      _errors.remove(name);
    } else {
      _errors[name] = message;
    }
  }

  static bool _same(Object? a, Object? b) {
    if (a is List && b is List) return listEquals(a, b);
    return a == b;
  }
}
