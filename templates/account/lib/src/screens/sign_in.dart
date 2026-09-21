/// The way in, and the way it fails.
///
/// `PlinthSignInBlock.error` is the parameter doing the work here. A
/// wrong password is not a malformed password, so it renders as an
/// alert about the attempt rather than as an error on the field — a
/// field-level error would tell a screen reader the password is invalid
/// when the password was typed perfectly and the account simply is not
/// that one.
library;

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

import '../session.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(theme.space(6)),
          child: PlinthSplitAuthBlock(
            height: 460,
            decoration: Padding(
              padding: EdgeInsets.all(theme.space(8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlinthTitle('Keystone', order: 2),
                  SizedBox(height: theme.space(3)),
                  const PlinthText(
                    'Accounts, teams and the permissions between them.',
                  ),
                ],
              ),
            ),
            child: PlinthSignInBlock(
              title: 'Sign in',
              subtitle: 'The password is “plinth”.',
              error: session.error,
              onSubmit: session.busy
                  ? null
                  : (values) => session.signIn(values.email, values.password),
              footer: PlinthAnchor('Create an account', onTap: () {}),
            ),
          ),
        ),
      ),
    );
  }
}
