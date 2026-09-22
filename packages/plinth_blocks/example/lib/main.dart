// Blocks are whole arrangements, not components.
//
// The point of the package in one screen: a sign-in card, a stat grid
// and a repeatable field group, none of which you assemble yourself.
// Every visible string is a parameter, so nothing here is translated
// by editing the library.
//
// For the full catalogue — 42 blocks, browsable — see
// https://ylahav.github.io/plinth_ui/

import 'package:flutter/material.dart';
import 'package:plinth_blocks/plinth_blocks.dart';

void main() => runApp(const BlocksExampleApp());

class BlocksExampleApp extends StatelessWidget {
  const BlocksExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'plinth_blocks',
        // One registration. Every block below resolves its colour,
        // spacing and radius from this and nothing else.
        theme: ThemeData(extensions: [PlinthTheme.defaultTheme]),
        darkTheme: ThemeData(extensions: [PlinthTheme.darkTheme]),
        home: const _Demo(),
      );
}

class _Demo extends StatefulWidget {
  const _Demo();

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  var _emails = <String>[''];

  @override
  Widget build(BuildContext context) {
    final theme = context.plinth;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(theme.space(6)),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // A whole card: email, password, remember-me, and a
                  // way in. It holds its own field state and reports
                  // the values on submit.
                  PlinthSignInBlock(
                    onSubmit: (values) => debugPrint(values.email),
                    onForgotPassword: () {},
                  ),
                  SizedBox(height: theme.space(8)),

                  // A dashboard figure that knows up from good: a
                  // rising refund rate is a rise *and* bad, and the
                  // tile paints it accordingly.
                  PlinthStatGrid(
                    columns: 2,
                    tiles: const [
                      PlinthStatTile(
                        label: 'Revenue',
                        value: r'$84,210',
                        delta: '12.4%',
                        trend: PlinthTrend.up,
                      ),
                      PlinthStatTile(
                        label: 'Refund rate',
                        value: '2.3%',
                        delta: '0.4pp',
                        trend: PlinthTrend.up,
                        higherIsBetter: false,
                      ),
                    ],
                  ),
                  SizedBox(height: theme.space(8)),

                  // Adding a row focuses it; removing one says what
                  // went and how many are left. Neither is visible in
                  // a screenshot and both decide whether the form is
                  // usable without a mouse.
                  PlinthRepeatableFields(
                    label: 'Invite your team',
                    rowName: 'invitation',
                    count: _emails.length,
                    onAdd: () => setState(() => _emails = [..._emails, '']),
                    onRemove: (i) =>
                        setState(() => _emails = [..._emails]..removeAt(i)),
                    rowBuilder: (context, i) => PlinthTextInput(
                      label: 'Email ${i + 1}',
                      placeholder: 'name@example.com',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
