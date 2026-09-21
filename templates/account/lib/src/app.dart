/// Signed out or signed in, and the shell for the latter.
///
/// One `ListenableBuilder` on the session decides which of the two the
/// app is showing. That is the whole routing decision, and keeping it in
/// one place is why no screen below here has to ask whether it is
/// allowed to be on screen.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import 'screens/account.dart';
import 'screens/permissions.dart';
import 'screens/security.dart';
import 'screens/sign_in.dart';
import 'session.dart';

class AccountApp extends StatefulWidget {
  const AccountApp({super.key, required this.light, required this.dark});

  final ThemeData light;
  final ThemeData dark;

  @override
  State<AccountApp> createState() => _AccountAppState();
}

class _AccountAppState extends State<AccountApp> {
  final _session = Session();

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Keystone',
        theme: widget.light,
        darkTheme: widget.dark,
        debugShowCheckedModeBanner: false,
        home: ListenableBuilder(
          listenable: _session,
          builder: (context, _) => _session.signedIn
              ? AccountShell(session: _session)
              : SignInScreen(session: _session),
        ),
      );
}

enum _Tab {
  profile('Profile'),
  security('Security'),
  permissions('Permissions');

  const _Tab(this.label);

  final String label;
}

class AccountShell extends StatefulWidget {
  const AccountShell({super.key, required this.session});

  final Session session;

  @override
  State<AccountShell> createState() => _AccountShellState();
}

class _AccountShellState extends State<AccountShell> {
  _Tab _current = _Tab.profile;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;
    final account = widget.session.account!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlinthTopBar(
              brand: const PlinthTopBarBrand(
                title: 'Keystone',
                icon: Icon(Icons.vpn_key_outlined),
              ),
              actions: [
                PlinthAvatar(name: account.name, size: PlinthSize.sm),
                SizedBox(width: theme.space(2)),
                PlinthButton(
                  variant: PlinthVariant.subtle,
                  onPressed: widget.session.signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(theme.space(6)),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PlinthPageHeader(
                          title: 'Account',
                          subtitle: account.email,
                        ),
                        SizedBox(height: theme.space(5)),
                        PlinthTabs<_Tab>(
                          value: _current,
                          onChanged: (tab) => setState(() => _current = tab),
                          tabs: [
                            for (final tab in _Tab.values)
                              PlinthTabItem(tab, tab.label),
                          ],
                        ),
                        SizedBox(height: theme.space(6)),
                        switch (_current) {
                          _Tab.profile => AccountScreen(account: account),
                          _Tab.security =>
                            SecurityScreen(session: widget.session),
                          _Tab.permissions => const PermissionsScreen(),
                        },
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
