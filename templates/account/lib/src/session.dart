/// Who is signed in, and how that changes.
///
/// A `ChangeNotifier` rather than anything larger, because the point of
/// this file is the *shape* — one object owns the answer to "is anyone
/// signed in", and the widget tree asks it rather than each screen
/// keeping its own flag. Swap the body for your auth SDK; the rest of
/// the app does not change.
library;

import 'package:flutter/foundation.dart';

/// A signed-in person.
class Account {
  const Account({
    required this.name,
    required this.email,
    required this.role,
    required this.twoFactor,
  });

  final String name;
  final String email;

  /// A key in `teamRoles` in `theme.dart`, not a colour.
  final String role;
  final bool twoFactor;

  Account copyWith({bool? twoFactor}) => Account(
        name: name,
        email: email,
        role: role,
        twoFactor: twoFactor ?? this.twoFactor,
      );
}

/// A sign-in that can fail, because one that cannot is not worth
/// starting from.
///
/// The interesting case is the wrong password: it has to surface as an
/// error on the *attempt*, not on the password field. Attaching it to
/// the field tells a screen reader the password is malformed when the
/// password was fine and the account was not.
class Session extends ChangeNotifier {
  Account? _account;
  String? _error;
  bool _busy = false;

  Account? get account => _account;
  String? get error => _error;
  bool get busy => _busy;
  bool get signedIn => _account != null;

  /// The only password this demo accepts. Yours will not be a constant.
  static const _password = 'plinth';

  Future<void> signIn(String email, String password) async {
    _error = null;
    _busy = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (password != _password) {
      _error = 'That email and password do not match an account.';
      _busy = false;
      notifyListeners();
      return;
    }

    _account = Account(
      name: 'Ada Okafor',
      email: email.isEmpty ? 'ada@example.com' : email,
      role: 'owner',
      twoFactor: false,
    );
    _busy = false;
    notifyListeners();
  }

  void signOut() {
    _account = null;
    _error = null;
    notifyListeners();
  }

  void setTwoFactor({required bool on}) {
    final current = _account;
    if (current == null) return;
    _account = current.copyWith(twoFactor: on);
    notifyListeners();
  }
}

/// One member of the team, for the permissions screen.
class Member {
  const Member({
    required this.name,
    required this.email,
    required this.role,
    required this.lastSeen,
  });

  final String name;
  final String email;
  final String role;
  final String lastSeen;
}

const team = <Member>[
  Member(
    name: 'Ada Okafor',
    email: 'ada@example.com',
    role: 'owner',
    lastSeen: 'Now',
  ),
  Member(
    name: 'Jun Park',
    email: 'jun@example.com',
    role: 'admin',
    lastSeen: '2 hours ago',
  ),
  Member(
    name: 'Mira Haddad',
    email: 'mira@example.com',
    role: 'member',
    lastSeen: 'Yesterday',
  ),
  Member(
    name: 'Tom Ellery',
    email: 'tom@example.com',
    role: 'invited',
    lastSeen: 'Never',
  ),
];
